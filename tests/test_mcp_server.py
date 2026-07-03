"""sembl.mcp_server: the tool bodies are plain functions, tested without a transport."""

import pytest

from sembl.mcp_server import (
    verify_change,
    gate_pr,
    bounds_from_spec,
    list_presets,
    doctor,
    build_server,
)

try:
    import mcp as _mcp  # noqa: F401
    HAS_MCP = True
except ImportError:
    HAS_MCP = False

DIFF = """\
diff --git a/src/app.py b/src/app.py
--- a/src/app.py
+++ b/src/app.py
@@ -1,2 +1,3 @@
 x = 1
+y = 2
diff --git a/infra/deploy.yaml b/infra/deploy.yaml
--- a/infra/deploy.yaml
+++ b/infra/deploy.yaml
@@ -1 +1,2 @@
 a: 1
+b: 2
"""


def test_verify_change_diff_mode_pass_in_scope():
    out = verify_change(diff=DIFF, editable_paths=["src/", "infra/"])
    assert out["verdict"] == "PASS"
    assert out["summary"]["files_changed"] == 2
    assert out["summary"]["out_of_scope"] == []


def test_verify_change_forbidden_blocks():
    out = verify_change(diff=DIFF, editable_paths=["src/"], forbidden_areas=["infra/"])
    assert out["verdict"] == "BLOCK"
    assert "infra/deploy.yaml" in out["summary"]["forbidden_hits"]


def test_verify_change_fabrication_blocks():
    # report claims a file the diff never touched -> fabrication -> BLOCK
    report = {"changed_files": ["src/app.py", "infra/deploy.yaml", "src/ghost.py"]}
    out = verify_change(diff=DIFF, editable_paths=["src/", "infra/"], report=report)
    assert out["verdict"] == "BLOCK"
    assert "src/ghost.py" in out["summary"]["fabricated_claims"]


def test_verify_change_scope_is_advisory_by_default():
    # infra/ not declared editable -> out of scope, but only a WARN (advisory)
    out = verify_change(diff=DIFF, editable_paths=["src/"])
    assert out["verdict"] == "WARN"
    assert "infra/deploy.yaml" in out["summary"]["out_of_scope"]
    # strict promotes the same change to BLOCK
    strict = verify_change(diff=DIFF, editable_paths=["src/"], strict=True)
    assert strict["verdict"] == "BLOCK"


def test_verify_change_uses_bounds_file(tmp_path):
    import json
    b = tmp_path / "bounds.json"
    b.write_text(json.dumps({"editable_paths": ["src/", "infra/"]}), encoding="utf-8")
    out = verify_change(diff=DIFF, bounds_file=str(b))
    assert out["verdict"] == "PASS"


def test_bounds_from_spec_text():
    text = "- [ ] T001 edit `src/auth/session.ts`\n- [ ] T002 fix src/auth/redirect.ts\n"
    out = bounds_from_spec(tasks_text=text)
    assert "src/auth/session.ts" in out["bounds"]["editable_paths"]
    assert "src/auth/redirect.ts" in out["bounds"]["editable_paths"]


def test_bounds_from_spec_requires_a_source():
    with pytest.raises(ValueError):
        bounds_from_spec()


def test_list_presets_includes_spec_kit():
    assert "spec-kit" in list_presets()["presets"]


def test_bounds_from_spec_config_file(tmp_path):
    import json
    (tmp_path / "specs").mkdir()
    (tmp_path / "specs" / "plan.md").write_text(
        "implement in `src/core/engine.py` and src/core/util.py", encoding="utf-8")
    cfg = tmp_path / "adapter.json"
    cfg.write_text(json.dumps({
        "source": ["specs/*.md"],
        "editable": {"strategy": "path-tokens"},
        "forbidden": {"literal": []},
    }), encoding="utf-8")
    out = bounds_from_spec(config_file=str(cfg), repo_path=str(tmp_path))
    assert "src/core/engine.py" in out["bounds"]["editable_paths"]


def test_doctor_runs_without_keys():
    out = doctor(repo_path=".")
    assert isinstance(out, dict)
    assert "checks" in out or "project_type" in out or out  # shape-tolerant smoke


def test_verify_change_flags_contract_self_edit(tmp_path):
    # a diff that rewrites the very bounds file judging it must BLOCK, not vanish
    import json
    b = tmp_path / "bounds.json"
    b.write_text(json.dumps({"editable_paths": ["src/"]}), encoding="utf-8")
    diff = """\
diff --git a/bounds.json b/bounds.json
--- a/bounds.json
+++ b/bounds.json
@@ -1 +1 @@
-{"editable_paths": ["src/"]}
+{"editable_paths": ["src/", "infra/"]}
"""
    out = verify_change(diff=diff, repo_path=str(tmp_path))
    assert out["verdict"] == "BLOCK"
    assert "bounds.json" in out.get("contract_edits", [])


# ── gate_pr: one-call PR gating against a real temp git repo ────────────────────

