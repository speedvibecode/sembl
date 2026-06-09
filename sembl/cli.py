"""
cli.py

Sembl CLI — the first machine.

Commands:
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

from .repo_probe import probe_repo, _crg_common_args, _crg_env
from .generator import generate_work_order
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
@click.version_option("0.1.5", prog_name="sembl")
def main():
    """Sembl — turn messy repo intent into scoped AI Work Orders."""
    pass


# ── sembl generate ────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo",     "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--task",     "-t", required=True,
              help="The task or request to turn into a Work Order.")
@click.option("--provider", "-p", default="openai",
              type=click.Choice(["openai", "anthropic", "gemini", "nvidia", "openrouter", "ollama"], case_sensitive=False),
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
def generate(repo, task, provider, model, api_key, graph_mode, refresh_graph,
             require_graph_context, no_graphify, no_crg, no_graph_enrichment):
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
    diag = detect(repo_path)

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
            diag = detect(repo_path)  # re-read after rebuilding

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
            )
        except Exception as e:
            console.print(_format_generation_error(e))
            sys.exit(1)

    # ── Step 3: Write output files ────────────────────────────────────────
    with console.status("[blue]Writing output files...[/blue]"):
        out_dir = write_work_order(wo, repo_path)

    # ── Step 5: Print summary ─────────────────────────────────────────────
    _print_work_order_summary(wo, out_dir)


# ── sembl doctor ──────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--json", "as_json", is_flag=True, default=False,
              help="Print the diagnostics as JSON.")
@click.option("--fix", is_flag=True, default=False,
              help="Install missing graph tools. Opt-in: only runs when you pass --fix, and it changes your Python environment.")
def doctor(repo, as_json, fix):
    """Check the graph subsystem: tools, graphs, provider keys, and how to fix gaps."""
    repo_path = str(Path(repo).resolve())
    diag = detect(repo_path)

    if fix and tools_missing(diag):
        _fix_tools()
        diag = detect(repo_path)
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

    dirs = sorted(sembl_dir.iterdir(), key=lambda d: d.stat().st_mtime, reverse=True)
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
        f"[bold]Risk:[/bold] [{risk_color}]{wo.risk_level.upper()}[/{risk_color}]",
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
    # Latest
    dirs = sorted(sembl_dir.iterdir(), key=lambda d: d.stat().st_mtime, reverse=True)
    return dirs[0] if dirs else None


def _check_api_key(provider: str, api_key: str | None):
    # Local providers need no API key.
    if provider.lower() == "ollama":
        return
    env_keys = {
        "openai": "OPENAI_API_KEY",
        "anthropic": "ANTHROPIC_API_KEY",
        "gemini": "GEMINI_API_KEY",
        "nvidia": "NVIDIA_API_KEY",
        "openrouter": "OPENROUTER_API_KEY",
    }
    env_key = env_keys[provider.lower()]
    if not api_key and not os.environ.get(env_key):
        console.print(f"\n[red]No API key found.[/red]")
        console.print(f"Set [bold]{env_key}[/bold] or pass [bold]--api-key[/bold].\n")
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
