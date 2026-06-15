"""sembl.speckit: Spec Kit tasks.md -> bounds contract adapter."""

import json

import pytest

from sembl.speckit import (
    bounds_from_spec_kit,
    bounds_from_tasks_text,
    extract_paths,
    find_tasks_file,
)

SAMPLE_TASKS = """\
# Tasks: User login redirect

## Phase 1
- [ ] T001 Create project structure in src/
- [ ] T002 [P] Implement session helper in `src/auth/session.ts`
- [ ] T003 [P] Fix redirect in src/auth/redirect.ts
- [ ] T004 Add tests in tests/auth/redirect.test.ts
- [ ] T005 Update the auth module docs (no path here)
- [ ] T006 Touch backend/app/api/routes/login.py
"""


def test_extract_paths_finds_concrete_files_only():
    paths = extract_paths(SAMPLE_TASKS)
    assert paths == [
        "src/auth/session.ts",
        "src/auth/redirect.ts",
        "tests/auth/redirect.test.ts",
        "backend/app/api/routes/login.py",
    ]
    # "src/" (no file) and prose ("the auth module") are not paths.
    assert "src" not in paths


def test_extract_paths_dedupes_and_strips_backticks():
    text = "edit `src/x.py` then src/x.py again and ./src/y.py"
    assert extract_paths(text) == ["src/x.py", "src/y.py"]


def test_extract_paths_ignores_urls():
    text = "see https://example.com/path/file.md and edit src/real.py"
    assert extract_paths(text) == ["src/real.py"]


def test_extract_paths_rejects_version_strings_and_useragents():
    # EXP-04: prose carries version/UA tokens (`Werkzeug/2.2.2`, `Python/3.10.4`,
    # `HTTP/1.1`, `Chrome/65.0.3325.183`) that the old regex matched as files. A
    # letter-led extension rejects them while keeping real paths.
    text = ("Repro on Werkzeug/2.2.2 with Python/3.10.4 over HTTP/1.1 in "
            "Chrome/65.0.3325.183 — the bug is in src/flask/app.py")
    assert extract_paths(text) == ["src/flask/app.py"]


def test_extract_paths_root_validation_filters_nonexistent(tmp_path):
    (tmp_path / "src").mkdir()
    (tmp_path / "src" / "real.py").write_text("x = 1\n", encoding="utf-8")
    text = "edit src/real.py and src/ghost.py"
    assert extract_paths(text) == ["src/real.py", "src/ghost.py"]      # no root: regex only
    assert extract_paths(text, root=tmp_path) == ["src/real.py"]       # root: must exist


def test_bounds_shape_and_grounded_budget():
    bounds = bounds_from_tasks_text(SAMPLE_TASKS)
    assert bounds["editable_paths"]  # non-empty
    assert bounds["forbidden_areas"] == []
    # max_files grounded on the 4 files found (+2), min 3.
    assert bounds["churn_budget"]["max_files"] == 6
    assert "max_lines" not in bounds["churn_budget"]


def test_empty_tasks_gives_min_budget_and_no_paths():
    bounds = bounds_from_tasks_text("# Tasks\n- [ ] T001 do a thing\n")
    assert bounds["editable_paths"] == []
    assert bounds["churn_budget"]["max_files"] == 3


def test_bounds_output_is_verify_compatible():
    """The emitted dict must be readable by the validator unchanged."""
    from sembl.validator import validate_against_work_order

    bounds = bounds_from_tasks_text(SAMPLE_TASKS)
    # changed_files mode: an in-scope file passes, an out-of-scope one doesn't.
    result = validate_against_work_order(
        ".", bounds,
        changed_files=["src/auth/redirect.ts", "infra/deploy.yaml"],
    )
    assert "src/auth/redirect.ts" in result.in_scope
    assert "infra/deploy.yaml" in result.out_of_scope


def test_find_tasks_file_from_dir(tmp_path):
    feature = tmp_path / "specs" / "001-login"
    feature.mkdir(parents=True)
    tasks = feature / "tasks.md"
    tasks.write_text(SAMPLE_TASKS, encoding="utf-8")
    assert find_tasks_file(tmp_path) == tasks
    bounds, source = bounds_from_spec_kit(tmp_path)
    assert source == tasks
    assert bounds["editable_paths"]


def test_find_tasks_file_multiple_raises(tmp_path):
    for feat in ("001-a", "002-b"):
        d = tmp_path / "specs" / feat
        d.mkdir(parents=True)
        (d / "tasks.md").write_text(SAMPLE_TASKS, encoding="utf-8")
    with pytest.raises(ValueError, match="multiple tasks.md"):
        find_tasks_file(tmp_path)


def test_find_tasks_file_none_raises(tmp_path):
    with pytest.raises(FileNotFoundError, match="no tasks.md"):
        find_tasks_file(tmp_path)
