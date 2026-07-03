"""
cli.py

Sembl CLI — the first machine.

Commands:
  sembl clarify   — judge if a task is specified enough to scope (intent stage)
  sembl generate  — repo + task → Work Order
  sembl doctor    — check the graph subsystem (tools, graphs, keys, fixes)
  sembl show      — display the latest Work Order
  sembl list      — list all Work Orders in this repo
"""

import os
import json
import subprocess
import sys
from pathlib import Path

import click
from rich.console import Console
from rich.markup import escape
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich import box

from . import __version__
from .repo_probe import probe_repo, _crg_common_args, _crg_env
from .generator import generate_work_order
from .clarify import analyze_clarity, analyze_clarity_best_effort
from .output import write_work_order
from .graph_diagnostics import (
    detect,
    resolve_graph_plan,
    repair_commands,
    tools_missing,
    install_graph_tools,
    INSTALL_HINT,
    INSTALL_HINT_UV,
)

console = Console()


@click.group()
@click.version_option(__version__, prog_name="sembl")
def main():
    """Sembl — a deterministic accountability gate for AI coding agents."""
    pass


# ── sembl generate ────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo",     "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--task",     "-t", required=True,
              help="The task or request to turn into a Work Order.")
@click.option("--provider", "-p", default="openai",
              type=click.Choice(["openai", "anthropic", "gemini", "nvidia", "openrouter", "tokenrouter", "ollama", "claude-cli"], case_sensitive=False),
              show_default=True, help="LLM provider.")
@click.option("--model",    "-m", default=None,
              help="Model name. Defaults to gpt-4o (openai), claude-sonnet-4-6 (anthropic), gemini-2.5-flash (gemini), or mistralai/mistral-medium-3.5-128b (nvidia).")
@click.option("--api-key",  default=None,
              help="API key. Otherwise Sembl reads the selected provider env var.")
@click.option("--graph-mode",
              type=click.Choice(["auto", "required", "off"], case_sensitive=False),
              default="auto", show_default=True,
              help="auto: use graph context if available, else fall back to direct probing. "
                   "required: fail before any LLM call if graph context is unavailable. "
                   "off: skip graph tools entirely.")
@click.option("--refresh-graph", is_flag=True, default=False,
              help="Rebuild Graphify + code-review-graph context before generating (graph tools must be installed).")
@click.option("--require-graph-context", is_flag=True, default=False,
              help="Alias for --graph-mode required.")
@click.option("--no-graphify", is_flag=True, default=False,
              help="Skip graphify even if available.")
@click.option("--no-crg",      is_flag=True, default=False,
              help="Skip code-review-graph even if available.")
@click.option("--no-graph-enrichment", is_flag=True, default=False,
              help="Skip the LLM pre-pass that synthesizes code-review-graph output into an impact analysis.")
@click.option("--graph-age-threshold", default=24.0, show_default=True,
              help="Warn if graph artifacts are older than this (hours).")
@click.option("--no-clarify", is_flag=True, default=False,
              help="Skip the intent/clarify stage. The Work Order is still produced but "
                   "carries no uncertainty analysis.")
@click.option("--strict-clarify", is_flag=True, default=False,
              help="Abort BEFORE generating a Work Order if the task is too underspecified "
                   "(clarify status=blocked). Use in scripts/CI to force clarification first.")
def generate(repo, task, provider, model, api_key, graph_mode, refresh_graph,
             require_graph_context, no_graphify, no_crg, no_graph_enrichment,
             graph_age_threshold, no_clarify, strict_clarify):
    """Generate a Work Order from a repo and a task description."""

    repo_path = str(Path(repo).resolve())
    mode = "required" if require_graph_context else graph_mode.lower()

    console.print()
    console.print(Panel(
        f"[bold]Task:[/bold] {task}",
        title="[bold blue]Sembl — Work Order Generator[/bold blue]",
        border_style="blue"
    ))
    console.print()

    # ── Step 1: Graph diagnostics (cheap, no LLM) ─────────────────────────
    diag = detect(repo_path, age_threshold_hours=graph_age_threshold)

    if refresh_graph:
        if mode == "off":
            console.print("[yellow]--refresh-graph ignored because --graph-mode off.[/yellow]\n")
        elif tools_missing(diag):
            console.print(
                "\n[red]Cannot refresh graph: the graph tools are not installed.[/red]\n"
                f"Install them with [bold]{escape(INSTALL_HINT)}[/bold] (or run [bold]sembl doctor --fix[/bold]),\n"
                "then rerun with --refresh-graph.\n"
            )
            sys.exit(1)
        else:
            _refresh_graph(repo_path, diag)
            diag = detect(repo_path, age_threshold_hours=graph_age_threshold)  # re-read after rebuilding

    # ── Step 2: Resolve what to do with graph context ─────────────────────
    action, message = resolve_graph_plan(mode, diag)
    if action == "fail":
        # Required but unavailable. Stop BEFORE the API-key check and any LLM call.
        console.print(_graph_unavailable_panel(message, diag))
        sys.exit(1)

    color = {"use": "green", "fallback": "yellow", "off": "dim"}.get(action, "white")
    console.print(f"[{color}]{message}[/{color}]\n")

    use_graphify = (
        action == "use"
        and diag.graphify_installed
        and diag.graphify_graph == "present"
        and not no_graphify
    )
    use_crg = (
        action == "use"
        and diag.crg_installed
        and diag.crg_status == "present"
        and not no_crg
    )

    # ── Step 3: Probe the repo ────────────────────────────────────────────
    with console.status("[blue]Probing repo...[/blue]"):
        probe = probe_repo(
            repo_path,
            task,
            use_graphify=use_graphify,
            use_crg=use_crg,
        )

    _print_probe_summary(probe, not use_graphify, not use_crg)

    # ── Step 4: Generate Work Order ───────────────────────────────────────
    _check_api_key(provider, api_key)

    # Intent stage (clarify) runs BEFORE packaging — decouple "is this ready to
    # scope?" from "scope it". A blocked task can be hard-stopped with
    # --strict-clarify, or generated anyway with its uncertainty recorded.
    clarity_report = None
    if not no_clarify:
        with console.status("[blue]Analyzing task clarity...[/blue]"):
            clarity_report = analyze_clarity_best_effort(task, probe, provider, model, api_key)
        if clarity_report is not None:
            _print_clarity_report(clarity_report)
            if clarity_report.clarification_required and strict_clarify:
                console.print(
                    "[red]Aborting:[/red] task is underspecified and --strict-clarify is set.\n"
                    "Answer the questions above (or rerun without --strict-clarify to "
                    "generate anyway with the uncertainty recorded).\n"
                )
                sys.exit(2)
            if clarity_report.clarification_required:
                console.print(
                    "[yellow]Proceeding despite open questions[/yellow] — they are recorded in "
                    "the Work Order's stop conditions so the executor will halt rather than "
                    "guess.\n"
                )

    enrich = action == "use" and not no_graph_enrichment
    with console.status(f"[blue]Generating Work Order via {provider}...[/blue]"):
        try:
            wo = generate_work_order(
                task=task,
                probe=probe,
                model_provider=provider,
                model=model,
                api_key=api_key,
                enrich_graph=enrich,
                clarity_report=clarity_report,
            )
        except Exception as e:
            console.print(_format_generation_error(e))
            sys.exit(1)

    # ── Step 3: Write output files ────────────────────────────────────────
    with console.status("[blue]Writing output files...[/blue]"):
        out_dir = write_work_order(wo, repo_path)

    # ── Step 5: Print summary ─────────────────────────────────────────────
    _print_work_order_summary(wo, out_dir)


