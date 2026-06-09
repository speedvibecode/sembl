"""
graph_diagnostics.py

One place that answers: is graph context real and ready for this repo?

It detects the graph tools (Graphify, code-review-graph), their built
artifacts, the environment, and produces specific repair commands. Everything
here is cheap and side-effect free (no LLM calls, no environment mutation) —
detection only. `sembl doctor` renders it; `sembl generate` uses
`resolve_graph_plan` to decide what to do per --graph-mode.
"""

import os
import sys
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

from . import __version__
from .repo_probe import (
    SUBPROCESS_ENCODING,
    _resolve_cli,
    _crg_data_dir,
    _crg_common_args,
    _crg_env,
    _data_dir_matches_repo,
)

INSTALL_HINT = 'pip install "sembl[graph-pipeline]"'
INSTALL_HINT_UV = 'uv pip install "sembl[graph-pipeline]"'

PROVIDER_ENV = {
    "openai": "OPENAI_API_KEY",
    "anthropic": "ANTHROPIC_API_KEY",
    "gemini": "GEMINI_API_KEY",
    "nvidia": "NVIDIA_API_KEY",
    "openrouter": "OPENROUTER_API_KEY",
}


@dataclass
class Check:
    """A single diagnostic line: what was checked, the verdict, and the fix."""
    name: str
    status: str          # "ok" | "warn" | "missing" | "info"
    detail: str = ""
    fix: str = ""


@dataclass
class GraphDiagnostics:
    repo_path: str = ""
    repo_valid: bool = False
    repo_is_git: bool = False

    sembl_version: str = __version__
    python_version: str = ""
    python_executable: str = ""
    provider_keys: dict = field(default_factory=dict)

    graphify_path: str = ""
    crg_path: str = ""
    graphify_version: str = ""   # tool version (provenance); "" if unavailable
    crg_version: str = ""

    graphify_out_dir: str = ""
    graphify_graph: str = "missing"   # "present" | "missing"

    crg_data_dir: str = ""
    crg_db_path: str = ""
    crg_status: str = "missing"       # "present" | "empty" | "missing"
    crg_nodes: int = 0
    crg_stale_env: bool = False

    checks: list = field(default_factory=list)

    @property
    def graphify_installed(self) -> bool:
        return bool(self.graphify_path)

    @property
    def crg_installed(self) -> bool:
        return bool(self.crg_path)

    @property
    def graph_available(self) -> bool:
        """True if at least one usable graph source exists for this repo."""
        graphify_ready = self.graphify_installed and self.graphify_graph == "present"
        crg_ready = self.crg_installed and self.crg_status == "present"
        return graphify_ready or crg_ready

    def to_dict(self) -> dict:
        import dataclasses
        d = dataclasses.asdict(self)
        d["graphify_installed"] = self.graphify_installed
        d["crg_installed"] = self.crg_installed
        d["graph_available"] = self.graph_available
        return d


# ── Detection ──────────────────────────────────────────────────────────────

def _tool_version(cli_path: str) -> str:
    """Best-effort tool version via `<cli> --version`. Empty string on any failure.

    Tool-version knowledge lives here (the graph adapter boundary) so callers — the CLI
    doctor, work-order provenance, and the benchmark — all read it from one place.
    """
    if not cli_path:
        return ""
    import subprocess
    try:
        r = subprocess.run([cli_path, "--version"], capture_output=True, text=True,
                           timeout=10, encoding="utf-8", errors="replace")
        out = (r.stdout or r.stderr or "").strip().splitlines()
        return out[0].strip()[:80] if out else ""
    except Exception:
        return ""


def detect_tool_versions(repo_path: str = ".") -> dict:
    """{tool: version_or_empty} for the graph tools, for provenance capture."""
    return {
        "graphify": _tool_version(_resolve_cli("graphify") or ""),
        "code-review-graph": _tool_version(_resolve_cli("code-review-graph") or ""),
    }


