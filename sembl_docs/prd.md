# PRD — sembl v1

## Section 1 — Product Identity and Core Definition

---

## 1.1 Product Identity

### Product Name

sembl

### Product Category

Graph-driven semantic software engineering system.

### Primary Platform

Web application.

v1 supports browser-based interaction only.

No CLI, IDE plugin, desktop runtime, or SDK surface is included in v1 scope.

---

## 1.2 Core Definition

sembl is a graph-native AI software engineering system that transforms user intent into production-grade software systems through:

* structured specification generation
* canonical semantic graph construction
* graph-scoped execution orchestration
* persistent architectural state management
* invariant-governed iteration

The system treats:

* specifications as primary
* graph state as canonical
* execution as graph-constrained
* code as compiled output
* iteration as semantic graph mutation

rather than:

* prompt-driven file generation
* stateless AI coding workflows
* unconstrained regeneration
* repository-wide improvisational execution

---

## 1.3 Canonical Representation Model

The canonical persistent representation of a project is the semantic graph state defined by:

* entities
* interfaces
* integration contracts
* flows
* invariants
* dependencies
* architectural relationships
* validation structures
* execution boundaries

Code is non-canonical execution output.

Generated repositories MAY diverge temporarily during execution or reconciliation phases without mutating canonical graph state. 

---

## 1.4 Primary Product Objective

sembl operationalizes the V4.3 methodology into a production system capable of:

* generating maintainable software systems
* preserving architectural continuity under iteration
* enabling graph-governed software evolution
* executing against scoped semantic context
* reconstructing semantic state from existing repositories
* supporting long-term semantic iteration stability
* preventing architectural drift across repeated mutations

The system exists to solve the primary failure modes of AI-assisted engineering:

* semantic fragmentation
* architectural inconsistency
* duplicated abstractions
* uncontrolled regeneration
* recursive implementation drift
* context collapse
* local optimization over global coherence

---

## 1.5 Core Operational Thesis

Modern frontier models are already capable of substantial implementation generation.

The primary engineering bottleneck is:

* semantic persistence
* architectural continuity
* scoped reasoning
* deterministic orchestration
* invariant preservation
* controlled iteration
* execution locality

sembl addresses these bottlenecks through:

* structured specifications
* canonical graph state
* graph-scoped execution
* normalized semantic structures
* deterministic task orchestration
* validation-driven reconciliation

---

## 1.6 Canonical System Principle

The graph is the persistent architectural state of the software system.

All execution derives from graph state.

All mutations reconcile back into graph state.

The graph functions as:

* semantic memory
* architectural persistence layer
* execution constraint surface
* dependency representation
* orchestration substrate
* semantic compression layer

The graph is not visualization infrastructure.

Visualization systems in v1 are derived inspection surfaces over canonical graph state.

---

## 1.7 Code Ownership and Persistence Model

Generated code is user-owned execution output.

sembl does not persist:

* generated repositories
* generated source files
* build artifacts
* full execution contexts

sembl persists:

* specification documents
* graph state
* graph versions
* validation outputs
* architectural diffs
* deployment references
* repository references
* commit references

Version lineage is maintained through graph state and repository references rather than stored code snapshots.

---

## 1.8 Infrastructure Abstraction Principle

Infrastructure providers are non-canonical execution adapters.

The graph expresses capability requirements only.

Examples:

* authentication
* persistence
* queueing
* storage
* deployment

Execution targets resolve implementation providers.

Infrastructure providers are not graph entities.

Provider-specific implementation details remain outside canonical graph state.

---

## 1.9 v1 Scope Boundary

v1 includes:

* Documentation Mode
* Execution Mode
* Iteration Mode
* existing repository ingestion
* graph visualization
* approval-gated architectural mutation
* semantic branching
* architectural diffing
* validation and reconciliation flows
* workspace collaboration
* approval queues
* execution dashboards

v1 excludes:

* IDE plugins
* CLI execution surfaces
* infrastructure sandbox isolation
* autonomous production operations
* unrestricted self-modifying execution
* unmanaged infrastructure orchestration
* embedded/native targets
* granular real-time collaborative graph editing

---

## 1.10 Collaboration Model

Collaboration operates at workspace level.

v1 supports:

* multiple workspace members
* role-based permissions
* approval queues
* shared project visibility
* async semantic collaboration
* live execution visibility
* shared graph visualization
* branch-based collaboration

v1 does not support:

* Google Docs–style concurrent semantic editing
* real-time graph co-authoring
* simultaneous live mutation reconciliation

Mutation coordination occurs through:

* branch isolation
* approval workflows
* reconciliation validation
* semantic diff resolution

---

## 1.11 Branching Model

v1 supports:

* whole-graph branching
* subgraph branching
* feature-scoped branching

Branching operates on canonical graph state rather than repositories.

Branches maintain:

* semantic lineage
* graph version history
* architectural diff history
* reconciliation metadata

Branch merges require:

* invariant validation
* dependency validation
* interface continuity validation
* conflict reconciliation

---

## 1.12 Interaction Surface Model

### Documentation Mode

Primary interaction surface:

* conversational specification generation

Secondary interaction surfaces:

* document editing
* structured specification review
* artifact upload
* approval confirmation

---

### Execution Mode

Primary interaction surface:

* workflow-oriented execution dashboard

Includes:

* execution state
* task progress
* validation outputs
* reconciliation summaries
* deployment status
* architectural diffs

---

### Iteration Mode

Primary interaction surface:

* mutation and execution workflow dashboard

Includes:

* semantic diffs
* branch management
* mutation approvals
* affected scope summaries
* execution lineage
* reconciliation history

---

## 1.13 Repository Ingestion Principle

Existing repositories MAY bypass Documentation Mode.

Repository ingestion targets near-lossless reconstruction of explicitly expressed semantic structures.

The system reconstructs:

* entities
* interfaces
* flows
* dependencies
* architectural relationships
* integration structures

Implicit conventions or ambiguous structures are surfaced as low-confidence semantic nodes requiring user confirmation before Iteration Mode activation.

Partial repository ingestion is disallowed.

Global repository understanding is mandatory for:

* dependency integrity
* architectural continuity
* invariant preservation

---

## 1.15 Canonical Execution Principle

Execution is graph-scoped and DAG-driven.

Execution context generation is enforced primarily through:

* graph slicing
* dependency traversal
* invariant-scoped locality
* feature-scoped context generation

Worker execution context MUST NOT derive from unrestricted repository scanning.

Stateless feature-scoped workers receive only:

* assigned task scope
* direct dependencies
* required interfaces
* required invariants
* localized execution context

---

## 1.16 Canonical Approval Model

v1 contains exactly two approval gates.

### Approval Gate 1 — Pre-Execution Confirmation

Occurs after Documentation Mode completion and before execution begins.

The user confirms:

* specification summary
* execution targets
* architectural assumptions
* inferred structures

Execution cannot begin before confirmation.

---

### Approval Gate 2 — Architectural Mutation Confirmation

Occurs during Iteration Mode when architectural mutation detection triggers.

Approval-gated mutations include:

* entity additions/removals
* entity renames
* interface additions/removals
* interface renames
* dependency restructuring
* execution-target migration
* invariant-affecting mutations

Re-execution cannot proceed before approval.

---

## Section 2 — Product Scope and Capability Boundaries

---

## 2.1 Scope Definition

sembl v1 is a web-based graph-driven semantic software engineering system that supports:

* specification generation
* semantic graph construction
* graph-scoped execution orchestration
* repository ingestion
* semantic iteration
* validation-driven reconciliation
* deployment orchestration
* semantic collaboration
* architectural diffing
* graph visualization

The system operates through:

* Documentation Mode
* Execution Mode
* Iteration Mode

---

## 2.2 Included Software Targets

v1 supports generation and iteration of:

### Full-Stack Web Applications

Including:

* frontend applications
* backend APIs
* authentication systems
* persistence systems
* workflow systems
* dashboard systems

---

### Mobile Applications

Limited to managed execution-target ecosystems.

Initial target examples:

* Expo
* React Native managed workflows

---

### API and Backend Systems

Including:

* REST systems
* async workflow systems
* database-backed services
* authentication services
* orchestration services

---

## 2.3 Included Core Capabilities

### Specification Generation

The system MUST support generation and refinement of:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

Generated specifications MUST remain:

* graph-extractable
* invariant-compatible
* semantically normalized
* execution-ready

---

### Semantic Graph Construction

The system MUST:

* extract semantic structures from specifications
* generate canonical graph state
* normalize graph structures
* validate graph invariants
* generate graph-local execution context

Canonical graph structures MUST include:

* entities
* interfaces
* integration contracts
* flows
* dependencies
* invariants
* architectural relationships
* validation structures

---

### Graph Visualization

v1 includes graph visualization capabilities.

Visualization is a derived inspection layer over canonical graph state.

Visualization MUST support:

* entity inspection
* interface inspection
* dependency traversal
* flow visualization
* architectural relationship visualization
* branch comparison visibility
* mutation visibility
* validation issue highlighting

Visualization MUST NOT:

* mutate graph state directly
* function as canonical editing surface
* bypass specification-driven mutation flow

All mutations continue through structured semantic workflows.

---

### Scoped Execution Orchestration

The system MUST:

