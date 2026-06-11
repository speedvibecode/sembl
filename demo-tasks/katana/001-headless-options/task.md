# katana / 001 — headless options ignored since v1.4.0

## Provenance

- Target repo: https://github.com/projectdiscovery/katana (~17k stars, Go crawler)
- Source issue: https://github.com/projectdiscovery/katana/issues/1621
  "Headless options ignored since v1.4.0"
- Human reference fix: https://github.com/projectdiscovery/katana/pull/1622
  (merge commit `f3fa1f0c2c7e4ddd706efad159f8a05286c88823`)
- Pinned base SHA (parent of the fix — bug live here):
  `007a5f4c8e8d4cddef53391aa4d8b800f13b3164`

## The bug

The v1.4.0 headless rewrite never passes `-headless-options` / `-ho` flags through to
Chrome. e.g. `-ho "--proxy-server=..."` is silently ignored and traffic bypasses the
proxy. Reference fix (+8 lines across 3 files): add a `UserArguments` field to the
browser launcher (`pkg/engine/headless/browser/browser.go`), wire
`ParseHeadlessOptionalArguments()` through `pkg/engine/headless/crawler/crawler.go`
and `pkg/engine/headless/headless.go`.

## Why this task

- Real regression, real closed issue, tiny multi-file reference fix.
- Issue names the FLAG, not the files; "headless" keyword hits a whole directory —
  ranking has to pick the wiring path, not just keyword-matching files.
- Go repo: no Go toolchain on the demo machine, so this is a scope-metrics task
  (executors cannot run tests; both arms equally constrained).

## Localization result (sembl 0.1.8, full graph: graphify + CRG 770 nodes)

editable_paths recall vs reference: **1/3** (headless.go ✓; browser.go ✗ crawler.go ✗).
Noise: headless_test.go, debugger.go, pkg/utils/queue/stack.go, cmd/* mains, js/utils.js.
Contradictions: `headless_test.go` and all three `cmd/` paths appear in BOTH
editable_paths and forbidden_areas. Replicates the httpie-cli/001 defect family on Go.
