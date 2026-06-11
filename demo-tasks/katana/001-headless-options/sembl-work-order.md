# Work Order - wo-katana-1781181138-katana-s-headless-options-ho-flag-is-ign

**Repo:** `katana` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T12:32:18.735625+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.

**Clarified goal:** Fix the regression in katana v1.4.0+ where the -headless-options / -ho flag is ignored, causing custom Chrome flags (e.g., proxy-server) to not be applied during headless execution

**User-visible outcome:** Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy server, as it did in v1.3.x

## 2. Boundary Lock

**Non-goals:**

- Add new headless flags or options
- Modify non-headless engine behavior
- Change the CLI argument parsing for other flags
- Update documentation or tests for unrelated features

**Must not change:**

- Existing headless functionality unrelated to custom flag passing
- CLI argument parsing for other flags
- Behavior of non-headless crawling modes
- Test files (only implementation files may be modified)

**Forbidden areas (agent must not touch):**

- cmd/functional-test/
- cmd/tools/crawl-maze-score/
- cmd/integration-test/
- pkg/engine/headless/headless_test.go

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
- pkg/engine/headless/headless_test.go
- pkg/engine/headless/debugger.go
- pkg/utils/queue/stack.go
- cmd/functional-test/main.go
- cmd/tools/crawl-maze-score/main.go
- cmd/integration-test/integration-test.go
- pkg/engine/headless/js/utils.js

**Read-only context (inspect, do not modify):**

- pkg/engine/headless/headless_test.go
- README.md
- pkg/engine/headless/types

## 4. Context Lock

**Files to inspect before starting:**

- pkg/engine/headless/headless.go
- pkg/engine/headless/headless_test.go
- pkg/engine/headless/debugger.go
- pkg/engine/headless/js/utils.js
- pkg/engine/headless/js/page-init.js
- pkg/engine/headless/captcha/js/identify.js
- pkg/engine/headless/captcha/js/inject-hcaptcha.js
- pkg/engine/headless/captcha/js/inject-recaptcha.js
- pkg/engine/headless/captcha/js/inject-turnstile.js
- pkg/utils/queue/stack.go
- cmd/functional-test/main.go
- cmd/tools/crawl-maze-score/main.go

**Tests to inspect:**

- pkg/engine/headless/headless_test.go

**Architecture notes:**

- Headless Chrome launch logic is centralized in pkg/engine/headless/
- Custom flags must be passed through to the Chrome/Chromium binary at launch
- The regression was introduced during the headless rewrite in v1.4.0

## 5. Success Lock

**Acceptance criteria:**

1. Custom flags passed via -ho are applied to the headless Chrome instance
2. Proxy server flag (--proxy-server) works as expected when passed via -ho
3. No regression in existing headless functionality
4. Behavior matches v1.3.x for -ho flag handling

**Regressions to preserve:**

- All existing headless crawling behavior not related to custom flags
- CLI argument parsing for other flags remains unchanged
- Non-headless modes continue to work as before

## 6. Proof Lock

**Validation commands:**

- `katana -headless -ho '--proxy-server=http://127.0.0.1:18080' -u http://example.com -d 1 -jc -kf 2>&1 | grep -i 'proxy' || echo 'Proxy flag not detected in output'`
- `go test ./pkg/engine/headless/... -v`

**Tests to add or update:** _none identified_

**Manual checks:**

1. Verify with a real proxy server (e.g., mitmproxy) that traffic is routed through it when -ho '--proxy-server=...' is used
2. Test multiple custom flags via -ho to ensure all are applied

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Regression in a core feature (headless flag handling)
- Affects user-facing behavior (proxy settings ignored)
- Requires changes to critical path (Chrome launch logic)

**Stop conditions (agent must halt and ask human):**

- If the fix requires changes outside pkg/engine/headless/
- If the solution involves modifying test files
- If the change affects non-headless execution paths
- If the fix cannot be validated with the existing test suite and manual checks
- No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.

**Approval triggers (blocks merge):**

- Any change to the public API of the headless package
- Modifications to flag parsing logic outside the headless package

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Changes limited to pkg/engine/headless/headless.go and/or pkg/engine/headless/debugger.go
- Modifications to how custom flags are passed to the Chrome binary
- No changes to test files or unrelated packages
- Minimal diff focusing solely on the flag-passing regression

**Reporting format:** A JSON object with: { "changes": [{"file": "path", "diff": "unified diff"}], "validation": {"manual": ["description of manual tests performed"], "automated": ["output of validation commands"]}, "risks": ["any potential risks not covered by tests"] }

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
