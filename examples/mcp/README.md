# Sembl MCP server

Run the deterministic accountability gate as an MCP server so an agent — or an
orchestrator supervising a sub-agent — can call it directly.

## Zero-install (recommended)

Paste `.mcp.json` here into your MCP client's config. `uvx` fetches and runs the
server on demand — no clone, no build, no API key:

```json
{
  "mcpServers": {
    "sembl": { "command": "uvx", "args": ["--from", "sembl[mcp]", "sembl-mcp"] }
  }
}
```

- **Claude Code**: put it in `.mcp.json` at your project root (or `claude mcp add`).
- **Cursor / Windsurf / other clients**: add the same `sembl` entry to their MCP config.

## Or install it

```bash
pip install "sembl[mcp]"
sembl-mcp          # speaks MCP over stdio
```

## Tools

| Tool | What it does |
|------|--------------|
| `verify_change` | Gate a diff: pass a unified `diff` + `editable_paths`/`forbidden_areas` (or a `bounds_file`) + an optional `report`; get PASS/WARN/BLOCK and per-check findings. |
| `bounds_from_spec` | Derive bounds from a Spec Kit `tasks.md` (text/path), a preset, or a custom config. |
| `list_presets` | The declarative bounds presets. |
| `doctor` | Deterministic repo-readiness diagnostics (no model). |
| `clarify_task` / `generate_work_order` | **beta** — the generation half, for completeness. |

## The main-agent-verifies-sub-agent pattern

```jsonc
// verify_change arguments
{
  "diff": "<the sub-agent's patch>",
  "editable_paths": ["src/auth/"],          // what it said it would touch
  "forbidden_areas": ["migrations/"],
  "report": { "changed_files": ["src/auth/login.ts"], "tests_passed": true }
}
```

Catches a sub-agent that edits outside its declared files, touches a forbidden area,
claims a file it never changed, or says "tests passed" with no evidence —
deterministically, with no second model in the loop.
