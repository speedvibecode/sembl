# Supabase Existing Project Takeover Runbook

Target project:

```text
https://djquuvkwnjpweubzrsnn.supabase.co
```

## Current State

- The project contains old Sembl public-schema objects.
- Public tables report zero rows.
- No Edge Functions are deployed.
- Supabase migration history has seven old Sembl migration records.
- Supabase-backed build tasks remain blocked until reset is complete.

## Destructive Reset Scope

The intended takeover reset is:

- Drop old app-owned objects from the `public` schema.
- Drop old app-owned enum/types, tables, views, functions, policies, triggers, and constraints through the schema drop.
- Recreate `public` with standard Supabase grants.
- Clear old Supabase migration-history rows only after the schema reset succeeds.
- Preserve Supabase-managed system schemas such as `auth`, `storage`, `realtime`, `extensions`, and other platform schemas.
- Do not delete provider credentials, project settings, or committed files.

## Required Approval

Before executing, get explicit confirmation for this exact target and destructive scope:

```text
I approve destructively resetting the existing Supabase project
https://djquuvkwnjpweubzrsnn.supabase.co by dropping old app-owned public schema
state and clearing old Sembl migration history.
```

## Verification After Reset

After reset:

- `public` exists.
- Old Sembl public tables no longer exist.
- Old Sembl migration-history rows are gone.
- Supabase system schemas remain intact.
- `graph/service_preflight.json` records Supabase takeover reset as complete.
- `npm run graph:validate` passes.