* generate execution DAGs
* execute through scoped workers
* preserve architectural continuity
* enforce dependency locality
* enforce invariant-scoped execution

Execution MUST remain:

* DAG-driven
* graph-scoped
* dependency-aware
* invariant-aware
* topologically ordered

---

### Validation and Reconciliation

The system MUST:

* validate graph structures
* validate interface contracts
* validate dependency integrity
* validate invariant preservation
* reconcile execution outputs into graph state

Validation MUST occur:

* before execution
* during execution
* after execution
* during reconciliation
* during iteration merge operations

---

### Semantic Iteration

The system MUST support:

* specification mutation
* graph mutation
* scoped task regeneration
* scoped re-execution
* semantic versioning
* architectural diff generation

The system MUST preserve:

* interface continuity
* dependency continuity
* entity continuity
* architectural coherence
* graph lineage

---

### Repository Ingestion

The system MUST support ingestion of existing repositories into semantic iteration workflows.

Repository ingestion MUST:

* ingest entire repositories
* reconstruct semantic structures
* infer architectural relationships
* reconstruct interfaces and entities
* identify ambiguity gaps
* surface low-confidence structures for user confirmation

Repository ingestion MUST target near-lossless reconstruction of explicitly expressed semantics.

---

### Collaboration

v1 collaboration operates through workspace-scoped async semantic workflows.

Supported collaboration structures:

* workspaces
* members
* permissions
* approval queues
* shared visibility
* branch workflows
* semantic reviews
* architectural review flows

v1 collaboration does not include:

* concurrent live semantic editing
* real-time graph mutation reconciliation
* multi-user simultaneous graph mutation sessions

---

### Semantic Branching

v1 supports:

* whole-graph branches
* subgraph branches
* feature-scoped branches

Branch operations MUST preserve:

* graph lineage
* dependency integrity
* reconciliation history
* semantic diff history

Branch merges MUST validate:

* invariant compatibility
* dependency continuity
* interface integrity
* architectural compatibility

---

### Deployment Orchestration

The system MUST support deployment-aware execution targets.

Execution targets define:

* runtime assumptions
* deployment assumptions
* validation packs
* orchestration boundaries
* infrastructure capabilities

Infrastructure implementation remains adapter-level and non-canonical.

---

## 2.4 Included Execution Architecture Components

v1 agent architecture contains:

### Orchestrator Agent

Responsibilities:

* pipeline coordination
* execution lifecycle management
* architectural oversight
* mutation routing
* approval routing

---

### Planner Agent

Responsibilities:

* task DAG generation
* dependency resolution
* graph slicing
* execution scope resolution
* worker context generation

---

### Validator Agent

Responsibilities:

* invariant validation
* structural validation
* semantic validation
* reconciliation validation
* execution verification

Validation MUST operate through multi-pass validation procedures.

---

### Reconciliation Agent

Responsibilities:

* graph updates
* diff generation
* semantic reconciliation
* lineage updates
* version updates

---

### Stateless Worker Agents

Responsibilities:

* scoped task execution
* localized implementation generation
* interface-constrained execution
* dependency-local implementation updates

Workers MUST receive only:

* localized task scope
* required interfaces
* direct dependencies
* required invariants
* execution-local context

Workers MUST remain stateless.

---

## 2.5 Excluded v1 Scope

### Infrastructure Orchestration

v1 excludes:

* arbitrary unmanaged infrastructure provisioning
* low-level cloud orchestration
* autonomous infrastructure optimization
* infrastructure-as-code orchestration systems

---

### Autonomous Self-Modifying Systems

v1 excludes:

* unrestricted autonomous graph mutation
* self-directed architectural rewriting
* unsupervised invariant modification
* uncontrolled self-improving execution systems

---

### Execution Isolation Infrastructure

v1 excludes:

* isolated infrastructure sandboxes
* per-worker runtime isolation
* container-level semantic execution boundaries

Execution isolation in v1 is enforced through scoped semantic context only.

---

### Native Development Targets

v1 excludes:

* embedded systems
* unmanaged native systems
* game engine pipelines
* OS-native runtime orchestration

---

### Real-Time Semantic Co-Editing

v1 excludes:

* simultaneous live graph mutation
* Google Docs–style collaboration
* concurrent semantic editing synchronization
* real-time semantic merge systems

---

### Direct Graph Mutation Interfaces

v1 excludes:

* raw graph editing interfaces
* unrestricted node manipulation
* direct graph mutation APIs for users

Graph mutation MUST occur through:

* specification mutation
* structured workflow mutation
* validated reconciliation flows

---

## 2.6 Canonical Capability Constraints

### Constraint — Graph Canonicality

The graph remains canonical under all execution conditions.

Repositories and generated code are non-canonical execution artifacts.

---

### Constraint — Specification Primacy

Execution MUST derive from validated specification state.

Execution MUST NOT originate from unconstrained prompts.

---

### Constraint — Scoped Intelligence

Workers MUST NOT receive unrestricted repository context.

Execution locality MUST derive from graph slicing and dependency traversal.

---

### Constraint — Validation Enforcement

Validation failures MUST block successful execution completion.

Invariant violations MUST block reconciliation completion.

---

### Constraint — Architectural Continuity

Iteration MUST preserve:

* semantic continuity
* dependency integrity
* interface continuity
* graph lineage
* architectural identity

---

## 2.7 Success Boundary for v1

v1 succeeds if the system can:

* generate coherent production-grade systems
* preserve architectural continuity under iteration
* reconstruct semantic structures from repositories
* execute through scoped semantic context
* maintain graph consistency across long cycles
* support semantic collaboration workflows
* outperform stateless vibe-coding workflows in maintainability and iteration stability

while preserving graph state as canonical architectural state.

---

## Section 3 — Operational Modes and State Transitions

---

## 3.1 Canonical Operational Model

sembl operates as a persistent semantic state system with three canonical operational modes:

* Documentation Mode
* Execution Mode
* Iteration Mode

The system transitions between modes through validation-governed state transitions.

All transitions MUST be:

* explicit
* state-validatable
* invariant-aware
* graph-reconcilable

---

## 3.2 Canonical State Flow

```text
Project Creation
→ Documentation Mode
→ Specification Validation
→ Graph Construction
→ Pre-Execution Approval
→ Execution Mode
→ Reconciliation
→ Iteration Mode
→ Mutation
→ Scoped Re-Execution
→ Reconciliation
→ Iteration Mode
```

Existing repositories MAY enter through Repository Ingestion Flow.

---

# 3.3 Documentation Mode

## Purpose

Transform ambiguous user intent into validated executable specification state.

Documentation Mode is the semantic specification construction phase.

No execution occurs during Documentation Mode.

---

## Inputs

Documentation Mode accepts:

* conversational prompts
* uploaded documents
* screenshots
* wireframes
* Figma exports
* architectural notes
* workflow descriptions
* behavioral descriptions
* repositories (optional)
* existing specifications

---

## Responsibilities

The system MUST:

* generate structured specifications
* infer missing specification structures
* normalize terminology
* resolve semantic ambiguity
* detect missing invariants
* infer architectural relationships
* generate execution-ready specification state

---

## Output Artifacts

Documentation Mode outputs:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

Outputs MUST remain:

* semantically normalized
* graph-extractable
* invariant-compatible
* execution-compatible

---

## Interaction Surface

Primary interaction surface:

* conversational semantic refinement

Secondary surfaces:

* structured specification review
* artifact inspection
* approval review
* document editing

---

## Validation Requirements

Documentation Mode validation MUST include:

* specification completeness validation
* invariant validation
* undefined structure detection
* naming normalization
* interface completeness validation
* dependency consistency validation

---

## Exit Conditions

Documentation Mode exits only when:

* specifications validate successfully
* graph extraction readiness passes
* Design Artifacts are locked
* invariant validation succeeds
* unresolved semantic ambiguity is cleared

---

## Transition — Documentation → Execution

Transition occurs only after:

* graph construction succeeds
* validation passes
* pre-execution approval is confirmed

---

## Transition — Documentation → Escalation

Escalation occurs when:

* semantic convergence repeatedly fails
* invariant conflicts remain unresolved
* graph extraction repeatedly fails
* required specification state remains incomplete

---

# 3.4 Execution Mode

## Purpose

Transform validated semantic graph state into deployable execution outputs.

Execution Mode is the deterministic orchestration phase.

---

## Canonical Execution Flow

```text
Validated Specifications
→ Concept Graph Construction
→ Graph Normalization
→ Validation
→ Task DAG Generation
→ Scoped Execution
→ Validation
→ Reconciliation
→ Deployment
→ Iteration Activation
```

---

## Responsibilities

The system MUST:

* generate normalized graph state
* construct execution DAGs
* resolve scoped execution context
* execute task nodes
* validate execution outputs
* reconcile outputs into graph state
* generate deployment references
* generate architectural diffs

---

## Execution Characteristics

Execution MUST remain:

* DAG-based
* topologically ordered
* graph-scoped
* dependency-aware
* invariant-aware
* validation-constrained
* reconciliation-governed

---

## Execution Context Rules

Worker execution context MUST derive from:

* graph slicing
* dependency traversal
* interface locality
* invariant locality
* task-local execution scope

Workers MUST NOT receive:

* unrestricted repository context
* full graph context
* unrelated execution scopes

---

## Execution Visibility

Execution Mode MUST expose:

* execution progress
* task state
* validation summaries
* failure state
* reconciliation summaries
* deployment state
* architectural diffs

---

## Validation Responsibilities

Execution validation MUST include:

* compile validation
* type validation
* invariant validation
* dependency validation
* interface contract validation
* integration validation
* undefined reference validation
* runtime-target validation

---

## Deployment Responsibilities

Deployment execution MUST:

* execute through target adapters
* validate runtime assumptions
* generate deployment references
* generate deployment metadata
* preserve graph lineage references

Deployments are non-canonical execution outputs.

---

## Exit Conditions

Execution Mode exits only when one of the following occurs:

### Successful Completion

Occurs when:

* execution succeeds
* validation passes
* reconciliation succeeds
* deployment succeeds

System transitions to Iteration Mode.

---

### Escalation

Occurs when:

* invariant failures persist
* execution repeatedly fails
* reconciliation repeatedly fails
* validation cannot converge

---

## Transition — Execution → Iteration

Transition occurs after:

* successful reconciliation
* persistent graph state update
* version lineage creation
* deployment reference creation

---

# 3.5 Iteration Mode

## Purpose

Enable long-term software evolution through semantic graph mutation.

Iteration Mode is the persistent operational state after first successful execution.

---

## Canonical Iteration Flow

```text
Mutation Request
→ Specification Mutation
→ Graph Mutation
→ Scope Resolution
→ Affected DAG Regeneration
→ Scoped Re-Execution
→ Validation
→ Reconciliation
→ Version Update
```

---

## Responsibilities

The system MUST:

* preserve graph continuity
* preserve interface continuity
* preserve dependency integrity
* preserve semantic lineage
* localize re-execution scope
* prevent uncontrolled regeneration

---

## Mutation Categories

### Automatic Mutations

Automatic mutations include:

* localized feature additions
* isolated UI modifications
* non-breaking interface extensions
* localized flow updates
* scoped behavioral updates

Automatic mutations proceed without approval unless invariant violations are detected.

---

### Approval-Gated Mutations

Approval-gated mutations include:

* entity additions
* entity removals
* entity renames
* interface additions
* interface removals
* interface renames
* dependency restructuring
* execution-target migration
* invariant-affecting mutations

Re-execution MUST pause until approval completes.

---

## Branching Responsibilities

Iteration Mode MUST support:

* whole-graph branches
* subgraph branches
* feature-scoped branches

Branch operations MUST preserve:

* graph lineage
* semantic version lineage
* dependency integrity
* reconciliation history

---

## Merge Validation Responsibilities

Branch merges MUST validate:

* invariant compatibility
* interface continuity
* dependency continuity
* graph consistency
* architectural compatibility

Conflicting merges MUST enter reconciliation workflows before merge completion.

---

## Collaboration Responsibilities

Iteration Mode collaboration MUST support:

* workspace review flows
* approval queues
* branch review workflows
* semantic diff review
* architectural review visibility

v1 collaboration remains async and branch-oriented.

---

## Persistent State Responsibilities

Iteration Mode maintains:

* graph versions
* semantic lineage
* branch lineage
* architectural diffs
* validation history
* deployment references
* reconciliation history

---

## Exit Conditions

Iteration Mode is persistent and does not terminate unless:

* project deletion occurs
* workspace ownership transfer occurs
* graph state becomes unrecoverable

---

# 3.6 Repository Ingestion Flow

## Purpose

Enable existing repositories to enter semantic iteration workflows.

---

## Canonical Flow

```text
Repository Intake
→ Repository Analysis
→ Semantic Extraction
→ Graph Reconstruction
→ Confidence Analysis
→ Validation
→ User Resolution
→ Reconciliation
→ Iteration Mode
```

---

## Responsibilities

The system MUST:

* ingest entire repositories
* infer entities
* infer interfaces
* infer flows
* infer architectural relationships
* infer dependency structures
* infer execution boundaries

---

## Confidence Resolution

Ambiguous semantic structures MUST be surfaced as low-confidence nodes.

Low-confidence structures require user confirmation before:

* graph finalization
* reconciliation completion
* Iteration Mode activation

---

## Validation Requirements

Repository ingestion validation MUST include:

* dependency validation
* interface validation
* architectural consistency validation
* invariant validation
* undefined structure detection
* duplicate structure detection

---

## Constraints

Partial repository ingestion is disallowed.

Repository reconstruction MUST preserve:

* architectural continuity
* dependency integrity
* semantic consistency
* execution validity

---

# 3.7 Escalation State

## Purpose

Prevent invalid semantic state progression.

Escalation State is entered when deterministic convergence cannot be achieved automatically.

---

## Escalation Triggers

Escalation occurs when:

* invariant conflicts persist
* validation repeatedly fails
* reconciliation repeatedly fails
* semantic ambiguity cannot converge
* merge conflicts remain unresolved
* repository reconstruction remains incomplete

---

## Escalation Actions

Escalation workflows MAY include:

* manual specification review
* manual invariant resolution
* user clarification requests
* manual graph reconciliation
* architectural override confirmation

---

## Exit Conditions

Escalation exits only after:

* validation succeeds
* conflicts resolve
* invariant compatibility restores
* reconciliation completes

---

## Section 4 — Core System Behavior and Product Flows

---

# 4.1 Canonical System Behavior

sembl behaves as a persistent semantic orchestration system.

The system continuously maintains alignment between:

* specification state
* graph state
* execution state
* validation state
* reconciliation state
* deployment lineage

All user-visible operations are mediated through graph-governed workflows.

The system MUST prevent:

* uncontrolled regeneration
* semantic divergence
* invariant-breaking execution
* dependency corruption
* interface inconsistency
* architecture-local optimization that violates global continuity

---

# 4.2 Canonical Product Flow

## New Project Flow

```text id="d3m6xq"
Project Creation
→ Documentation Mode
→ Specification Generation
→ Validation
→ Graph Extraction Readiness
→ Pre-Execution Approval
→ Execution Mode
→ Deployment
→ Iteration Mode
```

---

## Existing Repository Flow

```text id="9n7vxa"
Repository Intake
→ Repository Analysis
→ Semantic Reconstruction
→ Confidence Resolution
→ Validation
→ Graph Reconciliation
→ Iteration Mode
```

---

## Iteration Flow

```text id="8e3pzm"
Mutation Request
→ Scope Resolution
→ Graph Mutation
→ DAG Regeneration
→ Scoped Re-Execution
→ Validation
→ Reconciliation
→ Version Update
```

---

# 4.3 Documentation Mode Behavior

## Intent Interpretation

The system MUST transform ambiguous user intent into structured specification state.

The system MUST:

* infer missing technical structures
* normalize inconsistent terminology
* detect undefined architectural assumptions
* identify missing flows
* identify incomplete interfaces
* identify missing entities
* infer execution targets when unspecified

The system MUST surface assumptions before execution readiness.

---

## Conversational Refinement Behavior

Documentation conversations MUST behave as semantic refinement workflows rather than raw chat interactions.

Each conversational mutation MUST reconcile into:

* specification state
* semantic relationships
* architectural assumptions
* behavioral definitions
* validation structures

The system MUST maintain continuity across conversations without reconstructing architecture from scratch.

---

## Specification Dependency Behavior

Specification documents MUST remain semantically linked.

Mutations to one specification MAY invalidate others.

Examples:

* DB schema mutation MAY invalidate API contracts
* interface mutation MAY invalidate flows
* architecture mutation MAY invalidate deployment assumptions

The system MUST detect affected specification scopes automatically.

---

## Design Artifact Behavior

Design Artifacts become immutable after Documentation Mode completion.

Execution MUST derive UI implementation strictly from locked Design Artifacts.

UI mutation during Execution Mode is disallowed.

UI changes MUST re-enter through Iteration Mode.

---

# 4.4 Graph Construction Behavior

## Canonical Graph Generation

The system MUST transform validated specifications into canonical graph state.

The graph MUST contain:

* entities
* interfaces
* integration contracts
* flows
* dependencies
* invariants
* validation structures
* execution boundaries
* branch lineage references

---

## Graph Normalization Behavior

Normalization MUST execute through deterministic multi-pass processing.

Normalization passes MUST include:

### Structural Pass

Validates:

* entity completeness
* interface completeness
* schema validity
* reference validity

---

### Consistency Pass

Validates:

* naming consistency
* duplication
* semantic conflicts
* undefined structures

---

### Mapping Pass

Validates:

* entity reuse
* interface reuse
* dependency reuse
* relationship correctness

---

### Completeness Pass

Validates:

* example completeness
* interface coverage
* validation coverage
* missing requirements

---

## Validation Loop Behavior

Validation MUST operate iteratively until:

* zero invariant violations remain
  or
* escalation thresholds trigger

Validation violations MUST remain structured and graph-addressable.

---

# 4.5 Execution Behavior

## Task DAG Generation

The Planner Agent MUST transform normalized graph state into execution DAGs.

Each task MUST define:

* dependencies
* execution order
* required interfaces
* required entities
* required invariants
* execution scope
* expected outputs

Circular task dependencies are disallowed.

---

## Scoped Execution Behavior

