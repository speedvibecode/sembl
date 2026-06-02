# System Design — sembl v1

## 1. Foundations

### 1.1 Canonical Graph Structures

The canonical graph is composed of the following node types:

| Node Type            | Responsibility                                                                                                      |
| -------------------- | ----------------------------------------------------------------------------------------------------------------|
| Entity               | Structured reusable data object with typed fields                                                                 |
| Interface            | Executable contract defining inputs, outputs, preconditions, postconditions, success examples, and failure examples |
| Integration Contract | Ordered composition of Interfaces including field mappings and error propagation                                    |
| Flow                 | End-to-end user journey composed of Integration Contracts                                                           |
| Invariant            | Constraint that must hold across graph state                                                                        |
| Execution Boundary   | Dependency-local execution scope used for context generation and task generation                                    |

The canonical graph supports the following edge types:

| Edge Type  | Meaning                                                  |
| ---------- | ---------------------------------------------------------|
| dependency | Target must exist and validate before source executes    |
| implements | Interface output resolves to Entity                      |
| precedes   | Ordered execution relationship                           |
| triggers   | Completion activates downstream behavior                 |
| owns       | Integration Contract or Flow responsibility relationship |
| lineage    | Historical derivation relationship                       |

All graph construction, validation, execution, reconciliation, branching, and lineage operations operate exclusively against these node and edge types.

---

### 1.2 Event Model

All state transitions are event-driven.

Events are persisted.

Events are part of canonical lineage state.

Events are immutable after creation.

Canonical events include:

* SpecificationCreated
* SpecificationModified
* ValidationTriggered
* ValidationPassed
* ValidationFailed
* GraphMutationProposed
* GraphMutationApproved
* GraphMutationRejected
* GraphMutationCommitted
* ExecutionApprovalRequested
* ExecutionApproved
* ExecutionStarted
* ExecutionCompleted
* ExecutionFailed
* ReconciliationStarted
* ReconciliationCompleted
* ReconciliationFailed
* ReconciliationRolledBack
* DeploymentStarted
* DeploymentCompleted
* DeploymentFailed
* DeploymentRolledBack
* BranchCreated
* MergeRequested
* MergeApproved
* MergeCompleted
* MergeRolledBack
* EscalationTriggered
* RepositoryIngestionStarted
* RepositoryIngestionCompleted
* RepositoryIngestionFailed

Events are strictly ordered within a project.

No ordering guarantees exist across projects.

The event log is authoritative for lineage reconstruction, audit reconstruction, activity reconstruction, and state derivation.

---

### 1.2.1 Authority Hierarchy

Canonical graph state is the authoritative operational state of the system.

The event log is the authoritative lineage and audit record of the system.

Authority hierarchy is:

Specifications
→ Canonical Graph State
→ Execution
→ Reconciliation
→ Deployment

Events do not supersede graph authority.

Events record:

* state transitions
* mutation history
* approvals
* execution history
* reconciliation history
* deployment history

Event replay MAY reconstruct lineage, audit history, operational history, and historical state transitions.

Event replay MUST NOT redefine canonical graph state independently of persisted graph versions.

In the event of disagreement between event-derived state and persisted canonical graph state, canonical graph state remains authoritative.

---

### 1.3 Branch Representation

A branch is a named graph version plus an ordered mutation delta.

A branch stores:

* branch identifier
* branch point graph version
* mutation list
* mutation lineage
* branch events

A branch does not store a full graph copy.

Branch state is computed as:

Base Graph Version
+
Ordered Delta Application

Merge operates through:

Branch Delta
→ Validation
→ Conflict Resolution
→ Reconciliation
→ Canonical Graph Update

Successful merges archive the branch and preserve lineage.

---

### 1.3.1 Graph Version Retention

Canonical graph versions are immutable and permanently retained.

Every successful reconciliation creates a new graph version.

Each graph version contains:

* version identifier
* graph snapshot
* lineage references
* reconciliation references
* semantic diff references

Branches store only mutation deltas.

Branch reconstruction is performed by:

