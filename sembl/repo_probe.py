"""
repo_probe.py

Extracts structured repo intelligence to ground Work Order generation.

Two layers:
  graphify         → broad project understanding (concepts, modules, architecture)
  code-review-graph → precise blast radius (files, calls, tests, imports)

Both degrade gracefully if unavailable.
"""

import subprocess
import json
import os
import shutil
import sys
from pathlib import Path
from dataclasses import dataclass, field


SUBPROCESS_ENCODING = "utf-8"


@dataclass
class RepoProbe:
    """Everything Sembl needs to know about a repo before generating a Work Order."""

    # Identity
    repo_path: str = ""
    project_name: str = ""
    git_branch: str = ""
    git_head_commit: str = ""
    git_is_dirty: bool = False

    # Project shape
    project_type: str = ""
    primary_languages: list = field(default_factory=list)
    framework_hints: list = field(default_factory=list)
    top_level_dirs: list = field(default_factory=list)

    # Project rules and commands
    readme_summary: str = ""
    project_rules: list = field(default_factory=list)
    test_commands: list = field(default_factory=list)
    lint_commands: list = field(default_factory=list)
    build_commands: list = field(default_factory=list)

    # Graphify — broad understanding
    graphify_available: bool = False
    graphify_summary: str = ""
    graphify_communities: str = ""
    graphify_task_context: str = ""

    # code-review-graph — structural precision
    crg_available: bool = False
    crg_node_count: int = 0
    crg_edge_count: int = 0
    crg_languages: list = field(default_factory=list)
    crg_blast_radius: list = field(default_factory=list)

    # Grounding
    context_basis: str = "direct_probe_fallback"
    graph_context_sources: list = field(default_factory=list)


def probe_repo(
    repo_path: str,
    task: str = "",
    *,
    use_graphify: bool = True,
    use_crg: bool = True,
) -> RepoProbe:
    """Run all probes. Each is independent — failures degrade gracefully."""
    p = RepoProbe(repo_path=repo_path)
    root = Path(repo_path).resolve()

    _probe_git(p, root)
    _probe_structure(p, root)
    _probe_project_type(p, root)
    _probe_rules_and_commands(p, root)
    if use_graphify:
        _probe_graphify(p, root, task)
    if use_crg:
        _probe_crg(p, root, task)
    _finalize_context_basis(p)

    return p


# ── Probes ────────────────────────────────────────────────────────────────────

def _probe_git(p: RepoProbe, root: Path):
    p.project_name = root.name
    try:
        p.git_branch = _run_git(root, "rev-parse", "--abbrev-ref", "HEAD")
    except Exception:
        try:
            p.git_branch = _run_git(root, "symbolic-ref", "--short", "HEAD")
        except Exception:
            pass

    try:
        p.git_head_commit = _run_git(root, "rev-parse", "HEAD")
    except Exception:
        p.git_head_commit = ""

    try:
        dirty = _run_git(root, "status", "--porcelain")
        p.git_is_dirty = bool(dirty.strip())
    except Exception:
        pass


def _probe_structure(p: RepoProbe, root: Path):
    skip = {"node_modules", "__pycache__", ".git", "dist", "build", ".venv", "venv", ".next"}
    try:
        p.top_level_dirs = [
            d.name for d in sorted(root.iterdir())
            if d.is_dir() and not d.name.startswith(".") and d.name not in skip
        ]
    except Exception:
        pass


def _probe_project_type(p: RepoProbe, root: Path):
    indicators, languages, frameworks = [], [], []

    # JavaScript / TypeScript
    if (root / "package.json").exists():
        languages.append("TypeScript/JavaScript")
        try:
            pkg = json.loads((root / "package.json").read_text(errors="ignore"))
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            if "expo" in deps or "expo-router" in deps:
                frameworks.append("Expo")
                if "react-native" in deps:
                    frameworks.append("React Native")
                indicators.append("Expo React Native app")
            elif "next" in deps:
                frameworks.append("Next.js"); indicators.append("Next.js app")
            elif "react" in deps:
                frameworks.append("React"); indicators.append("React SPA")
            if any(k in deps for k in ["express", "fastify", "koa", "hono"]):
                frameworks.append("Node API"); indicators.append("Node.js API")
            if "vite" in deps: frameworks.append("Vite")
            if "tailwindcss" in deps: frameworks.append("Tailwind CSS")
            if "prisma" in deps: frameworks.append("Prisma")
            if "drizzle-orm" in deps: frameworks.append("Drizzle ORM")
        except Exception:
            pass

    # Python
    for pyfile in ["pyproject.toml", "setup.py", "requirements.txt"]:
        if (root / pyfile).exists():
            languages.append("Python")
            content = (root / pyfile).read_text(errors="ignore").lower()
            if "fastapi" in content:
                frameworks.append("FastAPI"); indicators.append("Python API (FastAPI)")
            elif "flask" in content:
                frameworks.append("Flask"); indicators.append("Python API (Flask)")
            elif "django" in content:
                frameworks.append("Django"); indicators.append("Django app")
            elif "streamlit" in content:
                frameworks.append("Streamlit"); indicators.append("Streamlit app")
            break

    # Rust / Go
    if (root / "Cargo.toml").exists():
        languages.append("Rust"); indicators.append("Rust project")
    if (root / "go.mod").exists():
        languages.append("Go"); indicators.append("Go module")

    # Monorepo signals
    if any((root / f).exists() for f in ["pnpm-workspace.yaml", "lerna.json", "turbo.json"]):
        indicators.append("monorepo")

    p.primary_languages = list(dict.fromkeys(languages))
    p.framework_hints = list(dict.fromkeys(frameworks))
    p.project_type = ", ".join(indicators) if indicators else "general software project"


