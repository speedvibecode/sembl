---
name: sembl-setup-bounds
description: Use to create a Sembl bounds.json for a repo so changes can be gated. Derives editable_paths/forbidden_areas from a Spec Kit tasks.md, a known planning tool (Kiro/Tessl/AGENTS.md/Cursor rules), or by hand. Trigger on "set up sembl bounds", "create a bounds file", "make this repo gateable", "turn the spec into bounds".
---

# Set up Sembl bounds for a repo

`sembl verify` reads a four-field contract: `editable_paths`, `forbidden_areas`,
`churn_budget`, and optional `scope_tolerance`. The gate is only as good as these
bounds, so derive them from a precise source — a spec that names files — not a vague
issue. (Measured on 437 real PRs: issue/prose-derived bounds are usable <6% of the
time; a `tasks.md` that names files is the right input.)

## Pick the best available source

1. **A Spec Kit `tasks.md`** (or any doc that names exact file paths) — the ideal
   source, since each task lists the files it will touch:
   ```bash
   sembl bounds --from spec-kit            # auto-finds specs/**/tasks.md
   sembl bounds --from spec-kit --source "specs/**/plan.md"
   ```

2. **Another planning tool** — declarative presets, no code:
   ```bash
   sembl bounds --from kiro          # .kiro/specs/**/tasks.md
   sembl bounds --from tessl
   sembl bounds --from agents-md     # AGENTS.md / CLAUDE.md
   sembl bounds --from cursor-rules
   ```
   For anything else, write a small adapter config and `sembl bounds --config adapter.json`
   (what files to read, how to pull paths, what's forbidden).

3. **By hand** — when there's no spec, write `bounds.json` at the repo root:
   ```json
   {
     "editable_paths": ["src/auth/", "src/api/routes/login.ts"],
     "forbidden_areas": ["migrations/", "infra/", ".github/"],
     "churn_budget": { "max_files": 6, "max_lines": 200 }
   }
   ```

## Verify it works

`verify` auto-discovers `bounds.json` (then `.sembl/bounds.json`) at the repo root, so
once the file exists most integrations run zero-arg:

```bash
git diff | sembl verify --diff -
```

## Guidance

- Be precise with `editable_paths` — list the real directories/files the change
  should touch. Incomplete bounds make scope noisy (it's advisory and tolerant by
  default, but garbage in = noise out).
- You do **not** need to list tests, generated files, lockfiles, or docs/changelogs —
  those are always treated as in-scope.
- Put genuinely off-limits areas in `forbidden_areas` — those are a hard BLOCK.
- If you used a spec tool, keep the spec as the source of truth and regenerate bounds
  when it changes.
