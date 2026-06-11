# raw-sonnet — notes

- **Outcome: correct fix, 1 file (`httpie/ssl_.py`, +14/−3), 23/23 tests pass.**
- Different placement from the reference: loads default certs inside
  `_create_ssl_context` when `verify=True`, rather than the reference's
  `__init__`-time `get_ca_certs()` check. Functionally equivalent for the bug;
  arguably cleaner.
- Did NOT drop the `requests <=2.31.0` pin in `setup.cfg` (the reference fix did) —
  the runtime bug is fixed but installing against newer requests stays blocked, so
  vs the reference file set this is 1/2 primary+secondary coverage, 0 out-of-scope.
- No protocol deviations observed: did not touch the venv, relied on the test suite.
- Best root-cause analysis so far (explicitly tied the change to requests'
  CVE-2024-35195 context handling).
- Agent stats: 55 tool uses, ~795s (slowest so far), ~65k subagent tokens.
