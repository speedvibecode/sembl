# Work Order - wo-chatbotui-1781182543-claude-3-responses-get-cut-off-after-a-f

**Repo:** `chatbot-ui` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T12:55:43.793816+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> claude 3 responses get cut off after a few words

**Clarified goal:** Fix the truncation of Claude 3 responses in the OpenAI assistants API route by ensuring full response streaming or buffering

**User-visible outcome:** Claude 3 responses are no longer cut off and display in full to the user

## 2. Boundary Lock

**Non-goals:**

- Modify any non-Claude 3 model handling
- Change the API endpoint structure or URL
- Adjust authentication or rate-limiting logic
- Update frontend UI components for response rendering

**Must not change:**

- Response format for other models (e.g., GPT-4, Llama)
- Error handling behavior for non-200 responses
- API contract (request/response shape) for existing clients
- Logging or monitoring hooks

**Forbidden areas (agent must not touch):**

- context/context.tsx
- supabase/types.ts
- lib/envs.ts
- lib/server/server-utils.ts
- types/valid-keys.ts
- components/
- db/
- worker/

## 3. Scope Lock

**Likely affected areas:**

- db
- lib
- types
- context
- supabase
- lib/server
- app/api/keys
- lib/supabase
- components/ui
- lib/models/llm

**Editable paths (agent MAY modify):**

- lib/envs.ts
- lib/utils.ts
- supabase/types.ts
- context/context.tsx
- app/api/keys/route.ts
- components/ui/input.tsx
- components/ui/button.tsx
- lib/server/server-utils.ts

**Read-only context (inspect, do not modify):**

- package.json
- types/key-type.ts
- lib/utils.ts
- tsconfig.json
- README.md
- supabase/types.ts
- lib/supabase/browser-client.ts
- types/index.ts
- types/valid-keys.ts
- types/llms.ts

## 4. Context Lock

**Files to inspect before starting:**

- lib/envs.ts
- lib/utils.ts
- db/messages.ts
- jest.config.ts
- supabase/types.ts
- context/context.tsx
- app/api/keys/route.ts
- components/ui/input.tsx
- components/ui/button.tsx
- lib/chat-setting-limits.ts
- lib/server/server-utils.ts
- components/chat/chat-ui.tsx

**Tests to inspect:** _none identified_

**Architecture notes:**

- Route follows Next.js API route conventions (GET/POST handlers)
- Response streaming is likely handled via Next.js Response or custom streaming logic
- Claude 3 responses may require special handling for partial/streamed chunks

## 5. Success Lock

**Acceptance criteria:**

1. Claude 3 responses are delivered in full without truncation
2. No regression in response latency for Claude 3 or other models
3. Existing unit/integration tests (if any) continue to pass
4. Response headers (e.g., Content-Type) remain consistent with existing behavior

**Regressions to preserve:**

- Non-Claude 3 model responses must continue to work as before
- Error cases (e.g., API key failures, timeouts) must retain existing behavior
- Response metadata (e.g., model name, usage stats) must remain intact

## 6. Proof Lock

**Validation commands:**

- `curl -X GET http://localhost:3000/api/assistants/openai?model=claude-3-sonnet -H 'Authorization: Bearer TEST_KEY' -v | grep -i 'truncat'`
- `npm run lint`
- `npm run type-check`
- `npm run test`
- `npm run build`

**Tests to add or update:**

- app/api/assistants/openai/route.test.ts

**Manual checks:**

1. Verify Claude 3 responses >1000 tokens render fully in the UI
2. Test edge cases: empty responses, partial failures, timeouts

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- API route is user-facing and critical for core functionality
- Potential for cross-model regression if streaming logic is shared
- No existing test coverage detected for this route

**Stop conditions (agent must halt and ask human):**

- If the fix requires changes to shared utilities (e.g., lib/utils.ts) not in editable_paths
- If the root cause is in a dependency (e.g., OpenAI SDK) requiring version updates
- If the issue stems from upstream API limitations (e.g., Claude 3 provider truncation)
- If changes to package.json or other forbidden_areas are needed
- No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.

**Approval triggers (blocks merge):**

- Any modification to response streaming logic that could affect other models
- Changes to error handling that might mask failures

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to app/api/assistants/openai/route.ts (e.g., streaming buffer size, chunk handling, or response concatenation logic)
- No changes to imports/dependencies unless absolutely necessary
- Preservation of all existing response headers and metadata

**Reporting format:** {'summary': 'Brief description of the root cause and fix', 'changes': 'List of modified lines/files with before/after', 'validation': 'Results of validation_commands and manual checks', 'risks': 'Any potential regressions or edge cases not covered', 'tests': 'New/updated test cases and their coverage'}

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**
