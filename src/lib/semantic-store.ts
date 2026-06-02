import normalizedGraph from "../../graph/normalized_graph.json";
import servicePreflight from "../../graph/service_preflight.json";
import taskGraph from "../../graph/task_graph.json";
import uiGraph from "../../graph/ui_graph.json";
import validationReport from "../../graph/validation_report.json";
import type {
  Approval,
  ExecutionRun,
  ExecutionTask,
  GraphEdge,
  GraphNode,
  GraphVersion,
  ReconciliationAttempt,
  UiScreen
} from "./types";

type NormalizedGraph = {
  nodes: GraphNode[];
  edges: GraphEdge[];
  normalization_policy: {
    allowed_node_types: string[];
    allowed_edge_types: string[];
  };
};

type TaskGraph = {
  tasks: Array<{
    id: string;
    name: string;
    agent: string;
    dependencies: string[];
    graph_scope: string[];
    execution_boundary: string | null;
    status?: string;
  }>;
  topological_order: string[];
};

type UiGraph = {
  primary_screen_hierarchy: UiScreen[];
  navigation_model: {
    global_navigation: string[];
    project_navigation: string[];
    contextual_navigation: string[];
  };
  secondary_inspection_surfaces: Array<{
    id: string;
    name: string;
    allowed_actions: string[];
    forbidden_actions: string[];
  }>;
  design_tokens: Record<string, unknown>;
  status_model: string[];
};

type ValidationReport = {
  status: string;
  passes: Array<{ name: string; status: string; violations: unknown[] }>;
  blocking_violations: unknown[];
  warnings: Array<Record<string, unknown>>;
};

type ServicePreflight = {
  checks: Record<string, { status: string; notes?: string[] }>;
  secret_scan: {
    forbidden_patterns_present: boolean;
    committed_secret_files: string[];
  };
};

const graph = normalizedGraph as NormalizedGraph;
const tasks = taskGraph as TaskGraph;
const ui = uiGraph as UiGraph;
const validation = validationReport as ValidationReport;
const services = servicePreflight as ServicePreflight;

export const PROJECT_ID = "project_sembl_core";
export const WORKSPACE_ID = "workspace_speedvibe";
export const BRANCH_ID = "branch_main";
export const GRAPH_VERSION_ID = "graph_version.v0_docs_seed";
export const APPROVAL_ID = "approval_execution_preflight";

const now = new Date("2026-06-02T12:00:00.000Z").toISOString();

const graphVersion: GraphVersion = {
  id: GRAPH_VERSION_ID,
  version_number: 0,
  parent_version_id: null,
  reconciliation_id: null,
  created_at: "2026-06-01T00:00:00+05:30"
};

export const graphNodes = graph.nodes.map((node) => ({
  ...node,
  created_at: node.created_at ?? "2026-06-01T00:00:00+05:30"
}));

export const graphEdges = graph.edges.map((edge) => ({
  ...edge,
  created_at: edge.created_at ?? "2026-06-01T00:00:00+05:30"
}));

export function getProjectSnapshot() {
  const blockingWarnings = validation.warnings.filter((warning) =>
    String(warning.code ?? "").includes("SUPABASE")
  );

  return {
    workspace: {
      id: WORKSPACE_ID,
      name: "Speedvibe",
      slug: "speedvibe"
    },
    project: {
      id: PROJECT_ID,
      name: "Sembl Core",
      slug: "sembl-core",
      lifecycle_state: "awaiting_approval",
      operational_mode: "execution",
      active_branch_id: BRANCH_ID,
      active_graph_version_id: GRAPH_VERSION_ID
    },
    branch: {
      id: BRANCH_ID,
      name: "main",
      state: "active",
      base_graph_version_id: GRAPH_VERSION_ID
    },
    screens: ui.primary_screen_hierarchy,
    navigation: ui.navigation_model,
    inspectionSurfaces: ui.secondary_inspection_surfaces,
    designTokens: ui.design_tokens,
    statusModel: ui.status_model,
    validation: {
      status: validation.status,
      passes: validation.passes,
      blocking_violations: validation.blocking_violations,
      warnings: blockingWarnings
    },
    servicePreflight: services.checks,
    secretScan: services.secret_scan,
    counts: {
      nodes: graphNodes.length,
      edges: graphEdges.length,
      tasks: tasks.tasks.length,
      screens: ui.primary_screen_hierarchy.length
    }
  };
}

