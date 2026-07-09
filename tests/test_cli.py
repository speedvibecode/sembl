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


class VerifyAcceptanceFlagTests(unittest.TestCase):
    """`--acceptance <file.json>` wires the O12 behavioral axis into `sembl verify`."""

    def test_acceptance_flag_blocks_on_declared_fail(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            (repo / "src" / "a.py").write_text("FIXED\n", encoding="utf-8")
            acc_file = repo / "acc.json"
            acc_file.write_text(json.dumps({
                "declared": [{"id": "chk-1", "kind": "example", "profile": "command"}],
                "results": [{"id": "chk-1", "outcome": "FAIL", "detail": "assert failed"}],
            }), encoding="utf-8")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo),
                 "--acceptance", str(acc_file), "--json"])
        payload = json.loads(result.output)
        self.assertEqual(payload["verdict"], "BLOCK")
        self.assertTrue(payload["behavioral_failures"])
        self.assertEqual(result.exit_code, 1)

    def test_no_acceptance_flag_is_back_compat_noop(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            (repo / "src" / "a.py").write_text("FIXED\n", encoding="utf-8")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--json"])
        payload = json.loads(result.output)
        self.assertEqual(payload["verdict"], "PASS")
        self.assertEqual(payload["behavioral_failures"], [])
        self.assertEqual(payload["behavioral_errors"], [])
        self.assertEqual(payload["behavioral_missing"], [])


class VerifyStagedTests(unittest.TestCase):
    """--staged gates the index (the commit being made), not the whole worktree."""

    def _run_git(self, repo: Path, *args):
        subprocess.run(["git", *args], cwd=str(repo), check=True,
                       capture_output=True, text=True)

    def test_staged_ignores_unstaged_worktree_noise(self):
        # An out-of-scope UNSTAGED edit must not pollute the verdict on the
        # staged, in-scope change — the pre-commit-hook scenario.
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)                       # editable: src/a.py only
            (repo / "src" / "a.py").write_text("FIXED\n", encoding="utf-8")
            self._run_git(repo, "add", "src/a.py")
            (repo / "src" / "b.py").write_text("UNSTAGED WIP\n", encoding="utf-8")

            staged = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--staged", "--strict"])
            worktree = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--strict"])
        self.assertEqual(staged.exit_code, 0, staged.output)
        self.assertIn("PASS", staged.output)
        # sanity: the default worktree mode DOES see the noise
        self.assertEqual(worktree.exit_code, 1)

    def test_staged_catches_a_staged_forbidden_edit(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo, forbidden_areas=["src/b.py"])
            (repo / "src" / "b.py").write_text("SNEAKY\n", encoding="utf-8")
            self._run_git(repo, "add", "src/b.py")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--staged"])
        self.assertEqual(result.exit_code, 1)
        self.assertIn("BLOCK", result.output)

    def test_staged_and_diff_are_mutually_exclusive(self):
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _init_repo(repo)
            wo = _write_wo(repo)
            patch_file = repo / "x.patch"
            patch_file.write_text("", encoding="utf-8")
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo),
                 "--staged", "--diff", str(patch_file)])
        self.assertEqual(result.exit_code, 1)
        self.assertIn("mutually exclusive", result.output)

    def test_staged_works_on_an_unborn_branch(self):
        # The repo's very first commit: git diff --cached diffs the empty tree.
        runner = CliRunner()
        with TemporaryDirectory() as tmp:
            repo = Path(tmp)
            self._run_git(repo, "init", "-q")
            self._run_git(repo, "config", "user.email", "t@example.com")
            self._run_git(repo, "config", "user.name", "t")
            (repo / "src").mkdir()
            (repo / "src" / "a.py").write_text("NEW\n", encoding="utf-8")
            self._run_git(repo, "add", "-A")
            wo = _write_wo(repo)
            result = runner.invoke(cli.main,
                ["verify", "--repo", tmp, "--wo-file", str(wo), "--staged"])
        self.assertEqual(result.exit_code, 0, result.output)
        self.assertIn("PASS", result.output)


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


class FindWoDirTests(unittest.TestCase):
    def test_latest_is_by_contract_file_mtime_not_dir_mtime(self):
        # rewriting work-order.json in an EXISTING slug dir doesn't bump the dir
        # mtime — "latest" must follow the contract file's own timestamp
        import time
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            wo_root = root / ".sembl" / "work-orders"
            old, new = wo_root / "old-slug", wo_root / "new-slug"
            for d in (old, new):
                d.mkdir(parents=True)
                (d / "work-order.json").write_text("{}", encoding="utf-8")
            now = time.time()
            # new-slug's DIR looks newest, but old-slug's FILE was regenerated last
            os.utime(old / "work-order.json", (now + 100, now + 100))
            os.utime(new / "work-order.json", (now, now))
            os.utime(new, (now + 200, now + 200))
            self.assertEqual(cli._find_wo_dir(root, None), old)

    def test_dir_without_contract_never_shadows_one_with(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            wo_root = root / ".sembl" / "work-orders"
            has = wo_root / "has-contract"
            has.mkdir(parents=True)
            (has / "work-order.json").write_text("{}", encoding="utf-8")
            (wo_root / "empty-but-newer").mkdir()
            self.assertEqual(cli._find_wo_dir(root, None), has)


if __name__ == "__main__":
    unittest.main()