Execution MUST occur through stateless scoped workers.

Workers MUST receive:

* localized graph slices
* direct dependency context
* relevant interfaces
* invariant-local context
* task-specific execution structures

Workers MUST NOT receive:

* unrestricted repository access
* unrelated feature context
* global execution state

---

## Worker Execution Behavior

Workers MUST:

* implement only assigned scope
* preserve interface contracts
* preserve dependency integrity
* preserve architectural continuity
* avoid undefined abstraction creation

Workers MUST NOT:

* redefine unrelated structures
* mutate unrelated interfaces
* introduce undefined dependencies
* invent undefined logic

---

## Orchestrator Behavior

The Orchestrator Agent MUST:

* coordinate lifecycle state
* coordinate approvals
* route execution phases
* monitor convergence
* trigger escalation flows
* coordinate reconciliation

The Orchestrator Agent owns global execution continuity.

---

## Planner Behavior

The Planner Agent MUST:

* resolve dependency locality
* slice execution scope
* generate task DAGs
* determine affected re-execution scope
* generate worker-local execution context

---

## Validator Behavior

The Validator Agent MUST:

* validate invariants
* validate interface contracts
* validate dependency integrity
* validate runtime assumptions
* validate reconciliation correctness

Validation MUST operate through multi-pass validation procedures.

---

## Reconciliation Behavior

The Reconciliation Agent MUST:

* reconcile execution outputs into graph state
* generate semantic diffs
* update lineage
* preserve graph continuity
* preserve version history
* reconcile branch mutations

The graph remains canonical during reconciliation.

---

# 4.6 Validation Behavior

## Validation Enforcement

Validation failures MUST block:

* execution completion
* reconciliation completion
* merge completion
* deployment completion

---

## Interface Validation Behavior

Each interface MUST validate:

* input schema
* output schema
* success examples
* failure examples
* preconditions
* postconditions

Interfaces violating invariants are invalid execution surfaces.

---

## Integration Contract Validation

Integration Contracts MUST validate:

* ordered execution flow
* explicit data mapping
* dependency continuity
* error propagation
* rollback behavior

Implicit flow mappings are disallowed.

---

## Runtime Validation

Execution targets MUST validate:

* runtime compatibility
* dependency compatibility
* deployment compatibility
* framework compatibility
* adapter compatibility

---

# 4.7 Iteration Behavior

## Mutation Resolution Behavior

Mutation requests MUST resolve into:

* specification mutations
* graph mutations
* affected scope determination
* scoped task regeneration

The system MUST avoid full-system regeneration unless explicitly required.

---

## Architectural Continuity Behavior

Iteration MUST preserve:

* entity identity
* interface continuity
* dependency lineage
* semantic continuity
* graph history

Iteration MUST extend architecture rather than reconstruct unrelated structures.

---

## Approval-Gated Mutation Behavior

Architectural mutations MUST pause execution until approval completes.

Approval review MUST expose:

* affected graph scopes
* dependency impact
* interface impact
* execution impact
* architectural diff summaries

---

## Branching Behavior

Branching operates on canonical graph state.

Branch operations MUST preserve:

* lineage references
* semantic continuity
* dependency integrity
* reconciliation history

Subgraph branches MUST remain dependency-validatable.

---

## Merge Behavior

Merges MUST validate:

* invariant compatibility
* dependency continuity
* interface continuity
* architectural compatibility

Conflicting merges MUST enter reconciliation workflows.

---

# 4.8 Repository Ingestion Behavior

## Repository Analysis Behavior

Repository analysis MUST operate globally rather than feature-locally.

The system MUST reconstruct:

* entities
* interfaces
* dependencies
* architectural boundaries
* runtime assumptions
* integration flows

---

## Confidence Modeling Behavior

Ambiguous structures MUST generate low-confidence semantic nodes.

Low-confidence nodes MUST expose:

* inferred structure
* confidence reason
* unresolved dependency context
* required user confirmation

---

## Ingestion Validation Behavior

Repository ingestion MUST validate reconstructed graph state before Iteration Mode activation.

Invalid reconstruction state MUST block activation.

---

# 4.9 Collaboration Behavior

## Workspace Collaboration Behavior

Workspace members MAY:

* inspect graph state
* inspect diffs
* inspect branches
* review mutations
* participate in approvals
* review execution state

Permissions MUST constrain mutation authority.

---

## Approval Queue Behavior

Approval queues MUST support:

* architectural mutation review
* branch merge review
* execution readiness review

Approvals MUST generate immutable audit lineage.

---

## Async Collaboration Constraint

v1 collaboration remains async.

Concurrent live semantic editing is disallowed.

Mutation coordination occurs through:

* branch isolation
* semantic diffs
* reconciliation workflows
* approval flows

---

# 4.10 Visualization Behavior

## Visualization Responsibilities

Graph visualization MUST support:

* dependency inspection
* flow inspection
* interface inspection
* branch inspection
* validation inspection
* architectural relationship inspection

Visualization is a derived inspection layer.

---

## Visualization Constraints

Visualization MUST NOT:

* directly mutate graph state
* bypass specification workflows
* bypass reconciliation workflows
* function as unrestricted graph editor

Canonical mutation pathways remain specification-governed.

---

# 4.11 Deployment Behavior

## Deployment Reference Behavior

Deployments are non-canonical runtime outputs.

sembl stores:

* deployment references
* deployment metadata
* runtime metadata
* graph lineage references

sembl does not store generated runtime artifacts.

---

## Deployment Failure Behavior

Deployment failures MUST NOT corrupt canonical graph state.

Failed deployments MAY trigger:

* rollback workflows
* reconciliation retries
* escalation flows

---

# 4.12 Escalation Behavior

Escalation workflows MUST activate when convergence cannot be achieved automatically.

Escalation conditions include:

* unresolved invariant conflicts
* repeated validation failure
* unresolved merge conflicts
* repeated reconciliation failure
* unresolved semantic ambiguity

Escalation workflows MAY require:

* manual review
* manual approval
* manual reconciliation
* specification clarification

---

## Section 5 — Functional Requirements

---

# 5.1 Functional Requirement Structure

Functional requirements define executable product behavior.

Each requirement MUST remain:

* graph-extractable
* validation-addressable
* execution-compatible
* invariant-compatible
* semantically localized

Requirements define:

* system responsibilities
* state transitions
* behavioral constraints
* validation behavior
* execution behavior

---

# 5.1A User Identity, Authentication, and Onboarding Requirements

## FR-5.1A.1 User Registration

The system MUST support user account creation.

Registration MUST support:

* email-based registration
* OAuth-based registration
* invitation-based workspace joining

User creation initializes:

* user identity
* default workspace membership
* session state
* onboarding state

---

## FR-5.1A.2 Authentication

The system MUST support authenticated access to workspace resources.

Authentication flows MUST support:

* session creation
* session validation
* session expiration
* session revocation

Authentication infrastructure providers remain adapter-level concerns.

---

## FR-5.1A.3 Session Management

The system MUST maintain authenticated session state for active users.

Session state MUST govern:

* workspace access
* project access
* mutation authority
* approval authority
* execution authority

Unauthorized execution access is disallowed.

---

## FR-5.1A.4 Workspace Initialization

Initial onboarding MUST initialize:

* default workspace
* default project context
* permission state
* onboarding progression state

Users MUST be able to:

* create a new project
* ingest an existing repository
* upload existing specifications

during onboarding completion.

---

## FR-5.1A.5 Onboarding Flow

The onboarding flow MUST guide users into:

* Documentation Mode
* repository ingestion
* template initialization

based on detected user intent.

The onboarding flow MUST remain minimally interruptive.

---

## FR-5.1A.6 Silent Technical Profiling

The system MAY infer technical context during onboarding through:

* uploaded artifacts
* repository analysis
* framework detection
* specification analysis
* interaction patterns

Detected context MAY initialize:

* execution target assumptions
* framework assumptions
* architectural assumptions
* runtime assumptions

Inferred assumptions MUST remain reviewable before execution readiness.

---

## FR-5.1A.7 User and Session Structures

The graph-extractable semantic model MUST include:

* User
* Workspace Membership
* Session
* Permission State
* Onboarding State

These structures govern authenticated behavioral flows and authorization boundaries.

---

# 5.2 Workspace and Project Management

## FR-5.2.1 Workspace Creation

The system MUST allow users to create workspaces.

A workspace MUST contain:

* members
* projects
* branches
* approvals
* graph lineage
* execution history

---

## FR-5.2.2 Workspace Permissions

The system MUST support role-based permissions.

Permissions MUST govern:

* project access
* mutation authority
* branch operations
* approval authority
* execution authority

---

## FR-5.2.3 Project Creation

The system MUST allow users to create projects through:

* conversational initialization
* repository ingestion
* template initialization

Project creation initializes canonical semantic state.

---

## FR-5.2.4 Project State Persistence

The system MUST persist:

* specifications
* graph state
* graph versions
* branch lineage
* validation history
* deployment references
* architectural diffs

The system MUST NOT persist generated source repositories.

---

# 5.3 Documentation Mode Requirements

## FR-5.3.1 Conversational Specification Generation

The system MUST support conversational specification generation.

Conversational flows MUST reconcile into structured specification state.

Generated structures MUST remain:

