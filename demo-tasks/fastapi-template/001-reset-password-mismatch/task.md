# fastapi-template / 001 — password reset always says "passwords do not match"

## Provenance

- Target repo: https://github.com/fastapi/full-stack-fastapi-template (~44k stars, Py+TS)
- Source: discussion #1170 → human reference fix PR #1171
  (commit `78a8a3b4c4e31616a5c59b015f0de1bdd6d83689`)
- Pinned base SHA (parent of the fix — bug live here):
  `e53dc1702bd7525936e80be3b2b2ec3c8c374b01`

## The bug

`confirmPasswordRules` in `frontend/src/utils.ts` validates the confirmation field
against `getValues().password`, but the reset-password form names its field
`new_password` — so the comparison is always against undefined and every reset fails
with "The passwords do not match". Reference fix (+12/−5, 1 file): compare against
`getValues().password || getValues().new_password`.

## Why this task

- The fix file is genuinely NOT guessable from the complaint: the error appears on the
  reset-password page, but the broken code lives in a generically named shared
  `utils.ts`. This is the "issue doesn't name the file" archetype the demo needs.
- No toolchain validation on the demo machine (old lockfile, heavy npm install);
  scope metrics primary; executors validate by reading.

## Localization result (sembl 0.1.8, full graph: graphify + CRG 358 nodes)

editable_paths recall vs reference: **0/1** — `frontend/src/utils.ts` absent from
editable_paths AND files_to_inspect. Noise/bias: `frontend/biome.json` (config),
`backend/app/initial_data.py` + `backend_pre_start.py` (entry points), backend login
routes. Contradictions: `biome.json` in BOTH editable and forbidden; `backend/app`
forbidden while three editable paths live inside it. Third repo in a row with the
same defect family — the ranking miss is now demonstrated cross-stack (Python CLI,
Go, TS/React).
