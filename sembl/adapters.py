"""
sembl.adapters — declarative bounds adapters (Tier 2).

The Spec Kit adapter (sembl.speckit) is the proof that "planning artifact ->
bounds contract" is a *config* problem, not a per-tool coding problem. This
module generalizes it: a small declarative config says which source files to
read, how to pull editable paths out of them, what's forbidden, and the churn
budget. New tools (Tessl, Kiro, AGENTS.md, Cursor rules) become a config entry,
not a new module — that's how the long tail stays free to support.

A config is a dict (loaded from JSON, or YAML when PyYAML is installed):

    {
      "source": ["specs/**/tasks.md"],        # files/globs, repo-relative
      "editable": {"strategy": "path-tokens",  # pull file paths from the text
                   "literal": []},             # plus any always-editable paths
      "forbidden": {"literal": ["migrations/", "infra/"]},
      "churn": {"max_files": "auto"}           # "auto" = files found + 2 (min 3)
    }

Built-in presets cover the head of the distribution; everything else is a custom
`--config` file or a community entry. The only extraction strategy today is
`path-tokens` (reuses the conservative file-path regex from sembl.speckit); more
can be added without changing the contract verify reads.
"""

from __future__ import annotations

import json
from pathlib import Path

from .speckit import extract_paths

# Head-of-distribution presets. Each is just a config dict; `source` globs are
# tried in order and all matches are read. Forbidden defaults are conservative
# (empty) — verify reserves BLOCK for forbidden hits, so the user opts in.
PRESETS: dict = {
    "spec-kit": {
        "source": ["specs/**/tasks.md", "**/tasks.md"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
        "churn": {"max_files": "auto"},
    },
    "kiro": {
        "source": [".kiro/specs/**/tasks.md", ".kiro/**/tasks.md"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
        "churn": {"max_files": "auto"},
    },
    "tessl": {
        "source": [".tessl/**/*.md", "**/*.spec.md", "specs/**/*.spec.*"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
        "churn": {"max_files": "auto"},
    },
    "agents-md": {
        "source": ["AGENTS.md", "CLAUDE.md", ".github/AGENTS.md", ".github/copilot-instructions.md"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
        "churn": {"max_files": "auto"},
    },
    "cursor-rules": {
        "source": [".cursor/rules/**/*.mdc", ".cursor/rules/**/*", ".cursorrules"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
        "churn": {"max_files": "auto"},
    },
}


def preset_names() -> list:
    return sorted(PRESETS)


def build_bounds_from_config(config: dict, root: str | Path) -> tuple[dict, list]:
    """Build a bounds contract from a declarative adapter config.

    Returns (bounds, source_files_used). Unknown strategies fall back to
    path-tokens so a typo degrades to the sane default rather than crashing.
    """
    root = Path(root)
    globs = config.get("source") or []
    if isinstance(globs, str):
        globs = [globs]
    text, used = _read_sources(root, globs)

    editable_rule = config.get("editable") or {"strategy": "path-tokens"}
    editable: list = []
    if editable_rule.get("strategy", "path-tokens") == "path-tokens":
        editable = extract_paths(text)
    for extra in editable_rule.get("literal", []) or []:
        if extra not in editable:
            editable.append(extra)

    forbidden = list((config.get("forbidden") or {}).get("literal", []) or [])

    churn = config.get("churn") or {"max_files": "auto"}
    max_files = churn.get("max_files", "auto")
    if max_files == "auto":
        max_files = max(3, len(editable) + 2)
    budget: dict = {}
    if isinstance(max_files, int) and max_files >= 0:
        budget["max_files"] = max_files
    if isinstance(churn.get("max_lines"), int):
        budget["max_lines"] = churn["max_lines"]

    bounds = {"editable_paths": editable, "forbidden_areas": forbidden, "churn_budget": budget}
    return bounds, used


def bounds_from_preset(name: str, root: str | Path, source: str | None = None) -> tuple[dict, list]:
    """Build bounds from a named preset, optionally overriding its source glob."""
    if name not in PRESETS:
        raise KeyError(f"unknown adapter preset '{name}'. Available: {', '.join(preset_names())}")
    config = dict(PRESETS[name])
    if source:
        config["source"] = [source]
    return build_bounds_from_config(config, root)


def load_config(path: str | Path) -> dict:
    """Load an adapter config from JSON (always) or YAML (if PyYAML is installed)."""
    p = Path(path)
    text = p.read_text(encoding="utf-8", errors="replace")
    if p.suffix.lower() in (".yml", ".yaml"):
        try:
            import yaml  # optional dependency
        except ImportError as exc:  # pragma: no cover - depends on env
            raise RuntimeError(
                "YAML adapter configs need PyYAML (`pip install pyyaml`), or use JSON."
            ) from exc
        return yaml.safe_load(text) or {}
    return json.loads(text)


def _read_sources(root: Path, globs: list) -> tuple[str, list]:
    """Concatenate the text of every file matching the globs (repo-relative)."""
    texts: list = []
    used: list = []
    seen: set = set()
    for pattern in globs:
        has_glob = any(ch in pattern for ch in "*?[")
        p = Path(pattern)
        if p.is_absolute():
            # Glob an absolute pattern from its anchor; else use the path directly.
            matches = (sorted(Path(p.anchor).glob(str(p.relative_to(p.anchor))))
                       if has_glob else ([p] if p.exists() else []))
        elif has_glob:
            matches = sorted(root.glob(pattern))
        else:
            candidate = root / pattern
            matches = [candidate] if candidate.exists() else []
        for match in matches:
            if match.is_file() and match not in seen:
                seen.add(match)
                used.append(match)
                texts.append(match.read_text(encoding="utf-8", errors="replace"))
    return "\n".join(texts), used