* semantically normalized
* graph-extractable
* invariant-compatible

---

## FR-5.3.2 Specification Generation Scope

The system MUST support generation of:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

---

## FR-5.3.3 Specification Mutation

Users MUST be able to mutate generated specifications through:

* conversational prompts
* structured edits
* mutation review workflows

Mutations MUST propagate affected dependency scopes automatically.

---

## FR-5.3.4 Specification Dependency Detection

The system MUST detect cross-specification dependency impact.

Examples:

* DB schema changes affecting APIs
* interface changes affecting flows
* architecture changes affecting execution targets

Affected scopes MUST be surfaced before execution readiness.

---

## FR-5.3.5 Assumption Detection

The system MUST surface inferred assumptions before execution begins.

Examples:

* inferred runtime assumptions
* inferred architecture assumptions
* inferred entity relationships
* inferred deployment assumptions

---

## FR-5.3.6 Specification Validation

The system MUST validate:

* completeness
* invariant compatibility
* undefined references
* naming consistency
* interface completeness
* dependency consistency

Validation failures MUST block Execution Mode transition.

---

## FR-5.3.7 Design Artifact Locking

Design Artifacts MUST become immutable before execution begins.

Execution MUST derive UI implementation from locked Design Artifacts only.

---

## FR-5.3.8 Pre-Execution Approval

The system MUST require user confirmation before execution activation.

Approval review MUST expose:

* specification summary
* inferred assumptions
* execution targets
* architectural assumptions
* validation summaries

Execution MUST remain blocked until approval completes.

---

# 5.4 Graph Construction Requirements

## FR-5.4.1 Graph Construction

The system MUST construct canonical graph state from validated specifications.

The graph MUST contain:

* entities
* interfaces
* integration contracts
* flows
* dependencies
* invariants
* validation structures
* execution boundaries

---

## FR-5.4.2 Graph Normalization

The system MUST execute deterministic normalization passes.

Normalization MUST include:

* structural normalization
* consistency normalization
* mapping normalization
* completeness normalization

---

## FR-5.4.3 Graph Validation

The system MUST validate graph invariants through multi-pass validation procedures.

Validation MUST detect:

* duplicate structures
* undefined structures
* vague fields
* invalid references
* inconsistent naming
* invalid interface contracts

---

## FR-5.4.4 Validation Violation Reporting

Validation violations MUST remain structured and graph-addressable.

Violation outputs MUST include:

* invariant identifier
* affected structure
* violation reason
* graph location

---

## FR-5.4.5 Graph Versioning

The system MUST maintain versioned graph state.

Version lineage MUST preserve:

* mutation history
* reconciliation history
* branch lineage
* architectural diffs

---

# 5.5 Execution Requirements

## FR-5.5.1 Task DAG Generation

The Planner Agent MUST generate execution DAGs from normalized graph state.

Each task MUST define:

* dependencies
* execution order
* required interfaces
* required entities
* required invariants
* expected outputs

Circular dependencies are disallowed.

---

## FR-5.5.2 Scoped Context Generation

The system MUST generate graph-scoped execution context for workers.

Execution context MUST derive from:

* graph slicing
* dependency traversal
* interface locality
* invariant locality

---

## FR-5.5.3 Stateless Worker Execution

Workers MUST remain stateless.

Workers MUST receive only:

* assigned execution scope
* required interfaces
* direct dependencies
* task-local execution context

Workers MUST NOT receive unrestricted repository context.

---

## FR-5.5.4 Contract-Constrained Execution

Workers MUST preserve:

* interface contracts
* dependency integrity
* invariant validity
* architectural continuity

Workers MUST NOT invent undefined abstractions.

---

## FR-5.5.5 Execution Monitoring

The system MUST expose execution visibility including:

* execution progress
* task state
* validation state
* reconciliation state
* deployment state
* failure state

---

## FR-5.5.6 Execution Failure Handling

Execution failures MUST trigger:

* validation analysis
* reconciliation analysis
* retry eligibility analysis
* escalation eligibility analysis

Execution failures MUST NOT corrupt canonical graph state.

---

# 5.6 Validation and Reconciliation Requirements

## FR-5.6.1 Interface Validation

Each interface MUST validate:

* input schema
* output schema
* success examples
* failure examples
* preconditions
* postconditions

---

## FR-5.6.2 Integration Contract Validation

Integration Contracts MUST validate:

* ordered execution
* explicit field mapping
* dependency continuity
* rollback rules
* error propagation rules

Implicit mappings are disallowed.

---

## FR-5.6.3 Runtime Validation

Execution targets MUST validate:

* runtime compatibility
* dependency compatibility
* framework compatibility
* deployment compatibility

---

## FR-5.6.4 Validation Enforcement

Validation failures MUST block:

* execution completion
* reconciliation completion
* deployment completion
* merge completion

---

## FR-5.6.5 Reconciliation

The Reconciliation Agent MUST reconcile execution outputs into graph state.

Reconciliation MUST preserve:

* graph continuity
* lineage continuity
* architectural continuity
* semantic consistency

---

## FR-5.6.6 Architectural Diff Generation

The system MUST generate architectural diffs after reconciliation.

Diffs MUST expose:

* entity mutations
* interface mutations
* dependency mutations
* execution-target mutations
* flow mutations

---

# 5.7 Iteration Requirements

## FR-5.7.1 Mutation-Based Iteration

Iteration MUST operate through semantic mutation workflows rather than unrestricted regeneration.

Mutation flows MUST resolve into:

* specification mutations
* graph mutations
* scoped re-execution

---

## FR-5.7.2 Affected Scope Resolution

The system MUST determine affected execution scope automatically.

Affected scope detection MUST include:

* dependency impact
* interface impact
* invariant impact
* execution impact

---

## FR-5.7.3 Scoped Task Regeneration

The system MUST regenerate only affected task graph scopes unless full regeneration is explicitly required.

---

## FR-5.7.4 Architectural Mutation Detection

The system MUST detect approval-gated architectural mutations.

Detection MUST include:

* entity mutations
* interface mutations
* dependency restructuring
* invariant-affecting mutations
* execution-target migrations

---

## FR-5.7.5 Architectural Mutation Approval

Execution MUST pause until approval completes for approval-gated mutations.

Approval review MUST expose:

* affected scopes
* architectural diffs
* dependency impact
* execution impact

---

## FR-5.7.6 Semantic Lineage Preservation

Iteration MUST preserve:

* graph lineage
* branch lineage
* semantic continuity
* dependency continuity
* interface continuity

---

# 5.8 Branching and Merge Requirements

## FR-5.8.1 Semantic Branching

The system MUST support:

* whole-graph branching
* subgraph branching
* feature-scoped branching

Branches operate on canonical graph state.

---

## FR-5.8.2 Branch Isolation

Branch mutations MUST remain isolated until reconciliation or merge completion.

---

## FR-5.8.3 Merge Validation

Branch merges MUST validate:

* invariant compatibility
* interface continuity
* dependency continuity
* graph consistency

---

## FR-5.8.4 Conflict Resolution

Conflicting merges MUST enter reconciliation workflows before merge completion.

---

# 5.9 Repository Ingestion Requirements

## FR-5.9.1 Full Repository Ingestion

The system MUST ingest repositories globally rather than feature-locally.

Partial repository ingestion is disallowed.

---

## FR-5.9.2 Semantic Reconstruction

Repository ingestion MUST reconstruct:

* entities
* interfaces
* flows
* dependencies
* architectural relationships

---

## FR-5.9.3 Confidence Analysis

Ambiguous structures MUST generate low-confidence semantic nodes.

Low-confidence nodes MUST require user confirmation before Iteration Mode activation.

---

## FR-5.9.4 Ingestion Validation

Repository reconstruction MUST validate:

* dependency consistency
* interface validity
* invariant compatibility
* graph completeness

---

# 5.10 Collaboration Requirements

## FR-5.10.1 Workspace Collaboration

Workspace members MUST be able to:

* inspect graph state
* inspect branches
* inspect diffs
* review mutations
* review execution state

---

## FR-5.10.2 Approval Queues

The system MUST support approval queues for:

* execution readiness
* architectural mutations
* branch merges

---

## FR-5.10.3 Audit Lineage

Approvals MUST generate immutable lineage records.

---

## FR-5.10.4 Permission Enforcement

Permissions MUST constrain:

* mutation authority
* merge authority
* execution authority
* approval authority

---

# 5.11 Visualization Requirements

## FR-5.11.1 Graph Visualization

The system MUST support visualization of:

* entities
* interfaces
* dependencies
* flows
* branches
* validation state
* architectural relationships

---

## FR-5.11.2 Visualization Constraints

Visualization MUST NOT:

* directly mutate graph state
* bypass validation workflows
* bypass reconciliation workflows

Visualization remains inspection-only in v1.

---

# 5.12 Deployment Requirements

## FR-5.12.1 Deployment References

The system MUST persist:

* deployment references
* deployment metadata
* runtime metadata
* graph lineage references

The system MUST NOT persist generated runtime artifacts.

---

## FR-5.12.2 Deployment Validation

Deployment workflows MUST validate:

* runtime assumptions
* framework compatibility
* adapter compatibility
* deployment target compatibility

---

## FR-5.12.3 Deployment Failure Handling