export function getGraph() {
  return {
    version_id: GRAPH_VERSION_ID,
    version_number: graphVersion.version_number,
    nodes: graphNodes,
    edges: graphEdges
  };
}

export function getGraphVersions() {
  return [graphVersion];
}

export function getGraphVersion(versionId: string) {
  if (versionId !== GRAPH_VERSION_ID) {
    return null;
  }

  return getGraph();
}

export function getNode(nodeId: string) {
  return graphNodes.find((node) => node.id === nodeId) ?? null;
}

export function getSubgraph(nodeId: string, depth = 2) {
  const rootNode = getNode(nodeId);
  if (!rootNode) {
    return null;
  }

  const visited = new Set<string>([nodeId]);
  let frontier = new Set<string>([nodeId]);

  for (let level = 0; level < depth; level += 1) {
    const next = new Set<string>();

    graphEdges.forEach((edge) => {
      if (frontier.has(edge.source_node_id)) {
        next.add(edge.target_node_id);
      }
      if (frontier.has(edge.target_node_id)) {
        next.add(edge.source_node_id);
      }
    });

    next.forEach((id) => visited.add(id));
    frontier = next;
  }

  const nodes = graphNodes.filter((node) => visited.has(node.id));
  const edges = graphEdges.filter(
    (edge) => visited.has(edge.source_node_id) && visited.has(edge.target_node_id)
  );

  return {
    root_node: rootNode,
    nodes,
    edges
  };
}

export function getApprovals(): Approval[] {
  return [
    {
      id: APPROVAL_ID,
      approval_type: "execution_approval",
      status: "pending",
      project_id: PROJECT_ID,
      branch_id: BRANCH_ID,
      requested_by: "demo-user",
      reviewed_by: null,
      affected_scope: {
        graph_version_id: GRAPH_VERSION_ID,
        execution_boundary: "node.boundary.api_runtime"
      },
      mutation_summary: {
        summary: "Approve graph-scoped execution from the validated V4.3 task DAG.",
        impact_score: 0.74,
        impacted_nodes: [
          "node.interface.generate_task_graph",
          "node.interface.start_execution",
          "node.interface.reconcile_execution_output"
        ]
      },
      expires_at: "2026-06-09T00:00:00.000Z",
      decided_at: null,
      created_at: now
    }
  ];
}

export function getApproval(approvalId: string) {
  return getApprovals().find((approval) => approval.id === approvalId) ?? null;
}

export function decideApproval(
  approvalId: string,
  decision: "approved" | "rejected"
): Approval | null {
  const approval = getApproval(approvalId);
  if (!approval) {
    return null;
  }

  return {
    ...approval,
    status: decision,
    reviewed_by: "demo-user",
    decided_at: new Date().toISOString()
  };
}

export function getDeterministicDag() {
  const byId = new Map(tasks.tasks.map((task) => [task.id, task]));
  const order: string[] = [];
  const temporary = new Set<string>();
  const permanent = new Set<string>();

  function visit(taskId: string) {
    if (permanent.has(taskId)) {
      return;
    }
    if (temporary.has(taskId)) {
      throw new Error("task_dag_cycle");
    }

    temporary.add(taskId);
    const task = byId.get(taskId);
    if (!task) {
      throw new Error(`missing_task:${taskId}`);
    }

    [...task.dependencies].sort().forEach(visit);
    temporary.delete(taskId);
    permanent.add(taskId);
    order.push(taskId);
  }

  [...tasks.tasks.map((task) => task.id)].sort().forEach(visit);

  return order.map((taskId, index) => {
    const task = byId.get(taskId);
    if (!task) {
      throw new Error(`missing_task:${taskId}`);
    }

    return {
      ...task,
      sequence_number: index + 1
    };
  });
}

