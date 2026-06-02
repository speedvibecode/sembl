# sembl v1 — Database Schema
**Version:** Post-Review, Ready For Lock  
**Authority:** Tech Architecture (primary), System Design, NFR, V4.3 Formal Specification  
**Persistence target:** Supabase / PostgreSQL

---

## Schema Design Principles

**Canonical persistence** includes: specifications, graph state, graph versions, events, lineage, branches, mutation deltas, validation outputs, approvals, deployment references, and repository references.

**Canonical graph state** is the authoritative operational state for system behavior. It is a subset of canonical persistence. Approvals, events, notifications, and deployments are canonical persistence without being canonical graph state. This distinction governs authority — not storage.

All primary keys are `uuid` generated via `gen_random_uuid()`.

All timestamps are `timestamptz` stored in UTC.

Immutable records (graph versions, events, specification revisions, graph nodes, graph edges, semantic diffs, mutation deltas, validation violations) carry no `updated_at` column. Application-layer and RLS policies prohibit UPDATE and DELETE on these tables for all roles.

Soft deletion is not used for canonical state. Canonical records are permanently retained.

`project_id` is present on all project-scoped tables. `workspace_id` is present on workspace-level tables.

Row-Level Security (RLS) is enforced via Supabase Auth. Every table carries workspace or project scoping for policy evaluation.

JSONB is used for mutation payloads, metadata, and fields whose internal structure is defined by graph semantics rather than relational constraints.

Group state has no column anywhere in this schema. It is derived at read time from sub-states and is never persisted.

Execution context payloads are generated at runtime by the Planner Module and are never persisted. They are discarded after task completion.

---

## Domain Index

1. Identity and Workspace
2. Project and Lifecycle
3. Specifications
4. Graph — Nodes and Edges
5. Graph Versions and Lineage
6. Branches and Mutation Deltas
7. Events
8. Validation
9. Approvals
10. Execution Runs
11. Reconciliation
12. Deployment
13. Repository Ingestion
14. Notifications and Activity

---

## 1. Identity and Workspace

### `workspaces`

```sql
CREATE TABLE workspaces (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

### `workspace_members`

Roles are workspace-scoped. Authorization inheritance flows Workspace → Project → Branch → Execution.

```sql
CREATE TYPE workspace_role AS ENUM (
  'owner',
  'admin',
  'member',
  'viewer'
);

CREATE TABLE workspace_members (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id  uuid NOT NULL REFERENCES workspaces(id),
  user_id       uuid NOT NULL REFERENCES auth.users(id),
  role          workspace_role NOT NULL DEFAULT 'member',
  joined_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE(workspace_id, user_id)
);
```

### `workspace_integrations`

Stores external provider references. Credentials are never persisted here — only integration metadata.

```sql
CREATE TABLE workspace_integrations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id  uuid NOT NULL REFERENCES workspaces(id),
  provider      text NOT NULL,  -- 'github' | 'vercel'
  external_id   text NOT NULL,
  metadata      jsonb NOT NULL DEFAULT '{}',
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
```

---

## 2. Project and Lifecycle

### `projects`

Every project belongs to exactly one workspace. Projects carry the primary lifecycle state. Group state is derived at read time and is never stored here.

```sql
CREATE TYPE project_lifecycle_state AS ENUM (
  'draft',
  'ready_for_execution',
  'awaiting_approval',
  'executing',
  'reconciling',
  'deploying',
  'active',
  'escalated'
);

CREATE TYPE operational_mode AS ENUM (
  'documentation',
  'execution',
  'iteration'
);