# ── sembl clarify ─────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository (used to ground questions).")
@click.option("--task", "-t", required=True,
              help="The task or request to analyze for underspecification.")
@click.option("--provider", "-p", default="openai",
              type=click.Choice(["openai", "anthropic", "gemini", "nvidia", "openrouter", "tokenrouter", "ollama", "claude-cli"], case_sensitive=False),
              show_default=True, help="LLM provider.")
@click.option("--model", "-m", default=None, help="Model name (provider default if unset).")
@click.option("--api-key", default=None,
              help="API key. Otherwise Sembl reads the selected provider env var.")
@click.option("--json", "as_json", is_flag=True, default=False,
              help="Print the clarity report as JSON (the machine contract).")
def clarify(repo, task, provider, model, api_key, as_json):
    """Judge whether a task is specified well enough to scope — before any code.

    The intent stage: scores underspecification, names the missing information as
    typed questions, and splits safe assumptions from unsafe ones. Exit code is 0
    when ready, 2 when blocked (so it can gate a pipeline).
    """
    repo_path = str(Path(repo).resolve())

    # Cheap, graph-free probe: clarify only needs repo shape to ground questions.
    with console.status("[blue]Probing repo...[/blue]"):
        probe = probe_repo(repo_path, task, use_graphify=False, use_crg=False)

    _check_api_key(provider, api_key)

    with console.status(f"[blue]Analyzing task clarity via {provider}...[/blue]"):
        try:
            report = analyze_clarity(task, probe, provider, model, api_key)
        except Exception as e:
            console.print(_format_generation_error(e))
            sys.exit(1)

    if as_json:
        click.echo(json.dumps(report.to_dict(), indent=2))
    else:
        _print_clarity_report(report, title=True)

    sys.exit(2 if report.clarification_required else 0)


def _print_clarity_report(report, title: bool = False):
    blocked = report.clarification_required
    score_color = {"high": "green", "medium": "yellow", "low": "red"}.get(
        report.intent_confidence, "white")
    status_text = (
        "[bold red]BLOCKED — clarification required[/bold red]" if blocked
        else "[bold green]READY — specified enough to scope[/bold green]"
    )

    lines = [
        status_text,
        "",
        f"[bold]Underspecification:[/bold] {report.underspecification_score:.2f}   "
        f"[bold]Intent confidence:[/bold] [{score_color}]{report.intent_confidence.upper()}[/{score_color}]",
    ]
    if report.ambiguity_tags:
        lines.append(f"[bold]Ambiguity:[/bold] [dim]{', '.join(report.ambiguity_tags)}[/dim]")

    if report.missing_information:
        lines += ["", "[bold]Missing information:[/bold]"]
        for item in report.missing_information:
            flag = "[red](blocking)[/red]" if item.get("blocking") else "[dim](assumable)[/dim]"
            lines.append(f"  [cyan]{item.get('type','?')}[/cyan] {flag}")
            lines.append(f"    {escape(item.get('question',''))}")

    if report.unsafe_assumptions:
        lines += ["", "[bold red]Unsafe to assume (ask first):[/bold red]"]
        lines += [f"  - {escape(a)}" for a in report.unsafe_assumptions]

    if report.safe_assumptions:
        lines += ["", "[bold]Safe to assume (will proceed):[/bold]"]
        lines += [f"  - [dim]{escape(a)}[/dim]" for a in report.safe_assumptions]

    console.print()
    console.print(Panel(
        "\n".join(lines),
        title="[bold blue]Sembl — Intent / Clarify[/bold blue]" if title else "[bold]Task clarity[/bold]",
        border_style="red" if blocked else "green",
    ))
    console.print()