def _git(repo, *args):
    import subprocess
    proc = subprocess.run(["git", *args], cwd=str(repo), capture_output=True,
                          text=True, encoding="utf-8", errors="replace")
    assert proc.returncode == 0, f"git {' '.join(args)} failed: {proc.stderr}"
    return proc.stdout


@pytest.fixture
def pr_repo(tmp_path):
    """A repo with master (bounds.json + src/app.py) and a `feature` branch that
    edits src/app.py in scope and adds infra/deploy.yaml out of it."""
    import json
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-b", "master")
    _git(repo, "config", "user.email", "t@example.com")
    _git(repo, "config", "user.name", "t")
    (repo / "src").mkdir()
    (repo / "src" / "app.py").write_text("x = 1\n", encoding="utf-8")
    (repo / "bounds.json").write_text(
        json.dumps({"editable_paths": ["src/"], "forbidden_areas": ["secrets/"]}),
        encoding="utf-8")
    _git(repo, "add", "-A")
    _git(repo, "commit", "-m", "base")
    _git(repo, "checkout", "-b", "feature")
    (repo / "src" / "app.py").write_text("x = 1\ny = 2\n", encoding="utf-8")
    _git(repo, "commit", "-am", "feature work")
    return repo


def test_gate_pr_one_call_pass(pr_repo):
    out = gate_pr(repo_path=str(pr_repo))  # base auto-detected, bounds discovered
    assert out["verdict"] == "PASS"
    assert out["pr"]["base"] == "master"
    assert out["pr"]["head"] == "HEAD"
    assert out["pr"]["merge_base"]
    assert out["pr"]["bounds_source"].endswith("bounds.json")
    assert out["summary"]["files_changed"] == 1


def test_gate_pr_diff_is_branch_only(pr_repo):
    # commits added to master AFTER the branch point must not appear in the diff
    _git(pr_repo, "checkout", "master")
    (pr_repo / "src" / "other.py").write_text("z = 3\n", encoding="utf-8")
    _git(pr_repo, "add", "-A")
    _git(pr_repo, "commit", "-m", "master moved on")
    _git(pr_repo, "checkout", "feature")
    out = gate_pr(repo_path=str(pr_repo))
    assert out["summary"]["files_changed"] == 1  # three-dot: feature's commits only


def test_gate_pr_forbidden_blocks(pr_repo):
    (pr_repo / "secrets").mkdir()
    (pr_repo / "secrets" / "prod.env").write_text("k=v\n", encoding="utf-8")
    _git(pr_repo, "add", "-A")
    _git(pr_repo, "commit", "-m", "oops")
    out = gate_pr(repo_path=str(pr_repo))
    assert out["verdict"] == "BLOCK"
    assert "secrets/prod.env" in out["summary"]["forbidden_hits"]


def test_gate_pr_contract_self_edit_blocks(pr_repo):
    import json
    (pr_repo / "bounds.json").write_text(
        json.dumps({"editable_paths": ["src/", "secrets/"]}), encoding="utf-8")
    _git(pr_repo, "commit", "-am", "widen my own contract")
    out = gate_pr(repo_path=str(pr_repo))
    assert out["verdict"] == "BLOCK"
    assert "bounds.json" in out.get("contract_edits", [])


def test_gate_pr_inline_bounds_win(pr_repo):
    out = gate_pr(repo_path=str(pr_repo), editable_paths=["docs/"])
    assert out["verdict"] == "WARN"  # src/app.py now out of the (inline) scope
    assert "src/app.py" in out["summary"]["out_of_scope"]


def test_gate_pr_explicit_base(pr_repo):
    out = gate_pr(repo_path=str(pr_repo), base="master")
    assert out["verdict"] == "PASS"
    assert out["pr"]["base"] == "master"


def test_gate_pr_bad_base_is_structured_error(pr_repo):
    out = gate_pr(repo_path=str(pr_repo), base="no-such-branch")
    assert "error" in out and "hint" in out


def test_gate_pr_no_bounds_is_structured_error(tmp_path):
    repo = tmp_path / "bare"
    repo.mkdir()
    _git(repo, "init", "-b", "master")
    _git(repo, "config", "user.email", "t@example.com")
    _git(repo, "config", "user.name", "t")
    (repo / "a.txt").write_text("a\n", encoding="utf-8")
    _git(repo, "add", "-A")
    _git(repo, "commit", "-m", "base")
    out = gate_pr(repo_path=str(repo))
    assert out["error"] == "no bounds contract found"
    assert "bounds" in out["hint"]


def test_gate_pr_not_a_repo_is_structured_error(tmp_path):
    out = gate_pr(repo_path=str(tmp_path), editable_paths=["src/"])
    assert "error" in out and "hint" in out


@pytest.mark.skipif(not HAS_MCP, reason="requires the 'mcp' extra")
def test_all_fronts_registered():
    # The MCP surface mirrors the CLI: gate + bounds + diagnostics + beta generation.
    import asyncio
    s = build_server()
    names = {t.name for t in asyncio.new_event_loop().run_until_complete(s.list_tools())}
    assert {"gate_pr", "verify_change", "bounds_from_spec", "list_presets",
            "doctor", "clarify_task", "generate_work_order"} <= names
