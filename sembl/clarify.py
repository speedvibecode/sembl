"""
clarify.py

Sembl's intent stage — the step BEFORE a Work Order is packaged.

Current coding agents are optimized for autonomous completion: handed a vague
task, they assume their way to a confident wrong answer. The research on
underspecification (Ambig-SWE, "Ask or Assume?") shows the opposite behaviour is
what real collaboration needs — recognize uncertainty and ask before executing.

`analyze_clarity` is that recognizer. It takes a task + a light repo probe and
produces a ClarityReport: an underspecification score, the specific missing
information (as questions, typed), and a split between assumptions that are SAFE
to make and ones that are NOT. It refuses to manufacture false certainty.

This module owns no execution. It only decides: is this task ready to scope, or
does a human need to answer something first? The Work Order generator consumes
the report (see generator.WorkOrder uncertainty fields); it does not recompute it.
"""

from __future__ import annotations

import dataclasses
from dataclasses import dataclass, field
from typing import Optional

from .repo_probe import RepoProbe


# A task scoring at or above this is "blocked": too underspecified to scope
# safely without an answer. Tuned conservatively — the cost of a needless
# question is small; the cost of a confident wrong large change is not.
BLOCK_THRESHOLD = 0.6

# Missing-information taxonomy. The model is steered toward these types so the
# output is consumable, but parsing is permissive — an unknown type is kept.
MISSING_INFO_TYPES = [
    "product_behavior",   # what should it actually do
    "data_model",         # schema, persistence, shape of state
    "scope",              # how far the change is allowed to reach
    "acceptance_criteria",# how we know it is done / correct
    "constraints",        # perf, compat, deadlines, must-not-break
    "integration",        # external systems, APIs, callers
    "edge_cases",         # failure modes, empty/limit inputs
    "security",           # auth, secrets, exposure
]

# Missing information of these types blocks by default even on a moderate score:
# getting them wrong causes schema churn, scope creep, or security exposure that
# a downstream executor cannot safely guess.
HARD_TYPES = {"data_model", "scope", "security", "constraints", "integration"}


@dataclass
class ClarityReport:
    """The intent stage's verdict on a task. Serializes straight to the
    `sembl clarify` JSON contract and onto the Work Order's uncertainty fields."""

    status: str = "ready"                       # "ready" | "blocked"
    underspecification_score: float = 0.0       # 0.0 (crisp) .. 1.0 (vague)
    intent_confidence: str = "high"             # "high" | "medium" | "low"
    missing_information: list = field(default_factory=list)  # [{type, question, blocking}]
    safe_assumptions: list = field(default_factory=list)
    unsafe_assumptions: list = field(default_factory=list)
    ambiguity_tags: list = field(default_factory=list)
    # Derived convenience views (so consumers don't re-walk missing_information):
    clarification_questions: list = field(default_factory=list)
    blocked_until_answered: list = field(default_factory=list)
    # Provenance
    provider: str = ""
    model: str = ""

    @property
    def clarification_required(self) -> bool:
        return self.status == "blocked"

    def to_dict(self) -> dict:
        d = dataclasses.asdict(self)
        d["clarification_required"] = self.clarification_required
        return d


def analyze_clarity(
    task: str,
    probe: RepoProbe,
    provider: str = "openai",
    model: Optional[str] = None,
    api_key: Optional[str] = None,
) -> ClarityReport:
    """Run the intent stage on a task. Raises on a hard provider/parse failure;
    callers that must never block (e.g. generation) should wrap this — see
    `analyze_clarity_best_effort`."""
    # Imported here to avoid a circular import (generator imports nothing from us,
    # but we reuse its provider router and tolerant JSON loader).
    from .generator import _call_llm, _load_json_object

    raw = _call_llm(
        _build_clarify_system_prompt(),
        _build_clarify_user_prompt(task, probe),
        provider,
        model,
        api_key,
    )
    data = _load_json_object(raw)
    if not isinstance(data, dict):
        raise ValueError("Clarify stage returned JSON, but not an object.")
    return _report_from_llm(data, provider=provider, model=model or "")


def analyze_clarity_best_effort(
    task: str,
    probe: RepoProbe,
    provider: str = "openai",
    model: Optional[str] = None,
    api_key: Optional[str] = None,
) -> Optional[ClarityReport]:
    """Like `analyze_clarity` but never raises — returns None on any failure.
    Used by the Work Order generator, where a missing intent read must degrade
    gracefully rather than abort packaging."""
    try:
        return analyze_clarity(task, probe, provider, model, api_key)
    except Exception:
        return None


# ── Report assembly ────────────────────────────────────────────────────────────

