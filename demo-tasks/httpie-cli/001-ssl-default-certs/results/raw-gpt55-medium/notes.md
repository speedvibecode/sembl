# raw-gpt-5.5-medium — notes

- **Outcome: working fix, 1 file (`httpie/ssl_.py`, +11/−7); 23/23 tests pass
  (harness-validated; agent's own pytest blocked by the sandbox flake again).**
- Approach differs from every other run: instead of loading default certs into the
  custom context, it makes the custom `SSLContext` conditional — plain HTTPS uses
  requests' default SSL/CA handling, and the custom context is only created when
  `--ssl` or `--ciphers` actually require it. Same family as gpt-5.5-xhigh-sembl's
  adapter-routing idea, but placed in `ssl_.py`.
- Zero out-of-scope files; no tests added (unlike its xhigh sibling on the raw arm —
  effort level visibly traded away the belt-and-braces behavior).
- Did NOT drop the `setup.cfg` requests pin.
- Reviewer caution (same as gpt55-xhigh-sembl): conditional-context approaches change
  which SSL path serves plain HTTPS; wider behavioral surface than the reference
  +7-line fix even with a small diff.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write sandbox.
