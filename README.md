# Sembl

[![PyPI](https://img.shields.io/pypi/v/sembl.svg)](https://pypi.org/project/sembl/)
[![Python](https://img.shields.io/pypi/pyversions/sembl.svg)](https://pypi.org/project/sembl/)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

**A deterministic accountability gate for AI coding agents.**

Sembl checks what an AI coding agent *actually changed* against the bounds the
change was supposed to stay in — which files it may touch, which it must not,
how big the diff may get — and whether it lied about what it touched or what it
tested. It runs **after** the agent and **before** a human approves, and returns
a single verdict: **PASS / WARN / BLOCK**.

```text
declared bounds  +  the agent's real diff  ->  sembl verify  ->  PASS / WARN / BLOCK
```

The check is **deterministic** (no LLM in the loop), **executor-neutral** (Cursor,
Claude Code, Codex, Aider, OpenCode — Sembl never sees the agent), and **free to
run in CI**. Same inputs, same verdict, every time.

[Website](https://sembl.vercel.app) | [PyPI](https://pypi.org/project/sembl/) | [Issues](https://github.com/speedvibecode/sembl/issues)

## Why

AI agents are strong executors. The gap is no longer writing the code — it is
**trusting what the agent did without reading every line.** As agents get more
autonomous and humans review less, you need a repeatable, mechanical check that
the change stayed inside its declared bounds and didn't fabricate its results.

What Sembl **does**: deterministically catch objective, checkable problems in a
diff — out-of-scope edits, edits in forbidden areas, files the agent *claimed* to
change but didn't, and "tests passed" claims with no evidence.

What Sembl **does not** do: it does not make the agent smarter, and it does not
judge code quality or maintainability. That's a reviewer's job, and an LLM
reviewer does it about as well — so it isn't Sembl's claim. Sembl's edge is
narrow and honest: **determinism, zero cost, and auditability** — a gate you can
put in CI that gives the same answer every time and that nobody can argue with.

## How it works

1. **Declare the bounds** of the change — the files it may edit, areas it must
   not touch, and (optionally) a size budget. Produce this with whatever you
   already use (see [Declaring bounds](#declaring-bounds-bring-your-own)).
2. **Your agent does the work.**
3. **`sembl verify`** compares the real git diff against the bounds and returns
   PASS / WARN / BLOCK. With `--report`, it also cross-checks the agent's own
   success report and flags fabricated file claims and unevidenced test passes.

```powershell
pip install sembl

# after your agent has edited the repo:
sembl verify --wo-file bounds.json --report agent-report.json
```

```text
sembl verify — BLOCK
  Files changed         7
  Scope (out of scope)  infra/deploy.yaml
  Forbidden hits        none
  Fabricated claims     src/payments/refund.ts
  Validation evidenced  missing: pytest
  Churn vs budget       7 files > 6
  Reasons               • fabricated claims (reported but unchanged): src/payments/refund.ts
                        • out-of-scope edits: infra/deploy.yaml
```

Exit codes: `PASS=0`, `WARN=0` (or `1` with `--strict`), `BLOCK=1`. Add `--json`
for machine-readable output in CI.

## Declaring bounds (bring your own)

`verify` reads a small, portable contract. **Only four fields matter** — anything
that can emit them can drive the gate:

```json
{
  "editable_paths": ["src/auth/"],
  "forbidden_areas": ["migrations/", "infra/"],
  "churn_budget": { "max_files": 6, "max_lines": 200 }
}
```

Produce it however you like:

- **From a planning tool (recommended).** `sembl bounds` turns what an upstream
  tool already wrote into a bounds file:
  ```bash
  sembl bounds --spec-kit specs/001-feature --out bounds.json   # GitHub Spec Kit
  sembl bounds --from kiro|tessl|agents-md|cursor-rules          # other presets
  sembl bounds --config adapter.json                            # custom (declarative)
  ```
  Spec Kit's `tasks.md` (and the other tools' artifacts) already name the **exact
  file paths** for each task — those map straight onto `editable_paths`. Use the
  planner to decide *what* to build; use Sembl to verify the agent *stayed in
  those lines*. Adding a new tool is a config entry, not code — see
  [`docs/integrations.md`](docs/integrations.md).
- **By hand.** Write the four fields yourself. It's a normal JSON file.
- **`sembl generate` (beta, optional).** Sembl can also produce a fuller Work
  Order JSON that `verify` reads directly — see
  [Beta: Work Order generation](#beta-work-order-generation). This is optional and
  interchangeable with the tools above.

## What `verify` checks (all deterministic)

| Check | Signal | Verdict |
|-------|--------|---------|
| **Scope** | a changed file is outside `editable_paths` | out-of-scope (BLOCK in strict, else WARN) |
| **Forbidden** | a changed file is inside `forbidden_areas` | **BLOCK** |
| **Fabrication** | the report claims a file changed, but the diff doesn't show it | **BLOCK** |
| **Validation evidence** | the report says a test/check passed, with no exit code or output to back it | WARN |
| **Churn** | the diff exceeds `max_files` / `max_lines` | WARN |

Tests are always allowed alongside in-scope edits. The verdict rolls up to BLOCK
(hard contract breach), WARN (soft signal), or PASS (clean). `--strict` makes
WARN a failing exit code for CI gating.

The executor report (the `--report` file) is JSON the agent or your harness
emits; Sembl never trusts it — it only uses it to catch *contradictions* with the
real diff. Common shapes are recognized (`files_modified`, `changes[]`,
`tests_passed`, a `checks[]` list, …).

## Gate it in CI

`verify` can score a PR's diff directly — no working-tree checkout needed — so it
drops into CI as a hard gate. Feed it a patch with `--diff` (or `--diff -` for
stdin):

```bash
git diff origin/main...HEAD | sembl verify --wo-file bounds.json --diff - --strict
```

Or use the GitHub Action on every pull request (see
[`examples/github-workflow.yml`](examples/github-workflow.yml)):

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: speedvibecode/sembl@v0.1.21
  with:
    bounds: bounds.json
    strict: "false"   # advisory by default; true for a hard scope gate
```

## Integrations

`verify` auto-discovers a `bounds.json` (then `.sembl/bounds.json`) at the repo
root, so most integrations run zero-arg. Every one is just a trigger for the same
command. Full recipes: [`docs/integrations.md`](docs/integrations.md).

- **GitHub Action** — gate every PR (above).
- **pre-commit** — gate local commits:
  ```yaml
  - repo: https://github.com/speedvibecode/sembl
    rev: v0.1.21
    hooks: [{ id: sembl-verify }]
  ```
- **Agent harnesses** — run verify the moment the agent stops editing. Claude Code
  (`Stop` hook), Aider (`--test-cmd`), OpenCode (post-edit hook), or any harness
  that can run a shell command. See [`examples/`](examples/).
- **MCP** — let an agent (or an orchestrator supervising a sub-agent) call the gate
  with no shell: it hands over a diff + what it declared, and gets back the
  PASS/WARN/BLOCK verdict. The general case for *main-agent-verifies-sub-agent*.
  Zero-install — paste into your MCP client (`.mcp.json`, Cursor, Windsurf, …):
  ```json
  {
    "mcpServers": {
      "sembl": { "command": "uvx", "args": ["--from", "sembl[mcp]", "sembl-mcp"] }
    }
  }
  ```
  Or `pip install "sembl[mcp]"` and run `sembl-mcp`. Tools: `verify_change`,
  `bounds_from_spec`, `list_presets`, `doctor`, plus beta `clarify_task` /
  `generate_work_order` (the full CLI surface). Example config in
  [`examples/mcp/`](examples/mcp/); recipes in [`docs/integrations.md`](docs/integrations.md).
- **Agent Skills** — drop-in skills in [`skills/`](skills/) (copy to
  `.claude/skills/`): `sembl-verify-subagent` (main-agent-verifies-sub-agent),
  `sembl-setup-bounds`, and `sembl-gate-pr`.

## Install

```powershell
pip install sembl

# As an isolated tool
uv tool install sembl
```

From source:

```powershell
git clone https://github.com/speedvibecode/sembl
cd sembl
uv pip install -e .
```

## Status & honesty

Sembl went through a long generation-first phase. We tested its central premise
— that compiling a rich up-front contract makes the agent produce *better*
outcomes — and **our own results did not support it**: a one-line task did as well
as an eight-part Work Order for a capable agent. So we stopped claiming it.

What survived testing, and what Sembl now is:

- **`verify` — the accountability gate. This is the product.** Deterministic
  checks over a real diff; covered by the test suite.
- **`generate` / `clarify` / graph context — beta, optional, unproven as an
  outcome-improver.** Kept because they're a convenient way to produce a bounds
  file, but if you already use GitHub Spec Kit / Tessl / Kiro, **use that
  instead** and feed its output to `verify`.

We make **no** claim that Sembl improves what an agent produces. Its claim is
narrow and true: a repeatable, executor-neutral, free check that a change stayed
in declared bounds and didn't fabricate its results.

---

## Beta: Work Order generation

> **Optional and unproven.** Everything in this section is the older generation
> half of Sembl. It produces a "Work Order" — a scoped contract + executor prompt
> + a `work-order.json` that `verify` can read directly. It is interchangeable
> with GitHub Spec Kit and similar tools; reach for it only if you don't already
> have a spec/planning step.

```powershell
# core (generation uses an LLM provider)
pip install sembl

# with optional graph context (Graphify + code-review-graph)
pip install "sembl[graph-pipeline]"
```

Set one provider key, then generate:

```powershell
$env:OPENAI_API_KEY="..."   # or ANTHROPIC_API_KEY / GEMINI_API_KEY / NVIDIA_API_KEY / OPENROUTER_API_KEY
sembl generate --repo C:\path\to\repo --task "fix the failing login redirect test" --provider openai
```

Providers: `openai`, `anthropic`, `gemini`, `nvidia`, `openrouter`, `tokenrouter`,
local `ollama`, and `claude-cli`. Output lands in
`.sembl/work-orders/wo-...{slug}/` as `work-order.md`, `executor-prompt.md`,
`validation-plan.md`, and `work-order.json` (the file `verify --wo-file` reads).

Other beta commands:

```powershell
sembl clarify  --repo . --task "..."   # judge whether a task is specified enough to scope (exit 2 if blocked)
sembl doctor   --repo .                # check the optional graph subsystem (tools, graphs, keys, fixes)
sembl show                             # show the latest Work Order
sembl list                             # list Work Orders in this repo
sembl validate                         # older PASS/FAIL form of verify (kept for back-compat)
```

### Optional graph context

`generate` can use [Graphify](https://pypi.org/project/graphify/) and
code-review-graph to ground scope in the repo's structure. It is best-effort and
off the critical path; run `sembl doctor` to see what's installed and how to fix
gaps, and use `--graph-mode auto|required|off` to control it.

## Local test

```powershell
.venv\Scripts\python.exe -m pytest tests\ -q
python -m compileall -q sembl tests
```

## Releasing

Publishing uses GitHub Actions and Trusted Publishing (OIDC); no API tokens are
stored. `.github/workflows/release.yml` publishes to PyPI when you publish a
GitHub Release whose tag (`v<version>`) matches `pyproject.toml` and
`sembl/__init__.py`. See `VERSIONING.md`.

---

Models write code. **Sembl makes the change accountable.**