Base Graph Version
+
Ordered Delta Application

Historical recoverability depends on retained graph versions rather than retained branch snapshots.

Graph version retention is owned by the Graph Subsystem.

Branch retention is owned by the Branch Lineage Model.

Deletion of canonical graph versions is prohibited.

This guarantees deterministic reconstruction of:

* branch state
* merge history
* lineage history
* architectural history

---

### 1.4 Group State Derivation

Group State is derived at read time.

Group State is never persisted.

Input states:

* Validation State
* Execution State
* Reconciliation State
* Deployment State
* Approval State

Priority hierarchy:

Escalated
→ Blocked
→ Awaiting Action
→ In Progress
→ Healthy

Derivation rules:

* Any Escalated sub-state produces Escalated group state.
* Any Failed or Blocked sub-state produces Blocked group state if Escalated does not exist.
* Any approval or review dependency produces Awaiting Action if higher states do not exist.
* Any active execution, validation, reconciliation, or deployment produces In Progress if higher states do not exist.
* Otherwise the state is Healthy.

---

### 1.5 Reconciliation Atomicity

Reconciliation is atomic.

Stages:

Snapshot
→ Diff Generation
→ Invariant Validation
→ Lineage Update
→ Commit

Failure during any stage prior to Commit restores the Snapshot.

Partial graph mutation is prohibited.

No subsystem may observe proposed graph mutations before Commit succeeds.

Canonical graph state changes only after successful Commit.

---

## 2. System Architecture Overview

The system is composed of seven operational subsystems.

### Specification Subsystem

Owns:

* specifications
* document lineage
* specification validation triggers

Produces:

* graph extraction inputs

---

### Graph Subsystem

Owns:

* canonical graph state
* graph versions
* graph lineage

Produces:

* normalized graph state

---

### Validation Subsystem

Owns:

* invariant enforcement
* structural validation
* semantic validation

Produces:

* validation outputs
* violation records

---

### Orchestration Subsystem

Owns:

* execution coordination
* lifecycle progression
* escalation routing

Produces:

* execution state transitions

---

### Approval Responsibilities

Approval handling belongs to the Orchestration Subsystem.

The Orchestration Subsystem owns:

* approval routing
* approval lifecycle management
* approval expiry handling
* approval state transitions

Approval is not an independent subsystem.

Approval workflows are orchestration workflows governed by validation and reconciliation requirements.

---

### Execution Subsystem

Owns:

* task execution
* scoped implementation generation
* execution outputs

Produces:

* implementation artifacts

---

### Reconciliation Subsystem

Owns:

* graph mutation
* lineage updates
* semantic diff generation

Produces:

* updated canonical state

---

### Deployment Subsystem

Owns:

* deployment orchestration
* deployment validation
* deployment health verification

Produces:

* deployment references
* deployment status

All subsystem interactions occur through persisted events and validated graph state.

No subsystem may mutate canonical graph state directly.

---

## 3. Graph Construction and Normalization

### 3.1 Graph Construction

Graph construction transforms validated specification state into canonical graph state.

Input:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

Construction process:

Specification Extraction
→ Node Identification
→ Relationship Identification
→ Initial Graph Creation

Output:

G₀ (Unnormalized Graph)

---

### 3.2 Node Extraction

Extraction creates graph nodes for:

* Entities
* Interfaces
* Integration Contracts
* Flows
* Invariants
* Execution Boundaries
(No Feature node extraction step)

Every extracted node receives:

* unique identifier
* source references
* lineage origin

---

### 3.3 Relationship Extraction

Relationship discovery creates:

* dependency edges
* ownership edges
* execution ordering edges
* lineage edges

Undefined relationships are invalid graph state.

---

### 3.4 Normalization Pipeline

Normalization executes deterministically.

Pass 1 — Structural Normalization

Validates:

* required fields
* node completeness
* edge validity

Pass 2 — Consistency Normalization

Validates:

* naming consistency
* duplicate detection
* reference consistency

Pass 3 — Mapping Normalization

