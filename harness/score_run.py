"""
score_run.py — deterministic scorer for one matrix cell.

Given a target repo whose working tree holds an executor's changes, plus the
task's expected-scope and the Work Order it ran against, emit ONE data row:
files changed, recall vs the human reference scope, out-of-scope edits, sembl
validate verdict, diff size. Append it to a JSONL so the full matrix is queryable
with zero hand-written notes.

Works for ANY executor (Claude agent, codex, gemini, ollama) — it only reads the
git working tree, so how the change was produced is irrelevant. This is the
"auto-scoring so the matrix scales" piece.

Usage:
  python harness/score_run.py \
    --repo <clone> --base <sha> --expected <task>/expected-scope.json \
    --label sembl-gemini --task zod-001 --arm sembl \
    [--wo <work-order.json>] [--tokens N] [--seconds N] \
    --out harness/results/matrix.jsonl
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

# Reuse Sembl's own validator so scoring matches the shipped `sembl validate`.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from sembl.validator import validate_against_work_order, _norm, _looks_like_test  # noqa: E402


def _changed_files(repo: Path, base: str) -> list[str]:
    r = subprocess.run(
        ["git", "diff", "--name-only", base],
        cwd=str(repo), capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    files = [_norm(x) for x in r.stdout.splitlines() if x.strip()]
    return [f for f in files if not f.startswith((".sembl/", "graphify-out/"))]


def _diff_lines(repo: Path, base: str) -> int:
    r = subprocess.run(
        ["git", "diff", "--numstat", base],
        cwd=str(repo), capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    total = 0
    for line in r.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) >= 2:
            for n in parts[:2]:
                if n.isdigit():
                    total += int(n)
    return total


def _matches(path: str, scope: list[str]) -> bool:
    p = _norm(path)
    return any(p == _norm(s) or p.startswith(_norm(s).rstrip("/") + "/") for s in scope)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--base", required=True, help="pinned base SHA")
    ap.add_argument("--expected", required=True, help="expected-scope.json")
    ap.add_argument("--label", required=True, help="e.g. sembl-gemini / raw-codex")
    ap.add_argument("--task", required=True, help="e.g. zod-001")
    ap.add_argument("--arm", required=True, choices=["raw", "sembl"])
    ap.add_argument("--wo", default=None, help="work-order.json (sembl arm only)")
    ap.add_argument("--tokens", type=int, default=0)
    ap.add_argument("--seconds", type=float, default=0.0)
    ap.add_argument("--tool-uses", type=int, default=0)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    repo = Path(a.repo)
    expected = json.loads(Path(a.expected).read_text(encoding="utf-8-sig"))
    primary = expected.get("primary", []) or []
    secondary = expected.get("secondary", []) or []

    changed = _changed_files(repo, a.base)
    impl_changed = [f for f in changed if not _looks_like_test(f)]

    primary_hit = [p for p in primary if any(_matches(c, [p]) for c in changed)]
    secondary_hit = [s for s in secondary if any(_matches(c, [s]) for c in changed)]
    ref_files = primary + secondary
    extra = [c for c in impl_changed if not _matches(c, ref_files)]

    row = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "task": a.task,
        "arm": a.arm,
        "label": a.label,
        "changed_files": changed,
        "n_changed": len(changed),
        "diff_lines": _diff_lines(repo, a.base),
        "primary_recall": f"{len(primary_hit)}/{len(primary)}" if primary else "n/a",
        "primary_hit": bool(primary) and len(primary_hit) == len(primary),
        "secondary_hit": secondary_hit,
        "extra_impl_files": extra,            # touched beyond the reference scope
        "over_scope": len(extra),
        "tokens": a.tokens,
        "seconds": a.seconds,
        "tool_uses": a.tool_uses,
    }

    # sembl validate (scope vs the WO's own contract) for the sembl arm.
    if a.arm == "sembl" and a.wo:
        wo = json.loads(Path(a.wo).read_text(encoding="utf-8-sig"))
        vr = validate_against_work_order(str(repo), wo)
        row["validate_pass"] = vr.ok
        row["validate_forbidden_hits"] = vr.forbidden_hits
        row["validate_out_of_scope"] = vr.out_of_scope

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row) + "\n")

    print(json.dumps(row, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
