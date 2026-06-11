# raw-qwen2.5-coder:7b — notes

- **Outcome: total failure — no edits, no fix, no real tool use.**
- Harness: codex exec 0.135.0, --oss / ollama, sandbox workspace-write, CPU.
- The model emitted a hallucinated tool call (`mcp__node_repl`, which does not exist)
  containing pseudo-Python, then "reported" hypothetical validation results it never
  ran ("should complete successfully", "should fail"), and exited. 4,360 tokens total.
- Zero files changed; diff.patch is empty.
- Matches the strategy doc's standing caveat (§5: qwen2.5-coder:7b is for plumbing
  A/Bs, not absolute results) — now demonstrated on the execution side, not just
  localization: a 7B local model cannot drive an agentic editing loop in codex.
- Implication for the demo matrix: local-model rows are a floor/baseline showing the
  matrix runs anywhere, not a meaningful raw-vs-WO comparison; don't read scope
  metrics into them.