Validates:

* entity reuse
* interface mappings
* integration mappings

Pass 4 — Completeness Normalization

Validates:

* examples
* preconditions
* postconditions
* execution metadata

Output:

Normalized Graph (Gₙ)

---

### 3.5 Invariant Enforcement

Invariant enforcement executes after normalization.

Validation categories:

* graph invariants
* interface invariants
* execution invariants
* lineage invariants

Violations produce structured records.

Each record includes:

* invariant identifier
* affected node
* affected scope
* severity
* remediation path

---

### 3.6 Canonicalization

Graph state becomes canonical only when:

* normalization completes
* validation passes
* invariant violations equal zero

Output:

Validated Canonical Graph

This graph becomes the authoritative source for context generation, task generation, execution, reconciliation, iteration, branching, merging, and deployment.

---

## 4. Event Architecture

### 4.1 Purpose

Events are the sole mechanism for state transition.

Every consequential system action produces an event.

Every lifecycle transition is triggered by an event.

Every event becomes part of immutable lineage history.

The event log functions as:

* audit source
* lineage source
* activity source
* state reconstruction source

No subsystem may directly alter lifecycle state without producing an event.

---

### 4.2 Event Structure

Every event contains:

* event identifier
* event type
* project identifier
* branch identifier
* originating subsystem
* timestamp
* triggering actor
* affected scope
* source state
* target state
* metadata

Events are immutable after creation.

---

### 4.3 Event Ownership

Specification Subsystem emits:

* SpecificationCreated
* SpecificationModified

Validation Subsystem emits:

* ValidationTriggered
* ValidationPassed
* ValidationFailed

Orchestration Subsystem emits::

* ExecutionApprovalRequested
* ExecutionApproved
* GraphMutationApproved
* GraphMutationRejected
* MergeApproved

Approval decision events are emitted by the Orchestration Subsystem after recording user or workspace approval actions.

Orchestration Subsystem emits:

* ExecutionStarted
* ExecutionCompleted
* ExecutionFailed
* EscalationTriggered

Reconciliation Subsystem emits:

* GraphMutationProposed
* GraphMutationCommitted
* ReconciliationStarted
* ReconciliationCompleted
* ReconciliationFailed
* ReconciliationRolledBack

Deployment Subsystem emits:

* DeploymentStarted
* DeploymentCompleted
* DeploymentFailed
* DeploymentRolledBack

Graph Subsystem emits:

* BranchCreated
* MergeRequested
* MergeCompleted
* MergeRolledBack

Repository Ingestion Subsystem emits:

* RepositoryIngestionStarted
* RepositoryIngestionCompleted
* RepositoryIngestionFailed

---

### 4.4 Event Propagation

Propagation follows deterministic routing.

Example:

SpecificationModified
→ ValidationTriggered

ValidationPassed
→ ExecutionApprovalRequested

ExecutionApproved
→ ExecutionStarted

ExecutionCompleted
→ ReconciliationStarted

ReconciliationCompleted
→ DeploymentStarted

DeploymentCompleted
→ Active State

Events may trigger multiple downstream events.

Propagation order remains deterministic.

---

### 4.5 Event Ordering

Within a project:

* total ordering guaranteed

Across projects:

* no ordering guarantee

Within a branch:

* ordering preserved

Across branches:

* ordering independent

Lineage reconstruction always uses project-local ordering.

---

### 4.5.1 Ordering Authority

Event ordering authority belongs to the Orchestration Subsystem.

Within a project, events are assigned monotonically increasing sequence identifiers.

Branches preserve ordering relative to their originating project sequence.

Cross-branch ordering is reconstructed through:

* branch point version
* sequence identifiers
* lineage references

Ordering guarantees exist for lineage reconstruction and audit reconstruction only.

Execution ordering remains governed by the Task Graph rather than event ordering.

---

### 4.6 Event Authority

Events are the authoritative mechanism for lifecycle transition recording.

Canonical graph state remains the authoritative operational state.

Current lifecycle state is derived from:

Latest Relevant Event
+
Current Validation Status
+
Current Approval Status

Manual state mutation is prohibited.

---

### 4.7 Event Invariants

Every consequential action must emit an event.

Events must remain immutable.

Events must remain lineage-addressable.

State transitions without events are invalid.

---

## 5. Group State and Lifecycle State Machine

### 5.1 Lifecycle States

Projects exist in exactly one lifecycle state.

Allowed states:

* Draft
* Ready For Execution
* Awaiting Approval
* Executing
* Reconciling
* Deploying
* Active
* Escalated

Multiple lifecycle states simultaneously are invalid.

---

### 5.1.1 Operational Mode Mapping

Operational Modes and Lifecycle States are distinct concepts.

Operational Mode defines the active system workflow.

Lifecycle State defines current execution status within that workflow.

Operational Modes:

* Documentation Mode
* Execution Mode
* Iteration Mode

Lifecycle States operate inside operational modes.

Documentation Mode may contain:

* Draft
* Ready For Execution

Execution Mode may contain:

* Awaiting Approval
* Executing
* Reconciling
* Deploying

Iteration Mode may contain:

* Active
* Awaiting Approval
* Executing
* Reconciling
* Deploying

Escalated may occur within any operational mode.

Operational Mode changes are governed by the state transition rules defined in the PDD.

Lifecycle State changes are governed by the state machine defined in this document.

---

### 5.2 Lifecycle Transition Model

Draft
→ Ready For Execution

Ready For Execution
→ Awaiting Approval

Awaiting Approval
→ Executing

Executing
→ Reconciling

Reconciling
→ Deploying

Deploying
→ Active

Any state
→ Escalated

Escalated
→ Previous Valid State

Only after issue resolution.

---

### 5.3 Transition Authority

Transition authority belongs to Orchestration.

Orchestration evaluates:

* validation outcomes
* approval outcomes
* reconciliation outcomes
* deployment outcomes

State transitions occur only after required events exist.

---

### 5.4 Transition Atomicity

Lifecycle transitions are atomic.

Partial transitions are prohibited.

Transition procedure:

Validate Preconditions
→ Emit Event
→ Commit State

Failure restores prior state.

---

### 5.5 Rollback Rules

Rollback permitted for:

* reconciliation failure
* deployment failure
* merge failure

Rollback restores:

* graph version
* lineage version
* lifecycle state

Rollback never removes history.

Rollback itself produces events.

---

### 5.6 Sub-State Model

Validation State:

* Passed
* Warning
* Failed
* Revalidating

Execution State:

* Queued
* Preparing
* Running
* Validating
* Reconciling
* Completed
* Failed
* Escalated

Approval State:

* Pending
* Under Review
* Approved
* Rejected

Deployment State:

* Not Deployed
* Deploying
* Healthy
* Degraded
* Failed
* Rolling Back

Reconciliation State:

* Pending
* Running
* Completed
* Failed

---

### 5.7 Group State Derivation

Group state derives from sub-state priority.

Evaluation order:

Escalated
→ Blocked
→ Awaiting Action
→ In Progress
→ Healthy

Examples:

# Validation Failed

Blocked

# Execution Running

In Progress

Deployment Healthy
+
Validation Passed
+
No Approvals
============

Healthy

# Any Escalated state

Escalated

---

### 5.8 State Invariants

Every project has one lifecycle state.

Group state is derived only.

Group state is never persisted.

Lifecycle transitions require events.

Blocked states expose resolution paths.

Escalated states terminate automatic progression.

---

## 6. Scoped Context Generation

### 6.1 Purpose

Context generation converts graph state into execution-local context.

Workers never operate against full graph state.

Workers operate against execution boundaries.

---

### 6.2 Context Inputs

Inputs:

* canonical graph
* task graph
* dependency graph
* invariant graph
* interface graph

No repository-wide context is allowed.

---

### 6.3 Scope Resolution

Planner receives:

* requested mutation
* execution request
* validation request

Planner determines:

Affected Node Set

Dependency Closure

