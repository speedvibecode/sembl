# sembl-sonnet — notes (katana/001, sembl 0.1.10 corrected WO)

- **Confirms the flagship result at the next executor tier.** Same task that was a
  zero-delivery STOP under the 0.1.8 WO; sonnet on the 0.1.10 WO delivered the exact
  reference fix file set: `pkg/engine/headless/browser/browser.go` (+14),
  `pkg/engine/headless/crawler/crawler.go`, `pkg/engine/headless/headless.go`.
- **`sembl validate` → PASS**: 3 files, all in scope, 0 forbidden, 0 out-of-scope.
- Traced the full data-flow (CLI parse → crawler.Options → LauncherOptions → Chrome
  launch) and matched the reference's threading precisely, including the `--` prefix
  handling the existing headlessFlags loop uses. Cleanest analysis of the retest set.
- haiku + sonnet now both deliver in-scope fixes where the 0.1.8 WO produced a STOP —
  the localization fix holds across two executor tiers. Opus tier is the owner's gate.
- Agent stats: 17 tool uses, ~379s, ~57k subagent tokens.
