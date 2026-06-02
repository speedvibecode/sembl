# NFR Section 1 — Operational Philosophy and Canonical Constraints

## 1.1 Canonical Operational Principle

The semantic graph is the canonical operational state of the system.

All execution, validation, orchestration, reconciliation, iteration, branching, and deployment behavior derives from graph state.

Generated repositories, runtime artifacts, deployments, temporary execution memory, and worker-local context are non-canonical execution artifacts.

Canonical graph state MUST remain authoritative under all operational conditions.  

---

## 1.2 Specification Primacy Constraint

Execution MUST derive from validated specification state.

Execution MUST NOT derive from:

* unrestricted prompts
* repository-wide improvisation
* direct worker reasoning over raw repositories
* uncontrolled regeneration flows

Specifications function as the operational semantic source for:

* graph extraction
* invariant derivation
* execution scope generation
* validation constraints
* orchestration boundaries
* reconciliation behavior

Code generation is downstream execution output only.  

---

## 1.3 Graph Canonicality Constraint

The graph MUST remain:

* structurally normalized
* semantically normalized
* invariant-addressable
* lineage-preserving
* reconciliation-governed
* execution-compatible

The graph MUST preserve explicit representations for:

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

Implicit semantic state is non-canonical.

Undefined graph structures are invalid operational state.  

---

## 1.4 Scoped Execution Locality Constraint

Execution locality is mandatory.

Execution context generation MUST operate through:

* graph slicing
* dependency traversal
* interface locality
* invariant locality
* architecture-scoped resolution

Workers MUST receive only:

* assigned execution scope
* direct dependencies
* required interfaces
* required invariants
* task-local execution structures

Workers MUST NOT receive:

* unrestricted repository context
* unrelated graph structures
* unrelated execution scopes
* full architectural state unless explicitly required by orchestration

Repository-wide execution reasoning is prohibited for worker execution.  

---

## 1.5 Stateless Execution Constraint

Worker execution MUST remain stateless.

Persistent architectural continuity is preserved through:

* graph state
* lineage state
* reconciliation state
* validation state
* specification state

Workers MUST NOT persist:

* private semantic memory
* hidden execution state
* implicit architectural assumptions
* undocumented dependency assumptions

All reusable execution knowledge MUST reconcile into canonical graph state or validated specification state.  

---

## 1.6 Dependency-Scoped Orchestration Constraint

Execution orchestration MUST remain dependency-scoped and DAG-validatable.

The orchestration system MUST preserve:

* topological ordering
* dependency continuity
* invariant continuity
* execution locality
* interface continuity

Execution DAGs MUST remain:

* acyclic
* graph-derived
* validation-addressable
* reconciliation-compatible

Circular dependency execution state is invalid.  

---

## 1.7 Invariant Enforcement Constraint

Invariant enforcement is operationally mandatory.

Invariant violations MUST block:

* execution completion
* reconciliation completion
* deployment completion
* merge completion
* graph finalization

Invariant enforcement MUST remain deterministic and multi-pass validated.

Operational execution MAY continue only within unaffected valid scopes when locality guarantees remain preserved.

Invariant bypass behavior is prohibited.  

---

## 1.8 Architectural Continuity Constraint

Execution and iteration MUST extend existing architectural state rather than reconstruct unrelated structures.

The system MUST preserve:

* entity continuity
* dependency continuity
* interface continuity
* semantic lineage
* graph identity
* architectural consistency

Localized mutations MUST NOT trigger unrelated regeneration unless dependency analysis proves global invalidation.

Architectural drift through uncontrolled regeneration is invalid operational behavior.  

---

## 1.9 Reconciliation-Governed Mutation Constraint

All semantic mutation MUST reconcile through canonical graph state.

Mutation sources MAY include:

* specification mutation
* validated repository reconstruction
* branch reconciliation
* approved architectural mutation
* iteration workflows

Direct mutation of canonical graph state outside reconciliation workflows is prohibited.

Repositories MUST NOT become canonical mutation sources.  

---

## 1.10 Semantic Lineage Preservation Constraint

The system MUST preserve immutable semantic lineage across:

* graph versions
* branches
* reconciliation operations
* execution cycles
* deployment lineage
* architectural diffs

Lineage continuity MUST remain reconstructable without requiring historical execution memory persistence.

