# Section 1 — Architectural Principles

## 1.1 Purpose

This document defines the implementation architecture of sembl v1.

It maps the canonical product architecture into a concrete implementation constrained to:

* Next.js
* Node.js
* Supabase
* Vercel
* OpenAI APIs

The document defines implementation ownership, runtime ownership, persistence ownership, operational boundaries, and communication boundaries.

This document does not redefine product behavior.

Product behavior remains governed by:

* V4.3 Formal Specification
* Product Statement & Execution Architecture
* PDD
* PRD
* NFR
* UI/UX Specification
* System Design

---

## 1.2 Architectural Separation Principle

The product architecture remains execution-target agnostic.

The implementation architecture is not.

Canonical structures including:

* specifications
* graph state
* graph versions
* events
* lineage
* reconciliation
* branching

remain independent of implementation providers.

v1 implements those structures using:

* Next.js application runtime
* Node.js execution runtime
* Supabase persistence
* Vercel deployment
* OpenAI model execution

Provider choices are implementation details rather than canonical graph state.

---

## 1.3 Canonical Authority Principle

Authority hierarchy remains:

```text
Specifications
    ↓
Canonical Graph State
    ↓
Execution
    ↓
Reconciliation
    ↓
Deployment
```

The graph is the authoritative operational state.

Repositories, execution workspaces, deployments, and generated code remain non-canonical artifacts.

The implementation architecture must preserve this authority hierarchy under all operating conditions.

Repository references attach to Projects.

Projects may reference multiple repositories.

Branches do not directly own repository references.

Execution runs may produce multiple commit references.

Deployments reference a single deployed commit revision.

Repositories remain external artifacts and never become canonical state.

---

## 1.4 Shared Runtime Principle

v1 operates as a modular monolithic system.

Logical subsystem separation exists through ownership boundaries rather than deployment boundaries.

The following subsystems execute inside a shared backend runtime:

* Specification
* Graph
* Planner
* Validation
* Execution
* Orchestration
* Reconciliation
* Deployment
* Repository Ingestion

No subsystem is deployed as an independent service.

No internal network boundaries exist between subsystems.

Subsystem isolation is enforced through application boundaries and ownership rules.

---

## 1.5 Background Execution Principle

Execution workers are the only independently executing runtime units.

Workers execute as background jobs invoked by the Orchestration Subsystem.

Workers remain:

* stateless
* scoped
* dependency-local
* execution-local

Workers do not own persistent state.

Persistent continuity remains owned by:

* specifications
* graph state
* lineage state
* validation state
* reconciliation state

---

## 1.6 Persistence Principle

Supabase/Postgres functions as the sole system of record.

All canonical persistence resides within Supabase.

Canonical persistence includes:

* specifications
* graph state
* graph versions
* event log
* lineage
* branches
* mutation deltas
* validation outputs
* approvals
* deployment references
* repository references

No secondary persistence system exists.

No graph database exists.

No event store exists outside Supabase.

---

## 1.7 Event-Driven Coordination Principle

Subsystem coordination occurs through:

* persisted events
* persisted state transitions
* validated graph state

Events provide:

* lifecycle progression
* auditability
* lineage reconstruction
* operational visibility

Events do not supersede graph authority.

Events record state transitions while graph state remains operationally authoritative.

---

## 1.8 Branch-Centric Execution Principle

Execution operates against branch state.

Execution ownership chain is:

```text
Branch
    ↓
Execution Run
    ↓
Reconciliation
    ↓
Graph Version
```

Execution never operates directly against canonical graph state.

Execution always occurs against a branch-resolved graph view.

Canonical graph state changes only through successful reconciliation.

---

## 1.9 Reconciliation Governance Principle

All canonical mutation flows through the Reconciliation Subsystem.

No subsystem may:

* mutate graph state directly
* create graph versions directly
* modify lineage directly

Canonical graph updates occur only through reconciliation commit operations.

Reconciliation remains the sole mutation gateway for canonical state.

---

# Section 2 — Runtime Architecture

## 2.1 Runtime Topology

sembl v1 consists of five runtime domains.

