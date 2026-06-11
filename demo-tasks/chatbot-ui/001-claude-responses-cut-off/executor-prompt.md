# Executor Prompt - wo-chatbotui-1781196195-claude-3-responses-in-the-app-get-cut-of

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix streaming truncation for Claude 3 models by correcting the API client or chat handler logic that prematurely terminates the response stream. Original request: claude 3 responses in the app get cut off after a few words or tokens - i added anthropic credits, pasted a fresh api key, default settings, and the very first answer stops mid-sentence every time. increasing context length in settings did nothing. gpt models work fine, it's only the claude models. please fix so claude responses stream to completion.. User-visible outcome: Claude 3 model responses stream to completion without mid-sentence truncation, matching the behavior of GPT models. Non-goals: Modify non-Claude model streaming behavior; Change UI rendering logic unless directly causing truncation; Alter API key handling or authentication flows; Update dependencies or package.json; Modify Supabase types or database schemas. You MAY only edit these paths: components/workspace/workspace-settings.tsx; components/utility/profile-settings.tsx; components/chat/quick-settings.tsx; components/ui/chat-settings-form.tsx; app/api/chat/anthropic/route.ts; app/[locale]/[workspaceid]/layout.tsx; context/context.tsx; components/models/model-select.tsx. You must NOT touch: package.json; .eslintrc.json; types/; supabase/types.ts; db/; worker/. Inspect these files before changing code: components/workspace/workspace-settings.tsx; lib/models/llm/anthropic-llm-list.ts; db/models.ts; db/workspaces.ts; context/context.tsx; lib/consume-stream.ts; lib/models/fetch-models.ts; public/worker-development.js; components/ui/context-menu.tsx; db/storage/workspace-images.ts; components/chat/chat-settings.tsx; components/chat/quick-settings.tsx. Inspect these tests before changing code: __tests__/lib/openapi-conversion.test.ts. Acceptance criteria: Claude 3 responses stream to full completion without premature truncation; GPT model streaming remains unaffected; No new errors in browser console during Claude 3 streaming; Streaming behavior matches the expected token-by-token delivery. Stop and ask the human if: If changes to ChatbotUIContext are required (high risk of breaking other features); If the root cause is identified as a third-party library bug (e.g., Anthropic SDK); If the fix requires modifying Supabase client initialization; If truncation persists after exhausting likely_affected_areas; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Fix in use-chat-handler.tsx: Correct stream handling for Claude models (e.g., remove premature stream closure, fix chunk aggregation); Fix in browser-client.ts: Adjust Claude API client to properly handle streaming responses (e.g., timeout settings, response parsing); No changes to message.tsx or chat-ui.tsx unless rendering is proven to cause truncation; No modifications to context/context.tsx without approval. Validate with: npm test -- __tests__/lib/openapi-conversion.test.ts; npm run lint; npm run type-check; npm run build; npm run test. Report your work using this format: Provide: (1) Root cause (file:line), (2) Fix applied, (3) Validation results (Claude 3 streaming test, GPT parity check, console errors), (4) Any manual checks performed.

---

## Scope enforcement

**You MAY only edit these paths:**
- `components/workspace/workspace-settings.tsx`
- `components/utility/profile-settings.tsx`
- `components/chat/quick-settings.tsx`
- `components/ui/chat-settings-form.tsx`
- `app/api/chat/anthropic/route.ts`
- `app/[locale]/[workspaceid]/layout.tsx`
- `context/context.tsx`
- `components/models/model-select.tsx`

**You must NOT touch:**
- `package.json`
- `.eslintrc.json`
- `types/`
- `supabase/types.ts`
- `db/`
- `worker/`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If changes to ChatbotUIContext are required (high risk of breaking other features)
- If the root cause is identified as a third-party library bug (e.g., Anthropic SDK)
- If the fix requires modifying Supabase client initialization
- If truncation persists after exhausting likely_affected_areas
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Fix in use-chat-handler.tsx: Correct stream handling for Claude models (e.g., remove premature stream closure, fix chunk aggregation)
- Fix in browser-client.ts: Adjust Claude API client to properly handle streaming responses (e.g., timeout settings, response parsing)
- No changes to message.tsx or chat-ui.tsx unless rendering is proven to cause truncation
- No modifications to context/context.tsx without approval