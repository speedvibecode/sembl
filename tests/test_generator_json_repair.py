import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

from sembl.generator import WorkOrder, _ground_work_order_in_repo, _parse_llm_response, _path_exists
from sembl.repo_probe import RepoProbe


def _raw_work_order(executor_prompt: str) -> str:
    return f"""{{
  "clarified_goal": "Fix login redirect",
  "user_visible_outcome": "Users land in the app",
  "task_type": "bugfix",
  "non_goals": [],
  "must_not_change": [],
  "forbidden_areas": [],
  "likely_affected_areas": ["src/features/auth"],
  "editable_paths": ["src/app/index.tsx"],
  "read_only_context": [],
  "files_to_inspect": [],
  "tests_to_inspect": [],
  "architecture_notes": [],
  "acceptance_criteria": [],
  "regressions_to_preserve": [],
  "validation_commands": [],
  "tests_to_add_or_update": [],
  "manual_checks": [],
  "stop_conditions": [],
  "approval_triggers": [],
  "risk_level": "medium",
  "risk_reasons": [],
  "executor_prompt": "{executor_prompt}",
  "patch_expectations": [],
  "reporting_format": "Report files changed"
}}"""


class GeneratorJsonRepairTests(unittest.TestCase):
    def test_allows_provider_control_chars_inside_strings(self):
        wo = WorkOrder()

        _parse_llm_response(
            _raw_work_order("Line one\nLine two"),
            wo,
            RepoProbe(repo_path="C:/repo"),
        )

        self.assertEqual(wo.executor_prompt, "Line one\nLine two")
        self.assertEqual(wo.editable_paths, ["src/app/index.tsx"])

    def test_extracts_fenced_json(self):
        wo = WorkOrder()

        _parse_llm_response(
            "```json\n" + _raw_work_order("Prompt") + "\n```",
            wo,
            RepoProbe(repo_path="C:/repo"),
        )

        self.assertEqual(wo.executor_prompt, "Prompt")

    def test_extracts_json_from_wrapped_text(self):
        wo = WorkOrder()

        _parse_llm_response(
            "Here is the work order:\n" + _raw_work_order("Prompt") + "\nDone.",
            wo,
            RepoProbe(repo_path="C:/repo"),
        )

        self.assertEqual(wo.executor_prompt, "Prompt")


class GeneratorGroundingTests(unittest.TestCase):
    def test_removes_hallucinated_paths_and_adds_repo_real_graph_paths(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            for path in [
                "src/app/(auth)/login.tsx",
                "src/app/(auth)/_layout.tsx",
                "src/app/auth/callback.tsx",
                "src/app/index.tsx",
                "src/app/(main)/groups/[id]/index.tsx",
                "src/features/auth/api/completeOAuthSession.ts",
                "src/features/auth/hooks/useAuth.ts",
                "src/features/auth/screens/LoginScreen.tsx",
                "src/features/auth/store/auth.store.ts",
                "src/core/supabase/client.ts",
                "package.json",
                "tsconfig.json",
            ]:
                file_path = root / path
                file_path.parent.mkdir(parents=True, exist_ok=True)
                file_path.write_text("export const marker = true;\n", encoding="utf-8")
            (root / "package.json").write_text(
                '{"scripts": {"typecheck": "tsc --noEmit"}}',
                encoding="utf-8",
            )

            wo = WorkOrder(
                original_request="fix the failing login redirect test",
                editable_paths=[
                    "src/app/(auth)/login.tsx",
                    "src/lib/auth/redirects.ts",
                    "src/components/auth/LoginForm.tsx",
                ],
                files_to_inspect=["src/lib/auth/utils.ts"],
                tests_to_inspect=["__tests__/auth/login-redirect.test.tsx"],
                tests_to_add_or_update=["__tests__/auth/login-redirect.test.tsx"],
                validation_commands=[
                    "npm test -- __tests__/auth/login-redirect.test.tsx",
                    "npm run typecheck",
                    "npx expo start --clear && manual test of login flow",
                ],
                executor_prompt="Edit src/lib/auth/redirects.ts and src/components/auth/LoginForm.tsx",
            )
            probe = RepoProbe(
                repo_path=str(root),
                graphify_task_context=(
                    "NODE callback.tsx [src=src/app/auth/callback.tsx]\n"
                    "NODE completeOAuthSession.ts [src=src/features/auth/api/completeOAuthSession.ts]\n"
                    "NODE useAuth.ts [src=src/features/auth/hooks/useAuth.ts]\n"
                    "NODE [id]/index.tsx [src=src/app/(main)/groups/[id]/index.tsx]"
                ),
                lint_commands=["npm run typecheck"],
            )

            _ground_work_order_in_repo(wo, probe)

            self.assertIn("src/app/(auth)/login.tsx", wo.editable_paths)
            self.assertIn("src/features/auth/api/completeOAuthSession.ts", wo.editable_paths)
            self.assertIn("src/app/auth/callback.tsx", wo.editable_paths)
            self.assertNotIn("src/lib/auth/redirects.ts", wo.editable_paths)
            self.assertNotIn("src/components/auth/LoginForm.tsx", wo.editable_paths)
            self.assertNotIn("__tests__/auth/login-redirect.test.tsx", wo.tests_to_inspect)
            self.assertEqual(wo.validation_commands, ["npm run typecheck"])
            self.assertTrue(_path_exists(root, "src/app/(main)/groups/[id]/index.tsx"))
            self.assertTrue(any("No failing test file is present" in s for s in wo.stop_conditions))
            self.assertNotIn("src/lib/auth/redirects.ts", wo.executor_prompt)
            self.assertNotIn("src/components/auth/LoginForm.tsx", wo.executor_prompt)
            self.assertIn("src/features/auth/api/completeOAuthSession.ts", wo.executor_prompt)

    def test_existing_task_related_test_is_preserved_for_validation(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            for path, content in {
                "components/LoginForm.tsx": (
                    "export function LoginForm() { "
                    "return 'login redirect callbackUrl auth session'; "
                    "}\n"
                ),
                "components/LoginForm.test.tsx": (
                    "test('login redirect callbackUrl is local', () => {});\n"
                ),
                "app/api/auth/[...nextauth]/route.ts": "export const auth = true;\n",
            }.items():
                file_path = root / path
                file_path.parent.mkdir(parents=True, exist_ok=True)
                file_path.write_text(content, encoding="utf-8")
            (root / "package.json").write_text(
                '{"scripts": {"test": "vitest run"}}',
                encoding="utf-8",
            )

            wo = WorkOrder(
                original_request="fix the failing login redirect test",
                tests_to_inspect=[],
                validation_commands=[],
                stop_conditions=[],
            )
            probe = RepoProbe(repo_path=str(root))

            _ground_work_order_in_repo(wo, probe)

            self.assertIn("components/LoginForm.test.tsx", wo.tests_to_inspect)
            self.assertNotIn("components/LoginForm.test.tsx", wo.editable_paths)
            self.assertIn("npm test -- components/LoginForm.test.tsx", wo.validation_commands)
            self.assertFalse(any("No failing test file is present" in s for s in wo.stop_conditions))
            self.assertIn("components/LoginForm.test.tsx", wo.executor_prompt)


if __name__ == "__main__":
    unittest.main()
