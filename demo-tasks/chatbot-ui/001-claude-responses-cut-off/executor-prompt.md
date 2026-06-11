# Executor Prompt - wo-chatbotui-1781197150-claude-3-responses-in-the-app-get-cut-of

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix Claude model streaming truncation by correcting the browser client or chat handler logic that prematurely terminates Claude API response streams. Original request: claude 3 responses in the app get cut off after a few words or tokens - i added anthropic credits, pasted a fresh api key, default settings, and the very first answer stops mid-sentence every time. increasing context length in settings did nothing. gpt models work fine, it's only the claude models. please fix so claude responses stream to completion.. User-visible outcome: Claude model responses now stream to completion without mid-sentence truncation, matching GPT model behavior. Non-goals: Modify GPT model streaming logic; Change UI rendering of messages; Alter API key validation; Update settings UI for context length; Modify Supabase or database logic. You MAY only edit these paths: components/workspace/workspace-settings.tsx; components/utility/profile-settings.tsx; components/chat/quick-settings.tsx; components/ui/chat-settings-form.tsx; app/api/chat/anthropic/route.ts; app/[locale]/[workspaceid]/layout.tsx; context/context.tsx; components/models/model-select.tsx. You must NOT touch: types.ts; supabase/types.ts; lib/utils.ts; components/ui/input.tsx; components/ui/button.tsx. Inspect these files before changing code: components/workspace/workspace-settings.tsx; lib/models/llm/anthropic-llm-list.ts; db/models.ts; db/workspaces.ts; context/context.tsx; lib/consume-stream.ts; lib/models/fetch-models.ts; public/worker-development.js; components/ui/context-menu.tsx; db/storage/workspace-images.ts; components/chat/chat-settings.tsx; components/chat/quick-settings.tsx. Inspect these tests before changing code: __tests__/lib/openapi-conversion.test.ts. Acceptance criteria: Claude 3 responses stream to full completion without truncation; GPT model streaming remains unaffected; No new console errors during Claude streaming; Response chunks are concatenated correctly in the chat handler; Stream termination only occurs on explicit [DONE] or error from Claude API. Stop and ask the human if: Claude API streaming logic cannot be isolated in browser-client.ts or use-chat-handler.tsx; Changes required in forbidden areas (types.ts, utils.ts, UI primitives); Streaming truncation persists after fixing obvious issues in editable paths; Claude-specific configuration is found in ChatbotUIContext that cannot be modified safely; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal changes to browser-client.ts or use-chat-handler.tsx; Possible addition of Claude-specific stream handling; No changes to types or UI primitives; No modifications to message rendering unless absolutely necessary. Validate with: npm test -- __tests__/lib/openapi-conversion.test.ts; npm run type-check; npm run lint; Test Claude 3 streaming in the app with a multi-sentence prompt; npm run build; npm run test. Report your work using this format: JSON with fields: root_cause, files_modified, changes_summary, validation_results (Claude streaming, GPT streaming, console errors), manual_test_passed (boolean)

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
- `types.ts`
- `supabase/types.ts`
- `lib/utils.ts`
- `components/ui/input.tsx`
- `components/ui/button.tsx`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- Claude API streaming logic cannot be isolated in browser-client.ts or use-chat-handler.tsx
- Changes required in forbidden areas (types.ts, utils.ts, UI primitives)
- Streaming truncation persists after fixing obvious issues in editable paths
- Claude-specific configuration is found in ChatbotUIContext that cannot be modified safely
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal changes to browser-client.ts or use-chat-handler.tsx
- Possible addition of Claude-specific stream handling
- No changes to types or UI primitives
- No modifications to message rendering unless absolutely necessary