# Work Order - wo-chatbotui-1781196195-claude-3-responses-in-the-app-get-cut-of

**Repo:** `chatbot-ui` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T16:43:15.249895+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> claude 3 responses in the app get cut off after a few words or tokens - i added anthropic credits, pasted a fresh api key, default settings, and the very first answer stops mid-sentence every time. increasing context length in settings did nothing. gpt models work fine, it's only the claude models. please fix so claude responses stream to completion.

**Clarified goal:** Fix streaming truncation for Claude 3 models by correcting the API client or chat handler logic that prematurely terminates the response stream

**User-visible outcome:** Claude 3 model responses stream to completion without mid-sentence truncation, matching the behavior of GPT models

## 2. Boundary Lock

**Non-goals:**

- Modify non-Claude model streaming behavior
- Change UI rendering logic unless directly causing truncation
- Alter API key handling or authentication flows
- Update dependencies or package.json
- Modify Supabase types or database schemas

**Must not change:**

- GPT model streaming behavior
- Existing API key validation logic
- ChatbotUIContext state structure for non-streaming fields
- Message rendering for non-Claude responses

**Forbidden areas (agent must not touch):**

- package.json
- .eslintrc.json
- types/
- supabase/types.ts
- db/
- worker/

## 3. Scope Lock

**Likely affected areas:**

- worker
- context
- lib/models
- components/models
- context/context.tsx
- components/workspace
- app/api/chat/anthropic
- app/[locale]/[workspaceid]
- components/sidebar/items/models
- lib/models/llm

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
- types/key-type.ts
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

- ChatbotUIContext manages model settings and may influence streaming behavior
- Claude API integration is likely isolated in browser-client.ts or use-chat-handler.tsx
- Streaming UI is handled in chat-ui.tsx, but truncation is likely upstream in the API client
- Message rendering in message.tsx could mask truncation but is unlikely to be the root cause

## 5. Success Lock

**Acceptance criteria:**

1. Claude 3 responses stream to full completion without premature truncation
2. GPT model streaming remains unaffected
3. No new errors in browser console during Claude 3 streaming
4. Streaming behavior matches the expected token-by-token delivery

**Regressions to preserve:**

- GPT model streaming must continue to work as before
- API key validation must remain intact
- Chat history and context must persist correctly
- UI must not break for non-streaming responses

## 6. Proof Lock

**Validation commands:**

- `npm test -- __tests__/lib/openapi-conversion.test.ts`
- `npm run lint`
- `npm run type-check`
- `npm run build`
- `npm run test`

**Tests to add or update:** _none identified_

**Manual checks:**

1. Test Claude 3 streaming with a long response (>100 tokens) to verify no truncation
2. Compare streaming behavior side-by-side with a GPT model
3. Check browser DevTools Network tab for premature stream closure (HTTP 200 vs. abort)
4. Verify no console errors during Claude 3 streaming

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Streaming logic is core to the app's functionality
- Shared context (ChatbotUIContext) could have hidden coupling
- Claude-specific changes might affect other Anthropic models
- Streaming fixes can introduce race conditions or memory leaks

**Stop conditions (agent must halt and ask human):**

- If changes to ChatbotUIContext are required (high risk of breaking other features)
- If the root cause is identified as a third-party library bug (e.g., Anthropic SDK)
- If the fix requires modifying Supabase client initialization
- If truncation persists after exhausting likely_affected_areas
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Any changes to context/context.tsx
- Modifications to shared state management affecting multiple models
- If the fix involves altering HTTP client timeouts or retry logic

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Fix in use-chat-handler.tsx: Correct stream handling for Claude models (e.g., remove premature stream closure, fix chunk aggregation)
- Fix in browser-client.ts: Adjust Claude API client to properly handle streaming responses (e.g., timeout settings, response parsing)
- No changes to message.tsx or chat-ui.tsx unless rendering is proven to cause truncation
- No modifications to context/context.tsx without approval

**Reporting format:** Provide: (1) Root cause (file:line), (2) Fix applied, (3) Validation results (Claude 3 streaming test, GPT parity check, console errors), (4) Any manual checks performed.

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
