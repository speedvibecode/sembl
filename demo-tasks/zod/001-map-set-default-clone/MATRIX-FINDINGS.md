# zod-001 — executor-axis matrix (2026-06-12)

Fixed Work Order (nvidia-generated, 0.1.11, WO id 1781266035: 9 validation commands,
no locale noise, recall HIT, but v3/* files still in editable_paths). Every executor
run from a clean pinned-base worktree; auto-scored by `harness/score_run.py`. Raw arm =
bug description only; sembl arm = the WO executor prompt. No toolchain (scope metrics).

## Results (12 cells, recall 1/1 everywhere)

| executor | raw over_scope | WO over_scope | WO effect on scope |
|----------|----------------|---------------|--------------------|
| codex gpt-5.4 med   | 2 (fixes v3 too) | 0 | **tightened** |
| codex gpt-5.5 xhigh | 0 | 0 | neutral (already disciplined) |
| gemini-3-pro        | 0 (1 file only) | 1 (v3) | **loosened** |
| gemini-3-flash      | 0 | 1 (v3) | **loosened** |
| sonnet              | 1 (v3) | 1 (v3) | neutral |
| haiku               | 1 (stray play.ts) | 1 (v3) | neutral |

Wall-time spread: gemini-3-flash raw ~instant → gemini-3-pro raw 1537s. gpt-5.5-xhigh
and gemini-3-pro are the slowest.

## Findings

1. **The Work Order's effect on scope is bidirectional and model-dependent.** The same
   (slightly noisy) WO TIGHTENED an over-eager model (codex-5.4: 2→0) and LOOSENED
   disciplined ones (both gemini models: 0→1, taking the v3 permission). Net effect
   depends on the model's own scoping instinct.
2. **Scope precision is the lever — confirmed across 6 models.** On an easy-to-localize
   task where everyone already gets recall 1/1, residual `editable_paths` noise (v3) is
   a net wash-to-negative: it can only hurt the models that would otherwise be tight.
   This is the cross-model evidence (not one task) that justifies a **relevance-gap
   cutoff** to drop the weak long-tail from editable_paths.
3. **`sembl validate` is blind to WO-permitted over-scope** (every over_scope=1 cell
   still validated PASS, because v3 IS in editable_paths). Reinforces: fix scope
   upstream; don't rely on validate to catch noise the WO itself sanctioned.
4. **Newer/stronger ≠ more over-scoping.** Raw discipline: gemini-3-pro (1 file) >
   gpt-5.5-xhigh = gemini-3-flash (2) > sonnet = haiku (1 extra) > codex-5.4 (2 extra).
   codex-5.4 was the most over-eager on raw; the WO is what reined it in.

## Method notes / harness

- `harness/run_cell.ps1` runs one CLI-executor cell (gemini/codex) in an isolated git
  worktree and self-scores. Claude cells run via the Agent tool in IN-ROOT worktrees
  (`sembl/.matrix-wt/*`) because background subagents are denied file tools outside the
  project root; scored manually post-run.
- PowerShell `>`/`Out-File` write UTF-16/BOM (corrupts patches + JSON) — scorer reads
  utf-8-sig; capture diffs as raw git bytes.
- Pending: MiniMax-M3 (tokenrouter) once the correct API base URL is confirmed.
