# Executor Prompt - wo-katana-1781186477-katana-s-headless-options-ho-flag-is-ign

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix regression in katana where -headless-options / -ho flags are ignored by headless Chrome since v1.4.0, ensuring user-provided flags (e.g., --proxy-server) are propagated to the Chrome instance. Original request: katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.. User-visible outcome: Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy. Non-goals: Add new CLI flags; Modify non-headless engine behavior; Change default Chrome flags; Alter test logic in headless_test.go. You MAY only edit these paths: pkg/engine/headless/headless.go; pkg/types/options.go; internal/runner/options.go; pkg/types/crawler_options.go; pkg/engine/headless/browser/browser.go; pkg/engine/headless/crawler/crawler.go; pkg/engine/headless/browser/stealth/assets.go; pkg/engine/headless/browser/element.go; pkg/engine/headless/headless_test.go. You must NOT touch: cmd/tools/crawl-maze-score; cmd/functional-test; cmd/integration-test; pkg/engine/headless/headless_test.go. Inspect these files before changing code: pkg/types/options.go; pkg/output/options.go; pkg/engine/common/http.go; pkg/types/options_test.go; internal/runner/options.go; pkg/output/custom_field.go; pkg/types/crawler_options.go; internal/runner/options_test.go; pkg/engine/headless/headless.go; internal/testutils/testserver.go; pkg/engine/headless/headless_test.go; pkg/engine/headless/js/js.go. Inspect these tests before changing code: pkg/engine/headless/headless_test.go; pkg/types/options_test.go; internal/runner/options_test.go; internal/testutils/testserver.go; pkg/engine/headless/crawler/state_test.go; pkg/engine/headless/captcha/inject_test.go; pkg/engine/headless/captcha/solver_test.go; pkg/engine/headless/browser/browser_test.go. Acceptance criteria: User-provided -ho flags are appended to Chrome's launch arguments; Proxy server flag (--proxy-server) works as expected when passed via -ho; No existing headless functionality is broken (e.g., default flags still work); All existing headless tests pass. Stop and ask the human if: If the fix requires modifying CLI flag parsing logic outside pkg/engine/headless; If the change affects non-headless engine behavior; If existing headless tests fail after the fix; If the debugger or headless setup cannot be modified without breaking other functionality; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal changes to headless.go or debugger.go to propagate -ho flags to Chrome; No changes to test files in the initial fix (tests may be added separately); No modifications to CLI parsing or other engine types. Validate with: go test ./pkg/engine/headless/... -v; katana -headless -ho '--proxy-server=http://127.0.0.1:18080' -u http://example.com -d 1 -jc 1 2>&1 | grep -i 'proxy' || echo 'Proxy flag not visible in output (may still be applied)'. Report your work using this format: Structured summary with: 1) Root cause (1 sentence), 2) Files modified, 3) Changes made (bullet points), 4) Validation results (tests + manual checks), 5) Confirmation of acceptance criteria

---

## Scope enforcement

**You MAY only edit these paths:**
- `pkg/engine/headless/headless.go`
- `pkg/types/options.go`
- `internal/runner/options.go`
- `pkg/types/crawler_options.go`
- `pkg/engine/headless/browser/browser.go`
- `pkg/engine/headless/crawler/crawler.go`
- `pkg/engine/headless/browser/stealth/assets.go`
- `pkg/engine/headless/browser/element.go`
- `pkg/engine/headless/headless_test.go`

**You must NOT touch:**
- `cmd/tools/crawl-maze-score`
- `cmd/functional-test`
- `cmd/integration-test`
- `pkg/engine/headless/headless_test.go`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If the fix requires modifying CLI flag parsing logic outside pkg/engine/headless
- If the change affects non-headless engine behavior
- If existing headless tests fail after the fix
- If the debugger or headless setup cannot be modified without breaking other functionality
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal changes to headless.go or debugger.go to propagate -ho flags to Chrome
- No changes to test files in the initial fix (tests may be added separately)
- No modifications to CLI parsing or other engine types