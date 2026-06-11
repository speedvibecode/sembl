# Work Order - wo-httpiecli-1781163174-httpie-is-completely-broken-for-https-si

**Repo:** `httpie-cli` | **Branch:** `pinned-base` | **Risk:** `HIGH`
**Created:** 2026-06-11T07:32:54.868956+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.

**Clarified goal:** Fix SSL certificate verification for HTTPS requests in httpie by ensuring the requests library uses system certificates after version 2.32.3

**User-visible outcome:** HTTPS requests (e.g., `https https://raw.githubusercontent.com/...`) succeed without SSLError: CERTIFICATE_VERIFY_FAILED

## 2. Boundary Lock

**Non-goals:**

- Change default HTTP behavior
- Modify non-HTTPS request handling
- Alter CLI argument parsing
- Update documentation for unrelated features

**Must not change:**

- Existing HTTP (non-HTTPS) request behavior
- Custom certificate verification options (e.g., --verify)
- Proxy handling
- Authentication flows

**Forbidden areas (agent must not touch):**

- docs/README.md
- extras/packaging/linux/scripts/http_cli.py
- httpie/__main__.py

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

- extras/packaging/linux/scripts/httpie_cli.py
- httpie/__main__.py
- httpie/manager/__main__.py
- extras/scripts/generate_man_pages.py
- extras/packaging/linux/scripts/http_cli.py
- httpie/core.py
- httpie/client.py
- httpie/config.py

**Read-only context (inspect, do not modify):**

- tests/
- docs/
- extras/
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
- SSL verification is typically configured via `requests.Session` or per-request `verify` parameter
- System certificates are usually loaded via `certifi` or platform-specific paths
- Changes must respect existing `--verify` CLI flag behavior

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

1. A fresh venv with `requests>=2.32.3` can successfully execute `https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSL errors
2. Existing `--verify` flag behavior remains unchanged (e.g., `--verify=no` still disables verification)
3. No regression in HTTP (non-HTTPS) requests
4. All existing SSL-related tests pass

**Regressions to preserve:**

- Custom certificate paths via `--verify`
- Disable verification with `--verify=no`
- Proxy support over HTTPS
- Client certificate authentication

## 6. Proof Lock

**Validation commands:**

- `python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb`
- `python -m pytest tests/test_ssl.py -v`

**Tests to add or update:**

- tests/test_ssl.py (add test for system cert verification with requests>=2.32.3)

**Manual checks:**

1. Verify the fix works on macOS, Linux, and Windows (different system cert paths)
2. Test with `requests==2.32.2` to ensure backward compatibility
3. Test with custom `--verify` paths

## 7. Safety Lock

**Risk level:** `HIGH`

**Risk reasons:**

- Affects core HTTPS functionality (all secure requests)
- Involves SSL/TLS configuration which is security-sensitive
- Cross-platform compatibility concerns (system cert paths vary)
- Dependency behavior change (`requests` 2.32.3) with potential hidden side effects

**Stop conditions (agent must halt and ask human):**

- If the fix requires modifying `certifi` or platform-specific cert paths directly
- If the solution involves downgrading `requests`
- If changes to `httpie/__main__.py` are deemed necessary (forbidden per graph)
- If the root cause is unclear after inspecting `requests` 2.32.3 changelog

**Approval triggers (blocks merge):**

- Changes to default SSL verification behavior
- Modifications to how `verify` parameter is passed to `requests`
- Any platform-specific conditional logic for cert paths

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to SSL/TLS configuration in httpie's requests usage
- Explicit system certificate path handling if requests 2.32.3+ no longer defaults to it
- No changes to CLI argument parsing or user-facing behavior beyond fixing the bug
- Test additions for SSL verification with modern requests versions

**Reporting format:** A JSON object with: { 'changes': [list of modified files with brief descriptions], 'validation': { 'commands': [list of validation commands run], 'results': [pass/fail for each] }, 'tests': { 'added': [list of new tests], 'updated': [list of modified tests] }, 'manual_checks': [list of manual verifications performed], 'risks': [any unresolved concerns] }

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
