import { Pool } from "pg";
import type {
  Approval,
  ExecutionRun,
  ExecutionTask,
  GraphEdge,
  GraphNode,
  ReconciliationAttempt
} from "./types";
import {
  APPROVAL_ID,
  BRANCH_ID,
  decideApproval as decideArtifactApproval,
  getApprovals as getArtifactApprovals,
  getDeterministicDag as getArtifactTasks,
  getExecution as getArtifactExecution,
  getExecutionTasks as getArtifactExecutionTasks,
  getExecutions as getArtifactExecutions,
  getGraph as getArtifactGraph,
  getGraphSummary as getArtifactGraphSummary,
  getGraphVersions as getArtifactGraphVersions,
  getProjectSnapshot as getArtifactProjectSnapshot,
  getReconciliation as getArtifactReconciliation,
  getReconciliations as getArtifactReconciliations,
  getSubgraph as getArtifactSubgraph,
  GRAPH_VERSION_ID,
  PROJECT_ID
} from "./semantic-store";

type RuntimeTask = ReturnType<typeof getArtifactTasks>[number];
type RuntimeGraph = ReturnType<typeof getArtifactGraph>;

type DbNodeRow = {
  id: string;
  node_type: GraphNode["node_type"];
  name: string;
  payload: Record<string, unknown>;
  source_spec_type: string | null;
  created_at: Date | string;
};

type DbEdgeRow = {
  id: string;
  edge_type: GraphEdge["edge_type"];
  source_node_id: string;
  target_node_id: string;
  metadata: Record<string, unknown>;
  created_at: Date | string;
};

type DbTaskRow = {
  id: string;
  execution_run_id: string;
  execution_boundary_semantic_id: string | null;
  sequence_number: number;
  status: ExecutionTask["status"];
  dependency_task_ids: string[];
  output_payload: Record<string, unknown>;
  started_at: Date | string | null;
  completed_at: Date | string | null;
  failure_reason: string | null;
};

type DbApprovalRow = {
  approval_type: Approval["approval_type"];
  status: Approval["status"];
  affected_scope: Record<string, unknown>;
  mutation_summary: Record<string, unknown>;
  expires_at: Date | string;
  decided_at: Date | string | null;
  created_at: Date | string;
};

const connectionString = process.env.SUPABASE_DB_URL ?? process.env.POSTGRES_URL;
const globalForPg = globalThis as typeof globalThis & { __semblPgPool?: Pool };

function getPool() {
  if (!connectionString) {
    return null;
  }

  if (!globalForPg.__semblPgPool) {
    globalForPg.__semblPgPool = new Pool({
      connectionString,
      max: 3,
      ssl: { rejectUnauthorized: false }
    });
  }

  return globalForPg.__semblPgPool;
}

function toIso(value: Date | string | null | undefined) {
  if (!value) {
    return null;
  }
  return value instanceof Date ? value.toISOString() : value;
}

function toTaskStatus(value: unknown): ExecutionTask["status"] {
  return value === "running" ||
    value === "completed" ||
    value === "failed" ||
    value === "skipped"
    ? value
    : "pending";
}

function mapDbApproval(row: DbApprovalRow): Approval {
  return {
    id: APPROVAL_ID,
    approval_type: row.approval_type,
    status: row.status,
    project_id: PROJECT_ID,
    branch_id: BRANCH_ID,
    requested_by: "sembl-system",
    reviewed_by: row.decided_at ? "sembl-system" : null,
    affected_scope: row.affected_scope ?? {},
    mutation_summary: row.mutation_summary ?? {},
    expires_at: toIso(row.expires_at) ?? "",
    decided_at: toIso(row.decided_at),
    created_at: toIso(row.created_at) ?? ""
  };
}

async function dbOrArtifact<T>(load: (pool: Pool) => Promise<T>, fallback: () => T) {
  const pool = getPool();
  if (!pool) {
    return fallback();
  }

  try {
    return await load(pool);
  } catch (error) {
    console.warn(
      "Supabase runtime read failed; using artifact fallback.",
      error instanceof Error ? error.message : error
    );
    return fallback();
  }
}

