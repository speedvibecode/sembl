# The bounds contract

`sembl verify` (and the back-compat `sembl validate`) check a real git diff
against a **bounds contract**: a small JSON object describing where a change was
allowed to go. This is the portable input to the gate — you can write it by hand,
emit it from GitHub Spec Kit / Tessl / Kiro, or let `sembl generate` (beta)
produce a fuller Work Order that contains it.

`verify` is **executor-neutral** and **deterministic**: it never runs an LLM and
never sees the agent. It only reads the four fields below, plus (optionally) an
executor report.

## The four fields verify reads

```json
{
  "editable_paths": ["src/auth/", "src/api/routes/login.ts"],
  "forbidden_areas": ["migrations/", "infra/", ".github/"],
  "churn_budget": { "max_files": 6, "max_lines": 200 }
}
```

| Field | Type | Meaning |
|-------|------|---------|
| `editable_paths` | list of path prefixes | files the change may touch. A changed file outside all of these is **out-of-scope**. |
| `forbidden_areas` | list of path prefixes | files the change must **not** touch. A changed file here is a **forbidden hit** (→ BLOCK), unless it's also explicitly in `editable_paths`. |
| `churn_budget.max_files` | int ≥ 0 | soft cap on number of changed files (→ WARN if exceeded). Omit to skip. |
| `churn_budget.max_lines` | int ≥ 0 | soft cap on added+deleted lines (→ WARN if exceeded). Omit to skip. |

Paths are prefix-matched on normalized POSIX form: `src/auth/` matches
`src/auth/login.ts`. Tests are always treated as in-scope alongside edits, so you
don't have to enumerate test files in `editable_paths`.

Any extra keys (a full `work-order.json` has many) are ignored by `verify`, so a
Work Order produced by `sembl generate` works as a bounds file unchanged.

## The optional executor report

If you pass `--report report.json`, `verify` cross-checks the agent's own claims
against the diff. It never trusts the report — it only catches contradictions:

- **Fabricated claims** (→ BLOCK): a file the report says it changed that the diff
  does not show. Recognized shapes: `files_modified`, `files_changed`, `files`,
  and `changes: [{ "file": "..." }]`.
- **Unevidenced validation** (→ WARN): a `tests_passed: true` / `status: "passed"`
  / `checks: [{...}]` claim with no backing evidence (no `exit_code: 0`, no
  captured `output`/`stdout`/`log`). Claim-without-evidence only — Sembl asserts
  nothing about whether a check ran in history.

## Verdict

| | meaning |
|---|---|
| **BLOCK** (exit 1) | forbidden hit, fabricated claim, or (in strict mode) any out-of-scope edit |
| **WARN** (exit 0, or 1 with `--strict`) | out-of-scope edit (default mode), churn over budget, unevidenced validation, or unreported change |
| **PASS** (exit 0) | clean |

```powershell
sembl verify --wo-file bounds.json
sembl verify --wo-file bounds.json --report report.json --strict --json
```

## From GitHub Spec Kit

Spec Kit's `tasks.md` lists the exact file paths for each task. Collect those
paths into `editable_paths`, set `forbidden_areas` to whatever the spec declared
off-limits (migrations, infra, generated code), and you have a bounds file. A
small adapter that reads `specs/<feature>/tasks.md` and emits `bounds.json` is on
the roadmap; until then the mapping is a copy of the paths Spec Kit already wrote.
