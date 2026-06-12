"""
generator.py

Takes a RepoProbe and a task description.
Calls an LLM (OpenAI, Anthropic, Gemini, or NVIDIA NIM) to generate the 8-lock Work Order.

The Work Order schema is our design — not borrowed from any other tool.
"""

import json
import os
import re
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from .repo_probe import RepoProbe


class ProviderAPIError(RuntimeError):
    """Normalized provider error for CLI-friendly reporting."""

    def __init__(
        self,
        message: str,
        *,
        provider: str,
        status_code: int | None = None,
        code: str | None = None,
    ):
        super().__init__(message)
        self.provider = provider
        self.status_code = status_code
        self.code = code


@dataclass
class WorkOrder:
    """
    The core Sembl object. An execution contract for AI software work.
    Built from 8 locks, derived from the Sembl schema design.
    """

    # Identity
    id: str = ""
    created_at: str = ""
    schema_version: str = "0.1.0"
    repo_path: str = ""
    repo_name: str = ""
    git_branch: str = ""
    git_head_commit: str = ""

    # Lock 1 — Intent
    original_request: str = ""
    clarified_goal: str = ""
    user_visible_outcome: str = ""
    task_type: str = ""

    # Lock 2 — Boundary
    non_goals: list = field(default_factory=list)
    must_not_change: list = field(default_factory=list)
    forbidden_areas: list = field(default_factory=list)

    # Lock 3 — Scope
    likely_affected_areas: list = field(default_factory=list)
    editable_paths: list = field(default_factory=list)
    read_only_context: list = field(default_factory=list)

    # Lock 4 — Context
    files_to_inspect: list = field(default_factory=list)
    project_rules: list = field(default_factory=list)
    tests_to_inspect: list = field(default_factory=list)
    architecture_notes: list = field(default_factory=list)

    # Lock 5 — Success
    acceptance_criteria: list = field(default_factory=list)
    regressions_to_preserve: list = field(default_factory=list)

    # Lock 6 — Proof
    validation_commands: list = field(default_factory=list)
    tests_to_add_or_update: list = field(default_factory=list)
    manual_checks: list = field(default_factory=list)

    # Lock 7 — Safety
    stop_conditions: list = field(default_factory=list)
    approval_triggers: list = field(default_factory=list)
    risk_level: str = "medium"
    risk_reasons: list = field(default_factory=list)

    # Lock 8 — Executor Packet
    executor_prompt: str = ""
    patch_expectations: list = field(default_factory=list)
    reporting_format: str = ""

    # Graph intelligence — LLM synthesis over code-review-graph structural output
    graph_impact_analysis: str = ""

    # Reconciliation (filled post-execution)
    reconciliation: dict = field(default_factory=lambda: {
        "status": "pending",
        "summary": "",
        "files_changed": [],
        "validation_results": [],
        "human_decision": "",
        "override_reason": "",
        "memory_updates": []
    })


TASK_TYPES = [
    "bugfix", "feature", "refactor", "test",
    "docs", "dependency", "migration", "security",
    "performance", "cleanup", "api-change", "ui-change", "infra"
]


IGNORED_REPO_PATH_PARTS = {
    ".git",
    ".crg-data",
    ".crg-home",
    ".expo",
    ".mypy_cache",
    ".next",
    ".pytest_cache",
    ".ruff_cache",
    ".sembl",
    ".turbo",
    ".uv-cache",
    ".venv",
    "__pycache__",
    "build",
    "coverage",
    "dist",
    "graphify-out",
    "htmlcov",
    "node_modules",
    "site-packages",
    "venv",
    "web-build",
}
IGNORED_REPO_PATH_GLOBS = {
    "*.egg-info",
    "*.pyc",
    "*.pyo",
}


def generate_work_order(
    task: str,
    probe: RepoProbe,
    model_provider: str = "openai",
    model: Optional[str] = None,
    api_key: Optional[str] = None,
    enrich_graph: bool = True,
) -> WorkOrder:
    """
    Main entry point. Generates a Work Order from task + probe data.
    Calls LLM to produce the 8 locks, then assembles the WorkOrder object.

    When `enrich_graph` is set and code-review-graph structural context is
    available, an LLM pre-pass first synthesizes that raw graph output into a
    semantic impact analysis, which then grounds the main generation.
    """
    wo = WorkOrder()
    wo.id = _generate_id(task, probe.project_name)
    wo.created_at = datetime.now(timezone.utc).isoformat()
    wo.repo_path = probe.repo_path
    wo.repo_name = probe.project_name
    wo.git_branch = probe.git_branch
    wo.git_head_commit = probe.git_head_commit
    wo.original_request = task
    wo.project_rules = probe.project_rules

    # Optional LLM pre-pass: reason over the structural graph before generating.
    if enrich_graph:
        wo.graph_impact_analysis = synthesize_graph_impact(
            task, probe, model_provider, model, api_key
        )

    # Build the generation prompt
    system_prompt = _build_system_prompt()
    user_prompt = _build_user_prompt(task, probe, wo.graph_impact_analysis)

    # Call the LLM
    raw = _call_llm(system_prompt, user_prompt, model_provider, model, api_key)

    # Parse the structured JSON response into the WorkOrder
    _parse_llm_response(raw, wo, probe)
    _ground_work_order_in_repo(wo, probe)

    return wo


# ── Graph impact synthesis (LLM pre-pass over code-review-graph) ───────────────

def _should_enrich(probe: RepoProbe) -> bool:
    """Only worth an extra LLM call when there is real structural graph signal.

    code-review-graph supplies the deterministic structure (blast radius, node
    and edge counts). graphify's task context, if present, is folded in as
    supporting detail. With neither, there is nothing to synthesize.
    """
    has_crg_signal = bool(
        probe.crg_blast_radius or probe.crg_node_count or probe.crg_edge_count
    )
    return has_crg_signal or bool(probe.graphify_task_context)


def synthesize_graph_impact(
    task: str,
    probe: RepoProbe,
    provider: str = "openai",
    model: Optional[str] = None,
    api_key: Optional[str] = None,
) -> str:
    """
    LLM pre-pass that turns code-review-graph's terse structural output into a
    concise, grounded impact analysis for the task at hand.

    Returns markdown text, or "" when there is nothing to synthesize or the call
    fails. This step is best-effort and must never block Work Order generation.
    """
    if not _should_enrich(probe):
        return ""

    try:
        raw = _call_llm(
            _build_impact_system_prompt(),
            _build_impact_user_prompt(task, probe),
            provider,
            model,
            api_key,
        )
    except Exception:
        return ""

    return (raw or "").strip()


def _build_impact_system_prompt() -> str:
    return (
        "You are the graph-analysis stage of Sembl. You receive structural output "
        "from code-review-graph (a code dependency/impact graph) plus optional "
        "graphify context, and turn it into a short, concrete impact analysis that a "
        "later stage will use to scope an AI coding Work Order.\n\n"
        "Produce concise Markdown with exactly these sections:\n"
        "- **Blast radius**: what the change is structurally likely to touch, in plain terms.\n"
        "- **Likely edit targets**: specific files/modules the task probably changes.\n"
        "- **Hidden coupling / risk**: non-obvious dependents, shared state, or cross-module links.\n"
        "- **Keep read-only**: files that are relevant context but should not be modified.\n\n"
        "Rules:\n"
        "- Ground every claim strictly in the provided graph data. Never invent file names.\n"
        "- If the data is thin or absent for a section, say so plainly rather than guessing.\n"
        "- Be terse and specific. No preamble, no restating the task. Under 250 words."
    )


