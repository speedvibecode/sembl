# Graph Impact Analysis - wo-fastapitempl-1781181564-in-the-dashboard-resetting-a-password-is

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Frontend password reset flow (form validation, state handling).

**Likely edit targets**: `frontend/src/routes/_layout/index.tsx` (Dashboard entry point likely routes to reset page).

**Hidden coupling / risk**: Graph data provides no visibility into password reset logic, validation, or shared state. Risk unknown.

**Keep read-only**: `frontend/package.json`, `frontend/biome.json` (config files, not implementation).