```text
Browser Client
        ↓
Next.js Application
        ↓
Backend Runtime Modules
        ↓
Background Worker Runtime
        ↓
Supabase Persistence

External Providers:
    OpenAI
    GitHub
    Vercel
```

All runtime domains communicate through explicitly owned interfaces.

---

## 2.2 Browser Runtime

### Responsibilities

Owns:

* user interaction
* document editing
* project navigation
* graph visualization
* approval workflows
* execution visibility
* deployment visibility
* activity visibility

### Runtime Location

Next.js client runtime.

### Persistence Ownership

None.

The browser never owns canonical state.

### Communication Boundary

Communicates exclusively through application APIs.

Direct database access is prohibited.

Direct provider access is prohibited.

---

## 2.3 Application Runtime

### Responsibilities

Owns:

* authentication enforcement
* authorization enforcement
* request processing
* project lifecycle APIs
* specification lifecycle APIs
* branch lifecycle APIs
* approval lifecycle APIs
* realtime state publication

### Runtime Location

Next.js server runtime on Vercel.

### Persistence Ownership

None.

Application runtime coordinates persistence but does not own stored state.

### Communication Boundary

Communicates with:

* Supabase
* worker runtime
* OpenAI
* repository providers
* deployment providers

through subsystem interfaces.

---

## 2.4 Core Backend Runtime Modules

The following modules execute inside the shared backend runtime.

### Specification Module

Owns:

* specification lifecycle
* document lineage
* specification validation triggers

### Graph Module

Owns:

* graph construction
* graph retrieval
* graph version retrieval
* graph lineage retrieval

### Planner Module

Owns:

* scope resolution
* execution DAG generation
* dependency traversal
* execution context generation
* execution boundary determination

### Execution Module

Owns:

* execution lifecycle management
* execution run management
* worker coordination
* execution metadata
* execution state tracking

Execution coordination remains governed by Orchestration.

### Validation Module

Owns:

* structural validation
* semantic validation
* invariant validation

### Orchestration Module

Owns:

* lifecycle progression
* execution coordination
* approval routing
* escalation routing
* confirmation routing

### Reconciliation Module

Owns:

* semantic diffs
* graph updates
* version creation
* lineage updates

### Deployment Module

Owns:

* deployment coordination
* deployment verification
* deployment status tracking

### Repository Ingestion Module

Owns:

* repository acquisition
* repository analysis
* semantic extraction
* reconstruction execution

Validation, confirmation workflows, and canonicalization remain owned by their respective subsystems.

---

## 2.5 Worker Runtime

### Responsibilities

Owns:

* scoped execution tasks
* implementation generation
* task-level validation
* execution artifact generation

### Runtime Location

Background Node.js worker processes.

### Persistence Ownership

None.

Workers never own canonical persistence.

### Communication Boundary

Workers receive:

* execution scope
* interfaces
* invariants
* dependencies
* localized context

Workers never receive unrestricted graph state.

Workers never receive unrestricted repository state.

Execution ownership remains with the Execution Module.

Workers perform execution work but do not own execution lifecycle state.

Workers act as stateless execution units operating under Execution Module coordination.

---

## 2.6 External Runtime Dependencies

### OpenAI

Used for:

* specification generation
* graph extraction assistance
* execution generation
* validation assistance
* repository reconstruction assistance

OpenAI owns no canonical state.

---

### GitHub

Used for:

* repository ingestion
* repository mutation
* commit reference generation

GitHub repositories remain external artifacts.

---

### Vercel

Used for:

* application hosting
* deployment execution
* deployment status retrieval

Deployment artifacts remain external to canonical persistence.

---

# Section 3 — Application Architecture

## 3.1 Application Structure

The application is organized around subsystem ownership rather than UI pages.

Primary domains:

* Workspace Domain
* Project Domain
* Specification Domain
* Graph Domain
* Execution Domain
* Branch Domain
* Approval Domain
* Deployment Domain
* Activity Domain

Each domain owns its lifecycle operations, persistence access, and validation boundaries.

---

## 3.2 Workspace Domain

### Responsibilities

Owns:

* workspaces
* members
* roles
* permissions

### Runtime Ownership

Application runtime.

### Persistence Ownership

Workspace security state.

### Communication Boundaries

Provides authorization decisions to all downstream domains.

---

