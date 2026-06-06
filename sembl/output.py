"""
output.py

Writes Work Order output files to .sembl/work-orders/{slug}/

  work-order.md       - human-readable, the thing developers actually read
  work-order.json     - machine-readable, feeds future tooling
  executor-prompt.md  - paste this directly into Claude Code / Aider / Cursor
  validation-plan.md  - what to run and check after execution
"""

import json
import re
from pathlib import Path
from .generator import WorkOrder


def write_work_order(wo: WorkOrder, repo_path: str) -> Path:
    """Write all 4 output files. Returns the directory path."""
    slug = _slug(wo.id)
    out_dir = Path(repo_path) / ".sembl" / "work-orders" / slug
    out_dir.mkdir(parents=True, exist_ok=True)

    _write_markdown(wo, out_dir)
    _write_json(wo, out_dir)
    _write_executor_prompt(wo, out_dir)
    _write_validation_plan(wo, out_dir)

    return out_dir


# Writers

def _write_markdown(wo: WorkOrder, out_dir: Path):
    lines = [
        f"# Work Order - {wo.id}",
        f"",
        f"**Repo:** `{wo.repo_name}` | **Branch:** `{wo.git_branch}` | **Risk:** `{wo.risk_level.upper()}`",
        f"**Created:** {wo.created_at}",
        f"**Task type:** `{wo.task_type}`",
        f"",
        f"---",
        f"",
    ]

    # Lock 1 - Intent
    lines += [
        "## 1. Intent Lock",
        "",
        f"**Original request:**",
        f"> {wo.original_request}",
        "",
        f"**Clarified goal:** {wo.clarified_goal}",
        "",
        f"**User-visible outcome:** {wo.user_visible_outcome}",
        "",
    ]

    # Lock 2 - Boundary
    lines += ["## 2. Boundary Lock", ""]
    lines += _md_list("Non-goals", wo.non_goals)
    lines += _md_list("Must not change", wo.must_not_change)
    lines += _md_list("Forbidden areas (agent must not touch)", wo.forbidden_areas)

    # Lock 3 - Scope
    lines += ["## 3. Scope Lock", ""]
    lines += _md_list("Likely affected areas", wo.likely_affected_areas)
    lines += _md_list("Editable paths (agent MAY modify)", wo.editable_paths)
    lines += _md_list("Read-only context (inspect, do not modify)", wo.read_only_context)

    # Lock 4 - Context
    lines += ["## 4. Context Lock", ""]
    lines += _md_list("Files to inspect before starting", wo.files_to_inspect)
    lines += _md_list("Tests to inspect", wo.tests_to_inspect)
    lines += _md_list("Architecture notes", wo.architecture_notes)
    if wo.project_rules:
        lines += ["**Project rules found:**", ""]
        for rule in wo.project_rules:
            lines += [f"```\n{rule[:300]}\n```", ""]

    # Lock 5 - Success
    lines += ["## 5. Success Lock", ""]
    lines += _md_list("Acceptance criteria", wo.acceptance_criteria, numbered=True)
    lines += _md_list("Regressions to preserve", wo.regressions_to_preserve)

    # Lock 6 - Proof
    lines += ["## 6. Proof Lock", ""]
    lines += _md_list("Validation commands", wo.validation_commands, code=True)
    lines += _md_list("Tests to add or update", wo.tests_to_add_or_update)
    lines += _md_list("Manual checks", wo.manual_checks, numbered=True)

    # Lock 7 - Safety
    lines += [
        "## 7. Safety Lock",
        "",
        f"**Risk level:** `{wo.risk_level.upper()}`",
        "",
    ]
    if wo.risk_reasons:
        lines += ["**Risk reasons:**", ""]
        for r in wo.risk_reasons:
            lines += [f"- {r}"]
        lines += [""]
    lines += _md_list("Stop conditions (agent must halt and ask human)", wo.stop_conditions)
    lines += _md_list("Approval triggers (blocks merge)", wo.approval_triggers)

    # Lock 8 - Executor Packet
    lines += [
        "## 8. Executor Packet",
        "",
        "_See `executor-prompt.md` for the agent-ready prompt._",
        "",
    ]
    lines += _md_list("Patch expectations", wo.patch_expectations)
    if wo.reporting_format:
        lines += [f"**Reporting format:** {wo.reporting_format}", ""]

    # Reconciliation placeholder
    lines += [
        "---",
        "",
        "## Reconciliation _(fill after execution)_",
        "",
        "- **Status:** pending",
        "- **Files changed:**",
        "- **Validation results:**",
        "- **Human decision:**",
        "- **Notes:**",
        "",
    ]

    _write_markdown_file(out_dir / "work-order.md", lines)