Lineage corruption invalidates reconciliation correctness. 

---

## 1.11 Semantic Context Explosion Prevention Constraint

The system MUST prevent unrestricted semantic-context expansion.

Context generation MUST remain:

* bounded
* locality-preserving
* dependency-scoped
* invariant-scoped
* reconciliation-compatible

Execution quality optimization through unrestricted global context exposure is prohibited.

Scalability MUST derive from semantic locality rather than larger execution context windows. 

---

## 1.12 Operational Determinism Constraint

The system MUST preserve deterministic operational flows for:

* graph normalization
* validation sequencing
* execution DAG generation
* reconciliation sequencing
* mutation resolution
* branch reconciliation

Equivalent canonical graph state MUST produce semantically equivalent orchestration behavior under identical execution conditions.

Operational nondeterminism that mutates canonical semantic meaning is invalid system behavior.  

---

## 1.13 Canonical Agent Responsibility Constraint

Agent responsibilities MUST remain operationally isolated.

### Orchestrator

Responsible only for:

* global coordination
* lifecycle continuity
* escalation routing
* approval routing
* execution state coordination

The Orchestrator MUST NOT perform unrestricted implementation execution.

---

### Planner

Responsible only for:

* graph slicing
* dependency resolution
* DAG generation
* scope resolution
* worker context generation

---

### Validator

Responsible only for:

* invariant enforcement
* structural validation
* semantic validation
* reconciliation validation
* execution correctness validation

---

### Reconciliation

Responsible only for:

* graph updates
* lineage updates
* semantic reconciliation
* diff generation
* merge reconciliation

---

### Workers

Responsible only for:

* localized scoped execution
* dependency-local implementation
* interface-constrained implementation
* task-local generation

Workers MUST remain stateless localized execution units. 

---

## 1.14 Operational Anti-Degradation Constraint

The system MUST NOT degrade into:

* repo-wide reasoning agents
* unrestricted context execution
* uncontrolled regeneration workflows
* monolithic orchestration systems
* architecture-unaware execution
* implicit semantic mutation systems

Operational scalability MUST remain dependent on:

* graph locality
* bounded execution scopes
* dependency-scoped orchestration
* invariant-local validation
* modular graph topology

not on unrestricted context expansion.

---

# NFR Section 2 — Execution and Locality Constraints

## 2.1 Canonical Execution Constraint

Execution MUST derive exclusively from:

* validated specification state
* normalized graph state
* invariant-valid execution DAGs
* scoped semantic context

Execution MUST NOT derive from:

* unrestricted prompts
* unrestricted repository reasoning
* uncontrolled regeneration
* implicit execution flows

Execution is a deterministic graph-governed compilation process over canonical semantic state. 

---

## 2.2 Execution DAG Constraint

Execution DAGs MUST remain:

* acyclic
* dependency-valid
* invariant-compatible
* reconciliation-compatible
* graph-derived

Each task MUST define:

* execution scope
* dependency requirements
* required interfaces
* required invariants
* expected outputs
* validation requirements

Implicit execution ordering is prohibited. 

---

## 2.3 Scoped Execution Constraint

Execution context generation MUST operate through:

* graph slicing
* dependency traversal
* interface locality
* invariant locality

Workers MUST receive only:

* assigned execution scope
* direct dependencies
* required interfaces
* required invariants
* task-local execution structures

Workers MUST NOT receive:

* unrestricted repository context
* unrelated graph structures
* unrelated execution scopes
* unrestricted architectural state

Repository-wide worker reasoning is prohibited. 

---

## 2.4 Stateless Worker Constraint

Workers MUST remain stateless localized execution units.

Persistent continuity MUST derive only from:

* graph state
* specification state
* validation state
* lineage state
* reconciliation state

Workers MUST NOT persist hidden semantic state or undocumented architectural assumptions. 

---

## 2.5 Orchestration Constraint

Execution orchestration MUST remain:

* dependency-scoped
* topologically ordered
* invariant-aware
* reconciliation-governed
* locality-preserving

The orchestration system MUST prevent:

* circular execution flows
* uncontrolled task expansion
* unrelated scope mutation
* execution-local optimization that violates architectural continuity

---

## 2.6 Re-Execution Localization Constraint

Iteration-triggered execution MUST regenerate only:

* affected graph scopes
* dependency-impacted scopes
* invariant-affected scopes
* affected task scopes

Full-system regeneration is prohibited unless global dependency or invariant invalidation occurs.

---

## 2.7 Agent Responsibility Constraint

Agent responsibilities are defined exclusively by Section 1.13.

Execution workflows MUST operate within those responsibility boundaries.

Agents MUST NOT bypass scoped execution boundaries.

---

## 2.8 Execution Continuity Constraint

Execution MUST preserve:

* interface continuity
* dependency continuity
* graph continuity
* semantic continuity
* architectural identity

Execution MUST extend existing semantic structures rather than reconstruct unrelated architectural regions. 

---

## 2.9 Execution Convergence Constraint

Execution retries and regeneration loops MUST remain bounded.

The system MUST escalate non-converging execution states including:

* repeated invariant failure
* repeated reconciliation failure
* cyclic dependency emergence
* unstable execution outputs
* unresolved semantic conflict

Indefinite regeneration behavior is prohibited. 

---

# NFR Section 3 — Validation, Graph Integrity, and Invariant Constraints

## 3.1 Canonical Validation Constraint

Validation is a mandatory deterministic enforcement layer governing:

* graph correctness
* execution correctness
* interface correctness
* dependency correctness
* reconciliation correctness

Validation failures MUST block invalid state progression. 

---

## 3.2 Multi-Pass Validation Constraint

Validation MUST operate through bounded multi-pass procedures including:

* structural validation
* semantic validation
* consistency cross-validation

Validation outputs MUST remain:

* structured
* graph-addressable
* reconciliation-compatible
* invariant-addressable

Single-pass validation authority is prohibited. 

---

## 3.3 Graph Integrity Constraint

Canonical graph state MUST remain:

* structurally complete
* semantically normalized
* dependency-valid
* self-contained
* invariant-valid

The graph MUST prevent:

* undefined structures
* duplicate structures
* invalid references
* semantic ambiguity
* unresolved dependency state

Invalid graph state is non-executable. 

---

## 3.4 Invariant Enforcement Constraint

Invariant violations MUST block:

* execution completion
* reconciliation completion
* merge completion
* deployment completion
* graph finalization

Invariant bypass behavior is prohibited.

Operational progression MAY continue only within unaffected valid scopes when locality guarantees remain preserved. 

---

## 3.5 Interface Integrity Constraint

Interfaces MUST remain:

* schema-valid
* invariant-valid
* explicitly defined
* contract-stable
* dependency-compatible

Interfaces MUST define:

* explicit inputs
* explicit outputs
* preconditions
* postconditions
* success examples
* failure examples

Implicit contracts are prohibited. 

---

## 3.6 Integration Contract Constraint

Integration Contracts MUST define:

* ordered execution flow
* explicit field mappings
* dependency transitions
* error propagation behavior
* rollback behavior

Implicit data transfer between interfaces is prohibited. 

---

## 3.7 Graph Normalization Constraint

Normalization MUST execute deterministically through bounded validation passes including:

* structural normalization
* consistency normalization
* mapping normalization
* completeness normalization

Normalization MUST remove:

* duplication
* ambiguous naming
* unresolved references
* semantic conflicts
* invalid reuse patterns

Normalization outputs MUST remain execution-compatible. 

---

## 3.8 Validation Locality Constraint

Validation systems MUST operate against localized affected scopes whenever dependency continuity permits.

The system MUST avoid unrelated validation invalidation unless:

* dependency propagation becomes global
* invariant propagation becomes global
* graph consistency cannot otherwise be guaranteed

---

## 3.9 Validation Determinism Constraint

Equivalent canonical graph state MUST produce semantically equivalent validation outcomes under equivalent execution conditions.

Validation behavior that mutates semantic interpretation nondeterministically is prohibited.

---

## 3.10 Design Integrity Constraint

Locked Design Artifacts MUST remain immutable during execution.

UI implementation MUST derive strictly from locked design state.

Execution-time redesign behavior is prohibited. 

---

# NFR Section 4 — Reconciliation, Mutation, and Continuity Constraints

## 4.1 Canonical Reconciliation Constraint

All canonical state mutation MUST reconcile through validated graph state.

Reconciliation governs:

* graph mutation
* lineage updates
* semantic diff generation
* branch reconciliation
* version continuity

Direct mutation outside reconciliation workflows is prohibited. 

---

## 4.2 Mutation Governance Constraint

Semantic mutation MUST originate only from:

* specification mutation
* validated repository reconstruction
* approved architectural mutation
* branch reconciliation
* iteration workflows

Repositories, deployments, and runtime artifacts MUST NOT become canonical mutation sources.

---

## 4.3 Architectural Continuity Constraint

Mutation workflows MUST preserve:

* entity continuity
* interface continuity
* dependency continuity
* graph identity
* semantic lineage
* architectural coherence

Localized mutations MUST extend existing semantic structures rather than reconstruct unrelated system regions. 

---

## 4.4.1 Architectural Mutation Definition

Architectural Mutation is any semantic mutation that alters one or more of:

* entity identity
* interface identity
* dependency topology
* invariant behavior
* execution target assignment

Architectural Mutations modify graph structure, semantic identity, or execution semantics.

Architectural Mutations require approval-gated reconciliation before canonicalization.

---

## 4.4.2 Approval-Gated Mutation Constraint

The system MUST pause re-execution for mutations affecting:

* entities
* interfaces
* dependency topology
* execution targets
* invariant behavior

Approval workflows MUST expose:

* affected scopes
* dependency impact
* interface impact
* architectural diffs
* execution impact

Unapproved architectural mutation is prohibited. 

---

## 4.5 Semantic Diff Constraint

Reconciliation MUST generate graph-addressable semantic diffs for:

* entity mutations
* interface mutations
* dependency mutations
* invariant mutations
* flow mutations
* execution-target mutations

Diffs MUST remain lineage-compatible and merge-compatible. 

---

## 4.6 Lineage Continuity Constraint

The system MUST preserve immutable lineage across:

* graph versions
* reconciliation operations
* branch mutations
* merges
* deployments
* execution cycles

Lineage reconstruction MUST NOT depend on retained worker execution memory. 

---

## 4.7 Scoped Mutation Constraint

Mutation propagation MUST remain dependency-scoped whenever graph continuity permits.

The system MUST avoid:

* unrelated scope regeneration
* unrelated dependency mutation
* unrelated interface mutation
* graph-wide reconciliation for localized changes

Global mutation propagation is permitted only when locality guarantees break.

---

## 4.8 Merge Continuity Constraint

Branch merges MUST validate:

* invariant compatibility
* dependency continuity
* interface continuity
* architectural compatibility
* graph consistency

Conflicting merges MUST enter reconciliation workflows before merge completion. 

---

## 4.9 Continuity Preservation Constraint

The system MUST prevent:

* semantic fragmentation
* duplicated abstractions
* recursive architectural drift
* dependency corruption
* lineage discontinuity
* uncontrolled regeneration

Operational optimization that weakens long-term architectural continuity is prohibited.

---

# NFR Section 5 — Repository Ingestion and Branch Isolation Constraints

## 5.1 Full-System Ingestion Constraint

Repository ingestion MUST operate against the complete repository.

Partial repository ingestion is prohibited.

Repository reconstruction MUST preserve:

* dependency integrity
* architectural continuity
* semantic consistency
* execution validity

Feature-local reconstruction without global repository understanding is invalid. 

The complete-repository requirement applies only to repository analysis, semantic reconstruction, and canonicalization workflows.

Post-ingestion execution, validation, reconciliation, and iteration workflows remain subject to scoped locality constraints.

---

## 5.2 Reconstruction Constraint

Repository ingestion MUST reconstruct explicitly expressed:

* entities
* interfaces
* flows
* dependencies
* architectural relationships
* execution boundaries

The reconstructed graph MUST be capable of entering normal validation, reconciliation, and iteration workflows. 

---

## 5.3 Low-Confidence Structure Lifecycle Constraint

Ambiguous or incomplete semantic structures MUST become Low-Confidence Structures.

Low-Confidence Structures MUST expose:

* inferred structure
* ambiguity source
* unresolved dependencies
* confirmation requirements

Low-Confidence Structures enter Pending state after reconstruction.

Pending structures MAY be:

* confirmed
* rejected
* escalated

Confirmation occurs through validation workflows, user approval workflows, or subsequent repository evidence.