def _build_impact_user_prompt(task: str, probe: RepoProbe) -> str:
    sections = [f"TASK:\n{task}"]

    if probe.crg_available:
        sections.append(
            "CODE-REVIEW-GRAPH — STRUCTURAL STATS:\n"
            f"Nodes: {probe.crg_node_count} | Edges: {probe.crg_edge_count}\n"
            f"Languages: {', '.join(probe.crg_languages) or 'unknown'}"
        )
    if probe.crg_blast_radius:
        sections.append(
            "CODE-REVIEW-GRAPH — IMPACT SUMMARY (raw):\n"
            + "\n\n".join(probe.crg_blast_radius)
        )
    if probe.graphify_task_context:
        sections.append(
            "GRAPHIFY — TASK-SPECIFIC SCOPE CONTEXT:\n" + probe.graphify_task_context
        )
    if probe.graphify_communities:
        sections.append("GRAPHIFY — CODE COMMUNITIES:\n" + probe.graphify_communities)

    sections.append(
        "DIRECT REPO METADATA (secondary):\n"
        f"Name: {probe.project_name}\n"
        f"Type: {probe.project_type}\n"
        f"Top-level dirs: {', '.join(probe.top_level_dirs[:20])}"
    )

    return "\n\n---\n\n".join(sections)


# ── Prompt construction ───────────────────────────────────────────────────────

def _build_system_prompt() -> str:
    task_type_list = "\n".join(f"- {t}" for t in TASK_TYPES)
    return f"""You are Sembl — a system that turns messy developer intent into precise AI Work Orders.

A Work Order is an execution contract. It is not a prompt. It tells an AI coding agent exactly:
- what the goal is (and what it is not)
- which files it can touch
- which files it must never touch
- what must be true when it finishes
- how to prove it succeeded
- when to stop and ask a human

Your job is to generate a Work Order in structured JSON.

Task type taxonomy:
{task_type_list}

Risk levels: low | medium | high
- low: docs, tests only, isolated UI copy
- medium: normal feature, small backend change, local refactor
- high: auth, payments, DB schema, migrations, public API, security, cross-module refactor, infra

Output ONLY valid JSON matching this exact schema. No markdown, no explanation, no preamble.

{{
  "clarified_goal": "single precise sentence, actionable, scoped",
  "user_visible_outcome": "what a user would observe if this succeeds",
  "task_type": "one of the task types above",
  "non_goals": ["list of things not to build or change"],
  "must_not_change": ["behaviours that must remain identical after this change"],
  "forbidden_areas": ["named modules/dirs agent must not touch"],
  "likely_affected_areas": ["modules/dirs likely affected"],
  "editable_paths": ["specific files or dirs the agent MAY edit"],
  "read_only_context": ["files useful for context but not to be modified"],
  "files_to_inspect": ["files the agent must read before starting"],
  "tests_to_inspect": ["test files covering affected areas"],
  "architecture_notes": ["key constraints from the project structure to respect"],
  "acceptance_criteria": ["testable statements that must be true on completion"],
  "regressions_to_preserve": ["existing behaviours that must not break"],
  "validation_commands": ["exact shell commands to validate the change"],
  "tests_to_add_or_update": ["specific test files or cases to create/update"],
  "manual_checks": ["things a human must verify that automation cannot prove"],
  "stop_conditions": [
    "conditions where agent must stop and ask human rather than proceed"
  ],
  "approval_triggers": ["conditions that block merge and require human approval"],
  "risk_level": "low | medium | high",
  "risk_reasons": ["specific factors that determine the risk level"],
  "executor_prompt": "complete, agent-ready prompt incorporating all locks above",
  "patch_expectations": ["what the output diff/PR should contain"],
  "reporting_format": "how the agent should report its work when done"
}}

The executor_prompt must be complete and self-contained. It should include: the goal, non-goals,
editable files, forbidden areas, acceptance criteria, stop conditions, and patch expectations.
An agent receiving only the executor_prompt should be able to execute the Work Order correctly.

Be precise. Be specific to this repo and task. Do not be generic.
If graphify or code-review-graph context is present, treat it as the primary source of truth for
repo scope, likely files, dependencies, and risk. Use direct repo probes only as secondary metadata.
If graph context conflicts with direct probes, prefer graph context unless it is obviously stale.
If no graph context is present, say so implicitly by producing a conservative, lower-specificity Work Order.
If the probe data reveals project rules or architecture patterns, respect them."""


def _build_user_prompt(task: str, probe: RepoProbe, graph_impact: str = "") -> str:
    sections = [f"TASK:\n{task}\n"]

    graph_sources = ", ".join(probe.graph_context_sources) or "none"
    if probe.context_basis == "graph_pipeline":
        sections.append(
            "CONTEXT BASIS:\n"
            "Primary: graphify/code-review-graph pipeline.\n"
            f"Graph sources: {graph_sources}\n"
            "Instruction: base likely affected areas, editable paths, files to inspect, tests, "
            "risk reasons, and stop conditions on graph-derived context first. Treat direct repo "
            "metadata as secondary."
        )
    else:
        sections.append(
            "CONTEXT BASIS:\n"
            "Primary graph context unavailable. This is a direct-probe fallback; be conservative "
            "and avoid pretending to know exact files that were not identified."
        )

    if graph_impact:
        sections.append(
            "GRAPH IMPACT ANALYSIS (LLM synthesis of code-review-graph output):\n"
            "Treat this as primary guidance for scope, editable paths, read-only context, "
            "and risk. It is already grounded in the structural graph.\n\n"
            + graph_impact
        )

    if probe.graphify_task_context:
        sections.append(f"GRAPHIFY — TASK-SPECIFIC SCOPE CONTEXT:\n{probe.graphify_task_context}")

    if probe.graphify_available and probe.graphify_summary:
        sections.append(f"GRAPHIFY — PROJECT UNDERSTANDING:\n{probe.graphify_summary}")
    if probe.graphify_communities:
        sections.append(f"GRAPHIFY — CODE COMMUNITIES:\n{probe.graphify_communities}")

    if probe.crg_available:
        sections.append(
            f"CODE-REVIEW-GRAPH — STRUCTURAL STATS:\n"
            f"Nodes: {probe.crg_node_count} | Edges: {probe.crg_edge_count}\n"
            f"Languages: {', '.join(probe.crg_languages)}"
        )
    if probe.crg_blast_radius:
        sections.append(
            f"CODE-REVIEW-GRAPH — IMPACT SUMMARY FOR THIS TASK:\n"
            + "\n\n".join(probe.crg_blast_radius)
        )

    sections.append(f"DIRECT REPO METADATA (secondary):\n"
                    f"Name: {probe.project_name}\n"
                    f"Type: {probe.project_type}\n"
                    f"Languages: {', '.join(probe.primary_languages) or 'unknown'}\n"
                    f"Frameworks: {', '.join(probe.framework_hints) or 'none detected'}\n"
                    f"Branch: {probe.git_branch or 'unknown'}\n"
                    f"Dirty: {probe.git_is_dirty}\n"
                    f"Top-level dirs: {', '.join(probe.top_level_dirs[:20])}")

    if probe.readme_summary:
        sections.append(f"README (secondary, first 1200 chars):\n{probe.readme_summary}")

    if probe.project_rules:
        sections.append(f"PROJECT RULES:\n" + "\n\n".join(probe.project_rules))

    cmds = []
    if probe.test_commands: cmds.append(f"Test: {', '.join(probe.test_commands)}")
    if probe.lint_commands:  cmds.append(f"Lint: {', '.join(probe.lint_commands)}")
    if probe.build_commands: cmds.append(f"Build: {', '.join(probe.build_commands)}")
    if cmds: sections.append("KNOWN COMMANDS:\n" + "\n".join(cmds))

    return "\n\n---\n\n".join(sections)


