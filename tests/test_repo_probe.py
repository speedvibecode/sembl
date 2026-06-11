import os
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch

from sembl.repo_probe import (
    RepoProbe,
    _crg_common_args,
    _crg_data_dir,
    _crg_env,
    _crg_status_is_empty,
    _probe_crg,
    _subprocess_env,
)


class RepoProbeCrgEnvTests(unittest.TestCase):
    def test_crg_common_args_accepts_repo_scoped_crg_data_dir(self):
        with patch.dict(os.environ, {"CRG_DATA_DIR": "C:/tmp/repo"}, clear=True):
            self.assertEqual(
                _crg_common_args(Path("C:/repo")),
                ["--repo", "C:\\repo", "--data-dir", "C:/tmp/repo"],
            )

    def test_crg_common_args_ignores_stale_generic_crg_data_dir(self):
        with patch.dict(os.environ, {"CRG_DATA_DIR": "C:/tmp/other-repo"}, clear=True):
            data_dir = _crg_data_dir(Path("C:/repo"))

        self.assertTrue(data_dir.endswith(".crg-data\\repo") or data_dir.endswith(".crg-data/repo"))

    def test_sembl_crg_data_dir_takes_precedence(self):
        with patch.dict(
            os.environ,
            {"CRG_DATA_DIR": "C:/tmp/crg", "SEMBL_CRG_DATA_DIR": "C:/tmp/sembl-crg"},
            clear=True,
        ):
            self.assertEqual(
                _crg_common_args(Path("C:/repo")),
                ["--repo", "C:\\repo", "--data-dir", "C:/tmp/sembl-crg"],
            )

    def test_crg_env_sets_python_io_encoding(self):
        with patch.dict(os.environ, {"CRG_DATA_DIR": "C:/tmp/repo"}, clear=True):
            env = _crg_env(Path("C:/repo"))

        self.assertEqual(env["CRG_DATA_DIR"], "C:/tmp/repo")
        self.assertEqual(env["SEMBL_CRG_DATA_DIR"], "C:/tmp/repo")
        self.assertEqual(env["PYTHONIOENCODING"], "utf-8")
        self.assertTrue(env["USERPROFILE"].endswith(".crg-home"))

    def test_subprocess_env_defaults_to_utf8(self):
        with patch.dict(os.environ, {}, clear=True):
            env = _subprocess_env()

        self.assertEqual(env["PYTHONIOENCODING"], "utf-8")


class CrgStatusIsEmptyTests(unittest.TestCase):
    def test_zero_nodes_is_empty(self):
        self.assertTrue(_crg_status_is_empty("Nodes: 0\nEdges: 0\nLast updated: never"))

    def test_never_updated_is_empty(self):
        self.assertTrue(_crg_status_is_empty("Last updated: never"))

    def test_populated_graph_is_not_empty(self):
        self.assertFalse(
            _crg_status_is_empty("Nodes: 120\nEdges: 340\nLast updated: 2026-06-10")
        )

    def test_unrecognised_output_is_not_empty(self):
        self.assertFalse(_crg_status_is_empty("some unrelated output"))


class ProbeCrgEmptyGraphTests(unittest.TestCase):
    """CRG 2.3.5 `status` exits 0 on an empty/absent DB; the probe must still build."""

    EMPTY_STATUS = "Nodes: 0\nEdges: 0\nLast updated: never"
    POPULATED_STATUS = "Nodes: 120\nEdges: 340\nLanguages: python\nLast updated: 2026-06-11"

    def _run_probe(self, status_outputs, build_returncode=0):
        statuses = list(status_outputs)
        calls = []

        def fake_run(cmd, cwd, *, timeout, env=None):
            verb = cmd[1]
            calls.append(verb)
            if verb == "status":
                return subprocess.CompletedProcess(cmd, 0, statuses.pop(0), "")
            if verb == "build":
                return subprocess.CompletedProcess(cmd, build_returncode, "", "")
            raise AssertionError(f"unexpected crg verb: {verb}")

        p = RepoProbe()
        with patch.dict(os.environ, {"CRG_DATA_DIR": "C:/tmp/repo"}, clear=True), \
                patch("sembl.repo_probe._resolve_cli", return_value="code-review-graph"), \
                patch("sembl.repo_probe._run_optional", side_effect=fake_run):
            _probe_crg(p, Path("C:/repo"), task="")
        return p, calls

    def test_empty_status_triggers_build_and_restatus(self):
        p, calls = self._run_probe([self.EMPTY_STATUS, self.POPULATED_STATUS])

        self.assertEqual(calls, ["status", "build", "status"])
        self.assertTrue(p.crg_available)
        self.assertEqual(p.crg_node_count, 120)
        self.assertEqual(p.crg_edge_count, 340)

    def test_populated_status_skips_build(self):
        p, calls = self._run_probe([self.POPULATED_STATUS])

        self.assertEqual(calls, ["status"])
        self.assertTrue(p.crg_available)
        self.assertEqual(p.crg_node_count, 120)

    def test_failed_build_leaves_crg_unavailable(self):
        p, calls = self._run_probe([self.EMPTY_STATUS], build_returncode=1)

        self.assertEqual(calls, ["status", "build"])
        self.assertFalse(p.crg_available)
        self.assertEqual(p.crg_node_count, 0)


if __name__ == "__main__":
    unittest.main()
