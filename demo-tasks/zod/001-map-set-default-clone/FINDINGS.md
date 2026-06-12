# zod / 001 — map/set default shared-state (PR #5855, pinned b6b1288)

Task: `z.map().default(new Map())` / `z.set().default(new Set())` return the SAME
reference each `.parse(undefined)` — mutations leak. Reference fix: `shallowClone` in
`packages/zod/src/v4/core/util.ts` (+ test). Hard-localization: the symptom points at
"parsing/defaults", the fix is buried in a core util.

## Short-loop WO-quality fixes (before any executor ran) — 0.1.11 wip

The first WO on this task exposed three generic bugs, all fixed (commits a9580be, d498b1d):
1. `validation_commands` exploded to ~170 (one `npm test` per monorepo test file) → capped to ≤10.
2. Locale/i18n files (`locales/he.ts`) in edit scope on a non-localization task → excluded (gated by intent).
3. `patch_expectations`/`stop_conditions` asserted a scope NARROWER than editable_paths
   ("only in schemas.ts" / "stop if outside schemas.ts") while the real fix is util.ts →
   contradictory narrowing claims dropped; canonical Lock-7 boundary kept.
Recall (`util.ts`) stayed HIT throughout. Left UNFIXED on purpose (not rigged): `v3/` files
remained in scope — a v3-vs-v4 rule would be zod-specific tuning.

## Executor A/B — Haiku, raw vs clean WO

| arm | files changed | vs reference scope | tool uses | core fix |
|-----|---------------|--------------------|-----------|----------|
| raw-haiku | util.ts (+2), default.test.ts (+26) | **matches reference (tight)** | 46 | correct |
| sembl-haiku | util.ts (+2), **v3/types.ts (+6)**, default.test.ts (+56) | **over-scoped (+v3)** | 76 | correct + extra v3 |

**On this task the Work Order did NOT help — it slightly hurt.** Raw Haiku localized the
core fix unaided (matching the maintainer), tight and in 46 tool uses. The WO arm fixed the
same core but ALSO edited `v3/types.ts` (out of reference scope) and took MORE tool uses
(76) — because the WO's residual `editable_paths` noise (the v3 files) *granted permission*
to over-scope.

**The load-bearing insight: scope PRECISION is upstream of validation.**
`sembl validate` on the WO arm returned **PASS** — it cannot catch the over-scope, because
`v3/types.ts` IS in the WO's (noisy) editable_paths. A recall-HIT but low-precision Work
Order can make an agent do *more*, not less, and the validator is blind to it because the
noise is "in scope." Fixing this must happen UPSTREAM (tighter editable_paths), not in
validation.

## Honest read & next

- This is ONE task, and an easy-to-localize-for-Haiku one (raw succeeded). The WO's value
  proposition (scope discipline, efficiency) did not show here; it inverted.
- Candidate generic fix: a **relevance-gap cutoff** on editable_paths — drop candidates
  whose score is far below the top candidate when a strong trace/content hit exists, so the
  long tail of weakly-related parallel files (v3) falls away. MUST be validated across
  multiple tasks first (avoid rigging / hurting recall on genuinely multi-file tasks).
- Do NOT patch on one task's evidence. Run more loop tasks (pydantic large cross-file,
  thunderbird) and the rest of the model roster before deciding the cutoff.