## 3.3 Project Domain

### Responsibilities

Owns:

* project lifecycle
* project state
* project visibility
* project context

Acts as the root operational container.

---

## 3.4 Specification Domain

### Responsibilities

Owns:

* specification creation
* specification updates
* specification lineage
* specification validation initiation

Acts as the source domain for graph construction.

---

## 3.5 Execution Domain

### Responsibilities

Owns:

* execution runs
* execution state
* execution progress
* execution lifecycle visibility

Execution coordination remains delegated to Orchestration.

---

## 3.6 Branch Domain

### Responsibilities

Owns:

* branch lifecycle
* branch isolation
* branch execution association
* merge workflows

Branches act as execution containers.

---

# Section 4 — Graph Persistence Architecture

## 4.1 Persistence Model

The canonical graph is implemented as a relational graph projection within Supabase/Postgres.

Graph semantics remain unchanged.

Relational representation exists solely as an implementation strategy.

No graph database exists in v1.

---

## 4.2 Graph Ownership

The Graph Subsystem owns:

* graph persistence
* graph retrieval
* graph version retrieval
* graph lineage retrieval
* graph reconstruction

The Graph Subsystem does not possess graph mutation authority.

Graph mutation authority belongs exclusively to the Reconciliation Subsystem.

No other subsystem may directly modify canonical graph state.

---

## 4.3 Graph Representation

Graph persistence stores:

* nodes
* edges
* graph versions
* lineage references
* reconciliation references
* semantic diff references

Graph persistence does not store:

* generated code
* repositories
* execution artifacts

The graph remains the canonical architectural representation.

---

## 4.4 Graph Version Ownership

Graph versions are immutable.

Every successful reconciliation creates a new graph version.

Graph versions remain permanently retained.

Deletion is prohibited.

Version ownership belongs exclusively to the Graph Subsystem.

Specifications are persisted as immutable revisions.

Specification updates create new specification revisions.

Previous revisions remain permanently retained.

Projects reference the active specification revision.

Graph versions maintain lineage references to the specification revision from which they were derived.

---

## 4.5 Branch Representation

Branches do not store graph snapshots.

Branches store:

* branch identity
* base graph version reference
* ordered mutation deltas
* branch lineage references
* branch events

Branch state is reconstructed through:

```text
Base Graph Version
+
Ordered Delta Application
```

Only resolved branch views are materialized at runtime.

---

## 4.6 Persistence Boundaries

### Graph Subsystem Owns

* graph nodes
* graph edges
* graph versions
* graph lineage

### Branch Domain Owns

* branch identity
* branch lineage
* mutation deltas

### Reconciliation Subsystem Owns

* semantic diffs
* reconciliation references
* graph version creation

No ownership overlap is permitted.

---

# Section 5 — Event and Lineage Architecture

## 5.1 Purpose

The Event and Lineage Architecture provides immutable operational history for:

* audit reconstruction
* lineage reconstruction
* activity visibility
* lifecycle reconstruction
* branch reconstruction
* reconciliation reconstruction

The event log records system history.

The graph remains authoritative operational state.

---

## 5.2 Event Ownership

Event persistence is a cross-cutting architectural capability rather than a standalone subsystem.

Event emission ownership follows existing subsystem ownership boundaries.

No dedicated Event Subsystem exists.

Events provide auditability, lineage reconstruction, lifecycle reconstruction, and operational visibility while remaining subordinate to canonical graph state.

### Specification Module Emits

* SpecificationCreated
* SpecificationModified

### Validation Module Emits

* ValidationTriggered
* ValidationPassed
* ValidationFailed

### Orchestration Module Emits

* ExecutionApprovalRequested
* ExecutionApproved
* GraphMutationApproved
* GraphMutationRejected
* EscalationTriggered

### Execution Module Emits

* ExecutionStarted
* ExecutionCompleted
* ExecutionFailed

### Reconciliation Module Emits

* ReconciliationStarted
* ReconciliationCompleted
* ReconciliationFailed
* GraphMutationCommitted

### Deployment Module Emits

* DeploymentStarted
* DeploymentCompleted
* DeploymentFailed
* DeploymentRolledBack

### Branch Domain Emits

