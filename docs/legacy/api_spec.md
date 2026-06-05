# sembl v1 — API Specification

**Authority:** Tech Architecture (primary), DB Schema (persistence authority), 24 Locked Derivation Rules  
**Base URL:** `/api/v1`  
**Authentication:** Supabase Auth JWT. All requests require `Authorization: Bearer <token>` header.  
**Content-Type:** `application/json` on all requests and responses unless noted.

---

## Design Conventions

**Resource ownership** flows from Tech Architecture subsystem boundaries. Every endpoint is owned by exactly one subsystem. Subsystem ownership is noted per group.

**Authorization levels** reference workspace roles: `owner`, `admin`, `member`, `viewer`. Where branch-level scoping applies, it is noted explicitly.

**Response envelope:** All responses follow:
```json
{ "data": <payload>, "meta": <pagination | null> }
```
Errors follow:
```json
{ "error": { "code": "<string>", "message": "<string>", "details": <object | null> } }
```

**Pagination:** List endpoints accept `?page=<int>&limit=<int>` (default limit: 50, max: 100). Responses include `meta: { page, limit, total }`.

**Immutability:** Endpoints that operate on immutable records (graph nodes, events, specification revisions, validation violations) expose GET only. No PATCH or DELETE exists for these.

**Realtime:** State-bearing resources publish to Supabase Realtime channels. Channel names are noted per resource. Realtime is a read surface — it never replaces REST for mutations.

---

## API Domain Index

1. Authentication
2. Workspaces
3. Workspace Members
4. Workspace Integrations
5. Projects
6. Specifications
7. Graph
8. Branches
9. Events
10. Validation
11. Approvals
12. Execution
13. Reconciliation
14. Deployments
15. Repository Ingestion
16. Notifications
17. Escalations
18. Realtime Channels

---

## 1. Authentication

**Owner:** Supabase Auth (pass-through — not a sembl subsystem endpoint)

Authentication is fully delegated to Supabase Auth. sembl does not expose custom auth endpoints. Clients use Supabase client libraries to obtain JWTs. The sembl API validates JWTs on every request via Supabase middleware.

Session management, OAuth flows, and token refresh are handled entirely by Supabase Auth.

---

## 2. Workspaces

**Owner:** Workspace Subsystem  
**Realtime channel:** none (workspaces are low-frequency state)

### `GET /workspaces`
Returns all workspaces the authenticated user is a member of.

**Response `data`:** `Workspace[]`
```json
{
  "id": "uuid",
  "name": "string",
  "slug": "string",
  "created_at": "timestamptz"
}
```

---

### `POST /workspaces`
Creates a new workspace. Creator is automatically assigned `owner` role.

**Request body:**
```json
{ "name": "string", "slug": "string" }
```

**Response `data`:** `Workspace`

**Authorization:** Any authenticated user.

---

### `GET /workspaces/:workspace_id`
Returns a single workspace.

**Authorization:** Workspace member (any role).

---

### `PATCH /workspaces/:workspace_id`
Updates workspace name or slug.

**Request body:** `{ "name"?: "string", "slug"?: "string" }`

**Authorization:** `owner` or `admin`.

---

### `DELETE /workspaces/:workspace_id`
Deletes workspace. Requires workspace to have no active projects.

**Authorization:** `owner` only.

---

## 3. Workspace Members

**Owner:** Workspace Subsystem

### `GET /workspaces/:workspace_id/members`
Returns all members of the workspace.

