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
import os
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Default scope tolerance (EXP-05, 437 merged PRs): WARN only when MORE THAN a
# quarter of the changed files fall outside declared scope. A fraction scales with
# PR size; a fixed count does not (allowing "1 file" hides a wholesale wrong-area
# change on the many small PRs). At 0.25 the false-alarm rate on good-but-imperfect
# bounds drops to ~0 while genuine wholesale violations are still caught ~81% of the
# time. A contract can override with its own `scope_tolerance`, or set it to `{}`
# for zero tolerance (any out-of-scope edit counts).
DEFAULT_SCOPE_TOLERANCE = {"max_fraction": 0.25}


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
    # Optional scope tolerance from the contract (see _scope_exceeds).
    scope_tolerance: dict = field(default_factory=dict)
    # Gate-contract self-edits: the change modified the very contract judging it
    # (bounds.json / .sembl work-order files / the supplied work-order file). Always
    # a hard breach — a change that can rewrite its own bounds can whitelist anything.
    contract_edits: list = field(default_factory=list)

    def _scope_exceeds(self) -> bool:
        # Whether out-of-scope edits should count toward the verdict. EXP-04/05
        # (437 merged PRs) showed an all-or-nothing scope rule false-alarms on
        # ~94% of legitimate merges: real changes touch a few files no declared
        # bound named (a helper, an incidental edit). docs/changelog/test/generated
        # are already absorbed at classification time; on top of that scope counts
        # only once out-of-scope edits exceed `scope_tolerance` (DEFAULT_SCOPE_
        # TOLERANCE unless the contract overrides). An explicit `{}` means zero
        # tolerance — any out-of-scope edit counts.
        oos = len(self.out_of_scope)
        if oos == 0:
            return False
        tol = self.scope_tolerance or {}
        if not tol:
            return True
        total = len(self.changed_files) or 1
        within = True
        # A malformed contract value (e.g. a string where a number is expected)
        # must never crash the gate with a raw exception — same
        # isinstance-before-compare defensiveness as `_churn_over_budget` below.
        # An unusable value is simply not applied, rather than raising.
        max_files = tol.get("max_files")
        if isinstance(max_files, (int, float)) and oos > max_files:
            within = False
        max_fraction = tol.get("max_fraction")
        if isinstance(max_fraction, (int, float)) and (oos / total) > max_fraction:
            within = False
        return not within

    # Hard contract breaches → BLOCK.
    def _blocking(self, policy: str = "strict") -> bool:
        # "strict" (default): out-of-scope edits (beyond tolerance) BLOCK.
        # "advisory_scope": out-of-scope edits demote to WARN; only forbidden hits
        #   and fabricated claims BLOCK. (Scope is advisory because declared
        #   editable_paths are rarely complete enough to gate on — see EXP-04/05.)
        # contract_edits is hard under EVERY policy: scope may be advisory, but the
        # contract file itself is never editable by the change under review.
        hard = bool(self.forbidden_hits or self.fabricated_claims or self.contract_edits)
        if policy == "advisory_scope":
            return hard
        return hard or self._scope_exceeds()

    # Soft signals → WARN.
    def _warning(self, policy: str = "strict") -> bool:
        soft = bool(self.churn_over_budget or self.validation_not_run or self.unreported_changes)
        if policy == "advisory_scope":
            soft = soft or self._scope_exceeds()
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
        if self.contract_edits:
            out.append("gate-contract self-edit (the change modifies its own "
                       f"bounds/work order): {', '.join(self.contract_edits)}")
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

    def to_dict(self, policy: str = "strict") -> dict:
        import dataclasses
        data = dataclasses.asdict(self)
        data["verdict"] = self.verdict(policy)
        data["reasons"] = self.reasons()
        data["policy"] = policy
        return data


def _is_contract_path(path: str, extra: list) -> bool:
    """Is `path` part of the gate's own contract surface (never the change's to edit)?

    Contract = the bounds/work-order files the verdict is computed FROM: root
    `bounds.json`, `.sembl/bounds.json`, `.sembl/work-orders/`, plus any caller-named
    work-order file (`extra`). Other `.sembl/` content (e.g. a run store's outputs)
    is tool output, not contract — excluded from scope but never flagged.
    """
    folded = _fold(path)
    return (folded in ("bounds.json", ".sembl/bounds.json", ".sembl/work-orders")
            or folded.startswith(".sembl/work-orders/")
            or any(folded == _fold(str(entry)) for entry in extra))


