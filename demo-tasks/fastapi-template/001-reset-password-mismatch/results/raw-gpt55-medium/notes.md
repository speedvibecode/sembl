# raw-gpt-5.5-medium — notes (fastapi-template/001)

- **Outcome: correct fix; localized the non-obvious file unaided.**
- Files: `frontend/src/utils.ts` (+2/−1), `frontend/src/routes/reset-password.tsx`
  (+4/−1), `frontend/src/components/UserSettings/ChangePassword.tsx` (+4/−1).
  +10/−3 total.
- Found `utils.ts` by tracing the error string from the reset form to the shared
  validator — the "issue doesn't name the file" localization the demo wants to test,
  done by the executor itself.
- Design slightly wider but arguably cleaner than the reference: instead of the
  reference's `password || new_password` fallback inside the validator, it
  parameterized which field to compare and updated the two call sites explicitly.
  3 files vs reference 1; all on-target, zero unrelated files.
- Honest blocker note re: no toolchain. Verified by reading all call sites.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write.
