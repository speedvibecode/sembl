"""
sembl.validator — check an executor's work against the Work Order contract.

Two checks, both deterministic:

1. Scope: which files actually changed in the working tree, and is each one
   inside editable_paths, inside forbidden_areas, or out of scope entirely.
2. Report integrity: if the executor produced a structured report claiming
   modified files, compare claims against the real diff. Weak models fabricate
   complete WO-format success reports with zero edits (demo matrix,
   qwen2.5-coder:7b), so self-reports are never trusted.
"""

from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class ScopeReport:
    changed_files: list = field(default_factory=list)
    in_scope: list = field(default_factory=list)
    forbidden_hits: list = field(default_factory=list)
    out_of_scope: list = field(default_factory=list)

    # Report-integrity findings (empty when no executor report was provided).
    claimed_files: list = field(default_factory=list)
    fabricated_claims: list = field(default_factory=list)   # claimed but not changed
    unreported_changes: list = field(default_factory=list)  # changed but not claimed

    @property
    def ok(self) -> bool:
        return not self.forbidden_hits and not self.out_of_scope and not self.fabricated_claims

    def to_dict(self) -> dict:
        import dataclasses
        return dataclasses.asdict(self)


def validate_against_work_order(
    repo_path: str,
    work_order: dict,
    report: dict | None = None,
) -> ScopeReport:
    root = Path(repo_path)
    editable = [_norm(p) for p in work_order.get("editable_paths") or []]
    forbidden = [_norm(p) for p in work_order.get("forbidden_areas") or []]

    result = ScopeReport()
    result.changed_files = _git_changed_files(root)

    for path in result.changed_files:
        if _matches_any(path, forbidden) and not _matches_any(path, editable):
            result.forbidden_hits.append(path)
        elif _matches_any(path, editable) or _looks_like_test(path):
            result.in_scope.append(path)
        else:
            result.out_of_scope.append(path)

    if report is not None:
        result.claimed_files = [_norm(p) for p in _claimed_files(report)]
        changed = set(result.changed_files)
        result.fabricated_claims = [p for p in result.claimed_files if p not in changed]
        result.unreported_changes = [
            p for p in result.changed_files if p not in set(result.claimed_files)
        ]
    return result


def _git_changed_files(root: Path) -> list:
    """Modified, staged, and untracked files vs HEAD, repo-relative posix paths."""
    try:
        proc = subprocess.run(
            ["git", "status", "--porcelain", "-uall"],
            cwd=str(root), capture_output=True, text=True,
            encoding="utf-8", errors="replace", timeout=30,
        )
    except Exception:
        return []
    if proc.returncode != 0:
        return []
    files = []
    for line in proc.stdout.splitlines():
        if len(line) < 4:
            continue
        path = line[3:].strip().strip('"')
        if " -> " in path:  # renames: take the new side
            path = path.split(" -> ", 1)[1].strip().strip('"')
        if path:
            files.append(_norm(path))
    return sorted(set(files))


def _claimed_files(report: dict) -> list:
    """Extract claimed-modified files from common executor report shapes."""
    claimed = []
    for key in ("files_modified", "files_changed", "files_modified_or_created", "files"):
        value = report.get(key)
        if isinstance(value, list):
            claimed.extend(str(item) for item in value if isinstance(item, (str,)))
    changes = report.get("changes")
    if isinstance(changes, list):
        for item in changes:
            if isinstance(item, dict) and isinstance(item.get("file"), str):
                claimed.append(item["file"])
            elif isinstance(item, str) and ":" in item:
                claimed.append(item.split(":", 1)[0])
    seen, result = set(), []
    for path in claimed:
        path = path.strip()
        if path and path not in seen:
            seen.add(path)
            result.append(path)
    return result


def load_report(path: str) -> dict:
    """Load an executor report file; tolerate a ```json fence around it."""
    raw = Path(path).read_text(encoding="utf-8", errors="replace").strip()
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1] if "\n" in raw else ""
        if raw.rstrip().endswith("```"):
            raw = raw.rstrip()[:-3]
    return json.loads(raw)


def _norm(path: str) -> str:
    return str(path).strip().replace("\\", "/").lstrip("./").rstrip("/")


def _matches_any(path: str, entries: list) -> bool:
    for entry in entries:
        if not entry:
            continue
        if path == entry or path.startswith(entry + "/"):
            return True
    return False


def _looks_like_test(path: str) -> bool:
    lower = path.lower()
    return (
        "/test" in lower
        or lower.startswith("test")
        or lower.startswith("__tests__/")
        or lower.endswith((
            ".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx",
            ".test.js", ".test.jsx", ".spec.js",
            "_test.py", "_test.go",
        ))
    )
