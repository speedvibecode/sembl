# Executor Prompt - wo-httpiecli-1781163174-httpie-is-completely-broken-for-https-si

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix SSL certificate verification for HTTPS requests in httpie by ensuring the requests library uses system certificates after version 2.32.3. Original request: httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.. User-visible outcome: HTTPS requests (e.g., `https https://raw.githubusercontent.com/...`) succeed without SSLError: CERTIFICATE_VERIFY_FAILED. Non-goals: Change default HTTP behavior; Modify non-HTTPS request handling; Alter CLI argument parsing; Update documentation for unrelated features. You MAY only edit these paths: extras/packaging/linux/scripts/httpie_cli.py; httpie/__main__.py; httpie/manager/__main__.py; extras/scripts/generate_man_pages.py; extras/packaging/linux/scripts/http_cli.py; httpie/core.py; httpie/client.py; httpie/config.py. You must NOT touch: docs/README.md; extras/packaging/linux/scripts/http_cli.py; httpie/__main__.py. Inspect these files before changing code: httpie/core.py; httpie/manager/core.py; httpie/cli/requestitems.py; httpie/output/formatters/headers.py; httpie/legacy/v3_2_0_session_header_format.py; tests/test_httpie.py; tests/test_httpie_cli.py; extras/packaging/linux/scripts/httpie_cli.py; httpie/ssl_.py; httpie/utils.py; httpie/client.py; httpie/compat.py. Inspect these tests before changing code: tests/test_ssl.py; tests/test_httpie.py; tests/test_httpie_cli.py; tests/conftest.py; tests/test_cli.py; tests/test_xml.py; tests/test_auth.py; tests/test_json.py. Acceptance criteria: A fresh venv with `requests>=2.32.3` can successfully execute `https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSL errors; Existing `--verify` flag behavior remains unchanged (e.g., `--verify=no` still disables verification); No regression in HTTP (non-HTTPS) requests; All existing SSL-related tests pass. Stop and ask the human if: If the fix requires modifying `certifi` or platform-specific cert paths directly; If the solution involves downgrading `requests`; If changes to `httpie/__main__.py` are deemed necessary (forbidden per graph); If the root cause is unclear after inspecting `requests` 2.32.3 changelog. Patch expectations: Minimal changes to SSL/TLS configuration in httpie's requests usage; Explicit system certificate path handling if requests 2.32.3+ no longer defaults to it; No changes to CLI argument parsing or user-facing behavior beyond fixing the bug; Test additions for SSL verification with modern requests versions. Validate with: python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb; python -m pytest tests/test_ssl.py -v. Report your work using this format: A JSON object with: { 'changes': [list of modified files with brief descriptions], 'validation': { 'commands': [list of validation commands run], 'results': [pass/fail for each] }, 'tests': { 'added': [list of new tests], 'updated': [list of modified tests] }, 'manual_checks': [list of manual verifications performed], 'risks': [any unresolved concerns] }

---

## Scope enforcement

**You MAY only edit these paths:**
- `extras/packaging/linux/scripts/httpie_cli.py`
- `httpie/__main__.py`
- `httpie/manager/__main__.py`
- `extras/scripts/generate_man_pages.py`
- `extras/packaging/linux/scripts/http_cli.py`
- `httpie/core.py`
- `httpie/client.py`
- `httpie/config.py`

**You must NOT touch:**
- `docs/README.md`
- `extras/packaging/linux/scripts/http_cli.py`
- `httpie/__main__.py`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If the fix requires modifying `certifi` or platform-specific cert paths directly
- If the solution involves downgrading `requests`
- If changes to `httpie/__main__.py` are deemed necessary (forbidden per graph)
- If the root cause is unclear after inspecting `requests` 2.32.3 changelog

## Patch expectations

- Minimal changes to SSL/TLS configuration in httpie's requests usage
- Explicit system certificate path handling if requests 2.32.3+ no longer defaults to it
- No changes to CLI argument parsing or user-facing behavior beyond fixing the bug
- Test additions for SSL verification with modern requests versions