Required Interfaces

Required Invariants

Execution Boundary

---

### 6.4 Dependency Traversal

Traversal begins at affected nodes.

Expansion permitted only through:

* dependency edges
* interface mappings
* integration contracts

Traversal stops when:

* no dependency expansion remains
* execution boundary reached

---

### 6.5 Context Package

Generated context contains:

* target nodes
* required dependencies
* required interfaces
* required invariants
* task objectives

Excluded:

* unrelated flows
* unrelated entities
* unrelated interfaces
* unrelated branches

---

### 6.6 Context Boundedness

Context size scales with:

Affected Scope

not

Repository Size

Context generation must preserve locality.

Repository growth must not force proportional context growth.

---

### 6.7 Context Validation

Generated context validates:

* dependency completeness
* interface completeness
* invariant completeness

Incomplete context is invalid.

Execution cannot begin.

---

### 6.8 Context Invariants

Execution operates only on scoped context.

Workers never access full graph state.

Context is graph-derived.

Context is deterministic for equivalent graph state.

---

## 7. Task Graph Generation

### 7.1 Purpose

Task Graph generation transforms validated graph state into executable DAG state.

Output:

Task Graph

Input:

Validated Canonical Graph

---

### 7.2 Task Creation

Tasks originate from:

* Interfaces
* Integration Contracts
* Validation Requirements
* Deployment Requirements

Each task defines:

* identifier
* scope
* dependencies
* required interfaces
* required invariants
* outputs
* validation criteria

---

### 7.3 Dependency Resolution

Dependencies derive from:

* dependency edges
* precedes edges
* integration mappings

Result:

Directed Acyclic Graph

Circular dependency detection blocks generation.

---

### 7.4 Integration Tasks

Integration Contracts become orchestration tasks.

Responsibilities:

* field mapping
* flow coordination
* error propagation
* rollback coordination

Integration tasks never implement business logic.

---

### 7.5 Execution Ordering

Ordering uses topological sorting.

Execution begins only after:

All Dependencies Complete

No dependency bypass is permitted.

---

### 7.6 Task Classification

Task Types:

Implementation Tasks

Validation Tasks

Integration Tasks

Reconciliation Tasks

Deployment Tasks

Each type follows distinct execution rules.

---

### 7.7 Task Outputs

Task outputs must be:

* explicit
* schema-valid
* dependency-addressable

Implicit outputs are invalid.

---

### 7.8 Task Graph Invariants

Task graph must remain acyclic.

Tasks must remain graph-derived.

Dependencies must remain explicit.

Execution order must remain deterministic.

Equivalent graph state must produce semantically equivalent task graphs.

---

## 8. Agent Execution

### 8.1 Agent Model

Execution operates through:

* Orchestrator
* Planner
* Validator
* Reconciliation Agent
* Workers

Agent responsibilities are isolated.

Responsibility overlap is prohibited.

---

### 8.2 Orchestrator

Responsible for:

* lifecycle progression
* event routing
* execution coordination
* escalation routing
* approval routing

Orchestrator never performs implementation generation.

---

### 8.3 Planner

Responsible for:

* graph slicing
* scope resolution
* context generation
* task graph generation
* dependency analysis

Planner never performs implementation generation.

---

### 8.4 Validator

Responsible for:

* invariant validation
* structural validation
* semantic validation
* execution validation
* reconciliation validation

Validator never mutates graph state.

---

### 8.5 Reconciliation Agent

Responsible for:

* graph updates
* semantic diffs
* lineage updates
* merge reconciliation

Graph mutation authority exists only here.

---

### 8.6 Workers

Responsible for:

* localized execution
* interface implementation
* task completion

Workers are stateless.

Workers persist nothing.

Reusable outputs must reconcile into canonical state.

---

### 8.7 Execution Flow

ExecutionApproved
→ Planner Generates Scope
→ Planner Generates Task Graph
→ Workers Execute Tasks
→ Validator Validates Outputs
→ Reconciliation Begins

---

### 8.8 Failure Handling