export async function getRuntimeProjectSnapshot() {
  return dbOrArtifact(async (pool) => {
    const base = getArtifactProjectSnapshot();
    const { rows } = await pool.query<{
      workspace_name: string;
      workspace_slug: string;
      project_name: string;
      project_slug: string;
      lifecycle_state: string;
      operational_mode: string;
      branch_name: string;
      branch_state: string;
      node_count: number;
      edge_count: number;
      task_count: number;
    }>(`
      select
        w.name as workspace_name,
        w.slug as workspace_slug,
        p.name as project_name,
        p.slug as project_slug,
        p.lifecycle_state::text,
        p.operational_mode::text,
        b.name as branch_name,
        b.state::text as branch_state,
        (select count(*)::int from public.graph_nodes gn where gn.project_id = p.id) as node_count,
        (select count(*)::int from public.graph_edges ge where ge.project_id = p.id) as edge_count,
        (select count(*)::int from public.execution_tasks et where et.project_id = p.id) as task_count
      from public.projects p
      join public.workspaces w on w.id = p.workspace_id
      join public.branches b on b.id = p.active_branch_id
      where p.slug = 'sembl-core'
      limit 1
    `);

    const row = rows[0];
    if (!row) {
      return base;
    }

    return {
      ...base,
      workspace: {
        ...base.workspace,
        name: row.workspace_name,
        slug: row.workspace_slug
      },
      project: {
        ...base.project,
        name: row.project_name,
        slug: row.project_slug,
        lifecycle_state: row.lifecycle_state,
        operational_mode: row.operational_mode
      },
      branch: {
        ...base.branch,
        name: row.branch_name,
        state: row.branch_state
      },
      counts: {
        ...base.counts,
        nodes: row.node_count,
        edges: row.edge_count,
        tasks: row.task_count
      },
      runtimeSource: "supabase"
    };
  }, getArtifactProjectSnapshot);
}

export async function getRuntimeGraph(): Promise<RuntimeGraph> {
  return dbOrArtifact(async (pool) => {
    const [nodesResult, edgesResult] = await Promise.all([
      pool.query<DbNodeRow>(`
        select gn.id::text, gn.node_type::text as node_type, gn.name, gn.payload,
               gn.source_spec_type::text, gn.created_at
        from public.graph_nodes gn
        join public.projects p on p.id = gn.project_id
        join public.graph_versions gv on gv.id = gn.graph_version_id
        where p.slug = 'sembl-core' and gv.version_number = 0
        order by gn.created_at, gn.name
      `),
      pool.query<DbEdgeRow>(`
        select ge.id::text, ge.edge_type::text as edge_type, ge.source_node_id::text,
               ge.target_node_id::text, ge.metadata, ge.created_at
        from public.graph_edges ge
        join public.projects p on p.id = ge.project_id
        join public.graph_versions gv on gv.id = ge.graph_version_id
        where p.slug = 'sembl-core' and gv.version_number = 0
        order by ge.created_at, ge.id
      `)
    ]);

    if (!nodesResult.rows.length) {
      return getArtifactGraph();
    }

    const nodeIdByDbId = new Map<string, string>();
    const nodes: RuntimeGraph["nodes"] = nodesResult.rows.map((row) => {
      const semanticId = String(row.payload?.semantic_id ?? row.id);
      nodeIdByDbId.set(row.id, semanticId);
      return {
        id: semanticId,
        node_type: row.node_type,
        name: row.name,
        payload: row.payload ?? {},
        source_spec_type: row.source_spec_type,
        source_refs: Array.isArray(row.payload?.source_refs)
          ? (row.payload.source_refs as string[])
          : [],
        created_at: toIso(row.created_at) ?? "2026-06-02T12:00:00.000Z"
      };
    });

    const edges: RuntimeGraph["edges"] = edgesResult.rows.map((row) => ({
      id: String(row.metadata?.semantic_id ?? row.id),
      edge_type: row.edge_type,
      source_node_id: String(
        row.metadata?.semantic_source_node_id ??
          nodeIdByDbId.get(row.source_node_id) ??
          row.source_node_id
      ),
      target_node_id: String(
        row.metadata?.semantic_target_node_id ??
          nodeIdByDbId.get(row.target_node_id) ??
          row.target_node_id
      ),
      metadata: row.metadata ?? {},
      created_at: toIso(row.created_at) ?? "2026-06-02T12:00:00.000Z"
    }));

    return {
      version_id: GRAPH_VERSION_ID,
      version_number: 0,
      nodes,
      edges
    };
  }, getArtifactGraph);
}

