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


def test_sembl_output_dir_is_ignored(git_repo):
    sembl_dir = git_repo / ".sembl" / "work-orders" / "wo-x"
    sembl_dir.mkdir(parents=True)
    (sembl_dir / "work-order.json").write_text("{}", encoding="utf-8")
    (git_repo / "graphify-out").mkdir()
    (git_repo / "graphify-out" / "graph.json").write_text("{}", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.changed_files == []
    assert result.ok


def test_load_report_tolerates_json_fence(tmp_path):
    path = tmp_path / "report.txt"
    path.write_text('```json\n{"files_modified": ["a.py"]}\n```', encoding="utf-8")
    assert load_report(str(path)) == {"files_modified": ["a.py"]}


# ── verdict layer ───────────────────────────────────────────────────────────


def test_verdict_pass_on_clean_in_scope(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.verdict() == "PASS"
    assert result.reasons() == []


def test_verdict_block_on_out_of_scope(git_repo):
    (git_repo / "httpie" / "core.py").write_text("CHANGED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.verdict() == "BLOCK"
    assert not result.ok


def test_verdict_block_on_forbidden(git_repo):
    (git_repo / "docs" / "readme.md").write_text("CHANGED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.verdict() == "BLOCK"


def test_verdict_warn_on_unreported(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO, {"files_modified": []})
    assert result.verdict() == "WARN"
    assert result.ok  # WARN is not a hard breach


def test_to_dict_carries_verdict_and_reasons(git_repo):
    (git_repo / "httpie" / "core.py").write_text("CHANGED", encoding="utf-8")
    data = validate_against_work_order(str(git_repo), WO).to_dict()
    assert data["verdict"] == "BLOCK"
    assert any("out-of-scope" in r for r in data["reasons"])


# ── broad churn vs budget ─────────────────────────────────────────────────────


def test_churn_within_budget_is_clean(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("line1\nline2\n", encoding="utf-8")
    wo = {**WO, "churn_budget": {"max_files": 5, "max_lines": 100}}
    result = validate_against_work_order(str(git_repo), wo)
    assert result.churn_over_budget == {}
    assert result.verdict() == "PASS"


def test_churn_over_file_budget_warns(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("X", encoding="utf-8")
    (git_repo / "httpie" / "core.py").write_text("X", encoding="utf-8")
    # both files in editable scope so the only finding is churn
    wo = {"editable_paths": ["httpie/"], "churn_budget": {"max_files": 1}}
    result = validate_against_work_order(str(git_repo), wo)
    assert result.churn_over_budget.get("files") == 2
    assert result.churn_over_budget.get("max_files") == 1
    assert result.verdict() == "WARN"


def test_churn_over_line_budget_warns(git_repo):
    body = "\n".join(f"line{i}" for i in range(50)) + "\n"
    (git_repo / "httpie" / "ssl_.py").write_text(body, encoding="utf-8")
    wo = {**WO, "churn_budget": {"max_lines": 10}}
    result = validate_against_work_order(str(git_repo), wo)
    assert result.churn_over_budget.get("max_lines") == 10
    assert result.churn_over_budget.get("lines", 0) > 10
    assert result.verdict() == "WARN"


def test_no_budget_means_no_churn_finding(git_repo):
    body = "\n".join(f"line{i}" for i in range(200)) + "\n"
    (git_repo / "httpie" / "ssl_.py").write_text(body, encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)  # no churn_budget
    assert result.churn_over_budget == {}
    assert result.verdict() == "PASS"


# ── validation actually ran (claim without evidence) ──────────────────────────


def test_validation_claimed_without_evidence_warns(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {"files_modified": ["httpie/ssl_.py"], "tests_passed": True}
    result = validate_against_work_order(str(git_repo), WO, report)
    assert "tests_passed" in result.validation_not_run
    assert result.verdict() == "WARN"


def test_validation_claimed_with_exit_code_is_evidenced(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {"files_modified": ["httpie/ssl_.py"], "tests_passed": True, "exit_code": 0}
    result = validate_against_work_order(str(git_repo), WO, report)
    assert result.validation_not_run == []
    assert result.verdict() == "PASS"


def test_validation_checklist_item_without_evidence_warns(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {
        "files_modified": ["httpie/ssl_.py"],
        "checks": [{"command": "pytest", "status": "passed"}],
    }
    result = validate_against_work_order(str(git_repo), WO, report)
    assert "pytest" in result.validation_not_run


def test_validation_checklist_item_with_output_is_evidenced(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {
        "files_modified": ["httpie/ssl_.py"],
        "checks": [{"command": "pytest", "status": "passed", "output": "5 passed"}],
    }
    result = validate_against_work_order(str(git_repo), WO, report)
    assert result.validation_not_run == []


def test_no_validation_claim_means_no_finding(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    report = {"files_modified": ["httpie/ssl_.py"]}
    result = validate_against_work_order(str(git_repo), WO, report)
    assert result.validation_not_run == []
    assert result.verdict() == "PASS"


# ── verdict policy: advisory_scope (C2 candidate fix) ─────────────────────────


def test_advisory_scope_demotes_out_of_scope_to_warn(tmp_path):
    wo = {"editable_paths": ["src/a.py"], "forbidden_areas": ["docs/"]}
    r = validate_against_work_order(str(tmp_path), wo, changed_files=["src/b.py"])
    assert r.verdict() == "BLOCK"                      # strict
    assert r.verdict("advisory_scope") == "WARN"       # scope is advisory


def test_advisory_scope_still_blocks_forbidden(tmp_path):
    wo = {"editable_paths": ["src/a.py"], "forbidden_areas": ["docs/"]}
    r = validate_against_work_order(str(tmp_path), wo, changed_files=["docs/x.md"])
    assert r.verdict("advisory_scope") == "BLOCK"


def test_advisory_scope_still_blocks_fabrication(tmp_path):
    wo = {"editable_paths": ["src/a.py"]}
    r = validate_against_work_order(
        str(tmp_path), wo, report={"files_modified": ["src/a.py"]}, changed_files=[],
    )
    assert r.fabricated_claims == ["src/a.py"]
    assert r.verdict("advisory_scope") == "BLOCK"


# ── diff mode (no git tree) ───────────────────────────────────────────────────


def test_diff_mode_scopes_without_git(tmp_path):
    # No commits, no working-tree changes — everything comes from changed_files.
    wo = {"editable_paths": ["src/a.py"], "forbidden_areas": ["docs/"]}
    result = validate_against_work_order(
        str(tmp_path), wo,
        changed_files=["src/a.py", "src/b.py", "docs/readme.md"],
    )
    assert result.in_scope == ["src/a.py"]
    assert result.out_of_scope == ["src/b.py"]
    assert result.forbidden_hits == ["docs/readme.md"]
    assert result.verdict() == "BLOCK"


def test_diff_mode_churn_uses_line_count(tmp_path):
    wo = {"editable_paths": ["src/a.py"], "churn_budget": {"max_lines": 10}}
    result = validate_against_work_order(
        str(tmp_path), wo, changed_files=["src/a.py"], diff_line_count=42,
    )
    assert result.churn_over_budget.get("lines") == 42
    assert result.verdict() == "WARN"


def test_diff_mode_empty_changed_files_is_pass(tmp_path):
    wo = {"editable_paths": ["src/a.py"]}
    result = validate_against_work_order(str(tmp_path), wo, changed_files=[])
    assert result.changed_files == []
    assert result.verdict() == "PASS"


def test_eol_only_rewrites_are_not_edits(git_repo, monkeypatch):
    # zod gemini-3-pro cell: a formatter rewrote line endings repo-wide; git
    # status listed ~350 modified files while git diff HEAD (EOL-normalizing)
    # showed only the 2 real edits. EOL-only files must not fail validate.
    import sembl.validator as v

    real_run = subprocess.run

    def fake_run(args, **kwargs):
        if args[:2] == ["git", "status"]:
            out = " M httpie/ssl_.py\n M httpie/core.py\n?? notes.txt\n"
            return subprocess.CompletedProcess(args, 0, stdout=out, stderr="")
        if args[:2] == ["git", "diff"]:
            return subprocess.CompletedProcess(args, 0, stdout="httpie/ssl_.py\n", stderr="")
        return real_run(args, **kwargs)

    monkeypatch.setattr(v.subprocess, "run", fake_run)
    # core.py is EOL-only (in status, not in diff) -> excluded; untracked kept
    assert v._git_changed_files(git_repo) == ["httpie/ssl_.py", "notes.txt"]


# ── parse_unified_diff (diff/patch mode for CI) ──────────────────────────────

SAMPLE_DIFF = """\
diff --git a/src/auth/login.ts b/src/auth/login.ts
index 1111111..2222222 100644
--- a/src/auth/login.ts
+++ b/src/auth/login.ts
@@ -1,3 +1,4 @@
 const x = 1;
-const y = 2;
+const y = 3;
+const z = 4;
diff --git a/infra/deploy.yaml b/infra/deploy.yaml
new file mode 100644
index 0000000..3333333
--- /dev/null
+++ b/infra/deploy.yaml
@@ -0,0 +1,1 @@
+image: app:latest
"""


def test_parse_unified_diff_paths_and_linecount():
    from sembl.validator import parse_unified_diff
    files, lines = parse_unified_diff(SAMPLE_DIFF)
    assert files == ["infra/deploy.yaml", "src/auth/login.ts"]
    # 3 added (+y, +z, +image) + 1 deleted (-y) = 4
    assert lines == 4


def test_parse_unified_diff_handles_deletion():
    from sembl.validator import parse_unified_diff
    deletion = (
        "diff --git a/old/gone.py b/old/gone.py\n"
        "deleted file mode 100644\n"
        "--- a/old/gone.py\n"
        "+++ /dev/null\n"
        "@@ -1,2 +0,0 @@\n"
        "-a\n-b\n"
    )
    files, lines = parse_unified_diff(deletion)
    assert files == ["old/gone.py"]   # /dev/null ignored, path kept from header
    assert lines == 2


def test_verify_diff_mode_matches_worktree_logic():
    from sembl.validator import parse_unified_diff
    wo = {"editable_paths": ["src/auth/"], "forbidden_areas": ["infra/"]}
    files, lines = parse_unified_diff(SAMPLE_DIFF)
    result = validate_against_work_order(".", wo, changed_files=files, diff_line_count=lines)
    assert "src/auth/login.ts" in result.in_scope
    assert "infra/deploy.yaml" in result.forbidden_hits
    assert result.verdict("advisory_scope") == "BLOCK"   # forbidden hit blocks


# ── diff robustness: generated/lockfiles ─────────────────────────────────────

def test_lockfile_and_generated_are_in_scope_not_out():
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    result = validate_against_work_order(
        ".", wo,
        changed_files=["src/app.py", "package-lock.json", "dist/bundle.min.js",
                       "api/__generated__/client.ts"],
    )
    assert result.out_of_scope == []                 # none false-flagged
    assert "package-lock.json" in result.in_scope
    assert "dist/bundle.min.js" in result.in_scope


def test_forbidden_still_wins_over_generated():
    wo = {"editable_paths": ["src/"], "forbidden_areas": ["vendor/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["vendor/pkg/lib.go"],
    )
    assert "vendor/pkg/lib.go" in result.forbidden_hits


def test_churn_excludes_generated_lines():
    # A massive lockfile diff must not trip a small line budget.
    big_lock = "diff --git a/poetry.lock b/poetry.lock\n--- a/poetry.lock\n+++ b/poetry.lock\n"
    big_lock += "".join(f"+dep-{i} = 1.0\n" for i in range(500))
    from sembl.validator import parse_unified_diff
    files, lines = parse_unified_diff(big_lock)
    assert files == ["poetry.lock"]
    assert lines == 0                                 # generated lines not counted
    wo = {"editable_paths": ["src/"], "churn_budget": {"max_lines": 50, "max_files": 1}}
    result = validate_against_work_order(".", wo, changed_files=files, diff_line_count=lines)
    assert result.churn_over_budget == {}             # within budget (lockfile ignored)


# ── broadened executor-report coverage ───────────────────────────────────────

def test_fabrication_detects_camelcase_and_dict_change_shapes():
    wo = {"editable_paths": ["src/"]}
    report = {
        "changedFiles": ["src/real.py"],             # camelCase list
        "changes": {"src/ghost.py": {"summary": "x"}},  # dict-keyed
    }
    result = validate_against_work_order(
        ".", wo, report=report, changed_files=["src/real.py"],
    )
    assert "src/ghost.py" in result.fabricated_claims  # claimed, never changed
    assert "src/real.py" not in result.fabricated_claims


def test_validation_not_run_detects_camelcase_claim():
    wo = {"editable_paths": ["src/"]}
    report = {"testsPassed": True}                    # claim, no evidence
    result = validate_against_work_order(
        ".", wo, report=report, changed_files=["src/a.py"],
    )
    assert "testsPassed" in result.validation_not_run