Confirmed structures MAY proceed to canonicalization.

Rejected structures MUST be removed from the reconstructed graph.

Structures that cannot be confirmed or rejected deterministically MUST enter escalation workflows.

Low-Confidence Structures MUST NOT become canonical graph state.

Iteration Mode activation MUST remain blocked while unresolved Low-Confidence Structures affect graph validity. 

---

## 5.4 Ingestion Validation Constraint

Repository reconstruction MUST pass:

* dependency validation
* interface validation
* invariant validation
* graph completeness validation
* architectural consistency validation

Invalid reconstruction state MUST block Iteration Mode activation. 

---

## 5.5 Canonicalization Constraint

Repository-derived semantic state MUST reconcile into canonical graph structures before becoming operational state.

Repositories MAY provide source information.

Repositories MUST NOT become canonical system representations.

Graph state remains authoritative after ingestion. 

---

## 5.6 Branch Isolation Constraint

Branches MUST remain semantically isolated until reconciliation or merge completion.

Branch mutations MUST NOT affect:

* canonical graph state
* unrelated branches
* active execution scopes
* lineage state outside branch boundaries

Isolation failure is invalid branch behavior. 

---

## 5.7 Branch Continuity Constraint

Branches MUST preserve:

* graph lineage
* dependency continuity
* interface continuity
* invariant continuity
* reconciliation history

Branch creation MUST extend lineage rather than fork semantic identity. 

---

## 5.8 Subgraph Branch Constraint

Subgraph branches MUST remain dependency-validatable.

The system MUST preserve all dependencies required to:

* validate the branch
* reconcile the branch
* merge the branch
* execute affected scopes

Dependency-incomplete branches are invalid operational state.

---

## 5.9 Branch Reconciliation Constraint

Branch reconciliation MUST validate:

* dependency continuity
* interface continuity
* invariant compatibility
* architectural compatibility
* graph consistency

Branch reconciliation MUST NOT introduce orphan semantic structures.

---

## 5.10 Repository-to-Iteration Continuity Constraint

Successful repository ingestion MUST establish:

* canonical graph state
* validation state
* lineage state
* reconciliation state

before Iteration Mode activation.

Repository onboarding MUST result in the same operational guarantees as graph-originated projects.

---

# NFR Section 6 — Runtime Reliability and Failure Handling Constraints

## 6.1 Reliability Principle

The system MUST preserve valid canonical state under execution, validation, reconciliation, merge, and deployment failures.

Failures MUST NOT corrupt:

* graph state
* lineage state
* validation state
* reconciliation state
* architectural continuity

Canonical state integrity takes precedence over execution completion. 

---

## 6.2 Failure Classification Constraint

Failures MUST be classified into:

* validation failures
* execution failures
* reconciliation failures
* merge failures
* deployment failures
* dependency failures
* reconstruction failures

Failure states MUST remain graph-addressable and operationally traceable. 

---

## 6.3 Failure Isolation Constraint

Failures MUST remain localized to affected scopes whenever dependency continuity permits.

The system MUST avoid invalidating unrelated:

* execution scopes
* graph regions
* branches
* interfaces
* dependencies

Global failure propagation is permitted only when consistency guarantees cannot otherwise be preserved. 

---

## 6.4 Recovery Constraint

Failure recovery MAY include:

* scoped retries
* validation retries
* reconciliation retries
* rollback workflows
* escalation workflows
* user intervention workflows

Recovery actions MUST preserve canonical state continuity. 

---

## 6.5 Escalation Constraint

The system MUST enter escalation workflows when deterministic convergence cannot be achieved automatically.

Escalation conditions include:

* persistent invariant violations
* repeated validation failure
* repeated reconciliation failure
* unresolved semantic ambiguity
* unresolved merge conflicts
* incomplete repository reconstruction

Escalation MUST terminate automated progression until resolution occurs. 

---

## 6.6 Rollback Constraint

Rollback workflows MUST restore the most recent valid operational state.

Rollback MUST preserve:

* graph continuity
* lineage continuity
* version continuity
* reconciliation history

Rollback MUST NOT create lineage discontinuities.

---

## 6.7 Deployment Failure Constraint

Deployment failures MUST remain isolated from canonical graph state.

Deployment failure handling MUST enter one of:

* rollback workflows
* escalation workflows

