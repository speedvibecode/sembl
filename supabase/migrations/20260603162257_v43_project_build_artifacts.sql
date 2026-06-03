-- Sembl v4.3 project build artifacts.
-- Generated software is a compiled artifact of published spec and graph state.

do $$
begin
  create type public.project_build_status as enum (
    'queued',
    'generating',
    'generated',
    'github_blocked',
    'deploy_blocked',
    'failed'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.project_build_file_role as enum (
    'source',
    'config',
    'test',
    'doc',
    'asset'
  );
exception when duplicate_object then null;
end $$;

alter type public.event_type add value if not exists 'BuildStarted';
alter type public.event_type add value if not exists 'BuildCompleted';
alter type public.event_type add value if not exists 'BuildFailed';

create table if not exists public.project_build_runs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid not null references public.branches(id),
  graph_version_id uuid not null references public.graph_versions(id),
  execution_run_id uuid references public.execution_runs(id),
  status public.project_build_status not null default 'queued',
  model text not null,
  prompt_hash text not null,
  summary text not null default '',
  repository_url text,
  deployment_url text,
  failure_reason text,
  metadata jsonb not null default '{}',
  triggered_by uuid not null references auth.users(id),
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_build_files (
  id uuid primary key default gen_random_uuid(),
  build_run_id uuid not null references public.project_build_runs(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  path text not null,
  role public.project_build_file_role not null default 'source',
  language text,
  content text not null,
  checksum text not null,
  byte_size integer not null check (byte_size >= 0),
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  unique (build_run_id, path),
  check (path !~ '(^/|^\.\.?/|/\.\.?/|/\.\.?$|\\)')
);

create index if not exists idx_project_build_runs_project_created
  on public.project_build_runs(project_id, created_at desc);

create index if not exists idx_project_build_runs_graph_version
  on public.project_build_runs(graph_version_id);

create index if not exists idx_project_build_files_build_path
  on public.project_build_files(build_run_id, path);

create index if not exists idx_project_build_files_project
  on public.project_build_files(project_id);

drop trigger if exists trg_project_build_runs_updated_at on public.project_build_runs;
create trigger trg_project_build_runs_updated_at
before update on public.project_build_runs
for each row execute function public.set_updated_at();

drop trigger if exists trg_project_build_files_immutable on public.project_build_files;
create trigger trg_project_build_files_immutable
before update or delete on public.project_build_files
for each row execute function sembl_private.prevent_immutable_update_delete();

alter table public.project_build_runs enable row level security;
alter table public.project_build_files enable row level security;

drop policy if exists "project_build_runs_select_project_members" on public.project_build_runs;
create policy "project_build_runs_select_project_members"
on public.project_build_runs
for select
to authenticated
using (
  exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    where p.id = project_build_runs.project_id
      and wm.user_id = (select auth.uid())
  )
);

drop policy if exists "project_build_runs_insert_project_members" on public.project_build_runs;
create policy "project_build_runs_insert_project_members"
on public.project_build_runs
for insert
to authenticated
with check (
  triggered_by = (select auth.uid())
  and exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    where p.id = project_build_runs.project_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin', 'member')
  )
);

drop policy if exists "project_build_runs_update_project_members" on public.project_build_runs;
create policy "project_build_runs_update_project_members"
on public.project_build_runs
for update
to authenticated
using (
  exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    where p.id = project_build_runs.project_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin', 'member')
  )
)
with check (
  exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    where p.id = project_build_runs.project_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin', 'member')
  )
);

drop policy if exists "project_build_files_select_project_members" on public.project_build_files;
create policy "project_build_files_select_project_members"
on public.project_build_files
for select
to authenticated
using (
  exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    where p.id = project_build_files.project_id
      and wm.user_id = (select auth.uid())
  )
);

drop policy if exists "project_build_files_insert_project_members" on public.project_build_files;
create policy "project_build_files_insert_project_members"
on public.project_build_files
for insert
to authenticated
with check (
  exists (
    select 1
    from public.projects p
    join public.workspace_members wm on wm.workspace_id = p.workspace_id
    join public.project_build_runs pbr on pbr.project_id = p.id
    where p.id = project_build_files.project_id
      and pbr.id = project_build_files.build_run_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin', 'member')
  )
);

grant select on public.project_build_runs, public.project_build_files to authenticated;
grant insert, update on public.project_build_runs to authenticated;
grant insert on public.project_build_files to authenticated;