# ── LLM call ─────────────────────────────────────────────────────────────────

def _call_llm(
    system_prompt: str,
    user_prompt: str,
    provider: str,
    model: Optional[str],
    api_key: Optional[str],
) -> str:
    provider = provider.lower()
    if provider == "anthropic":
        return _call_anthropic(system_prompt, user_prompt, model, api_key)
    if provider == "gemini":
        return _call_gemini(system_prompt, user_prompt, model, api_key)
    if provider == "nvidia":
        return _call_nvidia(system_prompt, user_prompt, model, api_key)
    if provider == "openrouter":
        return _call_openrouter(system_prompt, user_prompt, model, api_key)
    if provider == "ollama":
        return _call_ollama(system_prompt, user_prompt, model, api_key)
    if provider == "openai":
        return _call_openai(system_prompt, user_prompt, model, api_key)
    raise ValueError(f"Unsupported provider: {provider}")


def _call_openai(system_prompt, user_prompt, model, api_key) -> str:
    from openai import OpenAI
    key = api_key or os.environ.get("OPENAI_API_KEY")
    if not key:
        raise ValueError("No OpenAI API key. Set OPENAI_API_KEY or pass --api-key.")
    client = OpenAI(api_key=key)
    m = model or "gpt-4o"
    response = client.chat.completions.create(
        model=m,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0.2,
        max_tokens=8192,
        response_format={"type": "json_object"},
    )
    return response.choices[0].message.content


def _call_anthropic(system_prompt, user_prompt, model, api_key) -> str:
    import anthropic
    key = api_key or os.environ.get("ANTHROPIC_API_KEY")
    if not key:
        raise ValueError("No Anthropic API key. Set ANTHROPIC_API_KEY or pass --api-key.")
    client = anthropic.Anthropic(api_key=key)
    m = model or "claude-sonnet-4-6"
    response = client.messages.create(
        model=m,
        max_tokens=8192,
        system=system_prompt,
        messages=[{"role": "user", "content": user_prompt}],
        temperature=0.2,
    )
    return response.content[0].text


def _call_gemini(system_prompt, user_prompt, model, api_key) -> str:
    key = api_key or os.environ.get("GEMINI_API_KEY")
    if not key:
        raise ValueError("No Gemini API key. Set GEMINI_API_KEY or pass --api-key.")

    m = model or "gemini-2.5-flash"
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent"
    body = {
        "systemInstruction": {
            "parts": [{"text": system_prompt}]
        },
        "contents": [
            {
                "role": "user",
                "parts": [{"text": user_prompt}],
            }
        ],
        "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 8192,
            "responseMimeType": "application/json",
        },
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": key,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        payload = e.read().decode("utf-8", errors="replace")
        code, message = _parse_gemini_error(payload)
        raise ProviderAPIError(
            message,
            provider="gemini",
            status_code=e.code,
            code=code,
        ) from None
    except urllib.error.URLError as e:
        raise ProviderAPIError(
            f"Could not reach Gemini API: {e.reason}",
            provider="gemini",
        ) from None

    text = _extract_gemini_text(data)
    if not text.strip():
        raise ProviderAPIError(
            "Gemini returned an empty response.",
            provider="gemini",
        )
    return text


def _call_nvidia(system_prompt, user_prompt, model, api_key) -> str:
    from openai import OpenAI

    key = api_key or os.environ.get("NVIDIA_API_KEY")
    if not key:
        raise ValueError("No NVIDIA API key. Set NVIDIA_API_KEY or pass --api-key.")

    client = OpenAI(
        api_key=key,
        base_url="https://integrate.api.nvidia.com/v1",
    )
    m = model or "mistralai/mistral-medium-3.5-128b"

    try:
        response = client.chat.completions.create(
            model=m,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.2,
            max_tokens=8192,
            stream=False,
        )
    except Exception as e:
        raise ProviderAPIError(
            str(e),
            provider="nvidia",
            status_code=getattr(e, "status_code", None),
            code=getattr(e, "code", None),
        ) from None

    return response.choices[0].message.content or ""


def _call_openrouter(system_prompt, user_prompt, model, api_key) -> str:
    """OpenRouter is OpenAI-API-compatible; same client, different base URL + key.

    Routes to any model in OpenRouter's catalog (e.g. moonshotai/kimi-k2,
    deepseek/deepseek-chat). No response_format is forced, for broad model
    compatibility — Sembl's parser handles raw JSON text.
    """
    from openai import OpenAI

    key = api_key or os.environ.get("OPENROUTER_API_KEY")
    if not key:
        raise ValueError("No OpenRouter API key. Set OPENROUTER_API_KEY or pass --api-key.")

    client = OpenAI(
        api_key=key,
        base_url="https://openrouter.ai/api/v1",
    )
    m = model or "moonshotai/kimi-k2"

    try:
        response = client.chat.completions.create(
            model=m,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.2,
            max_tokens=8192,
            stream=False,
            extra_headers={
                "HTTP-Referer": "https://github.com/speedvibecode/sembl",
                "X-Title": "sembl",
            },
        )
    except Exception as e:
        raise ProviderAPIError(
            str(e),
            provider="openrouter",
            status_code=getattr(e, "status_code", None),
            code=getattr(e, "code", None),
        ) from None

    return response.choices[0].message.content or ""


