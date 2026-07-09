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


def test_git_changed_files_raises_on_nonzero_exit(git_repo, monkeypatch):
    # A failed `git status` (bad --repo, non-git dir, ownership rejection) must
    # never look like "nothing changed" -> silent PASS (codex review finding).
    import sembl.validator as v

    def fake_run(args, **kwargs):
        return subprocess.CompletedProcess(args, 128, stdout="", stderr="fatal: not a git repository")

    monkeypatch.setattr(v.subprocess, "run", fake_run)
    with pytest.raises(RuntimeError):
        v._git_changed_files(git_repo)


def test_git_changed_files_raises_on_subprocess_exception(git_repo, monkeypatch):
    import sembl.validator as v

    def fake_run(args, **kwargs):
        raise OSError("git not found")

    monkeypatch.setattr(v.subprocess, "run", fake_run)
    with pytest.raises(RuntimeError):
        v._git_changed_files(git_repo)


def test_validate_against_work_order_propagates_git_failure(git_repo, monkeypatch):
    import sembl.validator as v

    def fake_run(args, **kwargs):
        return subprocess.CompletedProcess(args, 128, stdout="", stderr="fatal: not a git repository")

    monkeypatch.setattr(v.subprocess, "run", fake_run)
    with pytest.raises(RuntimeError):
        validate_against_work_order(str(git_repo), WO)


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


def test_parse_unified_diff_pure_rename_with_space_in_path():
    # A pure rename has no content diff -> no +++/--- lines, so `diff --git`'s
    # naive space-split is the only thing that would otherwise see the new path
    # — and it mis-splits when the path contains a space. `rename to` gives the
    # exact, unambiguous new path (codex review finding).
    from sembl.validator import parse_unified_diff
    rename = (
        "diff --git a/infra/old name.py b/infra/new name.py\n"
        "similarity index 100%\n"
        "rename from infra/old name.py\n"
        "rename to infra/new name.py\n"
    )
    files, lines = parse_unified_diff(rename)
    assert "infra/new name.py" in files
    assert lines == 0


def test_pure_rename_with_space_into_forbidden_area_is_a_forbidden_hit():
    from sembl.validator import parse_unified_diff
    rename = (
        "diff --git a/src/old name.py b/infra/new name.py\n"
        "similarity index 100%\n"
        "rename from src/old name.py\n"
        "rename to infra/new name.py\n"
    )
    wo = {"editable_paths": ["src/"], "forbidden_areas": ["infra/"]}
    files, lines = parse_unified_diff(rename)
    result = validate_against_work_order(".", wo, changed_files=files, diff_line_count=lines)
    assert "infra/new name.py" in result.forbidden_hits


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


def test_docs_and_changelog_are_in_scope_not_out():
    # EXP-04: docs/changelog co-change with almost every fix; they must not
    # false-flag as out-of-scope (the single biggest real false-alarm source).
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    result = validate_against_work_order(
        ".", wo,
        changed_files=["src/app.py", "CHANGES.rst", "docs/guide/usage.md",
                       "README.md", "HISTORY.rst"],
    )
    assert result.out_of_scope == []
    for p in ("CHANGES.rst", "docs/guide/usage.md", "README.md", "HISTORY.rst"):
        assert p in result.in_scope


def test_buried_markdown_in_source_is_still_out_of_scope():
    # The docs allowance is narrow: arbitrary .md inside source is NOT a free pass.
    wo = {"editable_paths": ["src/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["lib/secret/notes.md"],
    )
    assert "lib/secret/notes.md" in result.out_of_scope


def test_default_scope_tolerance_is_fraction_based():
    # Default = max_fraction 0.25 (EXP-05). A single out-of-scope file in a small
    # change still WARNs (1/2 = 0.5 > 0.25); the same incidental file inside a
    # larger change is tolerated (1/5 = 0.2 <= 0.25). Scales with PR size.
    small = ["src/a.py", "lib/helper.py"]
    assert validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=small
    ).verdict("advisory_scope") == "WARN"

    larger = ["src/a.py", "src/b.py", "src/c.py", "src/d.py", "lib/helper.py"]
    r = validate_against_work_order(".", {"editable_paths": ["src/"]}, changed_files=larger)
    assert r.out_of_scope == ["lib/helper.py"]          # still reported as a fact
    assert r.verdict("advisory_scope") == "PASS"        # but within default tolerance


