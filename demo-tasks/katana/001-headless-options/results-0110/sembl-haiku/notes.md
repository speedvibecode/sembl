# sembl-haiku — notes (katana/001, sembl 0.1.10 corrected WO)

- **THE FLAGSHIP RESULT. STOP → in-scope fix.** With the 0.1.8 WO this exact task
  was a zero-delivery STOP (sembl-gpt55-medium: the fix files weren't editable, no
  escape hatch). With the 0.1.10 WO — where editable_paths recall is 3/3 — **haiku, a
  weaker model than the one that stopped, delivered the complete fix.**
- Files changed: `pkg/engine/headless/browser/browser.go` (+17),
  `pkg/engine/headless/crawler/crawler.go` (+14/−6), `pkg/engine/headless/headless.go`
  (+1). EXACTLY the human reference fix file set (PR #1622), same wiring approach
  (UserArguments/ChromeCustomArguments threaded launcher → crawler → headless).
  More verbose than the reference's +8 lines but identical scope.
- **`sembl validate` → PASS**: 3 files changed, all in scope, 0 forbidden, 0
  out-of-scope. End-to-end loop (generate → execute → validate) confirmed working.
- Interpretation: this isolates the variable. Same task, same repo, same pinned base;
  the ONLY change was the Work Order's editable_paths (wrong → correct). Output went
  from nothing to a correct in-scope patch. This is the direct causal evidence that
  scope correctness — not model strength — was the bottleneck.
- Agent stats: 40 tool uses, ~370s, ~64k subagent tokens.
