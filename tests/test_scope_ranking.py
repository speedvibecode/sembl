"""0.1.9 scope fixes: relevance-first ranking + contract reconciliation.

Grounded in demo-tasks/CROSS-REPO-FINDINGS.md: 4/4 demo repos produced WOs whose
editable_paths missed the true fix file (entry-point/config bias) and whose
editable/forbidden lists contradicted each other.
"""

from pathlib import Path

import pytest

from sembl.generator import (
    WorkOrder,
    _entry_point_penalty,
    _failure_trace_files,
    _failure_trace_signals,
    _looks_like_test_path,
    _rank_editable_paths,
    _reconcile_contract,
)


# ── relevance-first ranking ──────────────────────────────────────────────────

def test_entry_points_no_longer_outrank_content_matched_fix_file():
    # httpie/001 reproduction: graph provenance used to put entry points first.
    graph = ["httpie/__main__.py", "extras/packaging/linux/scripts/httpie_cli.py"]
    llm = ["httpie/core.py", "httpie/client.py"]
    direct = ["httpie/ssl_.py"]
    ranked = _rank_editable_paths(
        llm, graph, direct,
        task="https requests fail with certificate verify failed since requests 2.32.3",
        content_hits={"httpie/ssl_.py"},
    )
    assert ranked.index("httpie/ssl_.py") < ranked.index("httpie/__main__.py")
    assert ranked.index("httpie/ssl_.py") < ranked.index(
        "extras/packaging/linux/scripts/httpie_cli.py"
    )


def test_failure_trace_hit_dominates_everything():
    ranked = _rank_editable_paths(
        ["frontend/src/routes/reset-password.tsx"],
        ["backend/app/initial_data.py"],
        ["frontend/src/utils.ts"],
        task='reset password always errors with "The passwords do not match"',
        trace_hits={"frontend/src/utils.ts"},
    )
    assert ranked[0] == "frontend/src/utils.ts"


def test_entry_point_penalty_targets_launchers_packaging_and_config():
    assert _entry_point_penalty("httpie/__main__.py") >= 6
    assert _entry_point_penalty("cmd/functional-test/main.go") >= 6
    assert _entry_point_penalty("extras/scripts/generate_man_pages.py") >= 6
    assert _entry_point_penalty("frontend/biome.json") >= 6
    assert _entry_point_penalty("httpie/ssl_.py") == 0
    assert _entry_point_penalty("pkg/engine/headless/browser/browser.go") == 0


def test_graph_provenance_still_breaks_ties():
    # Equal relevance: the graph-surfaced file should win the tie.
    ranked = _rank_editable_paths(
        ["pkg/a/one.go"], ["pkg/a/two.go"], [],
        task="unrelated words entirely",
    )
    assert ranked[0] == "pkg/a/two.go"


def test_failure_trace_signals_extract_quotes_and_error_tokens():
    signals = _failure_trace_signals(
        'fails with SSLError: CERTIFICATE_VERIFY_FAILED and says "unable to get local issuer"'
    )
    assert "CERTIFICATE_VERIFY_FAILED" in signals
    assert "unable to get local issuer" in signals


def test_failure_trace_files_matches_content(tmp_path):
    target = tmp_path / "frontend" / "src"
    target.mkdir(parents=True)
    (target / "utils.ts").write_text(
        'export const msg = "The passwords do not match"', encoding="utf-8"
    )
    (target / "other.ts").write_text("export const x = 1", encoding="utf-8")
    hits = _failure_trace_files(
        tmp_path,
        ["frontend/src/utils.ts", "frontend/src/other.ts"],
        ["The passwords do not match"],
    )
    assert hits == {"frontend/src/utils.ts"}


def test_go_and_js_test_files_are_recognized():
    # katana/001: headless_test.go reached editable_paths because _test.go was
    # not recognized as a test path.
    assert _looks_like_test_path("pkg/engine/headless/headless_test.go")
    assert _looks_like_test_path("src/components/button.test.js")
    assert not _looks_like_test_path("pkg/engine/headless/headless.go")


# ── contract reconciliation ──────────────────────────────────────────────────