def validate_against_work_order(
    repo_path: str,
    work_order: dict,
    report: dict | None = None,
    changed_files: list | None = None,
    diff_line_count: int | None = None,
    contract_paths: list | None = None,
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
    contract = [_norm(p) for p in (contract_paths or []) if str(p).strip()]
    from_diff = changed_files is not None
    if from_diff:
        seen = sorted({_norm(p) for p in changed_files if str(p).strip()})
        result.contract_edits = [p for p in seen if _is_contract_path(p, contract)]
        result.changed_files = [p for p in seen if not _is_contract_path(p, contract)]
    else:
        hits: list = []
        result.changed_files = _git_changed_files(root, contract_extra=contract,
                                                   contract_hits=hits)
        result.contract_edits = hits

    if "scope_tolerance" in work_order:
        result.scope_tolerance = dict(work_order.get("scope_tolerance") or {})
    else:
        result.scope_tolerance = dict(DEFAULT_SCOPE_TOLERANCE)
    for path in result.changed_files:
        if _matches_any(path, forbidden) and not _matches_any(path, editable):
            result.forbidden_hits.append(path)
        elif (
            _matches_any(path, editable)
            or _looks_like_test(path)
            or _looks_like_generated(path)
            or _looks_like_docs(path)
        ):
            result.in_scope.append(path)
        else:
            result.out_of_scope.append(path)

    if report is not None:
        result.claimed_files = [_norm(p) for p in _claimed_files(report)]
        changed = {_fold(p) for p in result.changed_files}
        result.fabricated_claims = [
            p for p in result.claimed_files if _fold(p) not in changed
        ]
        claimed = {_fold(p) for p in result.claimed_files}
        result.unreported_changes = [
            p for p in result.changed_files if _fold(p) not in claimed
        ]
        result.validation_not_run = _validation_not_run(report)

    line_count = diff_line_count if from_diff else None
    result.churn_over_budget = _churn_over_budget(
        root, result.changed_files, work_order.get("churn_budget"), line_count,
    )
    return result


def parse_unified_diff(text: str) -> tuple[list, int]:
    """Parse a unified diff / .patch into (changed_files, added+deleted lines).

    Lets `verify` score a PR or patch without a live checkout (CI, code review).
    Paths come from `+++ b/<path>` (the post-image, authoritative for the new
    name), from `rename to <path>` / `copy to <path>` (a pure rename/copy has no
    content diff, so no `+++`/`---` lines at all — these are the only unambiguous
    source), and from `diff --git a/<old> b/<new>` headers as a fallback (which
    also catches deletions where the post-image is /dev/null). The `diff --git`
    line is naively space-split and is therefore AMBIGUOUS for a path containing
    a space (`a/x y b/x y` can't be split back into `x y`/`x y` in general) — a
    forbidden-area rename with a space could otherwise degrade to a silently
    dropped/truncated path (codex review finding); `rename to`/`copy to` give the
    exact new path unambiguously in exactly the case that matters (a pure rename
    has nothing else to parse). `a/`/`b/` prefixes and surrounding quotes are
    stripped; `/dev/null` is ignored. Line count sums content `+`/`-` lines,
    excluding the `+++`/`---` file headers — matching the numstat-based budget
    used in working-tree mode.
    """
    files: list = []
    seen: set = set()
    added = deleted = 0
    last_a = ""           # most recent `--- a/<path>` (post-image may be /dev/null)
    cur_generated = False  # don't count churn lines for generated/lockfiles

    def _add(path: str) -> None:
        if str(path).strip().strip('"') in ("/dev/null", "dev/null"):
            return                       # add/delete sentinel, not a file
        path = _strip_ab(path)
        if path and path not in seen:
            seen.add(path)
            files.append(path)

    for line in text.splitlines():
        if line.startswith("diff --git "):
            parts = line.split(" ")
            if len(parts) >= 4:
                _add(parts[-1])   # b/<new> — survives renames and deletions
        elif line.startswith("rename to ") or line.startswith("copy to "):
            # Unambiguous single path — the authoritative new name for a pure
            # rename/copy, which the `diff --git` line above can mis-split when
            # the path contains a space.
            _add(line.split(" to ", 1)[1].strip())
        elif line.startswith("--- "):
            last_a = _strip_ab(line[4:].strip().split("\t", 1)[0])
        elif line.startswith("+++ "):
            post = line[4:].strip().split("\t", 1)[0]
            _add(post)
            # a deletion's post-image is /dev/null — fall back to the pre-image path
            cur = _strip_ab(post) if post.strip() != "/dev/null" else last_a
            cur_generated = _looks_like_generated(cur) if cur else False
        elif line.startswith("+") and not line.startswith("+++"):
            if not cur_generated:
                added += 1
        elif line.startswith("-") and not line.startswith("---"):
            if not cur_generated:
                deleted += 1
    return sorted(files), added + deleted


def _strip_ab(path: str) -> str:
    path = str(path).strip().strip('"')
    if path[:2] in ("a/", "b/"):
        path = path[2:]
    return _norm(path)


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
    # Churn measures human-authored change: generated/lockfiles don't count.
    counted = [f for f in changed_files if not _looks_like_generated(f)]
    max_files = budget.get("max_files")
    if isinstance(max_files, int) and max_files >= 0 and len(counted) > max_files:
        over["files"] = len(counted)
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


def _git_changed_files(root: Path, contract_extra: list | None = None,
                       contract_hits: list | None = None) -> list:
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
    except Exception as exc:
        # A failure here means we genuinely don't know what changed — treating
        # that as "nothing changed" would silently PASS a broken/misconfigured
        # environment (bad --repo, non-git dir, git ownership rejection). Raise
        # so the caller surfaces a hard error instead of a false-clean verdict
        # (codex review finding).
        raise RuntimeError(f"could not read git status for {root}: {exc}") from exc
    if proc.returncode != 0:
        raise RuntimeError(
            f"`git status` failed for {root} (exit {proc.returncode}): "
            f"{proc.stderr.strip() or proc.stdout.strip() or 'no output'}")

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
        if not path:
            continue
        if path.startswith("graphify-out/"):
            continue                        # graph artifacts: never executor work
        if code != "??" and content_changed is not None and path not in content_changed:
            continue  # EOL-only rewrite, not an edit
        # The gate's own contract surface is excluded from scope BUT reported to the
        # caller: a change that edits bounds.json / the work-order files is rewriting
        # the very contract judging it, and must surface as a finding, not vanish.
        # UNTRACKED contract files are the normal authoring flow (bounds.json is
        # typically generated right before verify) and stay silently excluded — only
        # a MODIFIED tracked contract file is a self-edit. Diff mode has no such
        # ambiguity: there the diff IS the change, so any contract path in it flags.
        if _is_contract_path(path, contract_extra or []):
            if code != "??" and contract_hits is not None and path not in contract_hits:
                contract_hits.append(path)
            continue
        if path == ".sembl" or path.startswith(".sembl/"):
            continue                        # sembl's own outputs (runs, artifacts)
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
        if path in (".sembl", "bounds.json") or path.startswith((".sembl/", "graphify-out/")):
            continue
        if _looks_like_generated(path):
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
                "validation_passed", "checks_passed", "tests_pass",
                "testsPassed", "allTestsPassed", "validationPassed", "checksPassed"):
        if key in report and _truthy_pass(report.get(key)):
            out.append((key, True, top_evidenced))
    for key in ("validation", "tests", "test_status", "validation_status", "status",
                "testStatus", "validationStatus"):
        value = report.get(key)
        if isinstance(value, str) and _truthy_pass(value):
            out.append((key, True, top_evidenced))

    # Structured check lists.
    for list_key in ("checks", "validations", "validation_results", "test_results",
                     "testResults", "validationResults", "checkResults"):
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
    """Extract claimed-modified files from common executor report shapes.

    Covers the shapes Claude Code / Cursor / Aider / generic harnesses emit:
    flat string lists under many key spellings (snake + camel), and a `changes`
    field that may be a list of strings, a list of {file: ...} objects, or a dict
    keyed by filename.
    """
    claimed = []
    list_keys = (
        "files_modified", "files_changed", "files_modified_or_created", "files",
        "modified_files", "created_files", "edited_files", "added_files",
        "touched_files", "changed_files", "file_changes",
        "filesChanged", "changedFiles", "modifiedFiles", "editedFiles",
    )
    for key in list_keys:
        value = report.get(key)
        if isinstance(value, list):
            claimed.extend(str(item) for item in value if isinstance(item, str))
    changes = report.get("changes")
    if isinstance(changes, list):
        for item in changes:
            if isinstance(item, dict) and isinstance(item.get("file") or item.get("path"), str):
                claimed.append(item.get("file") or item.get("path"))
            elif isinstance(item, str) and ":" in item:
                claimed.append(item.split(":", 1)[0])
            elif isinstance(item, str):
                claimed.append(item)
    elif isinstance(changes, dict):
        claimed.extend(str(k) for k in changes.keys())
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
    """Normalize to a repo-relative POSIX path, neutralizing traversal.

    Drive anchors (`C:`), leading slashes, `.` segments, and `..` segments are
    collapsed lexically so a crafted diff path like `src/../infra/deploy.yaml`
    cannot alias into a declared editable bound while actually touching a
    forbidden area (it normalizes to `infra/deploy.yaml` and is judged as such).
    A leading `..` has nowhere to go and is dropped — the path is always judged
    repo-relative, never trusted to escape the root.
    """
    path = str(path).strip().replace("\\", "/")
    if len(path) >= 2 and path[1] == ":" and path[0].isalpha():
        path = path[2:]                      # strip a Windows drive anchor
    parts: list = []
    for seg in path.split("/"):
        if seg in ("", "."):
            continue
        if seg == "..":
            if parts:
                parts.pop()
            continue
        parts.append(seg)
    return "/".join(parts)