* BranchCreated
* MergeRequested
* MergeApproved
* MergeCompleted
* MergeRolledBack

### Repository Ingestion Workflow Emits

* RepositoryIngestionStarted
* RepositoryIngestionCompleted
* RepositoryIngestionFailed

---

## 5.3 Event Persistence Ownership

Event persistence belongs to Supabase.

Events are:

* immutable
* append-only
* project-scoped
* lineage-addressable

Events are never updated after creation.

Correction occurs through subsequent events.

---

## 5.4 Event Ordering Model

Ordering authority is a project-scoped monotonic event sequence. 

Timestamps are informational only.

Operational ordering derives exclusively from project-local event sequencing.

All lifecycle reconstruction uses sequence ordering.

All audit reconstruction uses sequence ordering.

All lineage reconstruction uses sequence ordering.

---

## 5.5 Event Consumption Model

Subsystems consume events through persisted state progression.

Events do not invoke subsystems directly.

Operational progression follows:

```text
Persist Event
    ↓
Persist State Transition
    ↓
Next Lifecycle Evaluation
```

This prevents transient runtime state from becoming authoritative.

---

## 5.6 Lineage Ownership

Lineage ownership is distributed.

### Graph Subsystem Owns

* graph lineage
* graph version lineage
* graph ancestry

### Branch Domain Owns

* branch lineage
* merge lineage
* mutation lineage

### Deployment Module Owns

* deployment lineage
* rollback lineage

### Reconciliation Module Owns

* reconciliation lineage
* semantic diff lineage

---

## 5.7 Activity Reconstruction

Workspace Activity and Project Activity surfaces derive from:

* event history
* lineage history
* lifecycle state

Activity views never become authoritative state.

Activity is a read model over immutable history.

---

## 5.8 Recovery Guarantees

The event log guarantees reconstruction of:

* approvals
* execution history
* reconciliation history
* deployment history
* merge history
* branch history

Operational state reconstruction relies on:

```text
Graph State
+
Graph Versions
+
Lineage References
+
Events
```

Event replay alone cannot supersede canonical graph state.

---

# Section 6 — Execution Architecture

## 6.1 Purpose

The Execution Architecture transforms canonical graph state into implementation artifacts through graph-scoped execution.

Execution remains:

* DAG-driven
* dependency-scoped
* invariant-aware
* branch-scoped
* reconciliation-governed

Execution never operates against unrestricted repository context.

---

## 6.2 Execution Ownership

The Execution Subsystem owns:

* task execution
* worker invocation
* implementation generation
* execution outputs

The Orchestration Subsystem owns:

* execution coordination
* execution lifecycle progression
* execution scheduling
* execution approvals

Ownership separation is mandatory.

---

## 6.3 Execution Lifecycle

Execution progresses through:

```text
Execution Approval
    ↓
Graph Resolution
    ↓
Task DAG Generation
    ↓
Worker Scheduling
    ↓
Scoped Execution
    ↓
Execution Validation
    ↓
Reconciliation
```

Execution completion does not mutate canonical graph state.

Only reconciliation may do so.

---

## 6.4 DAG Generation

The Planner Module generates execution DAGs from:

* graph state
* dependency topology
* execution boundaries
* invariants

DAG generation ownership belongs to the Planner Module.

Generated DAGs are execution artifacts.

They are not canonical graph structures.

---

## 6.5 Context Generation

Execution context is generated from:

* execution boundary
* direct dependencies
* required interfaces
* required invariants
* required lineage references

Context generation ownership belongs to the Planner Module.

Context remains execution-local.

Context is not persisted.

---

## 6.6 Worker Invocation

Workers execute as background jobs.

Workers receive:

* task scope
* dependency scope
* interface scope
* invariant scope

Workers never receive:

* full graph state
* full repository state
* unrelated execution scopes

---

## 6.7 Temporary Execution Workspaces

Implementation generation occurs within temporary execution workspaces. 

Execution workspaces may contain:

* temporary repository checkouts
* generated files
* implementation artifacts
* validation artifacts

Execution workspaces are non-canonical.

Execution workspaces are deleted after lifecycle completion.

---

## 6.8 Execution Outputs

Execution produces:

* implementation artifacts
* validation artifacts
* execution metadata
* repository mutations

