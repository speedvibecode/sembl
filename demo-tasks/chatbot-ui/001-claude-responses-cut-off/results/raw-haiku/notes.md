# raw-haiku — notes (chatbot-ui/001)

- **Outcome: reference file set hit (app/api/chat/anthropic/route.ts + package.json),
  +51/−42 — BUT the result is CONTAMINATED.**
- The agent explicitly said it was "applying a known fix from PR #1571" and "matches
  the exact fix that was applied upstream to resolve issue #1543" — it recalled the
  upstream fix from training data rather than deriving it. chatbot-ui is a famous
  repo; this task's fix is memorized.
- Consequences: (a) file-localization metrics on this task measure memory, not
  reasoning — do not use chatbot-ui/001 for raw-vs-WO localization claims;
  (b) the diff is larger than the reference's route.ts changes (+51/−42 vs the
  upstream's narrower edit) because it reconstructed the remembered fix imperfectly.
- Methodology lesson (add to demo protocol): tasks from famous repos with merged
  fixes are contamination-prone; prefer post-cutoff issues or verify the agent does
  not name the upstream PR. Same discipline sembl-bench applies (SWE-rebench) now
  demonstrated necessary for demo tasks.
- Agent stats: 22 tool uses, ~186s, ~42k subagent tokens.
