import os
import unittest
from pathlib import Path
from unittest.mock import patch

from sembl.repo_probe import _crg_common_args, _crg_data_dir, _crg_env, _subprocess_env


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


if __name__ == "__main__":
    unittest.main()