Execution outputs remain non-canonical.

Outputs become canonical only after reconciliation succeeds.

---

## 6.9 Failure Handling

Execution failures remain localized whenever dependency continuity permits.

Failure handling may trigger:

* scoped retry
* task retry
* validation retry
* escalation workflow

Execution failure does not mutate graph state.

---

# Section 7 — Reconciliation Architecture

## 7.1 Purpose

The Reconciliation Subsystem governs all canonical state mutation.

No canonical mutation path exists outside reconciliation.

---

## 7.2 Reconciliation Ownership

The Reconciliation Subsystem owns:

* graph mutation authority
* graph version creation authority
* reconciliation execution
* semantic diffs
* lineage updates
* canonical commit operations
* merge reconciliation

The Reconciliation Subsystem does not own graph persistence.

Graph persistence remains owned by the Graph Subsystem.

No other subsystem may create graph versions or commit canonical graph mutations.

---

## 7.3 Atomic Reconciliation Model

Reconciliation executes atomically.

Lifecycle:

```text
Snapshot
    ↓
Diff Generation
    ↓
Invariant Validation
    ↓
Lineage Update
    ↓
Commit
```

Failure prior to Commit restores Snapshot state.

Partial mutation is prohibited.

---

## 7.4 Semantic Diff Generation

Every reconciliation generates semantic diffs for:

* entity mutations
* interface mutations
* dependency mutations
* invariant mutations
* flow mutations
* execution boundary mutations

Diffs become lineage-addressable artifacts.

---

## 7.5 Validation Integration

Reconciliation cannot proceed without successful validation.

Validation must verify:

* graph invariants
* interface invariants
* execution invariants
* lineage invariants

Violation blocks reconciliation completion.

---

## 7.6 Version Creation

Successful reconciliation creates:

* graph version
* lineage references
* reconciliation references
* semantic diff references

Version creation occurs after successful commit.

---

## 7.7 Canonical State Update

Canonical graph state updates only after:

```text
Validation Success
+
Reconciliation Commit
```

No intermediate mutation visibility exists.

No subsystem may observe proposed graph state before commit.

---

## 7.8 Recovery Model

Failure recovery restores:

* graph snapshot
* lineage state
* reconciliation state

Recovery never restores partial graph mutations.

---

# Section 8 — Branching and Versioning Architecture

## 8.1 Purpose

Branching provides isolated semantic evolution paths while preserving canonical graph continuity.

Branches operate on graph state rather than repositories.

---

## 8.2 Branch Ownership

The Branch Domain owns:

* branch lifecycle
* branch lineage
* branch execution association
* merge workflows
* mutation deltas

The Graph Subsystem owns graph versions.

Ownership remains separate.

---

## 8.3 Branch Representation

Branches persist:

* branch identity
* branch point version
* mutation deltas
* lineage references
* branch events

Branches never persist graph snapshots.

---

## 8.4 Branch State Resolution

Branch state is derived through:

```text
Base Graph Version
+
Ordered Delta Application
```

Resolved branch views are runtime artifacts.

Only deltas are persisted.

---

## 8.5 Execution Association

Execution attaches to branches. 

Ownership chain:

```text
Branch
    ↓
Execution Run
    ↓
Reconciliation
    ↓
Graph Version
```

Graph versions are outputs.

Branches are execution containers.

---

## 8.6 Merge Architecture

Merge lifecycle:

```text
Merge Request
    ↓
Validation
    ↓
Conflict Detection
    ↓
Conflict Resolution
    ↓
Reconciliation
    ↓
Graph Version Creation
```

Merge completion never bypasses reconciliation.

---

## 8.7 Conflict Ownership

Conflict detection belongs to Branch Domain.

Conflict resolution workflow belongs to Orchestration.

Final mutation application belongs to Reconciliation.

---

## 8.8 Version Retention

Graph versions are:

* immutable
* permanently retained
* lineage-linked
* reconciliation-linked

Deletion is prohibited.

Historical reconstruction depends on graph versions.

---

## 8.9 Branch Isolation Guarantees

Branches may not mutate:

* canonical graph state
* unrelated branches
* unrelated lineage state

Isolation remains enforced until reconciliation completion.

