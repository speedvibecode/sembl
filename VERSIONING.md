# Versioning rule (HARD RULE — active through at least 2026-07-08)

Sembl's version must be **consistent across every surface, in lockstep, in the same
change that lands a functional edit.** This rule exists because a functional change
(the OpenRouter provider) once shipped without a version bump, leaving the package,
site, and changelog out of sync. Do not let that happen again.

## The rule

Any **functional** change to the `sembl` package — a new feature, a behavior change,
or a bug fix (NOT pure docs/comments/tests) — MUST bump the version in the **same
commit/PR**, across **all** of these:

1. `pyproject.toml` → `version`
2. `sembl/__init__.py` → `__version__`
3. `sembl/cli.py` → `@click.version_option(...)`
4. `sembl-site/changelog.html` → a new top entry for the version
5. `sembl-site/index.html` → the hero terminal `Successfully installed sembl X.Y.Z`
6. `sembl-site/docs.html` → the "latest stable release (X.Y.Z)" callout

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

## Why time-boxed

Set as a hard rule through **2026-07-08** to build the habit during the fast-moving
early phase. Revisit then — most likely keep it permanently, possibly automated via a
pre-commit/CI check that fails if a `sembl/` code change has no matching version bump.
