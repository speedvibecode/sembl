# sembl-gpt-5.5-xhigh — notes

- **Outcome: working, contract-compliant fix; 23/23 tests pass (harness-validated).**
- Files: `httpie/client.py` only (+14/−9). Like opus-sembl, it OBEYED the wrong scope
  lock — but with a different strategy: route plain HTTPS through requests' default
  adapter path (which handles certs correctly) and only use HTTPie's custom
  SSL-context adapter when custom TLS options actually require it.
- **Caught the WO's internal contradiction and resolved it contract-first:** risks
  explicitly state "No tests were added because the editable allowlist excludes test
  files" — the patch expectations demanded test additions, the scope lock forbade
  them, and the agent obeyed the scope lock and DOCUMENTED the conflict. Best
  contract-discipline of the whole matrix.
- First attempt aborted with zero changes when codex's Windows sandbox failed every
  shell spawn ("windows sandbox: spawn setup refresh") — it stopped and reported
  blockers in the WO format instead of proceeding blind (contrast: qwen-sembl
  fabricated success under far less pressure). Kept as agent-final-message in the
  run 1 log; this capture is the clean retry.
- Risk note for reviewers: the adapter-routing approach changes WHICH adapter serves
  plain HTTPS — behavioral surface is wider than the reference one-liner even though
  the diff is small; tests pass but this is the kind of change Lock 5
  (regressions_to_preserve) should scrutinize.
- Harness: codex exec, gpt-5.5, reasoning xhigh, workspace-write sandbox (flaky:
  agent's own pytest blocked; validation run by harness).