---

# Section 9 — Repository Ingestion Architecture

## 9.1 Purpose

Repository Ingestion converts an existing software system into canonical graph state.

Repositorys are treated as source material.

Canonical authority transfers to graph state only after:

* reconstruction
* validation
* confirmation workflows
* canonicalization

Successful ingestion activates Iteration Mode.

---

## 9.2 Ownership Model

### Repository Ingestion Module Owns

* repository acquisition
* repository analysis
* semantic extraction
* reconstruction execution

### Validation Module Owns

* ambiguity detection
* confidence scoring
* reconstruction validation
* low-confidence structure identification

### Orchestration Module Owns

* confirmation queue
* confirmation lifecycle
* escalation lifecycle
* activation gating

### Graph Subsystem Owns

* canonical graph creation
* graph persistence
* graph version initialization

Ownership boundaries must remain explicit.

---

## 9.3 Ingestion Runtime Flow

```text
Repository Connected
        ↓
Repository Analysis
        ↓
Semantic Extraction
        ↓
Graph Reconstruction
        ↓
Validation
        ↓
Low-Confidence Detection
        ↓
Confirmation Queue
        ↓
User Confirmation
        ↓
Canonicalization
        ↓
Initial Graph Version
        ↓
Iteration Activation
```

No stage may bypass validation.

No stage may bypass confirmation requirements.

---

## 9.4 Repository Analysis

Repository analysis executes against the complete repository.

Partial repository analysis is prohibited.

Analysis identifies:

* entities
* interfaces
* integration contracts
* flows
* dependencies
* architectural relationships
* execution boundaries

Repository analysis operates inside temporary ingestion workspaces.

Repository contents never become canonical persistence.

---

## 9.5 Reconstruction Architecture

Reconstruction produces:

* graph nodes
* graph edges
* lineage references
* inferred invariants
* execution boundaries

Reconstruction output remains provisional until validation succeeds.

---

## 9.6 Confidence Architecture

### High Confidence

Eligible for validation progression.

### Medium Confidence

Requires confirmation workflow.

### Low Confidence

Becomes Low-Confidence Structure.

Cannot become canonical state.

Cannot bypass confirmation workflows.

---

## 9.7 Confirmation Architecture

Validation detects ambiguity.

Orchestration owns confirmation.

Confirmation workflow owns:

* queue management
* routing
* user decisions
* escalation decisions
* activation blocking

Confirmation outcomes:

```text
Pending
    ↓
Confirmed

or

Rejected

or

Escalated
```

---

## 9.8 Canonicalization

Canonicalization creates:

* canonical graph state
* graph lineage
* validation lineage
* repository references

Repository contents themselves are not persisted as canonical structures.

Only reconstructed semantic structures become canonical.

---

## 9.9 Repository Persistence Boundaries

sembl persists:

* repository identifiers
* repository references
* repository locations
* repository integration metadata
* repository commit references

sembl does not persist:

* repository contents
* repository snapshots
* generated repositories

Repositorys remain external artifacts.

---

# Section 10 — Collaboration Architecture

## 10.1 Purpose

Collaboration enables coordinated software evolution across workspace members.

v1 collaboration is asynchronous.

Realtime capabilities exist solely for visibility and synchronization of operational state. 

---

## 10.2 Collaboration Ownership

### Workspace Domain Owns

* membership
* roles
* permissions

### Branch Domain Owns

* isolated mutation workflows
* branch collaboration

### Orchestration Module Owns

* approval workflows
* confirmation workflows
* escalation workflows

### Activity Module Owns

* activity visibility
* notification visibility
* status visibility

---

## 10.3 Realtime Scope

Realtime synchronization supports:

* execution state
* deployment state
* approval state
* activity state
* project state
* notification state
* presence visibility

Realtime synchronization does not support:

* collaborative editing
* graph co-editing
* live mutation authoring
* live reconciliation

---

## 10.4 Realtime Implementation

v1 implements realtime state distribution using Supabase Realtime.

Subscriptions publish:

* lifecycle transitions
* approval updates
* execution updates
* deployment updates
* activity updates

Realtime channels are visibility channels.

They are not mutation channels.

---

## 10.5 Collaboration Coordination

