# Tooling integration & update strategy

Sembl depends on external repo-intelligence tools (Graphify, code-review-graph today;
others later). The product rule is **the Work Order is stable; tools are swappable**.
This is how we stay reproducible and capture useful tool updates without churn or
silent breakage.

## The five pillars

**1. Adapter boundary.** All knowledge of a tool's CLI and output format lives in ONE
place (`repo_probe._probe_graphify` / `_probe_crg`, and `graph_diagnostics`). A tool
change → fix one adapter. A new tool (GitNexus, Understand, ...) → a new adapter that
fills the same internal "graph context", and the Work Order schema never changes.

**2. Version provenance, not blind hard-pins.** Graphify and code-review-graph are our
OWN, fast-moving tools — hard-pinning sembl's `pyproject` would force a sembl release
every time we want the latest, which fights development. Instead:
  - `graph_diagnostics.detect_tool_versions()` is the single source of tool versions.
  - `sembl doctor --json` surfaces `graphify_version` / `crg_version`.
  - The benchmark records them per run (provenance), so every result is traceable to an
    exact tool stack.
  - For THIRD-PARTY tools we don't control, DO pin a known-good range in `pyproject`.

**3. Snapshot for canonical benchmarks.** A benchmark number is only meaningful against
a known tool stack. When publishing a canonical result, record (and, if needed, pin)
the graphify/crg versions used. Day-to-day dev stays on latest; canonical runs are
snapshotted.

**4. Benchmark-gated adoption — the decision function.** When a tool ships something
major, do NOT "upgrade and hope." Wire it behind a flag, add a tool-version axis to the
benchmark matrix (sembl-bench `run_matrix.py`), run it on Loc-Bench, and read the
recall@k delta. Adopt only if it measurably helps. A tool update is a hypothesis tested
on the bench.

**5. The intake loop.** watch (their releases/changelog) → triage (breaking /
new-capability / noise) → evaluate the major ones via the matrix → pin-the-win (or stay
put). Early: a manual changelog skim. Later: a scheduled check. Eventually: part of the
self-improving factory (Sembl reading a tool's changelog and proposing the adapter
update).

## When a tool update lands — checklist

1. Does `sembl doctor` still pass and does generation still work? (adapter intact)
2. Read the changelog: breaking, new-capability, or noise?
3. Breaking → fix the adapter; add a regression note.
4. New-capability → wire behind a flag, matrix-eval on Loc-Bench, adopt iff recall@k
   improves; bump the pinned/snapshotted version and note it.
5. Always: the recorded tool versions in run provenance make "did the tool change the
   result, or did Sembl?" answerable.

## Adding a brand-new tool

Implement a new adapter (probe + version detect + output→context mapping) behind the
same internal interface. Do not change the Work Order schema. Add it to
`detect_tool_versions()` and to the matrix as a selectable backend. Swappable by design.