CREATE TABLE projects (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id            uuid NOT NULL REFERENCES workspaces(id),
  name                    text NOT NULL,
  slug                    text NOT NULL,
  lifecycle_state         project_lifecycle_state NOT NULL DEFAULT 'draft',
  operational_mode        operational_mode NOT NULL DEFAULT 'documentation',
  active_branch_id        uuid,   -- FK added after branches table is created
  active_graph_version_id uuid,   -- FK added after graph_versions table is created
  created_by              uuid NOT NULL REFERENCES auth.users(id),
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),
  UNIQUE(workspace_id, slug)
);
```

### `repository_references`

Projects may reference multiple repositories. Repositories are external artifacts and never become canonical state.

```sql
CREATE TABLE repository_references (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id      uuid NOT NULL REFERENCES projects(id),
  provider        text NOT NULL DEFAULT 'github',
  external_url    text NOT NULL,
  external_id     text NOT NULL,
  default_branch  text NOT NULL DEFAULT 'main',
  metadata        jsonb NOT NULL DEFAULT '{}',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
```

---

## 3. Specifications

Specifications follow a draft/publish model. Draft content is mutable and persisted on `specification_documents`. Publishing creates an immutable revision. Previous revisions are permanently retained. The project references the active revision per document. Only published revisions are eligible for graph extraction.

### `specification_documents`

One record per document type per project. Acts as the specification identity container.

```sql
CREATE TYPE specification_type AS ENUM (
  'pdd',
  'prd',
  'nfr',
  'uiux',
  'system_design',
  'db_schema',
  'api_spec',
  'tech_architecture'
);

CREATE TABLE specification_documents (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  spec_type           specification_type NOT NULL,
  active_revision_id  uuid,         -- FK added after specification_revisions is created
  draft_content       text,         -- mutable working state, never enters graph extraction
  draft_updated_at    timestamptz,  -- set on every autosave, null if no unpublished draft exists
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE(project_id, spec_type)
);
-- draft_content is cleared on publish. active_revision_id is always system-set on publish, never user-set.
-- Draft content never influences graph state. Only published revisions are eligible for graph extraction.
```

### `specification_revisions`

Immutable after insert. Created on publish only. Draft content never produces a revision. Previous revisions are never deleted.

```sql
CREATE TABLE specification_revisions (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id         uuid NOT NULL REFERENCES specification_documents(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  revision_number     integer NOT NULL,
  content             text NOT NULL,
  content_hash        text NOT NULL,
  authored_by         uuid NOT NULL REFERENCES auth.users(id),
  parent_revision_id  uuid REFERENCES specification_revisions(id),
  created_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE(document_id, revision_number)
  -- No updated_at. Immutable after insert.
);

ALTER TABLE specification_documents
  ADD CONSTRAINT fk_active_revision
  FOREIGN KEY (active_revision_id)
  REFERENCES specification_revisions(id);
```

---

## 4. Graph — Nodes and Edges

The canonical graph is implemented as a relational graph projection within Supabase/Postgres. No graph database exists. Graph semantics are fully preserved through node and edge tables.

Node types follow System Design §1.1 and §3.2. Feature is not extracted as a graph node (System Design §3.2 explicitly excludes it).

### `graph_nodes`

```sql
CREATE TYPE graph_node_type AS ENUM (
  'entity',
  'interface',
  'integration_contract',
  'flow',
  'invariant',
  'execution_boundary'
);

CREATE TABLE graph_nodes (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  graph_version_id    uuid NOT NULL,   -- FK added after graph_versions is created
  node_type           graph_node_type NOT NULL,
  name                text NOT NULL,
  payload             jsonb NOT NULL DEFAULT '{}',
  source_spec_type    specification_type,
  source_revision_id  uuid REFERENCES specification_revisions(id),
  created_at          timestamptz NOT NULL DEFAULT now()
  -- No updated_at. Immutable after insert.
);
```

**Payload structure by node type:**

| Node Type | Required payload fields |
|---|---|
| `entity` | `fields: { field_name: type }` |
| `interface` | `input, output, preconditions, postconditions, success_example, failure_examples` |
| `integration_contract` | `steps: [{ interface_id, input_mapping }], error_handling, transaction` |
| `flow` | `integration_contract_ids: []` |
| `invariant` | `rule, scope, severity` |
| `execution_boundary` | `included_node_ids: [], dependency_scope` |

### `graph_edges`

```sql
CREATE TYPE graph_edge_type AS ENUM (
  'dependency',
  'implements',
  'precedes',
  'triggers',
  'owns',
  'lineage'
);

CREATE TABLE graph_edges (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  graph_version_id  uuid NOT NULL,   -- FK added after graph_versions is created
  edge_type         graph_edge_type NOT NULL,
  source_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  target_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  metadata          jsonb NOT NULL DEFAULT '{}',
  created_at        timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  CHECK (source_node_id != target_node_id)
);
```

---

## 5. Graph Versions and Lineage

Graph versions are immutable and permanently retained. Every successful reconciliation creates a new version. Deletion is prohibited.

### `graph_versions`

```sql
CREATE TABLE graph_versions (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id               uuid NOT NULL REFERENCES projects(id),
  version_number           integer NOT NULL,
  parent_version_id        uuid REFERENCES graph_versions(id),
  reconciliation_id        uuid,   -- FK added after reconciliation_attempts is created
  source_spec_revision_id  uuid REFERENCES specification_revisions(id),
  semantic_diff_id         uuid,   -- FK added after semantic_diffs is created
  created_at               timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  UNIQUE(project_id, version_number)
);

-- Add FK references back from projects
ALTER TABLE projects
  ADD CONSTRAINT fk_active_graph_version
  FOREIGN KEY (active_graph_version_id)
  REFERENCES graph_versions(id);

-- Add FK references from nodes and edges
ALTER TABLE graph_nodes
  ADD CONSTRAINT fk_graph_version
  FOREIGN KEY (graph_version_id)
  REFERENCES graph_versions(id);

ALTER TABLE graph_edges
  ADD CONSTRAINT fk_graph_version
  FOREIGN KEY (graph_version_id)
  REFERENCES graph_versions(id);
```

### `semantic_diffs`

Every reconciliation produces a semantic diff. Diffs are lineage-addressable and immutable.

```sql
CREATE TABLE semantic_diffs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id      uuid NOT NULL REFERENCES projects(id),
  from_version_id uuid REFERENCES graph_versions(id),
  to_version_id   uuid REFERENCES graph_versions(id),
  diff_payload    jsonb NOT NULL DEFAULT '{}',
  -- payload structure:
  -- {
  --   entity_mutations: [],
  --   interface_mutations: [],
  --   dependency_mutations: [],
  --   invariant_mutations: [],
  --   flow_mutations: [],
  --   execution_boundary_mutations: []
  -- }
  created_at      timestamptz NOT NULL DEFAULT now()
  -- No updated_at. Immutable after insert.
);

ALTER TABLE graph_versions
  ADD CONSTRAINT fk_semantic_diff
  FOREIGN KEY (semantic_diff_id)
  REFERENCES semantic_diffs(id);
```

---

## 6. Branches and Mutation Deltas

Branches store identity, base version reference, and ordered mutation deltas only. No graph snapshots are stored per branch. Branch state is reconstructed at runtime as: Base Graph Version + Ordered Delta Application.

### `branches`

```sql
CREATE TYPE branch_state AS ENUM (
  'active',
  'diverged',
  'merge_pending',
  'merged',
  'rejected',
  'archived'
);

CREATE TABLE branches (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  name                    text NOT NULL,
  base_graph_version_id   uuid NOT NULL REFERENCES graph_versions(id),
  state                   branch_state NOT NULL DEFAULT 'active',
  merged_into_version_id  uuid REFERENCES graph_versions(id),
  created_by              uuid NOT NULL REFERENCES auth.users(id),
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),
  UNIQUE(project_id, name)
);

