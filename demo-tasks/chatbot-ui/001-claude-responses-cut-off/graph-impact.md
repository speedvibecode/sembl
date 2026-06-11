# Graph Impact Analysis - wo-chatbotui-1781196195-claude-3-responses-in-the-app-get-cut-of

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Claude-specific streaming logic, likely in chat handler or API client modules.

**Likely edit targets**: `use-chat-handler.tsx`, `browser-client.ts` (Claude API integration), `chat-ui.tsx` (streaming UI).

**Hidden coupling / risk**: Shared `ChatbotUIContext` (state for models/settings) may affect streaming. `message.tsx` renders responses-could mask truncation.

**Keep read-only**: `package.json`, `.eslintrc.json`, `types/`, `supabase/types.ts` (no structural impact shown).
