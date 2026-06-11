# raw-opus — notes

- **Outcome: correct fix, 1 file (`httpie/ssl_.py`, +12/−1), 23/23 tests pass.**
- Same placement as raw-sonnet (`_create_ssl_context`, gated on `verify`), with
  `ssl.Purpose.SERVER_AUTH` passed explicitly. Zero out-of-scope files.
- Did NOT drop the `setup.cfg` requests pin (same gap as both sonnet runs).
- **Most efficient run of the matrix so far: 16 tool uses, ~174s, ~41k tokens** —
  roughly half haiku's tool count and a quarter of sonnet-raw's wall time.
- Clean protocol behavior: no venv changes; validated via test suite plus a direct
  CA-count probe of the context (46 certs with verify=True, 0 with verify=False).
  Explicitly flagged the env's requests version (2.31.0) as a validation limitation.
- Agent stats: 16 tool uses, ~174s, ~41k subagent tokens.
