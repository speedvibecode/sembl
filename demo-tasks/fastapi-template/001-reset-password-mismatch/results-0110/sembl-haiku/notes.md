# sembl-haiku — notes (fastapi-template/001, sembl 0.1.10 corrected WO)

- **Symptom-fix → root-cause-fix.** With the 0.1.8 WO, `utils.ts` (the shared
  validator that actually holds the bug) was not editable, so sembl-gpt55-medium
  fixed the SYMPTOM in `reset-password.tsx` and left the root cause latent. With the
  0.1.10 WO — recall 1/1, `utils.ts` now editable via the failure-trace signal on the
  quoted "The passwords do not match" — haiku fixed the ROOT CAUSE in `utils.ts`
  (parameterized `confirmPasswordRules` field name, backward-compatible), matching the
  reference fix file (PR #1171).
- Files changed: `frontend/src/utils.ts` (root cause ✓),
  `frontend/src/routes/reset-password.tsx` (call site, editable ✓),
  `frontend/src/components/UserSettings/ChangePassword.tsx` (call site, **out of scope**).
- **`sembl validate` → FAIL**, out-of-scope: `ChangePassword.tsx`. The validator
  earned its keep on a REAL over-reach, not a fabrication: the file was in
  files_to_inspect (the agent correctly reasoned ChangePassword also calls the shared
  rule with `new_password` and would break without the call-site update) but NOT in
  editable_paths. This is precisely the "agent helpfully touched an adjacent file →
  review now covers implied decisions" problem from the r/cursor demand signal,
  surfaced automatically instead of slipping through.
- Honest read: this is a PARTIAL win. The localization fix worked (root cause now
  reachable and fixed); the scope discipline is imperfect (one justified-but-unlisted
  edit). Two follow-ups for the schema: (a) when the true fix is a shared utility, its
  call sites probably belong in editable_paths too — the ranker found ChangePassword
  for inspection but didn't promote it; (b) Lock-7's stop-clause didn't fire because
  the agent judged the edit in-scope-enough, which argues for validate-in-the-loop
  rather than relying on executor self-restraint.
- Agent stats: 22 tool uses, ~350s, ~39k subagent tokens.
