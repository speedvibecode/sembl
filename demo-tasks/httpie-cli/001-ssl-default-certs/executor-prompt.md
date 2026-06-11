# Executor Prompt - wo-httpiecli-1781196732-httpie-is-completely-broken-for-https-si

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix SSL certificate verification for HTTPS requests in httpie to use system certs by default, broken since requests 2.32.3. Original request: httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.. User-visible outcome: HTTPS requests (e.g., `https https://example.com`) verify certificates against system certs without SSLError. Non-goals: Add new CLI flags for SSL verification; Change default behavior for non-HTTPS requests; Modify packaging scripts; Update dependencies beyond fixing the SSL context. You MAY only edit these paths: httpie/core.py; httpie/client.py; httpie/ssl_.py; httpie/utils.py; httpie/uploads.py; httpie/sessions.py; httpie/downloads.py; httpie/manager/__main__.py; tests/test_ssl.py. You must NOT touch: extras/packaging/linux/scripts/http_cli.py; extras/packaging/linux/scripts/httpie_cli.py; extras/scripts/generate_man_pages.py; docs/; httpie.egg-info/. Inspect these files before changing code: httpie/core.py; httpie/manager/core.py; httpie/cli/requestitems.py; httpie/output/formatters/headers.py; httpie/legacy/v3_2_0_session_header_format.py; tests/test_httpie.py; tests/test_httpie_cli.py; extras/packaging/linux/scripts/httpie_cli.py; httpie/ssl_.py; httpie/utils.py; httpie/client.py; httpie/compat.py. Inspect these tests before changing code: tests/test_ssl.py; tests/test_httpie.py; tests/test_httpie_cli.py; tests/conftest.py; tests/test_cli.py; tests/test_xml.py; tests/test_auth.py; tests/test_json.py. Acceptance criteria: A fresh venv with `pip install httpie` can successfully execute `https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSLError; HTTPS requests verify against system certs by default; Existing `--verify=no` and custom CA bundle paths continue to work; No regression in HTTP (non-HTTPS) requests. Stop and ask the human if: Cannot determine how httpie initializes SSL context for requests; Unclear how requests 2.32.3 changed SSL behavior (needs investigation); Fix requires modifying packaging scripts or build system; Change would break existing `--verify` flag behavior; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal changes to SSL context initialization in httpie/core.py or client.py; No changes to CLI argument parsing; No new dependencies; Backward-compatible with existing `--verify` flags. Validate with: python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb; python -m httpie --verify=no https://expired.badssl.com 2>&1 | grep -q 'SSL'; python -m httpie http://example.com | grep -q 'HTTP'. Report your work using this format: {'summary': 'One-line description of the fix', 'changes': ['List of modified files with brief descriptions'], 'validation': ['Output of validation commands'], 'risks': ['Any remaining concerns or edge cases'], 'diff': 'Full diff of changes'}

---

## Scope enforcement

**You MAY only edit these paths:**
- `httpie/core.py`
- `httpie/client.py`
- `httpie/ssl_.py`
- `httpie/utils.py`
- `httpie/uploads.py`
- `httpie/sessions.py`
- `httpie/downloads.py`
- `httpie/manager/__main__.py`
- `tests/test_ssl.py`

**You must NOT touch:**
- `extras/packaging/linux/scripts/http_cli.py`
- `extras/packaging/linux/scripts/httpie_cli.py`
- `extras/scripts/generate_man_pages.py`
- `docs/`
- `httpie.egg-info/`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- Cannot determine how httpie initializes SSL context for requests
- Unclear how requests 2.32.3 changed SSL behavior (needs investigation)
- Fix requires modifying packaging scripts or build system
- Change would break existing `--verify` flag behavior
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal changes to SSL context initialization in httpie/core.py or client.py
- No changes to CLI argument parsing
- No new dependencies
- Backward-compatible with existing `--verify` flags