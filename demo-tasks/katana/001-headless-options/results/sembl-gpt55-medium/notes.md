# sembl-gpt-5.5-medium — notes (katana/001)

- **Outcome: ZERO delivery — agent stopped on scope conflict. The headline result of
  the cross-repo validation.**
- The agent correctly diagnosed the fix (option plumbing through
  `pkg/engine/headless/crawler/crawler.go` and `pkg/engine/headless/browser/browser.go`),
  checked the WO's MAY-edit list, found both files absent, and STOPPED with a clean
  blocker report and no textual changes (diff.patch is 0 bytes; the M statuses were
  CRLF-only noise from an aborted attempt, which it also explained).
- Contrast with the SAME model on the raw arm minutes earlier: exact reference fix,
  +8 lines, 3/3 files. The only difference between a perfect fix and no fix was the
  Work Order's wrong editable_paths.
- Spectrum of wrong-scope cost now fully mapped: weak models ignore the contract
  (haiku), strong models tunnel a worse fix through an allowed file when one exists
  (opus/gpt-5.5 on httpie, where client.py offered a workaround), and STOP entirely
  when no allowed file can host the fix (here — editable list had headless.go but the
  launcher/crawler plumbing was unreachable from it).
- Important nuance: the STOP behavior is itself correct and desirable — it is exactly
  the "permission to stop instead of helpfully expanding the work" that the r/cursor
  demand signal asks for, and far better than a silent out-of-scope patch. The defect
  is upstream: the scope data fed into the contract was wrong. Fix the ranking, keep
  the discipline.
- Harness: codex exec, gpt-5.5, reasoning medium, workspace-write (sandbox flake
  noted by agent on cleanup commands).