def test_explicit_empty_tolerance_means_zero_tolerance():
    # A contract can opt back into strict-per-file by setting scope_tolerance: {}.
    files = ["src/a.py", "src/b.py", "src/c.py", "src/d.py", "lib/helper.py"]
    wo = {"editable_paths": ["src/"], "scope_tolerance": {}}
    r = validate_against_work_order(".", wo, changed_files=files)
    assert r.verdict("advisory_scope") == "WARN"        # any OOS counts
    assert r.verdict("strict") == "BLOCK"


def test_scope_tolerance_override_max_files():
    files = ["src/a.py", "lib/helper.py"]               # 1 OOS, small change
    tol = {"editable_paths": ["src/"], "scope_tolerance": {"max_files": 1}}
    lenient = validate_against_work_order(".", tol, changed_files=files)
    assert lenient.out_of_scope == ["lib/helper.py"]
    assert lenient.verdict("advisory_scope") == "PASS"  # within explicit tolerance

    files3 = ["src/a.py", "lib/x.py", "other/y.py"]     # 2 OOS > max_files 1
    over = validate_against_work_order(".", tol, changed_files=files3)
    assert over.verdict("advisory_scope") == "WARN"


def test_malformed_scope_tolerance_does_not_crash():
    # A malformed contract value (string where a number is expected) must never
    # raise a raw exception — it's simply not applied (codex review finding).
    files = ["src/a.py", "lib/helper.py", "other/y.py"]
    wo = {"editable_paths": ["src/"], "scope_tolerance": {"max_files": "bad"}}
    result = validate_against_work_order(".", wo, changed_files=files)
    assert result.verdict("advisory_scope") in ("PASS", "WARN", "BLOCK")  # doesn't raise

    wo2 = {"editable_paths": ["src/"], "scope_tolerance": {"max_fraction": "0.25"}}
    result2 = validate_against_work_order(".", wo2, changed_files=files)
    assert result2.verdict("advisory_scope") in ("PASS", "WARN", "BLOCK")


# --- gate-contract self-edits (0.1.21, audit P0) ----------------------------------

def _commit(repo, msg="c"):
    subprocess.run(["git", "add", "-A"], cwd=str(repo), check=True,
                   capture_output=True, text=True)
    subprocess.run(["git", "commit", "-q", "-m", msg], cwd=str(repo), check=True,
                   capture_output=True, text=True)