def detect(repo_path: str) -> GraphDiagnostics:
    """Inspect the repo and graph subsystem. No LLM calls, no mutations."""
    root = Path(repo_path).resolve()
    d = GraphDiagnostics(repo_path=str(root))

    d.repo_valid = root.is_dir()
    d.repo_is_git = (root / ".git").exists()

    d.python_version = sys.version.split()[0]
    d.python_executable = sys.executable
    d.provider_keys = {p: bool(os.environ.get(env)) for p, env in PROVIDER_ENV.items()}

    d.graphify_path = _resolve_cli("graphify") or ""
    d.crg_path = _resolve_cli("code-review-graph") or ""
    d.graphify_version = _tool_version(d.graphify_path) if d.graphify_path else ""
    d.crg_version = _tool_version(d.crg_path) if d.crg_path else ""

    # Graphify graph artifact: graphify-out/graph.json (or $GRAPHIFY_OUT).
    out_dir = Path(os.environ.get("GRAPHIFY_OUT") or (root / "graphify-out"))
    d.graphify_out_dir = str(out_dir)
    graph_json = out_dir / "graph.json"
    if graph_json.is_file() and graph_json.stat().st_size > 2:
        d.graphify_graph = "present"

    # code-review-graph database: <data-dir>/graph.db
    data_dir = _crg_data_dir(root)
    d.crg_data_dir = data_dir or ""
    if data_dir:
        db = Path(data_dir) / "graph.db"
        d.crg_db_path = str(db)
        if db.is_file() and db.stat().st_size > 0:
            d.crg_nodes = _crg_node_count(root)
            d.crg_status = "present" if d.crg_nodes > 0 else "empty"

    # Stale env: CRG_DATA_DIR points at a different repo than this one.
    env_dir = os.environ.get("CRG_DATA_DIR")
    if env_dir and not _data_dir_matches_repo(env_dir, root):
        d.crg_stale_env = True

    d.checks = _build_checks(d, root)
    return d


def _crg_node_count(root: Path) -> int:
    """Ask code-review-graph for its node count. Returns 0 on any failure."""
    crg = _resolve_cli("code-review-graph")
    if not crg:
        return 0
    try:
        r = subprocess.run(
            [crg, "status", *_crg_common_args(root)],
            capture_output=True, text=True, encoding=SUBPROCESS_ENCODING,
            errors="replace", cwd=str(root), timeout=20, env=_crg_env(root),
        )
    except Exception:
        return 0
    if r.returncode != 0:
        return 0
    for line in r.stdout.splitlines():
        if "nodes:" in line.lower():
            digits = "".join(ch for ch in line.split(":")[-1] if ch.isdigit())
            if digits:
                return int(digits)
    return 0


def _build_checks(d: GraphDiagnostics, root: Path) -> list:
    checks = []

    # Repo
    if not d.repo_valid:
        checks.append(Check("Repository", "missing",
                            f"{d.repo_path} is not a directory.",
                            "Pass a valid path with --repo."))
    elif not d.repo_is_git:
        checks.append(Check("Repository", "warn",
                            "Not a git project root (no .git found). Sembl still works, "
                            "but graph tools are most accurate on a real project root.", ""))
    else:
        checks.append(Check("Repository", "ok", str(root)))

    # Provider key
    have = [p for p, ok in d.provider_keys.items() if ok]
    if have:
        checks.append(Check("Provider key", "ok", "set for: " + ", ".join(have)))
    else:
        checks.append(Check("Provider key", "warn",
                            "No provider key found in the environment.",
                            "Set one of: " + ", ".join(PROVIDER_ENV.values())))

    # Graphify tool + graph
    if d.graphify_installed:
        checks.append(Check("Graphify", "ok", d.graphify_path))
        if d.graphify_graph == "present":
            checks.append(Check("Graphify graph", "ok", graph_json_path(d)))
        else:
            checks.append(Check("Graphify graph", "missing",
                                f"No graph.json under {d.graphify_out_dir}.",
                                graphify_build_cmd(root)))
    else:
        checks.append(Check("Graphify", "missing",
                            "Graphify is not installed.", INSTALL_HINT))

    # code-review-graph tool + database
    if d.crg_installed:
        checks.append(Check("code-review-graph", "ok", d.crg_path))
        if d.crg_status == "present":
            checks.append(Check("CRG database", "ok",
                                f"{d.crg_nodes} nodes at {d.crg_db_path}"))
        elif d.crg_status == "empty":
            checks.append(Check("CRG database", "warn",
                                "Database exists but has no nodes.",
                                crg_build_cmd(root, d.crg_data_dir)))
        else:
            checks.append(Check("CRG database", "missing",
                                f"No graph.db at {d.crg_db_path or d.crg_data_dir}.",
                                crg_build_cmd(root, d.crg_data_dir)))
    else:
        checks.append(Check("code-review-graph", "missing",
                            "code-review-graph is not installed.", INSTALL_HINT))

    if d.crg_stale_env:
        checks.append(Check("CRG_DATA_DIR", "warn",
                            "CRG_DATA_DIR points at a different repo; Sembl will use a "
                            "repo-specific folder instead.",
                            f"Set SEMBL_CRG_DATA_DIR={d.crg_data_dir} to be explicit."))

    return checks


