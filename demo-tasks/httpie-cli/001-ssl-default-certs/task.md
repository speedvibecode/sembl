# httpie-cli / 001 — HTTPS connections failing since requests 2.32.3

## Provenance

- Target repo: https://github.com/httpie/cli (~38k stars, Python CLI)
- Source issue: https://github.com/httpie/cli/issues/1583
  "HTTPS connections failing since requests version 2.32.3"
- Human reference fix: https://github.com/httpie/cli/pull/1596
  (merge commit `fd30c4ef6230a927f9dcfad6301c40e8bf846156`)
- Pinned base SHA (parent of the fix — the bug is live here):
  `cee82c825e3ed2eeb9f0fc5f31d478c6b8683fca`

## The bug

requests >= 2.32.3 stopped loading the system default trusted certificates into
custom SSL contexts. HTTPie builds a custom context in `httpie/ssl_.py`
(`HTTPieHTTPSAdapter`), so every plain HTTPS request fails with
`SSL: CERTIFICATE_VERIFY_FAILED ... unable to get local issuer certificate`.

The human fix (7 lines in `httpie/ssl_.py`): after building the context, if it has no
CA certs loaded, call `load_default_certs()`. A second commit dropped the temporary
`requests` upper-bound pin in `setup.cfg`.

## Why this task

- Real bug with real user pain, derived from a closed issue with a merged human fix.
- The issue text does NOT name the file to change — scope localization is earned.
- Small reference diff = a tight scope yardstick; easy to spot over-reach.

## Setup

Clone https://github.com/httpie/cli, `git checkout cee82c825e3ed2eeb9f0fc5f31d478c6b8683fca`,
create a venv, `pip install -e ".[test]"`. Validation: `python -m pytest tests/test_ssl.py -q`
(23 tests pass at base).
