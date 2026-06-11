# sembl-sonnet — notes

- **Outcome: correct fix + 3 new regression tests; 26/26 tests pass.**
- Files: `httpie/ssl_.py` (+12/−2), `tests/test_ssl.py` (+34/−1).
- **The WO visibly shaped behavior here:** patch expectations said "Test additions for
  SSL verification with modern requests versions" — sonnet-sembl is the only run so far
  that added tests (raw-sonnet did not). It also followed the WO's report format JSON.
- **Same scope-compliance failure as sembl-haiku:** `httpie/ssl_.py` and
  `tests/test_ssl.py` are both outside the WO's MAY-edit list; the agent edited them
  without stopping (the correct fix demanded it; the contract was wrong).
- Clean protocol behavior otherwise: no venv modification, no live network reliance,
  pyOpenSSL-compat guard (`hasattr(..., 'load_default_certs')`) mirrors urllib3's own.
- Like raw-sonnet, did not drop the `setup.cfg` requests pin.
- Agent stats: 47 tool uses, ~473s, ~63k subagent tokens.