Deployment failures MUST NOT mutate canonical graph state.

Deployment failures MAY trigger:

* rollback workflows
* reconciliation retries
* escalation flows

---

## Section 6 — Canonical Data and Semantic Structures

---

# 6.1 Canonical Representation Principle

The semantic graph is the canonical persistent representation of the system.

All execution, reconciliation, branching, validation, and iteration derive from graph state.

Non-canonical representations include:

* generated repositories
* generated code
* deployment artifacts
* runtime execution state
* temporary worker context

Canonical structures MUST remain deterministic, normalized, and graph-addressable.

---

# 6.2 Canonical Semantic Structures

The graph MUST support the following canonical structures:

* entities
* interfaces
* integration contracts
* flows
* dependencies
* invariants
* execution boundaries
* validation structures
* branch lineage
* reconciliation lineage
* architectural diffs

All structures MUST remain JSON-representable and validation-addressable.

---

# 6.3 Entity Structure

## Definition

An Entity is a reusable structured data object.

Entities define canonical reusable semantic data structures.

---

## Entity Requirements

Each entity MUST contain:

* unique identifier
* canonical name
* typed fields
* field constraints
* lineage metadata
* relationship metadata

---

## Entity Constraints

Entities MUST:

* contain at least one field
* use explicit field types
* remain reusable across interfaces
* avoid UI-local temporary state
* avoid ambiguous field naming

Entities MUST NOT:

* contain undefined field structures
* duplicate existing semantic structures
* encode execution-local implementation details

---

## Entity Mutation Rules

Entity mutations affecting:

* structure
* naming
* dependencies
* interface compatibility

MUST trigger architectural mutation detection.

---

# 6.4 Interface Structure

## Definition

An Interface is an executable semantic contract.

Interfaces define execution behavior boundaries.

---

## Interface Requirements

Each interface MUST define:

* unique identifier
* canonical name
* input schema
* output schema
* success examples
* failure examples
* preconditions
* postconditions
* referenced entities
* dependency references

---

## Interface Constraints

Interfaces MUST:

* remain schema-validatable
* remain invariant-validatable
* expose deterministic contracts
* reference canonical entities

Interfaces MUST NOT:

* expose undefined outputs
* contain implicit contracts
* bypass validation requirements

---

## Interface Continuity Rules

Interface-breaking mutations MUST:

* trigger approval workflows
* trigger affected scope analysis
* trigger dependency validation

---

# 6.5 Integration Contract Structure

## Definition

Integration Contracts define composition behavior across interfaces.

---

## Integration Contract Requirements

Each Integration Contract MUST define:

* ordered interface sequence
* explicit input mappings
* explicit output mappings
* dependency transitions
* error propagation rules
* rollback rules
* transaction behavior

---

## Integration Constraints

Integration Contracts MUST:

* use explicit field mappings
* preserve dependency continuity
* preserve interface compatibility
* remain validation-addressable

Implicit mappings are disallowed.

---

# 6.6 Flow Structure

## Definition

Flows define behavioral and execution progression across semantic structures.

Flows MAY represent:

* user interaction flows
* execution flows
* mutation flows
* approval flows
* reconciliation flows
* deployment flows

---

## Flow Requirements

Flows MUST define:

* trigger conditions
* participating structures
* transition conditions
* success transitions
* failure transitions
* terminal conditions

---

## Flow Constraints

Flows MUST remain:

* graph-extractable
* transition-validatable
* dependency-consistent

---

# 6.7 Invariant Structure

## Definition

Invariants are non-violable semantic correctness constraints.

Invariants govern:

* graph correctness
* execution correctness
* interface correctness
* dependency correctness
* reconciliation correctness

---

## Invariant Requirements

Each invariant MUST define:

* invariant identifier
* invariant scope
* validation rules
* violation conditions
* reconciliation requirements

---

## Invariant Enforcement

Invariant violations MUST block:

* execution completion
* reconciliation completion
* merge completion
* deployment completion

---

# 6.8 Dependency Structure

## Definition

Dependencies define semantic and execution relationships between graph structures.

Dependencies MAY exist between:

* entities
* interfaces
* flows
* execution scopes
* branches
* validation structures

---

## Dependency Constraints

Dependencies MUST remain:

* directional
* validation-addressable
* lineage-preserving

Circular execution dependencies are disallowed.

---

# 6.10 Graph Lineage Structure

## Definition

Graph lineage defines historical semantic continuity across versions and branches.

---

## Lineage Requirements

The system MUST preserve:

* mutation lineage
* reconciliation lineage
* branch lineage
* merge lineage
* execution lineage
* validation lineage

---

## Lineage Constraints

Lineage records MUST remain immutable after reconciliation completion.

---

# 6.11 Branch Structure

## Definition

Branches are isolated semantic graph evolution paths.

Branches operate on canonical graph state rather than repositories.

---

## Branch Requirements

Branches MUST preserve:

* graph lineage
* dependency continuity
* interface continuity
* invariant continuity

---

## Supported Branch Types

v1 supports:

* whole-graph branches
* subgraph branches
* feature-scoped branches

---

# 6.12 Semantic Diff Structure

## Definition

Semantic diffs represent structured architectural mutations between graph versions.

---

## Diff Requirements

Diffs MUST expose:

* entity mutations
* interface mutations
* dependency mutations
* flow mutations
* invariant mutations
* execution-target mutations

---

## Diff Constraints

Diffs MUST remain:

* graph-addressable
* reconciliation-addressable
* branch-compatible
* merge-compatible

---

# 6.13 Validation Structure

## Definition

Validation structures define deterministic semantic correctness enforcement.

---

## Validation Requirements

Validation MUST support:

* structural validation
* semantic validation
* invariant validation
* dependency validation
* reconciliation validation
* runtime validation

---

## Validation Output Requirements

Validation outputs MUST include:

* violation identifiers
* affected graph structures
* violation reasons
* reconciliation requirements

---

# 6.14 Execution Scope Structure

## Definition

Execution scopes define localized semantic execution boundaries.

Execution scopes are generated through:

* graph slicing
* dependency traversal
* invariant locality
* interface locality

---

## Execution Scope Constraints

Execution scopes MUST:

* minimize unrelated context exposure
* preserve required dependencies
* preserve interface continuity
* preserve invariant locality

---

# 6.15 Visualization Structure

## Definition

Visualization structures are derived inspection representations of graph state.

Visualization is non-canonical.

---

## Visualization Requirements

Visualization MUST support inspection of:

* entities
* interfaces
* dependencies
* flows
* branches
* validation state
* reconciliation state

---

## Visualization Constraints

Visualization MUST NOT:

* directly mutate graph state
* bypass reconciliation
* bypass validation workflows

---

# 6.16 Repository Reconstruction Structure

## Definition

Repository reconstruction structures represent inferred semantic state derived from existing repositories.

---

## Reconstruction Requirements

Reconstructed structures MUST include confidence metadata.

Confidence metadata MUST expose:

* inferred structure
* confidence level
* ambiguity source
* unresolved dependencies
* confirmation requirements

---

## Reconstruction Constraints

Low-confidence structures MUST require user confirmation before graph finalization.

---

## Section 7 — Execution Targets and Runtime Model

---

# 7.1 Canonical Runtime Principle

Execution targets are structured orchestration domains.

Execution targets define:

* runtime assumptions
* framework assumptions
* deployment assumptions
* validation packs
* orchestration boundaries
* supported architectural patterns

Execution targets are adapter-level execution systems and are non-canonical.

The graph expresses capability requirements rather than provider-specific implementations.

---

# 7.2 Execution Target Definition

An Execution Target is a deterministic runtime orchestration environment capable of transforming graph state into deployable execution artifacts.

Execution targets MUST define:

* supported frameworks
* supported runtimes
* deployment adapters
* dependency assumptions
* validation requirements
* execution constraints
* supported patterns
* unsupported patterns

---

# 7.3 Initial v1 Execution Targets

v1 MUST support initial execution targets including:

| Target  | Runtime              | Deployment     | Primary Language |
| ------- | -------------------- | -------------- | ---------------- |
| Next.js | Node.js              | Vercel         | TypeScript       |
| Expo    | React Native Managed | EAS            | TypeScript       |
| FastAPI | Python               | Railway/Fly.io | Python           |

Additional execution targets MAY be added through adapter extension.

---

# 7.4 Runtime Abstraction Model

The graph defines runtime capability requirements only.

Examples:

* authentication capability
* persistence capability
* queue capability
* storage capability
* deployment capability

Execution target adapters resolve implementation providers.

Examples:

* Supabase
* PostgreSQL
* Redis
* Vercel
* Railway

Provider implementations MUST remain outside canonical graph state.

---

# 7.5 Execution Pipeline Model

## Canonical Execution Pipeline

```text id="54d91n"
Validated Specifications
→ Concept Graph
→ Graph Normalization
→ Validation
→ Execution DAG Generation
→ Scoped Worker Execution
→ Validation
→ Reconciliation
→ Deployment Adapter Execution
→ Deployment Reference Generation
```

---

## Execution Constraints

Execution MUST remain:

* graph-scoped
* dependency-scoped
* invariant-scoped
* topologically ordered
* reconciliation-governed

---

# 7.6 Agent Runtime Architecture

v1 execution architecture contains:

* Orchestrator Agent
* Planner Agent
* Validator Agent
* Reconciliation Agent
* Stateless Worker Agents

---

# 7.7 Orchestrator Runtime Responsibilities

The Orchestrator Agent owns global execution continuity.

Responsibilities include:

* lifecycle coordination
* execution phase routing
* approval routing
* convergence monitoring
* escalation triggering
* reconciliation coordination
* execution state management

The Orchestrator Agent MAY access global graph context.

---

# 7.8 Planner Runtime Responsibilities

The Planner Agent transforms normalized graph state into execution DAGs.

Responsibilities include:

* task generation
* dependency resolution
* execution ordering
* graph slicing
* affected scope resolution
* worker context generation

Planner outputs MUST remain deterministic and DAG-validatable.

---

# 7.9 Validator Runtime Responsibilities

The Validator Agent enforces semantic correctness.

Responsibilities include:

* invariant validation
* structural validation
* semantic validation
* interface validation
* reconciliation validation
* runtime-target validation

Validation MUST operate through multi-pass validation procedures.

---

# 7.10 Reconciliation Runtime Responsibilities

The Reconciliation Agent reconciles execution outputs into graph state.

Responsibilities include:

* graph updates
* lineage updates
* semantic diff generation
* merge reconciliation
* version reconciliation
* branch reconciliation

The graph remains canonical during reconciliation.

---

# 7.11 Worker Runtime Responsibilities

Workers execute localized implementation scopes.

Workers MUST remain stateless.

Workers MUST receive only:

* localized execution scope
* direct dependency context
* required interfaces
* required invariants
* required execution structures

Workers MUST NOT receive:

* unrestricted repository context
* unrelated feature scopes
* unrelated graph structures

---

# 7.12 Scoped Execution Enforcement

Scoped execution enforcement operates primarily through:

* graph slicing
* dependency traversal
* interface locality
* invariant locality

Context generation MUST derive from semantic graph structures rather than raw repository scanning.

---

# 7.13 Task DAG Model

## Task Structure

Each task MUST define:

* task identifier
* execution scope
* dependencies
* execution order
* required interfaces
* required entities
* expected outputs
* validation requirements

---

## DAG Constraints

Execution DAGs MUST:

* remain acyclic
* preserve dependency ordering
* preserve execution locality
* preserve invariant continuity

Circular dependencies are disallowed.

---

# 7.14 Context Generation Model

## Context Sources

Execution context MAY derive from:

* graph structures
* dependency relationships
* interfaces
* invariants
* execution lineage
* validation structures

---

## Context Constraints

Execution context MUST minimize unrelated semantic exposure.

Workers MUST receive only context required for deterministic execution.

---

# 7.15 Runtime Validation Model

## Validation Stages

Validation MUST execute during:

* graph normalization
* pre-execution readiness
* worker execution
* integration validation
* reconciliation
* merge operations
* deployment readiness

---

## Validation Blocking Rules

Validation failures MUST block:

* execution completion
* reconciliation completion
* deployment completion
* merge completion

---

# 7.16 Deployment Runtime Model

## Deployment Adapter Principle

Deployments execute through execution-target adapters.

Deployment adapters define:

* deployment procedures
* runtime assumptions
* provider integrations
* environment assumptions
* deployment validation rules

---

## Deployment Constraints

Deployment adapters MUST NOT mutate canonical graph state directly.

Deployment outputs remain non-canonical execution artifacts.

---

# 7.17 Runtime State Model

## Canonical Persistent State

sembl persists:

* graph state
* graph lineage
* specifications
* validation outputs
* architectural diffs
* deployment references
* branch lineage

---

## Non-Persistent Runtime State

sembl does not persist:

* generated repositories
* generated source files
* worker execution memory
* temporary execution context
* full runtime execution artifacts

---

# 7.18 Repository Integration Runtime Model

## Repository Ownership Principle

Generated repositories remain user-owned.

sembl integrates through:

* repository references
* commit references
* deployment references
* execution lineage references

---

## Repository Mutation Constraints

Repository mutations MUST reconcile through graph state.

Repositories MUST NOT become canonical mutation sources.

---

# 7.19 Branch Runtime Model

## Branch Execution Isolation

Branch execution MUST remain semantically isolated until reconciliation or merge completion.

---

## Branch Reconciliation Requirements

Branch reconciliation MUST validate:

* dependency continuity
* invariant compatibility
* interface continuity
* architectural consistency

---

# 7.20 Escalation Runtime Model

## Escalation Conditions

Runtime escalation occurs when:

* validation repeatedly fails
* reconciliation repeatedly fails
* convergence thresholds exceed limits
* dependency conflicts persist
* merge conflicts remain unresolved

---

## Escalation Actions

Escalation MAY require:

* manual review
* manual approval
* manual reconciliation
* architectural override confirmation

---

# 7.21 Runtime Visibility Model

## User-Visible Runtime State

Users MUST be able to inspect:

* execution progress
* validation summaries
* task state
* deployment state
* reconciliation state
* architectural diffs
* branch lineage

---

## Hidden Runtime State

The system MAY hide:

* internal optimization passes
* raw orchestration internals
* low-level DAG execution internals
* internal execution heuristics

---

# 7.22 Runtime Continuity Principle

Execution MUST preserve:

* graph continuity
* dependency continuity
* interface continuity
* lineage continuity
* architectural continuity

Execution MUST extend graph state rather than reconstruct unrelated semantic structures.

---

## Section 8 — Validation, Security, and Operational Constraints

---

# 8.1 Canonical Validation Principle

Validation is a mandatory deterministic enforcement layer governing:

* graph correctness
* execution correctness
* interface correctness
* dependency correctness
* reconciliation correctness
* deployment correctness

Validation is not advisory.

Validation failures MUST block invalid state progression.

---

# 8.2 Validation Domains

The system MUST validate:

* specification state
* graph structures
* entities
* interfaces
* integration contracts
* dependencies
* execution DAGs
* reconciliation outputs
* branch merges
* deployment readiness

---

# 8.3 Validation Pass Architecture

Validation MUST operate through multi-pass validation procedures.

Minimum required validation passes:

### Structural Validation Pass

Validates:

* schema correctness
* required structures
* entity completeness
* interface completeness
* graph consistency

---

### Semantic Validation Pass

Validates:

* semantic consistency
* invariant compatibility
* dependency integrity
* interface continuity
* architectural compatibility

---

### Cross-Validation Pass

Compares validation outputs across passes to detect:

* inconsistent conclusions
* unresolved ambiguity
* conflicting semantic interpretations

---

# 8.4 Invariant Enforcement Model

Invariant enforcement governs all execution and reconciliation behavior.

Invariant violations MUST block:

* execution completion
* reconciliation completion
* merge completion
* deployment completion

---

## Required Invariant Domains

The system MUST enforce:

### Graph Invariants

Including:

* interface completeness
* entity validity
* undefined structure prevention
* duplication prevention
* self-contained graph validity

---

### Interface Invariants

Including:

* immutable contracts
* strict schema adherence
* precondition enforcement
* postcondition verifiability

---

### Execution Invariants

Including:

* undefined logic prevention
* dependency continuity
* architecture continuity
* scoped execution integrity

---

### Iteration Invariants

Including:

* graph continuity
* lineage continuity
* reconciliation correctness
* architectural preservation

---

# 8.5 Validation Output Structure

Validation outputs MUST remain structured and graph-addressable.

Each violation MUST expose:

* violation identifier
* invariant identifier
* affected structure
* violation reason
* dependency impact
* reconciliation requirements

---

# 8.6 Failure Handling Model

## Failure Classification

The system MUST classify failures including:

* validation failures
* reconciliation failures
* execution failures
* merge failures
* deployment failures
* dependency failures

---

## Failure Isolation

Failures MUST remain localized to affected execution scopes whenever possible.

The system MUST avoid unrelated execution invalidation unless global consistency is affected.

---

## Failure Recovery

Failure recovery MAY include:

* scoped retries
* reconciliation retries
* rollback flows
* escalation workflows
* user confirmation workflows

---

# 8.7 Escalation Constraints

Escalation workflows activate when deterministic convergence cannot be achieved automatically.

---

## Escalation Triggers

Escalation MUST occur when:

* invariant conflicts persist
* repeated validation failures occur
* repeated reconciliation failures occur
* unresolved semantic ambiguity persists
* merge conflicts remain unresolved
* repository reconstruction remains incomplete

---

## Escalation Requirements

Escalation workflows MUST expose:

* affected graph structures
* unresolved violations
* dependency impact
* architectural impact
* required user actions

---

# 8.8 Approval Enforcement Constraints

v1 supports exactly two approval gates.

---

## Approval Gate 1 — Pre-Execution Confirmation

The system MUST block execution until users confirm:

* specification summary
* inferred assumptions
* execution targets
* architectural assumptions

---

## Approval Gate 2 — Architectural Mutation Confirmation

The system MUST block re-execution when architectural mutation detection triggers.

Approval-gated mutations include:

* entity mutations
* interface mutations
* dependency restructuring
* invariant-affecting mutations
* execution-target migration

---

# 8.9 Security Model

## Workspace Security

The system MUST support workspace-level authorization boundaries.

Authorization MUST govern:

