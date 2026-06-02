export type GraphNodeType =
  | "entity"
  | "interface"
  | "integration_contract"
  | "flow"
  | "invariant"
  | "execution_boundary";

export type GraphEdgeType =
  | "dependency"
  | "implements"
  | "precedes"
  | "triggers"
  | "owns"
  | "lineage";

export type GraphNode = {
  id: string;
  node_type: GraphNodeType;
  name: string;
  payload: Record<string, unknown>;
  source_spec_type: string | null;
  source_refs?: string[];
  created_at?: string;
};

export type GraphEdge = {
  id: string;
  edge_type: GraphEdgeType;
  source_node_id: string;
  target_node_id: string;
  metadata: Record<string, unknown>;
  created_at?: string;
};

export type GraphVersion = {
  id: string;
  version_number: number;
  parent_version_id: string | null;
  reconciliation_id: string | null;
  created_at: string;
};

export type Approval = {
  id: string;
  approval_type: "execution_approval" | "mutation_approval" | "merge_approval";
  status: "pending" | "under_review" | "approved" | "rejected" | "expired";
  project_id: string;
  branch_id: string;
  requested_by: string;
  reviewed_by: string | null;
  affected_scope: Record<string, unknown>;
  mutation_summary: Record<string, unknown>;
  expires_at: string;
  decided_at: string | null;
  created_at: string;
};

export type ExecutionRun = {
  id: string;
  project_id: string;
  branch_id: string;
  graph_version_id: string;
  approval_id: string | null;
  status:
    | "queued"
    | "preparing"
    | "running"
    | "validating"
    | "reconciling"
    | "completed"
    | "failed"
    | "escalated";
  triggered_by: string | null;
  started_at: string | null;
  completed_at: string | null;
  failure_reason: string | null;
  created_at: string;
};

export type ExecutionTask = {
  id: string;
  execution_run_id: string;
  execution_boundary_node_id: string | null;
  sequence_number: number;
  status: "pending" | "running" | "completed" | "failed" | "skipped";
  dependency_task_ids: string[];
  output_payload: Record<string, unknown>;
  started_at: string | null;
  completed_at: string | null;
  failure_reason: string | null;
};

export type ReconciliationAttempt = {
  id: string;
  project_id: string;
  branch_id: string | null;
  execution_run_id: string | null;
  merge_attempt_id: string | null;
  status:
    | "pending"
    | "snapshot_taken"
    | "diff_generated"
    | "invariant_validated"
    | "lineage_updated"
    | "committed"
    | "failed"
    | "rolled_back";
  snapshot_version_id: string | null;
  output_version_id: string | null;
  semantic_diff_id: string | null;
  failure_reason: string | null;
  started_at: string | null;
  committed_at: string | null;
  created_at: string;
};

export type UiScreen = {
  id: string;
  name: string;
  scope: string;
  purpose: string;
};
