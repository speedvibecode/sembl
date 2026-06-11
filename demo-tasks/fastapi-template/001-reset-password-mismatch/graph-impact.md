# Graph Impact Analysis - wo-fastapitempl-1781197070-in-the-dashboard-resetting-a-password-is

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Frontend password reset flow (likely form validation logic).

**Likely edit targets**: `frontend/src/routes/_layout/index.tsx` (Dashboard entry point, may route to reset page).

**Hidden coupling / risk**: Graph data is thin-no direct reset password files surfaced. Risk of shared validation logic with signup/login (but those work fine).

**Keep read-only**: `frontend/biome.json`, `frontend/package.json` (config, not implementation).
