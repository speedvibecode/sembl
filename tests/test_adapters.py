"""sembl.adapters: declarative bounds adapters (Tier 2)."""

import json

import pytest

from sembl.adapters import (
    bounds_from_preset,
    build_bounds_from_config,
    load_config,
    preset_names,
)

TASKS = """\
- [ ] T001 edit `src/auth/session.ts`
- [ ] T002 fix src/auth/redirect.ts
- [ ] T003 add tests/auth/redirect.test.ts
"""


def test_presets_exist():
    names = preset_names()
    for expected in ("spec-kit", "kiro", "tessl", "agents-md", "cursor-rules"):
        assert expected in names


def test_spec_kit_preset_reads_repo_relative_glob(tmp_path):
    feat = tmp_path / "specs" / "001-login"
    feat.mkdir(parents=True)
    (feat / "tasks.md").write_text(TASKS, encoding="utf-8")
    bounds, used = bounds_from_preset("spec-kit", tmp_path)
    assert "src/auth/session.ts" in bounds["editable_paths"]
    assert len(used) == 1
    assert bounds["forbidden_areas"] == []
    assert bounds["churn_budget"]["max_files"] == max(3, len(bounds["editable_paths"]) + 2)


def test_agents_md_preset(tmp_path):
    (tmp_path / "AGENTS.md").write_text(
        "Only touch src/api/routes.py and config/settings.py for this change.",
        encoding="utf-8",
    )
    bounds, used = bounds_from_preset("agents-md", tmp_path)
    assert "src/api/routes.py" in bounds["editable_paths"]
    assert "config/settings.py" in bounds["editable_paths"]


def test_source_override(tmp_path):
    (tmp_path / "plan.md").write_text("work in src/x.py", encoding="utf-8")
    bounds, used = bounds_from_preset("spec-kit", tmp_path, source="plan.md")
    assert bounds["editable_paths"] == ["src/x.py"]


def test_custom_config_with_literal_forbidden_and_budget(tmp_path):
    (tmp_path / "spec.md").write_text("edit src/feature.ts", encoding="utf-8")
    config = {
        "source": ["spec.md"],
        "editable": {"strategy": "path-tokens", "literal": ["src/always.ts"]},
        "forbidden": {"literal": ["migrations/", "infra/"]},
        "churn": {"max_files": 4, "max_lines": 120},
    }
    bounds, used = build_bounds_from_config(config, tmp_path)
    assert "src/feature.ts" in bounds["editable_paths"]
    assert "src/always.ts" in bounds["editable_paths"]      # literal added
    assert bounds["forbidden_areas"] == ["migrations/", "infra/"]
    assert bounds["churn_budget"] == {"max_files": 4, "max_lines": 120}


def test_unknown_preset_raises():
    with pytest.raises(KeyError, match="unknown adapter preset"):
        bounds_from_preset("nope", ".")


def test_output_is_verify_compatible(tmp_path):
    from sembl.validator import validate_against_work_order
    (tmp_path / "tasks.md").write_text(TASKS, encoding="utf-8")
    bounds, _ = bounds_from_preset("spec-kit", tmp_path, source="tasks.md")
    result = validate_against_work_order(
        ".", bounds, changed_files=["src/auth/redirect.ts", "infra/x.tf"],
    )
    assert "src/auth/redirect.ts" in result.in_scope
    assert "infra/x.tf" in result.out_of_scope


def test_load_config_json(tmp_path):
    cfg = tmp_path / "adapter.json"
    cfg.write_text(json.dumps({"source": ["a.md"]}), encoding="utf-8")
    assert load_config(cfg) == {"source": ["a.md"]}