The selected path MUST be deterministic for equivalent failure conditions.

Deployment outcomes MUST NOT alter graph correctness. 

---

## 6.8 Validation Blocking Constraint

Validation failures MUST block:

* execution completion
* reconciliation completion
* merge completion
* deployment completion

Progression through invalid operational state is prohibited. 

---

## 6.9 Operational Consistency Constraint

Equivalent canonical graph state MUST produce semantically equivalent operational outcomes under equivalent execution conditions.

Persistent operational inconsistency without graph mutation is invalid system behavior.

---

## 6.10 Recoverability Constraint

The system MUST maintain sufficient canonical state to recover from operational failure without reconstructing architecture from execution artifacts.

Recovery MUST derive from:

* specifications
* graph state
* lineage state
* validation outputs
* reconciliation history

Generated code and runtime artifacts MUST NOT be required for semantic recovery.

---

# NFR Section 7 — Scalability and Convergence Constraints

## 7.1 Scalability Principle

System scalability MUST derive from:

* semantic locality
* graph modularity
* dependency-scoped execution
* bounded context generation
* scoped validation
* scoped reconciliation

Scalability MUST NOT depend on unrestricted context expansion. 

---

## 7.2 Graph Modularity Constraint

Canonical graph state MUST support modular decomposition through:

* subgraphs
* domain boundaries
* interface grouping
* dependency-local structures

Graph growth MUST preserve navigability, validation integrity, and execution locality.

---

## 7.3 Context Boundedness Constraint

Execution context generation MUST remain bounded regardless of repository size.

Context generation MUST expose only:

* required graph structures
* required dependencies
* required interfaces
* required invariants

Repository growth MUST NOT force proportional context growth.

---

## 7.4 Dependency Locality Constraint

Execution, validation, and reconciliation MUST operate against dependency-local scopes whenever graph correctness permits.

The system MUST minimize:

* unrelated dependency exposure
* unrelated execution scope inclusion
* unrelated validation scope inclusion

Operational cost MUST scale primarily with affected scope rather than total repository size.

---

## 7.5 Scoped Regeneration Constraint

Iteration workflows MUST regenerate only affected semantic regions.

The system MUST avoid:

* graph-wide regeneration
* repository-wide regeneration
* unrelated task regeneration
* unrelated validation regeneration

Regeneration cost MUST remain proportional to mutation impact whenever locality guarantees remain valid.

---

## 7.6 Validation Scalability Constraint

Validation workflows MUST prioritize affected graph scopes before expanding validation boundaries.

Graph growth MUST NOT require full-system validation for localized mutations unless:

* invariant propagation becomes global
* dependency propagation becomes global
* graph consistency requires full evaluation

---

## 7.7 Reconciliation Scalability Constraint

Reconciliation MUST operate against affected graph regions whenever continuity guarantees permit.

The system MUST avoid graph-wide reconciliation for localized semantic mutations.

Reconciliation cost MUST remain proportional to mutation scope whenever possible.

---

## 7.8 Branch Scalability Constraint

Branch creation, execution, validation, and reconciliation MUST remain dependency-scoped.

Branch operations MUST preserve locality characteristics independent of total graph size.

---

## 7.9 Convergence Constraint

Execution, validation, and reconciliation workflows MUST remain convergence-oriented.

The system MUST detect and terminate non-converging operational states including:

* repeated invariant violations
* repeated reconciliation failure
* cyclic mutation behavior
* unresolved semantic conflict
* unstable execution outcomes

Infinite convergence loops are prohibited. 

---

## 7.10 Architectural Stability Constraint

System growth MUST preserve:

* architectural continuity
* dependency integrity
* interface continuity
* graph identity
* semantic locality

Repository size, graph size, and iteration count MUST NOT force degradation into monolithic execution behavior. 

---

# NFR Section 8 — Persistence and Lineage Constraints

## 8.1 Canonical Persistence Constraint

The system MUST persist only canonical semantic state and operational continuity state.

Canonical persisted state includes:

* specifications
* graph state
* graph versions
* validation outputs
* semantic diffs
* lineage state
* deployment references
* repository references

Persistence of canonical state is mandatory for continuity preservation. 

---

## 8.2 Non-Persistent Runtime Constraint

The system MUST NOT persist:

