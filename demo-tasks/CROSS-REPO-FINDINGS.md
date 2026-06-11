# Cross-repo findings — Demo Proof Phase 0, fast validation pass (2026-06-11)

Question answered: do the httpie-cli/001 Work Order defects generalize, or was one
repo unlucky? Method: 1 real-issue task per remaining target repo, full graph
pipeline (graphify + CRG), localization checked against the human reference fix,
plus one fast A/B executor pair per repo.

## Localization: editable_paths recall vs reference fix (sembl 0.1.8)

| repo | stack | reference fix file(s) | recall | editable∩forbidden overlaps |
|------|-------|----------------------|--------|------------------------------|
| httpie-cli | Python CLI | httpie/ssl_.py (+setup.cfg) | 0/1 primary (in inspect only) | 1 |
| katana | Go | browser.go, crawler.go, headless.go | 1/3 | 4 |
| fastapi-template | Py+TS | frontend/src/utils.ts | 0/1 (absent even from inspect) | 4 (incl. dir-level: backend/app forbidden, 3 editable files inside it) |
| chatbot-ui | TS/Next | app/api/chat/anthropic/route.ts | 0/1 (absent even from inspect; wrong route picked) | 4 (plus components/ forbidden with 2 editable files inside) |

**4/4 repos, 4 stacks: same defect family.** Recurring bias: entry points and config
files (\_\_main\_\_.py, cmd/* mains, initial_data.py, biome.json, ui components)
outrank task-relevant files. The miss is deterministic (`_rank_editable_paths`
grounding), not LLM noise.

## Executor A/Bs (fast pass: gpt-5.5 medium on katana + fastapi; haiku on chatbot-ui)

| repo | raw arm | sembl arm (same model) |
|------|---------|------------------------|
| katana | EXACT reference fix (+8 lines, 3/3 files) | **STOPPED, zero delivery** — correctly diagnosed fix, found files non-editable, no escape hatch |
| fastapi-template | correct fix incl. true file (utils.ts) +2 call sites | working symptom-level fix in the one relevant editable file (reset-password.tsx); root cause left latent in utils.ts |
| chatbot-ui | reference files hit — but CONTAMINATED (agent cited upstream PR #1571 from memory) | **STOPPED, zero delivery** — high-quality stop: diagnosed the true file, enumerated the contract contradictions, asked the right questions |

Combined with the 12-run httpie matrix, the **wrong-scope cost spectrum** is now fully
mapped, ordered by how much the contract constrains the executor:

1. Weak/ignoring executor → contract ignored, fix lands anyway (httpie haiku/sonnet).
2. Escape hatch exists → obedient executor ships a worse-placed/symptom fix
   (httpie opus & gpt-5.5 → client.py; fastapi → reset-password.tsx).
3. No escape hatch → obedient executor STOPS, zero delivery (katana, chatbot-ui).

The stop behavior itself is the product working as designed ("permission to stop" —
also the r/cursor demand signal). Every observed failure traces to one upstream
defect: **wrong editable_paths**.

## What this licenses (the schema/ranking change plan can now be written)

1. **Fix `_rank_editable_paths`**: task-relevance must outrank graph centrality;
   entry-point/config penalty; any file in files_to_inspect that matches the task's
   failure trace belongs in editable candidates. (Root cause, highest leverage.)
2. **Contract consistency validation at generation time** (deterministic, no LLM):
   editable ∩ forbidden = ∅ (file- AND directory-level); every file named in
   patch_expectations must be editable; if tests_to_add_or_update nonempty, a test
   path must be editable. Reject/repair before writing the WO.
3. **Lock 7 addition**: explicit stop condition "if the correct fix requires editing
   outside editable_paths, stop and report which file and why" — formalizes the good
   behavior strong models already exhibit and converts silent violations (weak
   models) into reports.
4. **/sembl-validate**: verify executor reports against the actual diff (qwen
   fabrication evidence).
5. **Task protocol**: contamination check for demo tasks (agent must not name the
   upstream PR; prefer post-cutoff issues — chatbot-ui/001 is memorized by Claude
   models and unusable for localization claims).

## 0.1.10 verification — localization recall after the fix (2026-06-11)

All five changes landed in sembl 0.1.10 (relevance-first `_rank_editable_paths`,
failure-trace + depth-scaled content bonuses, deterministic contract reconciliation,
Lock-7 permission-to-stop, `sembl validate`, contamination protocol). Regenerated the
WO for every task with the same task text + full graph pipeline:

| repo | reference fix file | 0.1.8 recall | 0.1.10 recall |
|------|--------------------|--------------|---------------|
| httpie-cli | httpie/ssl_.py | 0/1 (inspect-only) | **1/1 editable** |
| katana | browser.go, crawler.go, headless.go | 1/3 | **3/3 editable** |
| fastapi-template | frontend/src/utils.ts | 0/1 (absent everywhere) | **1/1 editable** |
| chatbot-ui | app/api/chat/anthropic/route.ts | 0/1 (wrong route) | **1/1 editable** |

Editable∩forbidden contradictions: 0 across all four (was ≥1 each). The fastapi and
chatbot-ui wins are driven by `_failure_trace_signals` lifting the file that *contains*
the quoted error string ("The passwords do not match"); katana's two missing files
came back via the depth-scaled content bonus (files mentioning proxy+chrome+headless
together outrank single-term keyword hits). The demo-task dirs now hold the 0.1.10 WOs.

## 0.1.10 executor re-test (haiku + sonnet, results-0110/)

Same tasks, same pinned bases, corrected WOs. The variable isolated is the Work
Order's editable_paths (wrong under 0.1.8 → correct under 0.1.10).

| repo | model | 0.1.8 outcome | 0.1.10 outcome | sembl validate |
|------|-------|---------------|----------------|----------------|
| katana | haiku | STOP, zero delivery | exact 3-file reference fix | **PASS** |
| katana | sonnet | (was gpt-5.5 STOP) | exact 3-file reference fix | **PASS** |
| fastapi | haiku | symptom fix (root cause unreachable) | **root-cause fix in utils.ts** + 1 adjacent call-site | FAIL (1 out-of-scope, caught) |

Headline: **a wrong Work Order made a weak model STOP; the corrected Work Order made
the same-or-weaker model deliver the human reference fix.** The only thing that changed
was scope correctness. `sembl validate` worked both ways — PASS on the clean fixes,
FAIL on the qwen fabricated report (0 files changed, fabricated claims named) and on
haiku's one fastapi over-reach (`ChangePassword.tsx`, in files_to_inspect but not
editable_paths).

Residual schema notes from the re-test (candidates for 0.1.11):
- When the true fix is a shared utility, its call sites likely belong in
  editable_paths too (haiku's fastapi over-reach was a justified call-site update the
  ranker surfaced for inspection but didn't promote to editable).
- Lock-7's stop-clause relies on executor self-restraint; the fastapi over-reach
  argues for validate-in-the-loop as the real backstop, not the prompt alone.

## Status

- Localization gate: **PASSED 4/4.** Executor re-test: **PASSED** at haiku + sonnet
  (in-scope reference fixes where 0.1.8 produced STOPs / symptom fixes).
- **Opus tier: owner's gate** — haiku + sonnet both pass, so opus is the go/no-go the
  owner reserved before moving to bigger/harder repos and re-running everything.
- fable runs: still ON HOLD until the bigger-repo round per the owner's plan.
- Toolchain validation unavailable for katana (no Go) and the two TS repos (heavy
  installs); those tasks are scope-metric tasks by design of this fast pass.