# ── sembl doctor ──────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--json", "as_json", is_flag=True, default=False,
              help="Print the diagnostics as JSON.")
@click.option("--fix", is_flag=True, default=False,
              help="Install missing graph tools. Opt-in: only runs when you pass --fix, and it changes your Python environment.")
@click.option("--graph-age-threshold", default=24.0, show_default=True,
              help="Warn if graph artifacts are older than this (hours).")
def doctor(repo, as_json, fix, graph_age_threshold):
    """Check the graph subsystem: tools, graphs, provider keys, and how to fix gaps."""
    repo_path = str(Path(repo).resolve())
    diag = detect(repo_path, age_threshold_hours=graph_age_threshold)

    if fix and tools_missing(diag):
        _fix_tools()
        diag = detect(repo_path, age_threshold_hours=graph_age_threshold)
    elif fix:
        console.print("[green]Graph tools already installed — nothing to fix.[/green]\n")

    if as_json:
        click.echo(json.dumps(diag.to_dict(), indent=2))
        return

    _render_doctor(diag)


# ── sembl show ────────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--id", "wo_id", default=None,
              help="Work Order ID. Defaults to latest.")
@click.option("--file", "output_file", default="work-order",
              type=click.Choice(["work-order", "executor-prompt", "validation-plan", "graph-impact"]),
              show_default=True, help="Which file to show.")
def show(repo, wo_id, output_file):
    """Show a Work Order. Defaults to the latest one."""
    repo_path = Path(repo).resolve()
    wo_dir = _find_wo_dir(repo_path, wo_id)
    if not wo_dir:
        console.print("[red]No Work Orders found in this repo.[/red]")
        console.print("Run [bold]sembl generate[/bold] to create one.")
        sys.exit(1)

    target = wo_dir / f"{output_file}.md"
    if not target.exists():
        console.print(f"[red]File not found:[/red] {target}")
        sys.exit(1)

    content = target.read_text(encoding="utf-8")
    from rich.markdown import Markdown
    console.print(Markdown(content))


# ── sembl validate ────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository whose working tree should be checked.")
@click.option("--id", "wo_id", default=None,
              help="Work Order ID. Defaults to latest.")
@click.option("--wo-file", "wo_file", default=None,
              type=click.Path(exists=True),
              help="Path to a work-order.json (overrides --id lookup).")
@click.option("--report", "report_file", default=None,
              type=click.Path(exists=True),
              help="Executor report (JSON) to cross-check against the real diff.")
def validate(repo, wo_id, wo_file, report_file):
    """Check the working tree (and an executor report) against a Work Order.

    Never trust executor self-reports: compares what actually changed in git
    against editable_paths/forbidden_areas, and flags claimed-but-unchanged
    files as fabrications.
    """
    import json as _json
    from .validator import validate_against_work_order, load_report

    repo_path = Path(repo).resolve()
    if wo_file:
        wo_json = Path(wo_file)
    else:
        wo_dir = _find_wo_dir(repo_path, wo_id)
        if not wo_dir or not (wo_dir / "work-order.json").exists():
            console.print("[red]No Work Order found.[/red] Use --wo-file or run [bold]sembl generate[/bold].")
            sys.exit(1)
        wo_json = wo_dir / "work-order.json"

    work_order = _json.loads(wo_json.read_text(encoding="utf-8", errors="replace"))
    report = None
    if report_file:
        try:
            report = load_report(report_file)
        except Exception as error:
            console.print(f"[red]Could not parse executor report:[/red] {error}")
            sys.exit(1)

    result = validate_against_work_order(str(repo_path), work_order, report)

    table = Table(show_header=True, header_style="bold")
    table.add_column("Check")
    table.add_column("Result")
    table.add_row("Files changed", str(len(result.changed_files)) or "0")
    table.add_row("In scope", ", ".join(result.in_scope) or "[dim]none[/dim]")
    table.add_row(
        "Forbidden hits",
        f"[red]{', '.join(result.forbidden_hits)}[/red]" if result.forbidden_hits else "[green]none[/green]",
    )
    table.add_row(
        "Out of scope",
        f"[yellow]{', '.join(result.out_of_scope)}[/yellow]" if result.out_of_scope else "[green]none[/green]",
    )
    if report is not None:
        table.add_row(
            "Fabricated claims",
            f"[red]{', '.join(result.fabricated_claims)}[/red]" if result.fabricated_claims else "[green]none[/green]",
        )
        table.add_row(
            "Unreported changes",
            f"[yellow]{', '.join(result.unreported_changes)}[/yellow]" if result.unreported_changes else "[green]none[/green]",
        )

    verdict = "[bold green]PASS[/bold green]" if result.ok else "[bold red]FAIL[/bold red]"
    console.print(Panel(table, title=f"Work Order validation — {verdict}", border_style="green" if result.ok else "red"))
    sys.exit(0 if result.ok else 1)


# ── sembl verify ────────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository whose working tree should be checked.")
@click.option("--id", "wo_id", default=None,
              help="Work Order ID. Defaults to latest.")
@click.option("--wo-file", "wo_file", default=None,
              type=click.Path(exists=True),
              help="Path to a work-order.json (overrides --id lookup).")
@click.option("--report", "report_file", default=None,
              type=click.Path(exists=True),
              help="Executor report (JSON) to cross-check against the real diff.")
@click.option("--diff", "diff_file", default=None,
              type=click.Path(exists=True, allow_dash=True),
              help="A unified diff / .patch to verify instead of the working tree "
                   "(for CI / code review — no checkout needed). Use '-' for stdin.")
@click.option("--staged", is_flag=True, default=False,
              help="Verify the staged change (git index vs HEAD) instead of the "
                   "whole working tree — what a pre-commit hook should gate. "
                   "Mutually exclusive with --diff.")
