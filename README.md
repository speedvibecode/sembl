# Sembl

[![PyPI](https://img.shields.io/pypi/v/sembl.svg)](https://pypi.org/project/sembl/)
[![Python](https://img.shields.io/pypi/pyversions/sembl.svg)](https://pypi.org/project/sembl/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Graph-first Work Order generator for AI coding agents.

Sembl turns vague repo tasks into scoped execution contracts before an AI coding
agent starts editing. Use it with Cursor, Claude Code, Codex, Aider, OpenCode,
or any executor that can follow a structured prompt.

```text
repo + task -> Work Order -> agent executes with tighter scope
```

A Work Order tells an agent:

- what the goal is, and what it is not
- which files it can touch
- which files it should inspect but not modify
- what must be true when it finishes
- how to prove it succeeded
- when to stop and ask a human

[Website](https://sembl.vercel.app) | [PyPI](https://pypi.org/project/sembl/) | [Issues](https://github.com/speedvibecode/sembl/issues)

## Why Sembl

AI coding agents are strong executors, but loose prompts still create avoidable
failure modes: broad edits, fake validation commands, missed test context, and
unclear stop conditions.

Sembl sits before execution:

1. It probes the repo.
2. It uses Graphify and code-review-graph when available.
3. It asks an LLM to produce a strict Work Order.
4. It writes Markdown and JSON outputs that another agent can execute.

The result is not "more autonomy." It is a narrower, clearer packet of work.

## Quickstart

```powershell
pip install "sembl[graph-pipeline]"

$env:NVIDIA_API_KEY="..."
sembl doctor --repo C:\path\to\repo
sembl generate --repo C:\path\to\repo --task "fix the failing login redirect test" --provider nvidia --graph-mode required --refresh-graph
```

For a core install without Graphify/code-review-graph:

```powershell
pip install sembl
```

## Example Output

```text
Work Order generated

Goal: Fix the failing login redirect test by correcting redirect behavior after successful authentication
Outcome: Users are correctly redirected to the intended destination after logging in
Task type: bugfix | Risk: MEDIUM

Acceptance criteria: 5 items
Validation commands: 4 commands
Stop conditions: 5 triggers

Output: .sembl/work-orders/wo-project-.../
```

The generated folder contains `work-order.md`, `executor-prompt.md`,
`validation-plan.md`, `work-order.json`, and graph impact notes when graph
context is available.

## Status

Sembl is early but usable for testing. The current CLI supports:

- repo probing for language/framework/branch/dirty state
- optional Graphify context
- optional code-review-graph context
- graph diagnostics via `sembl doctor`, and `--graph-mode auto|required|off`
- LLM graph-impact synthesis over code-review-graph output (`--no-graph-enrichment` to skip)
- OpenAI, Anthropic, Gemini, NVIDIA NIM, OpenRouter, and local Ollama providers
- work-order output as Markdown, JSON, executor prompt, validation plan, and graph-impact analysis

## Proof

Sembl is tested against real, popular open-source repos - not toy apps. Each task
is pinned to a commit and taken from a real closed issue that already has a known
human fix, so the Work Order's scope can be checked against the file a maintainer
actually changed. Every Work Order, diff, and validation run is in
[`demo-tasks/`](demo-tasks/).

| Repo | Stack | Task (from a real issue) | Work Order scoped to | Matches human fix |
|------|-------|--------------------------|----------------------|-------------------|
| [httpie/cli](https://github.com/httpie/cli) | Python CLI | HTTPS broke after `requests` 2.32.3 | `httpie/ssl_.py` | yes (1/1) |
| [projectdiscovery/katana](https://github.com/projectdiscovery/katana) | Go crawler | `-headless-options` ignored since v1.4.0 | 3 headless-engine files | yes (3/3) |
| [FastAPI full-stack template](https://github.com/fastapi/full-stack-fastapi-template) | Py + TS | password reset always "passwords do not match" | `frontend/src/utils.ts` | yes (1/1) |
| [mckaywrigley/chatbot-ui](https://github.com/mckaywrigley/chatbot-ui) | TS / Next | Claude responses cut off | `app/api/chat/anthropic/route.ts` | yes (1/1) |

Across all four, the Work Order's editable scope named the exact file a human
changed. On the katana regression, three different agents (Haiku, Sonnet, Opus)
each produced the maintainer's reference fix touching only the right files, and
`sembl validate` confirmed every in-scope fix - while flagging an out-of-scope
edit for review and catching a model that returned a success report for changes
it never made. One valid solution exists per task; scope is measured before
execution. Full method and per-run notes:
[`demo-tasks/CROSS-REPO-FINDINGS.md`](demo-tasks/CROSS-REPO-FINDINGS.md).

## Install

Sembl is published on PyPI: https://pypi.org/project/sembl/

```powershell
# Core CLI
pip install sembl

# With the graph pipeline (Graphify + code-review-graph)
pip install "sembl[graph-pipeline]"

# As an isolated tool
uv tool install sembl
```

### Pre-release channels

For the latest unreleased commits, install from GitHub:

```powershell
uv pip install "sembl[graph-pipeline] @ git+https://github.com/speedvibecode/sembl.git"
```

TestPyPI mirrors each release (the `--extra-index-url` lets dependencies resolve
from the real PyPI):

```powershell
pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ sembl
```

## Install From Source

```powershell
git clone https://github.com/speedvibecode/sembl
cd sembl
uv pip install -e ".[graph-pipeline]"
```

Plain pip also works:

```powershell
pip install -e ".[graph-pipeline]"
```

## Provider Keys

Set one provider key before generation:

```powershell
$env:OPENAI_API_KEY="..."
$env:ANTHROPIC_API_KEY="..."
$env:GEMINI_API_KEY="..."
$env:NVIDIA_API_KEY="..."
$env:OPENROUTER_API_KEY="..."
# Ollama needs no key (local); set OLLAMA_HOST only to point at a non-default server.
```

Then choose the provider (`openai`, `anthropic`, `gemini`, `nvidia`, `openrouter`, or `ollama`):

```powershell
sembl generate --repo C:\path\to\repo --task "replace starter screen text" --provider nvidia

# OpenRouter (OpenAI-compatible) routes to any model in its catalog:
sembl generate --repo C:\path\to\repo --task "replace starter screen text" --provider openrouter --model moonshotai/kimi-k2

# Ollama runs locally — no key, no rate limits, offline (slower on CPU-only machines):
#   ollama pull qwen2.5-coder:7b
sembl generate --repo C:\path\to\repo --task "replace starter screen text" --provider ollama --model qwen2.5-coder:7b
```

## Optional Graph Context

Sembl can run without graph tools, but the strongest results come from Graphify plus code-review-graph.

```powershell
graphify update C:\path\to\repo --no-cluster
code-review-graph build --repo C:\path\to\repo --data-dir C:\path\to\repo-specific-crg-data --skip-flows

$env:CRG_DATA_DIR="C:\path\to\repo-specific-crg-data"
sembl generate --repo C:\path\to\repo --task "fix the failing login redirect test" --provider nvidia --graph-mode required
```

Sembl guards against stale generic `CRG_DATA_DIR` values by deriving a repo-specific graph data directory when the env var does not look like it belongs to the target repo.

### Diagnose and control graph context

Run `sembl doctor` first to see exactly what is installed, what is built, and the
copy-paste command to fix each gap (add `--fix` to install missing graph tools,
or `--json` for machine-readable output):

```powershell
sembl doctor --repo C:\path\to\repo
```

Then choose how generation treats graph context with `--graph-mode`:

- `auto` (default): use graph context if available, otherwise explain what is missing and fall back to direct repo probing.
- `required`: fail **before** any LLM call if graph context is unavailable, so no tokens are wasted. (`--require-graph-context` is a backward-compatible alias.)
- `off`: skip Graphify and code-review-graph entirely.

Add `--refresh-graph` to rebuild the graphs (Graphify update + code-review-graph build) before generating.

## Usage

```powershell
# Generate a Work Order for the current repo
sembl generate --task "add recurring expenses to this tracker" --provider nvidia

# Generate for an explicit repo
sembl generate --repo C:\path\to\repo --task "fix the login redirect bug" --provider nvidia

# Check the graph subsystem (tools, graphs, keys) and how to fix gaps
sembl doctor --repo C:\path\to\repo

# Require graph context (fails before any LLM call if it is unavailable)
sembl generate --repo C:\path\to\repo --task "fix the login redirect bug" --provider nvidia --graph-mode required

# Rebuild the graphs first, then generate on fresh context
sembl generate --repo C:\path\to\repo --task "fix the login redirect bug" --provider nvidia --refresh-graph

# List Work Orders
sembl list

# Show latest Work Order
sembl show

# Show the executor prompt
sembl show --file executor-prompt

# Show the graph-impact analysis (when graph context was available)
sembl show --file graph-impact

# After the agent runs: check its diff against the Work Order scope
sembl validate

# Cross-check an executor's report for fabricated claims
sembl validate --report agent-report.json
```

`sembl validate` compares the repository's actual git changes against the latest
Work Order's editable paths and forbidden areas, and (with `--report`) flags any
files the executor claimed to change but did not. It never trusts an agent's
self-report.

## Output

```text
.sembl/work-orders/wo-myproject-{timestamp}-{slug}/
  work-order.md       - read this
  executor-prompt.md  - paste into your agent
  validation-plan.md  - run this after
  work-order.json     - machine-readable
  graph-impact.md     - LLM synthesis of code-review-graph blast radius (graph context only)
```

## Graph Impact Synthesis

When code-review-graph context is available, Sembl runs a focused LLM pre-pass
that turns the graph's terse structural output (blast radius, node/edge counts)
into a concise, grounded impact analysis: likely edit targets, hidden coupling,
and files to keep read-only. That synthesis grounds the main Work Order and is
also written to `graph-impact.md`. It is best-effort - if the provider call
fails it is skipped silently. Disable it with `--no-graph-enrichment`.

## The 8 Locks

| Lock | Purpose |
|------|---------|
| Intent | Goal, outcome, task type |
| Boundary | Non-goals, forbidden areas |
| Scope | Editable paths, read-only context |
| Context | Files to inspect, architecture notes |
| Success | Acceptance criteria, regressions |
| Proof | Validation commands, tests to add |
| Safety | Stop conditions, risk level |
| Executor | Agent-ready prompt, patch expectations |

## Local Test

```powershell
python -m unittest discover -s tests -v
python -m compileall -q sembl tests
```

## Testing Notes

If you test Sembl on a real repo, the best feedback is:

- the exact command you ran
- whether graph context was available
- the generated `work-order.md`
- whether the executor agent could complete the task without scope confusion
- any hallucinated files, missing validation commands, or false stop conditions

## Releasing

Publishing uses GitHub Actions and Trusted Publishing (OIDC). Stable releases
publish from GitHub Releases; TestPyPI dev builds are manual. No API tokens are
stored.

### Stable releases -> PyPI

`.github/workflows/release.yml` publishes to PyPI when you publish a GitHub
Release.

1. Bump the version in `pyproject.toml` and `sembl/__init__.py`
   (`sembl --version` is derived from `sembl/__init__.py`).
2. Commit and push.
3. On GitHub: **Releases -> Draft a new release -> Create a new tag** named
   `v<version>` (for example, `v0.1.3`, matching the bumped version) -> **Publish**.

The workflow builds, runs `twine check`, and publishes to PyPI. The tag must
equal the `pyproject.toml` version or the build fails with a clear error.

### Dev builds -> TestPyPI (manual, optional)

While the project is this early, stable releases go straight to PyPI and nothing
sits in TestPyPI by default. `.github/workflows/testpypi.yml` is **manual only**
(`workflow_dispatch`): trigger it from the Actions tab when you deliberately want
a pre-release dev build (`<version>.devN`, stamped in CI). When you do, testers
install it with pip:

```powershell
pip install --pre --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ sembl
```

Or with uv (needs `--prerelease allow` and a best-match index strategy so the
dev build is preferred over the last stable release):

```powershell
uv pip install --prerelease allow --index-strategy unsafe-best-match --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ sembl
```

Before cutting TestPyPI dev builds after a stable release, bump `master` to the
next patch or minor version (for example, after releasing `0.1.3`, bump to
`0.1.4`) so dev builds sort above the last stable release.

Models write code. Sembl makes the work governable.