Collaboration coordination occurs through:

* branches
* approvals
* semantic diffs
* reconciliation workflows

Direct concurrent mutation of canonical graph state is prohibited.

---

## 10.6 Notification Architecture

Notifications derive from lifecycle events.

Notification sources include:

* approvals
* merge requests
* execution completion
* deployment completion
* escalation triggers
* repository ingestion decisions

Notifications are derived artifacts.

Notifications are not authoritative state.

---

## 10.7 Activity Visibility

Activity timelines derive from:

* events
* lineage
* lifecycle transitions

Activity visibility remains observational.

Activity visibility may never mutate operational state.

---

# Section 11 — Authentication and Authorization Architecture

## 11.1 Purpose

Authentication establishes identity.

Authorization establishes operational capability.

Authentication and authorization remain implementation concerns and never become canonical graph structures.

---

## 11.2 Authentication Architecture

Authentication is implemented through Supabase Auth.

Authentication responsibilities:

* identity verification
* session issuance
* session refresh
* identity lifecycle

Authentication state remains external to graph structures.

---

## 11.3 Authorization Architecture

Authorization is workspace-scoped.

Authorization governs:

* workspace access
* project access
* branch access
* execution authority
* approval authority
* merge authority
* mutation authority

Authorization decisions are enforced by the application runtime.

---

## 11.4 Workspace Boundary

Workspace acts as the primary security boundary.

All projects belong to exactly one workspace.

Authorization inheritance flows:

```text
Workspace
    ↓
Project
    ↓
Branch
    ↓
Execution
```

---

## 11.5 Repository Authorization

Repository access requires explicit user authorization.

Repository credentials remain external to graph structures.

Repository permissions are evaluated before:

* ingestion
* repository mutation
* deployment preparation

---

## 11.6 Deployment Authorization

Deployment operations require:

* workspace authorization
* project authorization
* deployment authority

Deployment credentials remain isolated from canonical persistence.

---

## 11.7 Approval Authorization

Approval authority is role-controlled.

Approval evaluation occurs before:

* execution approval completion
* architectural mutation approval completion
* merge approval completion

Unauthorized approvals are invalid state transitions.

---

## 11.8 Security Boundaries

The browser never receives:

* provider credentials
* deployment credentials
* repository credentials
* administrative secrets

Secret ownership remains server-side only.

---

# Section 12 — Deployment Architecture

## 12.1 Purpose

Deployment converts execution outputs into operational software deployments.

Deployments remain non-canonical artifacts.

Deployment state never supersedes graph state.

---

## 12.2 Deployment Ownership

Deployment Module owns:

* deployment orchestration
* deployment validation
* deployment monitoring
* deployment status tracking
* rollback tracking

---

## 12.3 Deployment Adapter Model

## 12.3 Deployment Adapter Model

Deployment operations execute through deployment adapters.

The Deployment Module targets deployment adapters rather than provider-specific implementations.

v1 implements a single deployment adapter:

```text
Vercel Adapter
```
All deployment operations execute through this adapter.

Additional deployment adapters are outside v1 scope.

Deployment adapter selection remains an implementation concern and does not alter canonical graph structures.

---

## 12.4 Deployment Flow

```text
Deployment Request
        ↓
Target Validation
        ↓
Artifact Preparation
        ↓
Environment Validation
        ↓
Deployment Execution
        ↓
Health Verification
        ↓
Deployment Complete
```

Deployment failures enter recovery workflows.

---

## 12.5 Deployment Validation

Validation verifies:

* runtime compatibility
* framework compatibility
* dependency compatibility
* deployment compatibility

Validation failure blocks deployment completion.

Validation persistence is centered around Validation Runs.

Each Validation Run validates a single target lifecycle object.

Supported targets include:

- Repository Ingestion
- Execution Run
- Reconciliation Attempt
- Merge Attempt

Validation Runs own validation results and validation violations.

Validation artifacts remain independently addressable and lineage-linked.
---

## 12.6 Deployment Persistence

sembl persists:

* deployment references
* provider deployment identifiers
* deployment status
* deployment lineage
* rollback lineage
* environment references

Deployment artifacts remain external.

---

## 12.7 Rollback Architecture

