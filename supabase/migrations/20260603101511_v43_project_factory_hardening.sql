-- Sembl v4.3 project factory hardening.
-- Removes seed-workspace auto-ownership and adds durable project creation events.

alter type public.event_type add value if not exists 'ProjectCreated';
alter type public.event_type add value if not exists 'WorkspaceCreated';

drop trigger if exists trg_attach_user_to_seed_workspace on auth.users;
drop function if exists sembl_private.attach_user_to_seed_workspace();

create index if not exists idx_events_project_sequence
  on public.events(project_id, sequence_number desc);

create index if not exists idx_approvals_project_status_created
  on public.approvals(project_id, status, created_at desc);

create index if not exists idx_execution_runs_project_created
  on public.execution_runs(project_id, created_at desc);

create index if not exists idx_execution_tasks_run_status_sequence
  on public.execution_tasks(execution_run_id, status, sequence_number);

create index if not exists idx_reconciliation_project_created
  on public.reconciliation_attempts(project_id, created_at desc);

create index if not exists idx_deployments_project_created
  on public.deployments(project_id, created_at desc);

create index if not exists idx_validation_groups_project_created
  on public.validation_run_groups(project_id, created_at desc);

create index if not exists idx_graph_nodes_version_type_name
  on public.graph_nodes(graph_version_id, node_type, name);

create index if not exists idx_graph_edges_version_source_target
  on public.graph_edges(graph_version_id, source_node_id, target_node_id);
