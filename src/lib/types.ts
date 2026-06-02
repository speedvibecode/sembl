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
  source_spec_revision_id?: string | null;
  semantic_diff_id?: string | null;
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

export type WorkspaceRole = "owner" | "admin" | "member" | "viewer";

export type SpecificationType =
  | "pdd"
  | "prd"
  | "nfr"
  | "uiux"
  | "system_design"
  | "db_schema"
  | "api_spec"
  | "tech_architecture";

export type SpecificationDraft = {
  id: string;
  project_id: string;
  spec_type: SpecificationType;
  active_revision_id: string | null;
  active_revision_number: number | null;
  active_content: string;
  draft_content: string;
  draft_updated_at: string | null;
  updated_at: string;
  is_dirty: boolean;
};

export type SpecificationRevision = {
  id: string;
  document_id: string;
  project_id: string;
  revision_number: number;
  content: string;
  content_hash: string;
  authored_by: string;
  parent_revision_id: string | null;
  created_at: string;
};

export type ValidationRun = {
  id: string;
  group_id: string;
  project_id: string;
  pass_number: number;
  status: "running" | "passed" | "passed_with_warnings" | "failed";
  completed_at: string | null;
  created_at: string;
};

export type ValidationGroup = {
  id: string;
  project_id: string;
  branch_id: string | null;
  target_type:
    | "specification"
    | "execution_run"
    | "reconciliation_attempt"
    | "merge_attempt"
    | "repository_ingestion";
  target_id: string;
  status: "running" | "passed" | "passed_with_warnings" | "failed";
  completed_at: string | null;
  created_at: string;
  runs: ValidationRun[];
};

export type DeploymentRecord = {
  id: string;
  project_id: string;
  branch_id: string;
  graph_version_id: string;
  execution_run_id: string | null;
  provider: string;
  provider_deployment_id: string | null;
  provider_url: string | null;
  environment: string;
  status:
    | "not_deployed"
    | "deploying"
    | "healthy"
    | "degraded"
    | "failed"
    | "rolling_back"
    | "rolled_back";
  deployed_at: string | null;
  health_verified_at: string | null;
  failure_reason: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
};

export type NotificationRecord = {
  id: string;
  workspace_id: string;
  project_id: string | null;
  severity: "info" | "warning" | "action_required" | "critical";
  title: string;
  body: string;
  action_url: string | null;
  read_at: string | null;
  created_at: string;
};

export type EventRecord = {
  id: string;
  project_id: string;
  branch_id: string | null;
  event_type: string;
  sequence_number: number;
  actor_id: string | null;
  originating_subsystem: string;
  affected_scope: Record<string, unknown>;
  source_state: string | null;
  target_state: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
};

export type ProjectSnapshot = {
  workspace: {
    id: string;
    name: string;
    slug: string;
  };
  project: {
    id: string;
    name: string;
    slug: string;
    lifecycle_state: string;
    operational_mode: string;
    active_branch_id: string;
    active_graph_version_id: string;
  };
  branch: {
    id: string;
    name: string;
    state: string;
    base_graph_version_id: string;
  };
  currentUser: {
    id: string;
    email: string | null;
    role: WorkspaceRole;
  };
  navigation: {
    global_navigation: string[];
    project_navigation: string[];
    contextual_navigation: string[];
  };
  counts: {
    specifications: number;
    dirty_specs: number;
    nodes: number;
    edges: number;
    approvals: number;
    runs: number;
    open_tasks: number;
  };
  runtimeSource: "supabase";
};

export type GraphPayload = {
  version_id: string;
  version_number: number;
  nodes: GraphNode[];
  edges: GraphEdge[];
};

export type GraphCompileResult = {
  graph_version: GraphVersion;
  validation_group: ValidationGroup;
  approval: Approval;
};

export type ModelCatalogEntry = {
  id: string;
  label: string;
  family: "gpt-5";
  recommended?: boolean;
  description: string;
  source: "openai" | "configured";
};

export type RuntimeHomeData = {
  snapshot: ProjectSnapshot;
  specs: SpecificationDraft[];
  graph: GraphPayload;
  graphVersions: GraphVersion[];
  validationGroups: ValidationGroup[];
  approvals: Approval[];
  executions: ExecutionRun[];
  tasks: ExecutionTask[];
  reconciliations: ReconciliationAttempt[];
  deployments: DeploymentRecord[];
  notifications: NotificationRecord[];
  events: EventRecord[];
};