def _write_json(wo: WorkOrder, out_dir: Path):
    import dataclasses
    data = dataclasses.asdict(wo)
    (out_dir / "work-order.json").write_text(
        json.dumps(data, indent=2, ensure_ascii=True), encoding="utf-8"
    )


def _write_executor_prompt(wo: WorkOrder, out_dir: Path):
    lines = [
        f"# Executor Prompt - {wo.id}",
        "",
        "_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._",
        "_Do not modify the scope, forbidden areas, or stop conditions._",
        "",
        "---",
        "",
        wo.executor_prompt,
        "",
        "---",
        "",
        "## Scope enforcement",
        "",
        "**You MAY only edit these paths:**",
    ]
    for p in wo.editable_paths:
        lines.append(f"- `{p}`")
    lines += ["", "**You must NOT touch:**"]
    for p in wo.forbidden_areas:
        lines.append(f"- `{p}`")
    lines += [
        "",
        "## Stop conditions",
        "",
        "Stop immediately and ask the human if any of these occur:",
        "",
    ]
    for sc in wo.stop_conditions:
        lines.append(f"- {sc}")
    lines += [
        "",
        "## Patch expectations",
        "",
    ]
    for pe in wo.patch_expectations:
        lines.append(f"- {pe}")

    _write_markdown_file(out_dir / "executor-prompt.md", lines)


def _write_validation_plan(wo: WorkOrder, out_dir: Path):
    lines = [
        f"# Validation Plan - {wo.id}",
        "",
        "Run these checks after the agent completes its work.",
        "",
        "## Automated checks",
        "",
        "### Commands to run",
        "",
    ]
    if wo.validation_commands:
        lines.append("```bash")
        for cmd in wo.validation_commands:
            lines.append(cmd)
        lines.append("```")
    else:
        lines.append("_No automated commands detected. Add manually._")
    lines += [
        "",
        "### Tests to add or update",
        "",
    ]
    for t in wo.tests_to_add_or_update:
        lines.append(f"- [ ] {t}")

    lines += [
        "",
        "## Acceptance criteria checklist",
        "",
    ]
    for i, ac in enumerate(wo.acceptance_criteria, 1):
        lines.append(f"- [ ] {i}. {ac}")

    lines += [
        "",
        "## Manual verification",
        "",
    ]
    for mc in wo.manual_checks:
        lines.append(f"- [ ] {mc}")

    lines += [
        "",
        "## Approval triggers",
        "",
        "_The following conditions block merge and require explicit human approval:_",
        "",
    ]
    for at in wo.approval_triggers:
        lines.append(f"- {at}")

    lines += [
        "",
        "## Regressions to preserve",
        "",
    ]
    for rp in wo.regressions_to_preserve:
        lines.append(f"- [ ] {rp}")

    _write_markdown_file(out_dir / "validation-plan.md", lines)


# Helpers

def _md_list(title: str, items: list, numbered: bool = False, code: bool = False) -> list[str]:
    if not items:
        return [f"**{title}:** _none identified_", ""]
    lines = [f"**{title}:**", ""]
    for i, item in enumerate(items, 1):
        prefix = f"{i}." if numbered else "-"
        content = f"`{item}`" if code else item
        lines.append(f"{prefix} {content}")
    lines.append("")
    return lines


def _write_markdown_file(path: Path, lines: list[str]):
    path.write_text(_ascii_safe("\n".join(lines)), encoding="utf-8")


def _ascii_safe(text: str) -> str:
    replacements = {
        "\u2013": "-",
        "\u2014": "-",
        "\u2018": "'",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u2022": "-",
        "\u00b7": "|",
        "\u00a0": " ",
        "\u2192": "->",
        "\u2713": "ok",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text.encode("ascii", errors="replace").decode("ascii")


def _slug(wo_id: str) -> str:
    return re.sub(r"[^a-z0-9\-]", "", wo_id.lower())[:80]
