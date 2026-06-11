# sembl-gpt-5.5-medium — notes

- **Outcome: working, contract-compliant fix; 23/23 tests pass (harness-validated).**
- Files: `httpie/client.py` only (+22/−9). Obeyed the wrong scope lock, same
  adapter-routing strategy as its xhigh sibling: default requests HTTPS adapter for
  ordinary requests, custom TLS adapter only for `--ssl` / `--ciphers` / encrypted
  client keys.
- Honest blocker reporting: pytest blocked by the recurring codex Windows sandbox
  spawn failure on three attempts; said so in the risks field rather than claiming
  validation passed.
- No tests added (xhigh-sembl at least flagged the editable-paths/test-expectations
  contradiction; medium silently skipped tests).
- Both gpt-5.5 sembl runs converged on the same approach independently — the scope
  lock channels codex models toward client.py-level routing solutions, while Claude
  models channeled toward (opus) helper-injection in client.py. The WO is visibly
  steering DESIGN, not just file choice.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write sandbox (flaky).
