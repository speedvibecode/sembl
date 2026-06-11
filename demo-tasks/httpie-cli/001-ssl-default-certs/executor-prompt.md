# Executor Prompt - wo-httpiecli-1781186027-httpie-is-completely-broken-for-https-si

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix SSL certificate verification for HTTPS requests in httpie to restore system cert trust after requests 2.32.3 changes. Original request: httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.. User-visible outcome: HTTPS requests (e.g., `http https://example.com`) work without SSLError: CERTIFICATE_VERIFY_FAILED in fresh venvs. Non-goals: Add new CLI flags for SSL verification; Modify packaging scripts (extras/); Change documentation; Alter non-SSL-related HTTP client behavior. You MAY only edit these paths: httpie/core.py; httpie/manager/core.py; httpie/cli/requestitems.py; httpie/output/formatters/headers.py; httpie/legacy/v3_2_0_session_header_format.py; httpie/client.py; httpie/ssl_.py; extras/packaging/linux/scripts/httpie_cli.py; tests/test_ssl.py. You must NOT touch: extras/packaging/linux/scripts/http_cli.py; httpie_cli.py; docs/; extras/scripts/. Inspect these files before changing code: httpie/core.py; httpie/manager/core.py; httpie/cli/requestitems.py; httpie/output/formatters/headers.py; httpie/legacy/v3_2_0_session_header_format.py; tests/test_httpie.py; tests/test_httpie_cli.py; extras/packaging/linux/scripts/httpie_cli.py; httpie/ssl_.py; httpie/utils.py; httpie/client.py; httpie/compat.py. Inspect these tests before changing code: tests/test_ssl.py; tests/test_httpie.py; tests/test_httpie_cli.py; tests/conftest.py; tests/test_cli.py; tests/test_xml.py; tests/test_auth.py; tests/test_json.py. Acceptance criteria: A fresh venv with `pip install httpie` can successfully execute `http https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSLError; HTTPS requests to other domains (e.g., `https://httpbin.org/get`) also verify certificates correctly; HTTP (non-HTTPS) requests continue to work as before; Existing tests for HTTPS/SSL functionality pass. Stop and ask the human if: If the fix requires modifying `requests` library source or dependencies; If the solution involves disabling SSL verification by default; If changes to packaging scripts (extras/) are deemed necessary; If the root cause is identified as a downstream issue (e.g., OpenSSL configuration); If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal changes to SSL context initialization in HTTP client code; Explicit configuration to use system certs (e.g., `verify=True` or default SSL context); No hardcoded certificate paths; Backward-compatible with older `requests` versions. Validate with: python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb; python -m httpie https://httpbin.org/get; python -m pytest tests/test_ssl.py -v. Report your work using this format: {'summary': 'Brief description of the root cause and fix', 'changes': ['List of modified files with specific changes'], 'validation': ['Results of validation commands'], 'risks': ['Any potential risks or tradeoffs'], 'test_coverage': ['New/updated tests and their status']}

---

## Scope enforcement

**You MAY only edit these paths:**
- `httpie/core.py`
- `httpie/manager/core.py`
- `httpie/cli/requestitems.py`
- `httpie/output/formatters/headers.py`
- `httpie/legacy/v3_2_0_session_header_format.py`
- `httpie/client.py`
- `httpie/ssl_.py`
- `extras/packaging/linux/scripts/httpie_cli.py`
- `tests/test_ssl.py`

**You must NOT touch:**
- `extras/packaging/linux/scripts/http_cli.py`
- `httpie_cli.py`
- `docs/`
- `extras/scripts/`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If the fix requires modifying `requests` library source or dependencies
- If the solution involves disabling SSL verification by default
- If changes to packaging scripts (extras/) are deemed necessary
- If the root cause is identified as a downstream issue (e.g., OpenSSL configuration)
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal changes to SSL context initialization in HTTP client code
- Explicit configuration to use system certs (e.g., `verify=True` or default SSL context)
- No hardcoded certificate paths
- Backward-compatible with older `requests` versions