export async function getRuntimeGraphVersions() {
  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<{ version_number: number; created_at: Date }>(`
      select gv.version_number, gv.created_at
      from public.graph_versions gv
      join public.projects p on p.id = gv.project_id
      where p.slug = 'sembl-core'
      order by gv.version_number
    `);

    if (!rows.length) {
      return getArtifactGraphVersions();
    }

    return rows.map((row) => ({
      id: GRAPH_VERSION_ID,
      version_number: row.version_number,
      parent_version_id: null,
      reconciliation_id: null,
      created_at: toIso(row.created_at) ?? new Date().toISOString()
    }));
  }, getArtifactGraphVersions);
}

export async function getRuntimeGraphVersion(versionId: string) {
  if (versionId !== GRAPH_VERSION_ID) {
    return null;
  }
  return getRuntimeGraph();
}

export async function getRuntimeNode(nodeId: string) {
  const graph = await getRuntimeGraph();
  return graph.nodes.find((node) => node.id === nodeId) ?? null;
}

export async function getRuntimeSubgraph(nodeId: string, depth = 2) {
  const graph = await getRuntimeGraph();
  const rootNode = graph.nodes.find((node) => node.id === nodeId);
  if (!rootNode) {
    return getArtifactSubgraph(nodeId, depth);
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

export async function getRuntimeApprovals(): Promise<Approval[]> {
  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<DbApprovalRow>(`
      select a.approval_type::text as approval_type, a.status::text as status,
             a.affected_scope, a.mutation_summary, a.expires_at, a.decided_at, a.created_at
      from public.approvals a
      join public.projects p on p.id = a.project_id
      where p.slug = 'sembl-core'
      order by a.created_at
    `);

    if (!rows.length) {
      return getArtifactApprovals();
    }

    return rows.map(mapDbApproval);
  }, getArtifactApprovals);
}

export async function decideRuntimeApproval(
  approvalId: string,
  decision: "approved" | "rejected"
) {
  if (approvalId !== APPROVAL_ID) {
    return null;
  }

  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<DbApprovalRow>(
      `
        update public.approvals a
        set status = $1::public.approval_status,
            reviewed_by = (
              select id from auth.users where email = 'system@sembl.local' limit 1
            ),
            decided_at = now(),
            updated_at = now()
        from public.projects p
        where p.id = a.project_id
          and p.slug = 'sembl-core'
        returning a.approval_type::text as approval_type,
                  a.status::text as status,
                  a.affected_scope,
                  a.mutation_summary,
                  a.expires_at,
                  a.decided_at,
                  a.created_at
      `,
      [decision]
    );

    return rows[0] ? mapDbApproval(rows[0]) : null;
  }, () => decideArtifactApproval(approvalId, decision));
}

export async function getRuntimeExecutions(): Promise<ExecutionRun[]> {
  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<{
      status: ExecutionRun["status"];
      started_at: Date | string | null;
      completed_at: Date | string | null;
      failure_reason: string | null;
      created_at: Date | string;
    }>(`
      select er.status::text as status, er.started_at, er.completed_at,
             er.failure_reason, er.created_at
      from public.execution_runs er
      join public.projects p on p.id = er.project_id
      where p.slug = 'sembl-core'
      order by er.created_at
    `);

    if (!rows.length) {
      return getArtifactExecutions();
    }

    return rows.map((row) => ({
      id: "execution_seed_ready",
      project_id: PROJECT_ID,
      branch_id: BRANCH_ID,
      graph_version_id: GRAPH_VERSION_ID,
      approval_id: APPROVAL_ID,
      status: row.status,
      triggered_by: null,
      started_at: toIso(row.started_at),
      completed_at: toIso(row.completed_at),
      failure_reason: row.failure_reason,
      created_at: toIso(row.created_at) ?? ""
    }));
  }, getArtifactExecutions);
}

export async function getRuntimeExecution(runId: string) {
  const executions = await getRuntimeExecutions();
  return executions.find((execution) => execution.id === runId) ?? getArtifactExecution(runId);
}