def _probe_rules_and_commands(p: RepoProbe, root: Path):
    # Project rules
    rule_files = ["AGENTS.md", "CLAUDE.md", ".cursor/rules", ".cursorrules", "CONTRIBUTING.md"]
    for rf in rule_files:
        rp = root / rf
        if rp.is_file():
            p.project_rules.append(f"[{rf}]\n{rp.read_text(errors='ignore')[:1500]}")

    # README
    for name in ["README.md", "README.rst", "readme.md"]:
        rp = root / name
        if rp.exists():
            p.readme_summary = rp.read_text(errors="ignore")[:1200]
            break

    # Commands from package.json
    if (root / "package.json").exists():
        try:
            scripts = json.loads((root / "package.json").read_text(errors="ignore")).get("scripts", {})
            for k in ["test", "test:unit", "vitest", "jest"]:
                if k in scripts: p.test_commands.append(f"npm run {k}")
            for k in ["lint", "type-check", "typecheck"]:
                if k in scripts: p.lint_commands.append(f"npm run {k}")
            for k in ["build", "compile"]:
                if k in scripts: p.build_commands.append(f"npm run {k}")
        except Exception:
            pass

    # Commands from pyproject.toml
    if (root / "pyproject.toml").exists():
        content = (root / "pyproject.toml").read_text(errors="ignore").lower()
        if "pytest" in content: p.test_commands.append("pytest")
        if "ruff" in content: p.lint_commands.append("ruff check .")
        if "mypy" in content: p.lint_commands.append("mypy .")


def _probe_graphify(p: RepoProbe, root: Path, task: str):
    """Broad project understanding via graphify knowledge graph."""
    try:
        graphify = _resolve_cli("graphify")
        if not graphify:
            return

        check = _run_optional([graphify, "--help"], root, timeout=10)
        if check.returncode != 0:
            return
        p.graphify_available = True

        summary = _run_optional(
            [
                graphify,
                "query",
                "Summarise this project: its purpose, main modules, key entry points, "
                "and architectural patterns. Be concise - 200 words max.",
            ],
            root,
            timeout=90,
        )
        if summary.returncode == 0 and summary.stdout.strip():
            p.graphify_summary = summary.stdout.strip()[:2500]

        communities = _run_optional(
            [
                graphify,
                "query",
                "List the main code communities or modules with one-line descriptions each.",
            ],
            root,
            timeout=60,
        )
        if communities.returncode == 0 and communities.stdout.strip():
            p.graphify_communities = communities.stdout.strip()[:1500]

        if task:
            task_context = _run_optional(
                [
                    graphify,
                    "query",
                    "For this developer task, identify the likely implementation files, "
                    "test files, owning modules, risky dependencies, and areas that should "
                    "remain read-only. Be specific and cite graph node/file names when possible. "
                    f"Task: {task}",
                ],
                root,
                timeout=90,
            )
            if task_context.returncode == 0 and task_context.stdout.strip():
                p.graphify_task_context = task_context.stdout.strip()[:3000]

    except (FileNotFoundError, subprocess.TimeoutExpired, Exception):
        p.graphify_available = False


def _probe_crg(p: RepoProbe, root: Path, task: str):
    """Precise structural intelligence via code-review-graph."""
    try:
        crg = _resolve_cli("code-review-graph")
        if not crg:
            return

        crg_common_args = _crg_common_args(root)
        crg_env = _crg_env(root)
        status = _run_optional([crg, "status", *crg_common_args], root, timeout=15, env=crg_env)
        if status.returncode != 0:
            build = _run_optional([crg, "build", *crg_common_args], root, timeout=180, env=crg_env)
            if build.returncode != 0:
                return
            status = _run_optional([crg, "status", *crg_common_args], root, timeout=15, env=crg_env)

        p.crg_available = True
        for line in status.stdout.splitlines():
            ll = line.lower()
            if "nodes:" in ll:
                try: p.crg_node_count = int("".join(filter(str.isdigit, line.split(":")[-1].split(",")[0])))
                except Exception: pass
            if "edges:" in ll:
                try: p.crg_edge_count = int("".join(filter(str.isdigit, line.split(":")[-1].split(",")[0])))
                except Exception: pass
            if "languages:" in ll:
                p.crg_languages = [x.strip() for x in line.split(":")[-1].split(",")]

        # Impact summary for the current working tree. CRG 2.x exposes this as
        # detect-changes rather than the older blast-radius command.
        if task:
            impact = _run_optional(
                [crg, "detect-changes", "--brief", "--repo", str(root)],
                root, timeout=30, env=crg_env,
            )
            if impact.returncode == 0 and impact.stdout.strip():
                p.crg_blast_radius.append(impact.stdout.strip()[:1200])

    except (FileNotFoundError, subprocess.TimeoutExpired, Exception):
        p.crg_available = False


