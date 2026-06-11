# Executor Prompt - wo-katana-1781181138-katana-s-headless-options-ho-flag-is-ign

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix the regression in katana v1.4.0+ where the -headless-options / -ho flag is ignored, causing custom Chrome flags (e.g., proxy-server) to not be applied during headless execution. Original request: katana's -headless-options / -ho flag is ignored since v1.4.0 - e.g. running katana -headless -ho '--proxy-server=http://127.0.0.1:18080' and chrome never uses the proxy, traffic bypasses it completely. this worked fine in 1.3.x, looks like a regression from the headless rewrite. please fix so headless chrome actually gets the user's custom flags again.. User-visible outcome: Running `katana -headless -ho '--proxy-server=http://127.0.0.1:18080'` will now correctly route traffic through the specified proxy server, as it did in v1.3.x. Non-goals: Add new headless flags or options; Modify non-headless engine behavior; Change the CLI argument parsing for other flags; Update documentation or tests for unrelated features. You MAY only edit these paths: pkg/engine/headless/headless.go; pkg/engine/headless/headless_test.go; pkg/engine/headless/debugger.go; pkg/utils/queue/stack.go; cmd/functional-test/main.go; cmd/tools/crawl-maze-score/main.go; cmd/integration-test/integration-test.go; pkg/engine/headless/js/utils.js. You must NOT touch: cmd/functional-test/; cmd/tools/crawl-maze-score/; cmd/integration-test/; pkg/engine/headless/headless_test.go. Inspect these files before changing code: pkg/engine/headless/headless.go; pkg/engine/headless/headless_test.go; pkg/engine/headless/debugger.go; pkg/engine/headless/js/utils.js; pkg/engine/headless/js/page-init.js; pkg/engine/headless/captcha/js/identify.js; pkg/engine/headless/captcha/js/inject-hcaptcha.js; pkg/engine/headless/captcha/js/inject-recaptcha.js; pkg/engine/headless/captcha/js/inject-turnstile.js; pkg/utils/queue/stack.go; cmd/functional-test/main.go; cmd/tools/crawl-maze-score/main.go. Inspect these tests before changing code: pkg/engine/headless/headless_test.go. Acceptance criteria: Custom flags passed via -ho are applied to the headless Chrome instance; Proxy server flag (--proxy-server) works as expected when passed via -ho; No regression in existing headless functionality; Behavior matches v1.3.x for -ho flag handling. Stop and ask the human if: If the fix requires changes outside pkg/engine/headless/; If the solution involves modifying test files; If the change affects non-headless execution paths; If the fix cannot be validated with the existing test suite and manual checks; No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.. Patch expectations: Changes limited to pkg/engine/headless/headless.go and/or pkg/engine/headless/debugger.go; Modifications to how custom flags are passed to the Chrome binary; No changes to test files or unrelated packages; Minimal diff focusing solely on the flag-passing regression. Validate with: katana -headless -ho '--proxy-server=http://127.0.0.1:18080' -u http://example.com -d 1 -jc -kf 2>&1 | grep -i 'proxy' || echo 'Proxy flag not detected in output'; go test ./pkg/engine/headless/... -v. Report your work using this format: A JSON object with: { "changes": [{"file": "path", "diff": "unified diff"}], "validation": {"manual": ["description of manual tests performed"], "automated": ["output of validation commands"]}, "risks": ["any potential risks not covered by tests"] }

---

## Scope enforcement

**You MAY only edit these paths:**
- `pkg/engine/headless/headless.go`
- `pkg/engine/headless/headless_test.go`
- `pkg/engine/headless/debugger.go`
- `pkg/utils/queue/stack.go`
- `cmd/functional-test/main.go`
- `cmd/tools/crawl-maze-score/main.go`
- `cmd/integration-test/integration-test.go`
- `pkg/engine/headless/js/utils.js`

**You must NOT touch:**
- `cmd/functional-test/`
- `cmd/tools/crawl-maze-score/`
- `cmd/integration-test/`
- `pkg/engine/headless/headless_test.go`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If the fix requires changes outside pkg/engine/headless/
- If the solution involves modifying test files
- If the change affects non-headless execution paths
- If the fix cannot be validated with the existing test suite and manual checks
- No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.

## Patch expectations

- Changes limited to pkg/engine/headless/headless.go and/or pkg/engine/headless/debugger.go
- Modifications to how custom flags are passed to the Chrome binary
- No changes to test files or unrelated packages
- Minimal diff focusing solely on the flag-passing regression