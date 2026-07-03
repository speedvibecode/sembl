# IDE quickstart — gate your agent's PRs in one tool call

Your IDE agent writes the change; Sembl tells you — deterministically, no model
in the loop — whether that change stayed inside what was declared. This page
gets you from zero to a gated PR in about two minutes.

## 1. Register the MCP server

The server needs Python and git, no API key. `uvx` runs it with nothing to
install:

**Claude Code** (CLI, one line):

```bash
claude mcp add sembl -- uvx --from "sembl[mcp]" sembl-mcp
```

**Cursor** — `.cursor/mcp.json` in your repo (or `~/.cursor/mcp.json` globally):

```json
{
  "mcpServers": {
    "sembl": { "command": "uvx", "args": ["--from", "sembl[mcp]", "sembl-mcp"] }
  }
}
```

**VS Code (Copilot agent mode)** — `.vscode/mcp.json`:

```json
{
  "servers": {
    "sembl": { "type": "stdio", "command": "uvx", "args": ["--from", "sembl[mcp]", "sembl-mcp"] }
  }
}
```

Prefer a pinned install? `pip install "sembl[mcp]"` and use `sembl-mcp` as the
command instead of `uvx`.

## 2. Declare bounds once

The gate judges a change against a **bounds contract** — what's editable,
what's forbidden, how big the change may be. Put a `bounds.json` at the repo
root ([the four fields](bounds.md)), or derive one from the spec you already
have:

```bash
sembl bounds --from spec-kit --source specs/001/tasks.md   # or kiro | tessl | agents-md | cursor-rules
```

(Agents can do this over MCP too: `bounds_from_spec` → save the result.)

## 3. Gate the PR — one call

When the agent (or you) wants the verdict on the current branch, it calls
**`gate_pr`**:

```jsonc
// gate_pr arguments — everything below is optional
{ "repo_path": "." }
```

That one call picks the base ref (`origin/HEAD` → `main` → `master`), diffs
`base...HEAD` (the branch's own commits only), finds your `bounds.json`, and
returns `PASS` / `WARN` / `BLOCK` with per-check findings plus a `pr` record of
exactly what was gated (base, head, merge-base, bounds source). Options:
`base`/`head` refs, `strict: true` (out-of-scope becomes BLOCK), inline
`editable_paths`/`forbidden_areas` instead of a file, and a `report` of what
the agent claims it did — claims are checked against the diff, never trusted.

A natural prompt to your IDE agent:

> Implement the task, then call sembl's `gate_pr` and show me the verdict.
> If it's not PASS, fix the findings before you stop.

## 4. What it catches

- **Forbidden-area edits** → BLOCK — the change touched what the contract said
  never to touch.
- **Gate-contract self-edits** → BLOCK — the change rewrote `bounds.json` /
  the work order judging it.
- **Fabricated claims** → BLOCK — the report names a file the diff never
  changed.
- **Validation claimed, not evidenced** → WARN — "tests passed" with no exit
  code, log, or output behind it.
- **Out-of-scope edits / churn over budget** → WARN (BLOCK with `strict`) —
  advisory by default because loose bounds cause false alarms; precise bounds
  from a real spec make it a hard gate.

## Beyond the IDE

The same verdict, from the same code, everywhere the change moves next:
**pre-commit** hook, **GitHub Action** for CI, or plain
`git diff | sembl verify --diff -` in any harness — see
[integrations](integrations.md). For orchestrators supervising sub-agents
(hand over the sub-agent's patch, not a checkout), use `verify_change`
directly — the [MCP section](integrations.md#mcp-agents--sub-agent-supervision)
has the pattern.
