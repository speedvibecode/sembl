import unittest
from unittest.mock import patch

from sembl.generator import (
    _build_user_prompt,
    _should_enrich,
    synthesize_graph_impact,
)
from sembl.repo_probe import RepoProbe


class ShouldEnrichTests(unittest.TestCase):
    def test_false_without_any_graph_signal(self):
        self.assertFalse(_should_enrich(RepoProbe(repo_path="C:/repo")))

    def test_true_with_crg_blast_radius(self):
        probe = RepoProbe(repo_path="C:/repo", crg_blast_radius=["3 files impacted"])
        self.assertTrue(_should_enrich(probe))

    def test_true_with_node_counts_only(self):
        probe = RepoProbe(repo_path="C:/repo", crg_node_count=194, crg_edge_count=1115)
        self.assertTrue(_should_enrich(probe))

    def test_true_with_graphify_task_context_only(self):
        probe = RepoProbe(repo_path="C:/repo", graphify_task_context="NODE a [src=a.ts]")
        self.assertTrue(_should_enrich(probe))


class SynthesizeGraphImpactTests(unittest.TestCase):
    def test_skips_llm_call_when_no_signal(self):
        probe = RepoProbe(repo_path="C:/repo")
        with patch(
            "sembl.generator._call_llm",
            side_effect=AssertionError("LLM must not be called without graph signal"),
        ):
            self.assertEqual(synthesize_graph_impact("task", probe), "")

    def test_returns_stripped_text_when_signal_present(self):
        probe = RepoProbe(repo_path="C:/repo", crg_blast_radius=["3 files impacted"])
        with patch("sembl.generator._call_llm", return_value="  **Blast radius**: x  "):
            self.assertEqual(synthesize_graph_impact("task", probe), "**Blast radius**: x")

    def test_degrades_to_empty_when_llm_raises(self):
        probe = RepoProbe(repo_path="C:/repo", crg_node_count=10)
        with patch("sembl.generator._call_llm", side_effect=RuntimeError("provider down")):
            self.assertEqual(synthesize_graph_impact("task", probe), "")


class UserPromptInjectionTests(unittest.TestCase):
    def test_injects_impact_section_when_present(self):
        probe = RepoProbe(repo_path="C:/repo")
        prompt = _build_user_prompt("task", probe, "**Blast radius**: auth module")
        self.assertIn("GRAPH IMPACT ANALYSIS", prompt)
        self.assertIn("**Blast radius**: auth module", prompt)

    def test_omits_impact_section_when_empty(self):
        probe = RepoProbe(repo_path="C:/repo")
        prompt = _build_user_prompt("task", probe)
        self.assertNotIn("GRAPH IMPACT ANALYSIS", prompt)


if __name__ == "__main__":
    unittest.main()
