# chatbot-ui / 001 — claude 3 responses cut off after a few words

## Provenance

- Target repo: https://github.com/mckaywrigley/chatbot-ui (~33k stars, TS/Next.js)
- Source issue: https://github.com/mckaywrigley/chatbot-ui/issues/1543
  "Bug ? claude3 responses seems to be cut after a few words/tokens."
- Human reference fix: https://github.com/mckaywrigley/chatbot-ui/pull/1571
  (merge commit `ff4b643f42b4caf837d1f227793157babbcbde62`)
- Pinned base SHA (parent of the fix — bug live here):
  `b0768c0b6fcbb475378e0a14204789dc49b7fd25`

## The bug

Claude 3 responses truncate mid-sentence after a few words regardless of settings.
Reference fix: `app/api/chat/anthropic/route.ts` (streaming/parsing + error handling,
run on edge runtime) plus bumping `@anthropic-ai/sdk` in package.json/lock.

## Method notes

- WO generated from the short task text "claude 3 responses get cut off after a few
  words" (a longer task text hit a generation error on the first attempt; the short
  variant is what both arms received, keeping the A/B fair).
- Executor: claude haiku via Claude Code Agent tool (codex limits exhausted by this
  point — owner call). No toolchain validation (Next.js build too heavy); scope
  metrics primary.

## Localization result (sembl 0.1.8, full graph: graphify + CRG 1,091 nodes)

editable_paths recall vs reference: **0/1** — `app/api/chat/anthropic/route.ts`
absent from editable_paths AND files_to_inspect; the only API route included is the
unrelated `app/api/keys/route.ts`. Contradictions (worst of the 4 repos): four paths
(`context/context.tsx`, `supabase/types.ts`, `lib/envs.ts`,
`lib/server/server-utils.ts`) in BOTH editable and forbidden; `components/` forbidden
while `components/ui/input.tsx` and `components/ui/button.tsx` are editable.
