-- Sembl v4.3 real backend hardening and onboarding.

alter function sembl_private.prevent_immutable_update_delete()
  set search_path = '';

alter function public.set_updated_at()
  set search_path = '';

create or replace function sembl_private.attach_user_to_seed_workspace()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.workspace_members (workspace_id, user_id, role)
  select w.id, new.id, 'owner'::public.workspace_role
  from public.workspaces w
  where w.slug = 'speedvibe'
  on conflict (workspace_id, user_id) do nothing;

  return new;
end;
$$;

revoke all on function sembl_private.attach_user_to_seed_workspace() from public;
revoke all on function sembl_private.attach_user_to_seed_workspace() from anon;
revoke all on function sembl_private.attach_user_to_seed_workspace() from authenticated;

drop trigger if exists trg_attach_user_to_seed_workspace on auth.users;
create trigger trg_attach_user_to_seed_workspace
after insert on auth.users
for each row execute function sembl_private.attach_user_to_seed_workspace();

drop policy if exists "workspace_members_select_self" on public.workspace_members;
create policy "workspace_members_select_self"
on public.workspace_members
for select
to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "workspaces_select_members" on public.workspaces;
create policy "workspaces_select_members"
on public.workspaces
for select
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id and wm.user_id = (select auth.uid())
  )
);

drop policy if exists "workspaces_insert_authenticated" on public.workspaces;
create policy "workspaces_insert_authenticated"
on public.workspaces
for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and length(name) > 0
  and slug = lower(slug)
  and slug ~ '^[a-z0-9-]+$'
);

drop policy if exists "workspaces_update_admins" on public.workspaces;
create policy "workspaces_update_admins"
on public.workspaces
for update
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
)
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
);

drop policy if exists "workspace_integrations_select_members" on public.workspace_integrations;
create policy "workspace_integrations_select_members"
on public.workspace_integrations
for select
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
  )
);

drop policy if exists "workspace_integrations_insert_admins" on public.workspace_integrations;
create policy "workspace_integrations_insert_admins"
on public.workspace_integrations
for insert
to authenticated
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
);

drop policy if exists "workspace_integrations_update_admins" on public.workspace_integrations;
create policy "workspace_integrations_update_admins"
on public.workspace_integrations
for update
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
)
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
);

drop policy if exists "projects_select_members" on public.projects;
create policy "projects_select_members"
on public.projects
for select
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id and wm.user_id = (select auth.uid())
  )
);

drop policy if exists "projects_insert_members" on public.projects;
create policy "projects_insert_members"
on public.projects
for insert
to authenticated
with check (
  created_by = (select auth.uid()) and exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin', 'member')
  )
);

