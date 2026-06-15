---
name: sembl-verify-subagent
description: Use when delegating coding work to a sub-agent (or any autonomous agent) and you need to confirm it stayed in bounds and didn't fake results. Verifies a sub-agent's diff against what it was told it could touch and what it claims it did — deterministically, with no second model. Trigger on "verify the sub-agent", "did the agent stay in scope", "check the agent's patch before merging".
---

# Verify a sub-agent's work with Sembl

Sembl is a deterministic accountability gate. It does not judge code quality — it
checks objective facts about a diff against a declared contract: out-of-scope edits,
forbidden-area edits, fabricated file claims, "tests passed" claims with no evidence,
and churn over budget. Same inputs → same verdict, no LLM in the check.

Use this **whenever you hand work to a sub-agent and will act on the result.** Trust
the verdict, not the sub-agent's self-report.

## The pattern

1. **Before delegating, declare the bounds.** Decide which files the sub-agent may
   touch and which it must not. Capture them — don't rely on the sub-agent to
   remember:
   - `editable_paths`: path prefixes it may edit (e.g. `["src/auth/"]`).
   - `forbidden_areas`: path prefixes it must not touch (e.g. `["migrations/", "infra/"]`).
   - optionally `churn_budget`: `{ "max_files": N, "max_lines": M }`.

2. **Have the sub-agent return a diff and a short report** of what it changed and
   whether it validated, e.g.
   `{ "changed_files": ["src/auth/login.ts"], "tests_passed": true,
      "validations": [{ "command": "pytest -q", "output": "12 passed" }] }`.

3. **Run the gate.** Either via MCP or the CLI.

   **MCP** (preferred when available — tool `verify_change`):
   ```jsonc
   {
     "diff": "<the sub-agent's unified diff>",
     "editable_paths": ["src/auth/"],
     "forbidden_areas": ["migrations/"],
     "report": { "changed_files": ["src/auth/login.ts"], "tests_passed": true }
   }
   ```

   **CLI** (no MCP): write the bounds to `bounds.json` and the report to
   `report.json`, then:
   ```bash
   git diff | sembl verify --wo-file bounds.json --diff - --report report.json --json
   ```

4. **Act on the verdict:**
   - **BLOCK** — a forbidden-area edit or a fabricated file claim. Do **not** accept
     the work. Surface the offending paths and send it back.
   - **WARN** — out-of-scope edit (beyond the default tolerance), churn over budget,
     or an unevidenced "tests passed" claim. Review the listed reasons before
     accepting; ask the sub-agent to justify or trim.
   - **PASS** — the change stayed in declared bounds and the claims match the diff.

## Notes

- Scope is **advisory** and only as good as the `editable_paths` you give it. It
  tolerates a little incidental creep by default (a quarter of changed files); pass
  `scope_tolerance: {}` for zero tolerance, or `--strict` to make out-of-scope a hard
  BLOCK. The always-hard checks are forbidden-area edits and fabricated claims.
- Tests, generated/lockfiles, and docs/changelogs are auto in-scope — you don't have
  to enumerate them.
- No API key, no model, free to run. Install: `pip install sembl` (add `[mcp]` for
  the server: `pip install "sembl[mcp]"`, then run `sembl-mcp`).
