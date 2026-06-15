"""sembl.mcp_server: the tool bodies are plain functions, tested without a transport."""

import pytest

from sembl.mcp_server import (
    verify_change,
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


@pytest.mark.skipif(not HAS_MCP, reason="requires the 'mcp' extra")
def test_all_fronts_registered():
    # The MCP surface mirrors the CLI: gate + bounds + diagnostics + beta generation.
    import asyncio
    s = build_server()
    names = {t.name for t in asyncio.new_event_loop().run_until_complete(s.list_tools())}
    assert {"verify_change", "bounds_from_spec", "list_presets",
            "doctor", "clarify_task", "generate_work_order"} <= names