@click.option("--json", "as_json", is_flag=True, default=False,
              help="Emit the full verdict as JSON (for tooling / experiments).")
@click.option("--strict", is_flag=True, default=False,
              help="Strict gate: out-of-scope edits BLOCK (not just WARN), and any "
                   "WARN becomes a failing exit code. Use in CI for a hard gate.")
def verify(repo, wo_id, wo_file, report_file, diff_file, staged, as_json, strict):
    """Verify the actual diff against a Work Order and return a PASS/WARN/BLOCK verdict.

    The change-control verdict layer: deterministic checks only — scope adherence,
    forbidden-area edits, fabricated success claims, broad churn vs the Work Order's
    size budget, and validation claimed-but-not-evidenced. No maintainability
    judgement. Self-reports are never trusted.

    By default scope is advisory: out-of-scope edits WARN, and only forbidden-area
    edits and fabricated claims BLOCK — auto/loose bounds otherwise cause false
    blocks on legitimate related changes (config, manifests). Pass --strict to make
    out-of-scope a hard BLOCK and fail on any WARN.

    Three change sources: the working tree (default), a patch file (--diff, for
    CI / code review), or the git index (--staged, for pre-commit hooks — gates
    exactly the commit being made).

    Exit codes: PASS=0, WARN=0 (1 with --strict), BLOCK=1.
    """
    import json as _json
    from .validator import validate_against_work_order, load_report, parse_unified_diff

    repo_path = Path(repo).resolve()
    wo_json = _resolve_wo_json(repo_path, wo_id, wo_file)
    if not wo_json or not wo_json.exists():
        console.print(
            "[red]No bounds found.[/red] Pass [bold]--wo-file[/bold], add a "
            "[bold]bounds.json[/bold] at the repo root, or run [bold]sembl generate[/bold]."
        )
        sys.exit(1)

    work_order = _json.loads(wo_json.read_text(encoding="utf-8", errors="replace"))
    report = None
    if report_file:
        try:
            report = load_report(report_file)
        except Exception as error:
            console.print(f"[red]Could not parse executor report:[/red] {error}")
            sys.exit(1)

    # Diff mode (CI / code review): score a patch directly, no working tree needed.
    changed_files = diff_lines = None
    if staged and diff_file:
        console.print("[red]--staged and --diff are mutually exclusive.[/red]")
        sys.exit(1)
    if staged:
        # Pre-commit hooks run against the index: gate exactly the commit being
        # made, not whatever else is sitting in the working tree.
        diff_text = _staged_diff(repo_path)
        if diff_text is None:
            console.print("[red]Could not read the staged diff[/red] "
                          "(is this a git repository?)")
            sys.exit(1)
        changed_files, diff_lines = parse_unified_diff(diff_text)
    elif diff_file:
        diff_text = sys.stdin.read() if diff_file == "-" else Path(diff_file).read_text(
            encoding="utf-8", errors="replace")
        changed_files, diff_lines = parse_unified_diff(diff_text)

    # The work-order file itself is contract, not change: name it so an edit to it
    # (wherever it lives) surfaces as a gate-contract self-edit finding.
    try:
        wo_rel = wo_json.resolve().relative_to(repo_path).as_posix()
    except ValueError:
        wo_rel = None                       # WO outside the repo: unreachable by the diff

    policy = "strict" if strict else "advisory_scope"
    result = validate_against_work_order(
        str(repo_path), work_order, report,
        changed_files=changed_files, diff_line_count=diff_lines,
        contract_paths=[wo_rel] if wo_rel else None,
    )
    verdict = result.verdict(policy)

    if as_json:
        click.echo(_json.dumps(result.to_dict(policy), indent=2))
        sys.exit(_verify_exit_code(verdict, strict))

    style = {"PASS": "green", "WARN": "yellow", "BLOCK": "red"}[verdict]
    table = Table(show_header=True, header_style="bold")
    table.add_column("Check")
    table.add_column("Result")
    table.add_row("Files changed", str(len(result.changed_files)))
    table.add_row(
        "Scope (out of scope)",
        f"[red]{', '.join(result.out_of_scope)}[/red]" if result.out_of_scope else "[green]clean[/green]",
    )
    table.add_row(
        "Forbidden hits",
        f"[red]{', '.join(result.forbidden_hits)}[/red]" if result.forbidden_hits else "[green]none[/green]",
    )
    if result.contract_edits:
        table.add_row("Contract self-edit",
                      f"[red]{', '.join(result.contract_edits)}[/red]")
    if report is not None:
        table.add_row(
            "Fabricated claims",
            f"[red]{', '.join(result.fabricated_claims)}[/red]" if result.fabricated_claims else "[green]none[/green]",
        )
        table.add_row(
            "Validation evidenced",
            f"[yellow]missing: {', '.join(result.validation_not_run)}[/yellow]" if result.validation_not_run else "[green]ok[/green]",
        )
        table.add_row(
            "Unreported changes",
            f"[yellow]{', '.join(result.unreported_changes)}[/yellow]" if result.unreported_changes else "[green]none[/green]",
        )
    if result.churn_over_budget:
        c = result.churn_over_budget
        bits = []
        if "max_files" in c:
            bits.append(f"{c.get('files')} files > {c.get('max_files')}")
        if "max_lines" in c:
            bits.append(f"{c.get('lines')} lines > {c.get('max_lines')}")
        table.add_row("Churn vs budget", f"[yellow]{'; '.join(bits)}[/yellow]")
    else:
        table.add_row("Churn vs budget", "[green]within budget[/green]")

    reasons = result.reasons()
    if reasons:
        table.add_row("Reasons", "\n".join(f"• {r}" for r in reasons))

    console.print(Panel(
        table,
        title=f"sembl verify — [bold {style}]{verdict}[/bold {style}]",
        border_style=style,
    ))
    sys.exit(_verify_exit_code(verdict, strict))


