import os
import unittest
from tempfile import TemporaryDirectory
from unittest.mock import patch

from click.testing import CliRunner

from sembl import cli


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