Execution failures remain scope-local.

Failure categories:

* dependency failure
* invariant failure
* implementation failure
* integration failure

Recovery options:

* retry
* revalidate
* rollback
* escalate

Repeated failure triggers escalation.

---

### 8.9 Execution Invariants

Workers remain stateless.

Execution remains scoped.

Execution remains graph-derived.

Execution preserves interface continuity.

Execution preserves dependency continuity.

Execution preserves architectural continuity.

Execution cannot mutate canonical graph state directly.

---

## 9. Validation

### 9.1 Purpose

Validation is the mandatory enforcement layer governing graph correctness, execution correctness, reconciliation correctness, and deployment eligibility.

No state may progress to execution, reconciliation, merge, or deployment while blocking validation failures exist.

Validation is deterministic.

Validation does not mutate graph state.

---

### 9.2 Validation Architecture

Validation executes through bounded multi-pass evaluation.

Pass 1 — Structural Validation

Validates:

* node completeness
* edge validity
* schema correctness
* reference resolution

Pass 2 — Semantic Validation

Validates:

* interface consistency
* integration consistency
* dependency consistency
* architectural continuity

Pass 3 — Consistency Validation

Validates:

* duplicate structures
* conflicting structures
* lineage consistency
* reconciliation consistency

Outputs from all passes are aggregated before final determination.

---

### 9.3 Violation Classification

Violations are classified as:

Informational

Does not affect execution.

Warning

Execution may continue.

Must be surfaced.

Blocking

Execution prohibited until resolved.

Escalated

Human intervention required.

Automatic progression prohibited.

---

### 9.4 Violation Structure

Every violation contains:

* violation identifier
* violation type
* invariant identifier
* affected scope
* severity
* source location
* remediation guidance

Violations are graph-addressable.

---

### 9.5 Validation Locality

Validation executes against affected scopes whenever locality guarantees remain valid.

Validation expands beyond local scope only when:

* dependency propagation occurs
* invariant propagation occurs
* reconciliation requires broader evaluation

Localized changes do not trigger automatic global validation.

---

### 9.6 Validation Triggers

Validation is triggered by:

* specification mutation
* graph mutation proposal
* execution completion
* merge request
* repository ingestion
* deployment preparation

Validation cannot be bypassed.

---

### 9.7 Escalation Conditions

EscalationTriggered is emitted when:

* repeated invariant failures exceed threshold
* reconciliation repeatedly fails
* merge conflicts remain unresolved
* repository reconstruction cannot converge
* semantic ambiguity remains unresolved

Escalated state blocks automated progression.

---

### 9.8 Validation Invariants

Validation outputs are immutable.

Validation is deterministic.

Blocking violations prevent:

* execution completion
* reconciliation completion
* merge completion
* deployment completion

Equivalent graph state must produce equivalent validation outcomes.

---

## 10. Reconciliation

### 10.1 Purpose

Reconciliation is the sole mechanism through which canonical graph state may change.

All semantic mutation is reconciliation-governed.

Direct graph mutation is prohibited.

---

### 10.2 Reconciliation Inputs

Inputs:

* current canonical graph
* execution outputs
* validation outputs
* approved mutations

Reconciliation operates only on validated inputs.

---

### 10.3 Reconciliation Pipeline

Stage 1 — Snapshot

Capture immutable rollback point.

Emit:

ReconciliationStarted

---

Stage 2 — Diff Generation

Generate graph-addressable semantic diff.

Diff categories:

* entity mutation
* interface mutation
* dependency mutation
* flow mutation
* invariant mutation
* execution-boundary mutation

---

Stage 3 — Invariant Validation

Execute all graph invariants against proposed state.

Blocking violation:

→ Abort

---

Stage 4 — Lineage Update

Generate lineage edges for:

* created nodes
* modified nodes
* removed nodes

Lineage remains immutable.

---

Stage 5 — Commit

Apply entire mutation set.

Update graph version.

Persist diff.

Persist lineage.

Emit:

ReconciliationCompleted

---

### 10.4 Atomicity Rules