def _staged_diff(repo_path: Path) -> str | None:
    """The staged change (index vs HEAD) as a unified diff; None if git fails.

    `git diff --cached` also works on an unborn branch (it diffs against the
    empty tree), so a repo's very first commit is gated too.
    """
    try:
        proc = subprocess.run(
            ["git", "diff", "--cached", "--no-ext-diff", "--no-color"],
            cwd=str(repo_path), capture_output=True, text=True,
            encoding="utf-8", errors="replace", timeout=30,
        )
    except Exception:
        return None
    return proc.stdout if proc.returncode == 0 else None


def _verify_exit_code(verdict: str, strict: bool) -> int:
    if verdict == "BLOCK":
        return 1
    if verdict == "WARN":
        return 1 if strict else 0
    return 0


# ── sembl bounds ──────────────────────────────────────────────────────────────

@main.command()
@click.option("--from", "preset", default=None,
              help="Adapter preset: spec-kit, kiro, tessl, agents-md, cursor-rules. "
                   "Turns that tool's planning artifacts into a bounds file.")
@click.option("--source", default=None,
              help="Override the preset's source file/glob (repo-relative).")
@click.option("--config", "config_file", default=None,
              type=click.Path(exists=True),
              help="A custom declarative adapter config (JSON, or YAML if PyYAML installed).")
@click.option("--spec-kit", "spec_kit", default=None,
              type=click.Path(exists=True),
              help="Shortcut for --from spec-kit --source <path> (a tasks.md or specs dir).")
@click.option("--repo", "-r", default=".", show_default=True,
              help="Repository root that source globs are resolved against.")
@click.option("--out", "out_file", default=None,
              type=click.Path(),
              help="Write the bounds JSON here. Defaults to stdout.")
def bounds(preset, source, config_file, spec_kit, repo, out_file):
    """Build a Sembl bounds contract from a planning tool's artifacts.

    Declarative adapters turn what an upstream tool already wrote (GitHub Spec
    Kit, Kiro, Tessl, AGENTS.md, Cursor rules — or a custom --config) into the
    four-field bounds JSON that `sembl verify --wo-file` consumes: editable_paths
    pulled from the source, a forbidden_areas list for you to fill, and a grounded
    churn budget. Use the planner to decide what to build; use Sembl to verify the
    agent stayed in those lines.
    """
    from .adapters import bounds_from_preset, build_bounds_from_config, load_config, preset_names

    repo_path = str(Path(repo).resolve())
    title = "sembl bounds"
    try:
        if config_file:
            bounds_dict, used = build_bounds_from_config(load_config(config_file), repo_path)
            title = f"sembl bounds — {Path(config_file).name}"
        elif spec_kit:
            # Use the dedicated resolver: handles a tasks.md file OR a specs dir,
            # relative or absolute, robustly.
            from .speckit import bounds_from_spec_kit
            bounds_dict, source = bounds_from_spec_kit(spec_kit)
            used = [source]
            title = "sembl bounds — spec-kit"
        elif preset:
            bounds_dict, used = bounds_from_preset(preset, repo_path, source=source)
            title = f"sembl bounds — {preset}"
        else:
            console.print(
                "[red]Nothing to build from.[/red] Pass [bold]--from[/bold] "
                f"({', '.join(preset_names())}), [bold]--spec-kit[/bold], or [bold]--config[/bold]."
            )
            sys.exit(1)
    except Exception as error:
        console.print(f"[red]Could not build bounds:[/red] {error}")
        sys.exit(1)

    payload = json.dumps(bounds_dict, indent=2)
    if out_file:
        Path(out_file).write_text(payload + "\n", encoding="utf-8")

    editable = bounds_dict["editable_paths"]
    lines = [f"[dim]Sources read:[/dim] {len(used)}"]
    lines += [f"  [dim]{escape(str(u))}[/dim]" for u in used[:8]]
    if len(used) > 8:
        lines.append(f"  [dim]… and {len(used) - 8} more[/dim]")
    lines.append(f"[bold]Editable paths:[/bold] {len(editable)}")
    lines += [f"  [green]{escape(p)}[/green]" for p in editable[:20]]
    if len(editable) > 20:
        lines.append(f"  [dim]… and {len(editable) - 20} more[/dim]")
    if not editable:
        lines.append("  [yellow]none found — check the source artifacts name file paths, "
                     "or write the bounds by hand[/yellow]")
    lines += [
        "",
        "[bold]forbidden_areas[/bold] is empty — add paths the change must not touch "
        "(migrations, infra, generated code).",
    ]
    if out_file:
        lines.append("")
        lines.append(f"[dim]Wrote:[/dim] {out_file}  →  [bold]sembl verify --wo-file {out_file}[/bold]")
    console.print()
    console.print(Panel("\n".join(lines), title=f"[bold blue]{title}[/bold blue]", border_style="blue"))
    console.print()

    if not out_file:
        click.echo(payload)


# ── sembl list ────────────────────────────────────────────────────────────────