def _wo(**kwargs) -> WorkOrder:
    wo = WorkOrder()
    wo.original_request = kwargs.pop("original_request", "fix the bug")
    for key, value in kwargs.items():
        setattr(wo, key, value)
    return wo


def test_forbidden_entries_that_contradict_editable_are_dropped(tmp_path):
    wo = _wo(
        editable_paths=["httpie/__main__.py", "httpie/core.py"],
        forbidden_areas=["httpie/__main__.py", "docs/"],
    )
    _reconcile_contract(wo, tmp_path)
    assert "httpie/__main__.py" not in wo.forbidden_areas
    assert any(entry.rstrip("/") == "docs" for entry in wo.forbidden_areas)


def test_forbidden_dir_containing_editable_file_is_dropped(tmp_path):
    # fastapi-template/001: backend/app forbidden while backend/app/* editable.
    wo = _wo(
        editable_paths=["backend/app/api/routes/login.py"],
        forbidden_areas=["backend/app", "worker/"],
    )
    _reconcile_contract(wo, tmp_path)
    assert "backend/app" not in wo.forbidden_areas
    assert any(entry.startswith("worker") for entry in wo.forbidden_areas)


def test_patch_expectations_naming_non_editable_files_are_dropped(tmp_path):
    # chatbot-ui/001: patch expectations named a file in neither list.
    route = tmp_path / "app" / "api" / "assistants" / "openai"
    route.mkdir(parents=True)
    (route / "route.ts").write_text("export {}", encoding="utf-8")
    wo = _wo(
        editable_paths=["lib/utils.ts"],
        patch_expectations=[
            "Minimal changes to app/api/assistants/openai/route.ts buffering",
            "No new dependencies",
        ],
    )
    _reconcile_contract(wo, tmp_path)
    assert all("assistants" not in text for text in wo.patch_expectations)
    assert "No new dependencies" in wo.patch_expectations


def test_demanded_tests_force_an_editable_test_path(tmp_path):
    tests_dir = tmp_path / "tests"
    tests_dir.mkdir()
    (tests_dir / "test_ssl.py").write_text("def test(): pass", encoding="utf-8")
    wo = _wo(
        editable_paths=["httpie/ssl_.py"],
        tests_to_inspect=["tests/test_ssl.py"],
        patch_expectations=["Add tests for SSL verification"],
    )
    _reconcile_contract(wo, tmp_path)
    assert "tests/test_ssl.py" in wo.editable_paths


def test_permission_to_stop_condition_is_appended(tmp_path):
    wo = _wo(editable_paths=["httpie/ssl_.py"])
    _reconcile_contract(wo, tmp_path)
    assert any("outside editable_paths" in cond for cond in wo.stop_conditions)
    # idempotent
    _reconcile_contract(wo, tmp_path)
    assert sum("outside editable_paths" in cond for cond in wo.stop_conditions) == 1


def test_no_stop_condition_without_editable_paths(tmp_path):
    wo = _wo(editable_paths=[])
    _reconcile_contract(wo, tmp_path)
    assert not any("outside editable_paths" in cond for cond in wo.stop_conditions)


# ── validation-command grounding (large-monorepo explosion) ──────────────────

def test_validation_commands_capped_on_large_monorepo(tmp_path):
    # zod reproduction: ~170 candidate test files must not become 170 npm commands.
    from sembl.generator import _ground_validation_commands
    from sembl.repo_probe import RepoProbe

    (tmp_path / "package.json").write_text('{"scripts":{"test":"vitest"}}', encoding="utf-8")
    tests_dir = tmp_path / "tests"
    tests_dir.mkdir()
    test_files = []
    for i in range(170):
        rel = f"tests/t{i}.test.ts"
        (tmp_path / rel).write_text("test('x',()=>{})", encoding="utf-8")
        test_files.append(rel)

    probe = RepoProbe(repo_path=str(tmp_path))
    out = _ground_validation_commands([], probe, tmp_path, test_files)

    assert len(out) <= 10
    # the few that survive are the head (top-ranked) test files, not all 170
    assert sum(1 for c in out if c.startswith("npm test --")) <= 3
