create index if not exists idx_projects_active_branch
on public.projects(active_branch_id);

create index if not exists idx_projects_active_graph_version
on public.projects(active_graph_version_id);

create index if not exists idx_specification_documents_active_revision
on public.specification_documents(active_revision_id);

create index if not exists idx_specification_revisions_parent_revision
on public.specification_revisions(parent_revision_id);
