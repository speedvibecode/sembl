# Graph Impact Analysis - wo-katana-1781181138-katana-s-headless-options-ho-flag-is-ign

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Headless Chrome launch logic and flag handling in the headless engine.

**Likely edit targets**:
- `pkg/engine/headless/headless.go` (primary headless logic)
- `pkg/engine/headless/debugger.go` (server/debugger interaction)

**Hidden coupling / risk**: None detected in provided graph data.

**Keep read-only**:
- `pkg/engine/headless/headless_test.go` (tests, not implementation)
- `cmd/functional-test/main.go`, `cmd/tools/crawl-maze-score/main.go` (unrelated entry points)