# Case-insensitive filesystems (Windows, default macOS): `Src/App.py` and
# `src/app.py` are the same file there, so a case-only mismatch between the
# contract, the diff, and the report must not false-flag out-of-scope or
# fabrication. Folding is platform-gated: on a case-sensitive filesystem those
# ARE two different paths, and folding would quietly widen editable bounds
# (fail-open). Original casing is preserved in every report field — paths are
# folded only at comparison time.
_CASEFOLD_PATHS = os.name == "nt" or sys.platform == "darwin"


def _fold(path: str) -> str:
    return path.casefold() if _CASEFOLD_PATHS else path


def _matches_any(path: str, entries: list) -> bool:
    folded = _fold(path)
    for entry in entries:
        if not entry:
            continue
        entry = _fold(entry)
        if folded == entry or folded.startswith(entry + "/"):
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


# Machine-produced files: lockfiles, vendored/build output, codegen. They change
# alongside legitimate work (a dep bump rewrites a lockfile) and can be huge, so
# they shouldn't false-flag as out-of-scope or dominate the churn budget. Treated
# like tests for scope (in-scope unless explicitly forbidden) and excluded from
# the churn count — but a forbidden-area rule still wins over this.
_LOCKFILES = frozenset({
    "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "npm-shrinkwrap.json",
    "poetry.lock", "pdm.lock", "uv.lock", "cargo.lock", "go.sum", "composer.lock",
    "gemfile.lock", "packages.lock.json", "flake.lock", "bun.lockb",
})
_GENERATED_DIRS = frozenset({
    "node_modules", "vendor", "dist", "build", ".next", "__generated__",
    "__snapshots__", "generated",
    # Interpreter/tool caches: an agent that runs or tests its code leaves these
    # behind. They're machine-produced, never the substance of a change, and would
    # otherwise false-flag as out-of-scope and blow the churn budget.
    "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache",
})
_GENERATED_SUFFIXES = (
    ".min.js", ".min.css", ".map", ".pb.go", "_pb2.py", "_pb2.pyi",
    ".g.dart", ".freezed.dart", ".generated.ts",
    ".pyc", ".pyo", ".pyd",          # compiled Python bytecode
)