@main.command("list")
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository.")
def list_orders(repo):
    """List all Work Orders in this repo."""
    repo_path = Path(repo).resolve()
    sembl_dir = repo_path / ".sembl" / "work-orders"

    if not sembl_dir.exists():
        console.print("[yellow]No Work Orders found.[/yellow] Run [bold]sembl generate[/bold].")
        return

    # Newest first, by the work-order.json file's own mtime (the dir mtime
    # doesn't move when the contract is regenerated in place).
    dirs = sorted(
        sembl_dir.iterdir(),
        key=lambda d: ((d / "work-order.json").stat().st_mtime
                       if (d / "work-order.json").is_file() else d.stat().st_mtime),
        reverse=True,
    )
    if not dirs:
        console.print("[yellow]No Work Orders found.[/yellow]")
        return

    table = Table(box=box.ROUNDED, border_style="blue", show_header=True)
    table.add_column("Work Order ID", style="bold cyan")
    table.add_column("Task Type", style="green")
    table.add_column("Risk", style="yellow")
    table.add_column("Created", style="dim")
    table.add_column("Goal", style="white")

    for d in dirs:
        json_file = d / "work-order.json"
        if not json_file.exists():
            continue
        try:
            data = json.loads(json_file.read_text(encoding="utf-8"))
            risk = data.get("risk_level", "?").upper()
            risk_style = {"LOW": "green", "MEDIUM": "yellow", "HIGH": "red"}.get(risk, "white")
            table.add_row(
                data.get("id", d.name),
                data.get("task_type", "?"),
                Text(risk, style=risk_style),
                data.get("created_at", "?")[:19].replace("T", " "),
                data.get("clarified_goal", "")[:60] + ("…" if len(data.get("clarified_goal","")) > 60 else ""),
            )
        except Exception:
            table.add_row(d.name, "?", "?", "?", "?")

    console.print()
    console.print(table)
    console.print()


# ── Helpers ──────────────────────────────────────────────────────────────────

def _refresh_graph(repo_path: str, diag):
    """Rebuild Graphify and code-review-graph context, with visible output."""
    root = Path(repo_path)
    console.print("[blue]Refreshing graph context...[/blue]")
    console.print(f"[dim]$ graphify update {root} --no-cluster[/dim]")
    try:
        subprocess.run([diag.graphify_path, "update", str(root), "--no-cluster"], cwd=str(root))
    except Exception as e:  # noqa: BLE001
        console.print(f"[yellow]Graphify refresh failed: {e}[/yellow]")
    console.print("[dim]$ code-review-graph build --skip-flows[/dim]")
    try:
        subprocess.run(
            [diag.crg_path, "build", *_crg_common_args(root), "--skip-flows"],
            cwd=str(root), env=_crg_env(root),
        )
    except Exception as e:  # noqa: BLE001
        console.print(f"[yellow]code-review-graph refresh failed: {e}[/yellow]")
    console.print()


def _graph_unavailable_panel(message: str, diag) -> Panel:
    lines = [f"[red]{message}[/red]", ""]
    cmds = repair_commands(diag)
    if cmds:
        lines.append("[bold]To enable graph context:[/bold]")
        lines += [f"  [cyan]{escape(c)}[/cyan]" for c in cmds]
        lines.append("")
    lines.append("Or rerun with [bold]--graph-mode auto[/bold] for direct-probe fallback, "
                 "or [bold]--graph-mode off[/bold] to skip graph tools.")
    lines.append("Run [bold]sembl doctor[/bold] for the full report.")
    return Panel("\n".join(lines),
                 title="[bold red]Graph context required but unavailable[/bold red]",
                 border_style="red")


def _fix_tools():
    console.print(f"\n[blue]Installing graph tools:[/blue] {escape(INSTALL_HINT)}")
    console.print("[dim]You passed --fix, so this changes your Python environment.[/dim]")
    with console.status("[blue]Installing...[/blue]"):
        ok, out = install_graph_tools()
    if ok:
        console.print("[green]Graph tools installed.[/green]\n")
    else:
        console.print("[red]Install failed.[/red]")
        if out:
            console.print(f"[dim]{out[-600:]}[/dim]")
        console.print(
            f"Try manually: [bold]{escape(INSTALL_HINT)}[/bold]  or  "
            f"[bold]{escape(INSTALL_HINT_UV)}[/bold]\n"
        )


def _render_doctor(diag):
    keys = [p for p, ok in diag.provider_keys.items() if ok]
    env_lines = [
        f"[bold]Sembl[/bold]         {diag.sembl_version}",
        f"[bold]Python[/bold]        {diag.python_version}  [dim]{diag.python_executable}[/dim]",
        "[bold]Provider key[/bold]  " + ("[green]" + ", ".join(keys) + "[/green]" if keys else "[yellow]none set[/yellow]"),
        f"[bold]Repo[/bold]          {diag.repo_path}",
    ]
    console.print()
    console.print(Panel("\n".join(env_lines), title="[bold]Environment[/bold]", border_style="dim"))

    glyph = {"ok": "[green]OK[/green]", "warn": "[yellow]WARN[/yellow]",
             "missing": "[red]MISSING[/red]", "info": "[dim]INFO[/dim]"}
    table = Table(box=box.SIMPLE, show_header=True, padding=(0, 1))
    table.add_column("Check", style="bold")
    table.add_column("Status")
    table.add_column("Detail", style="white", overflow="fold")
    for c in diag.checks:
        table.add_row(c.name, glyph.get(c.status, c.status), c.detail or "")
    console.print(table)

    if diag.graph_available:
        console.print("\n[green]Graph context is available for this repo.[/green]\n")
    else:
        console.print("\n[yellow]Graph context is NOT available - auto mode will fall back to direct probing.[/yellow]")
        cmds = repair_commands(diag)
        if cmds:
            lines = ["[bold]Fix it with:[/bold]"]
            lines += [f"  [cyan]{escape(c)}[/cyan]" for c in cmds]
            if tools_missing(diag):
                lines += ["", "Shortcut: [bold]sembl doctor --fix[/bold] installs the tools for you."]
            console.print(Panel("\n".join(lines), border_style="dim"))
        console.print()