def _call_ollama(system_prompt, user_prompt, model, api_key) -> str:
    """Local models via Ollama's OpenAI-compatible endpoint. No API key needed; runs
    on the user's machine ($0, no rate limits). Base URL defaults to localhost and can
    be overridden with OLLAMA_HOST (e.g. http://host:port). A generous timeout is set
    because CPU inference can take minutes per generation.
    """
    from openai import OpenAI

    host = os.environ.get("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
    if not host.endswith("/v1"):
        host = host + "/v1"
    client = OpenAI(
        api_key=api_key or "ollama",  # Ollama ignores the key but the client requires one.
        base_url=host,
        timeout=900,
    )
    m = model or "qwen2.5-coder:7b"

    try:
        response = client.chat.completions.create(
            model=m,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.2,
            max_tokens=8192,
            stream=False,
        )
    except Exception as e:
        raise ProviderAPIError(
            str(e),
            provider="ollama",
            status_code=getattr(e, "status_code", None),
            code=getattr(e, "code", None),
        ) from None

    return response.choices[0].message.content or ""


def _parse_gemini_error(payload: str) -> tuple[str | None, str]:
    try:
        data = json.loads(payload)
        error = data.get("error", {})
        code = error.get("status") or error.get("code")
        message = error.get("message") or payload
        return str(code) if code is not None else None, str(message)
    except Exception:
        return None, payload


def _extract_gemini_text(data: dict) -> str:
    candidates = data.get("candidates") or []
    if not candidates:
        return ""
    parts = candidates[0].get("content", {}).get("parts") or []
    return "".join(str(part.get("text", "")) for part in parts)


# ── Response parsing ──────────────────────────────────────────────────────────

def _parse_llm_response(raw: str, wo: WorkOrder, probe: RepoProbe):
    """Parse the LLM JSON into the WorkOrder dataclass."""
    try:
        data = _load_json_object(raw)
    except json.JSONDecodeError as e:
        detail = _json_error_detail(raw, e)
        raise ValueError(f"LLM returned invalid JSON: {e}\n\n{detail}") from None

    if not isinstance(data, dict):
        raise ValueError("LLM returned JSON, but the top-level value was not an object.")

    def _get(key, default=None):
        return data.get(key, default if default is not None else [])

    wo.clarified_goal       = _get("clarified_goal", "")
    wo.user_visible_outcome = _get("user_visible_outcome", "")
    wo.task_type            = _get("task_type", "feature")
    wo.non_goals            = _get("non_goals")
    wo.must_not_change      = _get("must_not_change")
    wo.forbidden_areas      = _get("forbidden_areas")
    wo.likely_affected_areas= _get("likely_affected_areas")
    wo.editable_paths       = _get("editable_paths")
    wo.read_only_context    = _get("read_only_context")
    wo.files_to_inspect     = _get("files_to_inspect")
    wo.tests_to_inspect     = _get("tests_to_inspect")
    wo.architecture_notes   = _get("architecture_notes")
    wo.acceptance_criteria  = _get("acceptance_criteria")
    wo.regressions_to_preserve = _get("regressions_to_preserve")
    wo.validation_commands  = _get("validation_commands")
    wo.tests_to_add_or_update = _get("tests_to_add_or_update")
    wo.manual_checks        = _get("manual_checks")
    wo.stop_conditions      = _get("stop_conditions")
    wo.approval_triggers    = _get("approval_triggers")
    wo.risk_level           = _get("risk_level", "medium")
    wo.risk_reasons         = _get("risk_reasons")
    wo.executor_prompt      = _get("executor_prompt", "")
    wo.patch_expectations   = _get("patch_expectations")
    wo.reporting_format     = _get("reporting_format", "")

    # Merge any known commands from probe into validation_commands
    if probe.test_commands and not wo.validation_commands:
        wo.validation_commands = probe.test_commands[:]


def _ground_work_order_in_repo(wo: WorkOrder, probe: RepoProbe):
    """Remove impossible paths and reinforce generated scope with repo-real paths."""
    root = Path(probe.repo_path)
    if not root.exists():
        return

    ignored = _ignored_repo_path_patterns(root)
    graph_paths = _rank_task_paths(
        _extract_paths_from_text(
            "\n".join(
                [
                    probe.graphify_task_context,
                    probe.graphify_summary,
                    probe.graphify_communities,
                    "\n".join(probe.crg_blast_radius),
                ]
            ),
            root,
            ignored,
        ),
        wo.original_request,
    )
    scanned_paths, content_hits = _scan_task_paths_detailed(root, wo.original_request, ignored)
    repo_hits = _rank_task_paths(scanned_paths, wo.original_request)
    candidate_paths = _dedupe(graph_paths + repo_hits)
    candidate_files = [path for path in candidate_paths if (root / path).is_file()]
    candidate_test_files = [path for path in candidate_files if _looks_like_test_path(path)]
    editable_candidates = [path for path in candidate_files if _is_editable_candidate(path, wo.original_request)]
    candidate_areas = [path for path in candidate_paths if (root / path).is_dir()]

    wo.likely_affected_areas = _rank_task_paths(
        _merge_existing_paths(
            _valid_existing_paths(wo.likely_affected_areas, root, ignored),
            _dedupe(candidate_areas + _parent_dirs(candidate_files)),
            max_items=30,
        ),
        wo.original_request,
    )[:10]
    # Trusted editable sources: the LLM's own picks and graph-surfaced editable files.
    # These survive the keyword-score filter below — the keyword heuristic is weak and
    # web/auth-biased, so without this a graph-identified gold file whose path lacks task
    # terms (score 0) would be silently dropped (this is why graph context never moved
    # editable_paths). Generic repo keyword hits still require score > 0.
    graph_editable = [
        path for path in graph_paths
        if (root / path).is_file() and _is_editable_candidate(path, wo.original_request)
    ]
    llm_editable = [
        path for path in _valid_existing_paths(wo.editable_paths, root, ignored)
        if _is_editable_candidate(path, wo.original_request)
    ]
    # Files the LLM wants inspected are edit-scope candidates too: across the demo
    # matrix the true fix file repeatedly reached files_to_inspect while missing
    # editable_paths, leaving executors forbidden to edit the file the WO itself
    # pointed them at.
    inspect_editable = [
        path for path in _valid_existing_files(wo.files_to_inspect, root, ignored)
        if _is_editable_candidate(path, wo.original_request)
    ]
    direct_editable = [path for path in editable_candidates if path not in set(graph_editable)]
    all_editable_candidates = _dedupe(
        llm_editable + graph_editable + direct_editable + inspect_editable
    )
    trace_hits = _failure_trace_files(
        root,
        all_editable_candidates,
        _failure_trace_signals(wo.original_request),
    )
    ranked_editable = _rank_editable_paths(
        llm_editable,
        graph_editable,
        _dedupe(direct_editable + inspect_editable),
        wo.original_request,
        trace_hits=trace_hits,
        content_hits=content_hits,
    )
    wo.editable_paths = _cap_with_graph_floor(ranked_editable, set(graph_editable), cap=8)
    wo.files_to_inspect = _rank_task_paths(
        _merge_existing_paths(
            _valid_existing_files(wo.files_to_inspect, root, ignored),
            candidate_files,
            max_items=30,
        ),
        wo.original_request,
    )[:12]
    wo.read_only_context = _merge_existing_paths(
        _valid_existing_paths(wo.read_only_context, root, ignored),
        _read_only_context_paths(root, candidate_paths),
        max_items=10,
    )
    wo.tests_to_inspect = _merge_existing_paths(
        _ground_test_context_paths(
            wo.tests_to_inspect,
            root,
            wo.original_request,
            candidate_test_files,
            ignored,
        ),
        candidate_test_files,
        max_items=8,
    )

    if not _has_existing_test_path(root, wo.tests_to_inspect):
        wo.tests_to_add_or_update = _valid_new_test_paths(wo.tests_to_add_or_update, root, ignored)
        _append_unique(
            wo.stop_conditions,
            "No failing test file is present in the repo; ask the human for the exact failing test path before changing implementation.",
        )

    wo.validation_commands = _ground_validation_commands(
        wo.validation_commands,
        probe,
        root,
        candidate_test_files,
    )
    wo.patch_expectations = _ground_patch_expectations(
        wo.patch_expectations,
        root,
        wo.editable_paths,
        ignored,
    )
    _reconcile_contract(wo, root, ignored)
    _refresh_executor_prompt_from_grounded_fields(wo)


def _reconcile_contract(wo: WorkOrder, root: Path, ignored: set[str] | None = None):
    """Deterministic contract-consistency repair (no LLM).

    The demo matrix showed every generated WO contradicting itself somewhere:
    paths in both editable and forbidden, patch expectations naming non-editable
    files, test additions demanded with no editable test path. Executors resolve
    those contradictions unpredictably (silent violation, worse-placed fix, or a
    full stop), so the contract must be made coherent before it is written.
    """
    # 1. If the WO demands test work, a test path must be editable. (Runs first:
    #    later rules must see the final editable set, or the appended test path
    #    can reintroduce an editable/forbidden conflict.)
    wants_tests = bool(wo.tests_to_add_or_update) or any(
        re.search(r"\b(add|adding|new|write|create|update)\w*\b[^.;]*\btests?\b", str(text).lower())
        for text in (wo.patch_expectations or [])
    )
    if wants_tests and not any(_looks_like_test_path(path) for path in wo.editable_paths):
        test_path = next(
            (path for path in wo.tests_to_inspect or [] if _path_exists(root, path)),
            None,
        ) or next(iter(wo.tests_to_add_or_update or []), None)
        if test_path:
            _append_unique(wo.editable_paths, _clean_path(str(test_path)))

    editable = _dedupe(_clean_path(str(p)) for p in wo.editable_paths or [])

    # 2. Forbidden may not contradict editable — editable is the actionable scope,
    #    so a forbidden entry that names an editable file (or an ancestor dir of
    #    one) is dropped.
    kept_forbidden = []
    for raw in wo.forbidden_areas or []:
        entry = _clean_path(str(raw))
        if not entry:
            continue
        prefix = entry.rstrip("/") + "/"
        if entry in editable or any(path.startswith(prefix) for path in editable):
            continue
        kept_forbidden.append(entry)
    wo.forbidden_areas = _dedupe(kept_forbidden)

    # 3. Patch expectations may not name existing repo files outside editable
    #    scope (test files excepted — rule 1 makes those editable).
    editable_set = set(editable)
    consistent = []
    for value in wo.patch_expectations or []:
        text = str(value).strip()
        tokens = [
            token for token in _extract_path_like_tokens(text)
            if _path_exists(root, token)
        ]
        if any(
            token not in editable_set and not _looks_like_test_path(token)
            for token in tokens
        ):
            continue
        consistent.append(text)
    if not consistent and editable:
        consistent.append("Keep implementation changes within the grounded editable paths.")
    wo.patch_expectations = consistent

    # 4. Lock 7: permission to stop. Converts silent out-of-scope edits (weak
    #    executors) and dead-end tunneling (strong executors) into a report.
    if wo.editable_paths:
        _append_unique(
            wo.stop_conditions,
            "If the correct fix requires editing a file outside editable_paths, "
            "stop and report which file and why instead of proceeding or expanding scope.",
        )


def _refresh_executor_prompt_from_grounded_fields(wo: WorkOrder):
    goal = wo.clarified_goal or wo.original_request
    parts = [
        f"Your task is to {goal}.",
        f"Original request: {wo.original_request}.",
    ]

    if wo.user_visible_outcome:
        parts.append(f"User-visible outcome: {wo.user_visible_outcome}.")
    if wo.non_goals:
        parts.append("Non-goals: " + _sentence_list(wo.non_goals) + ".")
    if wo.editable_paths:
        parts.append("You MAY only edit these paths: " + _sentence_list(wo.editable_paths) + ".")
    if wo.forbidden_areas:
        parts.append("You must NOT touch: " + _sentence_list(wo.forbidden_areas) + ".")
    if wo.files_to_inspect:
        parts.append("Inspect these files before changing code: " + _sentence_list(wo.files_to_inspect) + ".")
    if wo.tests_to_inspect:
        parts.append("Inspect these tests before changing code: " + _sentence_list(wo.tests_to_inspect) + ".")
    if wo.acceptance_criteria:
        parts.append("Acceptance criteria: " + _sentence_list(wo.acceptance_criteria) + ".")
    if wo.stop_conditions:
        parts.append("Stop and ask the human if: " + _sentence_list(wo.stop_conditions) + ".")
    if wo.patch_expectations:
        parts.append("Patch expectations: " + _sentence_list(wo.patch_expectations) + ".")
    if wo.validation_commands:
        parts.append("Validate with: " + _sentence_list(wo.validation_commands) + ".")
    if wo.reporting_format:
        parts.append(f"Report your work using this format: {wo.reporting_format}")

    wo.executor_prompt = " ".join(parts)


def _sentence_list(values: list) -> str:
    return "; ".join(str(value).strip() for value in values if str(value).strip())


def _extract_paths_from_text(
    text: str,
    root: Path,
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    """Pull repo-relative file/dir paths out of free text (graph output, prose).

    Layout-agnostic: matches any multi-segment path token ending in an extension
    (e.g. `crosstl/backend/DirectX/DirectxParser.py`, `src/app/foo.ts`), including
    graphify's `src=<path>` node tokens, and validates each against the real repo.
    The previous version only matched a hardcoded JS/web prefix list (src/app/tests/
    supabase/package.json/...), so it extracted NOTHING from Python repos — graph file
    signal never reached editable_paths.
    """
    if not text:
        return []

    normalized = text.replace("\\", "/")
    candidates = []
    # `seg/seg.../name.ext` (>=1 slash, a file extension), optional `src=`
    # prefix. Allows common route/module chars: (), [], @, +.
    file_pat = re.compile(r"(?:src=)?([A-Za-z0-9_.@+\-()[\]]+(?:/[A-Za-z0-9_.@+\-()[\]]+)+\.[A-Za-z0-9]+)")
    for match in file_pat.finditer(normalized):
        path = _clean_path(match.group(1))
        if path and _is_repo_source_path(path, ignored_patterns) and _path_exists(root, path):
            candidates.append(path)
    return _dedupe(candidates)


def _scan_task_related_paths(
    root: Path,
    task: str,
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    paths, _ = _scan_task_paths_detailed(root, task, ignored_patterns)
    return paths


def _scan_task_paths_detailed(
    root: Path,
    task: str,
    ignored_patterns: set[str] | None = None,
) -> tuple[list[str], set[str]]:
    """Task-related paths plus the subset matched by file CONTENT.

    A content match (the file mentions the failing term) is a much stronger
    edit-scope signal than a path-name match, so the ranker needs to know which
    is which.
    """
    terms = set(_task_terms(task))
    if {"login", "redirect", "signin", "session"} & terms:
        terms.update({"auth", "callback", "oauth", "signin", "session", "login"})
    if not terms:
        return [], set()

    results = []
    content_hits: dict = {}
    extensions = {".ts", ".tsx", ".js", ".jsx", ".py", ".go"}

    for path in root.rglob("*"):
        rel = path.relative_to(root).as_posix()
        if not _is_repo_source_path(rel, ignored_patterns):
            continue
        haystack = rel.lower()
        if path.is_dir():
            if any(term in haystack for term in terms):
                results.append(rel)
            continue
        if path.suffix.lower() not in extensions:
            continue
        path_matched = any(term in haystack for term in terms)
        if path_matched:
            results.append(rel)
        try:
            content = path.read_text(errors="ignore").lower()
        except Exception:
            continue
        matched_terms = sum(1 for term in terms if term in content)
        if matched_terms:
            content_hits[rel] = matched_terms
            if not path_matched:
                results.append(rel)

    return _dedupe(results), content_hits


def _rank_task_paths(paths: list[str], task: str) -> list[str]:
    def score(path: str) -> tuple[int, int, str]:
        return (-_task_path_score(path, task), len(path), path)

    return sorted(_dedupe(paths), key=score)


def _rank_editable_paths(
    llm_paths: list[str],
    graph_paths: list[str],
    direct_paths: list[str],
    task: str,
    trace_hits: set[str] | frozenset = frozenset(),
    content_hits: dict | set[str] | frozenset = frozenset(),
) -> list[str]:
    """Rank edit scope by task relevance first, provenance second.

    0.1.9: relevance-first. The 0.1.8 provenance tiers let graph-surfaced entry
    points crowd out the actual fix file — graphify summaries name "key entry
    points", so __main__/cmd/packaging scripts arrived with top provenance and the
    8-item cap dropped content-matched files (demo-tasks/CROSS-REPO-FINDINGS.md:
    recall 0/1, 1/3, 0/1, 0/1 across four repos). Failure-trace hits (the task's
    quoted error text found in file content) and task-term scores now dominate;
    provenance only breaks ties; entry points and config files carry a penalty.
    """
    graph_set = set(graph_paths)
    llm_set = set(llm_paths)

    def score(path: str) -> tuple[int, int, int, str]:
        value = _task_path_score(path, task)
        if path in trace_hits:
            # A literal failure-trace match (the task's quoted error text found
            # in this file) is near-certain localization — it must beat any
            # realistic stack of keyword matches in prettier-named files.
            value += 25
        if path in content_hits:
            # Scaled by how many distinct task terms the file CONTAINS: a file
            # mentioning proxy+chrome+headless is a far stronger candidate than
            # one mentioning a single broad term.
            matched = content_hits[path] if isinstance(content_hits, dict) else 1
            value += min(3 * matched, 21)
        value -= _entry_point_penalty(path)
        if path in graph_set:
            provenance = 0
        elif path in llm_set:
            provenance = 1
        else:
            provenance = 2
        return (-value, provenance, len(path), path)

    return sorted(_dedupe(llm_paths + graph_paths + direct_paths), key=score)


def _cap_with_graph_floor(ranked: list[str], graph_set: set[str], cap: int = 8) -> list[str]:
    """Cap the ranked list while guaranteeing one slot to graph context.

    Relevance-first ranking can push a zero-keyword graph-surfaced file past the
    cap (keyword heuristics are weak — the 0.1.7 lesson). If no graph candidate
    survives, the best-ranked one takes the last slot so structural context is
    never silently dropped.
    """
    capped = ranked[:cap]
    if graph_set and not any(path in graph_set for path in capped):
        best_graph = next((path for path in ranked if path in graph_set), None)
        if best_graph:
            capped = capped[: cap - 1] + [best_graph] if len(capped) >= cap else capped + [best_graph]
    return capped


_ENTRY_POINT_NAMES = {
    "__main__.py", "__init__.py", "setup.py", "conftest.py",
    "main.go", "index.ts", "index.tsx", "index.js", "index.jsx",
}
_ENTRY_POINT_SEGMENTS = {
    "cmd", "scripts", "extras", "examples", "tools", "packaging",
    "dist", "build", "bin",
}
_CONFIG_SUFFIXES = (
    ".json", ".toml", ".cfg", ".ini", ".yaml", ".yml", ".lock",
)


def _entry_point_penalty(path: str) -> int:
    """Penalty for files that are launchers/packaging/config, not behavior.

    Entry points are graph-central (everything reaches them) and config files
    keyword-match broad tasks, but neither is usually where a bugfix lives.
    """
    lower = path.lower()
    penalty = 0
    if Path(lower).name in _ENTRY_POINT_NAMES:
        penalty += 6
    if set(lower.split("/")[:-1]) & _ENTRY_POINT_SEGMENTS:
        penalty += 6
    if lower.endswith(_CONFIG_SUFFIXES):
        penalty += 6
    return min(penalty, 10)


def _failure_trace_signals(task: str) -> list[str]:
    """Literal strings from the task that can pinpoint the fix file.

    Quoted phrases ("The passwords do not match") and SCREAMING_SNAKE error
    tokens are far stronger localizers than keyword overlap: when one appears in
    a source file, that file almost certainly owns the failing behavior.
    """
    signals = []
    for quote_pat in (r'"([^"]{6,120})"', r"'([^']{6,120})'", r"[‘’“”]([^‘’“”]{6,120})[‘’“”]"):
        signals.extend(re.findall(quote_pat, task))
    signals.extend(re.findall(r"\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+){1,}\b", task))
    return _dedupe([s.strip() for s in signals if s.strip()])


def _failure_trace_files(root: Path, paths: list[str], signals: list[str]) -> set[str]:
    if not signals:
        return set()
    hits = set()
    lowered = [s.lower() for s in signals]
    for path in paths:
        full = root / path
        if not full.is_file():
            continue
        try:
            content = full.read_text(errors="ignore").lower()
        except Exception:
            continue
        if any(signal in content for signal in lowered):
            hits.add(path)
    return hits


def _task_path_score(path: str, task: str) -> int:
    terms = set(_task_terms(task))
    if {"login", "redirect", "signin", "session"} & terms:
        terms.update({"auth", "callback", "oauth", "signin", "session", "login"})

    lower = path.lower()
    name = Path(lower).name
    value = 0
    for term in terms:
        if term in lower:
            value += 5
        if term in name:
            value += 4
    if "login" in terms and "form" in name and "login" in lower:
        value += 4
    if "/features/auth/" in lower or "\\features\\auth\\" in lower:
        value += 8
    if "/app/auth/" in lower or "\\app\\auth\\" in lower:
        value += 8
    if "/app/(auth)/" in lower or "\\app\\(auth)\\" in lower:
        value += 8
    if lower.startswith("app/api/auth/") and "auth" in terms:
        value += 3
    if lower.endswith((".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx")):
        value += 3
    if lower.startswith("types/"):
        value -= 6
    if lower.endswith(("package.json", "tsconfig.json", "readme.md")):
        value -= 4
    return value


def _task_terms(task: str) -> list[str]:
    stop = {
        "add", "fix", "update", "change", "make", "create", "remove", "delete",
        "refactor", "failing", "failed", "test", "tests", "the", "a", "an",
        "to", "for", "in", "of", "and", "or", "with", "this", "that",
    }
    return [
        word for word in re.findall(r"[a-z0-9]+", task.lower())
        if len(word) > 3 and word not in stop
    ]


def _valid_existing_paths(
    values: list,
    root: Path,
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if path and _is_repo_source_path(path, ignored_patterns) and _path_exists(root, path):
            valid.append(path)
    return _dedupe(valid)


def _valid_existing_files(
    values: list,
    root: Path,
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if path and _is_repo_source_path(path, ignored_patterns) and (root / path).is_file():
            valid.append(path)
    return _dedupe(valid)


def _valid_new_test_paths(
    values: list,
    root: Path,
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if not path:
            continue
        parent = (root / path).parent
        if _is_repo_source_path(path, ignored_patterns) and _looks_like_test_path(path) and parent.exists():
            valid.append(path)
    return _dedupe(valid)


def _ground_test_context_paths(
    values: list,
    root: Path,
    task: str,
    candidate_test_files: list[str],
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    """Keep existing LLM test picks only when they are task-grounded."""
    candidate_set = set(candidate_test_files)
    valid = _valid_existing_paths(values, root, ignored_patterns)
    return [
        path for path in valid
        if path in candidate_set or _task_path_score(path, task) > 0
    ]


def _ground_patch_expectations(
    values: list,
    root: Path,
    editable_paths: list[str],
    ignored_patterns: set[str] | None = None,
) -> list[str]:
    grounded = []
    for value in values or []:
        text = str(value).strip()
        if not text:
            continue
        path_tokens = _extract_path_like_tokens(text)
        if path_tokens and any(
            not _is_repo_source_path(path, ignored_patterns) or not _path_exists(root, path)
            for path in path_tokens
        ):
            continue
        grounded.append(text)

    if not grounded and editable_paths:
        grounded.append("Keep implementation changes within the grounded editable paths.")
    return _dedupe(grounded)


def _ground_validation_commands(
    commands: list,
    probe: RepoProbe,
    root: Path,
    test_files: list[str] | None = None,
) -> list[str]:
    grounded = []
    known = set(probe.test_commands + probe.lint_commands + probe.build_commands)
    package_scripts = _package_scripts(root)

    # Only the few most task-relevant test files become explicit commands. On a
    # large monorepo, candidate_test_files can be 100+ — emitting one npm command
    # per file produced a multi-hundred-command validation block (zod). test_files
    # arrives task-ranked, so the head is the relevant slice.
    if "test" in package_scripts:
        for test_file in (test_files or [])[:3]:
            test_command = f"npm test -- {test_file}"
            if test_command not in grounded:
                grounded.append(test_command)

    for command in commands or []:
        cmd = str(command).strip()
        if not cmd:
            continue
        lower = cmd.lower()
        if "&&" in cmd or "manual" in lower:
            continue
        if test_files and ("testnamepattern" in lower or "--grep" in lower):
            continue
        if "npm test" in lower and "test" not in package_scripts:
            continue
        if "npm run " in lower:
            script = lower.split("npm run ", 1)[1].split()[0]
            if script not in package_scripts:
                continue
        referenced_paths = _extract_command_paths(cmd)
        if any(not _path_exists(root, path) for path in referenced_paths):
            continue
        grounded.append(cmd)

    for command in known:
        if command not in grounded:
            grounded.append(command)
    # Cap the total: a Work Order's proof step must be actionable, not a wall of
    # commands. Keep the head (relevant per-file tests + LLM picks come first).
    return _dedupe(grounded)[:10]


def _extract_command_paths(command: str) -> list[str]:
    paths = []
    for token in re.split(r"\s+", command):
        path = _clean_path(token)
        if path.startswith(("src/", "app/", "tests/", "__tests__/")):
            paths.append(path)
    return paths


def _package_scripts(root: Path) -> set[str]:
    try:
        package = json.loads((root / "package.json").read_text(errors="ignore"))
        return set(package.get("scripts", {}).keys())
    except Exception:
        return set()


def _read_only_context_paths(root: Path, candidate_paths: list[str]) -> list[str]:
    context = []
    for path in ["package.json", "tsconfig.json", "README.md"]:
        if _path_exists(root, path):
            context.append(path)
    for path in candidate_paths:
        lower = path.lower()
        if "supabase" in lower or "store" in lower or "types" in lower:
            context.append(path)
    return _dedupe(context)


def _is_editable_candidate(path: str, task: str) -> bool:
    if not _is_repo_source_path(path):
        return False

    lower = path.lower()
    task_lower = task.lower()
    config_terms = {"dependency", "dependencies", "package", "script", "config", "typescript", "build"}
    task_terms = set(_task_terms(task))
    if _looks_like_test_path(path):
        return bool(re.search(
            r"\b(add|create|update|modify|write)\b.*\btests?\b|\btests?\b.*\b(add|create|update|modify|write)\b",
            task_lower,
        ))
    if lower.startswith("types/") or lower.endswith(".d.ts"):
        return bool(task_terms & {"type", "types", "typing", "typescript", "declaration"})
    if lower.endswith((
        "package.json",
        "package-lock.json",
        "pnpm-lock.yaml",
        "yarn.lock",
        "tsconfig.json",
        "readme.md",
    )):
        return bool(task_terms & config_terms)
    if lower.startswith(("docs/", "system design/", "ai system docs/", "stitch_ui_frontend_design/")):
        return False
    return True


def _parent_dirs(paths: list[str]) -> list[str]:
    dirs = []
    for path in paths:
        parent = Path(path).parent.as_posix()
        if parent and parent != ".":
            dirs.append(parent)
    return _dedupe(dirs)


def _merge_existing_paths(primary: list[str], fallback: list[str], max_items: int) -> list[str]:
    return _dedupe(primary + fallback)[:max_items]


def _has_existing_test_path(root: Path, paths: list[str]) -> bool:
    return any(_looks_like_test_path(path) and _path_exists(root, path) for path in paths)


def _looks_like_test_path(path: str) -> bool:
    lower = path.lower()
    return (
        "/test" in lower
        or lower.startswith("test")
        or lower.startswith("__tests__/")
        or lower.endswith((
            ".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx",
            ".test.js", ".test.jsx", ".spec.js",
            "_test.py", "_test.go",
        ))
    )


def _extract_path_like_tokens(text: str) -> list[str]:
    normalized = text.replace("\\", "/")
    file_pat = re.compile(r"(?:src=)?([A-Za-z0-9_.@+\-()[\]]+(?:/[A-Za-z0-9_.@+\-()[\]]+)+\.[A-Za-z0-9]+)")
    return _dedupe(_clean_path(match.group(1)) for match in file_pat.finditer(normalized))


def _is_repo_source_path(value: str, ignored_patterns: set[str] | None = None) -> bool:
    """True when a path is eligible source/test context for a Work Order.

    Generated caches and vendored dependency installs are repo-real files, but
    they are not repo-owned implementation scope. Accepting them lets broad
    terms like "error" or "message" swamp the intended package files.
    """
    path = _clean_path(value)
    if not path:
        return False

    parts = [part.lower() for part in path.split("/") if part and part != "."]
    if not parts:
        return False
    for part in parts:
        if part in IGNORED_REPO_PATH_PARTS:
            return False
    if _matches_ignored_pattern(path, ignored_patterns or IGNORED_REPO_PATH_GLOBS):
        return False
    return True


def _ignored_repo_path_patterns(root: Path) -> set[str]:
    patterns = set(IGNORED_REPO_PATH_GLOBS)
    gitignore = root / ".gitignore"
    try:
        lines = gitignore.read_text(errors="ignore").splitlines()
    except Exception:
        return patterns

    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        line = line.replace("\\", "/")
        while line.startswith("./"):
            line = line[2:]
        if line.startswith("/"):
            line = line[1:]
        patterns.add(line)
    return patterns


def _matches_ignored_pattern(path: str, patterns: set[str]) -> bool:
    parts = [part.lower() for part in path.split("/") if part and part != "."]
    lower_path = path.lower()
    name = parts[-1] if parts else lower_path
    for pattern in patterns:
        pat = pattern.lower().strip()
        if not pat:
            continue
        directory = pat.endswith("/")
        pat = pat.rstrip("/")
        if not pat:
            continue
        if directory:
            if any(ch in pat for ch in "*?[]") and any(Path(part).match(pat) for part in parts):
                return True
            if pat in parts or lower_path.startswith(pat + "/"):
                return True
            continue
        if "/" in pat:
            if lower_path == pat or lower_path.startswith(pat + "/"):
                return True
        elif pat in parts:
            return True
        if any(ch in pat for ch in "*?[]") and Path(name).match(pat):
            return True
    return False


def _path_exists(root: Path, value: str) -> bool:
    path = _clean_path(value)
    if not path:
        return False
    if (root / path).exists():
        return True
    if any(ch in path for ch in "*?[]"):
        return any(root.glob(path))
    return False


def _clean_path(value: str) -> str:
    path = value.strip().strip("`'\"")
    path = path.rstrip(".,;:")
    path = path.replace("\\", "/")
    while path.startswith("./"):
        path = path[2:]
    return path


def _append_unique(items: list, value: str):
    if value not in items:
        items.append(value)


def _dedupe(items: list[str]) -> list[str]:
    seen = set()
    result = []
    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def _load_json_object(raw: str) -> dict:
    """Load provider JSON while tolerating common LLM formatting defects."""
    cleaned = _extract_json_object(_strip_markdown_fence(raw))
    cleaned_structural = _quote_unquoted_property_names(
        _strip_garbage_before_property_names(cleaned)
    )

    attempts = [
        (cleaned, True),
        (cleaned, False),
        (_escape_control_chars_in_strings(cleaned), True),
        (_escape_invalid_json_escapes_in_strings(cleaned), True),
        (_escape_invalid_json_escapes_in_strings(_escape_control_chars_in_strings(cleaned)), True),
        (cleaned_structural, True),
        (_escape_control_chars_in_strings(cleaned_structural), True),
        (_escape_invalid_json_escapes_in_strings(cleaned_structural), True),
        (_escape_invalid_json_escapes_in_strings(_escape_control_chars_in_strings(cleaned_structural)), True),
    ]

    last_error: json.JSONDecodeError | None = None
    for candidate, strict in attempts:
        try:
            decoder = json.JSONDecoder(strict=strict)
            value, _ = decoder.raw_decode(candidate.strip())
            return value
        except json.JSONDecodeError as e:
            last_error = e

    assert last_error is not None
    raise last_error


def _strip_markdown_fence(text: str) -> str:
    cleaned = text.strip()
    if not cleaned.startswith("```"):
        return cleaned

    lines = cleaned.splitlines()
    if not lines:
        return cleaned
    if lines[-1].strip() == "```":
        return "\n".join(lines[1:-1]).strip()
    return "\n".join(lines[1:]).strip()


def _extract_json_object(text: str) -> str:
    start = text.find("{")
    if start == -1:
        return text.strip()

    in_string = False
    escaped = False
    depth = 0
    for i, ch in enumerate(text[start:], start):
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            continue

        if ch == '"':
            in_string = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return text[start:i + 1].strip()

    return text[start:].strip()


def _escape_control_chars_in_strings(text: str) -> str:
    out = []
    in_string = False
    escaped = False

    for ch in text:
        if in_string:
            if escaped:
                out.append(ch)
                escaped = False
                continue
            if ch == "\\":
                out.append(ch)
                escaped = True
                continue
            if ch == '"':
                out.append(ch)
                in_string = False
                continue
            if ord(ch) < 0x20:
                out.append(_escape_control_char(ch))
                continue
            out.append(ch)
            continue

        out.append(ch)
        if ch == '"':
            in_string = True

    return "".join(out)


def _escape_invalid_json_escapes_in_strings(text: str) -> str:
    out = []
    in_string = False
    valid_single_char_escapes = {'"', "\\", "/", "b", "f", "n", "r", "t"}
    hex_digits = set("0123456789abcdefABCDEF")
    i = 0

    while i < len(text):
        ch = text[i]
        if in_string:
            if ch == "\\":
                next_ch = text[i + 1] if i + 1 < len(text) else ""
                if next_ch in valid_single_char_escapes:
                    out.append(ch)
                    out.append(next_ch)
                    i += 2
                    continue
                if (
                    next_ch == "u"
                    and i + 5 < len(text)
                    and all(c in hex_digits for c in text[i + 2:i + 6])
                ):
                    out.append(text[i:i + 6])
                    i += 6
                    continue
                out.append("\\")
                out.append("\\")
                i += 1
                continue
            if ch == '"':
                out.append(ch)
                in_string = False
                i += 1
                continue
            out.append(ch)
            i += 1
            continue

        out.append(ch)
        if ch == '"':
            in_string = True
        i += 1

    return "".join(out)


def _strip_garbage_before_property_names(text: str) -> str:
    """Remove provider junk inserted before object property names.

    Some models occasionally insert a stray token at the beginning of an object
    property line, for example `aaa  "reporting_format": ...`. This keeps the
    repair outside JSON strings and only trims a simple word prefix immediately
    before a quoted property key.
    """
    out = []
    in_string = False
    escaped = False

    for line in text.splitlines(keepends=True):
        if not in_string:
            line = re.sub(
                r'^(\s*)[A-Za-z_][A-Za-z0-9_-]*\s+("[A-Za-z_][A-Za-z0-9_]*"\s*:)',
                r'\1\2',
                line,
            )

        for ch in line:
            if in_string:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == '"':
                    in_string = False
            elif ch == '"':
                in_string = True
        out.append(line)

    return "".join(out)


def _quote_unquoted_property_names(text: str) -> str:
    """Quote simple unquoted object property names outside strings.

    Repairs model output such as `tests_to_inspect: [...]` while avoiding prose
    inside string values.
    """
    out = []
    in_string = False
    escaped = False

    for line in text.splitlines(keepends=True):
        if not in_string:
            line = re.sub(
                r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:',
                r'\1"\2":',
                line,
            )

        for ch in line:
            if in_string:
                if escaped:
                    escaped = False
                elif ch == "\\":
                    escaped = True
                elif ch == '"':
                    in_string = False
            elif ch == '"':
                in_string = True
        out.append(line)

    return "".join(out)


def _escape_control_char(ch: str) -> str:
    if ch == "\n":
        return "\\n"
    if ch == "\r":
        return "\\r"
    if ch == "\t":
        return "\\t"
    return f"\\u{ord(ch):04x}"


def _json_error_detail(raw: str, error: json.JSONDecodeError) -> str:
    start = max(error.pos - 160, 0)
    end = min(error.pos + 160, len(raw))
    snippet = raw[start:end]
    return (
        "Raw output around parse failure:\n"
        f"{snippet}\n\n"
        "This usually means the provider emitted malformed JSON despite the JSON-only prompt."
    )


# ── ID generation ─────────────────────────────────────────────────────────────

def _generate_id(task: str, project_name: str) -> str:
    import re, time
    slug = re.sub(r"[^a-z0-9]+", "-", task.lower())[:40].strip("-")
    ts = int(time.time())
    proj = re.sub(r"[^a-z0-9]", "", project_name.lower())[:12]
    return f"wo-{proj}-{ts}-{slug}"
