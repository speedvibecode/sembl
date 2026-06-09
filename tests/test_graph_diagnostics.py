import os
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

from sembl.graph_diagnostics import (
    GraphDiagnostics,
    detect,
    resolve_graph_plan,
    repair_commands,
    tools_missing,
)


def _diag(**kw) -> GraphDiagnostics:
    return GraphDiagnostics(repo_path="C:/repo", **kw)


class ResolveGraphPlanTests(unittest.TestCase):
    def test_off_skips_graph(self):
        action, _ = resolve_graph_plan("off", _diag(graphify_graph="present"))
        self.assertEqual(action, "off")

    def test_required_uses_when_available(self):
        action, msg = resolve_graph_plan(
            "required",
            _diag(graphify_path="/x/graphify", graphify_graph="present"),
        )
        self.assertEqual(action, "use")
        self.assertIn("Graphify", msg)

    def test_required_fails_when_unavailable(self):
        action, msg = resolve_graph_plan("required", _diag())
        self.assertEqual(action, "fail")
        self.assertIn("no graph context", msg.lower())

    def test_auto_falls_back_when_unavailable(self):
        action, _ = resolve_graph_plan("auto", _diag())
        self.assertEqual(action, "fallback")

    def test_auto_uses_when_crg_present(self):
        action, msg = resolve_graph_plan(
            "auto",
            _diag(crg_path="/x/crg", crg_status="present", crg_nodes=194),
        )
        self.assertEqual(action, "use")
        self.assertIn("194", msg)

    def test_failure_message_is_specific(self):
        d = _diag(graphify_path="/x/graphify", graphify_graph="missing",
                  crg_path="/x/crg", crg_status="empty")
        _, msg = resolve_graph_plan("required", d)
        self.assertIn("graph is not built", msg)
        self.assertIn("empty", msg)


class RepairCommandTests(unittest.TestCase):
    def test_missing_tools_suggests_install(self):
        cmds = repair_commands(_diag())
        self.assertTrue(any("pip install" in c for c in cmds))

    def test_installed_tools_suggest_builds_not_install(self):
        d = _diag(graphify_path="/x/graphify", crg_path="/x/crg",
                  graphify_graph="missing", crg_status="missing", crg_data_dir="C:/dd")
        cmds = repair_commands(d)
        self.assertTrue(any("graphify update" in c for c in cmds))
        self.assertTrue(any("code-review-graph build" in c for c in cmds))
        self.assertFalse(any("pip install" in c for c in cmds))

    def test_tools_missing_helper(self):
        self.assertTrue(tools_missing(_diag()))
        self.assertFalse(tools_missing(_diag(graphify_path="/g", crg_path="/c")))


class DetectTests(unittest.TestCase):
    def test_detect_reports_openrouter_provider_key(self):
        with TemporaryDirectory() as tmp, patch.dict(
            os.environ,
            {"OPENROUTER_API_KEY": "set"},
            clear=True,
        ):
            with patch("sembl.graph_diagnostics._resolve_cli", return_value=None):
                d = detect(str(tmp))
            self.assertTrue(d.provider_keys["openrouter"])

    def test_detects_graphify_graph_artifact(self):
        with TemporaryDirectory() as tmp, patch.dict(os.environ, {}, clear=True):
            root = Path(tmp)
            (root / "graphify-out").mkdir()
            (root / "graphify-out" / "graph.json").write_text('{"nodes":[]}', encoding="utf-8")
            with patch("sembl.graph_diagnostics._resolve_cli", return_value=None):
                d = detect(str(root))
            self.assertEqual(d.graphify_graph, "present")
            self.assertFalse(d.graphify_installed)
            self.assertFalse(d.graph_available)

    def test_graphify_artifact_is_available_when_tool_is_installed(self):
        with TemporaryDirectory() as tmp, patch.dict(os.environ, {}, clear=True):
            root = Path(tmp)
            (root / "graphify-out").mkdir()
            (root / "graphify-out" / "graph.json").write_text('{"nodes":[]}', encoding="utf-8")
            with patch("sembl.graph_diagnostics._resolve_cli", return_value="/x/graphify"):
                d = detect(str(root))
            self.assertEqual(d.graphify_graph, "present")
            self.assertTrue(d.graphify_installed)
            self.assertTrue(d.graph_available)

    def test_missing_everything_is_unavailable(self):
        with TemporaryDirectory() as tmp, patch.dict(os.environ, {}, clear=True):
            with patch("sembl.graph_diagnostics._resolve_cli", return_value=None):
                d = detect(str(tmp))
            self.assertEqual(d.graphify_graph, "missing")
            self.assertEqual(d.crg_status, "missing")
            self.assertFalse(d.graph_available)
            self.assertTrue(any(c.status == "missing" for c in d.checks))


class GenerateRequiredModeTests(unittest.TestCase):
    def test_required_unavailable_fails_before_llm(self):
        from click.testing import CliRunner
        from sembl import cli

        with TemporaryDirectory() as tmp:
            with patch.object(cli, "detect", return_value=GraphDiagnostics(repo_path=tmp)), \
                 patch.object(cli, "generate_work_order",
                              side_effect=AssertionError("LLM must not be called")), \
                 patch.object(cli, "probe_repo",
                              side_effect=AssertionError("probe must not run")):
                result = CliRunner().invoke(
                    cli.main,
                    ["generate", "-r", tmp, "-t", "fix login", "--graph-mode", "required"],
                )
        self.assertEqual(result.exit_code, 1)
        self.assertNotIsInstance(result.exception, AssertionError)
        self.assertIn("unavailable", result.output.lower())
        self.assertIn('pip install "sembl[graph-pipeline]"', result.output)


if __name__ == "__main__":
    unittest.main()