def _looks_like_generated(path: str) -> bool:
    lower = path.lower()
    segments = lower.split("/")
    name = segments[-1]
    if name in _LOCKFILES:
        return True
    if any(seg in _GENERATED_DIRS for seg in segments[:-1]):
        return True
    if lower.endswith(_GENERATED_SUFFIXES):
        return True
    return False


# Docs and changelogs travel with almost every legitimate change (a fix updates
# CHANGES.rst; a feature touches docs/). EXP-04 showed they are the single biggest
# source of scope false-alarms on real merged PRs, so — like tests and generated
# files — they are in-scope unless explicitly forbidden. Kept deliberately narrow:
# a docs/ directory, a changelog-family file anywhere, or a top-level README/prose
# .md/.rst — NOT arbitrary markdown buried in source.
_DOC_DIRS = frozenset({"docs", "doc"})
_CHANGELOG_STEMS = frozenset({
    "changelog", "changes", "history", "news",
    "release-notes", "releasenotes", "releases",
})


def _looks_like_docs(path: str) -> bool:
    lower = path.lower()
    segments = lower.split("/")
    if any(seg in _DOC_DIRS for seg in segments[:-1]):
        return True
    name = segments[-1]
    stem = name.rsplit(".", 1)[0]
    if stem in _CHANGELOG_STEMS:
        return True
    if len(segments) == 1 and name.endswith((".md", ".rst")):
        return True
    return False