export async function getRuntimeTasks(): Promise<RuntimeTask[]> {
  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<DbTaskRow>(`
      select et.id::text, et.execution_run_id::text,
             gn.payload->>'semantic_id' as execution_boundary_semantic_id,
             et.sequence_number, et.status::text as status, et.dependency_task_ids::text[],
             et.output_payload, et.started_at, et.completed_at, et.failure_reason
      from public.execution_tasks et
      join public.projects p on p.id = et.project_id
      left join public.graph_nodes gn on gn.id = et.execution_boundary_node_id
      where p.slug = 'sembl-core'
      order by et.sequence_number
    `);

    if (!rows.length) {
      return getArtifactTasks();
    }

    const semanticIdByDbId = new Map(
      rows.map((row) => [row.id, String(row.output_payload?.task_id ?? row.id)])
    );

    return rows.map((row) => ({
      id: String(row.output_payload?.task_id ?? row.id),
      name: String(row.output_payload?.name ?? `Task ${row.sequence_number}`),
      agent: String(row.output_payload?.agent ?? "Sembl"),
      dependencies: (row.dependency_task_ids ?? []).map(
        (id) => semanticIdByDbId.get(id) ?? id
      ),
      graph_scope: Array.isArray(row.output_payload?.graph_scope)
        ? (row.output_payload.graph_scope as string[])
        : [],
      execution_boundary: row.execution_boundary_semantic_id,
      status: row.status,
      sequence_number: row.sequence_number
    }));
  }, getArtifactTasks);
}

export async function getRuntimeExecutionTasks(runId: string): Promise<ExecutionTask[]> {
  if (runId !== "execution_seed_ready") {
    return getArtifactExecutionTasks(runId);
  }

  const tasks = await getRuntimeTasks();
  return tasks.map((task) => ({
    id: `execution_task_${task.id.replaceAll(".", "_")}`,
    execution_run_id: runId,
    execution_boundary_node_id: task.execution_boundary,
    sequence_number: task.sequence_number,
    status: toTaskStatus(task.status),
    dependency_task_ids: task.dependencies.map(
      (dependency) => `execution_task_${dependency.replaceAll(".", "_")}`
    ),
    output_payload: {
      task_id: task.id,
      name: task.name,
      agent: task.agent,
      graph_scope: task.graph_scope,
      context_persisted: false
    },
    started_at: task.status === "completed" || task.status === "running"
      ? new Date("2026-06-02T12:00:00.000Z").toISOString()
      : null,
    completed_at: task.status === "completed"
      ? new Date("2026-06-02T12:00:00.000Z").toISOString()
      : null,
    failure_reason: null
  }));
}

export async function getRuntimeReconciliations(): Promise<ReconciliationAttempt[]> {
  return dbOrArtifact(async (pool) => {
    const { rows } = await pool.query<{
      status: ReconciliationAttempt["status"];
      failure_reason: string | null;
      started_at: Date | string | null;
      committed_at: Date | string | null;
      created_at: Date | string;
    }>(`
      select ra.status::text as status, ra.failure_reason, ra.started_at,
             ra.committed_at, ra.created_at
      from public.reconciliation_attempts ra
      join public.projects p on p.id = ra.project_id
      where p.slug = 'sembl-core'
      order by ra.created_at
    `);

    if (!rows.length) {
      return getArtifactReconciliations();
    }

    return rows.map((row) => ({
      id: "reconciliation_seed",
      project_id: PROJECT_ID,
      branch_id: BRANCH_ID,
      execution_run_id: "execution_seed_ready",
      merge_attempt_id: null,
      status: row.status,
      snapshot_version_id: GRAPH_VERSION_ID,
      output_version_id: null,
      semantic_diff_id: "semantic_diff_seed",
      failure_reason: row.failure_reason,
      started_at: toIso(row.started_at),
      committed_at: toIso(row.committed_at),
      created_at: toIso(row.created_at) ?? ""
    }));
  }, getArtifactReconciliations);
}

export async function getRuntimeReconciliation(reconciliationId: string) {
  const reconciliations = await getRuntimeReconciliations();
  return (
    reconciliations.find((reconciliation) => reconciliation.id === reconciliationId) ??
    getArtifactReconciliation(reconciliationId)
  );
}

export async function getRuntimeGraphSummary() {
  return dbOrArtifact(async () => {
    const graph = await getRuntimeGraph();
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
  }, getArtifactGraphSummary);
}

export async function getRuntimeHomeData() {
  const [snapshot, graph, approvals, tasks, reconciliations] = await Promise.all([
    getRuntimeProjectSnapshot(),
    getRuntimeGraph(),
    getRuntimeApprovals(),
    getRuntimeTasks(),
    getRuntimeReconciliations()
  ]);

  return {
    snapshot,
    graph,
    approvals,
    tasks,
    reconciliations
  };
}
