# Work Order - wo-httpiecli-1781186027-httpie-is-completely-broken-for-https-si

**Repo:** `httpie-cli` | **Branch:** `run-current` | **Risk:** `HIGH`
**Created:** 2026-06-11T13:53:47.689591+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.

**Clarified goal:** Fix SSL certificate verification for HTTPS requests in httpie to restore system cert trust after requests 2.32.3 changes

**User-visible outcome:** HTTPS requests (e.g., `http https://example.com`) work without SSLError: CERTIFICATE_VERIFY_FAILED in fresh venvs

## 2. Boundary Lock

**Non-goals:**

- Add new CLI flags for SSL verification
- Modify packaging scripts (extras/)
- Change documentation
- Alter non-SSL-related HTTP client behavior

**Must not change:**

- Default behavior for HTTP (non-HTTPS) requests
- Custom SSL context configurations explicitly set by users
- Existing CLI argument parsing
- Response handling or output formatting

**Forbidden areas (agent must not touch):**

- extras/packaging/linux/scripts/http_cli.py
- httpie_cli.py
- docs/
- extras/scripts/

## 3. Scope Lock

**Likely affected areas:**

- httpie/core.py
- httpie
- docs/installation
- tests/client_certs
- httpie/cli
- httpie/legacy
- httpie/output
- httpie/manager
- httpie/plugins
- httpie/internal

**Editable paths (agent MAY modify):**

- httpie/core.py
- httpie/manager/core.py
- httpie/cli/requestitems.py
- httpie/output/formatters/headers.py
- httpie/legacy/v3_2_0_session_header_format.py
- httpie/client.py
- httpie/ssl_.py
- extras/packaging/linux/scripts/httpie_cli.py
- tests/test_ssl.py

**Read-only context (inspect, do not modify):**

- docs/README.md
- extras/packaging/linux/scripts/http_cli.py
- README.md
- httpie/cli/argtypes.py

## 4. Context Lock

**Files to inspect before starting:**

- httpie/core.py
- httpie/manager/core.py
- httpie/cli/requestitems.py
- httpie/output/formatters/headers.py
- httpie/legacy/v3_2_0_session_header_format.py
- tests/test_httpie.py
- tests/test_httpie_cli.py
- extras/packaging/linux/scripts/httpie_cli.py
- httpie/ssl_.py
- httpie/utils.py
- httpie/client.py
- httpie/compat.py

**Tests to inspect:**

- tests/test_ssl.py
- tests/test_httpie.py
- tests/test_httpie_cli.py
- tests/conftest.py
- tests/test_cli.py
- tests/test_xml.py
- tests/test_auth.py
- tests/test_json.py

**Architecture notes:**

- HTTPie uses the `requests` library for HTTP(S) requests
- SSL context configuration must not override system cert trust by default
- Changes in requests 2.32.3 affected implicit SSL context behavior
- Packaging scripts (extras/) are read-only and must not be modified

**Project rules found:**

```
[CONTRIBUTING.md]
# Contributing to HTTPie

Bug reports and code and documentation patches are welcome. You can
help this project also by using the development version of HTTPie
and by reporting any bugs you might encounter.

## 1. Reporting bugs

**It's important that you provide the full command a
```

## 5. Success Lock

**Acceptance criteria:**

1. A fresh venv with `pip install httpie` can successfully execute `http https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSLError
2. HTTPS requests to other domains (e.g., `https://httpbin.org/get`) also verify certificates correctly
3. HTTP (non-HTTPS) requests continue to work as before
4. Existing tests for HTTPS/SSL functionality pass

**Regressions to preserve:**

- Custom `--verify` flag behavior (e.g., `--verify=no`) must remain unchanged
- Proxy configurations must not break
- Session/cookie handling must remain intact
- All existing HTTP methods (GET, POST, etc.) must work

## 6. Proof Lock

**Validation commands:**

- `python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb`
- `python -m httpie https://httpbin.org/get`
- `python -m pytest tests/test_ssl.py -v`

**Tests to add or update:**

- tests/test_ssl.py (add regression test for requests 2.32.3+ system cert verification)

**Manual checks:**

1. Verify the fix works in a fresh venv with only `requests>=2.32.3` and `httpie` installed
2. Test with different system cert stores (macOS, Linux, Windows if applicable)
3. Confirm no performance regression in HTTPS handshake

## 7. Safety Lock

**Risk level:** `HIGH`

**Risk reasons:**

- Affects core HTTPS functionality (security-critical)
- Involves SSL/TLS verification (high-risk area)
- Changes may impact all HTTPS requests globally
- Potential for introducing security vulnerabilities if misconfigured

**Stop conditions (agent must halt and ask human):**

- If the fix requires modifying `requests` library source or dependencies
- If the solution involves disabling SSL verification by default
- If changes to packaging scripts (extras/) are deemed necessary
- If the root cause is identified as a downstream issue (e.g., OpenSSL configuration)
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Any change to default SSL verification behavior
- Modifications to core session/connection management
- If the fix touches files outside `httpie/` directory

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to SSL context initialization in HTTP client code
- Explicit configuration to use system certs (e.g., `verify=True` or default SSL context)
- No hardcoded certificate paths
- Backward-compatible with older `requests` versions

**Reporting format:** {'summary': 'Brief description of the root cause and fix', 'changes': ['List of modified files with specific changes'], 'validation': ['Results of validation commands'], 'risks': ['Any potential risks or tradeoffs'], 'test_coverage': ['New/updated tests and their status']}

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
