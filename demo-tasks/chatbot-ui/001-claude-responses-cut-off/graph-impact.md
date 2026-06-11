# Graph Impact Analysis - wo-chatbotui-1781197150-claude-3-responses-in-the-app-get-cut-of

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: Claude-specific streaming logic, likely in chat handler or API client code.

**Likely edit targets**: `use-chat-handler.tsx`, `browser-client.ts` (Claude API calls), `chat-ui.tsx` (streaming display).

**Hidden coupling / risk**: Shared `ChatbotUIContext` (27-node community) may hold model configs affecting streaming. `message.tsx` (37-node community) may render partial responses.

**Keep read-only**: `types.ts`, `supabase/types.ts`, `utils.ts`, UI primitives (`input.tsx`, `button.tsx`). Graph shows 0 changed files; all edits are speculative.
