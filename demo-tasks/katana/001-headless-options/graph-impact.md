# Graph Impact Analysis - wo-katana-1781196770-katana-s-headless-options-ho-flag-is-ign

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Headless Chrome flag handling in `pkg/engine/headless/`, likely affecting flag parsing/propagation to Chrome instances.

**Likely edit targets**:
- `pkg/engine/headless/headless.go` (flag ingestion/launch logic)
- `pkg/engine/headless/debugger.go` (if flags are passed via debugger setup)

**Hidden coupling / risk**: None evident from graph data. No cross-module edges or shared state surfaced.

**Keep read-only**:
- `pkg/engine/headless/headless_test.go` (test file; context only)
