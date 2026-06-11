# raw-gpt-5.5-xhigh — notes

- **Outcome: correct fix + 2 unprompted regression tests; 25/25 tests pass**
  (validated by harness — codex's Windows sandbox blocked the agent's own pytest run
  with "windows sandbox: spawn setup refresh", reported honestly as a blocker).
- Files: `httpie/ssl_.py` (+15), `tests/test_ssl.py` (+55/−1). Zero out-of-scope.
- Fix placement: loads requests' default CA bundle into the custom SSL context when
  `verify=True` — same family as the sonnet/opus raw fixes; checked the actual
  requests 2.32.3 adapters.py source from the upstream tag as a reference.
- Notable: this is the only RAW-arm run that added tests unprompted (Claude raw arms
  never did; sembl arms did because the WO asked). gpt-5.5 xhigh behaves like a
  belt-and-braces engineer by default.
- Did NOT drop the `setup.cfg` requests pin (same as all non-haiku runs).
- Harness: codex exec, model gpt-5.5, reasoning xhigh, workspace-write sandbox.