Reconciliation commits as a single unit.

Partial commits prohibited.

Visibility prohibited before commit.

Failure restores snapshot.

No subsystem may observe intermediate state.

---

### 10.5 Failure Recovery

Failure during:

Diff Generation
→ Abort

Invariant Validation
→ Abort

Lineage Update
→ Abort

Commit
→ Abort

All failures restore snapshot.

Emit:

ReconciliationFailed

Repeated failure triggers escalation.

---

### 10.6 Post-Reconciliation State

Successful reconciliation produces:

* new graph version
* updated lineage
* persisted semantic diff
* updated branch lineage
* updated execution lineage

Canonical state becomes immediately authoritative.

---

### 10.7 Reconciliation Invariants

Graph mutation authority exists only here.

Lineage must remain reconstructable.

Diffs must remain graph-addressable.

Atomicity must be preserved.

---

## 11. Iteration

### 11.1 Purpose

Iteration enables long-term software evolution through controlled graph mutation.

Iteration modifies architecture through semantic state rather than repository state.

---

### 11.2 Iteration Entry

Iteration begins from:

* prompt
* specification modification
* branch merge
* repository update request

Input becomes mutation request.

---

### 11.3 Mutation Analysis

Planner performs scope analysis.

Outputs:

* affected nodes
* affected interfaces
* affected invariants
* affected execution boundaries
* affected dependencies

Result:

Mutation Scope

---

### 11.4 Mutation Classification

Automatic Mutations:

* additive features
* localized UI changes
* isolated flows
* non-breaking extensions

Approval-Gated Mutations:

* entity addition
* entity removal
* entity rename
* interface addition
* interface removal
* interface rename
* dependency restructuring
* invariant mutation
* execution-target migration

Classification determines approval routing.

---

### 11.5 Approval Routing

Approval-gated mutations generate:

GraphMutationProposed

Orchestration evaluates:

* affected scopes
* dependency impact
* interface impact
* architectural impact

Approved:

GraphMutationApproved

Rejected:

GraphMutationRejected

---

### 11.6 Localized Re-Execution

Planner regenerates:

Affected Scope
+
Dependency Closure

Only affected task graphs are regenerated.

Full-system regeneration prohibited unless locality breaks.

---

### 11.7 Diff Visibility

Iteration produces:

* semantic diff
* architectural diff
* dependency diff
* lineage diff

Users review semantic changes rather than raw repository changes.

---

### 11.8 Iteration Invariants

Iteration preserves:

* graph identity
* entity continuity
* interface continuity
* dependency continuity
* lineage continuity

Uncontrolled regeneration prohibited.

---

## 12. Branching and Merging

### 12.1 Branch Creation

Branch creation emits:

BranchCreated

Branch contains:

* branch identifier
* branch point version
* ordered delta list
* branch lineage

Branch creation never duplicates graph state.

---

### 12.2 Delta Tracking

Branch mutations are stored as deltas.

Delta types:

* add
* modify
* remove

Each delta contains:

* target node
* mutation payload
* triggering event
* lineage reference

---

### 12.3 Branch State Resolution

Branch state is computed as:

Base Version
+
Ordered Delta Application

Resolved branch state is transient.

Only deltas are persisted.

---

### 12.4 Merge Flow

MergeRequested
→ Validation
→ Conflict Detection
→ Conflict Resolution
→ Reconciliation
→ MergeCompleted

Merge never bypasses reconciliation.

---

### 12.5 Conflict Detection

Conflict exists when:

Branch Delta modifies a node that changed in canonical state after branch creation.

Conflicts include:

* entity conflict
* interface conflict
* dependency conflict
* invariant conflict

---

### 12.6 Conflict Resolution

Conflicts block merge.

Resolution options:

* accept canonical
* accept branch
* create merged mutation

Resolved mutations re-enter validation.

---

### 12.7 Canonical Update

Successful merge:

* applies validated deltas
* generates new graph version
* updates lineage
* archives branch

Branch lineage remains reconstructable.

---

