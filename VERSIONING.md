# Versioning rule (HARD RULE — active through at least 2026-07-08)

Sembl's version must be **consistent across every surface, in lockstep, in the same
change that lands a functional edit.** This rule exists because a functional change
(the OpenRouter provider) once shipped without a version bump, leaving the package,
site, and changelog out of sync. Do not let that happen again.

## The rule

Any **functional** change to the `sembl` package — a new feature, a behavior change,
or a bug fix (NOT pure docs/comments/tests) — MUST bump the version in the **same
commit/PR**, across **all** of these:

**Package (sembl repo) — 2 spots, CI-enforced equal:**
1. `pyproject.toml` → `version`  (the packaging source; `release.yml` reads it)
2. `sembl/__init__.py` → `__version__`  (the runtime source)

`sembl/cli.py` no longer hard-codes the version — it derives from `__init__`
(`@click.version_option(__version__, ...)`), so it can never drift. At release,
`release.yml` **fails the publish** unless tag == pyproject == `__init__` (one fewer
thing to get wrong; you cannot ship an inconsistent package).

**Site (sembl-site repo) — 3 spots:**
3. `changelog.html` → a new top entry for the version
4. `index.html` → the hero terminal `Successfully installed sembl X.Y.Z`
5. `docs.html` → the "latest stable release (X.Y.Z)" callout

Never push a functional change that leaves these out of sync. Pure documentation or
internal refactors that don't change behavior do not require a bump, but if in doubt,
bump the patch version — it is cheaper than an inconsistent release.

`generator.py`'s `schema_version` is a SEPARATE concern (the Work Order JSON schema)
and is bumped only when the schema itself changes.

## Release (owner action)

After the version is bumped and pushed, publish it:

```bash
gh release create vX.Y.Z --title "vX.Y.Z" --notes "…"
```

The GitHub Release triggers `release.yml` → PyPI Trusted Publishing. PyPI versions are
**permanent — never reuse a version number.** The site (Vercel) auto-deploys on push,
so cut the GitHub Release close to the site push to keep "stable on PyPI" honest.

## Toward full automation (staged — owner enables)

The CI guard above already makes an *inconsistent* release impossible. The next step is
to automate the *bump itself* so the number is never decided by hand:

- **Conventional Commits** (`feat:`, `fix:`, `feat!:`) on every commit to `sembl`.
- **release-please** (Google's bot): on merge to `master` it reads the commit types,
  computes the next version, opens a "release PR" that bumps `pyproject.toml` +
  `sembl/__init__.py` + creates/updates `CHANGELOG.md`, and on merge tags `vX.Y.Z` — which
  fires the existing `release.yml` → PyPI. The site version can then be updated by a
  small release-triggered step (or kept manual per the rule above).

This is **not yet wired** because it must be enabled and tested in GitHub Actions
(repo permissions + a trial release PR) — only the owner can validate that without
risking the working PyPI pipeline. When ready: add `release-please` config targeting
`pyproject.toml` and `sembl/__init__.py`, grant the action `contents: write` +
`pull-requests: write`, and do one trial release on a patch.

## Why time-boxed

Set as a hard rule through **2026-07-08** to build the habit during the fast-moving
early phase. Revisit then — most likely keep it permanently, fully replaced by
release-please once it is validated.
