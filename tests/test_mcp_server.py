"""sembl.mcp_server: the tool bodies are plain functions, tested without a transport."""

import pytest

from sembl.mcp_server import (
    verify_change,
    bounds_from_spec,
    list_presets,
)

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
