import json
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from sembl.generator import WorkOrder
from sembl.output import write_work_order


class OutputWriterTests(unittest.TestCase):
    def test_markdown_outputs_are_ascii_safe(self):
        with TemporaryDirectory() as tmp:
            wo = WorkOrder(
                id="wo-test-1",
                repo_name="repo",
                git_branch="main",
                risk_level="medium",
                task_type="bugfix",
                created_at="2026-06-06T00:00:00+00:00",
                original_request="fix redirect",
                clarified_goal="Fix redirect - safely",
                user_visible_outcome="Users don't see an open redirect",
                acceptance_criteria=["Callback URL is local -> safe"],
                executor_prompt="Change LoginForm - do not touch tests.",
            )

            out_dir = write_work_order(wo, tmp)

            for name in ["work-order.md", "executor-prompt.md", "validation-plan.md"]:
                content = (out_dir / name).read_text(encoding="utf-8")
                content.encode("ascii")

            work_order = (out_dir / "work-order.md").read_text(encoding="utf-8")
            self.assertIn("# Work Order - wo-test-1", work_order)
            self.assertIn("**Repo:** `repo` | **Branch:** `main` | **Risk:** `MEDIUM`", work_order)

            data = json.loads((out_dir / "work-order.json").read_text(encoding="utf-8"))
            self.assertEqual(data["id"], "wo-test-1")


if __name__ == "__main__":
    unittest.main()
