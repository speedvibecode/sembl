# Executor Prompt - wo-katana-1781196770-katana-s-headless-options-ho-flag-is-ign

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix the regression in katana where the -headless-options/-ho flag is ignored, ensuring custom Chrome flags (e.g., --proxy-server) are properly passed to headless Chrome instances. Original request: katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.. User-visible outcome: Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy. Non-goals: Add new headless Chrome flags; Modify non-headless execution paths; Change default Chrome behavior without -ho; Alter CLI argument parsing outside headless module. You MAY only edit these paths: pkg/engine/headless/headless.go; pkg/types/options.go; internal/runner/options.go; pkg/types/crawler_options.go; pkg/engine/headless/browser/browser.go; pkg/engine/headless/crawler/crawler.go; pkg/engine/headless/browser/stealth/assets.go; pkg/engine/headless/browser/element.go; pkg/engine/headless/headless_test.go. You must NOT touch: cmd/; integration_tests/. Inspect these files before changing code: pkg/types/options.go; pkg/output/options.go; pkg/engine/common/http.go; pkg/types/options_test.go; internal/runner/options.go; pkg/output/custom_field.go; pkg/types/crawler_options.go; internal/runner/options_test.go; pkg/engine/headless/headless.go; internal/testutils/testserver.go; pkg/engine/headless/headless_test.go; pkg/engine/headless/js/js.go. Inspect these tests before changing code: pkg/engine/headless/headless_test.go; pkg/types/options_test.go; internal/runner/options_test.go; internal/testutils/testserver.go; pkg/engine/headless/crawler/state_test.go; pkg/engine/headless/captcha/inject_test.go; pkg/engine/headless/captcha/solver_test.go; pkg/engine/headless/browser/browser_test.go. Acceptance criteria: Custom Chrome flags provided via -ho are passed to the Chrome instance; Proxy server flag (--proxy-server) works as expected when provided via -ho; Existing headless functionality without -ho remains unchanged; All existing tests in headless_test.go continue to pass. Stop and ask the human if: If changes are needed outside pkg/engine/headless/; If the fix requires modifying test files; If the solution involves changing CLI argument parsing in cmd/; If the root cause is unclear after inspecting headless.go and debugger.go; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal diff in pkg/engine/headless/headless.go or debugger.go; Changes limited to flag parsing/propagation logic; No additions to test files; No modifications to CLI argument definitions. Validate with: go test ./pkg/engine/headless/... -v. Report your work using this format: Provide: 1) Summary of root cause, 2) Exact changes made, 3) Verification steps performed, 4) Test results (go test output), 5) Manual verification results if performed

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
- `cmd/`
- `integration_tests/`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If changes are needed outside pkg/engine/headless/
- If the fix requires modifying test files
- If the solution involves changing CLI argument parsing in cmd/
- If the root cause is unclear after inspecting headless.go and debugger.go
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal diff in pkg/engine/headless/headless.go or debugger.go
- Changes limited to flag parsing/propagation logic
- No additions to test files
- No modifications to CLI argument definitions