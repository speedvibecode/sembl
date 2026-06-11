# raw-haiku — notes

- **Outcome: correct fix, exact match with the human reference.**
- Modified `httpie/ssl_.py` (+7: `load_default_certs()` fallback in
  `HTTPieHTTPSAdapter.__init__`, guarded by `getattr` + `get_ca_certs()` check —
  functionally identical to PR #1596) and `setup.cfg` (dropped the
  `<=2.31.0` requests pin), exactly the reference file set.
- Diff: 2 files, +8/−1. Zero out-of-scope files.
- Validation: 23/23 SSL tests pass (recorded post-run under restored requests 2.31.0).
- **Protocol deviation:** agent upgraded `requests` to 2.34.2 inside the prepared venv
  to reproduce the bug, despite "do not modify .venv contents". Useful initiative,
  but an instruction violation; venv restored to 2.31.0 afterwards. It located
  `httpie/ssl_.py` on its own by tracing where the custom SSL context is created.
- Agent stats: 31 tool uses, ~365s, ~50k subagent tokens.