* generated repositories
* generated source files
* worker execution memory
* temporary execution context
* full runtime execution artifacts
* unrestricted execution history

Runtime artifacts are non-canonical operational outputs. 

---

## 8.3 Graph Persistence Constraint

The graph MUST remain the authoritative persistent representation of the software system.

Execution outputs, repositories, deployments, and runtime state MUST remain subordinate to graph state.

Graph authority MUST remain preserved under all operational conditions. 

---

## 8.4 Lineage Preservation Constraint

The system MUST preserve immutable lineage across:

* graph versions
* execution cycles
* reconciliation operations
* branch operations
* merge operations
* deployments

Lineage records MUST remain reconstructable and historically traceable. 

---

## 8.5 Version Continuity Constraint

Version history MUST preserve:

* semantic evolution
* architectural evolution
* reconciliation history
* validation history
* branch history

Version transitions MUST remain lineage-linked and graph-addressable.

Orphan version states are prohibited.

---

## 8.6 Semantic Diff Persistence Constraint

The system MUST persist semantic diffs for all reconciled mutations.

Diff history MUST expose:

* what changed
* where it changed
* how it affected dependencies
* how it affected architecture

Diff persistence MUST support reconciliation, auditing, and lineage reconstruction.

---

## 8.7 Branch Lineage Constraint

Branches MUST preserve:

* parent lineage
* mutation lineage
* merge lineage
* reconciliation lineage

Branch operations MUST extend lineage rather than create independent semantic histories.

---

## 8.8 Continuity Reconstruction Constraint

The system MUST be capable of reconstructing operational continuity from persisted canonical state.

Continuity reconstruction MUST derive from:

* specifications
* graph state
* lineage state
* validation history
* reconciliation history

Continuity reconstruction MUST NOT depend on worker memory or retained execution context.

---

## 8.9 Repository Reference Constraint

Repositories remain external execution artifacts.

The system MAY persist:

* repository identifiers
* repository locations
* commit references
* integration references

The system MUST NOT persist repository contents as canonical semantic state.

Repository references identify external artifacts.

Graph state remains the authoritative persisted representation of system semantics. 

---

## 8.10 Persistence Integrity Constraint

Persistence systems MUST preserve:

* graph integrity
* lineage integrity
* version integrity
* reconciliation integrity

Persistence behavior that weakens semantic continuity or architectural continuity is prohibited.

---

# NFR Section 9 — Deployment, Security, and Operational Visibility Constraints

## 9.1 Deployment Isolation Constraint

Deployments are non-canonical execution outputs.

Deployment success or failure MUST NOT directly mutate:

* graph state
* lineage state
* validation state
* reconciliation state

Canonical state remains authoritative independent of deployment state. 

---

## 9.2 Execution Target Constraint

Execution targets MUST function as deterministic orchestration domains.

Execution targets MUST define:

* runtime assumptions
* deployment assumptions
* validation requirements
* orchestration boundaries
* supported architectural patterns

Execution targets MUST NOT operate as unrestricted generation environments. 

---

## 9.3 Runtime Compatibility Constraint

Deployment workflows MUST validate:

* runtime compatibility
* framework compatibility
* dependency compatibility
* deployment compatibility
* adapter compatibility

Incompatible deployment state MUST block deployment completion. 

---

## 9.4 Authorization Boundary Constraint

Authorization MUST govern:

* workspace access
* project access
* mutation authority
* execution authority
* approval authority
* merge authority

Unauthorized mutation, execution, or approval behavior is prohibited. 

---

## 9.5 Repository Access Constraint

Repository integrations MUST operate through explicit user authorization.

The system MUST NOT assume unrestricted repository access.

Repository access permissions MUST remain external to canonical graph state. 

---

## 9.6 Credential Isolation Constraint

Authentication providers, deployment credentials, and infrastructure credentials MUST remain outside canonical graph structures.

Provider-specific implementation details MUST remain adapter-level concerns. 

---

## 9.7 Operational Visibility Constraint

The system MUST expose operationally relevant visibility including:

* execution state
* validation state
* reconciliation state
* deployment state
* approval state
* semantic diffs
* branch lineage

Operational visibility MUST remain graph-aligned and lineage-compatible. 

---

## 9.8 Auditability Constraint

The system MUST preserve immutable operational records for:

* approvals
* reconciliations
* merges
* graph mutations
* lineage transitions

Operational history MUST remain reconstructable from canonical state. 

---

## 9.9 Visibility Boundary Constraint

The system MAY hide:

* internal optimization passes
* orchestration internals
* execution heuristics
* low-level DAG execution details

Visibility systems MUST expose operational outcomes without exposing unnecessary internal execution complexity. 

---

## 9.10 Inspection Surface Constraint

Operational inspection surfaces MUST derive from canonical graph state.

Inspection systems MUST NOT:

* mutate graph state
* bypass validation
* bypass reconciliation
* bypass approval workflows

Inspection surfaces remain observational rather than authoritative. 

---

# NFR Section 10 — Final Canonical Guarantees

## 10.1 Graph Canonicality Guarantee

The graph remains the canonical representation of the software system under all operational conditions.

All execution, validation, reconciliation, branching, deployment, and iteration behavior derives from graph state.

Repositories, deployments, runtime artifacts, and generated code remain non-canonical outputs.  

---

## 10.2 Specification Primacy Guarantee

Validated specification state remains the authoritative source for graph construction and execution.

Execution MUST NOT originate from unrestricted prompts, unrestricted repository reasoning, or direct implementation improvisation.

Specifications remain the operational source of semantic intent. 

---

## 10.3 Scoped Execution Guarantee

Execution remains:

* graph-scoped
* dependency-scoped
* interface-scoped
* invariant-scoped
* locality-preserving

The system MUST NOT degrade into repository-wide execution reasoning or unrestricted semantic execution. 

---

## 10.4 Invariant Enforcement Guarantee

Invariant violations MUST block invalid state progression.

The system MUST NOT permit execution, reconciliation, merge, deployment, or graph finalization through known invariant violations. 

---

## 10.5 Reconciliation Guarantee

All canonical state mutation remains reconciliation-governed.

Semantic mutation MUST reconcile through validated graph state before becoming operational state.

Direct canonical mutation outside reconciliation workflows is prohibited.

---

## 10.6 Architectural Continuity Guarantee

The system MUST preserve:

* entity continuity
* interface continuity
* dependency continuity
* semantic continuity
* lineage continuity
* architectural identity

Iteration extends architecture rather than reconstructing it. 

---

## 10.7 Lineage Preservation Guarantee

All reconciled semantic evolution MUST remain historically reconstructable through:

* graph lineage
* branch lineage
* reconciliation lineage
* validation lineage
* version lineage

Lineage discontinuity is invalid operational state. 

---

## 10.8 Repository Independence Guarantee

Repositories remain execution artifacts rather than semantic authorities.

The system MUST be capable of preserving semantic continuity through canonical state without requiring repositories to function as the source of truth. 

---

## 10.9 Scalability Guarantee

System scalability MUST derive from:

* graph modularity
* semantic locality
* dependency-scoped execution
* bounded context generation
* scoped validation
* scoped reconciliation

Scalability through unrestricted context expansion is prohibited. 

---

## 10.10 Continuity Guarantee

The system MUST maintain recoverable semantic continuity across:

* execution cycles
* repository ingestion
* branch operations
* merge operations
* reconciliation operations
* deployment cycles
* long-term iteration

Canonical state MUST remain sufficient to preserve architectural continuity independent of temporary execution state.

---

## 10.11 Anti-Degradation Guarantee

The system MUST NOT degrade into:

* uncontrolled regeneration
* semantic fragmentation
* duplicated abstractions
* recursive architectural drift
* monolithic execution behavior
* unrestricted context execution
* architecture-unaware iteration

Operational behavior MUST remain aligned with graph-governed semantic evolution. 

---

## 10.12 Canonical NFR Definition

sembl v1 operates under the following non-functional guarantees:

* graph state remains canonical
* specifications remain primary
* execution remains scoped
* validation remains mandatory
* reconciliation governs mutation
* continuity governs iteration
* lineage remains preserved
* scalability derives from locality
* repositories remain non-canonical
* architectural coherence takes precedence over generation convenience

The system optimizes for long-term semantic stability rather than short-term generation throughput.

Section 10 derives from and summarizes the operational constraints defined in Sections 1–9.

If interpretation conflicts arise, the operational constraints defined in Sections 1–9 remain authoritative.

---

