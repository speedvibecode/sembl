"""
sembl.validator — check an executor's work against the Work Order contract.

All checks are deterministic — no LLM, no maintainability judgement. The point
is a contract-aware verifier that catches objective bad-diff classes before a
human approves, NOT a code reviewer (see research note "Deterministic Bad-Diff
Verification"; EXP-01 keeps maintainability out of scope).

Checks:

1. Scope: which files actually changed in the working tree, and is each one
   inside editable_paths, inside forbidden_areas, or out of scope entirely.
2. Report integrity: if the executor produced a structured report claiming
   modified files, compare claims against the real diff. Weak models fabricate
   complete WO-format success reports with zero edits (demo matrix,
   qwen2.5-coder:7b), so self-reports are never trusted.
3. Broad churn: if the Work Order carries a churn_budget, compare the diff's
   file/line count against it (soft — a WARN, never a block).
4. Validation actually ran: if the report claims a check/test passed but carries
   no acceptable run evidence, flag it. Claim-without-evidence only — we score
   "actually ran" vs "claimed to have run", never historical execution (research
   note "Executable Regression Evidence"; safe over-approximation).

The verdict() rolls these into PASS / WARN / BLOCK.
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

    # Broad-churn finding (empty dict unless a churn_budget was set AND exceeded).
    churn_over_budget: dict = field(default_factory=dict)
    # Validation-not-actually-run: checks claimed-passed with no acceptable evidence.
    validation_not_run: list = field(default_factory=list)

    # Hard contract breaches → BLOCK.
    def _blocking(self, policy: str = "strict") -> bool:
        # "strict" (default): any out-of-scope edit BLOCKs.
        # "advisory_scope": out-of-scope edits demote to WARN; only forbidden hits
        #   and fabricated claims BLOCK. (Candidate fix — scope becomes advisory
        #   because auto-generated editable_paths aren't precise enough to gate on.)
        hard = bool(self.forbidden_hits or self.fabricated_claims)
        if policy == "advisory_scope":
            return hard
        return hard or bool(self.out_of_scope)

    # Soft signals → WARN.
    def _warning(self, policy: str = "strict") -> bool:
        soft = bool(self.churn_over_budget or self.validation_not_run or self.unreported_changes)
        if policy == "advisory_scope":
            soft = soft or bool(self.out_of_scope)
        return soft

    def verdict(self, policy: str = "strict") -> str:
        if self._blocking(policy):
            return "BLOCK"
        if self._warning(policy):
            return "WARN"
        return "PASS"

    def reasons(self) -> list:
        """Human-readable reason per active finding, in verdict order."""
        out = []
        if self.forbidden_hits:
            out.append(f"forbidden-area edits: {', '.join(self.forbidden_hits)}")
        if self.out_of_scope:
            out.append(f"out-of-scope edits: {', '.join(self.out_of_scope)}")
        if self.fabricated_claims:
            out.append(f"fabricated claims (reported but unchanged): {', '.join(self.fabricated_claims)}")
        if self.churn_over_budget:
            c = self.churn_over_budget
            parts = []
            if "max_files" in c:
                parts.append(f"{c.get('files')} files > {c.get('max_files')}")
            if "max_lines" in c:
                parts.append(f"{c.get('lines')} lines > {c.get('max_lines')}")
            out.append("churn over budget: " + "; ".join(parts))
        if self.validation_not_run:
            out.append(f"validation claimed but not evidenced: {', '.join(self.validation_not_run)}")
        if self.unreported_changes:
            out.append(f"unreported changes: {', '.join(self.unreported_changes)}")
        return out

    @property
    def ok(self) -> bool:
        # Back-compat: `validate` treated forbidden/out-of-scope/fabrication as fail.
        return not self._blocking()

    def to_dict(self) -> dict:
        import dataclasses
        data = dataclasses.asdict(self)
        data["verdict"] = self.verdict()
        data["reasons"] = self.reasons()
        return data


def validate_against_work_order(
    repo_path: str,
    work_order: dict,
    report: dict | None = None,
    changed_files: list | None = None,
    diff_line_count: int | None = None,
) -> ScopeReport:
    """Check a change against a Work Order contract.

    By default the change is read from the git working tree at `repo_path`. When
    `changed_files` is supplied (e.g. parsed from a PR/patch), that list is used
    instead and git is not consulted — this lets `verify` and experiments score a
    diff without a live checkout. `diff_line_count` feeds the churn check in that
    mode (git mode computes it via numstat).
    """
    root = Path(repo_path)
    editable = [_norm(p) for p in work_order.get("editable_paths") or []]
    forbidden = [_norm(p) for p in work_order.get("forbidden_areas") or []]

    result = ScopeReport()
    from_diff = changed_files is not None
    if from_diff:
        result.changed_files = sorted({_norm(p) for p in changed_files if str(p).strip()})
    else:
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
        result.validation_not_run = _validation_not_run(report)

    line_count = diff_line_count if from_diff else None
    result.churn_over_budget = _churn_over_budget(
        root, result.changed_files, work_order.get("churn_budget"), line_count,
    )
    return result


def _churn_over_budget(
    root: Path, changed_files: list, budget: dict | None, line_count: int | None = None,
) -> dict:
    """Compare diff size against a soft churn_budget; empty dict if within/absent.

    Only evaluated when the Work Order declares a budget. File count comes from
    the already-filtered changed_files; line count from `line_count` when given
    (diff mode), else `git diff HEAD --numstat` (binary files contribute 0).
    Budget is advisory — a WARN, never a block.
    """
    if not isinstance(budget, dict) or not budget:
        return {}
    over: dict = {}
    max_files = budget.get("max_files")
    if isinstance(max_files, int) and max_files >= 0 and len(changed_files) > max_files:
        over["files"] = len(changed_files)
        over["max_files"] = max_files
    max_lines = budget.get("max_lines")
    if isinstance(max_lines, int) and max_lines >= 0:
        lines = line_count if line_count is not None else _git_diff_numstat(root)
        if lines > max_lines:
            over["lines"] = lines
            over["max_lines"] = max_lines
    return over


def _validation_not_run(report: dict) -> list:
    """Checks the report *claims passed* but backs with no acceptable evidence.

    Claim-without-evidence only: we never assert a check did or didn't run in
    history, only that the report asserts success it cannot substantiate. A claim
    is evidenced by a zero/ok exit code, captured output/log text, or a command
    paired with a result. See research note "Executable Regression Evidence".
    """
    flagged = []
    for label, claimed_pass, evidenced in _claimed_validations(report):
        if claimed_pass and not evidenced:
            flagged.append(label)
    # de-dupe, preserve order
    seen, out = set(), []
    for item in flagged:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def _git_changed_files(root: Path) -> list:
    """Modified, staged, and untracked files vs HEAD, repo-relative posix paths.

    Tracked entries are cross-checked against `git diff HEAD --name-only`:
    `git status` reports line-ending-only rewrites (a formatter run on Windows
    can dirty every file in the repo), while git's diff machinery normalizes
    EOLs away. Counting EOL-only files as edits made validate flag ~200
    untouched files on the zod gemini-3-pro cell. Untracked files (never in
    a diff against HEAD) are kept from status.
    """
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

    content_changed: set | None = None
    try:
        diff_proc = subprocess.run(
            ["git", "diff", "HEAD", "--name-only"],
            cwd=str(root), capture_output=True, text=True,
            encoding="utf-8", errors="replace", timeout=30,
        )
        if diff_proc.returncode == 0:
            content_changed = {
                _norm(line.strip().strip('"'))
                for line in diff_proc.stdout.splitlines() if line.strip()
            }
    except Exception:
        pass  # fall back to trusting git status

    files = []
    for line in proc.stdout.splitlines():
        if len(line) < 4:
            continue
        code = line[:2]
        path = line[3:].strip().strip('"')
        if " -> " in path:  # renames: take the new side
            path = path.split(" -> ", 1)[1].strip().strip('"')
        path = _norm(path)
        # Sembl's own output and graph artifacts are not executor work.
        if path == ".sembl" or path.startswith((".sembl/", "graphify-out/")):
            continue
        if not path:
            continue
        if code != "??" and content_changed is not None and path not in content_changed:
            continue  # EOL-only rewrite, not an edit
        files.append(path)
    return sorted(set(files))


def _git_diff_numstat(root: Path) -> int:
    """Total added+deleted lines vs HEAD, excluding Sembl's own artifacts.

    Uses `git diff HEAD --numstat` (tracked changes only — untracked files are
    counted by file, not line, which is fine for a soft budget). Binary files
    report '-' for both columns and contribute 0. EOL-only rewrites normalize to
    0 here, matching the filtering in _git_changed_files.
    """
    try:
        proc = subprocess.run(
            ["git", "diff", "HEAD", "--numstat"],
            cwd=str(root), capture_output=True, text=True,
            encoding="utf-8", errors="replace", timeout=30,
        )
    except Exception:
        return 0
    if proc.returncode != 0:
        return 0

    total = 0
    for line in proc.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        added, deleted, path = parts[0], parts[1], parts[2]
        path = _norm(path.strip().strip('"'))
        if path == ".sembl" or path.startswith((".sembl/", "graphify-out/")):
            continue
        for col in (added, deleted):
            if col.isdigit():
                total += int(col)
    return total


def _claimed_validations(report: dict) -> list:
    """Extract (label, claimed_pass, evidenced) tuples from common report shapes.

    Recognized claims:
      - boolean success flags: tests_passed / all_tests_pass / validation_passed
      - status strings: validation / tests / status == passed/ok/success/green
      - a `checks`/`validations` list of {name/command, status/passed, ...}
    A claim is `evidenced` when the same scope carries an acceptable artifact:
      - exit_code / returncode == 0
      - non-empty output / stdout / log / evidence text
      - a command paired with any of the above
    """
    out: list = []

    def _truthy_pass(value) -> bool:
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return value.strip().lower() in {"pass", "passed", "ok", "success", "green", "true"}
        return False

    def _has_evidence(scope: dict) -> bool:
        for key in ("exit_code", "returncode", "exit_status", "return_code"):
            if scope.get(key) == 0 or scope.get(key) == "0":
                return True
        for key in ("output", "stdout", "log", "logs", "evidence", "transcript", "result"):
            value = scope.get(key)
            if isinstance(value, str) and value.strip():
                return True
            if isinstance(value, (list, dict)) and value:
                return True
        return False

    # Top-level boolean / string success flags. Evidence (if any) lives at top level.
    top_evidenced = _has_evidence(report)
    for key in ("tests_passed", "all_tests_pass", "all_tests_passed",
                "validation_passed", "checks_passed", "tests_pass"):
        if key in report and _truthy_pass(report.get(key)):
            out.append((key, True, top_evidenced))
    for key in ("validation", "tests", "test_status", "validation_status", "status"):
        value = report.get(key)
        if isinstance(value, str) and _truthy_pass(value):
            out.append((key, True, top_evidenced))

    # Structured check lists.
    for list_key in ("checks", "validations", "validation_results", "test_results"):
        items = report.get(list_key)
        if not isinstance(items, list):
            continue
        for item in items:
            if not isinstance(item, dict):
                continue
            name = (item.get("name") or item.get("command") or item.get("check")
                    or item.get("id") or list_key)
            status = item.get("status")
            claimed = _truthy_pass(item.get("passed")) or _truthy_pass(status)
            if claimed:
                out.append((str(name), True, _has_evidence(item)))
    return out


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
    path = str(path).strip().replace("\\", "/")
    while path.startswith("./"):
        path = path[2:]
    return path.rstrip("/")


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
