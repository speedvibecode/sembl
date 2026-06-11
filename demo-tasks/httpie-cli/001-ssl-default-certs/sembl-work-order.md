# Work Order - wo-httpiecli-1781196732-httpie-is-completely-broken-for-https-si

**Repo:** `httpie-cli` | **Branch:** `run-current` | **Risk:** `HIGH`
**Created:** 2026-06-11T16:52:12.801614+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> httpie is completely broken for https since requests 2.32.3 - in a fresh venv every https request fails with SSLError: CERTIFICATE_VERIFY_FAILED certificate verify failed: unable to get local issuer certificate. repro: pip install httpie then https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb . worked fine on older requests. apparently requests changed something about ssl contexts in 2.32.3. please fix this so plain https requests verify against the system certs again.

**Clarified goal:** Fix SSL certificate verification for HTTPS requests in httpie to use system certs by default, broken since requests 2.32.3

**User-visible outcome:** HTTPS requests (e.g., `https https://example.com`) verify certificates against system certs without SSLError

## 2. Boundary Lock

**Non-goals:**

- Add new CLI flags for SSL verification
- Change default behavior for non-HTTPS requests
- Modify packaging scripts
- Update dependencies beyond fixing the SSL context

**Must not change:**

- Existing HTTP (non-HTTPS) request behavior
- Custom SSL verification options (e.g., `--verify=no`)
- CLI argument parsing logic
- Response handling or output formatting

**Forbidden areas (agent must not touch):**

- extras/packaging/linux/scripts/http_cli.py
- extras/packaging/linux/scripts/httpie_cli.py
- extras/scripts/generate_man_pages.py
- docs/
- httpie.egg-info/

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
- httpie/client.py
- httpie/ssl_.py
- httpie/utils.py
- httpie/uploads.py
- httpie/sessions.py
- httpie/downloads.py
- httpie/manager/__main__.py
- tests/test_ssl.py

**Read-only context (inspect, do not modify):**

- tests/
- CONTRIBUTING.md
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

- Shared SSL context configuration between CLI entry points (httpie/__main__.py and httpie/manager/__main__.py)
- Must respect existing `--verify` flag behavior
- Changes must not break cross-module SSL context reuse

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

1. A fresh venv with `pip install httpie` can successfully execute `https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb` without SSLError
2. HTTPS requests verify against system certs by default
3. Existing `--verify=no` and custom CA bundle paths continue to work
4. No regression in HTTP (non-HTTPS) requests

**Regressions to preserve:**

- All existing SSL/TLS verification behaviors (e.g., `--verify`, `--cert`)
- HTTP request handling
- CLI argument parsing
- Error messages for non-SSL failures

## 6. Proof Lock

**Validation commands:**

- `python -m httpie https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb`
- `python -m httpie --verify=no https://expired.badssl.com 2>&1 | grep -q 'SSL'`
- `python -m httpie http://example.com | grep -q 'HTTP'`

**Tests to add or update:**

- tests/test_https.py::test_default_ssl_verification
- tests/test_ssl.py::test_system_certs_used_by_default

**Manual checks:**

1. Verify the fix works on macOS, Linux, and Windows (system cert paths vary by OS)
2. Test with custom `--verify` paths to ensure no regression

## 7. Safety Lock

**Risk level:** `HIGH`

**Risk reasons:**

- Affects core HTTPS functionality (all users impacted)
- Shared SSL context between CLI modules (high coupling)
- Security-sensitive (certificate verification)
- Cross-platform behavior (system cert paths differ by OS)

**Stop conditions (agent must halt and ask human):**

- Cannot determine how httpie initializes SSL context for requests
- Unclear how requests 2.32.3 changed SSL behavior (needs investigation)
- Fix requires modifying packaging scripts or build system
- Change would break existing `--verify` flag behavior
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Changes to core SSL context initialization logic
- Modifications to shared modules (e.g., httpie/core.py) used by multiple entry points

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to SSL context initialization in httpie/core.py or client.py
- No changes to CLI argument parsing
- No new dependencies
- Backward-compatible with existing `--verify` flags

**Reporting format:** {'summary': 'One-line description of the fix', 'changes': ['List of modified files with brief descriptions'], 'validation': ['Output of validation commands'], 'risks': ['Any remaining concerns or edge cases'], 'diff': 'Full diff of changes'}

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
