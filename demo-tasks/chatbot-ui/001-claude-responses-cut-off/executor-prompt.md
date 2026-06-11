# Executor Prompt - wo-chatbotui-1781182543-claude-3-responses-get-cut-off-after-a-f

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix the truncation of Claude 3 responses in the OpenAI assistants API route by ensuring full response streaming or buffering. Original request: claude 3 responses get cut off after a few words. User-visible outcome: Claude 3 responses are no longer cut off and display in full to the user. Non-goals: Modify any non-Claude 3 model handling; Change the API endpoint structure or URL; Adjust authentication or rate-limiting logic; Update frontend UI components for response rendering. You MAY only edit these paths: lib/envs.ts; lib/utils.ts; supabase/types.ts; context/context.tsx; app/api/keys/route.ts; components/ui/input.tsx; components/ui/button.tsx; lib/server/server-utils.ts. You must NOT touch: context/context.tsx; supabase/types.ts; lib/envs.ts; lib/server/server-utils.ts; types/valid-keys.ts; components/; db/; worker/. Inspect these files before changing code: lib/envs.ts; lib/utils.ts; db/messages.ts; jest.config.ts; supabase/types.ts; context/context.tsx; app/api/keys/route.ts; components/ui/input.tsx; components/ui/button.tsx; lib/chat-setting-limits.ts; lib/server/server-utils.ts; components/chat/chat-ui.tsx. Acceptance criteria: Claude 3 responses are delivered in full without truncation; No regression in response latency for Claude 3 or other models; Existing unit/integration tests (if any) continue to pass; Response headers (e.g., Content-Type) remain consistent with existing behavior. Stop and ask the human if: If the fix requires changes to shared utilities (e.g., lib/utils.ts) not in editable_paths; If the root cause is in a dependency (e.g., OpenAI SDK) requiring version updates; If the issue stems from upstream API limitations (e.g., Claude 3 provider truncation); If changes to package.json or other forbidden_areas are needed; No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.. Patch expectations: Minimal changes to app/api/assistants/openai/route.ts (e.g., streaming buffer size, chunk handling, or response concatenation logic); No changes to imports/dependencies unless absolutely necessary; Preservation of all existing response headers and metadata. Validate with: curl -X GET http://localhost:3000/api/assistants/openai?model=claude-3-sonnet -H 'Authorization: Bearer TEST_KEY' -v | grep -i 'truncat'; npm run lint; npm run type-check; npm run test; npm run build. Report your work using this format: {'summary': 'Brief description of the root cause and fix', 'changes': 'List of modified lines/files with before/after', 'validation': 'Results of validation_commands and manual checks', 'risks': 'Any potential regressions or edge cases not covered', 'tests': 'New/updated test cases and their coverage'}

---

## Scope enforcement

**You MAY only edit these paths:**
- `lib/envs.ts`
- `lib/utils.ts`
- `supabase/types.ts`
- `context/context.tsx`
- `app/api/keys/route.ts`
- `components/ui/input.tsx`
- `components/ui/button.tsx`
- `lib/server/server-utils.ts`

**You must NOT touch:**
- `context/context.tsx`
- `supabase/types.ts`
- `lib/envs.ts`
- `lib/server/server-utils.ts`
- `types/valid-keys.ts`
- `components/`
- `db/`
- `worker/`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- If the fix requires changes to shared utilities (e.g., lib/utils.ts) not in editable_paths
- If the root cause is in a dependency (e.g., OpenAI SDK) requiring version updates
- If the issue stems from upstream API limitations (e.g., Claude 3 provider truncation)
- If changes to package.json or other forbidden_areas are needed
- No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.

## Patch expectations

- Minimal changes to app/api/assistants/openai/route.ts (e.g., streaming buffer size, chunk handling, or response concatenation logic)
- No changes to imports/dependencies unless absolutely necessary
- Preservation of all existing response headers and metadata