export function getExecutions(): ExecutionRun[] {
  return [
    {
      id: "execution_seed_ready",
      project_id: PROJECT_ID,
      branch_id: BRANCH_ID,
      graph_version_id: GRAPH_VERSION_ID,
      approval_id: APPROVAL_ID,
      status: "queued",
      triggered_by: null,
      started_at: null,
      completed_at: null,
      failure_reason: null,
      created_at: now
    }
  ];
}

export function createExecutionRun(approvalId: string, actorId: string): ExecutionRun {
  const approval = getApproval(approvalId);
  if (!approval) {
    throw new Error("approval_required");
  }

  if (new Date(approval.expires_at).getTime() < Date.now()) {
    throw new Error("approval_expired");
  }

  return {
    id: `execution_${Date.now()}`,
    project_id: PROJECT_ID,
    branch_id: BRANCH_ID,
    graph_version_id: GRAPH_VERSION_ID,
    approval_id: approvalId,
    status: "running",
    triggered_by: actorId,
    started_at: new Date().toISOString(),
    completed_at: null,
    failure_reason: null,
    created_at: new Date().toISOString()
  };
}

export function getExecution(runId: string) {
  return getExecutions().find((run) => run.id === runId) ?? null;
}

export function getExecutionTasks(runId: string): ExecutionTask[] {
  return getDeterministicDag().map((task, index) => ({
    id: `execution_task_${task.id.replaceAll(".", "_")}`,
    execution_run_id: runId,
    execution_boundary_node_id: task.execution_boundary,
    sequence_number: task.sequence_number,
    status: index < 6 ? "completed" : index === 6 ? "running" : "pending",
    dependency_task_ids: task.dependencies.map((dependency) =>
      `execution_task_${dependency.replaceAll(".", "_")}`
    ),
    output_payload: {
      task_id: task.id,
      name: task.name,
      agent: task.agent,
      graph_scope: task.graph_scope,
      context_persisted: false
    },
    started_at: index < 7 ? now : null,
    completed_at: index < 6 ? now : null,
    failure_reason: null
  }));
}

export function getReconciliations(): ReconciliationAttempt[] {
  return [
    {
      id: "reconciliation_seed",
      project_id: PROJECT_ID,
      branch_id: BRANCH_ID,
      execution_run_id: "execution_seed_ready",
      merge_attempt_id: null,
      status: "diff_generated",
      snapshot_version_id: GRAPH_VERSION_ID,
      output_version_id: null,
      semantic_diff_id: "semantic_diff_seed",
      failure_reason: null,
      started_at: now,
      committed_at: null,
      created_at: now
    }
  ];
}

export function getReconciliation(reconciliationId: string) {
  return (
    getReconciliations().find(
      (reconciliation) => reconciliation.id === reconciliationId
    ) ?? null
  );
}

export function getGraphSummary() {
  const byType = graphNodes.reduce<Record<string, number>>((acc, node) => {
    acc[node.node_type] = (acc[node.node_type] ?? 0) + 1;
    return acc;
  }, {});

  return {
    version_id: GRAPH_VERSION_ID,
    node_count: graphNodes.length,
    edge_count: graphEdges.length,
    node_types: byType,
    invariants: graphNodes
      .filter((node) => node.node_type === "invariant")
      .map((node) => ({
        id: node.id,
        name: node.name,
        rule: String(node.payload.rule ?? "")
      })),
    execution_boundaries: graphNodes
      .filter((node) => node.node_type === "execution_boundary")
      .map((node) => ({
        id: node.id,
        name: node.name,
        dependency_scope: String(node.payload.dependency_scope ?? "")
      }))
  };
}
