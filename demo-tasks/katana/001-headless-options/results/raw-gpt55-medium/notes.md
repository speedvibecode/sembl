# raw-gpt-5.5-medium — notes (katana/001)

- **Outcome: exact reference match.** 3 files — browser.go (+5), crawler.go (+2),
  headless.go (+1) — identical file set and wiring strategy to human PR #1622
  (UserArguments on the launcher, ParseHeadlessOptionalArguments() threaded through).
  +8 insertions total, same as reference.
- Zero out-of-scope files. Honest blocker note: no Go toolchain, verified by reading
  and git diff only.
- Confirms the httpie pattern on Go: a strong executor with a RAW prompt localizes
  this task perfectly unaided. The WO can only add value here via constraints/proof,
  not localization — and its wrong editable_paths can only subtract.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write.
