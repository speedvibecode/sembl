"""
cli.py

Sembl CLI — the first machine.

Commands:
  sembl generate  — repo + task → Work Order
  sembl show      — display the latest Work Order
  sembl list      — list all Work Orders in this repo
"""

import os
import json
import sys
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich import box

from .repo_probe import probe_repo
from .generator import generate_work_order
from .output import write_work_order

console = Console()


@click.group()
@click.version_option("0.1.0", prog_name="sembl")
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
              type=click.Choice(["openai", "anthropic", "gemini", "nvidia"], case_sensitive=False),
              show_default=True, help="LLM provider.")
@click.option("--model",    "-m", default=None,
              help="Model name. Defaults to gpt-4o (openai), claude-sonnet-4-6 (anthropic), gemini-2.5-flash (gemini), or mistralai/mistral-medium-3.5-128b (nvidia).")
@click.option("--api-key",  default=None,
              help="API key. Otherwise Sembl reads the selected provider env var.")
@click.option("--no-graphify", is_flag=True, default=False,
              help="Skip graphify even if available.")
@click.option("--no-crg",      is_flag=True, default=False,
              help="Skip code-review-graph even if available.")
@click.option("--require-graph-context", is_flag=True, default=False,
              help="Fail instead of using direct-probe fallback when graphify/CRG context is unavailable.")
def generate(repo, task, provider, model, api_key, no_graphify, no_crg, require_graph_context):
    """Generate a Work Order from a repo and a task description."""

    repo_path = str(Path(repo).resolve())

    # ── Step 1: Probe the repo ────────────────────────────────────────────
    console.print()
    console.print(Panel(
        f"[bold]Task:[/bold] {task}",
        title="[bold blue]Sembl — Work Order Generator[/bold blue]",
        border_style="blue"
    ))
    console.print()

    with console.status("[blue]Probing repo...[/blue]"):
        probe = probe_repo(
            repo_path,
            task,
            use_graphify=not no_graphify,
            use_crg=not no_crg,
        )

    _print_probe_summary(probe, no_graphify, no_crg)
    if require_graph_context and probe.context_basis != "graph_pipeline":
        console.print(
            "\n[red]Graph context required but unavailable.[/red]\n"
            "Run graphify/code-review-graph for this repo, check PATH/venv resolution, "
            "or rerun without [bold]--require-graph-context[/bold] to allow direct-probe fallback.\n"
        )
        sys.exit(1)

    # ── Step 2: Generate Work Order ───────────────────────────────────────
    _check_api_key(provider, api_key)

    with console.status(f"[blue]Generating Work Order via {provider}...[/blue]"):
        try:
            wo = generate_work_order(
                task=task,
                probe=probe,
                model_provider=provider,
                model=model,
                api_key=api_key,
            )
        except Exception as e:
            console.print(_format_generation_error(e))
            sys.exit(1)

    # ── Step 3: Write output files ────────────────────────────────────────
    with console.status("[blue]Writing output files...[/blue]"):
        out_dir = write_work_order(wo, repo_path)

    # ── Step 4: Print summary ─────────────────────────────────────────────
    _print_work_order_summary(wo, out_dir)


# ── sembl show ────────────────────────────────────────────────────────────────

@main.command()
@click.option("--repo", "-r", default=".", show_default=True,
              help="Path to the repository.")
@click.option("--id", "wo_id", default=None,
              help="Work Order ID. Defaults to latest.")
@click.option("--file", "output_file", default="work-order",
              type=click.Choice(["work-order", "executor-prompt", "validation-plan"]),
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
    env_keys = {
        "openai": "OPENAI_API_KEY",
        "anthropic": "ANTHROPIC_API_KEY",
        "gemini": "GEMINI_API_KEY",
        "nvidia": "NVIDIA_API_KEY",
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
