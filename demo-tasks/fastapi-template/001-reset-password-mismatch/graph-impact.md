# Graph Impact Analysis - wo-fastapitempl-1781196074-in-the-dashboard-resetting-a-password-is

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Frontend password reset flow (validation logic, form handling).

**Likely edit targets**: `frontend/src/routes/_layout/index.tsx` (Dashboard entry point, likely routes to reset page).

**Hidden coupling / risk**: Graph data is thin-no direct nodes for reset password page or validation logic. Risk of undetected shared state or cross-module links.

**Keep read-only**: `frontend/biome.json`, `frontend/package.json` (config files, irrelevant to logic).