* project access
* branch access
* mutation authority
* execution authority
* approval authority

---

## Identity and Authentication

Authentication is capability-level semantic state.

Provider implementations remain adapter-level concerns.

The graph MUST NOT encode provider-specific authentication infrastructure.

---

## Repository Access Security

Repository integrations MUST operate through explicit user authorization.

The system MUST NOT assume unrestricted repository access.

---

## Deployment Security

Deployment integrations MUST execute through authorized deployment adapters.

Deployment credentials MUST remain isolated from canonical graph state.

---

# 8.10 Data Persistence Constraints

## Canonical Persistent Data

sembl MUST persist:

* specifications
* graph state
* graph lineage
* semantic diffs
* validation outputs
* deployment references
* repository references
* approval lineage

---

## Non-Persistent Runtime Data

sembl MUST NOT persist:

* generated repositories
* generated source files
* temporary worker context
* full runtime execution artifacts
* unrestricted execution memory

---

# 8.11 Branching and Merge Constraints

## Branch Isolation Constraints

Branches MUST remain semantically isolated until merge completion.

---

## Merge Validation Constraints

Merges MUST validate:

* dependency continuity
* invariant compatibility
* interface continuity
* architectural compatibility

Conflicting merges MUST enter reconciliation workflows before completion.

---

# 8.12 Execution Constraints

## Scoped Execution Constraints

Workers MUST execute only within assigned graph scope.

Workers MUST NOT:

* access unrelated graph structures
* mutate unrelated dependencies
* redefine unrelated interfaces
* introduce undefined abstractions

---

## Context Constraints

Execution context MUST derive from:

* graph slicing
* dependency traversal
* interface locality
* invariant locality

Raw unrestricted repository scanning is disallowed for worker execution.

---

# 8.13 Repository Ingestion Constraints

## Reconstruction Constraints

Repository ingestion MUST reconstruct:

* explicitly expressed semantic structures
* dependency relationships
* interfaces
* architectural relationships

Implicit conventions MAY remain unresolved.

---

## Confidence Constraints

Ambiguous reconstructed structures MUST become low-confidence nodes requiring user confirmation.

---

## Global Analysis Constraint

Repository ingestion MUST operate globally rather than feature-locally.

Partial ingestion is disallowed.

---

# 8.14 Visualization Constraints

Visualization is a derived inspection layer over graph state.

Visualization MUST NOT:

* directly mutate graph state
* bypass validation workflows
* bypass reconciliation workflows
* bypass approval workflows

---

# 8.15 Operational Reliability Constraints

## Continuity Constraints

The system MUST preserve:

* graph continuity
* lineage continuity
* dependency continuity
* interface continuity
* architectural continuity

across repeated iteration cycles.

---

## Drift Prevention Constraints

The system MUST prevent:

* duplicated abstractions
* uncontrolled regeneration
* semantic fragmentation
* recursive architectural drift
* dependency corruption

---

# 8.16 Runtime Target Constraints

Execution targets MUST remain deterministic orchestration domains.

Execution targets MUST define:

* runtime assumptions
* deployment assumptions
* validation packs
* orchestration boundaries

Execution targets MUST NOT operate as unrestricted generation environments.

---

# 8.17 Operational Visibility Constraints

## User-Visible Operational State

Users MUST be able to inspect:

* execution state
* validation summaries
* reconciliation summaries
* deployment state
* semantic diffs
* approval state
* branch lineage

---

## Hidden Operational State

The system MAY hide:

* internal optimization heuristics
* low-level orchestration internals
* internal DAG optimization structures
* provider-specific orchestration internals

---

# 8.18 Canonical Operational Constraint

The graph remains canonical under all operational conditions.

Execution artifacts, repositories, deployments, and runtime systems remain non-canonical outputs derived from graph state.

All mutations MUST reconcile back into canonical graph structures.

---

## Section 9 — Success Metrics, v1 Boundaries, and Forward Compatibility

---

# 9.1 Canonical Success Definition

sembl succeeds if it can:

* generate coherent production-grade systems
* preserve architectural continuity under iteration
* maintain semantic consistency across long development cycles
* execute through scoped semantic context
* reconstruct semantic state from existing repositories
* support collaborative semantic workflows
* outperform stateless vibe-coding workflows in maintainability and iteration reliability

while preserving graph state as canonical architectural state.

---

# 9.2 Product-Level Success Metrics

## Semantic Continuity Metrics

The system MUST measure:

* architectural continuity across iterations
* interface continuity across mutations
* dependency continuity across merges
* graph lineage preservation
* invariant preservation rate

---

## Execution Stability Metrics

The system MUST measure:

* execution convergence rate
* validation pass rate
* reconciliation success rate
* deployment success rate
* retry frequency
* escalation frequency

---

## Scoped Execution Metrics

The system MUST measure:

* average execution scope size
* context locality effectiveness
* dependency scope precision
* unrelated context exposure rate

---

## Iteration Stability Metrics

The system MUST measure:

* successful scoped re-execution rate
* unintended regeneration frequency
* architectural drift frequency
* merge conflict frequency
* invariant violation recurrence

---

## Repository Reconstruction Metrics

The system MUST measure:

* reconstruction completeness
* low-confidence node frequency
* confirmation dependency rate
* inferred dependency accuracy
* reconstruction validation success rate

---

## Collaboration Metrics

The system MUST measure:

* branch reconciliation success rate
* approval resolution time
* semantic diff review frequency
* merge validation success rate

---

# 9.3 Quality Success Conditions

Generated systems MUST:

* preserve semantic coherence
* avoid duplicated abstractions
* avoid recursive slop generation
* preserve dependency integrity
* preserve interface continuity
* satisfy competent developer expectations

Execution outputs SHOULD remain explainable through graph structures and specification lineage.

---

# 9.4 v1 Product Boundaries

v1 is intentionally constrained.

The objective of v1 is deterministic semantic execution stability rather than maximal platform breadth.

---

## Included v1 Priorities

v1 prioritizes:

* specification-first engineering
* graph canonicality
* scoped execution
* validation enforcement
* architectural continuity
* semantic iteration
* repository reconstruction
* semantic branching
* async collaboration
* graph visualization

---

## Explicitly Deferred Domains

The following domains are intentionally deferred beyond v1:

* real-time semantic co-editing
* infrastructure sandbox isolation
* autonomous infrastructure orchestration
* unrestricted autonomous graph mutation
* unmanaged infrastructure provisioning
* unrestricted graph editing
* IDE-native development workflows
* CLI-native orchestration workflows
* advanced distributed execution scheduling

---

# 9.5 Forward Compatibility Principles

v1 structures MUST remain forward-compatible with future semantic system expansion.

Future capabilities MUST extend canonical graph structures rather than replace them.

---

# 9.6 Forward-Compatible Branching Model

v1 branching architecture MUST remain extensible toward:

* granular semantic branches
* collaborative merge orchestration
* distributed semantic workflows
* advanced reconciliation systems

without invalidating canonical lineage structures.

---

# 9.7 Forward-Compatible Collaboration Model

v1 collaboration structures MUST remain extensible toward:

* real-time semantic collaboration
* concurrent graph mutation systems
* distributed semantic editing
* live reconciliation systems

without restructuring canonical graph semantics.

---

# 9.8 Forward-Compatible Execution Model

The execution architecture MUST remain extensible toward:

* sandboxed worker execution
* distributed worker orchestration
* advanced runtime isolation
* multi-runtime orchestration expansion
* adaptive execution optimization

while preserving:

* graph-scoped execution
* dependency locality
* invariant enforcement
* deterministic reconciliation

---

# 9.9 Forward-Compatible Visualization Model

Visualization systems MUST remain extensible toward:

* advanced graph navigation
* execution lineage visualization
* reconciliation visualization
* semantic dependency exploration
* architectural evolution playback

without becoming canonical mutation surfaces.

---

# 9.10 Forward-Compatible Repository Intelligence

Repository ingestion systems MUST remain extensible toward:

* deeper semantic inference
* architectural pattern inference
* runtime topology reconstruction
* behavioral inference
* automated ambiguity reduction

while preserving explicit user confirmation for unresolved ambiguity.

---

# 9.11 Forward-Compatible Validation Architecture

Validation systems MUST remain extensible toward:

* richer invariant systems
* adaptive semantic validation
* deeper reconciliation analysis
* distributed validation orchestration
* execution quality scoring

without weakening deterministic enforcement guarantees.

---

# 9.12 Canonical Evolution Principle

sembl evolves through semantic extension rather than architectural replacement.

Future versions MUST preserve:

* graph canonicality
* semantic lineage
* invariant continuity
* execution locality
* reconciliation continuity

across platform evolution.

---

# 9.13 Final v1 Definition

sembl v1 is a graph-native semantic software engineering system where:

* specifications are primary
* graph state is canonical
* execution is graph-scoped
* code is compiled output
* iteration is semantic graph mutation
* validation governs correctness
* reconciliation preserves continuity
* branching operates on semantic state
* repositories are non-canonical execution artifacts

The system transforms software engineering from:

* prompt iteration
* file manipulation
* stateless generation
* architecture rediscovery

into:

* semantic state evolution
* graph-governed execution
* persistent architectural intelligence
* structured semantic software engineering

---

This completes the PRD for sembl v1.


