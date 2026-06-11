# Work Order - wo-chatbotui-1781197150-claude-3-responses-in-the-app-get-cut-of

**Repo:** `chatbot-ui` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T16:59:10.569901+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> claude 3 responses in the app get cut off after a few words or tokens - i added anthropic credits, pasted a fresh api key, default settings, and the very first answer stops mid-sentence every time. increasing context length in settings did nothing. gpt models work fine, it's only the claude models. please fix so claude responses stream to completion.

**Clarified goal:** Fix Claude model streaming truncation by correcting the browser client or chat handler logic that prematurely terminates Claude API response streams

**User-visible outcome:** Claude model responses now stream to completion without mid-sentence truncation, matching GPT model behavior

## 2. Boundary Lock

**Non-goals:**

- Modify GPT model streaming logic
- Change UI rendering of messages
- Alter API key validation
- Update settings UI for context length
- Modify Supabase or database logic

**Must not change:**

- GPT model streaming behavior
- Existing message rendering for non-Claude models
- API key handling for other providers
- ChatbotUIContext structure (only read, do not modify types)
- UI primitives (input.tsx, button.tsx)

**Forbidden areas (agent must not touch):**

- types.ts
- supabase/types.ts
- lib/utils.ts
- components/ui/input.tsx
- components/ui/button.tsx

## 3. Scope Lock

**Likely affected areas:**

- worker
- context
- lib/models
- components/models
- components/workspace
- app/api/chat/anthropic
- app/[locale]/[workspaceid]
- components/sidebar/items/models
- lib/models/llm
- app/[locale]/[workspaceid]/chat

**Editable paths (agent MAY modify):**

- components/workspace/workspace-settings.tsx
- components/utility/profile-settings.tsx
- components/chat/quick-settings.tsx
- components/ui/chat-settings-form.tsx
- app/api/chat/anthropic/route.ts
- app/[locale]/[workspaceid]/layout.tsx
- context/context.tsx
- components/models/model-select.tsx

**Read-only context (inspect, do not modify):**

- context/context.tsx
- types/index.ts
- types/valid-keys.ts
- lib/envs.ts
- app/api/keys/route.ts
- package.json
- tsconfig.json
- README.md
- supabase/types.ts
- lib/supabase/browser-client.ts

## 4. Context Lock

**Files to inspect before starting:**

- components/workspace/workspace-settings.tsx
- lib/models/llm/anthropic-llm-list.ts
- db/models.ts
- db/workspaces.ts
- context/context.tsx
- lib/consume-stream.ts
- lib/models/fetch-models.ts
- public/worker-development.js
- components/ui/context-menu.tsx
- db/storage/workspace-images.ts
- components/chat/chat-settings.tsx
- components/chat/quick-settings.tsx

**Tests to inspect:**

- __tests__/lib/openapi-conversion.test.ts

**Architecture notes:**

- ChatbotUIContext (27-node community) holds shared model configs - verify Claude-specific overrides
- browser-client.ts handles API calls - likely contains provider-specific streaming logic
- use-chat-handler.tsx manages chat flow - may have early termination for Claude
- Streaming responses are rendered in message.tsx (37-node community) - verify no truncation in display layer

## 5. Success Lock

**Acceptance criteria:**

1. Claude 3 responses stream to full completion without truncation
2. GPT model streaming remains unaffected
3. No new console errors during Claude streaming
4. Response chunks are concatenated correctly in the chat handler
5. Stream termination only occurs on explicit [DONE] or error from Claude API

**Regressions to preserve:**

- GPT model streaming works as before
- Non-streaming models continue to work
- API key validation remains intact
- Error handling for failed requests is preserved

## 6. Proof Lock

**Validation commands:**

- `npm test -- __tests__/lib/openapi-conversion.test.ts`
- `npm run type-check`
- `npm run lint`
- `Test Claude 3 streaming in the app with a multi-sentence prompt`
- `npm run build`
- `npm run test`

**Tests to add or update:** _none identified_

**Manual checks:**

1. Verify Claude 3 responses complete fully in the UI
2. Compare streaming behavior between Claude and GPT models
3. Check browser console for streaming-related errors during Claude responses

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Affects core chat functionality for a specific provider (Claude)
- Involves streaming logic which is stateful and timing-sensitive
- Potential hidden coupling with ChatbotUIContext (27-node community)
- No existing tests to validate streaming behavior

**Stop conditions (agent must halt and ask human):**

- Claude API streaming logic cannot be isolated in browser-client.ts or use-chat-handler.tsx
- Changes required in forbidden areas (types.ts, utils.ts, UI primitives)
- Streaming truncation persists after fixing obvious issues in editable paths
- Claude-specific configuration is found in ChatbotUIContext that cannot be modified safely
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Changes touch ChatbotUIContext or other high-risk shared state
- Modifications to message rendering logic in message.tsx
- Any alterations to API key handling

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to browser-client.ts or use-chat-handler.tsx
- Possible addition of Claude-specific stream handling
- No changes to types or UI primitives
- No modifications to message rendering unless absolutely necessary

**Reporting format:** JSON with fields: root_cause, files_modified, changes_summary, validation_results (Claude streaming, GPT streaming, console errors), manual_test_passed (boolean)

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
