# Sembl

Turn messy repo intent into scoped AI Work Orders.

Sembl is not an AI coding agent. It is the layer that runs before one:

```text
repo + task -> Work Order -> agent executes with tighter scope
```

A Work Order is an execution contract. It tells an agent:

- what the goal is, and what it is not
- which files it can touch
- which files it should inspect but not modify
- what must be true when it finishes
- how to prove it succeeded
- when to stop and ask a human

Website: https://sembl.vercel.app

## Current Status

Sembl is early but usable for testing. The current CLI supports:

- repo probing for language/framework/branch/dirty state
- optional Graphify context
- optional code-review-graph context
- graph diagnostics via `sembl doctor`, and `--graph-mode auto|required|off`
- LLM graph-impact synthesis over code-review-graph output (`--no-graph-enrichment` to skip)
- OpenAI, Anthropic, Gemini, and NVIDIA NIM providers
- work-order output as Markdown, JSON, executor prompt, validation plan, and graph-impact analysis

The best test path is graph-first:

```powershell
pip install "sembl[graph-pipeline]"
sembl generate --repo C:\path\to\repo --task "fix the failing login redirect test" --provider nvidia --require-graph-context
```

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
```

Then choose the provider:

```powershell
sembl generate --repo C:\path\to\repo --task "replace starter screen text" --provider nvidia
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
```

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

Both channels publish automatically via GitHub Actions and Trusted Publishing
(OIDC). No API tokens are stored.

### Stable releases -> PyPI

`.github/workflows/release.yml` publishes to PyPI when you publish a GitHub
Release.

1. Bump the version in `pyproject.toml`, `sembl/__init__.py`, and the
   `--version` option in `sembl/cli.py` (all three must match).
2. Commit and push.
3. On GitHub: **Releases -> Draft a new release -> Create a new tag** named
   `v<version>` (e.g. `v0.1.2`, matching the bumped version) -> **Publish**.

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

Keep `master` on the next in-development version (e.g. after releasing `0.1.1`,
bump to `0.1.2`) so dev builds sort above the last stable release.

Models write code. Sembl makes the work governable.
