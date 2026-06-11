# sembl-opus — notes (katana/001, sembl 0.1.10 corrected WO)

- **Opus confirms the flagship at the top tier.** Same task that was a zero-delivery
  STOP under the 0.1.8 WO; opus on the 0.1.10 WO delivered the exact reference fix file
  set: `browser.go` (+20), `crawler.go` (+5), `headless.go` (+1). +26 lines, in scope.
- **`sembl validate` → PASS**: 3 files, all in scope, 0 forbidden, 0 out-of-scope.
- Deepest diagnosis of the three tiers: opus located the OLD hybrid engine
  (`pkg/engine/hybrid/hybrid.go:259-261`) still applying `-ho` flags and used it as the
  ground-truth mechanism to mirror, confirming the v1.4.0 rewrite dropped the wiring.
- Three tiers (haiku, sonnet, opus) now all deliver the exact reference fix in scope on
  the task that previously produced a STOP. The localization fix is robust across the
  full executor strength range.
- Agent stats: 20 tool uses, ~236s, ~62k subagent tokens.
