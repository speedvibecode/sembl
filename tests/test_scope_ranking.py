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
    _relevance_gap_cutoff,
    _superseded_version_paths,
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
    assert _entry_point_penalty("packages/docs/components/ecosystem.tsx") >= 6
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


def test_failure_trace_signals_survive_hard_wrapped_tasks(tmp_path):
    # fastapi-001 live repro: raw-prompt.md hard-wraps the quoted error mid-
    # phrase ("The passwords do not\nmatch") -> literal search missed utils.ts
    # and the WO lost its trace anchor entirely.
    signals = _failure_trace_signals(
        'always errors with "The passwords do not\nmatch" even though identical'
    )
    assert "The passwords do not match" in signals
    target = tmp_path / "src"
    target.mkdir()
    (target / "utils.ts").write_text(
        'value === getValues().password || "The passwords do not match",',
        encoding="utf-8",
    )
    hits = _failure_trace_files(tmp_path, ["src/utils.ts"], signals)
    assert hits == {"src/utils.ts"}


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


# ── precision: locale exclusion + narrowing-scope filter (zod loop) ──────────

def test_locale_files_excluded_unless_localization_task():
    from sembl.generator import _is_editable_candidate
    loc = "packages/zod/src/v4/locales/he.ts"
    core = "packages/zod/src/v4/core/util.ts"
    # non-localization task: locale file is NOT an editable candidate, core is
    assert not _is_editable_candidate(loc, "map and set defaults share state")
    assert _is_editable_candidate(core, "map and set defaults share state")
    # localization task: locale file IS allowed
    assert _is_editable_candidate(loc, "fix the hebrew translation message")


# ── relevance-gap cutoff (zod-001 matrix: scope noise loosens tight models) ──

def test_trace_hit_head_drops_keyword_only_tail():
    # zod-001 shape: v4 fix file is a trace hit; v3 siblings only keyword-match.
    task = 'Map/Set schema defaults share state, error "invalid_type" on clone'
    ranked = [
        "packages/zod/src/v4/core/util.ts",       # trace hit + content
        "packages/zod/src/v4/core/schemas.ts",     # strong content
        "packages/zod/src/v3/types.ts",            # weak keyword tail
        "packages/zod/src/v3/helpers/util.ts",     # weak keyword tail
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task,
        trace_hits={"packages/zod/src/v4/core/util.ts"},
        content_hits={
            "packages/zod/src/v4/core/util.ts": 6,
            "packages/zod/src/v4/core/schemas.ts": 6,
            "packages/zod/src/v3/types.ts": 1,
            "packages/zod/src/v3/helpers/util.ts": 1,
        },
    )
    assert "packages/zod/src/v4/core/util.ts" in out
    assert "packages/zod/src/v4/core/schemas.ts" in out
    assert "packages/zod/src/v3/types.ts" not in out
    assert "packages/zod/src/v3/helpers/util.ts" not in out


def test_no_strong_head_passes_through_unchanged():
    # katana shape: weak keyword signal everywhere -> breadth is the safe default.
    ranked = [
        "pkg/engine/headless/browser.go",
        "pkg/engine/standard/standard.go",
        "pkg/utils/queue/queue.go",
    ]
    out = _relevance_gap_cutoff(ranked, task="crawler hangs sometimes")
    assert out == ranked


def test_trace_hits_survive_below_threshold():
    # A second trace hit (e.g. the test asserting the error string) is never cut,
    # even when penalties push its score under the fraction.
    task = 'fails with "unable to get local issuer certificate"'
    ranked = [
        "httpie/ssl_.py",
        "extras/scripts/check_certs.py",  # trace hit but entry-point-penalized
        "httpie/core.py",
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task,
        trace_hits={"httpie/ssl_.py", "extras/scripts/check_certs.py"},
        content_hits={"httpie/ssl_.py": 5},
    )
    assert "extras/scripts/check_certs.py" in out
    assert "httpie/core.py" not in out


def test_strong_content_head_without_trace_hit_still_cuts():
    # httpie shape: no quoted trace, but the fix file content-matches many terms.
    task = "https requests fail certificate verify since requests 2.32.3 ssl context"
    ranked = [
        "httpie/ssl_.py",     # many content terms + path term
        "httpie/client.py",   # moderate
        "docs/config.md",     # noise
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task,
        content_hits={"httpie/ssl_.py": 7, "httpie/client.py": 4},
    )
    assert out[0] == "httpie/ssl_.py"
    assert "docs/config.md" not in out


def test_cutoff_preserves_graph_floor():
    # Keyword-strong head must not evict the last graph-provenance path:
    # keyword scores are weak evidence (0.1.7 lesson), so structural context
    # survives the gap cut.
    task = "improve the provider api key error message"
    ranked = [
        "src/noise/provider_error_message.py",  # keyword-strong head
        "src/gold/ownership.py",                # zero-keyword graph file
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task,
        content_hits={"src/noise/provider_error_message.py": 5},
        graph_set={"src/gold/ownership.py"},
    )
    assert "src/gold/ownership.py" in out


def test_cutoff_keeps_single_path_lists_intact():
    assert _relevance_gap_cutoff(["a.py"], task="anything") == ["a.py"]
    assert _relevance_gap_cutoff([], task="anything") == []


