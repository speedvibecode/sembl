# CLAUDE.md — sembl (the gate) session bootstrap

Cold-start contract for any agent working in this repo. Read fully before
non-trivial work. Also read `~/.claude/CLAUDE.md` (the owner's global
operating standard) — it applies here in full.

## What this is

**A deterministic accountability gate for AI coding agents** — a published
PyPI package (`pip install sembl`), GitHub Action (`action.yml`), and MCP
server. It checks an agent's *actual diff* against declared bounds (scope /
forbidden / fabrication / evidence / churn) and returns PASS / WARN / BLOCK.
It runs after the agent, before the human approves.

This is the heart of the sembl product family. `../sembl-stack` is the
factory built around this gate; its product contract is
`../sembl-stack/docs/PRODUCT-sembl-ide.md` and its ledger is
`../sembl-stack/docs/PROCESS-ACTION-PLAN.md` (O1–O15). Cross-repo decisions
live THERE, not here.

## Non-negotiable invariants (the product IS these properties)

- **Deterministic**: same inputs → same verdict, every time. No LLM, no
  network call, no wall-clock dependence anywhere in the judgment path. Any
  change that could make two runs disagree is a product-breaking bug.
- **Executor-neutral**: sembl never sees or assumes which agent made the
  diff. No executor-specific logic in the gate.
- **Fail loudly, never silently PASS**: an internal error (git failure,
  malformed config, unreadable diff) must surface as an error — a silent
  PASS on a broken check is the worst possible failure (see 6f45a29).
- **Verdicts bind to the diff SHA they judged.** BLOCK is never softened by
  a surface; overrides don't exist here.

## Public-package discipline (this repo is published — treat it that way)

- Semver per `VERSIONING.md`; releases via release-please + `release.yml` /
  `testpypi.yml`. **Never publish, tag, or push a release without the owner
  explicitly asking.** Local commits after verification are fine (global
  standard: verify → commit; never deploy/publish).
- CI runs the test matrix on push/PR (`tests.yml`) — a red matrix on a
  platform you didn't test locally is on you; tests must stay
  platform-neutral (see 2c5f45b: POSIX CI vs Windows paths).
- Public API changes (CLI flags, verdict schema, action inputs) are
  contracts: additive by default; breaking changes need a major bump and
  the owner's sign-off.

## How to run things

```bash
# tests, from the repo root
python -m pytest -q
# the gate itself against a repo
sembl verify --help
```

## Orientation

- Persistent memory (read first):
  `C:\Users\totla\.claude\projects\C--Users-totla-Desktop-projects-sembl\memory\MEMORY.md`
- `HANDOFF.md` is local-only pointer notes; re-verify all status lines
  against git log before trusting them.
- Docs for humans are in `README.md` / `docs/`; keep the README's claims
  exactly as strong as the code — never stronger.
