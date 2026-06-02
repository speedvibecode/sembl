create extension if not exists pgcrypto;

create schema if not exists sembl_private;

do $$
begin
  create type public.workspace_role as enum ('owner', 'admin', 'member', 'viewer');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.project_lifecycle_state as enum (
    'draft',
    'ready_for_execution',
    'awaiting_approval',
    'executing',
    'reconciling',
    'deploying',
    'active',
    'escalated'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.operational_mode as enum ('documentation', 'execution', 'iteration');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.specification_type as enum (
    'pdd',
    'prd',
    'nfr',
    'uiux',
    'system_design',
    'db_schema',
    'api_spec',
    'tech_architecture'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.graph_node_type as enum (
    'entity',
    'interface',
    'integration_contract',
    'flow',
    'invariant',
    'execution_boundary'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.graph_edge_type as enum (
    'dependency',
    'implements',
    'precedes',
    'triggers',
    'owns',
    'lineage'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.branch_state as enum (
    'active',
    'diverged',
    'merge_pending',
    'merged',
    'rejected',
    'archived'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.delta_operation as enum ('add', 'modify', 'remove');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.approval_type as enum (
    'execution_approval',
    'mutation_approval',
    'merge_approval'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.approval_status as enum (
    'pending',
    'under_review',
    'approved',
    'rejected',
    'expired'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.execution_run_status as enum (
    'queued',
    'preparing',
    'running',
    'validating',
    'reconciling',
    'completed',
    'failed',
    'escalated'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.task_status as enum (
    'pending',
    'running',
    'completed',
    'failed',
    'skipped'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.reconciliation_status as enum (
    'pending',
    'snapshot_taken',
    'diff_generated',
    'invariant_validated',
    'lineage_updated',
    'committed',
    'failed',
    'rolled_back'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.deployment_status as enum (
    'not_deployed',
    'deploying',
    'healthy',
    'degraded',
    'failed',
    'rolling_back',
    'rolled_back'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.validation_target_type as enum (
    'specification',
    'execution_run',
    'reconciliation_attempt',
    'merge_attempt',
    'repository_ingestion'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.validation_group_status as enum (
    'running',
    'passed',
    'passed_with_warnings',
    'failed'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.validation_run_status as enum (
    'running',
    'passed',
    'passed_with_warnings',
    'failed'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.violation_severity as enum (
    'blocking',
    'warning',
    'informational',
    'escalated'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.ingestion_status as enum (
    'connected',
    'analyzing',
    'reconstructing',
    'confidence_review',
    'validating',
    'ready_for_activation',
    'activated',
    'failed'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.confidence_level as enum ('high', 'medium', 'low');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.confidence_item_status as enum (
    'pending',
    'confirmed',
    'rejected',
    'escalated'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.notification_severity as enum (
    'info',
    'warning',
    'action_required',
    'critical'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.escalation_trigger as enum (
    'repeated_validation_failure',
    'repeated_reconciliation_failure',
    'unresolved_merge_conflict',
    'repository_reconstruction_failure',
    'unresolved_ambiguity'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.escalation_status as enum (
    'open',
    'in_resolution',
    'resolved',
    'closed'
  );
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.event_type as enum (
    'SpecificationCreated',
    'SpecificationModified',
    'ValidationTriggered',
    'ValidationPassed',
    'ValidationFailed',
    'GraphMutationProposed',
    'GraphMutationApproved',
    'GraphMutationRejected',
    'GraphMutationCommitted',
    'ExecutionApprovalRequested',
    'ExecutionApproved',
    'ExecutionStarted',
    'ExecutionCompleted',
    'ExecutionFailed',
    'ReconciliationStarted',
    'ReconciliationCompleted',
    'ReconciliationFailed',
    'ReconciliationRolledBack',
    'DeploymentStarted',
    'DeploymentCompleted',
    'DeploymentFailed',
    'DeploymentRolledBack',
    'BranchCreated',
    'MergeRequested',
    'MergeApproved',
    'MergeCompleted',
    'MergeRolledBack',
    'EscalationTriggered',
    'RepositoryIngestionStarted',
    'RepositoryIngestionCompleted',
    'RepositoryIngestionFailed'
  );
exception when duplicate_object then null;
end $$;

create or replace function sembl_private.prevent_immutable_update_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'canonical record % is immutable', tg_table_name
    using errcode = '45000';
end;
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspace_members (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.workspace_role not null default 'member',
  joined_at timestamptz not null default now(),
  unique (workspace_id, user_id)
);

create table if not exists public.workspace_integrations (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  provider text not null check (provider in ('github', 'vercel')),
  external_id text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  name text not null,
  slug text not null,
  lifecycle_state public.project_lifecycle_state not null default 'draft',
  operational_mode public.operational_mode not null default 'documentation',
  active_branch_id uuid,
  active_graph_version_id uuid,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workspace_id, slug)
);

create table if not exists public.repository_references (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  provider text not null default 'github' check (provider = 'github'),
  external_url text not null,
  external_id text not null,
  default_branch text not null default 'main',
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.specification_documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  spec_type public.specification_type not null,
  active_revision_id uuid,
  draft_content text,
  draft_updated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (project_id, spec_type)
);

create table if not exists public.specification_revisions (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references public.specification_documents(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  revision_number integer not null,
  content text not null,
  content_hash text not null,
  authored_by uuid not null references auth.users(id),
  parent_revision_id uuid references public.specification_revisions(id),
  created_at timestamptz not null default now(),
  unique (document_id, revision_number)
);

create table if not exists public.graph_versions (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  version_number integer not null,
  parent_version_id uuid references public.graph_versions(id),
  reconciliation_id uuid,
  source_spec_revision_id uuid references public.specification_revisions(id),
  semantic_diff_id uuid,
  created_at timestamptz not null default now(),
  unique (project_id, version_number)
);

create table if not exists public.graph_nodes (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  graph_version_id uuid not null references public.graph_versions(id) on delete cascade,
  node_type public.graph_node_type not null,
  name text not null,
  payload jsonb not null default '{}',
  source_spec_type public.specification_type,
  source_revision_id uuid references public.specification_revisions(id),
  created_at timestamptz not null default now()
);

create table if not exists public.graph_edges (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  graph_version_id uuid not null references public.graph_versions(id) on delete cascade,
  edge_type public.graph_edge_type not null,
  source_node_id uuid not null references public.graph_nodes(id),
  target_node_id uuid not null references public.graph_nodes(id),
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  check (source_node_id <> target_node_id)
);

create table if not exists public.semantic_diffs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  from_version_id uuid references public.graph_versions(id),
  to_version_id uuid references public.graph_versions(id),
  diff_payload jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  base_graph_version_id uuid not null references public.graph_versions(id),
  state public.branch_state not null default 'active',
  merged_into_version_id uuid references public.graph_versions(id),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (project_id, name)
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid references public.branches(id),
  event_type public.event_type not null,
  sequence_number bigint not null,
  actor_id uuid references auth.users(id),
  originating_subsystem text not null,
  affected_scope jsonb not null default '{}',
  source_state text,
  target_state text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  unique (project_id, sequence_number)
);

create table if not exists public.mutation_deltas (
  id uuid primary key default gen_random_uuid(),
  branch_id uuid not null references public.branches(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  sequence_number integer not null,
  operation public.delta_operation not null,
  target_node_id uuid references public.graph_nodes(id),
  target_edge_id uuid references public.graph_edges(id),
  payload jsonb not null default '{}',
  triggering_event_id uuid references public.events(id),
  created_at timestamptz not null default now(),
  unique (branch_id, sequence_number)
);

create table if not exists public.merge_attempts (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  source_branch_id uuid not null references public.branches(id),
  target_branch_id uuid references public.branches(id),
  status text not null default 'pending',
  conflict_payload jsonb,
  resolution_payload jsonb,
  requested_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.validation_run_groups (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid references public.branches(id),
  target_type public.validation_target_type not null,
  target_id uuid not null,
  status public.validation_group_status not null default 'running',
  triggered_by_event_id uuid references public.events(id),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.validation_runs (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.validation_run_groups(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  pass_number integer not null check (pass_number in (1, 2, 3)),
  status public.validation_run_status not null default 'running',
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (group_id, pass_number)
);

create table if not exists public.validation_violations (
  id uuid primary key default gen_random_uuid(),
  validation_run_id uuid not null references public.validation_runs(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  invariant_id text not null,
  affected_node_id uuid references public.graph_nodes(id),
  affected_scope jsonb not null default '{}',
  severity public.violation_severity not null,
  message text not null,
  remediation_path text,
  created_at timestamptz not null default now()
);

create table if not exists public.approvals (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid references public.branches(id),
  approval_type public.approval_type not null,
  status public.approval_status not null default 'pending',
  requested_by uuid not null references auth.users(id),
  reviewed_by uuid references auth.users(id),
  affected_scope jsonb not null default '{}',
  mutation_summary jsonb not null default '{}',
  triggering_event_id uuid references public.events(id),
  expires_at timestamptz not null,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.execution_runs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid not null references public.branches(id),
  graph_version_id uuid not null references public.graph_versions(id),
  approval_id uuid references public.approvals(id),
  status public.execution_run_status not null default 'queued',
  triggered_by uuid references auth.users(id),
  started_at timestamptz,
  completed_at timestamptz,
  failure_reason text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.execution_tasks (
  id uuid primary key default gen_random_uuid(),
  execution_run_id uuid not null references public.execution_runs(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  execution_boundary_node_id uuid references public.graph_nodes(id),
  sequence_number integer not null,
  status public.task_status not null default 'pending',
  dependency_task_ids uuid[] not null default '{}',
  output_payload jsonb not null default '{}',
  started_at timestamptz,
  completed_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default now(),
  unique (execution_run_id, sequence_number)
);

create table if not exists public.reconciliation_attempts (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid references public.branches(id),
  execution_run_id uuid references public.execution_runs(id),
  merge_attempt_id uuid references public.merge_attempts(id),
  status public.reconciliation_status not null default 'pending',
  snapshot_version_id uuid references public.graph_versions(id),
  output_version_id uuid references public.graph_versions(id),
  semantic_diff_id uuid references public.semantic_diffs(id),
  failure_reason text,
  started_at timestamptz,
  committed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    (execution_run_id is not null and merge_attempt_id is null) or
    (merge_attempt_id is not null and execution_run_id is null) or
    (execution_run_id is null and merge_attempt_id is null)
  )
);

create table if not exists public.deployments (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid not null references public.branches(id),
  graph_version_id uuid not null references public.graph_versions(id),
  execution_run_id uuid references public.execution_runs(id),
  provider text not null default 'vercel',
  provider_deployment_id text,
  provider_url text,
  environment text not null default 'production',
  status public.deployment_status not null default 'not_deployed',
  previous_deployment_id uuid references public.deployments(id),
  triggered_by uuid references auth.users(id),
  deployed_at timestamptz,
  health_verified_at timestamptz,
  failure_reason text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.repository_ingestion_runs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  repository_reference_id uuid not null references public.repository_references(id),
  status public.ingestion_status not null default 'connected',
  output_graph_version_id uuid references public.graph_versions(id),
  triggered_by uuid references auth.users(id),
  failure_reason text,
  analysis_metadata jsonb not null default '{}',
  started_at timestamptz,
  activated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ingestion_confidence_items (
  id uuid primary key default gen_random_uuid(),
  ingestion_run_id uuid not null references public.repository_ingestion_runs(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  node_type public.graph_node_type not null,
  confidence_level public.confidence_level not null,
  confidence_score numeric(4, 3) not null check (confidence_score >= 0 and confidence_score <= 1),
  proposed_payload jsonb not null default '{}',
  status public.confidence_item_status not null default 'pending',
  resolved_by uuid references auth.users(id),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid references public.projects(id) on delete cascade,
  recipient_user_id uuid not null references auth.users(id) on delete cascade,
  event_id uuid references public.events(id),
  severity public.notification_severity not null default 'info',
  title text not null,
  body text not null,
  action_url text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.escalations (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  branch_id uuid references public.branches(id),
  trigger_type public.escalation_trigger not null,
  trigger_event_id uuid references public.events(id),
  status public.escalation_status not null default 'open',
  affected_scope jsonb not null default '{}',
  resolution_notes text,
  resolved_by uuid references auth.users(id),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.specification_documents
  drop constraint if exists fk_active_revision;
alter table public.specification_documents
  add constraint fk_active_revision
  foreign key (active_revision_id) references public.specification_revisions(id);

alter table public.projects
  drop constraint if exists fk_active_graph_version;
alter table public.projects
  add constraint fk_active_graph_version
  foreign key (active_graph_version_id) references public.graph_versions(id);

alter table public.projects
  drop constraint if exists fk_active_branch;
alter table public.projects
  add constraint fk_active_branch
  foreign key (active_branch_id) references public.branches(id);

alter table public.graph_versions
  drop constraint if exists fk_semantic_diff;
alter table public.graph_versions
  add constraint fk_semantic_diff
  foreign key (semantic_diff_id) references public.semantic_diffs(id);

alter table public.graph_versions
  drop constraint if exists fk_reconciliation;
alter table public.graph_versions
  add constraint fk_reconciliation
  foreign key (reconciliation_id) references public.reconciliation_attempts(id);

create index if not exists idx_events_project_sequence on public.events(project_id, sequence_number);
create index if not exists idx_events_project_type on public.events(project_id, event_type);
create index if not exists idx_events_branch on public.events(branch_id) where branch_id is not null;
create index if not exists idx_approvals_project_status on public.approvals(project_id, status);
create index if not exists idx_execution_runs_branch on public.execution_runs(branch_id, status);
create index if not exists idx_deployments_project on public.deployments(project_id, status);
create index if not exists idx_confidence_items_status on public.ingestion_confidence_items(ingestion_run_id, status);
create index if not exists idx_notifications_unread on public.notifications(recipient_user_id, read_at) where read_at is null;
create index if not exists idx_branches_project_state on public.branches(project_id, state);
create index if not exists idx_graph_nodes_version on public.graph_nodes(graph_version_id);
create index if not exists idx_graph_edges_version on public.graph_edges(graph_version_id);
create index if not exists idx_graph_edges_source on public.graph_edges(source_node_id);
create index if not exists idx_graph_edges_target on public.graph_edges(target_node_id);
create index if not exists idx_validation_groups_target on public.validation_run_groups(target_type, target_id);

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'workspaces',
    'workspace_integrations',
    'projects',
    'repository_references',
    'specification_documents',
    'branches',
    'merge_attempts',
    'approvals',
    'execution_runs',
    'reconciliation_attempts',
    'deployments',
    'repository_ingestion_runs',
    'ingestion_confidence_items',
    'escalations'
  ]
  loop
    execute format('drop trigger if exists trg_%I_updated_at on public.%I', table_name, table_name);
    execute format('create trigger trg_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', table_name, table_name);
  end loop;
end $$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'events',
    'specification_revisions',
    'graph_versions',
    'graph_nodes',
    'graph_edges',
    'semantic_diffs',
    'mutation_deltas',
    'validation_violations'
  ]
  loop
    execute format('drop trigger if exists trg_%I_immutable on public.%I', table_name, table_name);
    execute format('create trigger trg_%I_immutable before update or delete on public.%I for each row execute function sembl_private.prevent_immutable_update_delete()', table_name, table_name);
  end loop;
end $$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'workspaces',
    'workspace_members',
    'workspace_integrations',
    'projects',
    'repository_references',
    'specification_documents',
    'specification_revisions',
    'graph_versions',
    'graph_nodes',
    'graph_edges',
    'semantic_diffs',
    'branches',
    'events',
    'mutation_deltas',
    'merge_attempts',
    'validation_run_groups',
    'validation_runs',
    'validation_violations',
    'approvals',
    'execution_runs',
    'execution_tasks',
    'reconciliation_attempts',
    'deployments',
    'repository_ingestion_runs',
    'ingestion_confidence_items',
    'notifications',
    'escalations'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
  end loop;
end $$;

create policy "workspace_members_select_self"
on public.workspace_members
for select
to authenticated
using (user_id = auth.uid());

create policy "workspaces_select_members"
on public.workspaces
for select
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id and wm.user_id = auth.uid()
  )
);

create policy "workspaces_insert_authenticated"
on public.workspaces
for insert
to authenticated
with check (true);

create policy "workspaces_update_admins"
on public.workspaces
for update
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id and wm.user_id = auth.uid() and wm.role in ('owner', 'admin')
  )
)
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id and wm.user_id = auth.uid() and wm.role in ('owner', 'admin')
  )
);

create policy "projects_select_members"
on public.projects
for select
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id and wm.user_id = auth.uid()
  )
);

create policy "projects_insert_members"
on public.projects
for insert
to authenticated
with check (
  created_by = auth.uid() and exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id and wm.user_id = auth.uid() and wm.role in ('owner', 'admin', 'member')
  )
);

create policy "projects_update_admins"
on public.projects
for update
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id and wm.user_id = auth.uid() and wm.role in ('owner', 'admin')
  )
)
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id and wm.user_id = auth.uid() and wm.role in ('owner', 'admin')
  )
);

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'repository_references',
    'specification_documents',
    'specification_revisions',
    'graph_versions',
    'graph_nodes',
    'graph_edges',
    'semantic_diffs',
    'branches',
    'events',
    'mutation_deltas',
    'merge_attempts',
    'validation_run_groups',
    'validation_runs',
    'validation_violations',
    'approvals',
    'execution_runs',
    'execution_tasks',
    'reconciliation_attempts',
    'deployments',
    'repository_ingestion_runs',
    'ingestion_confidence_items',
    'escalations'
  ]
  loop
    execute format(
      'create policy %I on public.%I for select to authenticated using (exists (select 1 from public.projects p join public.workspace_members wm on wm.workspace_id = p.workspace_id where p.id = project_id and wm.user_id = auth.uid()))',
      table_name || '_select_project_members',
      table_name
    );
  end loop;
end $$;

create policy "notifications_select_recipient"
on public.notifications
for select
to authenticated
using (recipient_user_id = auth.uid());

grant usage on schema public to anon, authenticated;
grant select on all tables in schema public to authenticated;
grant insert, update on public.workspaces, public.workspace_members, public.workspace_integrations, public.projects, public.repository_references, public.specification_documents, public.branches, public.approvals, public.execution_runs, public.execution_tasks, public.deployments, public.repository_ingestion_runs, public.ingestion_confidence_items, public.notifications, public.escalations to authenticated;