ALTER TABLE projects
  ADD CONSTRAINT fk_active_branch
  FOREIGN KEY (active_branch_id)
  REFERENCES branches(id);
```

### `mutation_deltas`

Each delta represents one atomic graph mutation within a branch. Deltas are ordered and immutable. Sequence number is branch-local.

```sql
CREATE TYPE delta_operation AS ENUM (
  'add',
  'modify',
  'remove'
);

CREATE TABLE mutation_deltas (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id           uuid NOT NULL REFERENCES branches(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  sequence_number     integer NOT NULL,
  operation           delta_operation NOT NULL,
  target_node_id      uuid REFERENCES graph_nodes(id),
  target_edge_id      uuid REFERENCES graph_edges(id),
  payload             jsonb NOT NULL DEFAULT '{}',
  triggering_event_id uuid,   -- FK added after events is created
  created_at          timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  UNIQUE(branch_id, sequence_number)
);
```

### `merge_attempts`

```sql
CREATE TYPE merge_status AS ENUM (
  'pending',
  'validating',
  'conflict_detected',
  'resolving',
  'approved',
  'reconciling',
  'completed',
  'failed',
  'rejected'
);

CREATE TABLE merge_attempts (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  source_branch_id    uuid NOT NULL REFERENCES branches(id),
  target_branch_id    uuid REFERENCES branches(id),   -- null = merge into canonical main
  status              merge_status NOT NULL DEFAULT 'pending',
  conflict_payload    jsonb,
  resolution_payload  jsonb,
  requested_by        uuid NOT NULL REFERENCES auth.users(id),
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);
```

---

## 7. Events

Events are immutable and append-only. Project-scoped with monotonically increasing sequence numbers. No event may be updated or deleted. Timestamps are informational only — sequence number is the ordering authority.

### `events`

```sql
CREATE TYPE event_type AS ENUM (
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

CREATE TABLE events (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  event_type              event_type NOT NULL,
  sequence_number         bigint NOT NULL,
  actor_id                uuid REFERENCES auth.users(id),
  originating_subsystem   text NOT NULL,
  affected_scope          jsonb NOT NULL DEFAULT '{}',
  source_state            text,
  target_state            text,
  metadata                jsonb NOT NULL DEFAULT '{}',
  created_at              timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  UNIQUE(project_id, sequence_number)
);

ALTER TABLE mutation_deltas
  ADD CONSTRAINT fk_triggering_event
  FOREIGN KEY (triggering_event_id)
  REFERENCES events(id);
```

---

## 8. Validation

Validation runs are grouped by a logical validation run group. Each group produces three passes (structural, semantic, consistency). The group carries the aggregate result. Individual pass rows carry pass-level detail.

### `validation_run_groups`

One group per logical validation operation. Carries aggregate status.

```sql
CREATE TYPE validation_target_type AS ENUM (
  'specification',
  'execution_run',
  'reconciliation_attempt',
  'merge_attempt',
  'repository_ingestion'
);

CREATE TYPE validation_group_status AS ENUM (
  'running',
  'passed',
  'passed_with_warnings',
  'failed'
);

CREATE TABLE validation_run_groups (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  target_type             validation_target_type NOT NULL,
  target_id               uuid NOT NULL,
  status                  validation_group_status NOT NULL DEFAULT 'running',
  triggered_by_event_id   uuid REFERENCES events(id),
  completed_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now()
);
```

### `validation_runs`

One row per pass within a group. Pass 1 = Structural, Pass 2 = Semantic, Pass 3 = Consistency.

```sql
CREATE TYPE validation_run_status AS ENUM (
  'running',
  'passed',
  'passed_with_warnings',
  'failed'
);

CREATE TABLE validation_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id          uuid NOT NULL REFERENCES validation_run_groups(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  pass_number       integer NOT NULL CHECK (pass_number IN (1, 2, 3)),
  status            validation_run_status NOT NULL DEFAULT 'running',
  completed_at      timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE(group_id, pass_number)
);
```

### `validation_violations`

Violations are immutable after creation. Correction occurs through subsequent validation runs, not by modifying existing violations.

```sql
CREATE TYPE violation_severity AS ENUM (
  'blocking',
  'warning',
  'informational',
  'escalated'
);

CREATE TABLE validation_violations (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  validation_run_id   uuid NOT NULL REFERENCES validation_runs(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  invariant_id        text NOT NULL,  -- e.g. 'I1', 'C2', 'E3' per V4.3 §3
  affected_node_id    uuid REFERENCES graph_nodes(id),
  affected_scope      jsonb NOT NULL DEFAULT '{}',
  severity            violation_severity NOT NULL,
  message             text NOT NULL,
  remediation_path    text,
  created_at          timestamptz NOT NULL DEFAULT now()
  -- No updated_at. Immutable after insert.
);
```

---

## 9. Approvals

Approvals are canonical persistence but not canonical graph state. They are workflow objects owned by the Orchestration Subsystem. Approval state never supersedes graph authority.

```sql
CREATE TYPE approval_type AS ENUM (
  'execution_approval',
  'mutation_approval',
  'merge_approval'
);

CREATE TYPE approval_status AS ENUM (
  'pending',
  'under_review',
  'approved',
  'rejected',
  'expired'
);

CREATE TABLE approvals (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  branch_id           uuid REFERENCES branches(id),
  approval_type       approval_type NOT NULL,
  status              approval_status NOT NULL DEFAULT 'pending',
  requested_by        uuid NOT NULL REFERENCES auth.users(id),
  reviewed_by         uuid REFERENCES auth.users(id),
  affected_scope      jsonb NOT NULL DEFAULT '{}',
  mutation_summary    jsonb NOT NULL DEFAULT '{}',
  triggering_event_id uuid REFERENCES events(id),
  expires_at          timestamptz NOT NULL,
  decided_at          timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);
```

**Expiry TTLs (enforced at application layer by Orchestration Subsystem):**

| Approval Type | TTL |
|---|---|
| `execution_approval` | 24 hours |
| `mutation_approval` | 7 days |
| `merge_approval` | 7 days |

Expired approvals become invalid. Associated workflows pause and require resubmission.

---

## 10. Execution Runs

Execution attaches to branches. Execution never operates directly against canonical graph state. Execution context is generated at runtime by the Planner Module and is not persisted.

### `execution_runs`

```sql
CREATE TYPE execution_run_status AS ENUM (
  'queued',
  'preparing',
  'running',
  'validating',
  'reconciling',
  'completed',
  'failed',
  'escalated'
);

CREATE TABLE execution_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid NOT NULL REFERENCES branches(id),
  graph_version_id  uuid NOT NULL REFERENCES graph_versions(id),
  approval_id       uuid REFERENCES approvals(id),
  status            execution_run_status NOT NULL DEFAULT 'queued',
  triggered_by      uuid REFERENCES auth.users(id),
  started_at        timestamptz,
  completed_at      timestamptz,
  failure_reason    text,
  metadata          jsonb NOT NULL DEFAULT '{}',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
```

### `execution_tasks`

Individual DAG tasks within an execution run. Each task maps to an Execution Boundary node. Execution context is not stored — only the output produced by the task.

```sql
CREATE TYPE task_status AS ENUM (
  'pending',
  'running',
  'completed',
  'failed',
  'skipped'
);

CREATE TABLE execution_tasks (
  id                           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  execution_run_id             uuid NOT NULL REFERENCES execution_runs(id),
  project_id                   uuid NOT NULL REFERENCES projects(id),
  execution_boundary_node_id   uuid REFERENCES graph_nodes(id),
  sequence_number              integer NOT NULL,
  status                       task_status NOT NULL DEFAULT 'pending',
  dependency_task_ids          uuid[] NOT NULL DEFAULT '{}',
  output_payload               jsonb NOT NULL DEFAULT '{}',  -- execution result only, not context
  started_at                   timestamptz,
  completed_at                 timestamptz,
  failure_reason               text,
  created_at                   timestamptz NOT NULL DEFAULT now(),
  UNIQUE(execution_run_id, sequence_number)
);
```

---

## 11. Reconciliation

Reconciliation is atomic. Partial graph mutation is prohibited. Every successful reconciliation creates a new graph version. Failure prior to commit restores the snapshot.

### `reconciliation_attempts`

```sql
CREATE TYPE reconciliation_status AS ENUM (
  'pending',
  'snapshot_taken',
  'diff_generated',
  'invariant_validated',
  'lineage_updated',
  'committed',
  'failed',
  'rolled_back'
);

CREATE TABLE reconciliation_attempts (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id            uuid NOT NULL REFERENCES projects(id),
  branch_id             uuid REFERENCES branches(id),
  execution_run_id      uuid REFERENCES execution_runs(id),
  merge_attempt_id      uuid REFERENCES merge_attempts(id),
  status                reconciliation_status NOT NULL DEFAULT 'pending',
  snapshot_version_id   uuid REFERENCES graph_versions(id),
  output_version_id     uuid REFERENCES graph_versions(id),
  semantic_diff_id      uuid REFERENCES semantic_diffs(id),
  failure_reason        text,
  started_at            timestamptz,
  committed_at          timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (execution_run_id IS NOT NULL AND merge_attempt_id IS NULL) OR
    (merge_attempt_id IS NOT NULL AND execution_run_id IS NULL) OR
    (execution_run_id IS NULL AND merge_attempt_id IS NULL)
  )
);

ALTER TABLE graph_versions
  ADD CONSTRAINT fk_reconciliation
  FOREIGN KEY (reconciliation_id)
  REFERENCES reconciliation_attempts(id);
```

---

## 12. Deployment

Deployments are non-canonical artifacts. Deployment state never supersedes graph state. Rollback does not mutate graph state.

```sql
CREATE TYPE deployment_status AS ENUM (
  'not_deployed',
  'deploying',
  'healthy',
  'degraded',
  'failed',
  'rolling_back',
  'rolled_back'
);

CREATE TABLE deployments (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid NOT NULL REFERENCES branches(id),
  graph_version_id        uuid NOT NULL REFERENCES graph_versions(id),
  execution_run_id        uuid REFERENCES execution_runs(id),
  provider                text NOT NULL DEFAULT 'vercel',
  provider_deployment_id  text,
  provider_url            text,
  environment             text NOT NULL DEFAULT 'production',
  status                  deployment_status NOT NULL DEFAULT 'not_deployed',
  previous_deployment_id  uuid REFERENCES deployments(id),
  triggered_by            uuid REFERENCES auth.users(id),
  deployed_at             timestamptz,
  health_verified_at      timestamptz,
  failure_reason          text,
  metadata                jsonb NOT NULL DEFAULT '{}',
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);
```

---

## 13. Repository Ingestion

Repository contents are never persisted as canonical state. Only reconstructed semantic structures and repository references become canonical.

### `repository_ingestion_runs`

```sql
CREATE TYPE ingestion_status AS ENUM (
  'connected',
  'analyzing',
  'reconstructing',
  'confidence_review',
  'validating',
  'ready_for_activation',
  'activated',
  'failed'
);

CREATE TABLE repository_ingestion_runs (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id                uuid NOT NULL REFERENCES projects(id),
  repository_reference_id   uuid NOT NULL REFERENCES repository_references(id),
  status                    ingestion_status NOT NULL DEFAULT 'connected',
  output_graph_version_id   uuid REFERENCES graph_versions(id),
  triggered_by              uuid REFERENCES auth.users(id),
  failure_reason            text,
  analysis_metadata         jsonb NOT NULL DEFAULT '{}',
  started_at                timestamptz,
  activated_at              timestamptz,
  created_at                timestamptz NOT NULL DEFAULT now(),
  updated_at                timestamptz NOT NULL DEFAULT now()
);
```

### `ingestion_confidence_items`

Low and medium confidence structures requiring user confirmation before canonicalization.

```sql
CREATE TYPE confidence_level AS ENUM (
  'high',
  'medium',
  'low'
);

CREATE TYPE confidence_item_status AS ENUM (
  'pending',
  'confirmed',
  'rejected',
  'escalated'
);

CREATE TABLE ingestion_confidence_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingestion_run_id  uuid NOT NULL REFERENCES repository_ingestion_runs(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  node_type         graph_node_type NOT NULL,
  confidence_level  confidence_level NOT NULL,
  confidence_score  numeric(4,3) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
  proposed_payload  jsonb NOT NULL DEFAULT '{}',
  status            confidence_item_status NOT NULL DEFAULT 'pending',
  resolved_by       uuid REFERENCES auth.users(id),
  resolved_at       timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
```

**Confidence thresholds (System Design §13.5):**

| Score | Level | Path |
|---|---|---|
| ≥ 0.90 | High | Eligible for validation directly |
| ≥ 0.70 and < 0.90 | Medium | Marked for confirmation workflow |
| < 0.70 | Low | Low-Confidence Structure — cannot become canonical without explicit confirmation |

---

## 14. Notifications and Activity

Notifications and activity are derived artifacts. They derive from events and lifecycle transitions and are not authoritative state.

### `notifications`

```sql
CREATE TYPE notification_severity AS ENUM (
  'info',
  'warning',
  'action_required',
  'critical'
);

CREATE TABLE notifications (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id      uuid NOT NULL REFERENCES workspaces(id),
  project_id        uuid REFERENCES projects(id),
  recipient_user_id uuid NOT NULL REFERENCES auth.users(id),
  event_id          uuid REFERENCES events(id),
  severity          notification_severity NOT NULL DEFAULT 'info',
  title             text NOT NULL,
  body              text NOT NULL,
  action_url        text,
  read_at           timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now()
);
```

### `escalations`

Created by the Orchestration Subsystem when automatic convergence fails.

```sql
CREATE TYPE escalation_trigger AS ENUM (
  'repeated_validation_failure',
  'repeated_reconciliation_failure',
  'unresolved_merge_conflict',
  'repository_reconstruction_failure',
  'unresolved_ambiguity'
);

CREATE TYPE escalation_status AS ENUM (
  'open',
  'in_resolution',
  'resolved',
  'closed'
);

CREATE TABLE escalations (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid REFERENCES branches(id),
  trigger_type      escalation_trigger NOT NULL,
  trigger_event_id  uuid REFERENCES events(id),
  status            escalation_status NOT NULL DEFAULT 'open',
  affected_scope    jsonb NOT NULL DEFAULT '{}',
  resolution_notes  text,
  resolved_by       uuid REFERENCES auth.users(id),
  resolved_at       timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
```

---

## Foreign Key Completion Summary

All deferred forward references, in application order:

```sql
-- After branches is created:
ALTER TABLE projects
  ADD CONSTRAINT fk_active_branch
  FOREIGN KEY (active_branch_id) REFERENCES branches(id);

-- After graph_versions is created:
ALTER TABLE projects
  ADD CONSTRAINT fk_active_graph_version
  FOREIGN KEY (active_graph_version_id) REFERENCES graph_versions(id);

ALTER TABLE graph_nodes
  ADD CONSTRAINT fk_graph_version
  FOREIGN KEY (graph_version_id) REFERENCES graph_versions(id);

ALTER TABLE graph_edges
  ADD CONSTRAINT fk_graph_version
  FOREIGN KEY (graph_version_id) REFERENCES graph_versions(id);

-- After specification_revisions is created:
ALTER TABLE specification_documents
  ADD CONSTRAINT fk_active_revision
  FOREIGN KEY (active_revision_id) REFERENCES specification_revisions(id);

-- After reconciliation_attempts is created:
ALTER TABLE graph_versions
  ADD CONSTRAINT fk_reconciliation
  FOREIGN KEY (reconciliation_id) REFERENCES reconciliation_attempts(id);

-- After semantic_diffs is created:
ALTER TABLE graph_versions
  ADD CONSTRAINT fk_semantic_diff
  FOREIGN KEY (semantic_diff_id) REFERENCES semantic_diffs(id);

-- After events is created:
ALTER TABLE mutation_deltas
  ADD CONSTRAINT fk_triggering_event
  FOREIGN KEY (triggering_event_id) REFERENCES events(id);
```

---

## Indexes

```sql
-- Event log reconstruction (primary query pattern)
CREATE INDEX idx_events_project_sequence  ON events(project_id, sequence_number);
CREATE INDEX idx_events_project_type      ON events(project_id, event_type);
CREATE INDEX idx_events_branch            ON events(branch_id) WHERE branch_id IS NOT NULL;

-- Approval queue
CREATE INDEX idx_approvals_project_status ON approvals(project_id, status);

-- Execution monitoring
CREATE INDEX idx_execution_runs_branch    ON execution_runs(branch_id, status);

-- Deployment status
CREATE INDEX idx_deployments_project      ON deployments(project_id, status);

-- Confidence item resolution queue
CREATE INDEX idx_confidence_items_status  ON ingestion_confidence_items(ingestion_run_id, status);

-- Notification unread queue
CREATE INDEX idx_notifications_unread     ON notifications(recipient_user_id, read_at)
  WHERE read_at IS NULL;

-- Branch lookup
CREATE INDEX idx_branches_project_state   ON branches(project_id, state);

-- Graph node and edge lookup by version
CREATE INDEX idx_graph_nodes_version      ON graph_nodes(graph_version_id);
CREATE INDEX idx_graph_edges_version      ON graph_edges(graph_version_id);
CREATE INDEX idx_graph_edges_source       ON graph_edges(source_node_id);
CREATE INDEX idx_graph_edges_target       ON graph_edges(target_node_id);

-- Validation group lookup
CREATE INDEX idx_validation_groups_target ON validation_run_groups(target_type, target_id);
```

---

## Immutability Enforcement

The following tables must be enforced as write-once at both the application layer and via RLS policies. No UPDATE or DELETE is permitted after initial INSERT:

- `events`
- `specification_revisions`
- `graph_versions`
- `graph_nodes`
- `graph_edges`
- `semantic_diffs`
- `mutation_deltas`
- `validation_violations`

---

## What Is Not Persisted Here

Per Tech Architecture §14.8:

- Generated code and implementation artifacts
- Repository file contents and snapshots
- Execution workspace contents
- Deployment artifacts
- Monitoring telemetry
- Execution context payloads (generated at runtime by Planner Module, discarded after task completion)
- Group state (derived at read time from sub-states, never stored)

---

*END OF SCHEMA*