def test_tracked_bounds_edit_is_a_contract_finding_git_mode(git_repo):
    # A change that rewrites its own (committed) bounds.json must BLOCK, not vanish.
    (git_repo / "bounds.json").write_text(
        json.dumps(WO), encoding="utf-8")
    _commit(git_repo, "add bounds")
    (git_repo / "bounds.json").write_text(
        '{"editable_paths": ["**"]}', encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.contract_edits == ["bounds.json"]
    assert result.verdict("advisory_scope") == "BLOCK"   # hard under EVERY policy
    assert result.verdict("strict") == "BLOCK"
    assert "bounds.json" not in result.changed_files     # still excluded from scope


def test_untracked_bounds_is_the_authoring_flow_not_a_finding(git_repo):
    # Generating bounds.json right before verify (the normal local flow) must NOT
    # flag — only a modified TRACKED contract file is a self-edit in git mode.
    (git_repo / "bounds.json").write_text(json.dumps(WO), encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.contract_edits == []
    assert result.ok


def test_tracked_work_order_edit_is_a_contract_finding(git_repo):
    wo_dir = git_repo / ".sembl" / "work-orders" / "task"
    wo_dir.mkdir(parents=True)
    (wo_dir / "work-order.json").write_text("{}", encoding="utf-8")
    _commit(git_repo, "add wo")
    (wo_dir / "work-order.json").write_text('{"editable_paths": ["**"]}',
                                            encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.contract_edits == [".sembl/work-orders/task/work-order.json"]
    assert result.verdict("advisory_scope") == "BLOCK"


def test_sembl_run_outputs_are_not_contract(git_repo):
    # A run store writing .sembl/runs/ is tool OUTPUT — excluded, never flagged.
    runs = git_repo / ".sembl" / "runs" / "20260702-x"
    runs.mkdir(parents=True)
    (runs / "run.json").write_text("{}", encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.contract_edits == []
    assert result.changed_files == []
    assert result.ok


def test_bounds_edit_in_diff_mode_blocks():
    wo = {"editable_paths": ["src/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["src/app.py", "bounds.json"])
    assert result.contract_edits == ["bounds.json"]
    assert result.changed_files == ["src/app.py"]
    assert result.verdict("advisory_scope") == "BLOCK"


def test_custom_work_order_file_is_contract_via_param():
    wo = {"editable_paths": ["src/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["specs/001/bounds.json", "src/app.py"],
        contract_paths=["specs/001/bounds.json"])
    assert result.contract_edits == ["specs/001/bounds.json"]
    assert result.verdict("advisory_scope") == "BLOCK"


# --- path normalization rejects traversal aliases (0.1.21, audit P1) ---------------

def test_traversal_path_cannot_alias_into_editable_scope():
    # `src/../infra/deploy.yaml` LOOKS editable by prefix but actually touches
    # infra/ — normalization must collapse it and judge the real target.
    wo = {"editable_paths": ["src/"], "forbidden_areas": ["infra/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["src/../infra/deploy.yaml"])
    assert result.forbidden_hits == ["infra/deploy.yaml"]


def test_absolute_and_drive_paths_are_judged_repo_relative():
    wo = {"editable_paths": ["src/"], "forbidden_areas": ["infra/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["C:/repo/infra/x.yaml", "/infra/y.yaml",
                                "../../../src/ok.py"])
    # Drive/absolute anchors are stripped; leading .. collapses away — every path
    # is judged repo-relative (fail-closed against aliasing, no false escapes).
    assert "src/ok.py" in result.in_scope
    assert "infra/y.yaml" in result.forbidden_hits          # "/" anchor stripped
    assert "repo/infra/x.yaml" in result.out_of_scope        # drive anchor stripped


# ── case-insensitive path comparison (Windows / macOS filesystems) ─────────────
# On a case-insensitive filesystem `Src/App.py` IS `src/app.py`; a case-only
# mismatch between contract, diff, and report must not false-flag out-of-scope
# or fabrication. On case-sensitive filesystems those are two different paths
# and folding stays OFF (it would silently widen editable bounds).

def test_case_only_mismatch_is_in_scope_when_folding(monkeypatch):
    from sembl import validator
    monkeypatch.setattr(validator, "_CASEFOLD_PATHS", True)
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    result = validate_against_work_order(".", wo, changed_files=["Src/App.py"])
    assert result.in_scope == ["Src/App.py"]      # original casing preserved
    assert result.out_of_scope == []


def test_case_only_mismatch_is_out_of_scope_without_folding(monkeypatch):
    from sembl import validator
    monkeypatch.setattr(validator, "_CASEFOLD_PATHS", False)
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    result = validate_against_work_order(".", wo, changed_files=["Src/App.py"])
    assert result.out_of_scope == ["Src/App.py"]


def test_forbidden_match_folds_case(monkeypatch):
    from sembl import validator
    monkeypatch.setattr(validator, "_CASEFOLD_PATHS", True)
    wo = {"editable_paths": [], "forbidden_areas": ["Infra/"]}
    result = validate_against_work_order(".", wo, changed_files=["infra/deploy.yaml"])
    assert result.forbidden_hits == ["infra/deploy.yaml"]


def test_case_only_claim_is_not_fabrication_when_folding(monkeypatch):
    from sembl import validator
    monkeypatch.setattr(validator, "_CASEFOLD_PATHS", True)
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    report = {"modified_files": ["SRC/app.py"]}
    result = validate_against_work_order(
        ".", wo, report=report, changed_files=["src/app.py"])
    assert result.fabricated_claims == []
    assert result.unreported_changes == []


def test_contract_path_folds_case(monkeypatch):
    from sembl import validator
    monkeypatch.setattr(validator, "_CASEFOLD_PATHS", True)
    wo = {"editable_paths": ["src/"], "forbidden_areas": []}
    result = validate_against_work_order(
        ".", wo, changed_files=["Bounds.json", "src/ok.py"])
    # a case-twisted edit of the gate's own contract still surfaces as one
    assert result.contract_edits == ["Bounds.json"]
    assert result.changed_files == ["src/ok.py"]


# ── O12 behavioral acceptance axis (WP1 — gate side) ──────────────────────────
# The fourth gate axis: a declared behavioral check the factory runner ran and
# reported back (never the executor's `report`). FAIL/ERROR/missing each BLOCK,
# under every policy, exactly like contract_edits — there is no advisory-
# behavioral mode. Absent/empty `acceptance` is a strict no-op.

ACC_DECLARED = [{"id": "chk-1", "kind": "example", "profile": "command"}]


def test_behavioral_fail_blocks():
    acc = {"declared": ACC_DECLARED,
           "results": [{"id": "chk-1", "outcome": "FAIL", "detail": "exit 1"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_failures == [{"id": "chk-1", "detail": "exit 1"}]
    assert result.behavioral_errors == []
    assert result.behavioral_missing == []
    assert result.verdict() == "BLOCK"
    assert result.verdict("advisory_scope") == "BLOCK"


def test_behavioral_error_blocks():
    acc = {"declared": ACC_DECLARED,
           "results": [{"id": "chk-1", "outcome": "ERROR", "detail": "timeout"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_errors == [{"id": "chk-1", "detail": "timeout"}]
    assert result.verdict() == "BLOCK"
    assert result.verdict("advisory_scope") == "BLOCK"


def test_behavioral_missing_blocks():
    # Declared but no matching result at all -> the behavioral analog of
    # fabricated_claims: cannot be trusted to have passed.
    acc = {"declared": ACC_DECLARED, "results": []}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_missing == ["chk-1"]
    assert result.verdict() == "BLOCK"
    assert result.verdict("advisory_scope") == "BLOCK"


def test_behavioral_all_pass_leaves_verdict_to_trespass_axes():
    acc = {"declared": ACC_DECLARED, "results": [{"id": "chk-1", "outcome": "PASS"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_failures == []
    assert result.behavioral_errors == []
    assert result.behavioral_missing == []
    assert result.verdict() == "PASS"        # in-scope, no report -> PASS as before


def test_no_acceptance_is_no_op_diff_mode():
    wo = {"editable_paths": ["src/"]}
    baseline = validate_against_work_order(".", wo, changed_files=["src/a.py"])
    absent = validate_against_work_order(".", wo, changed_files=["src/a.py"], acceptance=None)
    empty = validate_against_work_order(".", wo, changed_files=["src/a.py"], acceptance={})
    assert baseline.to_dict() == absent.to_dict() == empty.to_dict()
    assert baseline.verdict() == "PASS"


def test_no_acceptance_is_no_op_working_tree_mode(git_repo):
    (git_repo / "httpie" / "ssl_.py").write_text("FIXED", encoding="utf-8")
    baseline = validate_against_work_order(str(git_repo), WO)
    absent = validate_against_work_order(str(git_repo), WO, acceptance=None)
    empty = validate_against_work_order(str(git_repo), WO, acceptance={"declared": [], "results": []})
    assert baseline.to_dict() == absent.to_dict() == empty.to_dict()
    assert baseline.verdict() == "PASS"


def test_behavioral_dominates_over_scope_warn():
    # src/b.py is out-of-scope -> WARN under advisory_scope on its own; a FAILing
    # declared behavioral check must still BLOCK (behavior is never demoted).
    wo = {"editable_paths": ["src/a.py"]}
    acc = {"declared": ACC_DECLARED,
           "results": [{"id": "chk-1", "outcome": "FAIL", "detail": "boom"}]}
    result = validate_against_work_order(".", wo, changed_files=["src/b.py"], acceptance=acc)
    assert result.out_of_scope == ["src/b.py"]
    assert result.verdict("advisory_scope") == "BLOCK"


def test_reasons_ordering_hard_then_behavioral_then_soft():
    wo = {"editable_paths": ["src/a.py"], "churn_budget": {"max_files": 0}}
    acc = {"declared": [{"id": "chk-1"}, {"id": "chk-2"}],
           "results": [{"id": "chk-1", "outcome": "FAIL", "detail": "bad"}]}
    # chk-2 is declared but carries no result -> behavioral_missing
    result = validate_against_work_order(
        ".", wo, changed_files=["src/a.py", "src/b.py"], acceptance=acc)
    reasons = result.reasons()
    idx_oos = next(i for i, r in enumerate(reasons) if "out-of-scope" in r)
    idx_fail = next(i for i, r in enumerate(reasons) if "behavioral checks failed" in r)
    idx_missing = next(i for i, r in enumerate(reasons) if "no result (not run)" in r)
    idx_churn = next(i for i, r in enumerate(reasons) if "churn over budget" in r)
    assert idx_oos < idx_fail < idx_missing < idx_churn


def test_summary_and_to_dict_surface_behavioral_lists():
    acc = {"declared": ACC_DECLARED,
           "results": [{"id": "chk-1", "outcome": "FAIL", "detail": "nope"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    data = result.to_dict()
    assert data["behavioral_failures"] == [{"id": "chk-1", "detail": "nope"}]
    assert data["behavioral_errors"] == []
    assert data["behavioral_missing"] == []


def test_unrecognized_outcome_fails_closed():
    # A result whose outcome is not PASS/FAIL/ERROR (typo, buggy runner, missing
    # key) must never be an implicit PASS — it lands in behavioral_errors (D3).
    acc = {"declared": ACC_DECLARED,
           "results": [{"id": "chk-1", "outcome": "SKIPPED", "detail": "wat"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_errors == [
        {"id": "chk-1", "detail": "unrecognized outcome 'SKIPPED': wat"}]
    assert result.verdict() == "BLOCK"
    assert result.verdict("advisory_scope") == "BLOCK"

    # Same for a result with no outcome key at all.
    acc = {"declared": ACC_DECLARED, "results": [{"id": "chk-1"}]}
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"], acceptance=acc)
    assert result.behavioral_errors == [
        {"id": "chk-1", "detail": "unrecognized outcome None"}]
    assert result.verdict() == "BLOCK"


def test_malformed_acceptance_does_not_crash():
    result = validate_against_work_order(
        ".", {"editable_paths": ["src/"]}, changed_files=["src/a.py"],
        acceptance={"declared": "not-a-list", "results": None})
    assert result.behavioral_failures == []
    assert result.behavioral_errors == []
    assert result.behavioral_missing == []
    assert result.verdict() == "PASS"


# ── acceptance.json is gate contract surface (O12 §3.3) ──────────────────────

def test_acceptance_json_self_edit_in_diff_blocks_as_contract():
    wo = {"editable_paths": ["src/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["src/app.py", "acceptance.json"])
    assert result.contract_edits == ["acceptance.json"]
    assert result.changed_files == ["src/app.py"]
    assert result.verdict("advisory_scope") == "BLOCK"


def test_dot_sembl_acceptance_json_self_edit_in_diff_blocks_as_contract():
    wo = {"editable_paths": ["src/"]}
    result = validate_against_work_order(
        ".", wo, changed_files=["src/app.py", ".sembl/acceptance.json"])
    assert result.contract_edits == [".sembl/acceptance.json"]
    assert result.verdict("advisory_scope") == "BLOCK"


def test_tracked_acceptance_edit_is_a_contract_finding_git_mode(git_repo):
    (git_repo / "acceptance.json").write_text('{"checks": []}', encoding="utf-8")
    _commit(git_repo, "add acceptance")
    (git_repo / "acceptance.json").write_text('{"checks": [{"id": "x"}]}', encoding="utf-8")
    result = validate_against_work_order(str(git_repo), WO)
    assert result.contract_edits == ["acceptance.json"]
    assert result.verdict("advisory_scope") == "BLOCK"
    assert "acceptance.json" not in result.changed_files