### 12.8 Branch Invariants

Branches remain isolated.

Branches never mutate canonical state directly.

Merge requires validation.

Delta lineage remains immutable.

---

## 13. Repository Ingestion

### 13.1 Purpose

Repository ingestion converts existing software systems into canonical graph state.

Successful ingestion activates Iteration Mode.

---

### 13.2 Ingestion Pipeline

RepositoryIngestionStarted

Repository Analysis
→ Semantic Extraction
→ Graph Reconstruction
→ Validation
→ Canonicalization
→ RepositoryIngestionCompleted

---

### 13.3 Repository Analysis

Analysis operates against the entire repository.

Partial analysis prohibited.

Analysis identifies:

* entities
* interfaces
* flows
* dependencies
* architectural relationships

---

### 13.4 Graph Reconstruction

Reconstruction generates:

* graph nodes
* graph edges
* execution boundaries
* inferred invariants

Output enters validation.

---

### 13.5 Confidence Model

Reconstructed structures receive confidence scores.

High Confidence

Score ≥ 0.90

Eligible for validation.

---

Medium Confidence

Score ≥ 0.70 and < 0.90

Marked for confirmation.

---

Low Confidence

Score < 0.70

Becomes Low-Confidence Structure.

Cannot become canonical.

---

### 13.6 Low-Confidence Lifecycle

Detected
→ Pending
→ Confirmed
or
Rejected
or
Escalated

Pending structures block Iteration Mode if graph validity depends on them.

---

### 13.7 Activation Conditions

Iteration Mode activates only when:

* reconstruction completes
* validation passes
* unresolved low-confidence structures do not affect graph validity
* canonical graph created

---

### 13.8 Ingestion Invariants

Repositories are source material only.

Canonical graph becomes authoritative after ingestion.

Repository state never becomes canonical state.

---

## 14. Deployment and Collaboration

### 14.1 Deployment Pipeline

DeploymentStarted

Target Validation
→ Artifact Preparation
→ Environment Validation
→ Deployment Execution
→ Health Verification

DeploymentCompleted

or

DeploymentFailed

---

### 14.2 Deployment Validation

Validation includes:

* runtime compatibility
* framework compatibility
* dependency compatibility
* execution-target compatibility

Validation failure blocks deployment.

---

### 14.3 Deployment Rollback

Rollback permitted after deployment failure.

Rollback restores:

* previous deployment reference
* deployment health state

Rollback does not alter graph state.

Rollback emits deployment events.

---

### 14.4 Concurrent Editing

Collaboration operates against semantic state.

Concurrent edits occur through:

* branch isolation
* delta tracking
* merge validation

Direct concurrent mutation of canonical graph prohibited.

---

### 14.5 Approval Object Schema

Approval contains:

* approval identifier
* approval type
* requesting actor
* affected scope
* mutation summary
* status
* creation timestamp
* expiration timestamp

Approval types:

* execution approval
* mutation approval
* merge approval

---

### 14.6 Approval Lifecycle

Created
→ Under Review
→ Approved

or

Rejected

or

Expired

Expired approvals require resubmission.

---

### 14.7 Approval Expiry

Execution approvals:

24 hours

Mutation approvals:

7 days

Merge approvals:

7 days

Expired approvals become invalid.

Associated workflows pause.

---

### 14.8 Workspace Collaboration

Workspace members may receive:

* view authority
* edit authority
* execution authority
* approval authority
* merge authority

Permissions are evaluated before action execution.

---

### 14.9 Operational Visibility

Users may inspect:

* lifecycle state
* group state
* execution state
* deployment state
* validation state
* reconciliation state
* semantic diffs
* lineage history

Inspection is read-only.

---

### 14.10 System Invariants

Graph remains canonical.

Specifications remain primary.

Execution remains scoped.

Validation remains mandatory.

Reconciliation remains atomic.

Lineage remains reconstructable.

Branches remain delta-based.

Group state remains derived.

Architectural continuity remains preserved across all execution and iteration workflows.

END OF DOCUMENT

---