def _print_probe_summary(probe, skip_graphify: bool, skip_crg: bool):
    table = Table(box=box.SIMPLE, show_header=False, padding=(0, 1))
    table.add_column("Key", style="dim")
    table.add_column("Value", style="white")

    table.add_row("Project", probe.project_name or "unknown")
    table.add_row("Type", probe.project_type or "unknown")
    table.add_row("Languages", ", ".join(probe.primary_languages) or "unknown")
    table.add_row("Frameworks", ", ".join(probe.framework_hints) or "none detected")
    table.add_row("Branch", probe.git_branch or "unknown")
    table.add_row("Dirty", "yes" if probe.git_is_dirty else "no")
    table.add_row("Context basis", "graph pipeline" if probe.context_basis == "graph_pipeline" else "direct fallback")
    if probe.graph_context_sources:
        table.add_row("Graph sources", ", ".join(probe.graph_context_sources))

    gstatus = "available" if probe.graphify_available else ("skipped" if skip_graphify else "not found")
    cstatus = "available" if probe.crg_available else ("skipped" if skip_crg else "not found")
    table.add_row("Graphify", f"[green]{gstatus}[/green]" if probe.graphify_available else f"[dim]{gstatus}[/dim]")
    table.add_row("code-review-graph", f"[green]{cstatus}[/green]" if probe.crg_available else f"[dim]{cstatus}[/dim]")

    if probe.crg_available and probe.crg_node_count:
        table.add_row("CRG graph", f"{probe.crg_node_count:,} nodes · {probe.crg_edge_count:,} edges")
    if probe.crg_blast_radius:
        table.add_row("CRG impact summaries", str(len(probe.crg_blast_radius)))

    console.print(Panel(table, title="[bold]Repo probe[/bold]", border_style="dim"))
    console.print()


def _print_work_order_summary(wo, out_dir: Path):
    risk_color = {"low": "green", "medium": "yellow", "high": "red"}.get(wo.risk_level, "white")

    lines = [
        f"[bold]{wo.id}[/bold]",
        f"",
        f"[bold]Goal:[/bold] {wo.clarified_goal}",
        f"[bold]Outcome:[/bold] {wo.user_visible_outcome}",
        f"[bold]Task type:[/bold] {wo.task_type}  |  "
        f"[bold]Risk:[/bold] [{risk_color}]{wo.risk_level.upper()}[/{risk_color}]"
        + (f"  |  [bold]Intent:[/bold] [yellow]{wo.intent_confidence.upper()} "
           f"({len(wo.blocked_until_answered)} open Q)[/yellow]"
           if wo.clarification_required else ""),
        f"",
        f"[bold]Acceptance criteria:[/bold] {len(wo.acceptance_criteria)} items",
        f"[bold]Validation commands:[/bold] {len(wo.validation_commands)} commands",
        f"[bold]Stop conditions:[/bold] {len(wo.stop_conditions)} triggers",
        f"",
        f"[dim]Output:[/dim] {out_dir}",
        f"",
        f"  work-order.md       — read this",
        f"  executor-prompt.md  — paste into your agent",
        f"  validation-plan.md  — run this after",
        f"  work-order.json     — machine-readable",
    ]
    if wo.graph_impact_analysis:
        lines.append(f"  graph-impact.md     — LLM synthesis of graph blast radius")

    console.print(Panel(
        "\n".join(lines),
        title="[bold green]Work Order generated[/bold green]",
        border_style="green"
    ))
    console.print()


def _find_wo_dir(repo_path: Path, wo_id: str | None) -> Path | None:
    sembl_dir = repo_path / ".sembl" / "work-orders"
    if not sembl_dir.exists():
        return None
    if wo_id:
        target = sembl_dir / wo_id
        return target if target.exists() else None
    # Latest — judged by the work-order.json file's own mtime, not the dir's:
    # rewriting a file inside an existing slug dir doesn't bump the dir timestamp.
    dirs = [d for d in sembl_dir.iterdir() if d.is_dir()]
    with_wo = [d for d in dirs if (d / "work-order.json").is_file()]
    if with_wo:
        return max(with_wo, key=lambda d: (d / "work-order.json").stat().st_mtime)
    return max(dirs, key=lambda d: d.stat().st_mtime) if dirs else None


def _resolve_wo_json(repo_path: Path, wo_id: str | None, wo_file: str | None) -> Path | None:
    """Find the bounds/Work-Order JSON to verify against.

    Resolution order, so hooks and CI can run zero-arg when a bounds file is
    present: explicit --wo-file, then the latest generated Work Order, then a
    conventional bounds file (`bounds.json`, then `.sembl/bounds.json`).
    """
    if wo_file:
        return Path(wo_file)
    wo_dir = _find_wo_dir(repo_path, wo_id)
    if wo_dir and (wo_dir / "work-order.json").exists():
        return wo_dir / "work-order.json"
    for cand in (repo_path / "bounds.json", repo_path / ".sembl" / "bounds.json"):
        if cand.exists():
            return cand
    return None


