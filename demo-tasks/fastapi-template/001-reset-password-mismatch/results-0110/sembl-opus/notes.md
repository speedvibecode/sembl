# sembl-opus — notes (fastapi-template/001, sembl 0.1.10 corrected WO)

- **The cleanest result of the entire effort.** ONE file (`frontend/src/utils.ts`),
  ONE line (`getValues().password` → `getValues().new_password`) — even tighter than
  the human reference's `password || new_password` fallback. `sembl validate` → PASS,
  1 file in scope, 0 out-of-scope.
- **Resolved the over-reach that haiku hit on this exact task.** haiku also touched
  `ChangePassword.tsx` (an adjacent call site → validate FAIL). Opus reasoned that
  fixing the shared `confirmPasswordRules` util fixes BOTH consumers at once, so it
  deliberately left ChangePassword.tsx untouched — minimal and correct.
- Explicitly worked the scope contract: grep-verified `confirmPasswordRules` is used
  only by reset-password.tsx + ChangePassword.tsx (NOT signup/login, which have their
  own inline `password` validation), so the "shared utility used by signup/login" stop
  condition correctly did NOT fire. Exactly the judgment the WO is meant to enable.
- Honestly flagged the one unmet patch expectation (add tests): the repo has no test
  runner and adding one needs `package.json`, which is forbidden — so it declined to
  expand scope to satisfy a patch expectation, and said so. Textbook permission-to-stop
  reasoning applied to a sub-requirement.
- Stronger model → tighter, more in-scope fix. The opposite of the 0.1.8 pattern
  (where stronger models faithfully executed a WRONG contract into worse output).
  Now that the contract is right, model strength translates to better-scoped fixes.
- Agent stats: 13 tool uses, ~174s, ~37k subagent tokens.
