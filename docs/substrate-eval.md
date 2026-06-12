# Graph-Substrate Evaluation Log

Sembl treats repo-intelligence graphs as **swappable substrates** under an adapter
boundary — the Work Order is the product; the graph is a dependency we can change.
This log is the running, comparative record of every substrate we evaluate: what it
is, what it costs, what we can extract, how it fits Sembl, and what to watch for when
they ship updates. Goal: never be surprised by a tool update, and always know the
free/local fallback. Each entry is dated and versioned.

## Comparative snapshot

| Substrate | Cost | Locality | Semantic depth | Dynamic/incremental | Delivery | Sembl fit |
|-----------|------|----------|----------------|---------------------|----------|-----------|
| Graphify + code-review-graph | free | local | shallow (calls/imports) | static (rebuild) | files/CLI | current default |
| LatentGraph | paid + ~$0.58/update | backend (cloud) | high (implicit coupling) | yes (living graph) | MCP hook | premium optional only |
| Joern (CPG) | **free** | **local** | high (AST+CFG+**DDG**) | incremental-capable | CLI/query/export | **lead candidate** for free semantic substrate |

---

## LatentGraph — evaluated 2026-06-12 (CLI v1.0.36)

**What it is.** Hosted "living context graph." `npm i -g @latentforce/latentgraph`
→ `lgraph`. Pipeline: `start -k <key>` (daemon + WebSocket to backend) → `init`
(file index) → `update` (DRG + implicit deps + file-index + wiki). Exposes context to
agents **as an MCP server** via a PreToolUse hook (`lgraph add claude-code`).

**What it claims / delivers.** Semantic graph mapping architecture, intent, design
decisions, and **hidden runtime couplings** (Redis channels, shared DBs, event buses);
blast radius over explicit + implicit coupling; agents write edges back each session.

**Measured on httpie/cli (133 files, pinned cee82c82):**
- First full `update`: **129s wall, $0.5783 LLM cost** (server-side mining). Earlier
  `init`/pipeline phase ran 7+ min before DRG was queryable.
- `lgraph context <file>` (the "module role / reverse deps / implicit coupling / blast
  radius" command) returns **0 chars standalone** on every file tried (core.py,
  client.py, ssl_.py), exit 0. The value is only surfaced through the **MCP hook
  flow** the agent calls — not extractable as a plain CLI/library output.

**Strengths.** Real semantic + implicit-coupling modeling; genuinely dynamic; MCP
delivery is the right shape (agent calls it inside its tool-use loop).

**Disqualifiers as a default.** (1) **Cost**: ~$0.58 per update × frequent refreshes
the "living" model needs = recurring spend on top of subscription. (2) **Privacy**:
indexed code goes to their backend — fatal for a governance product / private repos.
(3) **Lock-in**: value is MCP-gated, not usable as a library.

**What we extract / learnings.**
- The **direction is validated**: semantic coupling + blast-radius + dynamic updates
  are worth having.
- The **delivery model is validated**: MCP server + PreToolUse hook >> CLI-emits-Markdown.
  This is direct evidence for building Sembl's own MCP/skills surface (answers the
  "UX friction" criticism).
- **Watch for updates**: if they add a local/offline mode or kill per-update cost, the
  privacy+cost calculus changes — re-evaluate. Track their `lgraph -v`.

**Status.** Keep as an optional premium adapter behind the substrate boundary. Never a
hard dependency. Reproduce its value for free (see Joern).

---

## Joern (Code Property Graph) — evaluated 2026-06-12 (v4.0.556)

**What it is.** Open-source code-analysis platform that builds **Code Property Graphs**
(AST + control-flow + **data-dependency** edges) in an in-memory graph DB, queried with
CPGQL. Multi-language: Python, JS/TS, **Kotlin**, Java, C/C++, binary. Free, fully local,
no account, no backend, no per-use cost.

**Install reality (Windows).** `joern-cli.zip` is **2.0 GB** (bundles all language
frontends + JVM deps). Download ~16 min here; extract 25s. Windows `.bat` launchers work
(`joern-parse.bat`, `joern.bat`, `joern-export.bat`, `joern-slice.bat`, …). Needs JDK 11+
(have Temurin 17). Heavy footprint → better suited to a CI/server indexing role or a
shared cache than a per-developer install.

**Measured on httpie/httpie (pinned cee82c82):**
- `joern-parse --language pythonsrc` → **7s**, cpg.bin **2.5 MB**. (vs LatentGraph 129s +
  $0.58 for the comparable index.)
- `blast.sc` query (reverse deps + dataflow surface for `ssl_.py`) → **10s**.
- **Result quality — it surfaced the right coupling.** The reverse-dependency query
  found `client.py:build_requests_session` calling into `ssl_.py`, and the SSL-context /
  `verify` data-flow surface resolved to exactly **`ssl_.py` + `client.py`**. That is the
  real semantic blast radius of the SSL bug — and in the 0.1.10 runs Opus and gpt-5.5
  fixed this very bug *in client.py*, the file Joern named as coupled. A static
  import/call graph would not have made that ssl_↔client coupling first-class.

**Weaknesses / watch-outs.**
- Python frontend is less mature than Java/C: queries return `<fakeNew>` metaclass
  constructor noise that must be filtered. Signal is present but needs cleanup.
- 2 GB footprint + JVM startup per query (~few s) — fine for batch/CI indexing, heavy for
  inline per-edit use. Mitigation: build the CPG once, keep `cpg.bin`, query incrementally;
  Joern supports content-hash incremental analysis.
- Go is NOT supported → keep code-review-graph for the Go target.
- Running `joern` from a directory creates a `workspace/` there — must gitignore / run
  out-of-tree.

**What we extract / learnings.**
- **This is the free win.** Joern reproduces the semantic-coupling / blast-radius value
  LatentGraph charges for, at $0 and locally, with sub-20s build+query on a medium repo.
- Integration path for Sembl: an adapter that builds a CPG per target (cached), runs a
  fixed reverse-deps + dataflow query for the task's seed files, and feeds the coupled
  file set into Work-Order scope (`editable_paths` + `read_only_context`). Filter the
  Python `<fakeNew>` noise in the adapter.
- Covers 3/4 hard-round stacks (Python, TS, Kotlin). Validate per-frontend quality next
  (TS and Kotlin frontends, on zod + thunderbird).

**Status.** **Lead candidate for the free semantic substrate.** Next: adapter spike +
per-language frontend validation; keep CRG for Go; keep static Graphify as the
zero-setup default.
