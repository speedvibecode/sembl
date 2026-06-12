# Matrix harness

score_run.py: deterministic per-cell scorer. Reads a target repo's working tree (any executor - Claude agent, codex, gemini, ollama), scores recall vs expected-scope, out-of-scope edits, sembl validate verdict, diff size, and cost; appends a JSONL row. See the module docstring for usage. results/ holds matrix.jsonl (gitignored).
