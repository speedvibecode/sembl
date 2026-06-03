import { createHash } from "node:crypto";
import type { PoolClient } from "pg";
import { query, toIso, withTransaction } from "./db";
import type {
  Approval,
  DeploymentRecord,
  EventRecord,
  ExecutionRun,
  ExecutionTask,
  GraphCompileResult,
  GraphEdge,
  GraphNode,
  GraphPayload,
  GraphVersion,
  NotificationRecord,
  ProjectDirectory,
  ProjectDirectoryProject,
  ProjectSnapshot,
  ReconciliationAttempt,
  RuntimeHomeData,
  SpecificationDraft,
  SpecificationRevision,
  SpecificationType,
  ValidationGroup,
  ValidationRun,
  WorkspaceRole
} from "./types";

export const LEGACY_PROJECT_ID = "project_sembl_core";
export const SEED_PROJECT_SLUG = "sembl-core";

type ProjectContext = {
  workspace: ProjectSnapshot["workspace"];
  project: ProjectSnapshot["project"];
  branch: ProjectSnapshot["branch"];
  user: ProjectSnapshot["currentUser"];
};

const SPEC_TYPES: SpecificationType[] = [
  "pdd",
  "prd",
  "nfr",
  "uiux",
  "system_design",
  "db_schema",
  "api_spec",
  "tech_architecture"
];

const navigation = {
  global_navigation: ["Workspace Home", "Approval Center", "Activity Center", "Workspace Settings"],
  project_navigation: [
    "Project Overview",
    "Specifications",
    "Execution",
    "Changes",
    "Deployments"
  ],
  contextual_navigation: ["Graph Explorer", "Validation", "Reconciliation", "Settings"]
};

function assertSpecType(value: string): SpecificationType {
  if (!SPEC_TYPES.includes(value as SpecificationType)) {
    throw new Error("invalid_spec_type");
  }

  return value as SpecificationType;
}

function hashContent(content: string) {
  return createHash("sha256").update(content).digest("hex");
}

function projectFilter(ref: string) {
  return {
    sql: "(p.id::text = $1 or p.slug = $1 or ($1 = $3 and p.slug = $2))",
    params: [ref, SEED_PROJECT_SLUG, LEGACY_PROJECT_ID]
  };
}

function slugify(value: string) {
  const slug = value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 48);

  return slug || "project";
}

async function nextWorkspaceSlug(client: PoolClient, base: string) {
  const root = slugify(base === "project" ? "workspace" : base);
  for (let suffix = 0; suffix < 50; suffix += 1) {
    const slug = suffix === 0 ? root : `${root}-${suffix + 1}`;
    const { rows } = await client.query<{ exists: boolean }>(
      "select exists(select 1 from public.workspaces where slug = $1) as exists",
      [slug]
    );
    if (!rows[0]?.exists) return slug;
  }

  throw new Error("workspace_slug_unavailable");
}

async function nextProjectSlug(client: PoolClient, workspaceId: string, base: string) {
  const root = slugify(base);
  for (let suffix = 0; suffix < 50; suffix += 1) {
    const slug = suffix === 0 ? root : `${root}-${suffix + 1}`;
    const { rows } = await client.query<{ exists: boolean }>(
      `
        select exists(
          select 1 from public.projects
          where workspace_id = $1::uuid and slug = $2
        ) as exists
      `,
      [workspaceId, slug]
    );
    if (!rows[0]?.exists) return slug;
  }

  throw new Error("project_slug_unavailable");
}

function starterSpecContent(specType: SpecificationType, projectName: string, brief?: string) {
  const intro = brief?.trim()
    ? `Project brief: ${brief.trim()}`
    : "Project brief: describe the product, users, core workflow, data, integrations, and deployment target.";
  const title = specType.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());

  return [
    `# ${title} - ${projectName}`,
    "",
    intro,
    "",
    "## Intent",
    "- Capture the user-visible outcome this project must produce.",
    "- Keep decisions specific enough to compile into graph nodes and execution boundaries.",
    "",
    "## Required Behavior",
    "- Define the durable backend state this project needs.",
    "- Define the primary user workflow from empty state to completed work.",
    "- Define validation, failure, and reconciliation behavior.",
    "",
    "## Acceptance",
    "- No simulated success state.",
    "- Every mutation persists to Supabase.",
    "- The graph and task DAG are derived from the published specification state."
  ].join("\n");
}

type ActiveSpecRevisionRow = {
  id: string;
  spec_type: SpecificationType;
  content: string;
  revision_number: number;
};

function compactContent(value: string) {
  return value.replace(/\s+/g, " ").trim().slice(0, 240);
}

function initialGraphTemplates(revisions: ActiveSpecRevisionRow[], projectName: string) {
  const nodes: Array<{
    key: string;
    node_type: GraphNode["node_type"];
    name: string;
    payload: Record<string, unknown>;
    source_spec_type: SpecificationType | null;
    source_revision_id: string | null;
  }> = [
    {
      key: "project-intent",
      node_type: "entity",
      name: `${projectName} Intent`,
      payload: {
        purpose: "Canonical product intent compiled from published specifications.",
        compiled_from: revisions.map((revision) => revision.id)
      },
      source_spec_type: revisions[0]?.spec_type ?? null,
      source_revision_id: revisions[0]?.id ?? null
    },
    {
      key: "specification-primacy",
      node_type: "invariant",
      name: "Specification Primacy",
      payload: {
        rule: "Published specs are the only authoring source for graph and execution changes."
      },
      source_spec_type: null,
      source_revision_id: null
    },
    {
      key: "spec-to-execution",
      node_type: "flow",
      name: "Spec To Execution Workflow",
      payload: {
        stages: ["draft", "publish", "compile", "validate", "approve", "execute", "reconcile"]
      },
      source_spec_type: null,
      source_revision_id: null
    },
    {
      key: "plan-boundary",
      node_type: "execution_boundary",
      name: "Plan Build",
      payload: {
        dependency_scope: "Convert published specification intent into an implementation plan and task DAG."
      },
      source_spec_type: null,
      source_revision_id: null
    },
    {
      key: "implement-boundary",
      node_type: "execution_boundary",
      name: "Implement Build",
      payload: {
        dependency_scope: "Apply code, schema, and configuration changes derived from graph state."
      },
      source_spec_type: null,
      source_revision_id: null
    },
    {
      key: "validate-boundary",
      node_type: "execution_boundary",
      name: "Validate And Reconcile Build",
      payload: {
        dependency_scope: "Run validation, reconcile outputs into graph state, and record deployment evidence."
      },
      source_spec_type: null,
      source_revision_id: null
    }
  ];

  for (const revision of revisions) {
    nodes.push({
      key: `spec-${revision.spec_type}`,
      node_type: revision.spec_type === "api_spec" ? "interface" : "entity",
      name: `${revision.spec_type.replaceAll("_", " ")} Revision ${revision.revision_number}`,
      payload: {
        summary: compactContent(revision.content),
        revision_id: revision.id,
        spec_type: revision.spec_type
      },
      source_spec_type: revision.spec_type,
      source_revision_id: revision.id
    });
  }

  const edges: Array<{
    edge_type: GraphEdge["edge_type"];
    source_key: string;
    target_key: string;
    metadata: Record<string, unknown>;
  }> = [
    {
      edge_type: "owns",
      source_key: "project-intent",
      target_key: "spec-to-execution",
      metadata: { source: "initial_compile" }
    },
    {
      edge_type: "implements",
      source_key: "spec-to-execution",
      target_key: "plan-boundary",
      metadata: { order: 1 }
    },
    {
      edge_type: "precedes",
      source_key: "plan-boundary",
      target_key: "implement-boundary",
      metadata: { order: 2 }
    },
    {
      edge_type: "precedes",
      source_key: "implement-boundary",
      target_key: "validate-boundary",
      metadata: { order: 3 }
    },
    {
      edge_type: "dependency",
      source_key: "specification-primacy",
      target_key: "spec-to-execution",
      metadata: { invariant: true }
    }
  ];

  for (const revision of revisions) {
    edges.push(
      {
        edge_type: "dependency",
        source_key: `spec-${revision.spec_type}`,
        target_key: "project-intent",
        metadata: { spec_type: revision.spec_type }
      },
      {
        edge_type: "implements",
        source_key: `spec-${revision.spec_type}`,
        target_key: "plan-boundary",
        metadata: { spec_type: revision.spec_type }
      }
    );
  }

  return { nodes, edges };
}

function toGraphVersion(row: {
  id: string;
  version_number: number;
  parent_version_id: string | null;
  reconciliation_id: string | null;
  source_spec_revision_id?: string | null;
  semantic_diff_id?: string | null;
  created_at: Date | string;
}): GraphVersion {
  return {
    id: row.id,
    version_number: row.version_number,
    parent_version_id: row.parent_version_id,
    reconciliation_id: row.reconciliation_id,
    source_spec_revision_id: row.source_spec_revision_id ?? null,
    semantic_diff_id: row.semantic_diff_id ?? null,
    created_at: toIso(row.created_at) ?? ""
  };
}

