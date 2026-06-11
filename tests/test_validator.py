"""sembl validate: diff-vs-contract scope check + executor report integrity."""

import json
import subprocess
from pathlib import Path

import pytest

from sembl.validator import (
    load_report,
    validate_against_work_order,
)


@pytest.fixture()
def git_repo(tmp_path):
    def run(*args):
        subprocess.run(
            ["git", *args], cwd=str(tmp_path), check=True,
            capture_output=True, text=True,
        )

    run("init", "-q")
    run("config", "user.email", "test@example.com")
    run("config", "user.name", "test")
    (tmp_path / "httpie").mkdir()
    (tmp_path / "httpie" / "ssl_.py").write_text("ORIGINAL", encoding="utf-8")
    (tmp_path / "httpie" / "core.py").write_text("ORIGINAL", encoding="utf-8")
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs" / "readme.md").write_text("ORIGINAL", encoding="utf-8")
    run("add", "-A")
    run("commit", "-q", "-m", "base")
    return tmp_path


WO = {
    "editable_paths": ["httpie/ssl_.py"],
    "forbidden_areas": ["docs/"],
}


def test_clean_tree_passes(git_repo):
    result = validate_against_work_order(str(git_repo), WO)
    assert result.ok
    assert result.changed_files == []


def test_in_scope_change_passes(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.ok
    assert result.in_scope == ["httpie/ssl_.py"]


def test_out_of_scope_change_fails(git_repo):
    (git_repo / "httpie" / "core.py").write_text("CHANGED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert not result.ok
    assert result.out_of_scope == ["httpie/core.py"]


def test_forbidden_change_fails(git_repo):
    (git_repo / "docs" / "readme.md").write_text("CHANGED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert not result.ok
    assert result.forbidden_hits == ["docs/readme.md"]


def test_new_test_file_counts_as_in_scope(git_repo):
    tests_dir = git_repo / "tests"
    tests_dir.mkdir()
    (tests_dir / "test_ssl.py").write_text("def test(): pass", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.ok
    assert result.in_scope == ["tests/test_ssl.py"]


def test_fabricated_claims_are_detected(git_repo):
    # qwen2.5-coder:7b reproduction: a complete success report with zero edits.
    report = {
        "changes": [
            {"file": "httpie/ssl_.py", "description": "Added cert loading"},
        ],
        "tests": {"added": ["tests/test_ssl.py::test_system_certs"]},
    }
    result = validate_against_work_order(str(git_repo), WO, report)
    assert not result.ok
    assert result.fabricated_claims == ["httpie/ssl_.py"]


def test_honest_report_passes(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {"files_modified": ["httpie/ssl_.py"]}
    result = validate_against_work_order(str(git_repo), WO, report)
    assert result.ok
    assert result.fabricated_claims == []
    assert result.unreported_changes == []


def test_unreported_changes_are_flagged_but_not_fatal(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO, {"files_modified": []})
    assert result.unreported_changes == ["httpie/ssl_.py"]
    assert result.ok  # in-scope work that wasn't claimed is suspicious, not fatal


def test_load_report_tolerates_json_fence(tmp_path):
    path = tmp_path / "report.txt"
    path.write_text('```json\n{"files_modified": ["a.py"]}\n```', encoding="utf-8")
    assert load_report(str(path)) == {"files_modified": ["a.py"]}
