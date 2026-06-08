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
        ),
        wo.original_request,
    )
    repo_hits = _rank_task_paths(_scan_task_related_paths(root, wo.original_request), wo.original_request)
    candidate_paths = _dedupe(graph_paths + repo_hits)
    candidate_files = [path for path in candidate_paths if (root / path).is_file()]
    candidate_test_files = [path for path in candidate_files if _looks_like_test_path(path)]
    editable_candidates = [path for path in candidate_files if _is_editable_candidate(path, wo.original_request)]
    candidate_areas = [path for path in candidate_paths if (root / path).is_dir()]

    wo.likely_affected_areas = _rank_task_paths(
        _merge_existing_paths(
            _valid_existing_paths(wo.likely_affected_areas, root),
            _dedupe(candidate_areas + _parent_dirs(candidate_files)),
            max_items=30,
        ),
        wo.original_request,
    )[:10]
    wo.editable_paths = [
        path for path in _rank_task_paths(
            _merge_existing_paths(
                [
                    path for path in _valid_existing_paths(wo.editable_paths, root)
                    if _is_editable_candidate(path, wo.original_request)
                ],
                editable_candidates,
                max_items=30,
            ),
            wo.original_request,
        )
        if _task_path_score(path, wo.original_request) > 0
    ][:8]
    wo.files_to_inspect = _rank_task_paths(
        _merge_existing_paths(
            _valid_existing_files(wo.files_to_inspect, root),
            candidate_files,
            max_items=30,
        ),
        wo.original_request,
    )[:12]
    wo.read_only_context = _merge_existing_paths(
        _valid_existing_paths(wo.read_only_context, root),
        _read_only_context_paths(root, candidate_paths),
        max_items=10,
    )
    wo.tests_to_inspect = _merge_existing_paths(
        _valid_existing_paths(wo.tests_to_inspect, root),
        candidate_test_files,
        max_items=8,
    )

    if not _has_existing_test_path(root, wo.tests_to_inspect):
        wo.tests_to_add_or_update = _valid_new_test_paths(wo.tests_to_add_or_update, root)
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
    _refresh_executor_prompt_from_grounded_fields(wo)


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


def _extract_paths_from_text(text: str, root: Path) -> list[str]:
    if not text:
        return []

    candidates = []
    pattern = re.compile(
        r"(?<![\w.-])((?:src|app|tests|__tests__|supabase|package\.json|tsconfig\.json|README\.md)"
        r"[\w./()@+\-\[\]]*)"
    )
    for match in pattern.finditer(text):
        path = _clean_path(match.group(1))
        if path in {"src", "app", "tests", "__tests__", "supabase"}:
            continue
        if path and _path_exists(root, path):
            candidates.append(path)
    return _dedupe(candidates)


def _scan_task_related_paths(root: Path, task: str) -> list[str]:
    terms = set(_task_terms(task))
    if {"login", "redirect", "signin", "session"} & terms:
        terms.update({"auth", "callback", "oauth", "signin", "session", "login"})
    if not terms:
        return []

    results = []
    skip_dirs = {
        ".git", ".expo", ".venv", "venv", "node_modules", "dist", "build",
        "web-build", "graphify-out", ".sembl", ".crg-data",
    }
    extensions = {".ts", ".tsx", ".js", ".jsx", ".py"}

    for path in root.rglob("*"):
        rel_parts = path.relative_to(root).parts
        if any(part in skip_dirs for part in rel_parts):
            continue
        rel = path.relative_to(root).as_posix()
        haystack = rel.lower()
        if path.is_dir():
            if any(term in haystack for term in terms):
                results.append(rel)
            continue
        if path.suffix.lower() not in extensions:
            continue
        if any(term in haystack for term in terms):
            results.append(rel)
            continue
        try:
            content = path.read_text(errors="ignore").lower()
        except Exception:
            continue
        if any(term in content for term in terms):
            results.append(rel)

    return _dedupe(results)


def _rank_task_paths(paths: list[str], task: str) -> list[str]:
    def score(path: str) -> tuple[int, int, str]:
        return (-_task_path_score(path, task), len(path), path)

    return sorted(_dedupe(paths), key=score)


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


def _valid_existing_paths(values: list, root: Path) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if path and _path_exists(root, path):
            valid.append(path)
    return _dedupe(valid)


def _valid_existing_files(values: list, root: Path) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if path and (root / path).is_file():
            valid.append(path)
    return _dedupe(valid)


def _valid_new_test_paths(values: list, root: Path) -> list[str]:
    valid = []
    for value in values or []:
        path = _clean_path(str(value))
        if not path:
            continue
        parent = (root / path).parent
        if _looks_like_test_path(path) and parent.exists():
            valid.append(path)
    return _dedupe(valid)


def _ground_validation_commands(
    commands: list,
    probe: RepoProbe,
    root: Path,
    test_files: list[str] | None = None,
) -> list[str]:
    grounded = []
    known = set(probe.test_commands + probe.lint_commands + probe.build_commands)
    package_scripts = _package_scripts(root)

    if "test" in package_scripts:
        for test_file in test_files or []:
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
    return _dedupe(grounded)


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
        or lower.endswith((".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx", "_test.py"))
    )


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
