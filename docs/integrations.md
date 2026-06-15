# Integrations

Sembl is the accountability gate; it sits **downstream of whatever plans the
change** and **independent of whatever agent makes it**. The verdict comes from
one place — `sembl verify` over the real diff and a bounds file — so every
integration is just a different trigger for that one command.

`verify` auto-discovers a `bounds.json` (then `.sembl/bounds.json`) at the repo
root, so most of these run zero-arg. Produce that bounds file by hand, with
`sembl bounds --spec-kit`, or with `sembl generate` (beta). See
[the bounds contract](bounds.md).

## Upstream — where bounds come from

| Tool | How | Status |
|------|-----|--------|
| GitHub Spec Kit | `sembl bounds --spec-kit specs/<feature>` (or `--from spec-kit`) | shipped |
| Kiro / Tessl / AGENTS.md / Cursor rules | `sembl bounds --from kiro\|tessl\|agents-md\|cursor-rules` | shipped |
| Any other tool | `sembl bounds --config adapter.json` (declarative — see below) | shipped |
| Hand-written | author the four fields directly | shipped |
| `sembl generate` (beta) | LLM drafts a `work-order.json` verify reads | shipped |

### Declarative adapters (the long tail)

New planning tools don't need new code — they need a config. A built-in **preset**
is just a config dict naming which files to read and how to pull paths out of them:

```bash
sembl bounds --from agents-md --out bounds.json     # reads AGENTS.md / CLAUDE.md
sembl bounds --from kiro --out bounds.json           # reads .kiro/specs/**/tasks.md
sembl bounds --from spec-kit --source specs/001/tasks.md
```

For anything not covered, point `--config` at your own adapter (JSON, or YAML if
PyYAML is installed):

```json
{
  "source": ["docs/plan/**/*.md"],
  "editable": { "strategy": "path-tokens", "literal": ["src/core/"] },
  "forbidden": { "literal": ["migrations/", "infra/"] },
  "churn": { "max_files": "auto", "max_lines": 400 }
}
```

`source` is a list of repo-relative files/globs; `path-tokens` extracts concrete
file paths from their text; `literal` lists are added verbatim. That's the whole
mechanism — the contract verify reads never changes, so the tail stays free.

## Downstream — where the verdict is consumed

### GitHub Actions (CI gate)

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: speedvibecode/sembl@v0.1.15
  with:
    bounds: bounds.json
    strict: "false"   # advisory by default; true for a hard scope gate
```

Full workflow: [`examples/github-workflow.yml`](../examples/github-workflow.yml).

### pre-commit (local commit gate)

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/speedvibecode/sembl
    rev: v0.1.15
    hooks:
      - id: sembl-verify
        # args: ["--strict"]
```

`pre-commit install`, then every commit runs `sembl verify` against the staged
change and your `bounds.json`.

### Agent harnesses (post-edit, in-loop)

Run verify the moment the agent stops editing, so a bad change is caught inside
the loop instead of at review. All of these read the working tree the agent just
modified against `bounds.json`.

**Claude Code** — `.claude/settings.json` (see
[`examples/claude-code-settings.json`](../examples/claude-code-settings.json)):

```json
{ "hooks": { "Stop": [ { "matcher": "",
  "hooks": [ { "type": "command", "command": "sembl verify --wo-file bounds.json || true" } ] } ] } }
```

**Aider** — wire verify in as the test command so Aider runs it after edits:

```bash
aider --test-cmd "sembl verify --wo-file bounds.json --strict" --auto-test
```

**OpenCode** — add a post-edit/stop hook in your OpenCode config that runs
`sembl verify --wo-file bounds.json`.

**Cursor / others** — any harness that can run a shell command on finish (or a
task you bind) can call `sembl verify`; pipe a diff with `--diff -` if you'd
rather not touch the working tree:

```bash
git diff | sembl verify --wo-file bounds.json --diff -
```

## The one command underneath

Every integration above is a trigger for:

```
sembl verify [--wo-file bounds.json] [--diff <patch>|-] [--report <agent.json>] [--strict]
```

Deterministic, executor-neutral, no model in the loop — same inputs, same verdict.