drop policy if exists "projects_update_admins" on public.projects;
create policy "projects_update_admins"
on public.projects
for update
to authenticated
using (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
  )
)
with check (
  exists (
    select 1 from public.workspace_members wm
    where wm.workspace_id = workspace_id
      and wm.user_id = (select auth.uid())
      and wm.role in ('owner', 'admin')
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
    execute format('drop policy if exists %I on public.%I', table_name || '_select_project_members', table_name);
    execute format(
      'create policy %I on public.%I for select to authenticated using (exists (select 1 from public.projects p join public.workspace_members wm on wm.workspace_id = p.workspace_id where p.id = project_id and wm.user_id = (select auth.uid())))',
      table_name || '_select_project_members',
      table_name
    );
  end loop;
end $$;

drop policy if exists "notifications_select_recipient" on public.notifications;
create policy "notifications_select_recipient"
on public.notifications
for select
to authenticated
using (recipient_user_id = (select auth.uid()));

create index if not exists idx_workspace_members_user on public.workspace_members(user_id);
create index if not exists idx_workspace_integrations_workspace on public.workspace_integrations(workspace_id);
create index if not exists idx_projects_workspace on public.projects(workspace_id);
create index if not exists idx_projects_created_by on public.projects(created_by);
create index if not exists idx_repository_references_project on public.repository_references(project_id);
create index if not exists idx_specification_documents_project on public.specification_documents(project_id);
create index if not exists idx_specification_revisions_document on public.specification_revisions(document_id);
create index if not exists idx_specification_revisions_project on public.specification_revisions(project_id);
create index if not exists idx_specification_revisions_authored_by on public.specification_revisions(authored_by);
create index if not exists idx_graph_versions_project on public.graph_versions(project_id);
create index if not exists idx_graph_versions_parent on public.graph_versions(parent_version_id);
create index if not exists idx_graph_versions_source_revision on public.graph_versions(source_spec_revision_id);
create index if not exists idx_graph_versions_reconciliation on public.graph_versions(reconciliation_id);
create index if not exists idx_graph_versions_semantic_diff on public.graph_versions(semantic_diff_id);
create index if not exists idx_graph_nodes_project on public.graph_nodes(project_id);
create index if not exists idx_graph_nodes_source_revision on public.graph_nodes(source_revision_id);
create index if not exists idx_graph_edges_project on public.graph_edges(project_id);
create index if not exists idx_semantic_diffs_project on public.semantic_diffs(project_id);
create index if not exists idx_semantic_diffs_from_version on public.semantic_diffs(from_version_id);
create index if not exists idx_semantic_diffs_to_version on public.semantic_diffs(to_version_id);
create index if not exists idx_branches_project on public.branches(project_id);
create index if not exists idx_branches_base_graph_version on public.branches(base_graph_version_id);
create index if not exists idx_branches_merged_into_version on public.branches(merged_into_version_id);
create index if not exists idx_branches_created_by on public.branches(created_by);
create index if not exists idx_events_project on public.events(project_id);
create index if not exists idx_events_actor on public.events(actor_id);
create index if not exists idx_mutation_deltas_project on public.mutation_deltas(project_id);
create index if not exists idx_mutation_deltas_branch on public.mutation_deltas(branch_id);
create index if not exists idx_mutation_deltas_target_node on public.mutation_deltas(target_node_id);
create index if not exists idx_mutation_deltas_target_edge on public.mutation_deltas(target_edge_id);
create index if not exists idx_mutation_deltas_event on public.mutation_deltas(triggering_event_id);
create index if not exists idx_merge_attempts_project on public.merge_attempts(project_id);
create index if not exists idx_merge_attempts_source_branch on public.merge_attempts(source_branch_id);
create index if not exists idx_merge_attempts_target_branch on public.merge_attempts(target_branch_id);
create index if not exists idx_merge_attempts_requested_by on public.merge_attempts(requested_by);
create index if not exists idx_validation_run_groups_project on public.validation_run_groups(project_id);
create index if not exists idx_validation_run_groups_branch on public.validation_run_groups(branch_id);
create index if not exists idx_validation_run_groups_event on public.validation_run_groups(triggered_by_event_id);
create index if not exists idx_validation_runs_group on public.validation_runs(group_id);
create index if not exists idx_validation_runs_project on public.validation_runs(project_id);
create index if not exists idx_validation_violations_run on public.validation_violations(validation_run_id);
create index if not exists idx_validation_violations_project on public.validation_violations(project_id);
create index if not exists idx_validation_violations_node on public.validation_violations(affected_node_id);
create index if not exists idx_approvals_project on public.approvals(project_id);
create index if not exists idx_approvals_branch on public.approvals(branch_id);
create index if not exists idx_approvals_requested_by on public.approvals(requested_by);
create index if not exists idx_approvals_reviewed_by on public.approvals(reviewed_by);
create index if not exists idx_approvals_triggering_event on public.approvals(triggering_event_id);
create index if not exists idx_execution_runs_project on public.execution_runs(project_id);
create index if not exists idx_execution_runs_approval on public.execution_runs(approval_id);
create index if not exists idx_execution_runs_graph_version on public.execution_runs(graph_version_id);
create index if not exists idx_execution_runs_triggered_by on public.execution_runs(triggered_by);
create index if not exists idx_execution_tasks_run on public.execution_tasks(execution_run_id);
create index if not exists idx_execution_tasks_project on public.execution_tasks(project_id);
create index if not exists idx_execution_tasks_boundary on public.execution_tasks(execution_boundary_node_id);
create index if not exists idx_reconciliation_attempts_project on public.reconciliation_attempts(project_id);
create index if not exists idx_reconciliation_attempts_branch on public.reconciliation_attempts(branch_id);
create index if not exists idx_reconciliation_attempts_execution_run on public.reconciliation_attempts(execution_run_id);
create index if not exists idx_reconciliation_attempts_merge on public.reconciliation_attempts(merge_attempt_id);
create index if not exists idx_reconciliation_attempts_snapshot on public.reconciliation_attempts(snapshot_version_id);
create index if not exists idx_reconciliation_attempts_output on public.reconciliation_attempts(output_version_id);
create index if not exists idx_reconciliation_attempts_diff on public.reconciliation_attempts(semantic_diff_id);
create index if not exists idx_deployments_project_fk on public.deployments(project_id);
create index if not exists idx_deployments_branch on public.deployments(branch_id);
create index if not exists idx_deployments_graph_version on public.deployments(graph_version_id);
create index if not exists idx_deployments_execution_run on public.deployments(execution_run_id);
create index if not exists idx_deployments_previous on public.deployments(previous_deployment_id);
create index if not exists idx_deployments_triggered_by on public.deployments(triggered_by);
create index if not exists idx_repository_ingestion_runs_project on public.repository_ingestion_runs(project_id);
create index if not exists idx_repository_ingestion_runs_reference on public.repository_ingestion_runs(repository_reference_id);
create index if not exists idx_repository_ingestion_runs_output_graph on public.repository_ingestion_runs(output_graph_version_id);
create index if not exists idx_repository_ingestion_runs_triggered_by on public.repository_ingestion_runs(triggered_by);
create index if not exists idx_ingestion_confidence_items_run on public.ingestion_confidence_items(ingestion_run_id);
create index if not exists idx_ingestion_confidence_items_project on public.ingestion_confidence_items(project_id);
create index if not exists idx_ingestion_confidence_items_resolved_by on public.ingestion_confidence_items(resolved_by);
create index if not exists idx_notifications_workspace on public.notifications(workspace_id);
create index if not exists idx_notifications_project on public.notifications(project_id);
create index if not exists idx_notifications_recipient on public.notifications(recipient_user_id);
create index if not exists idx_notifications_event on public.notifications(event_id);
create index if not exists idx_escalations_project on public.escalations(project_id);
create index if not exists idx_escalations_branch on public.escalations(branch_id);
create index if not exists idx_escalations_event on public.escalations(trigger_event_id);
create index if not exists idx_escalations_resolved_by on public.escalations(resolved_by);
