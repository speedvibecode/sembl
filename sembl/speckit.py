"""
sembl.speckit — turn a GitHub Spec Kit feature into a Sembl bounds contract.

Spec Kit (https://github.com/github/spec-kit) lives upstream of the agent: it
plans *what* to build and writes `specs/<feature>/tasks.md`, where each task
already names the exact file paths it will touch. Sembl lives downstream: it
verifies the agent *stayed in those lines*. This adapter is the bridge — it
reads a `tasks.md` and emits the four-field bounds contract `sembl verify` reads
(see docs/bounds.md).

It is deliberately conservative: it only extracts concrete file paths (an optional
directory prefix plus a `name.ext`), so `src/models/user.py` and a root-level
`index.html` both become editable paths but prose like "the auth module" does not. `forbidden_areas` cannot be inferred
from a task list and is left empty for the human to fill — verify treats scope
as advisory and reserves BLOCK for forbidden hits and fabrication, so an empty
forbidden list is safe, not silently permissive.
"""

from __future__ import annotations

import re
from pathlib import Path

# A concrete file path: zero or more "segment/" parts followed by "name.ext".
# Matched inside backticks or bare prose. The directory prefix is OPTIONAL so a
# bare, root-level file (`index.html`, `snake.js`, `README.md`, `package.json`)
# is captured too — greenfield / root-file specs name those, and the old
# slash-required pattern silently dropped them. Conservative on purpose — we want
# real paths, not every slash-containing token. The extension must begin with a
# letter (`[A-Za-z][A-Za-z0-9]{0,9}`): this is what separates `src/models/user.py`
# from version strings and user-agents like `Werkzeug/2.2.2`, `Python/3.10.4`,
# `HTTP/1.1`, `Chrome/65.0.3325.183`, which EXP-04 showed the old `[A-Za-z0-9]+`
# extension happily matched as if they were files.
_PATH_RE = re.compile(r"(?<![\w./-])((?:[\w.-]+/)*[\w.-]+\.[A-Za-z][A-Za-z0-9]{0,9})")

_ROOT_FILE_EXTENSIONS = {
    "c", "cc", "cpp", "cs", "css", "go", "h", "hpp", "html", "java", "js",
    "json", "jsx", "kt", "kts", "lock", "lua", "mjs", "md", "php", "py",
    "rb", "rs", "scss", "sh", "sql", "swift", "toml", "ts", "tsx", "txt",
    "xml", "yaml", "yml",
}


def extract_paths(text: str, root: "Path | str | None" = None) -> list[str]:
    """Extract unique, order-preserved file paths from spec / task text.

    When `root` is given, candidates are kept only if they resolve to a real file
    under it — the strongest defence against junk bounds. With no `root` (scoring
    free-form issue/PR text where the tree isn't to hand) the regex's letter-led
    extension is the guard.
    """
    base = Path(root) if root is not None else None
    seen: set[str] = set()
    out: list[str] = []
    for match in _PATH_RE.finditer(text):
        path = _norm(match.group(1))
        if not path or path in seen:
            continue
        # Drop obvious non-source noise (URLs already excluded by the lack of a
        # scheme in the regex; skip markdown image/link artifacts just in case).
        if path.startswith(("http:", "https:")):
            continue
        if "/" not in path:
            # A bare, root-level filename. Allowed (greenfield/root-file specs need
            # them), but prose often contains domain names (`example.com`), dotted config
            # keys (`app.mode`), package names (`left.pad`), and abbreviations (`e.g.`).
            # For bare root files, keep a conservative source/config extension allow-list;
            # slash-qualified paths still use the broader regex because the directory
            # prefix is already a strong signal.
            ext = path.rsplit(".", 1)[-1].lower()
            if ext not in _ROOT_FILE_EXTENSIONS:
                continue
        if base is not None and not (base / path).is_file():
            continue
        seen.add(path)
        out.append(path)
    return out


def bounds_from_tasks_text(text: str) -> dict:
    """Build a bounds contract dict from the contents of a Spec Kit tasks.md."""
    editable = extract_paths(text)
    bounds = {
        "editable_paths": editable,
        "forbidden_areas": [],
        # tasks.md enumerates the files, so a file-count budget is grounded;
        # line count can't be inferred and is left out (verify skips it).
        "churn_budget": {"max_files": max(3, len(editable) + 2)},
    }
    return bounds


def find_tasks_file(target: Path) -> Path:
    """Resolve a tasks.md from a file or a Spec Kit directory.

    If `target` is a file, it is used directly. If it's a directory, all
    `tasks.md` under it are collected: exactly one → use it; several → raise with
    the list so the caller can point at a specific file.
    """
    if target.is_file():
        return target
    if not target.exists():
        raise FileNotFoundError(f"path does not exist: {target}")
    candidates = sorted(target.rglob("tasks.md"))
    if not candidates:
        raise FileNotFoundError(f"no tasks.md found under {target}")
    if len(candidates) > 1:
        listing = "\n".join(f"  - {c}" for c in candidates)
        raise ValueError(
            f"multiple tasks.md found under {target}; point --spec-kit at one:\n{listing}"
        )
    return candidates[0]


def bounds_from_spec_kit(target: str | Path) -> tuple[dict, Path]:
    """Read a Spec Kit tasks.md (or feature dir) and return (bounds, source_file)."""
    tasks_file = find_tasks_file(Path(target))
    text = tasks_file.read_text(encoding="utf-8", errors="replace")
    return bounds_from_tasks_text(text), tasks_file


def _norm(path: str) -> str:
    path = str(path).strip().strip("`").replace("\\", "/")
    while path.startswith("./"):
        path = path[2:]
    return path.rstrip("/")