Rollback restores:

* previous deployment reference
* deployment health state

Rollback does not mutate:

* graph state
* lineage state
* reconciliation state

Rollback emits deployment lifecycle events.

---

## 12.8 Deployment Monitoring

Deployment monitoring tracks:

* deployment completion
* deployment health
* deployment availability
* deployment failures

Monitoring data supports visibility.

Monitoring data does not become canonical state.

---

# Section 13 — Observability and Recovery

## 13.1 Purpose

Observability provides operational visibility into system state.

Recovery preserves canonical continuity during failure.

Canonical state integrity takes precedence over execution completion.

---

## 13.2 Observability Domains

Operational visibility includes:

* execution state
* validation state
* reconciliation state
* deployment state
* approval state
* branch state
* repository ingestion state

All visibility derives from persisted state.

---

## 13.3 Logging Architecture

Logging captures:

* lifecycle transitions
* execution outcomes
* validation outcomes
* deployment outcomes
* failure events

Logs support diagnosis.

Logs do not become authoritative state.

---

## 13.4 Audit Architecture

Audit reconstruction derives from:

* events
* lineage
* approvals
* reconciliation history
* merge history

Auditability remains immutable.

Historical records are never modified.

---

## 13.5 Failure Classification

Failures include:

* validation failures
* execution failures
* reconciliation failures
* deployment failures
* merge failures
* ingestion failures

Failure classification is mandatory.

---

## 13.6 Recovery Architecture

Recovery actions include:

* task retry
* execution retry
* validation retry
* reconciliation retry
* rollback workflow
* escalation workflow

Recovery scope remains localized whenever possible.

---

## 13.7 Escalation Architecture

Escalation ownership belongs to Orchestration.

Escalation triggers include:

* repeated validation failures
* repeated reconciliation failures
* unresolved ambiguity
* unresolved merge conflicts
* repository reconstruction failure

Escalation creates required user actions.

---

## 13.8 Canonical Integrity Protection

Failures must never corrupt:

* graph state
* graph lineage
* graph versions
* reconciliation state
* approval state

Integrity preservation takes precedence over throughput.

---

# Section 14 — Implementation Constraints

## 14.1 Runtime Constraints

v1 implementation stack is fixed.

```text
Frontend:
    Next.js

Backend:
    Node.js

Persistence:
    Supabase/Postgres

Hosting:
    Vercel

Model Provider:
    OpenAI
```

Alternative implementations are out of scope.

---

## 14.2 Deployment Constraints

v1 deploys as a modular monolith.

The system does not implement:

* microservices
* service meshes
* distributed orchestration
* multi-region execution
* event buses
* Kafka infrastructure

Logical subsystem separation does not imply deployment separation.

---

## 14.3 Persistence Constraints

Supabase/Postgres is the sole persistence system.

No separate:

* graph database
* event store
* document database
* vector database

exists as a canonical persistence layer.

---

## 14.4 Graph Constraints

Canonical graph persistence is implemented as a relational graph projection.

Graph semantics remain unchanged.

Implementation representation may not alter graph behavior.

---

## 14.5 Execution Constraints

Workers remain:

* stateless
* scoped
* dependency-local

Workers may not:

* own canonical state
* mutate graph state directly
* access unrestricted repository context

---

## 14.6 Reconciliation Constraints

Canonical mutation may only occur through reconciliation.

Direct graph mutation is prohibited.

Direct lineage mutation is prohibited.

Direct version creation is prohibited.

---

## 14.7 Collaboration Constraints

Realtime infrastructure is visibility-only.

v1 excludes:

* CRDTs
* operational transforms
* collaborative editing engines
* live graph mutation systems

---

## 14.8 Canonical State Constraints

Canonical persistence remains limited to:

* specifications
* graph state
* graph versions
* lineage
* event log
* mutation deltas
* validation outputs
* approvals
* deployment references
* repository references

Generated code remains non-canonical.

Repositories remain non-canonical.

Deployments remain non-canonical.

---

## 14.9 Architectural Stability Constraint

Future scalability assumptions must not appear in v1 implementation architecture.

The architecture must describe:

* what is implemented
* where it executes
* who owns it
* how it persists

and not speculative future infrastructure.

---