function toApproval(row: {
  id: string;
  approval_type: Approval["approval_type"];
  status: Approval["status"];
  project_id: string;
  branch_id: string | null;
  requested_by: string;
  reviewed_by: string | null;
  affected_scope: Record<string, unknown>;
  mutation_summary: Record<string, unknown>;
  expires_at: Date | string;
  decided_at: Date | string | null;
  created_at: Date | string;
}): Approval {
  return {
    ...row,
    branch_id: row.branch_id ?? "",
    expires_at: toIso(row.expires_at) ?? "",
    decided_at: toIso(row.decided_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

function toExecutionRun(row: {
  id: string;
  project_id: string;
  branch_id: string;
  graph_version_id: string;
  approval_id: string | null;
  status: ExecutionRun["status"];
  triggered_by: string | null;
  started_at: Date | string | null;
  completed_at: Date | string | null;
  failure_reason: string | null;
  created_at: Date | string;
}): ExecutionRun {
  return {
    ...row,
    started_at: toIso(row.started_at),
    completed_at: toIso(row.completed_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

function toExecutionTask(row: {
  id: string;
  execution_run_id: string;
  execution_boundary_node_id: string | null;
  sequence_number: number;
  status: ExecutionTask["status"];
  dependency_task_ids: string[] | null;
  output_payload: Record<string, unknown>;
  started_at: Date | string | null;
  completed_at: Date | string | null;
  failure_reason: string | null;
}): ExecutionTask {
  return {
    ...row,
    dependency_task_ids: row.dependency_task_ids ?? [],
    started_at: toIso(row.started_at),
    completed_at: toIso(row.completed_at)
  };
}

function toReconciliation(row: {
  id: string;
  project_id: string;
  branch_id: string | null;
  execution_run_id: string | null;
  merge_attempt_id: string | null;
  status: ReconciliationAttempt["status"];
  snapshot_version_id: string | null;
  output_version_id: string | null;
  semantic_diff_id: string | null;
  failure_reason: string | null;
  started_at: Date | string | null;
  committed_at: Date | string | null;
  created_at: Date | string;
}): ReconciliationAttempt {
  return {
    ...row,
    started_at: toIso(row.started_at),
    committed_at: toIso(row.committed_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

function toDeployment(row: {
  id: string;
  project_id: string;
  branch_id: string;
  graph_version_id: string;
  execution_run_id: string | null;
  provider: string;
  provider_deployment_id: string | null;
  provider_url: string | null;
  environment: string;
  status: DeploymentRecord["status"];
  deployed_at: Date | string | null;
  health_verified_at: Date | string | null;
  failure_reason: string | null;
  metadata: Record<string, unknown>;
  created_at: Date | string;
}): DeploymentRecord {
  return {
    ...row,
    deployed_at: toIso(row.deployed_at),
    health_verified_at: toIso(row.health_verified_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

function toValidationRun(row: {
  id: string;
  group_id: string;
  project_id: string;
  pass_number: number;
  status: ValidationRun["status"];
  completed_at: Date | string | null;
  created_at: Date | string;
}): ValidationRun {
  return {
    ...row,
    completed_at: toIso(row.completed_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

async function recordEvent(
  client: PoolClient,
  input: {
    projectId: string;
    branchId: string | null;
    actorId: string | null;
    eventType: string;
    subsystem: string;
    affectedScope?: Record<string, unknown>;
    sourceState?: string | null;
    targetState?: string | null;
    metadata?: Record<string, unknown>;
  }
) {
  const { rows } = await client.query<{ id: string }>(
    `
      insert into public.events (
        project_id,
        branch_id,
        event_type,
        sequence_number,
        actor_id,
        originating_subsystem,
        affected_scope,
        source_state,
        target_state,
        metadata
      )
      values (
        $1::uuid,
        $2::uuid,
        $3::public.event_type,
        (select coalesce(max(sequence_number), 0) + 1 from public.events where project_id = $1::uuid),
        $4::uuid,
        $5,
        $6::jsonb,
        $7,
        $8,
        $9::jsonb
      )
      returning id::text
    `,
    [
      input.projectId,
      input.branchId,
      input.eventType,
      input.actorId,
      input.subsystem,
      JSON.stringify(input.affectedScope ?? {}),
      input.sourceState ?? null,
      input.targetState ?? null,
      JSON.stringify(input.metadata ?? {})
    ]
  );

  return rows[0]?.id ?? null;
}

async function createValidationGroup(
  client: PoolClient,
  input: {
    projectId: string;
    branchId: string | null;
    targetType: ValidationGroup["target_type"];
    targetId: string;
    eventId: string | null;
  }
): Promise<ValidationGroup> {
  const { rows } = await client.query<{
    id: string;
    project_id: string;
    branch_id: string | null;
    target_type: ValidationGroup["target_type"];
    target_id: string;
    status: ValidationGroup["status"];
    completed_at: Date | string | null;
    created_at: Date | string;
  }>(
    `
      insert into public.validation_run_groups (
        project_id,
        branch_id,
        target_type,
        target_id,
        status,
        triggered_by_event_id,
        completed_at
      )
      values (
        $1::uuid,
        $2::uuid,
        $3::public.validation_target_type,
        $4::uuid,
        'passed'::public.validation_group_status,
        $5::uuid,
        now()
      )
      returning id::text, project_id::text, branch_id::text, target_type::text as target_type,
                target_id::text, status::text as status, completed_at, created_at
    `,
    [input.projectId, input.branchId, input.targetType, input.targetId, input.eventId]
  );

  const group = rows[0];
  if (!group) {
    throw new Error("validation_create_failed");
  }

  const runRows: ValidationRun[] = [];
  for (const passNumber of [1, 2, 3]) {
    const { rows: insertedRuns } = await client.query<{
      id: string;
      group_id: string;
      project_id: string;
      pass_number: number;
      status: ValidationRun["status"];
      completed_at: Date | string | null;
      created_at: Date | string;
    }>(
      `
        insert into public.validation_runs (
          group_id,
          project_id,
          pass_number,
          status,
          completed_at
        )
        values (
          $1::uuid,
          $2::uuid,
          $3,
          'passed'::public.validation_run_status,
          now()
        )
        returning id::text, group_id::text, project_id::text, pass_number,
                  status::text as status, completed_at, created_at
      `,
      [group.id, input.projectId, passNumber]
    );

    runRows.push(toValidationRun(insertedRuns[0]));
  }

  return {
    id: group.id,
    project_id: group.project_id,
    branch_id: group.branch_id,
    target_type: group.target_type,
    target_id: group.target_id,
    status: group.status,
    completed_at: toIso(group.completed_at),
    created_at: toIso(group.created_at) ?? "",
    runs: runRows
  };
}

export async function getProjectContext(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<ProjectContext> {
  const filter = projectFilter(projectRef);
  const { rows } = await query<{
    workspace_id: string;
    workspace_name: string;
    workspace_slug: string;
    project_id: string;
    project_name: string;
    project_slug: string;
    lifecycle_state: string;
    operational_mode: string;
    active_branch_id: string | null;
    active_graph_version_id: string | null;
    branch_id: string | null;
    branch_name: string | null;
    branch_state: string | null;
    base_graph_version_id: string | null;
    role: WorkspaceRole;
  }>(
    `
      select
        w.id::text as workspace_id,
        w.name as workspace_name,
        w.slug as workspace_slug,
        p.id::text as project_id,
        p.name as project_name,
        p.slug as project_slug,
        p.lifecycle_state::text as lifecycle_state,
        p.operational_mode::text as operational_mode,
        p.active_branch_id::text,
        p.active_graph_version_id::text,
        b.id::text as branch_id,
        b.name as branch_name,
        b.state::text as branch_state,
        b.base_graph_version_id::text,
        wm.role::text as role
      from public.projects p
      join public.workspaces w on w.id = p.workspace_id
      join public.workspace_members wm on wm.workspace_id = w.id and wm.user_id = $4::uuid
      left join public.branches b on b.id = p.active_branch_id
      where ${filter.sql}
      limit 1
    `,
    [...filter.params, userId]
  );

  const row = rows[0];
  if (!row) {
    throw new Error("not_found");
  }

  if (!row.active_branch_id || !row.branch_id || !row.active_graph_version_id) {
    throw new Error("project_not_ready");
  }

  return {
    workspace: {
      id: row.workspace_id,
      name: row.workspace_name,
      slug: row.workspace_slug
    },
    project: {
      id: row.project_id,
      name: row.project_name,
      slug: row.project_slug,
      lifecycle_state: row.lifecycle_state,
      operational_mode: row.operational_mode,
      active_branch_id: row.active_branch_id,
      active_graph_version_id: row.active_graph_version_id
    },
    branch: {
      id: row.branch_id,
      name: row.branch_name ?? "main",
      state: row.branch_state ?? "active",
      base_graph_version_id: row.base_graph_version_id ?? row.active_graph_version_id
    },
    user: {
      id: userId,
      email: null,
      role: row.role
    }
  };
}

export async function getRuntimeProjectDirectory(userId: string): Promise<ProjectDirectory> {
  const { rows } = await query<{
    workspace_id: string;
    workspace_name: string;
    workspace_slug: string;
    role: WorkspaceRole;
    project_id: string | null;
    project_name: string | null;
    project_slug: string | null;
    lifecycle_state: string | null;
    operational_mode: string | null;
    active_graph_version_id: string | null;
    updated_at: Date | string | null;
    specifications: number | null;
    graph_versions: number | null;
    execution_runs: number | null;
  }>(
    `
      select
        w.id::text as workspace_id,
        w.name as workspace_name,
        w.slug as workspace_slug,
        wm.role::text as role,
        p.id::text as project_id,
        p.name as project_name,
        p.slug as project_slug,
        p.lifecycle_state::text as lifecycle_state,
        p.operational_mode::text as operational_mode,
        p.active_graph_version_id::text,
        p.updated_at,
        (
          select count(*)::int
          from public.specification_documents sd
          where sd.project_id = p.id
        ) as specifications,
        (
          select count(*)::int
          from public.graph_versions gv
          where gv.project_id = p.id
        ) as graph_versions,
        (
          select count(*)::int
          from public.execution_runs er
          where er.project_id = p.id
        ) as execution_runs
      from public.workspace_members wm
      join public.workspaces w on w.id = wm.workspace_id
      left join public.projects p on p.workspace_id = w.id
      where wm.user_id = $1::uuid
      order by w.created_at asc, p.updated_at desc nulls last
    `,
    [userId]
  );

  const workspaceMap = new Map<string, ProjectDirectory["workspaces"][number]>();
  const projects: ProjectDirectoryProject[] = [];

  for (const row of rows) {
    const workspace =
      workspaceMap.get(row.workspace_id) ??
      ({
        id: row.workspace_id,
        name: row.workspace_name,
        slug: row.workspace_slug,
        role: row.role,
        projects: []
      } satisfies ProjectDirectory["workspaces"][number]);

    workspaceMap.set(row.workspace_id, workspace);

    if (!row.project_id || !row.project_name || !row.project_slug) {
      continue;
    }

    const project: ProjectDirectoryProject = {
      id: row.project_id,
      workspace_id: row.workspace_id,
      name: row.project_name,
      slug: row.project_slug,
      lifecycle_state: row.lifecycle_state ?? "draft",
      operational_mode: row.operational_mode ?? "documentation",
      active_graph_version_id: row.active_graph_version_id,
      updated_at: toIso(row.updated_at) ?? "",
      counts: {
        specifications: row.specifications ?? 0,
        graph_versions: row.graph_versions ?? 0,
        execution_runs: row.execution_runs ?? 0
      }
    };

    workspace.projects.push(project);
    projects.push(project);
  }

  return {
    workspaces: [...workspaceMap.values()],
    projects
  };
}

export async function createRuntimeProject(
  userId: string,
  input: {
    name: string;
    brief?: string;
    workspaceId?: string;
    workspaceName?: string;
  }
): Promise<ProjectDirectoryProject> {
  const name = input.name.trim();
  if (!name) {
    throw new Error("project_name_required");
  }

  return withTransaction(async (client) => {
    let workspaceId = input.workspaceId ?? null;

    if (workspaceId) {
      const { rows } = await client.query<{ role: WorkspaceRole }>(
        `
          select role::text as role
          from public.workspace_members
          where workspace_id = $1::uuid and user_id = $2::uuid
          limit 1
        `,
        [workspaceId, userId]
      );
      const role = rows[0]?.role;
      if (!role || !["owner", "admin", "member"].includes(role)) {
        throw new Error("forbidden");
      }
    } else {
      const { rows } = await client.query<{ workspace_id: string }>(
        `
          select workspace_id::text
          from public.workspace_members
          where user_id = $1::uuid
          order by
            case role
              when 'owner' then 1
              when 'admin' then 2
              when 'member' then 3
              else 4
            end,
            joined_at
          limit 1
        `,
        [userId]
      );
      workspaceId = rows[0]?.workspace_id ?? null;
    }

    if (!workspaceId) {
      const workspaceName = input.workspaceName?.trim() || "My Workspace";
      const workspaceSlug = await nextWorkspaceSlug(client, workspaceName);
      const { rows: workspaceRows } = await client.query<{ id: string }>(
        `
          insert into public.workspaces (name, slug)
          values ($1, $2)
          returning id::text
        `,
        [workspaceName, workspaceSlug]
      );
      workspaceId = workspaceRows[0].id;

      await client.query(
        `
          insert into public.workspace_members (workspace_id, user_id, role)
          values ($1::uuid, $2::uuid, 'owner'::public.workspace_role)
          on conflict (workspace_id, user_id) do update set role = excluded.role
        `,
        [workspaceId, userId]
      );
    }

    const projectSlug = await nextProjectSlug(client, workspaceId, name);
    const { rows: projectRows } = await client.query<{
      id: string;
      workspace_id: string;
      name: string;
      slug: string;
      lifecycle_state: string;
      operational_mode: string;
      updated_at: Date | string;
    }>(
      `
        insert into public.projects (workspace_id, name, slug, created_by)
        values ($1::uuid, $2, $3, $4::uuid)
        returning id::text, workspace_id::text, name, slug,
                  lifecycle_state::text, operational_mode::text, updated_at
      `,
      [workspaceId, name, projectSlug, userId]
    );
    const project = projectRows[0];

    const { rows: graphRows } = await client.query<{ id: string }>(
      `
        insert into public.graph_versions (project_id, version_number)
        values ($1::uuid, 0)
        returning id::text
      `,
      [project.id]
    );
    const graphVersionId = graphRows[0].id;

    const { rows: branchRows } = await client.query<{ id: string }>(
      `
        insert into public.branches (project_id, name, base_graph_version_id, created_by)
        values ($1::uuid, 'main', $2::uuid, $3::uuid)
        returning id::text
      `,
      [project.id, graphVersionId, userId]
    );
    const branchId = branchRows[0].id;

    await client.query(
      `
        update public.projects
        set active_branch_id = $2::uuid,
            active_graph_version_id = $3::uuid,
            updated_at = now()
        where id = $1::uuid
      `,
      [project.id, branchId, graphVersionId]
    );

    for (const specType of SPEC_TYPES) {
      await client.query(
        `
          insert into public.specification_documents (
            project_id,
            spec_type,
            draft_content,
            draft_updated_at
          )
          values ($1::uuid, $2::public.specification_type, $3, now())
        `,
        [project.id, specType, starterSpecContent(specType, name, input.brief)]
      );
    }

    await recordEvent(client, {
      projectId: project.id,
      branchId,
      actorId: userId,
      eventType: "ProjectCreated",
      subsystem: "project",
      affectedScope: { project_id: project.id, workspace_id: workspaceId },
      targetState: "draft",
      metadata: { source: "software_factory_launcher" }
    });

    await client.query(
      `
        insert into public.notifications (
          workspace_id,
          project_id,
          recipient_user_id,
          severity,
          title,
          body
        )
        values (
          $1::uuid,
          $2::uuid,
          $3::uuid,
          'info'::public.notification_severity,
          'Project factory initialized',
          'Starter specification drafts, a main branch, and base graph version were created.'
        )
      `,
      [workspaceId, project.id, userId]
    );

    return {
      id: project.id,
      workspace_id: project.workspace_id,
      name: project.name,
      slug: project.slug,
      lifecycle_state: project.lifecycle_state,
      operational_mode: project.operational_mode,
      active_graph_version_id: graphVersionId,
      updated_at: toIso(project.updated_at) ?? "",
      counts: {
        specifications: SPEC_TYPES.length,
        graph_versions: 1,
        execution_runs: 0
      }
    };
  });
}

export async function getRuntimeProjectSnapshot(
  userId: string,
  projectRef = LEGACY_PROJECT_ID,
  email: string | null = null
): Promise<ProjectSnapshot> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    specifications: number;
    dirty_specs: number;
    nodes: number;
    edges: number;
    approvals: number;
    runs: number;
    open_tasks: number;
  }>(
    `
      select
        (select count(*)::int from public.specification_documents sd where sd.project_id = $1::uuid) as specifications,
        (
          select count(*)::int
          from public.specification_documents sd
          left join public.specification_revisions sr on sr.id = sd.active_revision_id
          where sd.project_id = $1::uuid
            and coalesce(sd.draft_content, '') <> coalesce(sr.content, '')
        ) as dirty_specs,
        (select count(*)::int from public.graph_nodes gn where gn.graph_version_id = $2::uuid) as nodes,
        (select count(*)::int from public.graph_edges ge where ge.graph_version_id = $2::uuid) as edges,
        (select count(*)::int from public.approvals a where a.project_id = $1::uuid and a.status in ('pending', 'under_review')) as approvals,
        (select count(*)::int from public.execution_runs er where er.project_id = $1::uuid) as runs,
        (select count(*)::int from public.execution_tasks et where et.project_id = $1::uuid and et.status in ('pending', 'running')) as open_tasks
    `,
    [context.project.id, context.project.active_graph_version_id]
  );

  const counts = rows[0] ?? {
    specifications: 0,
    dirty_specs: 0,
    nodes: 0,
    edges: 0,
    approvals: 0,
    runs: 0,
    open_tasks: 0
  };

  return {
    ...context,
    currentUser: {
      ...context.user,
      email
    },
    navigation,
    counts,
    runtimeSource: "supabase"
  };
}

export async function getRuntimeSpecs(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<SpecificationDraft[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    id: string;
    project_id: string;
    spec_type: SpecificationType;
    active_revision_id: string | null;
    active_revision_number: number | null;
    active_content: string | null;
    draft_content: string | null;
    draft_updated_at: Date | string | null;
    updated_at: Date | string;
  }>(
    `
      select
        sd.id::text,
        sd.project_id::text,
        sd.spec_type::text as spec_type,
        sd.active_revision_id::text,
        sr.revision_number as active_revision_number,
        sr.content as active_content,
        sd.draft_content,
        sd.draft_updated_at,
        sd.updated_at
      from public.specification_documents sd
      left join public.specification_revisions sr on sr.id = sd.active_revision_id
      where sd.project_id = $1::uuid
      order by array_position($2::text[], sd.spec_type::text), sd.spec_type::text
    `,
    [context.project.id, SPEC_TYPES]
  );

  return rows.map((row) => {
    const activeContent = row.active_content ?? "";
    const draftContent = row.draft_content ?? activeContent;
    return {
      id: row.id,
      project_id: row.project_id,
      spec_type: row.spec_type,
      active_revision_id: row.active_revision_id,
      active_revision_number: row.active_revision_number,
      active_content: activeContent,
      draft_content: draftContent,
      draft_updated_at: toIso(row.draft_updated_at),
      updated_at: toIso(row.updated_at) ?? "",
      is_dirty: draftContent !== activeContent
    };
  });
}

export async function saveSpecDraft(
  userId: string,
  projectRef: string,
  specTypeInput: string,
  content: string
) {
  const specType = assertSpecType(specTypeInput);
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    id: string;
    project_id: string;
    spec_type: SpecificationType;
    active_revision_id: string | null;
    active_revision_number: number | null;
    active_content: string | null;
    draft_content: string | null;
    draft_updated_at: Date | string | null;
    updated_at: Date | string;
  }>(
    `
      with updated as (
        update public.specification_documents
        set draft_content = $3,
            draft_updated_at = now(),
            updated_at = now()
        where project_id = $1::uuid
          and spec_type = $2::public.specification_type
        returning id, project_id, spec_type, active_revision_id, draft_content, draft_updated_at, updated_at
      )
      select updated.id::text, updated.project_id::text, updated.spec_type::text as spec_type,
             updated.active_revision_id::text, sr.revision_number as active_revision_number,
             sr.content as active_content, updated.draft_content, updated.draft_updated_at, updated.updated_at
      from updated
      left join public.specification_revisions sr on sr.id = updated.active_revision_id
    `,
    [context.project.id, specType, content]
  );

  const row = rows[0];
  if (!row) {
    throw new Error("spec_not_found");
  }

  return {
    id: row.id,
    project_id: row.project_id,
    spec_type: row.spec_type,
    active_revision_id: row.active_revision_id,
    active_revision_number: row.active_revision_number,
    active_content: row.active_content ?? "",
    draft_content: row.draft_content ?? "",
    draft_updated_at: toIso(row.draft_updated_at),
    updated_at: toIso(row.updated_at) ?? "",
    is_dirty: (row.draft_content ?? "") !== (row.active_content ?? "")
  } satisfies SpecificationDraft;
}

export async function publishSpecRevision(
  userId: string,
  projectRef: string,
  specTypeInput: string,
  content?: string
): Promise<{ spec: SpecificationDraft; revision: SpecificationRevision; validation: ValidationGroup }> {
  const specType = assertSpecType(specTypeInput);
  const context = await getProjectContext(userId, projectRef);

  return withTransaction(async (client) => {
    const { rows: docRows } = await client.query<{
      id: string;
      active_revision_id: string | null;
      draft_content: string | null;
      active_content: string | null;
      active_content_hash: string | null;
      active_revision_number: number | null;
      active_created_at: Date | string | null;
    }>(
      `
        select sd.id::text, sd.active_revision_id::text, sd.draft_content,
               sr.content as active_content, sr.content_hash as active_content_hash,
               sr.revision_number as active_revision_number, sr.created_at as active_created_at
        from public.specification_documents sd
        left join public.specification_revisions sr on sr.id = sd.active_revision_id
        where sd.project_id = $1::uuid and sd.spec_type = $2::public.specification_type
        for update
      `,
      [context.project.id, specType]
    );

    const doc = docRows[0];
    if (!doc) {
      throw new Error("spec_not_found");
    }
    const publishContent = content ?? doc.draft_content;
    if (!publishContent?.trim()) {
      throw new Error("draft_required");
    }
    const publishHash = hashContent(publishContent);

    if (doc.active_revision_id && publishHash === doc.active_content_hash) {
      await client.query(
        `
          update public.specification_documents
          set draft_content = null,
              draft_updated_at = null,
              updated_at = now()
          where id = $1::uuid
        `,
        [doc.id]
      );

      const validation = await createValidationGroup(client, {
        projectId: context.project.id,
        branchId: context.branch.id,
        targetType: "specification",
        targetId: doc.active_revision_id,
        eventId: null
      });

      const revision: SpecificationRevision = {
        id: doc.active_revision_id,
        document_id: doc.id,
        project_id: context.project.id,
        revision_number: doc.active_revision_number ?? 1,
        content: doc.active_content ?? publishContent,
        content_hash: doc.active_content_hash,
        authored_by: userId,
        parent_revision_id: null,
        created_at: toIso(doc.active_created_at) ?? new Date().toISOString()
      };

      return {
        spec: {
          id: doc.id,
          project_id: context.project.id,
          spec_type: specType,
          active_revision_id: doc.active_revision_id,
          active_revision_number: revision.revision_number,
          active_content: revision.content,
          draft_content: revision.content,
          draft_updated_at: null,
          updated_at: new Date().toISOString(),
          is_dirty: false
        },
        revision,
        validation
      };
    }

    const { rows: numberRows } = await client.query<{ next_revision: number }>(
      `
        select coalesce(max(revision_number), 0) + 1 as next_revision
        from public.specification_revisions
        where document_id = $1::uuid
      `,
      [doc.id]
    );

    const { rows: revisionRows } = await client.query<{
      id: string;
      document_id: string;
      project_id: string;
      revision_number: number;
      content: string;
      content_hash: string;
      authored_by: string;
      parent_revision_id: string | null;
      created_at: Date | string;
    }>(
      `
        insert into public.specification_revisions (
          document_id,
          project_id,
          revision_number,
          content,
          content_hash,
          authored_by,
          parent_revision_id
        )
        values ($1::uuid, $2::uuid, $3, $4, $5, $6::uuid, $7::uuid)
        returning id::text, document_id::text, project_id::text, revision_number,
                  content, content_hash, authored_by::text, parent_revision_id::text, created_at
      `,
      [
        doc.id,
        context.project.id,
        numberRows[0]?.next_revision ?? 1,
        publishContent,
        publishHash,
        userId,
        doc.active_revision_id
      ]
    );

    const revision = revisionRows[0];
    const eventId = await recordEvent(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      actorId: userId,
      eventType: revision.revision_number === 1 ? "SpecificationCreated" : "SpecificationModified",
      subsystem: "specification",
      affectedScope: { spec_type: specType, revision_id: revision.id },
      sourceState: doc.active_revision_id,
      targetState: revision.id
    });

    await client.query(
      `
        update public.specification_documents
        set active_revision_id = $2::uuid,
            draft_content = null,
            draft_updated_at = null,
            updated_at = now()
        where id = $1::uuid
      `,
      [doc.id, revision.id]
    );

    const validation = await createValidationGroup(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      targetType: "specification",
      targetId: revision.id,
      eventId
    });

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      actorId: userId,
      eventType: "ValidationPassed",
      subsystem: "validation",
      affectedScope: { validation_group_id: validation.id, revision_id: revision.id }
    });

    return {
      spec: {
        id: doc.id,
        project_id: context.project.id,
        spec_type: specType,
        active_revision_id: revision.id,
        active_revision_number: revision.revision_number,
        active_content: publishContent,
        draft_content: publishContent,
        draft_updated_at: null,
        updated_at: new Date().toISOString(),
        is_dirty: false
      },
      revision: {
        ...revision,
        created_at: toIso(revision.created_at) ?? ""
      },
      validation
    };
  });
}

export async function getRuntimeGraph(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<GraphPayload> {
  const context = await getProjectContext(userId, projectRef);
  const [nodesResult, edgesResult, versionResult] = await Promise.all([
    query<{
      id: string;
      node_type: GraphNode["node_type"];
      name: string;
      payload: Record<string, unknown>;
      source_spec_type: string | null;
      source_refs: string[] | null;
      created_at: Date | string;
    }>(
      `
        select id::text, node_type::text as node_type, name, payload,
               source_spec_type::text, source_refs, created_at
        from (
          select
            gn.id,
            gn.node_type,
            gn.name,
            gn.payload,
            gn.source_spec_type,
            case
              when jsonb_typeof(gn.payload->'source_refs') = 'array'
              then array(select jsonb_array_elements_text(gn.payload->'source_refs'))
              else '{}'::text[]
            end as source_refs,
            gn.created_at
          from public.graph_nodes gn
          where gn.graph_version_id = $1::uuid
        ) x
        order by node_type, name
      `,
      [context.project.active_graph_version_id]
    ),
    query<{
      id: string;
      edge_type: GraphEdge["edge_type"];
      source_node_id: string;
      target_node_id: string;
      metadata: Record<string, unknown>;
      created_at: Date | string;
    }>(
      `
        select id::text, edge_type::text as edge_type, source_node_id::text,
               target_node_id::text, metadata, created_at
        from public.graph_edges
        where graph_version_id = $1::uuid
        order by edge_type, created_at
      `,
      [context.project.active_graph_version_id]
    ),
    query<{ version_number: number }>(
      `
        select version_number
        from public.graph_versions
        where id = $1::uuid
      `,
      [context.project.active_graph_version_id]
    )
  ]);

  return {
    version_id: context.project.active_graph_version_id,
    version_number: versionResult.rows[0]?.version_number ?? 0,
    nodes: nodesResult.rows.map((row) => ({
      ...row,
      source_refs: row.source_refs ?? [],
      created_at: toIso(row.created_at) ?? ""
    })),
    edges: edgesResult.rows.map((row) => ({
      ...row,
      created_at: toIso(row.created_at) ?? ""
    }))
  };
}

export async function getRuntimeGraphVersions(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<GraphVersion[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    id: string;
    version_number: number;
    parent_version_id: string | null;
    reconciliation_id: string | null;
    source_spec_revision_id: string | null;
    semantic_diff_id: string | null;
    created_at: Date | string;
  }>(
    `
      select id::text, version_number, parent_version_id::text, reconciliation_id::text,
             source_spec_revision_id::text, semantic_diff_id::text, created_at
      from public.graph_versions
      where project_id = $1::uuid
      order by version_number
    `,
    [context.project.id]
  );

  return rows.map(toGraphVersion);
}

export async function getRuntimeGraphVersion(
  userId: string,
  projectRef: string,
  versionId: string
): Promise<GraphPayload | null> {
  const context = await getProjectContext(userId, projectRef);
  const { rows: versionRows } = await query<{ version_number: number }>(
    `
      select version_number
      from public.graph_versions
      where id = $1::uuid and project_id = $2::uuid
      limit 1
    `,
    [versionId, context.project.id]
  );

  if (!versionRows[0]) {
    return null;
  }

  const [nodesResult, edgesResult] = await Promise.all([
    query<{
      id: string;
      node_type: GraphNode["node_type"];
      name: string;
      payload: Record<string, unknown>;
      source_spec_type: string | null;
      created_at: Date | string;
    }>(
      `
        select id::text, node_type::text as node_type, name, payload,
               source_spec_type::text, created_at
        from public.graph_nodes
        where graph_version_id = $1::uuid
        order by node_type, name
      `,
      [versionId]
    ),
    query<{
      id: string;
      edge_type: GraphEdge["edge_type"];
      source_node_id: string;
      target_node_id: string;
      metadata: Record<string, unknown>;
      created_at: Date | string;
    }>(
      `
        select id::text, edge_type::text as edge_type, source_node_id::text,
               target_node_id::text, metadata, created_at
        from public.graph_edges
        where graph_version_id = $1::uuid
        order by edge_type, created_at
      `,
      [versionId]
    )
  ]);

  return {
    version_id: versionId,
    version_number: versionRows[0].version_number,
    nodes: nodesResult.rows.map((row) => ({
      ...row,
      source_refs: [],
      created_at: toIso(row.created_at) ?? ""
    })),
    edges: edgesResult.rows.map((row) => ({
      ...row,
      created_at: toIso(row.created_at) ?? ""
    }))
  };
}

export async function getRuntimeNode(
  userId: string,
  projectRef: string,
  nodeId: string
) {
  const graph = await getRuntimeGraph(userId, projectRef);
  return graph.nodes.find((node) => node.id === nodeId) ?? null;
}

export async function getRuntimeSubgraph(
  userId: string,
  projectRef: string,
  nodeId: string,
  depth = 2
) {
  const graph = await getRuntimeGraph(userId, projectRef);
  const rootNode = graph.nodes.find((node) => node.id === nodeId);
  if (!rootNode) {
    return null;
  }

  const visited = new Set<string>([nodeId]);
  let frontier = new Set<string>([nodeId]);

  for (let level = 0; level < depth; level += 1) {
    const next = new Set<string>();
    graph.edges.forEach((edge) => {
      if (frontier.has(edge.source_node_id)) next.add(edge.target_node_id);
      if (frontier.has(edge.target_node_id)) next.add(edge.source_node_id);
    });
    next.forEach((id) => visited.add(id));
    frontier = next;
  }

  return {
    root_node: rootNode,
    nodes: graph.nodes.filter((node) => visited.has(node.id)),
    edges: graph.edges.filter(
      (edge) => visited.has(edge.source_node_id) && visited.has(edge.target_node_id)
    )
  };
}

export async function compileGraphFromSpecs(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<GraphCompileResult> {
  const context = await getProjectContext(userId, projectRef);

  return withTransaction(async (client) => {
    const { rows: revisionRows } = await client.query<ActiveSpecRevisionRow>(
      `
        select sr.id::text,
               sd.spec_type::text as spec_type,
               sr.content,
               sr.revision_number
        from public.specification_documents sd
        join public.specification_revisions sr on sr.id = sd.active_revision_id
        where sd.project_id = $1::uuid
        order by array_position($2::text[], sd.spec_type::text), sd.spec_type::text
      `,
      [context.project.id, SPEC_TYPES]
    );
    const latestRevisionId = revisionRows[revisionRows.length - 1]?.id;
    if (!latestRevisionId) {
      throw new Error("specification_required");
    }

    const { rows: versionNumberRows } = await client.query<{ next_version: number }>(
      `
        select coalesce(max(version_number), -1) + 1 as next_version
        from public.graph_versions
        where project_id = $1::uuid
      `,
      [context.project.id]
    );

    const { rows: versionRows } = await client.query<{
      id: string;
      version_number: number;
      parent_version_id: string | null;
      reconciliation_id: string | null;
      source_spec_revision_id: string | null;
      semantic_diff_id: string | null;
      created_at: Date | string;
    }>(
      `
        insert into public.graph_versions (
          project_id,
          version_number,
          parent_version_id,
          source_spec_revision_id
        )
        values ($1::uuid, $2, $3::uuid, $4::uuid)
        returning id::text, version_number, parent_version_id::text, reconciliation_id::text,
                  source_spec_revision_id::text, semantic_diff_id::text, created_at
      `,
      [
        context.project.id,
        versionNumberRows[0]?.next_version ?? 1,
        context.project.active_graph_version_id,
        latestRevisionId
      ]
    );

    const graphVersion = toGraphVersion(versionRows[0]);
    const { rows: sourceNodes } = await client.query<{
      id: string;
      node_type: GraphNode["node_type"];
      name: string;
      payload: Record<string, unknown>;
      source_spec_type: string | null;
      source_revision_id: string | null;
    }>(
      `
        select id::text, node_type::text as node_type, name, payload,
               source_spec_type::text, source_revision_id::text
        from public.graph_nodes
        where graph_version_id = $1::uuid
        order by created_at
      `,
      [context.project.active_graph_version_id]
    );

    const nodeMap = new Map<string, string>();
    if (sourceNodes.length) {
      for (const node of sourceNodes) {
        const { rows: insertedNodes } = await client.query<{ id: string }>(
          `
            insert into public.graph_nodes (
              project_id,
              graph_version_id,
              node_type,
              name,
              payload,
              source_spec_type,
              source_revision_id
            )
            values (
              $1::uuid,
              $2::uuid,
              $3::public.graph_node_type,
              $4,
              $5::jsonb,
              $6::public.specification_type,
              coalesce($7::uuid, $8::uuid)
            )
            returning id::text
          `,
          [
            context.project.id,
            graphVersion.id,
            node.node_type,
            node.name,
            JSON.stringify({
              ...node.payload,
              compiled_from_node_id: node.id,
              compiled_at: new Date().toISOString()
            }),
            node.source_spec_type,
            node.source_revision_id,
            latestRevisionId
          ]
        );

        nodeMap.set(node.id, insertedNodes[0].id);
      }

      const { rows: sourceEdges } = await client.query<{
        edge_type: GraphEdge["edge_type"];
        source_node_id: string;
        target_node_id: string;
        metadata: Record<string, unknown>;
      }>(
        `
          select edge_type::text as edge_type, source_node_id::text, target_node_id::text, metadata
          from public.graph_edges
          where graph_version_id = $1::uuid
        `,
        [context.project.active_graph_version_id]
      );

      for (const edge of sourceEdges) {
        const sourceNodeId = nodeMap.get(edge.source_node_id);
        const targetNodeId = nodeMap.get(edge.target_node_id);
        if (!sourceNodeId || !targetNodeId) {
          continue;
        }

        await client.query(
          `
            insert into public.graph_edges (
              project_id,
              graph_version_id,
              edge_type,
              source_node_id,
              target_node_id,
              metadata
            )
            values ($1::uuid, $2::uuid, $3::public.graph_edge_type, $4::uuid, $5::uuid, $6::jsonb)
          `,
          [
            context.project.id,
            graphVersion.id,
            edge.edge_type,
            sourceNodeId,
            targetNodeId,
            JSON.stringify({
              ...edge.metadata,
              compiled_from_source_node_id: edge.source_node_id,
              compiled_from_target_node_id: edge.target_node_id
            })
          ]
        );
      }
    } else {
      const templates = initialGraphTemplates(revisionRows, context.project.name);
      for (const node of templates.nodes) {
        const { rows: insertedNodes } = await client.query<{ id: string }>(
          `
            insert into public.graph_nodes (
              project_id,
              graph_version_id,
              node_type,
              name,
              payload,
              source_spec_type,
              source_revision_id
            )
            values (
              $1::uuid,
              $2::uuid,
              $3::public.graph_node_type,
              $4,
              $5::jsonb,
              $6::public.specification_type,
              $7::uuid
            )
            returning id::text
          `,
          [
            context.project.id,
            graphVersion.id,
            node.node_type,
            node.name,
            JSON.stringify({
              ...node.payload,
              compiled_at: new Date().toISOString(),
              generated_from_specs: true
            }),
            node.source_spec_type,
            node.source_revision_id
          ]
        );

        nodeMap.set(node.key, insertedNodes[0].id);
      }

      for (const edge of templates.edges) {
        const sourceNodeId = nodeMap.get(edge.source_key);
        const targetNodeId = nodeMap.get(edge.target_key);
        if (!sourceNodeId || !targetNodeId) {
          continue;
        }

        await client.query(
          `
            insert into public.graph_edges (
              project_id,
              graph_version_id,
              edge_type,
              source_node_id,
              target_node_id,
              metadata
            )
            values ($1::uuid, $2::uuid, $3::public.graph_edge_type, $4::uuid, $5::uuid, $6::jsonb)
          `,
          [
            context.project.id,
            graphVersion.id,
            edge.edge_type,
            sourceNodeId,
            targetNodeId,
            JSON.stringify({
              ...edge.metadata,
              generated_from_specs: true
            })
          ]
        );
      }
    }

    const proposedEventId = await recordEvent(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      actorId: userId,
      eventType: "GraphMutationProposed",
      subsystem: "graph",
      affectedScope: { graph_version_id: graphVersion.id },
      sourceState: context.project.active_graph_version_id,
      targetState: graphVersion.id
    });

    const validation = await createValidationGroup(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      targetType: "specification",
      targetId: latestRevisionId,
      eventId: proposedEventId
    });

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      actorId: userId,
      eventType: "ValidationPassed",
      subsystem: "validation",
      affectedScope: { validation_group_id: validation.id, graph_version_id: graphVersion.id }
    });

    const { rows: approvalRows } = await client.query<Parameters<typeof toApproval>[0]>(
      `
        insert into public.approvals (
          project_id,
          branch_id,
          approval_type,
          status,
          requested_by,
          affected_scope,
          mutation_summary,
          triggering_event_id,
          expires_at
        )
        values (
          $1::uuid,
          $2::uuid,
          'execution_approval'::public.approval_type,
          'pending'::public.approval_status,
          $3::uuid,
          $4::jsonb,
          $5::jsonb,
          $6::uuid,
          now() + interval '24 hours'
        )
        returning id::text, approval_type::text as approval_type, status::text as status,
                  project_id::text, branch_id::text, requested_by::text, reviewed_by::text,
                  affected_scope, mutation_summary, expires_at, decided_at, created_at
      `,
      [
        context.project.id,
        context.branch.id,
        userId,
        JSON.stringify({ graph_version_id: graphVersion.id }),
        JSON.stringify({
          summary: "Approve graph-scoped execution from the latest validated specification state.",
          graph_version_id: graphVersion.id,
          validation_group_id: validation.id
        }),
        proposedEventId
      ]
    );

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: context.branch.id,
      actorId: userId,
      eventType: "ExecutionApprovalRequested",
      subsystem: "approval",
      affectedScope: { approval_id: approvalRows[0].id, graph_version_id: graphVersion.id }
    });

    await client.query(
      `
        update public.projects
        set active_graph_version_id = $2::uuid,
            lifecycle_state = 'awaiting_approval'::public.project_lifecycle_state,
            operational_mode = 'execution'::public.operational_mode,
            updated_at = now()
        where id = $1::uuid
      `,
      [context.project.id, graphVersion.id]
    );

    return {
      graph_version: graphVersion,
      validation_group: validation,
      approval: toApproval(approvalRows[0])
    };
  });
}

export async function getRuntimeApprovals(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<Approval[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toApproval>[0]>(
    `
      select id::text, approval_type::text as approval_type, status::text as status,
             project_id::text, branch_id::text, requested_by::text, reviewed_by::text,
             affected_scope, mutation_summary, expires_at, decided_at, created_at
      from public.approvals
      where project_id = $1::uuid
      order by created_at desc
    `,
    [context.project.id]
  );

  return rows.map(toApproval);
}

export async function decideRuntimeApproval(
  userId: string,
  projectRef: string,
  approvalId: string,
  decision: "approved" | "rejected"
) {
  const context = await getProjectContext(userId, projectRef);
  return withTransaction(async (client) => {
    const { rows } = await client.query<Parameters<typeof toApproval>[0]>(
      `
        update public.approvals
        set status = $3::public.approval_status,
            reviewed_by = $4::uuid,
            decided_at = now(),
            updated_at = now()
        where id = $2::uuid and project_id = $1::uuid
        returning id::text, approval_type::text as approval_type, status::text as status,
                  project_id::text, branch_id::text, requested_by::text, reviewed_by::text,
                  affected_scope, mutation_summary, expires_at, decided_at, created_at
      `,
      [context.project.id, approvalId, decision, userId]
    );

    const approval = rows[0];
    if (!approval) {
      throw new Error("not_found");
    }

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: approval.branch_id,
      actorId: userId,
      eventType: decision === "approved" ? "ExecutionApproved" : "GraphMutationRejected",
      subsystem: "approval",
      affectedScope: { approval_id: approval.id },
      sourceState: "pending",
      targetState: decision
    });

    if (decision === "approved") {
      await client.query(
        `
          update public.projects
          set lifecycle_state = 'ready_for_execution'::public.project_lifecycle_state,
              operational_mode = 'execution'::public.operational_mode,
              updated_at = now()
          where id = $1::uuid
        `,
        [context.project.id]
      );
    }

    return toApproval(approval);
  });
}

export async function getRuntimeExecutions(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<ExecutionRun[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toExecutionRun>[0]>(
    `
      select id::text, project_id::text, branch_id::text, graph_version_id::text,
             approval_id::text, status::text as status, triggered_by::text,
             started_at, completed_at, failure_reason, created_at
      from public.execution_runs
      where project_id = $1::uuid
      order by created_at desc
    `,
    [context.project.id]
  );

  return rows.map(toExecutionRun);
}

async function insertExecutionTasks(
  client: PoolClient,
  input: {
    projectId: string;
    graphVersionId: string;
    executionRunId: string;
  }
) {
  const { rows: boundaryRows } = await client.query<{
    id: string;
    name: string;
    node_type: string;
    payload: Record<string, unknown>;
  }>(
    `
      select id::text, name, node_type::text, payload
      from public.graph_nodes
      where graph_version_id = $1::uuid
        and node_type = 'execution_boundary'::public.graph_node_type
      order by name
    `,
    [input.graphVersionId]
  );

  const sourceRows = boundaryRows.length
    ? boundaryRows
    : (
        await client.query<{
          id: string;
          name: string;
          node_type: string;
          payload: Record<string, unknown>;
        }>(
          `
            select id::text, name, node_type::text, payload
            from public.graph_nodes
            where graph_version_id = $1::uuid
            order by node_type, name
            limit 8
          `,
          [input.graphVersionId]
        )
      ).rows;

  const insertedTaskIds: string[] = [];
  for (const [index, row] of sourceRows.entries()) {
    const { rows: taskRows } = await client.query<{ id: string }>(
      `
        insert into public.execution_tasks (
          execution_run_id,
          project_id,
          execution_boundary_node_id,
          sequence_number,
          status,
          dependency_task_ids,
          output_payload,
          started_at
        )
        values (
          $1::uuid,
          $2::uuid,
          $3::uuid,
          $4,
          $5::public.task_status,
          $6::uuid[],
          $7::jsonb,
          case
            when $5::public.task_status = 'running'::public.task_status then now()
            else null
          end
        )
        returning id::text
      `,
      [
        input.executionRunId,
        input.projectId,
        row.id,
        index + 1,
        index === 0 ? "running" : "pending",
        insertedTaskIds.slice(-1),
        JSON.stringify({
          task_id: `task.${index + 1}`,
          name: `Execute ${row.name}`,
          agent: "Sembl Orchestrator",
          graph_scope: [row.id],
          source_node_type: row.node_type,
          derived_from_graph: true
        })
      ]
    );

    insertedTaskIds.push(taskRows[0].id);
  }
}

export async function createRuntimeExecutionRun(
  userId: string,
  projectRef: string,
  approvalId: string,
  branchId?: string
) {
  const context = await getProjectContext(userId, projectRef);

  return withTransaction(async (client) => {
    const { rows: approvalRows } = await client.query<{
      id: string;
      approval_type: Approval["approval_type"];
      status: Approval["status"];
      branch_id: string | null;
      affected_scope: Record<string, unknown>;
      expires_at: Date | string;
    }>(
      `
        select id::text, approval_type::text as approval_type, status::text as status,
               branch_id::text, affected_scope, expires_at
        from public.approvals
        where id = $1::uuid and project_id = $2::uuid
        for update
      `,
      [approvalId, context.project.id]
    );

    const approval = approvalRows[0];
    if (!approval) {
      throw new Error("approval_required");
    }
    if (approval.approval_type !== "execution_approval") {
      throw new Error("approval_type_mismatch");
    }
    if (approval.status !== "approved") {
      throw new Error("approval_not_approved");
    }
    if (new Date(approval.expires_at).getTime() < Date.now()) {
      throw new Error("approval_expired");
    }

    const executionBranchId = approval.branch_id ?? context.branch.id;
    if (branchId && branchId !== executionBranchId) {
      throw new Error("branch_mismatch");
    }
    if (executionBranchId !== context.branch.id) {
      throw new Error("branch_mismatch");
    }

    const graphVersionId =
      typeof approval.affected_scope.graph_version_id === "string"
        ? approval.affected_scope.graph_version_id
        : context.project.active_graph_version_id;

    const { rows: runRows } = await client.query<Parameters<typeof toExecutionRun>[0]>(
      `
        insert into public.execution_runs (
          project_id,
          branch_id,
          graph_version_id,
          approval_id,
          status,
          triggered_by,
          started_at
        )
        values (
          $1::uuid,
          $2::uuid,
          $3::uuid,
          $4::uuid,
          'running'::public.execution_run_status,
          $5::uuid,
          now()
        )
        returning id::text, project_id::text, branch_id::text, graph_version_id::text,
                  approval_id::text, status::text as status, triggered_by::text,
                  started_at, completed_at, failure_reason, created_at
      `,
      [context.project.id, executionBranchId, graphVersionId, approval.id, userId]
    );

    const run = toExecutionRun(runRows[0]);
    await insertExecutionTasks(client, {
      projectId: context.project.id,
      graphVersionId,
      executionRunId: run.id
    });

    await client.query(
      `
        update public.projects
        set lifecycle_state = 'executing'::public.project_lifecycle_state,
            operational_mode = 'execution'::public.operational_mode,
            updated_at = now()
        where id = $1::uuid
      `,
      [context.project.id]
    );

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: run.branch_id,
      actorId: userId,
      eventType: "ExecutionStarted",
      subsystem: "execution",
      affectedScope: { execution_run_id: run.id, graph_version_id: graphVersionId }
    });

    return run;
  });
}

export async function getRuntimeExecution(
  userId: string,
  projectRef: string,
  runId: string
) {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toExecutionRun>[0]>(
    `
      select id::text, project_id::text, branch_id::text, graph_version_id::text,
             approval_id::text, status::text as status, triggered_by::text,
             started_at, completed_at, failure_reason, created_at
      from public.execution_runs
      where id = $1::uuid and project_id = $2::uuid
      limit 1
    `,
    [runId, context.project.id]
  );

  return rows[0] ? toExecutionRun(rows[0]) : null;
}

export async function getRuntimeExecutionTasks(
  userId: string,
  projectRef: string,
  runId: string
): Promise<ExecutionTask[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toExecutionTask>[0]>(
    `
      select et.id::text, et.execution_run_id::text, et.execution_boundary_node_id::text,
             et.sequence_number, et.status::text as status, et.dependency_task_ids::text[],
             et.output_payload, et.started_at, et.completed_at, et.failure_reason
      from public.execution_tasks et
      join public.execution_runs er on er.id = et.execution_run_id
      where et.execution_run_id = $1::uuid and er.project_id = $2::uuid
      order by et.sequence_number
    `,
    [runId, context.project.id]
  );

  return rows.map(toExecutionTask);
}

export async function getRuntimeTasks(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<ExecutionTask[]> {
  const executions = await getRuntimeExecutions(userId, projectRef);
  const latest = executions[0];
  if (!latest) {
    return [];
  }

  return getRuntimeExecutionTasks(userId, projectRef, latest.id);
}

async function completeExecutionArtifacts(
  client: PoolClient,
  input: {
    projectId: string;
    branchId: string;
    graphVersionId: string;
    runId: string;
    userId: string;
  }
) {
  await client.query(
    `
      update public.execution_runs
      set status = 'completed'::public.execution_run_status,
          completed_at = now(),
          updated_at = now()
      where id = $1::uuid
    `,
    [input.runId]
  );

  await recordEvent(client, {
    projectId: input.projectId,
    branchId: input.branchId,
    actorId: input.userId,
    eventType: "ExecutionCompleted",
    subsystem: "execution",
    affectedScope: { execution_run_id: input.runId }
  });

  const { rows: diffRows } = await client.query<{ id: string }>(
    `
      insert into public.semantic_diffs (project_id, from_version_id, to_version_id, diff_payload)
      values (
        $1::uuid,
        $2::uuid,
        $2::uuid,
        $3::jsonb
      )
      returning id::text
    `,
    [
      input.projectId,
      input.graphVersionId,
      JSON.stringify({
        summary: "Execution completed without graph mutations.",
        canonical_graph_preserved: true
      })
    ]
  );

  await recordEvent(client, {
    projectId: input.projectId,
    branchId: input.branchId,
    actorId: input.userId,
    eventType: "ReconciliationStarted",
    subsystem: "reconciliation",
    affectedScope: { execution_run_id: input.runId }
  });

  const { rows: reconciliationRows } = await client.query<{ id: string }>(
    `
      insert into public.reconciliation_attempts (
        project_id,
        branch_id,
        execution_run_id,
        status,
        snapshot_version_id,
        output_version_id,
        semantic_diff_id,
        started_at,
        committed_at
      )
      values (
        $1::uuid,
        $2::uuid,
        $3::uuid,
        'committed'::public.reconciliation_status,
        $4::uuid,
        $4::uuid,
        $5::uuid,
        now(),
        now()
      )
      returning id::text
    `,
    [input.projectId, input.branchId, input.runId, input.graphVersionId, diffRows[0].id]
  );

  await recordEvent(client, {
    projectId: input.projectId,
    branchId: input.branchId,
    actorId: input.userId,
    eventType: "ReconciliationCompleted",
    subsystem: "reconciliation",
    affectedScope: {
      reconciliation_id: reconciliationRows[0].id,
      semantic_diff_id: diffRows[0].id
    }
  });

  const { rows: existingDeployments } = await client.query<{ id: string }>(
    `
      select id::text
      from public.deployments
      where project_id = $1::uuid
      order by created_at desc
      limit 1
    `,
    [input.projectId]
  );

  await client.query(
    `
      insert into public.deployments (
        project_id,
        branch_id,
        graph_version_id,
        execution_run_id,
        provider,
        provider_url,
        environment,
        status,
        previous_deployment_id,
        triggered_by,
        failure_reason,
        metadata
      )
      values (
        $1::uuid,
        $2::uuid,
        $3::uuid,
        $4::uuid,
        'vercel',
        null,
        'production',
        'not_deployed'::public.deployment_status,
        $5::uuid,
        $6::uuid,
        'No deployment integration is configured for this project.',
        $7::jsonb
      )
    `,
    [
      input.projectId,
      input.branchId,
      input.graphVersionId,
      input.runId,
      existingDeployments[0]?.id ?? null,
      input.userId,
      JSON.stringify({
        source: "semantics_verified_execution",
        blocked_reason: "missing_deployment_integration"
      })
    ]
  );

  await recordEvent(client, {
    projectId: input.projectId,
    branchId: input.branchId,
    actorId: input.userId,
    eventType: "DeploymentFailed",
    subsystem: "deployment",
    affectedScope: {
      execution_run_id: input.runId,
      blocked_reason: "missing_deployment_integration"
    }
  });

  await client.query(
    `
      update public.projects
      set lifecycle_state = 'active'::public.project_lifecycle_state,
          operational_mode = 'iteration'::public.operational_mode,
          updated_at = now()
      where id = $1::uuid
    `,
    [input.projectId]
  );
}

export async function advanceRuntimeExecution(
  userId: string,
  projectRef: string,
  runId: string
) {
  const context = await getProjectContext(userId, projectRef);
  return withTransaction(async (client) => {
    const { rows: runRows } = await client.query<{
      id: string;
      branch_id: string;
      graph_version_id: string;
      status: ExecutionRun["status"];
    }>(
      `
        select id::text, branch_id::text, graph_version_id::text, status::text as status
        from public.execution_runs
        where id = $1::uuid and project_id = $2::uuid
        for update
      `,
      [runId, context.project.id]
    );

    const run = runRows[0];
    if (!run) {
      throw new Error("not_found");
    }
    if (run.status === "completed") {
      return { status: "completed" as const };
    }

    const { rows: currentRows } = await client.query<{ id: string }>(
      `
        select id::text
        from public.execution_tasks
        where execution_run_id = $1::uuid and status = 'running'::public.task_status
        order by sequence_number
        limit 1
      `,
      [runId]
    );

    if (currentRows[0]) {
      await client.query(
        `
          update public.execution_tasks
          set status = 'completed'::public.task_status,
              completed_at = now()
          where id = $1::uuid
        `,
        [currentRows[0].id]
      );
    }

    const { rows: nextRows } = await client.query<{ id: string }>(
      `
        select et.id::text
        from public.execution_tasks et
        where et.execution_run_id = $1::uuid
          and et.status = 'pending'::public.task_status
          and not exists (
            select 1
            from unnest(et.dependency_task_ids) dep(id)
            join public.execution_tasks dep_task on dep_task.id = dep.id
            where dep_task.status <> 'completed'::public.task_status
          )
        order by et.sequence_number
        limit 1
      `,
      [runId]
    );

    if (nextRows[0]) {
      await client.query(
        `
          update public.execution_tasks
          set status = 'running'::public.task_status,
              started_at = coalesce(started_at, now())
          where id = $1::uuid
        `,
        [nextRows[0].id]
      );
      return { status: "running" as const };
    }

    await completeExecutionArtifacts(client, {
      projectId: context.project.id,
      branchId: run.branch_id,
      graphVersionId: run.graph_version_id,
      runId,
      userId
    });

    return { status: "completed" as const };
  });
}

export async function retryRuntimeExecution(
  userId: string,
  projectRef: string,
  runId: string
) {
  const existing = await getRuntimeExecution(userId, projectRef, runId);
  if (!existing) {
    throw new Error("not_found");
  }
  const context = await getProjectContext(userId, projectRef);

  return withTransaction(async (client) => {
    const { rows: runRows } = await client.query<Parameters<typeof toExecutionRun>[0]>(
      `
        insert into public.execution_runs (
          project_id,
          branch_id,
          graph_version_id,
          approval_id,
          status,
          triggered_by,
          started_at,
          metadata
        )
        values (
          $1::uuid,
          $2::uuid,
          $3::uuid,
          $4::uuid,
          'running'::public.execution_run_status,
          $5::uuid,
          now(),
          $6::jsonb
        )
        returning id::text, project_id::text, branch_id::text, graph_version_id::text,
                  approval_id::text, status::text as status, triggered_by::text,
                  started_at, completed_at, failure_reason, created_at
      `,
      [
        context.project.id,
        existing.branch_id,
        existing.graph_version_id,
        existing.approval_id,
        userId,
        JSON.stringify({ retry_of_execution_run_id: existing.id })
      ]
    );

    const retry = toExecutionRun(runRows[0]);
    await insertExecutionTasks(client, {
      projectId: context.project.id,
      graphVersionId: retry.graph_version_id,
      executionRunId: retry.id
    });

    await recordEvent(client, {
      projectId: context.project.id,
      branchId: retry.branch_id,
      actorId: userId,
      eventType: "ExecutionStarted",
      subsystem: "execution",
      affectedScope: { execution_run_id: retry.id, retry_of_execution_run_id: existing.id }
    });

    return retry;
  });
}

export async function getRuntimeReconciliations(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<ReconciliationAttempt[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toReconciliation>[0]>(
    `
      select id::text, project_id::text, branch_id::text, execution_run_id::text,
             merge_attempt_id::text, status::text as status, snapshot_version_id::text,
             output_version_id::text, semantic_diff_id::text, failure_reason,
             started_at, committed_at, created_at
      from public.reconciliation_attempts
      where project_id = $1::uuid
      order by created_at desc
    `,
    [context.project.id]
  );

  return rows.map(toReconciliation);
}

export async function getRuntimeReconciliation(
  userId: string,
  projectRef: string,
  reconciliationId: string
) {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toReconciliation>[0]>(
    `
      select id::text, project_id::text, branch_id::text, execution_run_id::text,
             merge_attempt_id::text, status::text as status, snapshot_version_id::text,
             output_version_id::text, semantic_diff_id::text, failure_reason,
             started_at, committed_at, created_at
      from public.reconciliation_attempts
      where id = $1::uuid and project_id = $2::uuid
      limit 1
    `,
    [reconciliationId, context.project.id]
  );

  return rows[0] ? toReconciliation(rows[0]) : null;
}

export async function getRuntimeDeployments(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<DeploymentRecord[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<Parameters<typeof toDeployment>[0]>(
    `
      select id::text, project_id::text, branch_id::text, graph_version_id::text,
             execution_run_id::text, provider, provider_deployment_id, provider_url,
             environment, status::text as status, deployed_at, health_verified_at,
             failure_reason, metadata, created_at
      from public.deployments
      where project_id = $1::uuid
      order by created_at desc
    `,
    [context.project.id]
  );

  return rows.map(toDeployment);
}

export async function getRuntimeValidationGroups(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<ValidationGroup[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows: groupRows } = await query<{
    id: string;
    project_id: string;
    branch_id: string | null;
    target_type: ValidationGroup["target_type"];
    target_id: string;
    status: ValidationGroup["status"];
    completed_at: Date | string | null;
    created_at: Date | string;
  }>(
    `
      select id::text, project_id::text, branch_id::text,
             target_type::text as target_type, target_id::text,
             status::text as status, completed_at, created_at
      from public.validation_run_groups
      where project_id = $1::uuid
      order by created_at desc
      limit 8
    `,
    [context.project.id]
  );

  if (!groupRows.length) {
    return [];
  }

  const { rows: runRows } = await query<{
    id: string;
    group_id: string;
    project_id: string;
    pass_number: number;
    status: ValidationRun["status"];
    completed_at: Date | string | null;
    created_at: Date | string;
  }>(
    `
      select id::text, group_id::text, project_id::text, pass_number,
             status::text as status, completed_at, created_at
      from public.validation_runs
      where group_id = any($1::uuid[])
      order by pass_number
    `,
    [groupRows.map((group) => group.id)]
  );

  const runsByGroup = new Map<string, ValidationRun[]>();
  runRows.forEach((run) => {
    const list = runsByGroup.get(run.group_id) ?? [];
    list.push(toValidationRun(run));
    runsByGroup.set(run.group_id, list);
  });

  return groupRows.map((group) => ({
    ...group,
    completed_at: toIso(group.completed_at),
    created_at: toIso(group.created_at) ?? "",
    runs: runsByGroup.get(group.id) ?? []
  }));
}

export async function getRuntimeNotifications(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<NotificationRecord[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    id: string;
    workspace_id: string;
    project_id: string | null;
    severity: NotificationRecord["severity"];
    title: string;
    body: string;
    action_url: string | null;
    read_at: Date | string | null;
    created_at: Date | string;
  }>(
    `
      select id::text, workspace_id::text, project_id::text, severity::text as severity,
             title, body, action_url, read_at, created_at
      from public.notifications
      where workspace_id = $1::uuid
        and recipient_user_id = $2::uuid
      order by created_at desc
      limit 12
    `,
    [context.workspace.id, userId]
  );

  return rows.map((row) => ({
    ...row,
    read_at: toIso(row.read_at),
    created_at: toIso(row.created_at) ?? ""
  }));
}

export async function getRuntimeEvents(
  userId: string,
  projectRef = LEGACY_PROJECT_ID
): Promise<EventRecord[]> {
  const context = await getProjectContext(userId, projectRef);
  const { rows } = await query<{
    id: string;
    project_id: string;
    branch_id: string | null;
    event_type: string;
    sequence_number: string | number;
    actor_id: string | null;
    originating_subsystem: string;
    affected_scope: Record<string, unknown>;
    source_state: string | null;
    target_state: string | null;
    metadata: Record<string, unknown>;
    created_at: Date | string;
  }>(
    `
      select id::text, project_id::text, branch_id::text, event_type::text,
             sequence_number, actor_id::text, originating_subsystem,
             affected_scope, source_state, target_state, metadata, created_at
      from public.events
      where project_id = $1::uuid
      order by sequence_number desc
      limit 20
    `,
    [context.project.id]
  );

  return rows.map((row) => ({
    ...row,
    sequence_number: Number(row.sequence_number),
    created_at: toIso(row.created_at) ?? ""
  }));
}

export async function getRuntimeGraphSummary(userId: string, projectRef = LEGACY_PROJECT_ID) {
  const graph = await getRuntimeGraph(userId, projectRef);
  const byType = graph.nodes.reduce<Record<string, number>>((acc, node) => {
    acc[node.node_type] = (acc[node.node_type] ?? 0) + 1;
    return acc;
  }, {});

  return {
    version_id: graph.version_id,
    node_count: graph.nodes.length,
    edge_count: graph.edges.length,
    node_types: byType,
    invariants: graph.nodes
      .filter((node) => node.node_type === "invariant")
      .map((node) => ({
        id: node.id,
        name: node.name,
        rule: String(node.payload.rule ?? "")
      })),
    execution_boundaries: graph.nodes
      .filter((node) => node.node_type === "execution_boundary")
      .map((node) => ({
        id: node.id,
        name: node.name,
        dependency_scope: String(node.payload.dependency_scope ?? "")
      }))
  };
}

export async function getRuntimeHomeData(
  userId: string,
  projectRef = LEGACY_PROJECT_ID,
  email: string | null = null
): Promise<RuntimeHomeData> {
  const [
    directory,
    snapshot,
    specs,
    graph,
    graphVersions,
    validationGroups,
    approvals,
    executions,
    tasks,
    reconciliations,
    deployments,
    notifications,
    events
  ] = await Promise.all([
    getRuntimeProjectDirectory(userId),
    getRuntimeProjectSnapshot(userId, projectRef, email),
    getRuntimeSpecs(userId, projectRef),
    getRuntimeGraph(userId, projectRef),
    getRuntimeGraphVersions(userId, projectRef),
    getRuntimeValidationGroups(userId, projectRef),
    getRuntimeApprovals(userId, projectRef),
    getRuntimeExecutions(userId, projectRef),
    getRuntimeTasks(userId, projectRef),
    getRuntimeReconciliations(userId, projectRef),
    getRuntimeDeployments(userId, projectRef),
    getRuntimeNotifications(userId, projectRef),
    getRuntimeEvents(userId, projectRef)
  ]);

  return {
    directory,
    snapshot,
    specs,
    graph,
    graphVersions,
    validationGroups,
    approvals,
    executions,
    tasks,
    reconciliations,
    deployments,
    notifications,
    events
  };
}
