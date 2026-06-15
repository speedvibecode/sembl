---
name: sembl-gate-pr
description: Use to gate a pull request or local diff with Sembl before it merges — confirm the change stayed in declared bounds and didn't touch forbidden areas. Trigger on "gate this PR", "check this diff against the rules", "run sembl on the PR", "is this change in scope before merge".
---

# Gate a PR / diff with Sembl

Run the deterministic accountability gate over a change before it merges. No model,
no API key — same inputs, same verdict — so it's safe in CI.

## Local diff

```bash
# working tree vs HEAD, or a specific patch
git diff | sembl verify --diff -            # uses bounds.json at the repo root
git diff main...HEAD | sembl verify --diff - --json
```

A patch file works too: `sembl verify --diff change.patch`.

## A GitHub PR in CI

Add the action to a workflow (it runs verify on the PR's diff and fails on a hard
breach):

```yaml
# .github/workflows/sembl.yml
on: { pull_request: {} }
jobs:
  sembl:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: speedvibecode/sembl@v0.1.17
```

## Reading the verdict

- **BLOCK** (exit 1) — forbidden-area edit or a fabricated file claim. Fail the check.
- **WARN** (exit 0; 1 with `--strict`) — out-of-scope edit beyond tolerance, churn
  over budget, or an unevidenced validation claim. Review before merge.
- **PASS** — in bounds, claims consistent.

## Prerequisites

- A `bounds.json` at the repo root (or `.sembl/bounds.json`). If there isn't one, use
  the **sembl-setup-bounds** skill first.
- Pass `--report agent.json` if an agent produced a report, to also catch fabricated
  file claims and unevidenced "tests passed" claims.
- Use `--strict` for a hard gate (out-of-scope becomes a BLOCK and any WARN fails).
