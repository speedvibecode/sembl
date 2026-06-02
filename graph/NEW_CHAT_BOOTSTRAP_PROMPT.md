# New Chat Bootstrap Prompt

Use this prompt in a new chat to continue Sembl from the semantic graph state.

```text
You are continuing the Sembl V4.3 graph-first rebuild in:

C:\Users\totla\Desktop\projects\sembl

Do not rediscover the project from scratch. Treat the graph artifacts as the semantic state store.

Load these files first:
- graph/semantic_state_store.json
- graph/docs_manifest.json
- graph/normalized_graph.json
- graph/ui_graph.json
- graph/task_graph.json
- graph/agents/agent_roster.json
- graph/service_preflight.json
- graph/validation_report.json

Rules:
1. `sembl_docs/v_4.3.md` is the top methodology authority.
2. All other docs under `sembl_docs/**` are canonical peers; resolve by domain ownership, not by a fixed priority ladder.
3. Future implementation must start from `graph/task_graph.json` and scoped packets under `graph/task-packets/`.
4. Use named subagents from `graph/agents/agent_roster.json`; choose model/effort per task policy.
5. Workers must be stateless and receive only their task packet, direct dependencies, graph scope, required interfaces, and local invariants.
6. Do not mutate the graph directly. All changes go through docs/spec mutation or reconciliation.
7. Do not start Supabase-backed build tasks until `graph/service_preflight.json` records Supabase takeover reset as complete and verified.

Current state:
- Graph artifacts are validated.
- Task packets are generated.
- Tasks `task.00` through `task.05` are complete.
- GitHub remote is reachable.
- Vercel project `sembl` exists and is linked.
- Supabase is the blocker: the existing project `https://djquuvkwnjpweubzrsnn.supabase.co` must be destructively reset/taken over before persistence build work.

Immediate action:
1. Run `npm run graph:validate`.
2. Inspect `graph/service_preflight.json`.
3. If the user explicitly approves the destructive Supabase takeover reset, inventory the existing Supabase project, clear old Sembl app-owned state, verify the reset, update `graph/service_preflight.json`, rerun validation, then deploy named subagents from `task.07` onward according to `graph/task_graph.json`.
4. If destructive Supabase reset is not approved, stop before persistence build tasks and report the blocker.
```
