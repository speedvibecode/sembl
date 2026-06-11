# Work Order - wo-katana-1781196770-katana-s-headless-options-ho-flag-is-ign

**Repo:** `katana` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T16:52:50.065009+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.

**Clarified goal:** Fix the regression in katana where the -headless-options/-ho flag is ignored, ensuring custom Chrome flags (e.g., --proxy-server) are properly passed to headless Chrome instances

**User-visible outcome:** Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy

## 2. Boundary Lock

**Non-goals:**

- Add new headless Chrome flags
- Modify non-headless execution paths
- Change default Chrome behavior without -ho
- Alter CLI argument parsing outside headless module

**Must not change:**

- Existing headless Chrome behavior when no -ho flag is provided
- Non-headless execution modes
- Other CLI flags or their parsing logic
- Test file contents (headless_test.go is read-only)

**Forbidden areas (agent must not touch):**

- cmd/
- integration_tests/

## 3. Scope Lock

**Likely affected areas:**

- pkg/engine/headless
- pkg/engine/headless/
- pkg/engine/headless/js
- pkg/engine/headless/graph
- pkg/engine/headless/types
- pkg/engine/headless/browser
- pkg/engine/headless/captcha
- pkg/engine/headless/crawler
- pkg/engine/headless/captcha/js
- pkg/engine/headless/browser/cookie

**Editable paths (agent MAY modify):**

- pkg/engine/headless/headless.go
- pkg/types/options.go
- internal/runner/options.go
- pkg/types/crawler_options.go
- pkg/engine/headless/browser/browser.go
- pkg/engine/headless/crawler/crawler.go
- pkg/engine/headless/browser/stealth/assets.go
- pkg/engine/headless/browser/element.go
- pkg/engine/headless/headless_test.go

**Read-only context (inspect, do not modify):**

- pkg/engine/headless/headless_test.go
- README.md
- pkg/types/options.go
- pkg/types/options_test.go
- pkg/types/crawler_options.go
- pkg/engine/headless/types
- pkg/engine/headless/types/types.go
- pkg/types/default.go

## 4. Context Lock

**Files to inspect before starting:**

- pkg/types/options.go
- pkg/output/options.go
- pkg/engine/common/http.go
- pkg/types/options_test.go
- internal/runner/options.go
- pkg/output/custom_field.go
- pkg/types/crawler_options.go
- internal/runner/options_test.go
- pkg/engine/headless/headless.go
- internal/testutils/testserver.go
- pkg/engine/headless/headless_test.go
- pkg/engine/headless/js/js.go

**Tests to inspect:**

- pkg/engine/headless/headless_test.go
- pkg/types/options_test.go
- internal/runner/options_test.go
- internal/testutils/testserver.go
- pkg/engine/headless/crawler/state_test.go
- pkg/engine/headless/captcha/inject_test.go
- pkg/engine/headless/captcha/solver_test.go
- pkg/engine/headless/browser/browser_test.go

**Architecture notes:**

- Headless Chrome flag handling is isolated to pkg/engine/headless/
- No cross-module dependencies detected for this functionality
- The regression was introduced during the headless rewrite in v1.4.0

## 5. Success Lock

**Acceptance criteria:**

1. Custom Chrome flags provided via -ho are passed to the Chrome instance
2. Proxy server flag (--proxy-server) works as expected when provided via -ho
3. Existing headless functionality without -ho remains unchanged
4. All existing tests in headless_test.go continue to pass

**Regressions to preserve:**

- Headless mode without -ho flag must work identically to current behavior
- All other CLI flags must continue to work as before

## 6. Proof Lock

**Validation commands:**

- `go test ./pkg/engine/headless/... -v`

**Tests to add or update:** _none identified_

**Manual checks:**

1. Verify proxy traffic routing with a test proxy server (e.g., mitmproxy) when using -ho '--proxy-server=...'
2. Confirm other Chrome flags (e.g., --user-agent) work via -ho

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Regression fix in core functionality (headless Chrome)
- Affects user-provided configuration (proxy settings)
- Potential to break existing headless behavior if not careful

**Stop conditions (agent must halt and ask human):**

- If changes are needed outside pkg/engine/headless/
- If the fix requires modifying test files
- If the solution involves changing CLI argument parsing in cmd/
- If the root cause is unclear after inspecting headless.go and debugger.go
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Any change to flag parsing logic that might affect other flags
- Modifications to Chrome launch configuration that could impact stability

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal diff in pkg/engine/headless/headless.go or debugger.go
- Changes limited to flag parsing/propagation logic
- No additions to test files
- No modifications to CLI argument definitions

**Reporting format:** Provide: 1) Summary of root cause, 2) Exact changes made, 3) Verification steps performed, 4) Test results (go test output), 5) Manual verification results if performed

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