def _task_keywords(task: str) -> list[str]:
    stop = {
        "add","fix","update","change","make","create","remove","delete","refactor",
        "the","a","an","to","for","in","of","and","or","with","this","that",
        "it","is","on","at","by","from","into","as","so","but","should","need"
    }
    words = task.lower().replace("-", " ").replace("_", " ").split()
    return [w for w in words if w not in stop and len(w) > 3]


def _finalize_context_basis(p: RepoProbe):
    sources = []
    if p.graphify_task_context:
        sources.append("graphify task context")
    if p.graphify_summary:
        sources.append("graphify project summary")
    if p.graphify_communities:
        sources.append("graphify code communities")
    if p.crg_available and (p.crg_node_count or p.crg_edge_count):
        sources.append("code-review-graph structural graph")
    if p.crg_blast_radius:
        sources.append("code-review-graph impact summary")

    p.graph_context_sources = sources
    p.context_basis = "graph_pipeline" if sources else "direct_probe_fallback"


def _run(cmd: list[str], cwd: Path, timeout: int = 10) -> str:
    r = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding=SUBPROCESS_ENCODING,
        errors="replace",
        cwd=str(cwd),
        timeout=timeout,
    )
    if r.returncode != 0:
        raise RuntimeError((r.stderr or r.stdout).strip())
    return r.stdout.strip()


def _run_optional(
    cmd: list[str],
    cwd: Path,
    *,
    timeout: int,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding=SUBPROCESS_ENCODING,
        errors="replace",
        cwd=str(cwd),
        timeout=timeout,
        env=_subprocess_env(env),
    )


def _run_git(root: Path, *args: str) -> str:
    # Read-only probes should work in sandbox/copied repos without changing global Git config.
    return _run(["git", "-c", f"safe.directory={root.as_posix()}", *args], root)


def _resolve_cli(name: str) -> str | None:
    """Find optional integration CLIs on PATH or beside the current venv Python."""
    found = shutil.which(name)
    if found:
        return found

    scripts_dir = Path(sys.executable).parent
    candidates = [scripts_dir / name]
    if os.name == "nt":
        candidates.extend([scripts_dir / f"{name}.exe", scripts_dir / f"{name}.cmd"])

    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    return None


def _crg_common_args(root: Path) -> list[str]:
    args = ["--repo", str(root)]
    data_dir = _crg_data_dir(root)
    if data_dir:
        args.extend(["--data-dir", data_dir])
    return args


def _crg_env(root: Path | None = None) -> dict[str, str] | None:
    env = os.environ.copy()
    data_dir = _crg_data_dir(root)
    if data_dir:
        env["CRG_DATA_DIR"] = data_dir
        env["SEMBL_CRG_DATA_DIR"] = data_dir
        env["USERPROFILE"] = _crg_home(data_dir)
    env["PYTHONIOENCODING"] = "utf-8"
    return env


def _crg_data_dir(root: Path | None = None) -> str:
    explicit = os.environ.get("SEMBL_CRG_DATA_DIR")
    if explicit:
        return explicit

    generic = os.environ.get("CRG_DATA_DIR")
    if generic and (root is None or _data_dir_matches_repo(generic, root)):
        return generic

    if root is not None:
        return str(_default_crg_data_dir(root))

    return generic or ""


def _data_dir_matches_repo(data_dir: str, root: Path) -> bool:
    try:
        parts = {part.lower() for part in Path(data_dir).resolve().parts}
    except Exception:
        parts = {part.lower() for part in Path(data_dir).parts}
    repo_names = {root.name.lower(), _safe_name(root.name)}
    return bool(parts & repo_names)


def _default_crg_data_dir(root: Path) -> Path:
    package_root = Path(__file__).resolve().parent.parent
    return package_root / ".crg-data" / _safe_name(root.name)


def _safe_name(value: str) -> str:
    safe = "".join(ch.lower() if ch.isalnum() else "-" for ch in value)
    return "-".join(part for part in safe.split("-") if part)


def _crg_home(data_dir: str) -> str:
    configured = os.environ.get("SEMBL_CRG_HOME") or os.environ.get("CRG_HOME")
    if configured:
        return configured

    home = Path(data_dir).resolve().parent / ".crg-home"
    try:
        home.mkdir(parents=True, exist_ok=True)
    except Exception:
        pass
    return str(home)


def _subprocess_env(env: dict[str, str] | None = None) -> dict[str, str]:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    merged.setdefault("PYTHONIOENCODING", "utf-8")
    return merged