**Response `data`:** `WorkspaceMember[]`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "role": "owner | admin | member | viewer",
  "joined_at": "timestamptz"
}
```

**Authorization:** Workspace member (any role).

---

### `POST /workspaces/:workspace_id/members/invite`
Invites a user by email. Creates a pending `workspace_members` row.

**Request body:**
```json
{ "email": "string", "role": "admin | member | viewer" }
```

**Authorization:** `owner` or `admin`.

---

### `PATCH /workspaces/:workspace_id/members/:member_id`
Changes a member's role.

**Request body:** `{ "role": "admin | member | viewer" }`

**Constraints:** Owners cannot have their role changed via this endpoint. Role change to `owner` is not permitted — ownership transfer is a separate operation.

**Authorization:** `owner` or `admin`. Admins cannot promote to `admin`.

---

### `DELETE /workspaces/:workspace_id/members/:member_id`
Removes a member from the workspace.

**Constraints:** Owners cannot be removed. They must transfer ownership first.

**Authorization:** `owner` or `admin` to remove others. Any member may remove themselves (leave).

---

### `POST /workspaces/:workspace_id/transfer-ownership`
Transfers owner role to another member.

**Request body:** `{ "new_owner_user_id": "uuid" }`

**Authorization:** `owner` only.

---

## 4. Workspace Integrations

**Owner:** Workspace Subsystem

### `GET /workspaces/:workspace_id/integrations`
Returns all integrations for the workspace.

**Response `data`:** `WorkspaceIntegration[]`
```json
{
  "id": "uuid",
  "provider": "github | vercel",
  "external_id": "string",
  "metadata": "object",
  "created_at": "timestamptz"
}
```

**Authorization:** Workspace member (any role).

---

### `POST /workspaces/:workspace_id/integrations`
Connects a new integration. Credentials are handled by provider OAuth — this endpoint persists only the resulting metadata.

**Request body:**
```json
{
  "provider": "github | vercel",
  "external_id": "string",
  "metadata": "object"
}
```

**Authorization:** `owner` or `admin`.

---

### `POST /workspaces/:workspace_id/integrations/:integration_id/verify`
Checks connection health. Does not mutate state. Returns current connectivity status.

**Response `data`:** `{ "healthy": boolean, "checked_at": "timestamptz" }`

**Authorization:** `owner` or `admin`.

---

### `POST /workspaces/:workspace_id/integrations/:integration_id/refresh`
Re-authorizes an existing integration without deleting it.

**Authorization:** `owner` or `admin`.

---

### `DELETE /workspaces/:workspace_id/integrations/:integration_id`
Disconnects the integration. Projects using this integration are not affected — repository references persist but ingestion will fail on next attempt.

**Authorization:** `owner` or `admin`.

---

## 5. Projects

**Owner:** Orchestration Subsystem  
**Realtime channel:** `project:{project_id}` — publishes lifecycle state changes and operational mode changes.

### `GET /workspaces/:workspace_id/projects`
Returns all projects in the workspace visible to the authenticated user.

**Response `data`:** `Project[]`
```json
{
  "id": "uuid",
  "name": "string",
  "slug": "string",
  "lifecycle_state": "draft | ready_for_execution | awaiting_approval | executing | reconciling | deploying | active | escalated",
  "operational_mode": "documentation | execution | iteration",
  "active_branch_id": "uuid | null",
  "active_graph_version_id": "uuid | null",
  "created_by": "uuid",
  "created_at": "timestamptz",
  "updated_at": "timestamptz"
}
```

---

### `POST /workspaces/:workspace_id/projects`
Creates a new project. Initial state: `lifecycle_state: draft`, `operational_mode: documentation`.

**Request body:**
```json
{ "name": "string", "slug": "string" }
```

**Authorization:** `owner`, `admin`, or `member`.

---

### `GET /workspaces/:workspace_id/projects/:project_id`
Returns a single project including derived group state.

**Response `data`:** `Project` with additional computed field:
```json
{
  "group_state": {
    "status": "escalated | blocked | awaiting_action | in_progress | healthy",
    "sub_states": {
      "validation": "string",
      "execution": "string",
      "reconciliation": "string",
      "deployment": "string",
      "approval": "string"
    }
  }
}
```

Group state is computed at read time. It is never persisted. Derivation hierarchy: Escalated → Blocked → Awaiting Action → In Progress → Healthy.

---

### `PATCH /workspaces/:workspace_id/projects/:project_id`
Updates project name, slug, or operational mode.

**Request body:** `{ "name"?: "string", "slug"?: "string", "operational_mode"?: "documentation | execution | iteration" }`

**Constraints:** `lifecycle_state` is never user-settable. It is system-managed.

**Authorization:** `owner` or `admin`.

---

### `DELETE /workspaces/:workspace_id/projects/:project_id`
Deletes project. Only permitted when `lifecycle_state` is `draft`.

**Authorization:** `owner` or `admin`.

---

## 6. Specifications

**Owner:** Specification Subsystem  
**Realtime channel:** `project:{project_id}` — publishes `SpecificationModified` events on publish.

### `GET /projects/:project_id/specifications`
Returns all specification documents for the project (one per type, active revision metadata only).

**Response `data`:** `SpecificationDocument[]`
```json
{
  "id": "uuid",
  "spec_type": "pdd | prd | nfr | uiux | system_design | db_schema | api_spec | tech_architecture",
  "active_revision_id": "uuid | null",
  "has_draft": "boolean",
  "draft_updated_at": "timestamptz | null",
  "updated_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/specifications/:spec_type`
Returns the specification document for the given type, including active revision content.

**Response `data`:** `SpecificationDocument` with:
```json
{
  "active_revision": {
    "id": "uuid",
    "revision_number": "integer",
    "content": "string",
    "content_hash": "string",
    "authored_by": "uuid",
    "created_at": "timestamptz"
  },
  "draft_content": "string | null"
}
```

---

### `PUT /projects/:project_id/specifications/:spec_type/draft`
Saves draft content. Does not create a revision. Does not trigger graph extraction. Overwrites any existing draft for this document.

**Request body:** `{ "content": "string" }`

**Response `data`:** `{ "draft_updated_at": "timestamptz" }`

**Authorization:** `owner`, `admin`, or `member`.

---

### `POST /projects/:project_id/specifications/:spec_type/publish`
Publishes the current draft as a new immutable revision. Clears draft content. Updates `active_revision_id`. Fires `SpecificationModified` event. Triggers automatic validation.

**Request body:** none (publishes current draft)

**Constraints:** Requires non-null `draft_content`. Publishing an empty or unchanged draft is a no-op returning the current active revision.

**Response `data`:** `SpecificationRevision`

**Authorization:** `owner`, `admin`, or `member`.

---

### `GET /projects/:project_id/specifications/:spec_type/revisions`
Returns revision history for the specification document. Content is excluded from list view.

**Response `data`:** `SpecificationRevision[]`
```json
{
  "id": "uuid",
  "revision_number": "integer",
  "content_hash": "string",
  "authored_by": "uuid",
  "parent_revision_id": "uuid | null",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/specifications/:spec_type/revisions/:revision_id`
Returns full content of a specific revision.

**Response `data`:** `SpecificationRevision` with `content` field included.

---

## 7. Graph

**Owner:** Graph Construction Subsystem  
**Write surface:** None. Graph is read-only via API. All mutations arrive through reconciliation.  
**Realtime channel:** `project:{project_id}` — publishes `GraphMutationCommitted` on new version creation.

### `GET /projects/:project_id/graph`
Returns the active graph version's full node and edge set.

**Response `data`:**
```json
{
  "version_id": "uuid",
  "version_number": "integer",
  "nodes": "GraphNode[]",
  "edges": "GraphEdge[]"
}
```

`GraphNode`:
```json
{
  "id": "uuid",
  "node_type": "entity | interface | integration_contract | flow | invariant | execution_boundary",
  "name": "string",
  "payload": "object",
  "source_spec_type": "string | null",
  "created_at": "timestamptz"
}
```

`GraphEdge`:
```json
{
  "id": "uuid",
  "edge_type": "dependency | implements | precedes | triggers | owns | lineage",
  "source_node_id": "uuid",
  "target_node_id": "uuid",
  "metadata": "object"
}
```

---

### `GET /projects/:project_id/graph/versions`
Returns all graph versions for the project (metadata only, no node/edge payloads).

**Response `data`:** `GraphVersion[]`
```json
{
  "id": "uuid",
  "version_number": "integer",
  "parent_version_id": "uuid | null",
  "reconciliation_id": "uuid | null",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/graph/versions/:version_id`
Returns full node and edge set for a specific historical graph version.

---

### `GET /projects/:project_id/graph/versions/:version_id/diff/:target_version_id`
Returns the semantic diff between two graph versions.

**Response `data`:** `SemanticDiff`
```json
{
  "id": "uuid",
  "from_version_id": "uuid",
  "to_version_id": "uuid",
  "diff_payload": {
    "entity_mutations": [],
    "interface_mutations": [],
    "dependency_mutations": [],
    "invariant_mutations": [],
    "flow_mutations": [],
    "execution_boundary_mutations": []
  }
}
```

---

### `GET /projects/:project_id/graph/nodes/:node_id`
Returns a single graph node with its full payload.

---

### `GET /projects/:project_id/graph/nodes/:node_id/subgraph`
Returns the node and its dependency neighborhood. Accepts `?depth=<int>` (default: 2, max: 5).

**Response `data`:** `{ "root_node": GraphNode, "nodes": GraphNode[], "edges": GraphEdge[] }`

---

### `GET /projects/:project_id/graph/nodes/:node_id/lineage`
Returns the lineage chain (ancestry) for a given node across graph versions.

**Response `data`:** `{ "node_id": "uuid", "lineage": [{ "version_number": int, "node_snapshot": GraphNode }] }`

---

## 8. Branches

**Owner:** Branch Subsystem  
**Realtime channel:** `branch:{branch_id}` — publishes branch state changes.

### `GET /projects/:project_id/branches`
Returns all branches for the project.

**Response `data`:** `Branch[]`
```json
{
  "id": "uuid",
  "name": "string",
  "state": "active | diverged | merge_pending | merged | rejected | archived",
  "base_graph_version_id": "uuid",
  "merged_into_version_id": "uuid | null",
  "created_by": "uuid",
  "created_at": "timestamptz",
  "updated_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/branches`
Creates a new branch from the current active graph version. Historical version branching is not supported.

**Request body:** `{ "name": "string" }`

**Constraints:** Branch name must be unique per project. Branch is always created from `active_graph_version_id` of the project. Historical version branching is not supported. Service layer must validate `base_graph_version_id == project.active_graph_version_id` at creation time.

**Response `data`:** `Branch`

**Authorization:** `owner`, `admin`, or `member`.

Fires `BranchCreated` event.

---

### `GET /projects/:project_id/branches/:branch_id`
Returns a single branch including delta count.

**Response `data`:** `Branch` with `{ "delta_count": integer }`

---

### `PATCH /projects/:project_id/branches/:branch_id`
Archives an abandoned branch. Only permitted when `state` is `active` or `rejected`.

**Request body:** `{ "state": "archived" }`

**Constraints:** Only `archived` is a valid user-settable state transition. All other state transitions are system-managed.

**Authorization:** `owner` or `admin`.

---

### `GET /projects/:project_id/branches/:branch_id/deltas`
Returns ordered mutation deltas for the branch.

**Response `data`:** `MutationDelta[]`
```json
{
  "id": "uuid",
  "sequence_number": "integer",
  "operation": "add | modify | remove",
  "target_node_id": "uuid | null",
  "target_edge_id": "uuid | null",
  "payload": "object",
  "created_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/branches/:branch_id/merge`
Requests a merge of this branch into canonical main. Initiates the locked merge sequence: validation → approval → reconciliation → archive.

**Request body:** none

**Constraints:** Branch must be in `active` or `diverged` state. Branch must have at least one delta.

**Response `data`:** `MergeAttempt`
```json
{
  "id": "uuid",
  "source_branch_id": "uuid",
  "status": "pending",
  "requested_by": "uuid",
  "created_at": "timestamptz"
}
```

**Authorization:** `owner`, `admin`, or `member`.

Fires `MergeRequested` event. Automatic validation triggered immediately.

---

### `GET /projects/:project_id/branches/:branch_id/merge`
Returns the current or most recent merge attempt for this branch.

**Response `data`:** `MergeAttempt`
```json
{
  "id": "uuid",
  "status": "pending | validating | conflict_detected | resolving | approved | reconciling | completed | failed | rejected",
  "conflict_payload": "object | null",
  "resolution_payload": "object | null",
  "requested_by": "uuid",
  "created_at": "timestamptz",
  "updated_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/branches/:branch_id/merge/resolve`
Submits conflict resolution payload for a merge in `conflict_detected` state.

**Request body:** `{ "resolution_payload": "object" }`

**Constraints:** Only valid when merge status is `conflict_detected`.

**Authorization:** `owner` or `admin`.

---

## 9. Events

**Owner:** Orchestration Subsystem  
**Write surface:** None. Events are append-only and system-generated. No user-facing create endpoint exists.

### `GET /projects/:project_id/events`
Returns the project event log in sequence order.

**Query params:** `?branch_id=<uuid>`, `?event_type=<string>`, `?from_sequence=<int>`, `?limit=<int>`

**Response `data`:** `Event[]`
```json
{
  "id": "uuid",
  "event_type": "string",
  "sequence_number": "integer",
  "actor_id": "uuid | null",
  "originating_subsystem": "string",
  "affected_scope": "object",
  "source_state": "string | null",
  "target_state": "string | null",
  "metadata": "object",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/events/:event_id`
Returns a single event.

---

## 10. Validation

**Owner:** Validation Subsystem  
**Realtime channel:** `project:{project_id}` — publishes `ValidationPassed`, `ValidationFailed` events.

### `POST /projects/:project_id/validations`
Triggers a manual validation run against the project's active branch and active specification revision.

**Request body:** `{ "branch_id": "uuid" }`

**Response `data`:** `ValidationRunGroup`
```json
{
  "id": "uuid",
  "target_type": "specification",
  "target_id": "uuid",
  "status": "running",
  "triggered_by_event_id": "uuid | null",
  "created_at": "timestamptz"
}
```

**Authorization:** `owner`, `admin`, or `member`.

Fires `ValidationTriggered` event.

---

### `GET /projects/:project_id/validations`
Returns validation run groups for the project. Filterable by `target_type` and `status`.

**Query params:** `?target_type=<string>`, `?status=<string>`, `?branch_id=<uuid>`

**Response `data`:** `ValidationRunGroup[]`

---

### `GET /projects/:project_id/validations/:group_id`
Returns a validation run group with all pass rows and their violations.

**Response `data`:**
```json
{
  "id": "uuid",
  "target_type": "string",
  "target_id": "uuid",
  "status": "running | passed | passed_with_warnings | failed",
  "completed_at": "timestamptz | null",
  "passes": [
    {
      "id": "uuid",
      "pass_number": 1,
      "status": "string",
      "violations": "ValidationViolation[]"
    }
  ]
}
```

`ValidationViolation`:
```json
{
  "id": "uuid",
  "invariant_id": "string",
  "affected_node_id": "uuid | null",
  "affected_scope": "object",
  "severity": "blocking | warning | informational | escalated",
  "message": "string",
  "remediation_path": "string | null"
}
```

---

## 11. Approvals

**Owner:** Orchestration Subsystem  
**Realtime channel:** `project:{project_id}` — publishes approval state changes.

Approvals are system-created only. No user-facing create endpoint exists.

### `GET /projects/:project_id/approvals`
Returns approvals for the project. Filterable by status and type.

**Query params:** `?status=<string>`, `?approval_type=<string>`, `?branch_id=<uuid>`

**Response `data`:** `Approval[]`
```json
{
  "id": "uuid",
  "approval_type": "execution_approval | mutation_approval | merge_approval",
  "status": "pending | under_review | approved | rejected | expired",
  "requested_by": "uuid",
  "reviewed_by": "uuid | null",
  "affected_scope": "object",
  "mutation_summary": "object",
  "expires_at": "timestamptz",
  "decided_at": "timestamptz | null",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/approvals/:approval_id`
Returns a single approval.

---

### `POST /projects/:project_id/approvals/:approval_id/approve`
Approves an approval. Only valid when status is `pending` or `under_review` and not expired.

**Request body:** none

**Response `data`:** `Approval` with updated status.

**Authorization:** `owner` or `admin`.

Fires `GraphMutationApproved` or `ExecutionApproved` or `MergeApproved` depending on type.

---

### `POST /projects/:project_id/approvals/:approval_id/reject`
Rejects an approval.

**Request body:** `{ "reason": "string" }`

**Authorization:** `owner` or `admin`.

Fires `GraphMutationRejected`.

---

## 12. Execution

**Owner:** Execution Subsystem  
**Realtime channel:** `project:{project_id}` and `branch:{branch_id}` — publishes execution status changes.

### `GET /projects/:project_id/executions`
Returns execution runs for the project.

**Query params:** `?branch_id=<uuid>`, `?status=<string>`

**Response `data`:** `ExecutionRun[]`
```json
{
  "id": "uuid",
  "branch_id": "uuid",
  "graph_version_id": "uuid",
  "approval_id": "uuid | null",
  "status": "queued | preparing | running | validating | reconciling | completed | failed | escalated",
  "triggered_by": "uuid | null",
  "started_at": "timestamptz | null",
  "completed_at": "timestamptz | null",
  "failure_reason": "string | null",
  "created_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/executions`
Triggers execution on a branch. Requires a valid non-expired `execution_approval` for the branch.

**Request body:** `{ "branch_id": "uuid", "approval_id": "uuid" }`

**Constraints:** Execution is manual-only. Approval is required. Maximum 3 total execution runs per branch execution lineage before automatic escalation. An execution lineage is the chain of runs originating from the same initial execution trigger on a branch.

**Response `data`:** `ExecutionRun`

**Authorization:** `owner` or `admin`.

Fires `ExecutionStarted` event.

---

### `GET /projects/:project_id/executions/:run_id`
Returns a single execution run.

---

### `GET /projects/:project_id/executions/:run_id/tasks`
Returns all tasks within an execution run in DAG order.

**Response `data`:** `ExecutionTask[]`
```json
{
  "id": "uuid",
  "execution_boundary_node_id": "uuid | null",
  "sequence_number": "integer",
  "status": "pending | running | completed | failed | skipped",
  "dependency_task_ids": "uuid[]",
  "output_payload": "object",
  "started_at": "timestamptz | null",
  "completed_at": "timestamptz | null",
  "failure_reason": "string | null"
}
```

Note: `context_payload` is not present. Execution context is generated at runtime and is never persisted.

---

### `POST /projects/:project_id/executions/:run_id/retry`
Retries a failed execution run. Two modes available.

**Request body:** `{ "mode": "full | from_failed_task" }`

- `full`: Creates a new execution run referencing the same branch and graph version.
- `from_failed_task`: Creates a new execution run with previously completed tasks pre-satisfied.

**Constraints:** Requires valid non-expired approval. Max 3 total runs per branch execution lineage. Fires `ExecutionApprovalRequested` if approval has expired.

**Authorization:** `owner` or `admin`.

---

## 13. Reconciliation

**Owner:** Reconciliation Subsystem  
**Write surface:** Reconciliation is automatic-only. No user-facing trigger endpoint exists.  
**Realtime channel:** `project:{project_id}` — publishes reconciliation status changes.

### `GET /projects/:project_id/reconciliations`
Returns reconciliation attempts for the project.

**Query params:** `?branch_id=<uuid>`, `?status=<string>`

**Response `data`:** `ReconciliationAttempt[]`
```json
{
  "id": "uuid",
  "branch_id": "uuid | null",
  "execution_run_id": "uuid | null",
  "merge_attempt_id": "uuid | null",
  "status": "pending | snapshot_taken | diff_generated | invariant_validated | lineage_updated | committed | failed | rolled_back",
  "snapshot_version_id": "uuid | null",
  "output_version_id": "uuid | null",
  "semantic_diff_id": "uuid | null",
  "failure_reason": "string | null",
  "started_at": "timestamptz | null",
  "committed_at": "timestamptz | null",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/reconciliations/:reconciliation_id`
Returns a single reconciliation attempt including its semantic diff.

---

**Rollback behavior:** Rollback exists only during a failed reconciliation. It is automatic — the Reconciliation Subsystem restores the pre-reconciliation snapshot. There is no user-facing rollback endpoint. Historical graph version restoration is not supported in v1. Recovery from an unwanted graph state is achieved forward — through specification changes on a new branch, followed by reconciliation producing a new graph version.

---

## 14. Deployments

**Owner:** Deployment Subsystem  
**Realtime channel:** `project:{project_id}` — publishes deployment status changes.

### `GET /projects/:project_id/deployments`
Returns deployments for the project.

**Query params:** `?branch_id=<uuid>`, `?status=<string>`, `?environment=<string>`

**Response `data`:** `Deployment[]`
```json
{
  "id": "uuid",
  "branch_id": "uuid",
  "graph_version_id": "uuid",
  "execution_run_id": "uuid | null",
  "provider": "string",
  "provider_deployment_id": "string | null",
  "provider_url": "string | null",
  "environment": "string",
  "status": "not_deployed | deploying | healthy | degraded | failed | rolling_back | rolled_back",
  "previous_deployment_id": "uuid | null",
  "triggered_by": "uuid | null",
  "deployed_at": "timestamptz | null",
  "health_verified_at": "timestamptz | null",
  "failure_reason": "string | null",
  "created_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/deployments`
Triggers a deployment. The project must be in a deployable state (reconciliation committed, no active execution).

**Request body:**
```json
{
  "branch_id": "uuid",
  "graph_version_id": "uuid",
  "environment": "production | staging"
}
```

**Constraints:** Deployment is manual-only. Only one active deployment per environment per project.

**Authorization:** `owner` or `admin`.

Fires `DeploymentStarted` event.

---

### `GET /projects/:project_id/deployments/:deployment_id`
Returns a single deployment.

---

### `POST /projects/:project_id/deployments/:deployment_id/rollback`
Rolls back to the previous healthy deployment reference at the infrastructure level. Does not modify graph state.

**Constraints:** Only valid when deployment status is `failed` or `degraded`. Targets `previous_deployment_id`.

**Authorization:** `owner` or `admin`.

Fires `DeploymentRolledBack` event recording both failed deployment ID and restored deployment ID.

---

## 15. Repository Ingestion

**Owner:** Repository Ingestion Subsystem  
**Realtime channel:** `project:{project_id}` — publishes ingestion status changes.

### `GET /projects/:project_id/repository-references`
Returns all repository references attached to the project.

**Response `data`:** `RepositoryReference[]`
```json
{
  "id": "uuid",
  "provider": "github",
  "external_url": "string",
  "external_id": "string",
  "default_branch": "string",
  "created_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/repository-references`
Attaches a repository reference to the project. Repository must be accessible via an existing workspace integration.

**Request body:**
```json
{
  "provider": "github",
  "external_url": "string",
  "external_id": "string",
  "default_branch": "string"
}
```

**Authorization:** `owner` or `admin`.

---

### `DELETE /projects/:project_id/repository-references/:ref_id`
Detaches a repository reference. Active ingestion runs must be complete before detachment.

**Authorization:** `owner` or `admin`.

---

### `GET /projects/:project_id/ingestions`
Returns ingestion runs for the project.

**Response `data`:** `RepositoryIngestionRun[]`
```json
{
  "id": "uuid",
  "repository_reference_id": "uuid",
  "status": "connected | analyzing | reconstructing | confidence_review | validating | ready_for_activation | activated | failed",
  "output_graph_version_id": "uuid | null",
  "failure_reason": "string | null",
  "started_at": "timestamptz | null",
  "activated_at": "timestamptz | null",
  "created_at": "timestamptz"
}
```

---

### `POST /projects/:project_id/ingestions`
Starts an ingestion run from an attached repository reference.

**Request body:** `{ "repository_reference_id": "uuid" }`

**Constraints:** Repository reference must be attached to this project. Only one active ingestion run per project at a time.

**Authorization:** `owner` or `admin`.

Fires `RepositoryIngestionStarted` event.

---

### `GET /projects/:project_id/ingestions/:ingestion_id`
Returns a single ingestion run.

---

### `GET /projects/:project_id/ingestions/:ingestion_id/confidence-items`
Returns confidence items for review. Filterable by status and confidence level.

**Query params:** `?status=pending | confirmed | rejected | escalated`, `?confidence_level=high | medium | low`

**Response `data`:** `IngestionConfidenceItem[]`
```json
{
  "id": "uuid",
  "node_type": "string",
  "confidence_level": "high | medium | low",
  "confidence_score": "number",
  "proposed_payload": "object",
  "status": "pending | confirmed | rejected | escalated",
  "resolved_by": "uuid | null",
  "resolved_at": "timestamptz | null"
}
```

---

### `PATCH /projects/:project_id/ingestions/:ingestion_id/confidence-items/:item_id`
Confirms or rejects a confidence item.

**Request body:** `{ "status": "confirmed | rejected" }`

**Constraints:** Only `confirmed` and `rejected` are user-settable. `escalated` is system-set.

**Authorization:** `owner`, `admin`, or `member`.

---

### `POST /projects/:project_id/ingestions/:ingestion_id/activate`
Activates the ingestion run, canonicalizing confirmed structures into a new graph version. Only valid when status is `ready_for_activation` (no pending confidence items remain).

**Constraints:** All confidence items must be in terminal state (confirmed, rejected, or escalated). Any unresolved `escalated` items block activation.

**Authorization:** `owner` or `admin`.

Fires `RepositoryIngestionCompleted` event. Triggers automatic reconciliation.

---

## 16. Notifications

**Owner:** Orchestration Subsystem  
**Realtime channel:** `notifications:{user_id}` — publishes new notifications in real time.

Notifications are system-created only. No user-facing create endpoint exists.

### `GET /notifications`
Returns notifications for the authenticated user across all workspaces.

**Query params:** `?workspace_id=<uuid>`, `?project_id=<uuid>`, `?unread_only=true`, `?severity=info | warning | action_required | critical`

**Response `data`:** `Notification[]`
```json
{
  "id": "uuid",
  "workspace_id": "uuid",
  "project_id": "uuid | null",
  "event_id": "uuid | null",
  "severity": "info | warning | action_required | critical",
  "title": "string",
  "body": "string",
  "action_url": "string | null",
  "read_at": "timestamptz | null",
  "created_at": "timestamptz"
}
```

---

### `POST /notifications/:notification_id/read`
Marks a single notification as read.

**Response `data`:** `{ "read_at": "timestamptz" }`

---

### `POST /notifications/read-all`
Marks all unread notifications for the authenticated user as read. Accepts optional `workspace_id` or `project_id` filter.

**Request body:** `{ "workspace_id"?: "uuid", "project_id"?: "uuid" }`

**Response `data`:** `{ "marked_count": "integer" }`

---

## 17. Escalations

**Owner:** Orchestration Subsystem

Escalations are system-created only. User interaction is limited to resolution.

### `GET /projects/:project_id/escalations`
Returns escalations for the project.

**Query params:** `?status=open | in_resolution | resolved | closed`

**Response `data`:** `Escalation[]`
```json
{
  "id": "uuid",
  "branch_id": "uuid | null",
  "trigger_type": "repeated_validation_failure | repeated_reconciliation_failure | unresolved_merge_conflict | repository_reconstruction_failure | unresolved_ambiguity",
  "trigger_event_id": "uuid | null",
  "status": "open | in_resolution | resolved | closed",
  "affected_scope": "object",
  "resolution_notes": "string | null",
  "resolved_by": "uuid | null",
  "resolved_at": "timestamptz | null",
  "created_at": "timestamptz"
}
```

---

### `GET /projects/:project_id/escalations/:escalation_id`
Returns a single escalation.

---

### `PATCH /projects/:project_id/escalations/:escalation_id`
Updates escalation status and resolution notes.

**Request body:** `{ "status": "in_resolution | resolved | closed", "resolution_notes"?: "string" }`

**Authorization:** `owner` or `admin`.

---

## 18. Realtime Channels

**Owner:** Orchestration Subsystem  
**Transport:** Supabase Realtime (WebSocket)  
**Authorization:** Mirrors RLS policy. Users may only subscribe to projects and branches they have access to.

### Channel Definitions

| Channel | Pattern | Publishes |
|---|---|---|
| Project | `project:{project_id}` | Lifecycle state changes, validation events, execution events, reconciliation events, deployment events, specification events, graph version events |
| Branch | `branch:{branch_id}` | Branch state changes, delta additions, merge status changes |
| Notifications | `notifications:{user_id}` | New notifications for the user |

### Event Payload on Realtime

Every realtime message follows:
```json
{
  "event": "<event_type from events table>",
  "project_id": "uuid",
  "branch_id": "uuid | null",
  "sequence_number": "integer",
  "affected_scope": "object",
  "source_state": "string | null",
  "target_state": "string | null",
  "timestamp": "timestamptz"
}
```

Realtime is a read surface only. It never replaces REST for mutations. Clients must use REST endpoints to act on received realtime events.

### Subscription Authorization

Clients subscribe using Supabase client libraries. Channel access is validated against the authenticated user's workspace membership and project access. Unauthorized subscription attempts are silently rejected.

---

## Error Reference

| Code | Meaning |
|---|---|
| `unauthorized` | No valid JWT or insufficient role |
| `not_found` | Resource does not exist or is not visible to user |
| `invalid_state` | Operation not permitted given current resource state |
| `validation_required` | Operation blocked until active validation violations are resolved |
| `approval_required` | Operation requires a valid non-expired approval |
| `approval_expired` | Referenced approval has passed its TTL |
| `immutable_resource` | Attempt to mutate a write-once resource |
| `conflict_detected` | Merge conflict requires resolution before proceeding |
| `max_retries_exceeded` | Execution run lineage limit (3) reached on this branch — escalation triggered |
| `escalation_active` | Operation blocked by an open escalation on this project or branch |
| `ingestion_active` | Operation blocked by an active ingestion run |
| `draft_required` | Publish attempted with no draft content present |

---

*END OF API SPECIFICATION*