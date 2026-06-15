import json
import os
import subprocess
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

from click.testing import CliRunner

from sembl import cli


def _init_repo(path: Path):
    def run(*args):
        subprocess.run(["git", *args], cwd=str(path), check=True,
                       capture_output=True, text=True)
    run("init", "-q")
    run("config", "user.email", "test@example.com")
    run("config", "user.name", "test")
    (path / "src").mkdir()
    (path / "src" / "a.py").write_text("ORIGINAL\n", encoding="utf-8")
    (path / "src" / "b.py").write_text("ORIGINAL\n", encoding="utf-8")
    run("add", "-A")
    run("commit", "-q", "-m", "base")


def _write_wo(path: Path, **overrides):
    # Real WOs live under .sembl/ (ignored by the validator), not as repo sources.
    wo = {"id": "wo-test", "editable_paths": ["src/a.py"], "forbidden_areas": []}
    wo.update(overrides)
    wo_dir = path / ".sembl" / "work-orders" / "wo-test"
    wo_dir.mkdir(parents=True, exist_ok=True)
    (wo_dir / "work-order.json").write_text(json.dumps(wo), encoding="utf-8")
    return wo_dir / "work-order.json"


class VerifyCommandTests(unittest.TestCase):
    def test_pass_on_in_scope_change(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            (repo / "src" / "a.py").write_text("FIXED\n", encoding="utf-8")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo)])
        self.assertEqual(result.exit_code, 0)
        self.assertIn("PASS", result.output)

    def test_out_of_scope_warns_by_default_blocks_with_strict(self):
        # Advisory-scope is the default: an out-of-scope edit WARNs (exit 0) so
        # loose/auto bounds don't false-block legit related changes. --strict
        # promotes scope to a hard BLOCK (exit 1).
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            (repo / "src" / "b.py").write_text("CHANGED\n", encoding="utf-8")
            plain = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo)])
            strict = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--strict"])
        self.assertEqual(plain.exit_code, 0)
        self.assertIn("WARN", plain.output)
        self.assertEqual(strict.exit_code, 1)
        self.assertIn("BLOCK", strict.output)

    def test_json_output_shape(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            (repo / "src" / "b.py").write_text("CHANGED\n", encoding="utf-8")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--json"])
            strict = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--json", "--strict"])
        payload = json.loads(result.output)
        self.assertEqual(payload["verdict"], "WARN")          # advisory default
        self.assertEqual(payload["policy"], "advisory_scope")
        self.assertIn("src/b.py", payload["out_of_scope"])
        self.assertTrue(payload["reasons"])
        self.assertEqual(json.loads(strict.output)["verdict"], "BLOCK")  # --strict

    def test_auto_discovers_bounds_json_at_repo_root(self):
        # Zero-arg verify (for hooks/CI): no --wo-file, but bounds.json exists.
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            (repo / "bounds.json").write_text(
                json.dumps({"editable_paths": ["src/"], "forbidden_areas": []}),
                encoding="utf-8",
            )
            (repo / "src" / "a.py").write_text("FIXED\n", encoding="utf-8")
            result = runner.invoke(cli.main, ["verify", "--repo", tmp, "--json"])
        payload = json.loads(result.output)
        self.assertEqual(payload["verdict"], "PASS")        # in-scope, discovered bounds
        self.assertIn("src/a.py", payload["in_scope"])

    def test_diff_mode_verifies_a_patch_without_worktree(self):
        # CI path: a patch file is scored directly; no working-tree edits needed.
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)  # editable: src/a.py
            patch = repo / "pr.patch"
            patch.write_text(
                "diff --git a/src/b.py b/src/b.py\n"
                "--- a/src/b.py\n+++ b/src/b.py\n"
                "@@ -1 +1 @@\n-x\n+y\n",
                encoding="utf-8",
            )
            warn = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--diff", str(patch), "--json"])
            strict = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--diff", str(patch), "--strict"])
        payload = json.loads(warn.output)
        self.assertIn("src/b.py", payload["changed_files"])
        self.assertEqual(payload["verdict"], "WARN")      # out-of-scope, advisory
        self.assertEqual(strict.exit_code, 1)             # --strict blocks it

    def test_strict_promotes_warn_to_failure(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            # tiny line budget so an in-scope edit trips a churn WARN
            wo = _write_wo(repo, churn_budget={"max_lines": 0})
            (repo / "src" / "a.py").write_text("FIXED\nMORE\n", encoding="utf-8")
            plain = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo)])
            strict = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--strict"])
        self.assertEqual(plain.exit_code, 0)
        self.assertIn("WARN", plain.output)
        self.assertEqual(strict.exit_code, 1)


class CliApiKeyMessageTests(unittest.TestCase):
    def test_missing_provider_key_message_names_provider_and_env_var(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp, patch.dict(os.environ, {}, clear=True):
            result = runner.invoke(
                cli.main,
                [
                    "generate",
                    "--repo",
                    tmp,
                    "--task",
                    "replace starter text",
                    "--provider",
                    "gemini",
                    "--graph-mode",
                    "off",
                ],
            )

        self.assertEqual(result.exit_code, 1)
        self.assertIn("No Gemini API key is set.", result.output)
        self.assertIn("GEMINI_API_KEY", result.output)
        self.assertIn("--api-key", result.output)
        self.assertIn("--provider ollama", result.output)


if __name__ == "__main__":
    unittest.main()
