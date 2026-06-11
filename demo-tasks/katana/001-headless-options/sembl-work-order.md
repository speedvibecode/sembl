# Work Order - wo-katana-1781186477-katana-s-headless-options-ho-flag-is-ign

**Repo:** `katana` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T14:01:17.293774+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.

**Clarified goal:** Fix regression in katana where -headless-options / -ho flags are ignored by headless Chrome since v1.4.0, ensuring user-provided flags (e.g., --proxy-server) are propagated to the Chrome instance

**User-visible outcome:** Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy

## 2. Boundary Lock

**Non-goals:**

- Add new CLI flags
- Modify non-headless engine behavior
- Change default Chrome flags
- Alter test logic in headless_test.go

**Must not change:**

- Existing headless Chrome functionality for non-custom flags
- CLI flag parsing logic outside headless engine
- Behavior of other engine types (e.g., non-headless)

**Forbidden areas (agent must not touch):**

- cmd/tools/crawl-maze-score
- cmd/functional-test
- cmd/integration-test
- pkg/engine/headless/headless_test.go

## 3. Scope Lock

**Likely affected areas:**

- pkg/engine/headless
- pkg/engine/headless/js
- pkg/engine/headless/graph
- pkg/engine/headless/types
- pkg/engine/headless/browser
- pkg/engine/headless/captcha
- pkg/engine/headless/crawler
- pkg/engine/headless/captcha/js
- pkg/engine/headless/browser/cookie
- pkg/engine/headless/browser/stealth

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

- Headless engine is decoupled from CLI parsing; flags must be explicitly passed through
- Regression introduced in v1.4.0 during headless rewrite suggests missing flag propagation in debugger or headless setup
- Graph shows no direct edges between CLI and headless flag handling, implying indirect coupling

## 5. Success Lock

**Acceptance criteria:**

1. User-provided -ho flags are appended to Chrome's launch arguments
2. Proxy server flag (--proxy-server) works as expected when passed via -ho
3. No existing headless functionality is broken (e.g., default flags still work)
4. All existing headless tests pass

**Regressions to preserve:**

- Default headless Chrome behavior without -ho flags
- Other headless options (e.g., --no-sandbox) continue to work
- Non-headless engine modes remain unaffected

## 6. Proof Lock

**Validation commands:**

- `go test ./pkg/engine/headless/... -v`
- `katana -headless -ho '--proxy-server=http://127.0.0.1:18080' -u http://example.com -d 1 -jc 1 2>&1 | grep -i 'proxy' || echo 'Proxy flag not visible in output (may still be applied)'`

**Tests to add or update:**

- pkg/engine/headless/headless_test.go (add test case for -ho flag propagation)

**Manual checks:**

1. Verify with a real proxy (e.g., mitmproxy) that traffic is routed through the proxy when -ho '--proxy-server=...' is used
2. Test multiple -ho flags (e.g., --proxy-server and --user-agent) to ensure all are propagated

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Regression in a core feature (headless flag handling)
- Hidden coupling between headless rewrite and flag propagation (per graph analysis)
- Potential to break existing headless functionality if flag passing is mishandled

**Stop conditions (agent must halt and ask human):**

- If the fix requires modifying CLI flag parsing logic outside pkg/engine/headless
- If the change affects non-headless engine behavior
- If existing headless tests fail after the fix
- If the debugger or headless setup cannot be modified without breaking other functionality
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Changes to files outside pkg/engine/headless
- Modifications to default Chrome flags or behavior
- Any risk of breaking backward compatibility with existing -ho usage

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to headless.go or debugger.go to propagate -ho flags to Chrome
- No changes to test files in the initial fix (tests may be added separately)
- No modifications to CLI parsing or other engine types

**Reporting format:** Structured summary with: 1) Root cause (1 sentence), 2) Files modified, 3) Changes made (bullet points), 4) Validation results (tests + manual checks), 5) Confirmation of acceptance criteria

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
