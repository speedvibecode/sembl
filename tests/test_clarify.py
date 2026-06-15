"""sembl clarify: intent-stage underspecification analysis + Work Order embedding."""

import json
import unittest
from unittest.mock import patch

from sembl.clarify import (
    BLOCK_THRESHOLD,
    ClarityReport,
    analyze_clarity,
    analyze_clarity_best_effort,
    _confidence_from_score,
    _normalize_missing,
    _report_from_llm,
)
from sembl.generator import WorkOrder, _embed_clarity_report, _merge_clarification_into_contract
from sembl.repo_probe import RepoProbe


def _raw(score, missing=None, safe=None, unsafe=None, tags=None) -> str:
    return json.dumps({
        "underspecification_score": score,
        "missing_information": missing or [],
        "safe_assumptions": safe or [],
        "unsafe_assumptions": unsafe or [],
        "ambiguity_tags": tags or [],
    })


class ScoreMappingTests(unittest.TestCase):
    def test_confidence_bands(self):
        self.assertEqual(_confidence_from_score(0.0), "high")
        self.assertEqual(_confidence_from_score(0.33), "high")
        self.assertEqual(_confidence_from_score(0.5), "medium")
        self.assertEqual(_confidence_from_score(0.66), "medium")
        self.assertEqual(_confidence_from_score(0.9), "low")

    def test_score_clamped_and_rounded(self):
        report = _report_from_llm({"underspecification_score": 1.7}, "openai", "m")
        self.assertEqual(report.underspecification_score, 1.0)
        report = _report_from_llm({"underspecification_score": "garbage"}, "openai", "m")
        self.assertEqual(report.underspecification_score, 0.0)


class StatusGatingTests(unittest.TestCase):
    def test_low_score_no_blockers_is_ready(self):
        report = _report_from_llm(json.loads(_raw(0.1)), "openai", "m")
        self.assertEqual(report.status, "ready")
        self.assertFalse(report.clarification_required)

    def test_high_score_blocks(self):
        report = _report_from_llm(json.loads(_raw(0.8)), "openai", "m")
        self.assertEqual(report.status, "blocked")

    def test_blocking_question_blocks_even_on_moderate_score(self):
        missing = [{"type": "product_behavior", "question": "Which schedules?", "blocking": True}]
        report = _report_from_llm(json.loads(_raw(0.3, missing=missing)), "openai", "m")
        self.assertEqual(report.status, "blocked")
        self.assertEqual(report.blocked_until_answered, ["Which schedules?"])

    def test_unsafe_assumption_without_question_still_blocks(self):
        report = _report_from_llm(
            json.loads(_raw(0.2, unsafe=["assuming a recurrence model causes schema churn"])),
            "openai", "m",
        )
        self.assertEqual(report.status, "blocked")


class NormalizeMissingTests(unittest.TestCase):
    def test_hard_type_infers_blocking_when_unspecified(self):
        out = _normalize_missing([{"type": "data_model", "question": "eager or lazy rows?"}])
        self.assertTrue(out[0]["blocking"])

    def test_soft_type_infers_non_blocking(self):
        out = _normalize_missing([{"type": "product_behavior", "question": "label text?"}])
        self.assertFalse(out[0]["blocking"])

    def test_plain_string_item_is_coerced(self):
        out = _normalize_missing(["just a bare question"])
        self.assertEqual(out[0]["question"], "just a bare question")
        self.assertEqual(out[0]["type"], "scope")

    def test_empty_questions_dropped(self):
        self.assertEqual(_normalize_missing([{"type": "scope", "question": ""}]), [])


class AnalyzeClarityTests(unittest.TestCase):
    def test_parses_provider_json(self):
        probe = RepoProbe(repo_path="C:/repo", project_name="demo")
        missing = [{"type": "data_model", "question": "eager or lazy?", "blocking": True}]
        with patch("sembl.generator._call_llm", return_value=_raw(0.7, missing=missing)):
            report = analyze_clarity("add recurring expenses", probe)
        self.assertIsInstance(report, ClarityReport)
        self.assertTrue(report.clarification_required)
        self.assertEqual(report.clarification_questions, ["eager or lazy?"])

    def test_best_effort_swallows_failure(self):
        probe = RepoProbe(repo_path="C:/repo")
        with patch("sembl.generator._call_llm", side_effect=RuntimeError("provider down")):
            self.assertIsNone(analyze_clarity_best_effort("task", probe))

    def test_best_effort_swallows_bad_json(self):
        probe = RepoProbe(repo_path="C:/repo")
        with patch("sembl.generator._call_llm", return_value="not json at all"):
            self.assertIsNone(analyze_clarity_best_effort("task", probe))


class WorkOrderEmbeddingTests(unittest.TestCase):
    def test_embed_copies_fields(self):
        report = ClarityReport(
            status="blocked",
            underspecification_score=0.7,
            intent_confidence="low",
            safe_assumptions=["snake_case naming"],
            unsafe_assumptions=["assume a recurrence model"],
            blocked_until_answered=["Which schedules?"],
            ambiguity_tags=["scope_unclear"],
            clarification_questions=["Which schedules?"],
        )
        wo = WorkOrder()
        _embed_clarity_report(wo, report)
        self.assertTrue(wo.clarification_required)
        self.assertEqual(wo.intent_confidence, "low")
        self.assertEqual(wo.assumptions, ["snake_case naming"])
        self.assertEqual(wo.unsafe_assumptions, ["assume a recurrence model"])
        self.assertEqual(wo.blocked_until_answered, ["Which schedules?"])

    def test_embed_accepts_dict(self):
        wo = WorkOrder()
        _embed_clarity_report(wo, {
            "intent_confidence": "medium",
            "underspecification_score": 0.5,
            "clarification_required": True,
            "blocked_until_answered": ["q?"],
        })
        self.assertEqual(wo.intent_confidence, "medium")
        self.assertTrue(wo.clarification_required)

    def test_blocked_questions_become_stop_conditions(self):
        wo = WorkOrder(
            blocked_until_answered=["Which schedules are supported?"],
            unsafe_assumptions=["assume a recurrence model"],
        )
        _merge_clarification_into_contract(wo)
        self.assertTrue(any("Which schedules" in c for c in wo.stop_conditions))
        self.assertTrue(any("unsafe assumption" in t for t in wo.approval_triggers))


if __name__ == "__main__":
    unittest.main()
