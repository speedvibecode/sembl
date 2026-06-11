# sembl-haiku — notes (chatbot-ui/001)

- **Outcome: ZERO delivery — stopped on scope conflict (diff.patch 0 bytes). Even
  haiku, which silently ignored the wrong contract on httpie, stopped here.**
- Why this one stopped where httpie-haiku didn't: the chatbot-ui WO's defects are
  flagrant — the clarified goal names the WRONG route ("OpenAI assistants"), the
  patch expectations name a file (`app/api/assistants/openai/route.ts`) that is in
  neither the MAY-edit nor forbidden list, four paths sit in BOTH lists, and the
  stop conditions trigger on the reference fix itself (SDK version bump). The
  contract was not just wrong but visibly incoherent, and the model noticed.
- Quality of the stop: high. The agent independently diagnosed that Claude models are
  served by `app/api/chat/anthropic/route.ts` (the TRUE fix file), enumerated the
  contract contradictions precisely, and asked exactly the right clarification
  questions. With sembl edit / human-in-the-loop (priority list item B), this stop
  report is a one-edit recovery: fix editable_paths, re-dispatch.
- Pairing with raw-haiku (same model, same task): raw delivered the (memorized,
  contaminated) fix; sembl delivered nothing but a correct diagnosis + questions.
- Agent stats: 39 tool uses, ~244s, ~58k subagent tokens.
