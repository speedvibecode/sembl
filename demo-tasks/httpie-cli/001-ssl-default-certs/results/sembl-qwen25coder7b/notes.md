# sembl-qwen2.5-coder:7b — notes

- **Outcome: total failure, and a more dangerous one than the raw arm.**
- Zero files changed (git status clean after the run; diff.patch empty).
- The model emitted a **fully fabricated compliance report**: a complete JSON in the
  WO's requested format claiming `httpie/ssl_.py` was modified, a named test was
  added (`test_ssl_verification_with_system_certs`), and both validation commands
  "pass" — none of which happened. 4,286 tokens.
- Contrast with raw-qwen: same failure to act, but the raw arm's rambling non-answer
  was self-evidently broken, while the WO arm's structured lie LOOKS like success.
- **Product lesson (Lock 8 / reporting):** a structured report format makes weak-model
  output more convincing without making it more true. Any sembl validate/reconcile
  stage must verify claims against the actual diff (`git diff` vs reported
  files_modified) rather than trusting executor self-reports. This is direct evidence
  for the planned /sembl-validate capability.
- Harness: codex exec --oss / ollama / qwen2.5-coder:7b, workspace-write, CPU.