# ── Repair commands ──────────────────────────────────────────────────────────

def graph_json_path(d: GraphDiagnostics) -> str:
    return str(Path(d.graphify_out_dir) / "graph.json")


def graphify_build_cmd(root: Path) -> str:
    return f'graphify update "{root}" --no-cluster'


def crg_build_cmd(root: Path, data_dir: str) -> str:
    dd = data_dir or "<data-dir>"
    return f'code-review-graph build --repo "{root}" --data-dir "{dd}" --skip-flows'


def repair_commands(d: GraphDiagnostics) -> list:
    """Ordered, copy-pasteable commands to make graph context available."""
    root = Path(d.repo_path)
    cmds = []
    if not d.graphify_installed or not d.crg_installed:
        cmds.append(INSTALL_HINT)
    if d.graphify_installed and d.graphify_graph != "present":
        cmds.append(graphify_build_cmd(root))
    if d.crg_installed and d.crg_status != "present":
        cmds.append(crg_build_cmd(root, d.crg_data_dir))
    return cmds


def tools_missing(d: GraphDiagnostics) -> bool:
    return not d.graphify_installed or not d.crg_installed


# ── Decision logic (pure, testable) ──────────────────────────────────────────

def resolve_graph_plan(mode: str, d: GraphDiagnostics) -> tuple:
    """
    Decide what generation should do, given the graph mode and diagnostics.

    Returns (action, message) where action is one of:
      "off"      — skip graph tools entirely
      "use"      — graph context is available; use it
      "fallback" — graph context unavailable; proceed with direct repo probing
      "fail"     — graph context required but unavailable; do not call the LLM
    """
    mode = (mode or "auto").lower()
    if mode == "off":
        return ("off", "Graph tools disabled (--graph-mode off). Using direct repo probing.")

    if d.graph_available:
        srcs = []
        if d.graphify_installed and d.graphify_graph == "present":
            srcs.append("Graphify")
        if d.crg_installed and d.crg_status == "present":
            srcs.append(f"code-review-graph ({d.crg_nodes} nodes)")
        return ("use", "Graph context available: " + ", ".join(srcs) + ".")

    reason = _unavailable_reason(d)
    if mode == "required":
        return ("fail", reason)
    return ("fallback", reason)


def _unavailable_reason(d: GraphDiagnostics) -> str:
    """A specific explanation of why graph context is not available."""
    bits = []
    if not d.graphify_installed:
        bits.append("Graphify is not installed")
    elif d.graphify_graph != "present":
        bits.append("Graphify is installed but its graph is not built")
    if not d.crg_installed:
        bits.append("code-review-graph is not installed")
    elif d.crg_status == "empty":
        bits.append("the code-review-graph database is empty")
    elif d.crg_status != "present":
        bits.append("the code-review-graph database is not built")
    return "No graph context for this repo: " + "; ".join(bits) + "."


# ── Opt-in tool install (consent happens at the CLI layer) ───────────────────

def install_graph_tools() -> tuple:
    """
    Install the graph extra into the current interpreter. Returns (ok, output).
    Only ever called after explicit user consent in the CLI.
    """
    cmd = [sys.executable, "-m", "pip", "install", "sembl[graph-pipeline]"]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                           encoding=SUBPROCESS_ENCODING, errors="replace", timeout=600)
    except FileNotFoundError:
        return (False, "pip is not available in this environment. Try: " + INSTALL_HINT_UV)
    except Exception as e:  # noqa: BLE001
        return (False, str(e))
    out = (r.stdout or "") + (r.stderr or "")
    return (r.returncode == 0, out.strip())