def _report_from_llm(data: dict, provider: str, model: str) -> ClarityReport:
    score = _clamp_score(data.get("underspecification_score"))

    missing = _normalize_missing(data.get("missing_information"))
    safe = _clean_str_list(data.get("safe_assumptions"))
    unsafe = _clean_str_list(data.get("unsafe_assumptions"))
    tags = _clean_str_list(data.get("ambiguity_tags"))

    questions = [m["question"] for m in missing if m.get("question")]
    blocked = [m["question"] for m in missing if m.get("blocking") and m.get("question")]

    # A task is blocked if it scores past the threshold, OR something concretely
    # blocking is missing, OR there is an unsafe assumption with no blocking
    # question naming it (the model flagged danger but did not turn it into a
    # question — surface it anyway).
    required = score >= BLOCK_THRESHOLD or bool(blocked) or bool(unsafe and not blocked)

    return ClarityReport(
        status="blocked" if required else "ready",
        underspecification_score=score,
        intent_confidence=_confidence_from_score(score),
        missing_information=missing,
        safe_assumptions=safe,
        unsafe_assumptions=unsafe,
        ambiguity_tags=tags,
        clarification_questions=questions,
        blocked_until_answered=blocked,
        provider=provider,
        model=model,
    )


def _normalize_missing(value) -> list:
    """Coerce missing_information into [{type, question, blocking}] and infer
    `blocking` from the type when the model did not say."""
    if not isinstance(value, list):
        return []
    out = []
    for item in value:
        if isinstance(item, dict):
            mtype = str(item.get("type", "")).strip() or "scope"
            question = str(item.get("question", "")).strip()
            blocking = item.get("blocking")
        elif isinstance(item, str):
            mtype, question, blocking = "scope", item.strip(), None
        else:
            continue
        if not question:
            continue
        if not isinstance(blocking, bool):
            blocking = mtype.lower() in HARD_TYPES
        out.append({"type": mtype, "question": question, "blocking": blocking})
    return out


def _clean_str_list(value) -> list:
    if not isinstance(value, list):
        return []
    seen, out = set(), []
    for item in value:
        text = str(item).strip()
        if text and text not in seen:
            seen.add(text)
            out.append(text)
    return out


def _clamp_score(value) -> float:
    try:
        score = float(value)
    except (TypeError, ValueError):
        return 0.0
    return round(max(0.0, min(1.0, score)), 2)


def _confidence_from_score(score: float) -> str:
    if score < 0.34:
        return "high"
    if score < 0.67:
        return "medium"
    return "low"


# ── Prompts ──────────────────────────────────────────────────────────────────

def _build_clarify_system_prompt() -> str:
    type_list = ", ".join(MISSING_INFO_TYPES)
    return (
        "You are the INTENT stage of Sembl. You run BEFORE any code is scoped or "
        "written. Your only job is to judge whether a development task is specified "
        "well enough to execute safely — and if not, to name exactly what is missing.\n\n"
        "You do not write code. You do not propose a solution. You decide: is this "
        "ready to scope, or must a human answer something first?\n\n"
        "Core principle: do NOT manufacture false certainty. A capable executor "
        "handed a vague task will assume its way to a confident wrong change. Your "
        "value is catching that before it happens. But do not interrogate a task "
        "that is already clear — a needless question has a cost too.\n\n"
        "Distinguish two kinds of assumption:\n"
        "- SAFE: a default any reasonable engineer would pick and that is cheap to "
        "reverse (e.g. naming, log wording, where a helper lives).\n"
        "- UNSAFE: an assumption that, if wrong, causes schema churn, scope creep, "
        "data loss, security exposure, or a breaking API/behaviour change. These must "
        "become questions, not guesses.\n\n"
        f"Classify each missing item with a `type` from: {type_list}. Mark "
        "`blocking: true` when execution genuinely cannot proceed safely without the "
        "answer; `blocking: false` when a safe assumption lets work continue.\n\n"
        "Output ONLY valid JSON, no markdown, no prose, matching exactly:\n"
        "{\n"
        '  "underspecification_score": 0.0,            // 0.0 fully specified .. 1.0 hopelessly vague\n'
        '  "missing_information": [\n'
        '    {"type": "data_model", "question": "...", "blocking": true}\n'
        "  ],\n"
        '  "safe_assumptions": ["assumptions you would make and proceed on"],\n'
        '  "unsafe_assumptions": ["assumptions that would be dangerous to make silently"],\n'
        '  "ambiguity_tags": ["short_snake_case labels e.g. scope_unclear, acceptance_criteria_missing"]\n'
        "}\n\n"
        "Calibrate the score to the questions: if there are blocking unknowns the "
        "score should be high (>= 0.6); if everything missing is safely assumable, "
        "keep it low. Ground questions in THIS task and repo — never generic."
    )


def _build_clarify_user_prompt(task: str, probe: RepoProbe) -> str:
    sections = [f"TASK:\n{task}"]

    repo_lines = [
        f"Name: {probe.project_name or 'unknown'}",
        f"Type: {probe.project_type or 'unknown'}",
        f"Languages: {', '.join(probe.primary_languages) or 'unknown'}",
        f"Frameworks: {', '.join(probe.framework_hints) or 'none detected'}",
    ]
    if probe.top_level_dirs:
        repo_lines.append(f"Top-level dirs: {', '.join(probe.top_level_dirs[:20])}")
    sections.append("REPO CONTEXT (for grounding questions, not for solving):\n" + "\n".join(repo_lines))

    if probe.readme_summary:
        sections.append(f"README (first 1200 chars):\n{probe.readme_summary[:1200]}")

    if probe.project_rules:
        sections.append("PROJECT RULES:\n" + "\n\n".join(probe.project_rules))

    return "\n\n---\n\n".join(sections)