def _check_api_key(provider: str, api_key: str | None):
    # Local providers need no API key.
    provider_key = provider.lower()
    if provider_key in ("ollama", "claude-cli"):
        return  # no API key: local inference / subscription-authenticated CLI
    provider_names = {
        "openai": "OpenAI",
        "anthropic": "Anthropic",
        "gemini": "Gemini",
        "nvidia": "NVIDIA",
        "openrouter": "OpenRouter",
        "tokenrouter": "TokenRouter",
    }
    env_keys = {
        "openai": "OPENAI_API_KEY",
        "anthropic": "ANTHROPIC_API_KEY",
        "gemini": "GEMINI_API_KEY",
        "nvidia": "NVIDIA_API_KEY",
        "openrouter": "OPENROUTER_API_KEY",
        "tokenrouter": "TOKENROUTER_API_KEY",
    }
    env_key = env_keys[provider_key]
    if not api_key and not os.environ.get(env_key):
        provider_name = provider_names.get(provider_key, provider)
        console.print(f"\n[red]No {provider_name} API key is set.[/red]")
        console.print(
            f"Set [bold]{env_key}[/bold] in your shell or rerun with "
            "[bold]--api-key[/bold]."
        )
        console.print(f"PowerShell: [bold]$env:{env_key}=\"...\"[/bold]")
        console.print(
            "For local generation without a provider key, rerun with "
            "[bold]--provider ollama[/bold].\n"
        )
        sys.exit(1)


def _format_generation_error(error: Exception) -> str:
    message = str(error)
    provider = getattr(error, "provider", None)
    code = getattr(error, "code", None)
    status_code = getattr(error, "status_code", None)
    lower_message = message.lower()

    if provider == "gemini":
        return _format_gemini_error(message, status_code, code)
    if provider == "nvidia":
        return _format_nvidia_error(message, status_code, code)

    if code == "insufficient_quota" or "insufficient_quota" in lower_message:
        return (
            "\n[red]Generation failed:[/red] OpenAI quota is exhausted for this API project/org.\n\n"
            "The request reached OpenAI, but the API account has no available quota or has hit a spend limit.\n"
            "Check billing: https://platform.openai.com/settings/organization/billing\n"
            "Check limits:  https://platform.openai.com/settings/organization/limits\n\n"
            "ChatGPT subscriptions and OpenAI API billing are separate. After adding credits or raising the limit, "
            "rerun the same Sembl command.\n"
        )

    if status_code == 401 or code == "invalid_api_key" or "invalid_api_key" in lower_message:
        return (
            "\n[red]Generation failed:[/red] OpenAI rejected the API key.\n\n"
            "Set a valid OPENAI_API_KEY for the selected project, then rerun the same Sembl command.\n"
        )

    if "rate_limit" in lower_message or code == "rate_limit_exceeded":
        return (
            "\n[red]Generation failed:[/red] OpenAI rate limit reached.\n\n"
            "Wait briefly, reduce concurrency, or use a lower-throughput model/project before retrying.\n"
        )

    if status_code == 403 or "permission" in lower_message or "model_not_found" in lower_message:
        return (
            "\n[red]Generation failed:[/red] The API key does not have access to the requested model or project.\n\n"
            "Check the model name, project, organization, and key scope, then rerun the command.\n"
        )

    return f"\n[red]Generation failed:[/red] {message}"


def _format_gemini_error(message: str, status_code: int | None, code: str | None) -> str:
    code_text = str(code or "").upper()
    lower_message = message.lower()

    if status_code == 400 or code_text == "INVALID_ARGUMENT":
        return (
            "\n[red]Generation failed:[/red] Gemini rejected the request.\n\n"
            f"{message}\n\n"
            "Check the model name and request shape, then rerun the same Sembl command.\n"
        )

    if status_code == 401 or status_code == 403 or code_text in {"UNAUTHENTICATED", "PERMISSION_DENIED"}:
        return (
            "\n[red]Generation failed:[/red] Gemini rejected the API key or project access.\n\n"
            "Set a valid GEMINI_API_KEY with access to the selected model, then rerun the same Sembl command.\n"
        )

    if status_code == 429 or code_text == "RESOURCE_EXHAUSTED" or "quota" in lower_message:
        return (
            "\n[red]Generation failed:[/red] Gemini quota or rate limit reached.\n\n"
            "Wait briefly, lower the request volume, or check the Google AI Studio / Google Cloud quota for this key.\n"
        )

    if status_code == 404 or "not found" in lower_message:
        return (
            "\n[red]Generation failed:[/red] Gemini model was not found or is unavailable for this API key.\n\n"
            "Try --model gemini-2.5-flash, then rerun the same Sembl command.\n"
        )

    return f"\n[red]Generation failed:[/red] Gemini API error: {message}"


def _format_nvidia_error(message: str, status_code: int | None, code: str | None) -> str:
    lower_message = message.lower()

    if status_code == 401 or status_code == 403 or "unauthorized" in lower_message:
        return (
            "\n[red]Generation failed:[/red] NVIDIA rejected the API key or model access.\n\n"
            "Set a valid NVIDIA_API_KEY with access to the selected model, then rerun the same Sembl command.\n"
        )

    if status_code == 429 or "rate" in lower_message or "quota" in lower_message:
        return (
            "\n[red]Generation failed:[/red] NVIDIA quota or rate limit reached.\n\n"
            "Wait briefly, choose another available NVIDIA model, or check the key limits in the NVIDIA API catalog.\n"
        )

    if status_code == 404 or "model" in lower_message and "not found" in lower_message:
        return (
            "\n[red]Generation failed:[/red] NVIDIA model was not found or is unavailable for this key.\n\n"
            "Try --model mistralai/mistral-medium-3.5-128b or another model shown in the NVIDIA catalog.\n"
        )

    if "invalid json" in lower_message or "llm returned invalid json" in lower_message:
        return (
            "\n[red]Generation failed:[/red] NVIDIA returned text that was not valid Work Order JSON.\n\n"
            "Retry once, or try a stronger instruction-following model from the NVIDIA catalog.\n"
        )

    return f"\n[red]Generation failed:[/red] NVIDIA API error: {message}"


if __name__ == "__main__":
    main()