def test_negative_scorers_dropped_even_without_strong_head():
    # zod-001 live run: packages/tsc/tsconfig.bench.json (score -6) survived
    # into editable_paths because no strong head existed to trigger the gap.
    ranked = [
        "packages/zod/src/v4/core/util.ts",
        "packages/tsc/tsconfig.bench.json",
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task="map and set defaults share state across parses",
        content_hits={"packages/zod/src/v4/core/util.ts": 3},
    )
    assert "packages/tsc/tsconfig.bench.json" not in out
    assert "packages/zod/src/v4/core/util.ts" in out


def test_graph_floor_does_not_resurrect_negative_scorers():
    # zod-001 live run: tsconfig.bench.json was the only graph-provenance path
    # and the floor re-added it (score -6) after the gap cut it.
    task = "map and set defaults share state across parses"
    ranked = [
        "packages/zod/src/v4/core/util.ts",
        "packages/tsc/tsconfig.bench.json",
    ]
    out = _relevance_gap_cutoff(
        ranked,
        task,
        content_hits={"packages/zod/src/v4/core/util.ts": 7},
        graph_set={"packages/tsc/tsconfig.bench.json"},
    )
    assert "packages/tsc/tsconfig.bench.json" not in out


# ── superseded version trees + legacy gate ───────────────────────────────────

def test_older_version_tree_leaves_edit_scope():
    # zod-001: v3 and v4 speak the same vocabulary; structure is the signal.
    pool = [
        "packages/zod/src/v3/types.ts",
        "packages/zod/src/v3/helpers/parseUtil.ts",
        "packages/zod/src/v4/core/util.ts",
        "packages/zod/src/v4/core/schemas.ts",
    ]
    dropped = _superseded_version_paths(pool, "map/set default shares state")
    assert dropped == {
        "packages/zod/src/v3/types.ts",
        "packages/zod/src/v3/helpers/parseUtil.ts",
    }


def test_version_named_in_task_stays_editable():
    pool = [
        "packages/zod/src/v3/types.ts",
        "packages/zod/src/v4/core/util.ts",
    ]
    assert _superseded_version_paths(pool, "backport the fix to v3 types") == set()


def test_single_version_tree_is_not_superseded():
    pool = ["api/v2/handlers.go", "api/v2/router.go"]
    assert _superseded_version_paths(pool, "fix the handler") == set()


def test_version_dirs_at_different_positions_do_not_conflict():
    # v1 under api/ and v2 under web/ are unrelated trees, not versions of
    # the same thing.
    pool = ["api/v1/handlers.go", "web/v2/render.go"]
    assert _superseded_version_paths(pool, "fix rendering") == set()


def test_legacy_tree_gated_by_task_intent():
    from sembl.generator import _is_editable_candidate
    legacy = "httpie/legacy/v3_2_0_session_header_format.py"
    assert not _is_editable_candidate(legacy, "https requests fail since 2.32.3")
    assert _is_editable_candidate(legacy, "fix the legacy session migration")


def test_narrowing_scope_stop_condition_dropped(tmp_path):
    # zod reproduction: LLM emitted "stop if changes are needed outside schemas.ts"
    # while the real fix (util.ts) is in editable_paths -> false-stop risk.
    (tmp_path / "schemas.ts").write_text("export const x = 1", encoding="utf-8")
    (tmp_path / "util.ts").write_text("export const y = 2", encoding="utf-8")
    wo = _wo(
        editable_paths=["util.ts", "schemas.ts"],
        stop_conditions=[
            "If the fix requires changes outside schemas.ts, stop and ask",
            "If type inference breaks, stop and ask",
        ],
        patch_expectations=["Changes only in schemas.ts", "Keep the diff minimal"],
    )
    _reconcile_contract(wo, tmp_path)
    # the narrowing file-specific stop condition is gone; the generic one stays
    assert not any("outside schemas.ts" in c for c in wo.stop_conditions)
    assert any("type inference" in c for c in wo.stop_conditions)
    # the canonical Lock-7 boundary survives
    assert any("outside editable_paths" in c for c in wo.stop_conditions)
    # the contradictory "only in schemas.ts" patch expectation is dropped
    assert not any("only in schemas.ts" in p.lower() for p in wo.patch_expectations)
    assert any("minimal" in p.lower() for p in wo.patch_expectations)


def test_directory_shaped_narrowing_stop_condition_dropped(tmp_path):
    # zod-001 0.1.11 WO repro: "outside packages/zod/src/v4/classic/schemas/"
    # is a dir-shaped boundary narrower than editable_paths (the true fix,
    # v4/core/util.ts, is editable but outside it) -> false-stop risk.
    wo = _wo(
        editable_paths=["packages/zod/src/v4/core/util.ts"],
        stop_conditions=[
            "If the fix requires changes outside packages/zod/src/v4/classic/schemas/",
            "If type inference breaks, stop and ask",
        ],
    )
    _reconcile_contract(wo, tmp_path)
    assert not any("classic/schemas" in c for c in wo.stop_conditions)
    assert any("type inference" in c for c in wo.stop_conditions)
    # canonical Lock-7 ("outside editable_paths", no slash) is appended, not dropped
    assert any("outside editable_paths" in c for c in wo.stop_conditions)


# 0.1.11 claude-cli provider (subscription CLI, no API key)

def test_claude_cli_provider_missing_binary_raises(monkeypatch):
    import sembl.generator as g
    monkeypatch.setattr(g.shutil, "which", lambda name: None)
    with pytest.raises(g.ProviderAPIError):
        g._call_claude_cli("sys", "user", None, None)
