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
- graph-required mode with `--require-graph-context`
- OpenAI, Anthropic, Gemini, and NVIDIA NIM providers
- work-order output as Markdown, JSON, executor prompt, and validation plan

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
sembl generate --repo C:\path\to\repo --task "fix the failing login redirect test" --provider nvidia --require-graph-context
```

Sembl guards against stale generic `CRG_DATA_DIR` values by deriving a repo-specific graph data directory when the env var does not look like it belongs to the target repo.

## Usage

```powershell
# Generate a Work Order for the current repo
sembl generate --task "add recurring expenses to this tracker" --provider nvidia

# Generate for an explicit repo
sembl generate --repo C:\path\to\repo --task "fix the login redirect bug" --provider nvidia

# Refuse direct-probe fallback
sembl generate --repo C:\path\to\repo --task "fix the login redirect bug" --provider nvidia --require-graph-context

# List Work Orders
sembl list

# Show latest Work Order
sembl show

# Show the executor prompt
sembl show --file executor-prompt
```

## Output

```text
.sembl/work-orders/wo-myproject-{timestamp}-{slug}/
  work-order.md       - read this
  executor-prompt.md  - paste into your agent
  validation-plan.md  - run this after
  work-order.json     - machine-readable
```

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

Models write code. Sembl makes the work governable.
