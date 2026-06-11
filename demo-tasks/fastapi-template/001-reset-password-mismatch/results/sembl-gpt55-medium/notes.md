# sembl-gpt-5.5-medium — notes (fastapi-template/001)

- **Outcome: working fix via the escape hatch; contract-compliant; 1 file.**
- File: `frontend/src/routes/reset-password.tsx` (+7/−2). The WO's editable_paths
  missed the reference file (`frontend/src/utils.ts`) but DID include
  `reset-password.tsx`, where an alternative valid fix exists — the agent fixed the
  comparison locally against `new_password` inside the allowed file.
- This completes the wrong-scope cost spectrum with its mildest case: when an allowed
  file can host a *legitimate* alternative fix, an obedient strong model delivers it
  (vs httpie: workaround in the wrong layer; vs katana: full stop, no escape hatch).
- Same contract discipline as the other codex sembl runs: declined to add tests
  because no test path was editable, and said so.
- Trade-off vs raw arm on the same task: raw fixed the SHARED validator (utils.ts),
  benefiting all forms; sembl's local fix leaves the shared `confirmPasswordRules`
  bug latent for any future form using `new_password`. Scope misses don't just block
  — they can silently push fixes from root cause to symptom.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write.
