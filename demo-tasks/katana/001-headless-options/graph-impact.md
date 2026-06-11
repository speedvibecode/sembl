# Graph Impact Analysis - wo-katana-1781186477-katana-s-headless-options-ho-flag-is-ign

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Headless Chrome flag handling, likely confined to headless engine and its CLI integration.

**Likely edit targets**:
- `pkg/engine/headless/headless.go`
- `pkg/engine/headless/debugger.go`

**Hidden coupling / risk**: Graph shows no direct edges to CLI flag parsing; regression suggests coupling between headless rewrite and flag propagation. Risk of missed flag-passing logic in debugger or headless setup.

**Keep read-only**:
- `pkg/engine/headless/headless_test.go` (context only)
- `cmd/tools/crawl-maze-score/main.go`, `cmd/functional-test/main.go` (unrelated communities)
