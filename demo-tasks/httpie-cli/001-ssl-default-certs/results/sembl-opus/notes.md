# sembl-opus — notes

- **Outcome: working fix, contract-compliant placement — and that's the problem.**
- Files: `httpie/client.py` (+53/−4), `tests/test_ssl.py` (+43). 28/28 tests pass,
  plus it ran the broader suite (114 passed) unprompted.
- **First run to OBEY the Work Order's scope lock.** opus noticed `httpie/ssl_.py` is
  not in MAY-edit and engineered around it: a `_load_ca_certs_into_context()` helper in
  `httpie/client.py` (allowed path) that loads the CA bundle into the HTTPS adapter's
  context after construction. Where haiku and sonnet silently violated the wrong
  contract and landed on the reference fix, opus complied — and produced a fix that is
  ~5x larger than the reference, in the wrong layer, with a semantic change it had to
  mitigate (eager CA-bundle loading at session build → errors move from send time to
  construction time, wrapped back into SSLError to preserve the contract).
- **Key product lesson of the matrix:** the stronger the executor, the more faithfully
  it follows the contract — so a WRONG editable_paths actively damages strong-model
  output while weak models just ignore it. Scope correctness is the whole ballgame.
- Also added 5 regression tests (patch expectations honored), explicitly verified the
  forbidden files were untouched, and flagged env limitations honestly in its report.
- `tests/test_ssl.py` is technically outside MAY-edit too — the WO demands test
  additions while not listing any test path as editable; internally inconsistent
  contract (same gap noted in sembl-sonnet).
- Agent stats: 21 tool uses, ~261s, ~60k subagent tokens.
