"""
sembl.mcp_server — expose the deterministic accountability gate over MCP.

This is how an agent (or an orchestrator supervising a sub-agent) calls Sembl
without a shell: it hands over a diff and what was *declared*, and gets back a
PASS / WARN / BLOCK verdict computed by the same code as `sembl verify`.

The headline is the four **claim-vs-reality** checks, which need no scope guess
and have no false-alarm problem (EXP-04/05):
  • forbidden-area edits            (explicit, author-declared)  → BLOCK
  • fabricated file claims          (claimed changed but wasn't) → BLOCK
  • validation claimed-not-evidenced (said tests passed, no proof) → WARN
  • churn over the declared budget                                → WARN
Scope adherence is an **optional** layer on top: only as good as the declared
editable_paths, so it is advisory and tolerant by default (DEFAULT_SCOPE_TOLERANCE).

The main-agent-verifies-sub-agent pattern (general case, no external tool):
  1. the sub-agent declares what it will touch (editable_paths) and reports what
     it did + whether it validated;
  2. it returns a diff;
  3. the orchestrator calls `verify_change(diff=..., editable_paths=...,
     report=...)` and trusts the deterministic verdict, not the sub-agent's word.

Tool bodies are plain functions (testable without an MCP transport); `main()`
registers them on a FastMCP server over stdio. Requires the `mcp` extra:
    pip install "sembl[mcp]"
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .validator import validate_against_work_order, load_report, parse_unified_diff


# --------------------------------------------------------------------------- #
# Tool bodies (plain functions — no MCP dependency, directly unit-testable)
# --------------------------------------------------------------------------- #
def _build_work_order(
    editable_paths: list | None,
    forbidden_areas: list | None,
    churn_budget: dict | None,
    scope_tolerance: dict | None,
    bounds_file: str | None,
    repo_path: str,
) -> dict:
    """Assemble the bounds contract from inline fields or a bounds file.

    Inline fields win; a `bounds_file` (or a `bounds.json` at the repo root) is the
    fallback. Returns the four-field contract verify reads."""
    wo: dict = {}
    path = None
    if bounds_file:
        path = Path(bounds_file)
    else:
        default = Path(repo_path) / "bounds.json"
        if default.is_file():
            path = default
    if path is not None and path.is_file():
        wo = json.loads(path.read_text(encoding="utf-8", errors="replace"))

    if editable_paths is not None:
        wo["editable_paths"] = editable_paths
    if forbidden_areas is not None:
        wo["forbidden_areas"] = forbidden_areas
    if churn_budget is not None:
        wo["churn_budget"] = churn_budget
    if scope_tolerance is not None:
        wo["scope_tolerance"] = scope_tolerance
    return wo


def verify_change(
    diff: str | None = None,
    repo_path: str = ".",
    editable_paths: list | None = None,
    forbidden_areas: list | None = None,
    churn_budget: dict | None = None,
    scope_tolerance: dict | None = None,
    report: dict | None = None,
    bounds_file: str | None = None,
    strict: bool = False,
) -> dict:
    """Run the gate over a change and return a deterministic PASS/WARN/BLOCK verdict.

    Provide EITHER `diff` (a unified diff / .patch string — no checkout needed, ideal
    for verifying a sub-agent's patch) OR a `repo_path` whose working tree is read via
    git. `report` is the actor's self-report (claimed files / validations) — never
    trusted, only checked against reality. Bounds come from the inline fields or a
    `bounds_file` / repo-root `bounds.json`. `strict` promotes out-of-scope to BLOCK.
    """
    wo = _build_work_order(
        editable_paths, forbidden_areas, churn_budget, scope_tolerance,
        bounds_file, repo_path,
    )
    changed_files = diff_lines = None
    if diff is not None:
        changed_files, diff_lines = parse_unified_diff(diff)

    policy = "strict" if strict else "advisory_scope"
    result = validate_against_work_order(
        repo_path, wo, report,
        changed_files=changed_files, diff_line_count=diff_lines,
    )
    data = result.to_dict(policy)
    data["summary"] = {
        "verdict": data["verdict"],
        "files_changed": len(result.changed_files),
        "blocking": bool(result.forbidden_hits or result.fabricated_claims),
        "out_of_scope": result.out_of_scope,
        "forbidden_hits": result.forbidden_hits,
        "fabricated_claims": result.fabricated_claims,
        "validation_not_evidenced": result.validation_not_run,
        "reasons": result.reasons(),
    }
    return data


def bounds_from_spec(
    tasks_text: str | None = None,
    tasks_path: str | None = None,
    preset: str | None = None,
    config_file: str | None = None,
    repo_path: str = ".",
    source: str | None = None,
) -> dict:
    """Derive a bounds contract from a spec/plan, so scope has precise inputs.

    One of: `tasks_text` (raw Spec Kit tasks.md content), `tasks_path` (a tasks.md or
    Spec Kit feature dir), `preset` (spec-kit / kiro / tessl / agents-md /
    cursor-rules, resolved under `repo_path`), or `config_file` (a custom declarative
    adapter config — which files to read, how to pull paths, what's forbidden).
    Returns {"bounds": {...}, "sources": [...]}. Prose is a poor bounds source —
    prefer a real tasks.md."""
    from . import speckit
    from . import adapters

    if tasks_text is not None:
        return {"bounds": speckit.bounds_from_tasks_text(tasks_text), "sources": ["<text>"]}
    if tasks_path is not None:
        bounds, src = speckit.bounds_from_spec_kit(tasks_path)
        return {"bounds": bounds, "sources": [str(src)]}
    if config_file is not None:
        config = adapters.load_config(config_file)
        bounds, sources = adapters.build_bounds_from_config(config, repo_path)
        return {"bounds": bounds, "sources": sources}
    if preset is not None:
        bounds, sources = adapters.bounds_from_preset(preset, repo_path, source)
        return {"bounds": bounds, "sources": sources}
    raise ValueError("provide one of: tasks_text, tasks_path, preset, or config_file")


def list_presets() -> dict:
    """List the available declarative bounds presets (Tier-2 adapters)."""
    from . import adapters
    return {"presets": adapters.preset_names()}


def doctor(repo_path: str = ".", graph_age_threshold: float = 24.0) -> dict:
    """Repo-readiness diagnostics (deterministic, no API key, no model).

    Reports project type, detected rules/commands, and — if the graph extra is
    installed — graph substrate freshness. Useful before generating bounds or
    handing a repo to an agent."""
    from .graph_diagnostics import detect
    return detect(repo_path, age_threshold_hours=graph_age_threshold).to_dict()


# --- Beta: generation half (frozen — exposed for surface completeness, not a
# --- recommended path). Needs an LLM provider + key; verify/bounds do not. Prefer
# --- a real spec tool (Spec Kit) upstream; see docs.
def clarify_task(
    task: str,
    repo_path: str = ".",
    provider: str = "openai",
    model: str | None = None,
    api_key: str | None = None,
) -> dict:
    """[beta] Read a task's intent and surface ambiguities before execution.

    Decoupled from execution; needs a provider API key. The deterministic gate
    (verify) is the supported product — this is optional and unmaintained."""
    from .repo_probe import probe_repo
    from .clarify import analyze_clarity
    probe = probe_repo(repo_path, task, use_graphify=False, use_crg=False)
    return analyze_clarity(task, probe, provider, model, api_key).to_dict()


def generate_work_order(
    task: str,
    repo_path: str = ".",
    provider: str = "openai",
    model: str | None = None,
    api_key: str | None = None,
    write: bool = False,
) -> dict:
    """[beta] Generate a Work Order (a superset of the bounds contract) from a task.

    Frozen generation half — our own evidence falsified "rich contract → better
    outcomes" (see project notes). Exposed for completeness; for real use, prefer a
    spec tool upstream and let `verify` gate the result. Needs a provider API key.
    Graph enrichment is off here for a light, dependency-free path."""
    import dataclasses
    from .repo_probe import probe_repo
    from .generator import generate_work_order as _gen
    from .output import write_work_order
    probe = probe_repo(repo_path, task, use_graphify=False, use_crg=False)
    wo = _gen(task, probe, provider, model, api_key, enrich_graph=False)
    out_dir = str(write_work_order(wo, repo_path)) if write else None
    return {"work_order": dataclasses.asdict(wo), "written_to": out_dir}


# --------------------------------------------------------------------------- #
# MCP wiring
# --------------------------------------------------------------------------- #
def build_server() -> Any:
    """Create the FastMCP server with the tools registered. Imports `mcp` lazily."""
    try:
        from mcp.server.fastmcp import FastMCP
    except ImportError as exc:  # pragma: no cover - depends on optional extra
        raise SystemExit(
            "The MCP server needs the 'mcp' package. Install it with:\n"
            '    pip install "sembl[mcp]"'
        ) from exc

    server = FastMCP("sembl")
    for fn in (
        verify_change,        # the gate (headline)
        bounds_from_spec,     # bounds from spec / preset / config
        list_presets,
        doctor,               # deterministic repo diagnostics
        clarify_task,         # [beta]
        generate_work_order,  # [beta]
    ):
        server.tool(name=fn.__name__, description=fn.__doc__)(fn)
    return server


def main() -> None:
    """Entry point: run the Sembl MCP server over stdio."""
    build_server().run()


if __name__ == "__main__":  # pragma: no cover
    main()
