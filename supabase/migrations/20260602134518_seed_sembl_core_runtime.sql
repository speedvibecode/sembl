-- Seed Sembl Core runtime data from graph artifacts.
-- Deterministic UUIDs preserve relational integrity while original graph IDs live in JSON payloads.

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at, is_sso_user, is_anonymous
) values (
  '00000000-0000-0000-0000-000000000000', '3b375490-2133-5e97-a59a-a39948a78ff5', 'authenticated', 'authenticated', 'system@sembl.local', null, '2026-06-02T12:00:00.000Z',
  '{"provider":"email","providers":["email"],"seed":true}'::jsonb, '{"name":"Sembl System Seed"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', false, false
) on conflict (id) do nothing;

insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
values (
  '5a12ac0a-1a35-5cd6-8e0c-68122e3da4fb', '3b375490-2133-5e97-a59a-a39948a78ff5', '3b375490-2133-5e97-a59a-a39948a78ff5',
  '{"sub":"3b375490-2133-5e97-a59a-a39948a78ff5","email":"system@sembl.local","email_verified":true,"seed":true}'::jsonb,
  'email', null, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z'
) on conflict do nothing;

insert into public.workspaces (id, name, slug, created_at, updated_at)
values ('61253f13-ee87-5c45-84fe-668c8fc0e17b', 'Speedvibe', 'speedvibe', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.workspace_members (id, workspace_id, user_id, role, joined_at)
values ('8884b354-2ca4-5fe4-8c68-8aaf0a9e0419', '61253f13-ee87-5c45-84fe-668c8fc0e17b', '3b375490-2133-5e97-a59a-a39948a78ff5', 'owner', '2026-06-02T12:00:00.000Z')
on conflict do nothing;

insert into public.workspace_integrations (id, workspace_id, provider, external_id, metadata, created_at, updated_at) values
('52cd2495-3e54-5fc7-89a8-c8dbb739f656', '61253f13-ee87-5c45-84fe-668c8fc0e17b', 'github', 'speedvibecode/sembl', '{"url":"https://github.com/speedvibecode/sembl"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z'),
('164d1f21-2cb7-5b76-9c0e-e39e7dbcc1cc', '61253f13-ee87-5c45-84fe-668c8fc0e17b', 'vercel', 'sembl', '{"url":"https://sembl.vercel.app"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.projects (id, workspace_id, name, slug, lifecycle_state, operational_mode, created_by, created_at, updated_at)
values ('755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '61253f13-ee87-5c45-84fe-668c8fc0e17b', 'Sembl Core', 'sembl-core', 'awaiting_approval', 'execution', '3b375490-2133-5e97-a59a-a39948a78ff5', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.repository_references (id, project_id, provider, external_url, external_id, default_branch, metadata, created_at, updated_at)
values ('16794891-b724-57d9-8a53-b33c561569a9', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'github', 'https://github.com/speedvibecode/sembl', 'speedvibecode/sembl', 'master', '{"seeded_from":"graph/service_preflight.json"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('1eb82c5a-70fd-5a67-9898-8e04b9cb144c', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'pdd', '# PDD — Product Definition Document

## sembl — Graph-Driven Semantic Software Engineering System

### Draft v1

---

# 1. Product Identity

## Product Name

sembl

## Product Category

Graph-driven semantic software engineering platform.

## Core Definition

sembl is a graph-native AI software engineering system that transforms user intent into production-grade software systems through structured specification generation, canonical semantic graphs, scoped execution orchestration, and persistent architectural state.

The system treats:

* graph state as canonical
* specifications as first-class
* code as compiled output
* iteration as semantic graph mutation
* collaboration as coordinated semantic state evolution

rather than:

* prompt-driven file generation
* stateless code synthesis
* isolated AI chat interactions

---

# 2. Product Objective

The objective of sembl is to operationalize the V4.3 methodology into a production software system capable of:

* generating maintainable software systems
* preserving architectural continuity across iterations
* enabling graph-governed software evolution
* supporting multi-stack execution
* enabling semantic collaboration
* preventing architectural drift under long iterative cycles

The system exists to solve the primary failure modes of AI-assisted software engineering:

* architectural inconsistency
* duplicated abstractions
* uncontrolled regeneration
* semantic fragmentation
* context collapse
* recursive implementation drift
* incoherent iteration chains
* local optimization over global coherence

---

# 3. Core Product Thesis

Modern frontier models are already capable of substantial software generation.

The bottleneck is no longer raw code synthesis.

The bottleneck is:

* semantic persistence
* architectural continuity
* scoped reasoning
* deterministic orchestration
* invariant preservation
* controlled iteration
* execution locality
* graph-governed evolution

sembl exists to solve these bottlenecks through:

* structured specifications
* canonical graph state
* scoped semantic execution
* graph-constrained orchestration
* semantic versioning
* architecture-aware iteration

---

# 4. Canonical Product Philosophy

## 4.1 Graph as Canonical State

The graph is the canonical persistent representation of the software system.

The graph contains:

* entities
* interfaces
* flows
* dependencies
* invariants
* architectural relationships
* runtime assumptions
* deployment assumptions
* execution boundaries
* validation structures
* collaboration state

All execution derives from graph state.

All modifications reconcile back into graph state.

---

## 4.2 Specifications are Primary

The primary source of truth is structured specification state.

This includes:

* PDD
* PRD
* NFR
* UI/UX specifications
* system flows
* entities
* APIs
* DB schemas
* infrastructure assumptions
* architectural constraints
* execution targets

Code generation is downstream of specification state.

---

## 4.3 Prompt as Semantic Mutation

Prompts are not direct implementation instructions.

Prompts:

* mutate specification state
* mutate graph state
* trigger scoped execution
* evolve architectural structures

The system prevents uncontrolled prompt-level regeneration.

---

## 4.4 Code as Compiled Artifact

Generated code is not canonical state.

Generated code is:

* compiled semantic output
* execution artifact
* runtime representation of graph state

The graph remains canonical.

---

## 4.5 Structured Over Improvised Execution

The system prioritizes:

* constrained execution
* graph-scoped reasoning
* semantic locality
* invariant-aware orchestration
* architecture-preserving evolution

over unconstrained generation.

---

# 5. Product Scope

## Included

### Software Targets

* full-stack web applications
* mobile applications
* API/backend systems

### Core Capabilities

* AI-assisted specification generation
* graph-driven execution
* semantic iteration
* existing repository ingestion
* architectural diffing
* semantic versioning
* multi-user collaboration
* real-time semantic synchronization
* scoped execution orchestration
* deployment orchestration
* semantic branching/forking
* approval-gated architectural mutations

### Execution Capabilities

* multi-runtime execution
* multi-framework execution
* execution-target-aware orchestration
* runtime-specific validation
* deployment adapter systems

---

## Excluded (v1)

### Infrastructure

* arbitrary unmanaged infrastructure orchestration
* low-level infrastructure provisioning
* autonomous production operations

### Platforms

* embedded systems
* game engines
* unmanaged native systems

### Intelligence

* unconstrained autonomous self-modifying execution
* unrestricted graph exportability

---

# 6. Core Product Modes and State Transitions

sembl operates through three canonical operational modes governed by explicit state transitions.

The system behaves as a persistent semantic state machine.

## 6.1 Documentation Mode
Purpose

Transform ambiguous user intent into validated executable specification state.

* Inputs
* natural language prompts
* conversations
* uploaded documents
* screenshots
* wireframes
* Figma/Stitch exports
* architectural notes
* repositories (optional)
* Outputs

Structured specification system:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

The system:

infers missing specifications
adapts abstraction depth dynamically
infers technical capability silently
guides users toward specification completeness
Exit Conditions

Documentation Mode exits only when:

specification validation passes
graph extraction readiness is achieved
Design Artifact is locked
invariant requirements are satisfied
Transition Rules
Transition → Execution Mode

Occurs when:

specifications are validated
graph construction succeeds
execution readiness passes validation
Transition → Escalation State

Occurs when:

specification convergence repeatedly fails
invariant conflicts persist
graph construction cannot converge

## 6.2 Execution Mode
Purpose

Transform specification state into deployable software systems through graph-governed execution.

Execution Pipeline
Specifications
→ Concept Graph
→ Normalization
→ Validation
→ Task Graph
→ Scoped Execution
→ Reconciliation
→ Deployment
Execution Characteristics

Execution MUST be:

* DAG-based
* graph-scoped
* dependency-aware
* invariant-aware
* stateless-worker-driven
* topologically ordered
* Outputs
* repositories
* deployments
* execution artifacts
* validation reports
* graph versions
* architectural diffs
* Exit Conditions

Execution Mode exits only when one of the following occurs:

Successful Completion
deployment succeeds
validation passes
reconciliation completes
Escalation
invariant failures persist
execution repeatedly fails
orchestration cannot converge
approval-gated mutations are rejected
Transition Rules
Transition → Iteration Mode

Occurs after:

successful deployment
graph reconciliation completion
persistent graph state creation
Transition → Escalation State

Occurs when:

execution convergence fails
validation repeatedly fails
architectural conflicts remain unresolved

## 6.3 Iteration Mode
Purpose

Enable persistent long-term software evolution through semantic graph mutation.

Iteration Mode is the steady-state operational mode after first successful deployment.

Iteration Flow
Prompt
→ Specification Mutation
→ Graph Mutation
→ Affected Scope Resolution
→ Task Regeneration
→ Scoped Re-execution
→ Validation
→ Reconciliation
→ Versioned Output
Iteration Rules
Automatic Mutations
additive features
localized UI changes
isolated flows
non-breaking extensions
Approval-Gated Mutations
entity additions/removals
entity renames
interface additions/removals
interface renames
dependency graph restructuring
architectural rewrites
execution-target migrations
invariant-affecting mutations
Persistent State Rules

Iteration Mode maintains:

graph continuity
semantic version history
architectural diffs
execution lineage
reconciliation history
Exit Conditions

Iteration Mode is persistent and does not terminate unless:

project deletion occurs
repository ownership transfer occurs
graph state becomes unrecoverable

## 6.4 Existing Repository Entry Path
Purpose

Allow existing software systems to directly enter semantic iteration workflows.

Entry Conditions

Users providing existing repositories bypass Documentation Mode and enter Repository Ingestion Flow.

Repository Ingestion Flow
Repository
→ Repository Analysis
→ Semantic Extraction
→ Graph Reconstruction
→ Validation
→ Reconciliation
→ Iteration Mode
Constraints

The system MUST:

ingest entire repositories
infer semantic structures globally
reconstruct entities/interfaces/flows
infer architectural relationships
identify inconsistencies
generate canonical graph state

Partial feature-only ingestion is disallowed.

---

# 7. Existing Repository Ingestion

## Purpose

Allow existing software systems to enter semantic iteration workflows.

---

## Intake Requirements

The system MUST:

* ingest entire repositories
* infer semantic structures globally
* reconstruct entities/interfaces/flows
* infer architectural relationships
* identify inconsistencies
* generate semantic graph state

---

## Constraint

Partial feature-only ingestion is disallowed.

Global repository understanding is required for:

* dependency integrity
* architectural continuity
* invariant preservation

---

# 8. Execution Capability Matrix

## Definition

Execution targets are structured orchestration domains defining:

* runtime assumptions
* infra assumptions
* deployment models
* validation packs
* architectural constraints
* supported patterns

---

## Initial Target Examples

| Target  | Runtime      | Deployment  | Primary Language |
| ------- | ------------ | ----------- | ---------------- |
| Next.js | Node         | Vercel      | TypeScript       |
| Expo    | React Native | EAS         | TypeScript       |
| FastAPI | Python       | Railway/Fly | Python           |

---

## Constraint

Execution targets MUST compile from structured graph semantics rather than prompt-level improvisation.

---

# 9. Collaboration Model

## Core Principle

Collaboration occurs on semantic state, not raw prompts.

---

## Supported Collaboration Structures

* workspaces
* members
* permissions
* graph versions
* semantic branches
* forks
* approvals
* execution visibility

---

## Semantic Versioning

The system supports:

* graph diffs
* architectural diffs
* entity diffs
* interface diffs
* dependency diffs
* flow diffs

---

## Reconciliation Model

Concurrent mutations reconcile through:

* invariant validation
* dependency analysis
* semantic conflict detection
* approval-gated merges

Raw textual merge systems are non-canonical.

---

# 10. User Types

---

## Non-Technical Users

Interact primarily through:

* goals
* workflows
* UI expectations
* business intent
* operational behavior

The system abstracts:

* infra complexity
* architecture selection
* deployment systems
* implementation details

---

## Technical Users

Can directly:

* modify specifications
* define constraints
* control execution targets
* influence architecture
* define invariants
* control orchestration assumptions

---

# 11. Ownership Model

## User Ownership

Users fully own:

* generated code
* deployments
* repositories
* runtime systems

---

## Sembl Ownership

sembl retains ownership of:

* semantic orchestration systems
* graph intelligence
* normalization systems
* execution intelligence
* orchestration infrastructure

---

## Exit Condition

Users retain functioning software systems even after leaving sembl.

Semantic iteration intelligence is lost outside sembl.

---

# 12. Canonical System Architecture

## Canonical Representation

V4.3 JSON graph format is canonical. 

---

## Canonical Layers

```text id="yzd32n"
Intent Layer
→ Specification Layer
→ Graph Layer
→ Validation Layer
→ Task Graph Layer
→ Execution Layer
→ Reconciliation Layer
→ Deployment Layer
```

---

# 13. Validation Model

## Mandatory Validation Requirements

* compile success
* type safety
* dependency validity
* interface contract validation
* postcondition validation
* undefined reference detection
* invariant validation
* runtime-target validation

---

## Architectural Goal

Generated systems MUST:

* preserve semantic coherence
* avoid duplicated abstractions
* avoid recursive slop
* maintain architectural continuity
* meet competent developer expectations

---

# 14. Visibility Model

## User Visible

* execution progress
* deployment state
* validation summaries
* architectural diffs
* semantic version history
* approval flows

---

## Hidden

* internal normalization passes
* orchestration internals
* raw execution DAGs
* internal graph optimization structures

---

# 15. Long-Term Direction

sembl aims to transform software engineering from:

* prompt iteration
* file manipulation
* stateless generation
* architecture rediscovery

into:

* semantic state evolution
* graph-governed execution
* persistent architectural intelligence
* collaborative semantic software engineering

The system treats software as:

* evolving semantic infrastructure
* graph-structured architectural state
* persistent execution intelligence

rather than generated text artifacts.

---

# 16. Explicit Assumptions

## A1

Design Artifacts become immutable during active execution and mutate only through Iteration Mode.

---

## A2

Execution operates through DAG-based stateless workers with graph-scoped context.

---

## A3

Canonical graph structures MAY contain execution-target-aware semantic structures when explicitly represented and invariant-validatable.

---

## A4

Execution targets define:

* runtime constraints
* deployment assumptions
* validation packs
* infra capabilities
* orchestration boundaries

through structured execution adapters.

---

## A5

Architectural mutation approval heuristics in v1 operate through structural graph mutation detection.

Approval-gated mutations include:

entity additions
entity removals
entity renames
interface additions
interface removals
interface renames
dependency graph restructuring
execution-target migrations

Mutations outside these categories execute automatically unless invariant violations are detected.

---

## A6

Version history stores:

* graph states
* specifications
* architectural diffs
* validation outputs
* deployment references

but not permanent full execution contexts.

---

## A7

Validation failures block successful deployment completion.

---

## A8

Semantic graph state supports:

* branching
* versioning
* concurrent mutation coordination
* semantic diffing
* approval-gated reconciliation

through structured semantic operations.

---

## A9

Execution targets remain compiler-resolved orchestration domains rather than unconstrained generation environments.

---

## A10

The graph remains canonical even when generated code diverges temporarily during execution or reconciliation phases.

---

# 17. Success Definition

sembl succeeds if it can:

* generate coherent production-grade systems
* preserve architectural continuity under iteration
* support multi-runtime semantic execution
* maintain semantic stability across long development cycles
* enable collaborative semantic software engineering
* outperform direct vibe-coding workflows in long-term maintainability and iteration reliability

while keeping the graph as canonical architectural state.
', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('9e83e00e-58f7-5784-8f3f-d72ada9ef06d', '1eb82c5a-70fd-5a67-9898-8e04b9cb144c', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# PDD — Product Definition Document

## sembl — Graph-Driven Semantic Software Engineering System

### Draft v1

---

# 1. Product Identity

## Product Name

sembl

## Product Category

Graph-driven semantic software engineering platform.

## Core Definition

sembl is a graph-native AI software engineering system that transforms user intent into production-grade software systems through structured specification generation, canonical semantic graphs, scoped execution orchestration, and persistent architectural state.

The system treats:

* graph state as canonical
* specifications as first-class
* code as compiled output
* iteration as semantic graph mutation
* collaboration as coordinated semantic state evolution

rather than:

* prompt-driven file generation
* stateless code synthesis
* isolated AI chat interactions

---

# 2. Product Objective

The objective of sembl is to operationalize the V4.3 methodology into a production software system capable of:

* generating maintainable software systems
* preserving architectural continuity across iterations
* enabling graph-governed software evolution
* supporting multi-stack execution
* enabling semantic collaboration
* preventing architectural drift under long iterative cycles

The system exists to solve the primary failure modes of AI-assisted software engineering:

* architectural inconsistency
* duplicated abstractions
* uncontrolled regeneration
* semantic fragmentation
* context collapse
* recursive implementation drift
* incoherent iteration chains
* local optimization over global coherence

---

# 3. Core Product Thesis

Modern frontier models are already capable of substantial software generation.

The bottleneck is no longer raw code synthesis.

The bottleneck is:

* semantic persistence
* architectural continuity
* scoped reasoning
* deterministic orchestration
* invariant preservation
* controlled iteration
* execution locality
* graph-governed evolution

sembl exists to solve these bottlenecks through:

* structured specifications
* canonical graph state
* scoped semantic execution
* graph-constrained orchestration
* semantic versioning
* architecture-aware iteration

---

# 4. Canonical Product Philosophy

## 4.1 Graph as Canonical State

The graph is the canonical persistent representation of the software system.

The graph contains:

* entities
* interfaces
* flows
* dependencies
* invariants
* architectural relationships
* runtime assumptions
* deployment assumptions
* execution boundaries
* validation structures
* collaboration state

All execution derives from graph state.

All modifications reconcile back into graph state.

---

## 4.2 Specifications are Primary

The primary source of truth is structured specification state.

This includes:

* PDD
* PRD
* NFR
* UI/UX specifications
* system flows
* entities
* APIs
* DB schemas
* infrastructure assumptions
* architectural constraints
* execution targets

Code generation is downstream of specification state.

---

## 4.3 Prompt as Semantic Mutation

Prompts are not direct implementation instructions.

Prompts:

* mutate specification state
* mutate graph state
* trigger scoped execution
* evolve architectural structures

The system prevents uncontrolled prompt-level regeneration.

---

## 4.4 Code as Compiled Artifact

Generated code is not canonical state.

Generated code is:

* compiled semantic output
* execution artifact
* runtime representation of graph state

The graph remains canonical.

---

## 4.5 Structured Over Improvised Execution

The system prioritizes:

* constrained execution
* graph-scoped reasoning
* semantic locality
* invariant-aware orchestration
* architecture-preserving evolution

over unconstrained generation.

---

# 5. Product Scope

## Included

### Software Targets

* full-stack web applications
* mobile applications
* API/backend systems

### Core Capabilities

* AI-assisted specification generation
* graph-driven execution
* semantic iteration
* existing repository ingestion
* architectural diffing
* semantic versioning
* multi-user collaboration
* real-time semantic synchronization
* scoped execution orchestration
* deployment orchestration
* semantic branching/forking
* approval-gated architectural mutations

### Execution Capabilities

* multi-runtime execution
* multi-framework execution
* execution-target-aware orchestration
* runtime-specific validation
* deployment adapter systems

---

## Excluded (v1)

### Infrastructure

* arbitrary unmanaged infrastructure orchestration
* low-level infrastructure provisioning
* autonomous production operations

### Platforms

* embedded systems
* game engines
* unmanaged native systems

### Intelligence

* unconstrained autonomous self-modifying execution
* unrestricted graph exportability

---

# 6. Core Product Modes and State Transitions

sembl operates through three canonical operational modes governed by explicit state transitions.

The system behaves as a persistent semantic state machine.

## 6.1 Documentation Mode
Purpose

Transform ambiguous user intent into validated executable specification state.

* Inputs
* natural language prompts
* conversations
* uploaded documents
* screenshots
* wireframes
* Figma/Stitch exports
* architectural notes
* repositories (optional)
* Outputs

Structured specification system:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

The system:

infers missing specifications
adapts abstraction depth dynamically
infers technical capability silently
guides users toward specification completeness
Exit Conditions

Documentation Mode exits only when:

specification validation passes
graph extraction readiness is achieved
Design Artifact is locked
invariant requirements are satisfied
Transition Rules
Transition → Execution Mode

Occurs when:

specifications are validated
graph construction succeeds
execution readiness passes validation
Transition → Escalation State

Occurs when:

specification convergence repeatedly fails
invariant conflicts persist
graph construction cannot converge

## 6.2 Execution Mode
Purpose

Transform specification state into deployable software systems through graph-governed execution.

Execution Pipeline
Specifications
→ Concept Graph
→ Normalization
→ Validation
→ Task Graph
→ Scoped Execution
→ Reconciliation
→ Deployment
Execution Characteristics

Execution MUST be:

* DAG-based
* graph-scoped
* dependency-aware
* invariant-aware
* stateless-worker-driven
* topologically ordered
* Outputs
* repositories
* deployments
* execution artifacts
* validation reports
* graph versions
* architectural diffs
* Exit Conditions

Execution Mode exits only when one of the following occurs:

Successful Completion
deployment succeeds
validation passes
reconciliation completes
Escalation
invariant failures persist
execution repeatedly fails
orchestration cannot converge
approval-gated mutations are rejected
Transition Rules
Transition → Iteration Mode

Occurs after:

successful deployment
graph reconciliation completion
persistent graph state creation
Transition → Escalation State

Occurs when:

execution convergence fails
validation repeatedly fails
architectural conflicts remain unresolved

## 6.3 Iteration Mode
Purpose

Enable persistent long-term software evolution through semantic graph mutation.

Iteration Mode is the steady-state operational mode after first successful deployment.

Iteration Flow
Prompt
→ Specification Mutation
→ Graph Mutation
→ Affected Scope Resolution
→ Task Regeneration
→ Scoped Re-execution
→ Validation
→ Reconciliation
→ Versioned Output
Iteration Rules
Automatic Mutations
additive features
localized UI changes
isolated flows
non-breaking extensions
Approval-Gated Mutations
entity additions/removals
entity renames
interface additions/removals
interface renames
dependency graph restructuring
architectural rewrites
execution-target migrations
invariant-affecting mutations
Persistent State Rules

Iteration Mode maintains:

graph continuity
semantic version history
architectural diffs
execution lineage
reconciliation history
Exit Conditions

Iteration Mode is persistent and does not terminate unless:

project deletion occurs
repository ownership transfer occurs
graph state becomes unrecoverable

## 6.4 Existing Repository Entry Path
Purpose

Allow existing software systems to directly enter semantic iteration workflows.

Entry Conditions

Users providing existing repositories bypass Documentation Mode and enter Repository Ingestion Flow.

Repository Ingestion Flow
Repository
→ Repository Analysis
→ Semantic Extraction
→ Graph Reconstruction
→ Validation
→ Reconciliation
→ Iteration Mode
Constraints

The system MUST:

ingest entire repositories
infer semantic structures globally
reconstruct entities/interfaces/flows
infer architectural relationships
identify inconsistencies
generate canonical graph state

Partial feature-only ingestion is disallowed.

---

# 7. Existing Repository Ingestion

## Purpose

Allow existing software systems to enter semantic iteration workflows.

---

## Intake Requirements

The system MUST:

* ingest entire repositories
* infer semantic structures globally
* reconstruct entities/interfaces/flows
* infer architectural relationships
* identify inconsistencies
* generate semantic graph state

---

## Constraint

Partial feature-only ingestion is disallowed.

Global repository understanding is required for:

* dependency integrity
* architectural continuity
* invariant preservation

---

# 8. Execution Capability Matrix

## Definition

Execution targets are structured orchestration domains defining:

* runtime assumptions
* infra assumptions
* deployment models
* validation packs
* architectural constraints
* supported patterns

---

## Initial Target Examples

| Target  | Runtime      | Deployment  | Primary Language |
| ------- | ------------ | ----------- | ---------------- |
| Next.js | Node         | Vercel      | TypeScript       |
| Expo    | React Native | EAS         | TypeScript       |
| FastAPI | Python       | Railway/Fly | Python           |

---

## Constraint

Execution targets MUST compile from structured graph semantics rather than prompt-level improvisation.

---

# 9. Collaboration Model

## Core Principle

Collaboration occurs on semantic state, not raw prompts.

---

## Supported Collaboration Structures

* workspaces
* members
* permissions
* graph versions
* semantic branches
* forks
* approvals
* execution visibility

---

## Semantic Versioning

The system supports:

* graph diffs
* architectural diffs
* entity diffs
* interface diffs
* dependency diffs
* flow diffs

---

## Reconciliation Model

Concurrent mutations reconcile through:

* invariant validation
* dependency analysis
* semantic conflict detection
* approval-gated merges

Raw textual merge systems are non-canonical.

---

# 10. User Types

---

## Non-Technical Users

Interact primarily through:

* goals
* workflows
* UI expectations
* business intent
* operational behavior

The system abstracts:

* infra complexity
* architecture selection
* deployment systems
* implementation details

---

## Technical Users

Can directly:

* modify specifications
* define constraints
* control execution targets
* influence architecture
* define invariants
* control orchestration assumptions

---

# 11. Ownership Model

## User Ownership

Users fully own:

* generated code
* deployments
* repositories
* runtime systems

---

## Sembl Ownership

sembl retains ownership of:

* semantic orchestration systems
* graph intelligence
* normalization systems
* execution intelligence
* orchestration infrastructure

---

## Exit Condition

Users retain functioning software systems even after leaving sembl.

Semantic iteration intelligence is lost outside sembl.

---

# 12. Canonical System Architecture

## Canonical Representation

V4.3 JSON graph format is canonical. 

---

## Canonical Layers

```text id="yzd32n"
Intent Layer
→ Specification Layer
→ Graph Layer
→ Validation Layer
→ Task Graph Layer
→ Execution Layer
→ Reconciliation Layer
→ Deployment Layer
```

---

# 13. Validation Model

## Mandatory Validation Requirements

* compile success
* type safety
* dependency validity
* interface contract validation
* postcondition validation
* undefined reference detection
* invariant validation
* runtime-target validation

---

## Architectural Goal

Generated systems MUST:

* preserve semantic coherence
* avoid duplicated abstractions
* avoid recursive slop
* maintain architectural continuity
* meet competent developer expectations

---

# 14. Visibility Model

## User Visible

* execution progress
* deployment state
* validation summaries
* architectural diffs
* semantic version history
* approval flows

---

## Hidden

* internal normalization passes
* orchestration internals
* raw execution DAGs
* internal graph optimization structures

---

# 15. Long-Term Direction

sembl aims to transform software engineering from:

* prompt iteration
* file manipulation
* stateless generation
* architecture rediscovery

into:

* semantic state evolution
* graph-governed execution
* persistent architectural intelligence
* collaborative semantic software engineering

The system treats software as:

* evolving semantic infrastructure
* graph-structured architectural state
* persistent execution intelligence

rather than generated text artifacts.

---

# 16. Explicit Assumptions

## A1

Design Artifacts become immutable during active execution and mutate only through Iteration Mode.

---

## A2

Execution operates through DAG-based stateless workers with graph-scoped context.

---

## A3

Canonical graph structures MAY contain execution-target-aware semantic structures when explicitly represented and invariant-validatable.

---

## A4

Execution targets define:

* runtime constraints
* deployment assumptions
* validation packs
* infra capabilities
* orchestration boundaries

through structured execution adapters.

---

## A5

Architectural mutation approval heuristics in v1 operate through structural graph mutation detection.

Approval-gated mutations include:

entity additions
entity removals
entity renames
interface additions
interface removals
interface renames
dependency graph restructuring
execution-target migrations

Mutations outside these categories execute automatically unless invariant violations are detected.

---

## A6

Version history stores:

* graph states
* specifications
* architectural diffs
* validation outputs
* deployment references

but not permanent full execution contexts.

---

## A7

Validation failures block successful deployment completion.

---

## A8

Semantic graph state supports:

* branching
* versioning
* concurrent mutation coordination
* semantic diffing
* approval-gated reconciliation

through structured semantic operations.

---

## A9

Execution targets remain compiler-resolved orchestration domains rather than unconstrained generation environments.

---

## A10

The graph remains canonical even when generated code diverges temporarily during execution or reconciliation phases.

---

# 17. Success Definition

sembl succeeds if it can:

* generate coherent production-grade systems
* preserve architectural continuity under iteration
* support multi-runtime semantic execution
* maintain semantic stability across long development cycles
* enable collaborative semantic software engineering
* outperform direct vibe-coding workflows in long-term maintainability and iteration reliability

while keeping the graph as canonical architectural state.
', '0e2ef5ae37aaa3514378bb800fb97f5033f6c7644fed67338f4aeef1b3e16eb7', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = '9e83e00e-58f7-5784-8f3f-d72ada9ef06d', updated_at = '2026-06-02T12:00:00.000Z' where id = '1eb82c5a-70fd-5a67-9898-8e04b9cb144c';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('a58aeb9d-a27a-53a7-bf68-17891a983e51', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'prd', '# PRD — sembl v1

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


', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('91e635da-2b5a-51b0-9492-21c5027fdea3', 'a58aeb9d-a27a-53a7-bf68-17891a983e51', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# PRD — sembl v1

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


', '9e05ef20674d6a6c3dc2a8a400d994e1d9b9bc983bd1a770a8377ca64e4e4209', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = '91e635da-2b5a-51b0-9492-21c5027fdea3', updated_at = '2026-06-02T12:00:00.000Z' where id = 'a58aeb9d-a27a-53a7-bf68-17891a983e51';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('c9026435-10e3-59ea-bbc3-aef4111317c3', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'nfr', '# NFR Section 1 — Operational Philosophy and Canonical Constraints

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

', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('67a0e984-c23d-5374-b639-e4ffaafb36f5', 'c9026435-10e3-59ea-bbc3-aef4111317c3', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# NFR Section 1 — Operational Philosophy and Canonical Constraints

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

', '9a4fc2c09b01894908724e51d69244aa15e286a489ba307f15998f4b48c4b67a', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = '67a0e984-c23d-5374-b639-e4ffaafb36f5', updated_at = '2026-06-02T12:00:00.000Z' where id = 'c9026435-10e3-59ea-bbc3-aef4111317c3';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('afc194d2-a715-54fc-add6-dc9cbd4d1c9e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'uiux', '# UI/UX Specification — Section 1

# Purpose, Scope, and UX Invariants

---

# 1.1 Purpose

This document defines the canonical interaction architecture for sembl v1.

It specifies:

* information architecture
* navigation architecture
* workspace architecture
* operational workflows
* interaction flows
* screen architecture
* visibility architecture
* state architecture
* approval behavior
* validation behavior
* reconciliation behavior
* deployment behavior
* user-visible system behavior

This document is authoritative for:

* UX design
* screen generation
* Figma generation
* Stitch generation
* HTML generation
* interaction modeling
* workflow extraction
* graph extraction

The document defines how users interact with sembl.

It does not define how sembl is visually styled.

---

# 1.2 Relationship to Other Canonical Documents

The UI/UX Specification is downstream of:

* PDD
* PRD
* NFR
* V4.3 Formal Specification
* V4.3 Execution Architecture

This document must remain consistent with all upstream specifications.

If interpretation conflicts occur:

```text
V4.3
→ PDD
→ PRD
→ NFR
→ UI/UX Specification
```

Higher-order documents remain authoritative.

---

# 1.3 Scope

This document defines user-visible behavior for:

* Documentation Mode
* Execution Mode
* Iteration Mode
* Repository Ingestion
* Validation
* Reconciliation
* Branching
* Deployment
* Collaboration
* Approval Workflows
* Audit Visibility
* Operational Visibility

This document defines:

* what users see
* what users can do
* where users can go
* when actions are available
* how state transitions occur

This document does not define:

* visual branding
* colors
* typography
* component styling
* animation systems
* design language

Those are downstream design concerns.

---

# 1.4 Canonical UX Objective

The primary UX objective of sembl is:

> Enable users to build, evolve, validate, and deploy software through specifications while preserving architectural continuity.

The product should feel like:

```text
Software evolves through specifications.
```

The product should not feel like:

```text
Managing repositories.

Managing graph databases.

Operating AI agents.

Managing execution DAGs.

Writing prompts to generate files.
```

The interaction model must continuously reinforce:

* specification primacy
* architectural continuity
* graph canonicality
* scoped execution
* reconciliation-governed mutation

without requiring users to understand those systems directly.

---

# 1.5 User Experience Model

sembl operates through progressive abstraction.

The same system must support:

* non-technical users
* semi-technical users
* highly technical users

without creating separate products.

The system progressively reveals complexity as user needs increase.

---

## Non-Technical User Experience

Primary interaction objects:

* goals
* requirements
* workflows
* specifications
* progress
* approvals
* outputs

The user should rarely need to interact with:

* graph structures
* dependency structures
* execution topology
* reconciliation internals

unless explicitly requested.

---

## Technical User Experience

Technical users may progressively access:

* graph state
* dependency state
* validation state
* lineage state
* execution topology
* reconciliation state
* deployment state

Advanced visibility must remain available without becoming the default workflow.

---

# 1.6 Progressive Complexity Disclosure Principle

Complexity must be revealed gradually.

Users should always encounter:

```text
Intent
→ Specification
→ Workflow
→ Outcome
```

before encountering:

```text
Graph
→ Dependency
→ Validation
→ Reconciliation
→ Topology
```

Advanced operational state should be inspectable.

It should never become mandatory for routine workflows.

---

# 1.7 Specification Primacy Principle

Specifications are the primary user interaction surface.

Users interact with:

* requirements
* workflows
* entities
* APIs
* UX definitions
* architecture definitions

The graph remains the canonical system state.

However:

the graph is not the primary user-facing editing surface.

All major mutations originate through:

* specification mutation
* structured workflows
* repository reconstruction workflows

rather than direct graph editing.

---

# 1.8 Graph Visibility Principle

Graph visibility is required.

Graph management is not.

The graph exists as:

* inspection surface
* diagnostic surface
* architectural visibility surface

The graph must not become:

* primary navigation
* primary editing model
* required operational interface

Users should understand software structure without needing to understand graph mechanics.

---

# 1.9 Workflow-Centric Navigation Principle

Navigation should organize around user goals.

Navigation should not organize around internal architecture.

Preferred user concepts:

* Specifications
* Execution
* Changes
* Branches
* Deployments
* Activity

Avoid exposing internal concepts as primary navigation destinations:

* Task DAGs
* Agent Systems
* Graph Storage
* Context Generation
* Reconciliation Engines

Internal architecture may be inspectable but should not drive navigation.

---

# 1.10 Execution Transparency Principle

Execution must be visible.

Execution internals do not need to be visible.

Users must always understand:

* what is happening
* what has completed
* what is blocked
* what failed
* what requires action

Users are not required to understand:

* agent orchestration
* worker allocation
* DAG execution internals
* planning internals

The system exposes progress.

The system may hide implementation mechanics.

---

# 1.11 Validation Visibility Principle

Validation is a first-class user-visible system.

Validation failures must never be hidden.

Users must always be able to determine:

* what failed
* why it failed
* what is affected
* what must be resolved

Validation outcomes must be actionable.

Validation visibility is mandatory.

---

# 1.12 Reconciliation Visibility Principle

Reconciliation is a core system behavior.

Users must be able to inspect:

* what changed
* why it changed
* affected structures
* architectural impact
* dependency impact

The system must make architectural evolution understandable.

Reconciliation outcomes must remain visible even when reconciliation succeeds.

---

# 1.13 Architectural Continuity Principle

The UX must reinforce continuity rather than regeneration.

Users should experience:

```text
Evolving software
```

rather than:

```text
Generating software again.
```

The interface must continuously surface:

* existing architecture
* existing entities
* existing interfaces
* existing flows
* existing decisions

before presenting mutation options.

---

# 1.14 Approval Visibility Principle

Approval gates are significant system events.

Approval workflows must clearly communicate:

* why approval is required
* what changed
* impact scope
* execution consequences

Approvals must never appear as arbitrary interruptions.

Approvals must be contextualized through visible architectural impact.

---

# 1.15 Visibility Hierarchy Principle

User-visible information should be presented in the following order:

```text
Goals
→ Specifications
→ Progress
→ Outputs
→ Changes
→ Validation
→ Reconciliation
→ Graph State
→ Execution Topology
```

Lower-level system state must not dominate higher-level user intent.

---

# 1.16 UX Invariants

The following invariants are mandatory across all sembl interfaces.

---

## UX-I1 — Specification Primacy

Users interact primarily through specifications.

Direct graph manipulation is not a primary workflow.

---

## UX-I2 — Graph Secondary

The graph is inspectable but not central.

Users can complete normal workflows without entering graph views.

---

## UX-I3 — Workflow First

Navigation prioritizes workflows and outcomes over internal system architecture.

---

## UX-I4 — Progressive Disclosure

Advanced system complexity is revealed only when relevant.

---

## UX-I5 — Validation Visibility

Validation failures must remain visible until resolved.

---

## UX-I6 — Reconciliation Visibility

Reconciliation outcomes must remain inspectable.

---

## UX-I7 — Architectural Mutation Visibility

Architectural mutations must clearly expose impact before approval.

---

## UX-I8 — Approval Before Architectural Mutation

Approval-gated mutations cannot proceed without explicit approval.

---

## UX-I9 — Execution Transparency

Execution progress must always be visible.

---

## UX-I10 — State Transparency

Users must always know:

* current state
* blocked state
* failure state
* required next action

---

## UX-I11 — Architectural Continuity

Interfaces must reinforce evolution of existing architecture rather than regeneration.

---

## UX-I12 — Canonical Consistency

All user-visible interactions must remain consistent with:

* graph canonicality
* specification primacy
* scoped execution
* reconciliation-governed mutation
* lineage preservation

---

# UI/UX Specification — Section 2

# Information Architecture

---

# 2.1 Purpose

The Information Architecture defines the canonical organizational structure of sembl.

It determines:

* what objects exist
* how objects relate
* ownership boundaries
* visibility boundaries
* navigation hierarchy
* workflow hierarchy

The Information Architecture must reflect the core operational model defined by:

```text
Specification
→ Graph
→ Execution
→ Reconciliation
→ Iteration
```

while exposing the system through user-oriented concepts rather than internal implementation structures.

---

# 2.2 Architectural Principle

The Information Architecture is organized around:

```text
Workspace
→ Project
→ Software Evolution
```

not around:

```text
Repositories
Graphs
Agents
Tasks
Files
```

The system should feel like managing an evolving software system rather than managing implementation artifacts.

---

# 2.3 Primary Information Objects

The following are canonical user-visible objects.

---

## Workspace

Highest-level organizational container.

Contains:

* members
* permissions
* projects
* approvals
* activity history

Responsibilities:

* collaboration boundary
* security boundary
* ownership boundary

A user may belong to multiple workspaces.

---

## Project

Primary operational container.

Represents a single software system.

Contains:

* specifications
* graph state
* execution history
* branches
* deployments
* validation history
* reconciliation history

A project is the primary unit of work.

---

## Specification Set

Represents the canonical specification layer.

Includes:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

Responsibilities:

* intent definition
* architecture definition
* execution source definition

Specifications are primary user-editable artifacts.

The specification set is the authoritative source for:

- graph extraction
- validation
- execution planning
- reconciliation
- software evolution

---

## Execution

Represents software generation and implementation activities.

Contains:

* execution runs
* execution progress
* validation results
* reconciliation results
* deployment outputs

Execution is non-canonical.

Execution derives from specifications and graph state.

---

## Branch

Represents an isolated semantic evolution path.

Contains:

* mutations
* diffs
* approvals
* execution history
* lineage references

Branches operate on graph state rather than repositories.

---

## Deployment

Represents a generated runtime output.

Contains:

* deployment metadata
* deployment references
* environment references
* deployment history

Deployments are non-canonical operational outputs.

---

## Approval

Represents a required governance decision.

Approval types:

* execution approval
* architectural mutation approval
* merge approval

Approvals are workflow objects rather than content objects.

---

## Activity

Represents historical operational visibility.

Contains:

* mutations
* executions
* approvals
* validations
* reconciliations
* deployments

Activity is read-only historical state.

---

## Graph

Represents canonical architectural state.

Contains:

* entities
* interfaces
* flows
* dependencies
* invariants
* lineage

Graph visibility exists primarily for inspection.

Graph editing is not a primary workflow.

---

# 2.4 Information Hierarchy

The canonical hierarchy is:

```text
Workspace
│
├ Members
├ Approvals
├ Activity
│
└ Projects
      │
      ├ Overview
      ├ Specifications
      ├ Execution
      ├ Changes
      ├ Branches
      ├ Deployments
      ├ Activity
      └ Graph
```

This hierarchy defines the primary organizational structure of the product.

---

# 2.5 Project Internal Structure

Every project is organized around software evolution.

```text
Project
│
├ Overview
│
├ Specifications
│     ├ PDD
│     ├ PRD
│     ├ NFR
│     ├ UI/UX
│     ├ System Design
│     ├ DB Schema
│     ├ API Spec
│     ├ Tech Architecture
│    
│
├ Execution
│
├ Changes
│
├ Branches
│
├ Deployments
│
├ Activity
│
└ Graph
```

This structure remains consistent regardless of operational mode.

---

# 2.6 Ownership Model

Ownership exists at three levels.

---

## Workspace Ownership

Owns:

* members
* permissions
* projects

Responsible for:

* governance
* access control
* collaboration

---

## Project Ownership

Owns:

* specifications
* graph state
* branches
* deployments
* activity history

Responsible for:

* software evolution
* execution lifecycle

---

## Branch Ownership

Owns:

* isolated mutations
* branch execution state
* branch approvals
* branch lineage

Responsible for:

* safe experimentation
* isolated evolution

---

# 2.7 Visibility Model

Information visibility follows progressive disclosure.

---

## Level 1 — Intent Visibility

Visible to all users by default.

Includes:

* goals
* requirements
* specifications
* progress
* outputs

This is the primary user experience.

---

## Level 2 — Operational Visibility

Visible during execution and iteration workflows.

Includes:

* validation
* approvals
* diffs
* execution progress
* deployments

This is the primary project management layer.

---

## Level 3 — Architectural Visibility

Available on demand.

Includes:

* entities
* interfaces
* flows
* dependencies
* lineage

This is the primary technical inspection layer.

---

## Level 4 — Deep Technical Visibility

Available through advanced inspection.

Includes:

* graph topology
* validation structures
* reconciliation details
* execution topology
* dependency analysis

This visibility exists for diagnosis and review.

It is not required for routine workflows.

---

# 2.8 Canonical User Mental Model

The product should encourage the following mental model:

```text
Workspace
    ↓
Project
    ↓
Specifications
    ↓
Build
    ↓
Deploy
    ↓
Evolve
```

Not:

```text
Workspace
    ↓
Repository
    ↓
Files
    ↓
Code Generation
```

And not:

```text
Workspace
    ↓
Graph
    ↓
Nodes
    ↓
Edges
```

The graph exists beneath the experience.

The user experiences software evolution.

---

# 2.9 Information Architecture Constraints

---

## IA-I1 — Project-Centric Organization

Projects are the primary operational unit.

All major workflows originate from projects.

---

## IA-I2 — Specification-Centric Structure

Specifications remain the primary editable artifacts.

---

## IA-I3 — Graph Secondary

Graph structures remain subordinate to specifications in the information hierarchy.

---

## IA-I4 — Operational Separation

Execution, deployments, branches, and activity remain distinct operational domains.

---

## IA-I5 — Progressive Visibility

Technical detail visibility increases progressively.

Complexity must never be front-loaded.

---

## IA-I6 — Architectural Continuity

Information architecture must reinforce continuity across project evolution.

Historical context must remain discoverable.

---

## IA-I7 — Repository Non-Canonicality

Repositories and generated code must never appear as canonical project state.

Canonical state remains:

* specifications
* graph
* lineage
* validation
* reconciliation

---

## IA-I8 — Workflow Alignment

Information organization must align with software evolution workflows rather than implementation storage structures.

---

# UI/UX Specification — Section 3

# Navigation and Workspace Architecture

---

# 3.1 Purpose

Navigation Architecture defines how users move through sembl.

Workspace Architecture defines the persistent operational environment within which all user activity occurs.

Together they establish:

* navigation hierarchy
* workspace structure
* operational orientation
* state visibility
* context persistence

The navigation model must support:

* Documentation Mode
* Execution Mode
* Iteration Mode
* Repository Ingestion

without requiring users to consciously manage modes.

Modes are system states.

Projects are user-facing constructs.

---

# 3.2 Navigation Philosophy

Navigation is organized around software evolution.

Navigation must prioritize:

```text
Specifications
→ Build
→ Deploy
→ Evolve
```

Navigation must not prioritize:

```text
Graphs
→ Agents
→ Tasks
→ Execution Internals
```

The navigation structure should reinforce the mental model:

```text
I am building software.
```

not:

```text
I am operating a semantic graph system.
```

---

# 3.3 Navigation Hierarchy

Navigation exists across three levels.

```text id="6c9o3y"
Global Navigation
      ↓
Project Navigation
      ↓
Contextual Navigation
```

Each level serves a different purpose.

---

# 3.4 Global Navigation

Global Navigation operates at workspace scope.

Accessible from all screens.

---

## Global Destinations

### Projects

Purpose:

Primary project access surface.

Contains:

* all accessible projects
* project search
* project creation
* project status visibility

---

### Approvals

Purpose:

Centralized approval queue.

Contains:

* pending approvals
* execution approvals
* architectural mutation approvals
* merge approvals

Must surface:

* urgency
* impact
* blocked workflows

---

### Activity

Purpose:

Workspace-wide operational visibility.

Contains:

* project activity
* executions
* deployments
* approvals
* merges
* mutations

Acts as organizational audit surface.

---

### Workspace Settings

Purpose:

Workspace administration.

Contains:

* members
* permissions
* integrations
* workspace configuration

---

# 3.5 Project Navigation

Project Navigation is the primary operational navigation system.

Every project exposes the same navigation structure.

---

## Overview

Purpose:

Project status and orientation.

Provides:

* project health
* current state
* active work
* recent changes
* execution status
* deployment status

Overview acts as the project home.

---

## Specifications

Purpose:

Primary software definition workspace.

Contains:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

This is the primary editing surface of the platform.

---

## Execution

Purpose:

Execution lifecycle visibility.

Contains:

* execution progress
* validation status
* reconciliation status
* deployment status
* execution history

Execution does not expose implementation internals by default.

---

## Changes

Purpose:

Software evolution visibility.

Contains:

* semantic diffs
* mutation history
* version history
* reconciliation summaries

Changes answers:

```text
What changed?
Why did it change?
What was affected?
```

---

## Branches

Purpose:

Parallel software evolution management.

Contains:

* active branches
* branch comparisons
* merge status
* branch lineage

---

## Deployments

Purpose:

Runtime delivery visibility.

Contains:

* deployment history
* deployment environments
* deployment status
* deployment failures
* rollback history

---

## Activity

Purpose:

Project-specific operational timeline.

Contains:

* approvals
* mutations
* validations
* executions
* deployments

---

## Graph

Purpose:

Architectural inspection.

Contains:

* entities
* interfaces
* flows
* dependencies
* lineage

Graph remains an inspection surface.

Graph is never the primary editing surface.

---

# 3.6 Contextual Navigation

Contextual Navigation exists within a destination.

It exposes information relevant to the current workflow.

---

## Specifications Context

Example:

```text id="m8v8sl"
Documents
Dependencies
Validation
Assumptions
History
```

---

## Execution Context

Example:

```text id="g2l88p"
Progress
Validation
Reconciliation
Deployment
History
```

---

## Changes Context

Example:

```text id="q8hns9"
Diffs
Impact
Lineage
Versions
```

---

## Branch Context

Example:

```text id="c2t9jv"
Overview
Changes
Execution
Merge Status
```

---

## Graph Context

Example:

```text id="44j3jm"
Entities
Interfaces
Flows
Dependencies
Lineage
```

Contextual navigation must remain localized and workflow-specific.

---

# 3.7 Workspace Shell

The Workspace Shell is the persistent environment visible across most screens.

The shell must maintain continuity while users move between workflows.

---

## Persistent Elements

The following elements remain consistently available.

### Global Navigation

Provides workspace-level movement.

---

### Project Navigation

Provides project-level movement.

---

### Project Context

Displays:

* current project
* current branch
* current version state

Users must always know where they are.

---

### Status Surface

Displays:

* execution status
* validation status
* approval status

without requiring navigation.

---

### Notifications Surface

Displays:

* approvals required
* execution completion
* validation failures
* deployment failures

---

### User Context

Displays:

* user identity
* workspace identity
* permissions

---

# 3.8 Project Context Model

The system must continuously maintain visible context.

Users should never lose awareness of:

```text id="4nd7um"
Workspace
Project
Branch
State
```

The active context should remain visible across navigation transitions.

---

## Required Context Indicators

At minimum:

### Active Workspace

### Active Project

### Active Branch

### Current State

Examples:

```text
Draft

Ready For Execution

Executing

Awaiting Approval

Iterating

Deployment Failed
```

---

# 3.9 Navigation Behavior by Operational Mode

The navigation structure remains stable across modes.

The visible content changes.

---

## Documentation Mode

Primary emphasis:

```text
Overview
Specifications
Validation
Approval
```

Execution-related sections remain secondary.

---

## Execution Mode

Primary emphasis:

```text
Execution
Validation
Reconciliation
Deployment
```

Specifications remain accessible.

---

## Iteration Mode

Primary emphasis:

```text
Changes
Branches
Execution
Deployments
```

Specifications remain editable.

---

## Repository Ingestion

Temporary emphasis:

```text
Repository
Analysis
Confidence Review
Validation
Activation
```

Once activated, the standard project navigation appears.

---

# 3.10 Navigation Visibility Rules

---

## NAV-I1 — Stable Navigation

Navigation structure must remain consistent throughout the project lifecycle.

Users should not experience major navigation restructuring between modes.

---

## NAV-I2 — Specification Accessibility

Specifications must always remain accessible regardless of current state.

---

## NAV-I3 — Context Persistence

Workspace, project, and branch context must remain continuously visible.

---

## NAV-I4 — Approval Visibility

Pending approvals must be visible globally.

Users should not need to discover blocked work manually.

---

## NAV-I5 — Failure Visibility

Execution failures, validation failures, and deployment failures must surface prominently.

---

## NAV-I6 — Graph Secondary

Graph access must remain available but non-dominant.

Graph navigation must never displace specification workflows.

---

## NAV-I7 — Workflow Orientation

Navigation labels should describe user goals and workflows rather than internal system implementation.

---

## NAV-I8 — Progressive Technical Exposure

Technical navigation destinations should become more prominent only when users enter technical workflows.

---

# 3.11 Workspace Architecture Constraints

---

## WA-I1

Projects are the primary operational unit.

---

## WA-I2

Specifications are the primary authoring surface.

---

## WA-I3

Execution is primarily observed, not manually managed.

---

## WA-I4

Changes are first-class navigation entities.

---

## WA-I5

Branches represent semantic evolution paths, not repository forks.

---

## WA-I6

Graph inspection must remain optional.

---

## WA-I7

Users must always know:

* where they are
* what state the project is in
* what requires action
* what changed recently

---

# UI/UX Specification — Section 4

# Project Lifecycle and Operational Modes

---

# 4.1 Purpose

The Project Lifecycle defines how software evolves inside sembl.

The lifecycle is the primary behavioral structure of the platform.

It governs:

* project creation
* specification generation
* execution
* deployment
* iteration
* repository onboarding
* escalation

The lifecycle defines user-visible progression.

Internal execution systems remain implementation concerns.

---

# 4.2 Lifecycle Principle

Software evolves through semantic state.

The user journey is:

```text
Intent
→ Specification
→ Validation
→ Approval
→ Execution
→ Deployment
→ Iteration
```

The lifecycle must reinforce:

* specification primacy
* architectural continuity
* reconciliation-governed evolution

The lifecycle must avoid:

* prompt-driven regeneration
* repository-centric workflows
* graph-centric workflows

---

# 4.3 Canonical Lifecycle

New projects follow the canonical lifecycle.

```text id="s0r9yt"
Project Creation
        ↓
Documentation Mode
        ↓
Specification Validation
        ↓
Execution Approval
        ↓
Execution Mode
        ↓
Validation
        ↓
Reconciliation
        ↓
Deployment
        ↓
Iteration Mode
```

This is the primary lifecycle for v1.

---

# 4.4 Lifecycle States

Every project exists in one primary lifecycle state.

---

## Draft

Meaning:

Project is being defined.

Characteristics:

* specifications incomplete
* validation incomplete
* execution unavailable

Primary user activity:

* specification creation
* refinement
* review

---

## Ready For Execution

Meaning:

Documentation is complete.

Characteristics:

* specifications validated
* graph extraction readiness achieved
* execution approval pending

Primary user activity:

* review
* approval

---

## Executing

Meaning:

Software generation is underway.

Characteristics:

* execution active
* validation active
* deployment unavailable

Primary user activity:

* monitoring

---

## Reconciling

Meaning:

Execution outputs are being integrated.

Characteristics:

* graph updates active
* validation active
* deployment blocked

Primary user activity:

* monitoring
* issue review

---

## Deploying

Meaning:

Deployment workflows are active.

Characteristics:

* execution completed
* reconciliation completed
* deployment active

Primary user activity:

* monitoring

---

## Active

Meaning:

Project has successfully entered Iteration Mode.

Characteristics:

* deployment completed
* iteration enabled
* mutations allowed

Primary user activity:

* software evolution

---

## Awaiting Approval

Meaning:

Workflow is blocked pending approval.

Characteristics:

* execution paused
* mutation paused
* merge paused

Primary user activity:

* review
* approval

---

## Escalated

Meaning:

Automatic convergence failed.

Characteristics:

* execution blocked
* mutation blocked
* manual intervention required

Primary user activity:

* resolution

---

# 4.5 Project Creation Experience

Project creation is the first interaction with sembl.

The system must immediately orient users toward software creation rather than technical setup.

---

## Supported Entry Paths

### New Project

User begins from intent.

Examples:

```text
I want a fitness coaching platform.

I want an event marketplace.

I want a CRM for consultants.
```

Entry destination:

Documentation Mode.

---

### Existing Repository

User begins from an existing codebase.

Examples:

```text
Import repository.

Continue existing project.

Modernize existing system.
```

Entry destination:

Repository Ingestion Flow.

---

# 4.6 Documentation Mode

---

## Purpose

Transform intent into executable specification state.

Documentation Mode is the specification construction phase.

No software execution occurs during this mode.

---

## Primary User Goal

Answer:

```text
What are we building?
```

---

## Primary User Activities

* defining requirements
* refining specifications
* reviewing assumptions
* resolving ambiguity
* validating completeness

---

## Primary System Activities

* specification generation
* dependency detection
* assumption detection
* validation
* graph extraction readiness analysis

---

## Core User Journey

```text id="8plx0s"
Intent
→ Specification Generation
→ Specification Refinement
→ Validation
→ Approval Readiness
```

---

## User Focus

Users primarily interact with:

* specifications
* requirements
* workflows
* assumptions

Not:

* graph structures
* execution systems
* task orchestration

---

## Exit Conditions

Documentation Mode exits only when:

* specifications validate
* graph extraction readiness passes
* unresolved ambiguity is cleared
* execution approval becomes available

---

# 4.7 Execution Approval State

---

## Purpose

Execution Approval is the final checkpoint before software generation begins.

This is Approval Gate 1.

---

## User Question Being Answered

```text
Are these specifications correct?
```

---

## Visible Information

Users must see:

* specification summary
* execution targets
* inferred assumptions
* validation summary
* architectural assumptions

---

## Available Actions

### Approve

Transitions:

```text
Ready For Execution
→ Executing
```

---

### Return To Documentation

Transitions:

```text
Ready For Execution
→ Draft
```

---

## Blocking Rule

Execution cannot begin until approval is granted.

---

# 4.8 Execution Mode

---

## Purpose

Transform validated semantic state into deployable software.

---

## Primary User Goal

Answer:

```text
What is currently being built?
```

---

## Primary User Activities

* monitoring progress
* reviewing validation
* reviewing failures

---

## Primary System Activities

* graph construction
* normalization
* validation
* DAG generation
* execution
* reconciliation
* deployment preparation

---

## Core User Journey

```text id="rw5wpr"
Execution
→ Validation
→ Reconciliation
→ Deployment
```

---

## User Experience Model

Users experience:

* progress
* milestones
* completion state

Users do not need to manage:

* workers
* DAGs
* orchestration

---

## Exit Conditions

Execution Mode exits when:

### Success

```text
Execution Complete
→ Reconciliation
→ Deployment
```

### Failure

```text
Execution
→ Escalation
```

---

# 4.9 Reconciliation Phase

---

## Purpose

Integrate execution outcomes into canonical graph state.

---

## User Question Being Answered

```text
What changed in the system?
```

---

## Visible Information

* affected structures
* architectural changes
* generated diffs
* dependency impacts

---

## Outcome

Successful reconciliation creates:

* updated graph state
* lineage updates
* version updates

---

## Transition

```text
Reconciliation
→ Deployment
```

---

# 4.10 Deployment Phase

---

## Purpose

Create deployable runtime outputs.

---

## User Question Being Answered

```text
Is the software available?
```

---

## Visible Information

* deployment progress
* deployment status
* environment status
* deployment failures

---

## Outcomes

### Success

```text
Deployment
→ Active
```

### Failure

```text
Deployment
→ Escalated
```

or

```text
Deployment
→ Rollback
```

depending on failure conditions.

---

# 4.11 Iteration Mode

---

## Purpose

Enable long-term software evolution.

Iteration Mode is the steady-state operating mode of sembl.

Most project life is spent here.

---

## Primary User Goal

Answer:

```text
How should the software evolve?
```

---

## Primary User Activities

* requesting changes
* reviewing diffs
* approving mutations
* reviewing deployments

---

## Primary System Activities

* scope analysis
* mutation analysis
* validation
* reconciliation
* localized re-execution

---

## Core User Journey

```text id="9g7vgh"
Change Request
→ Scope Analysis
→ Mutation
→ Validation
→ Reconciliation
→ Deployment
```

---

## Key UX Principle

The experience should feel like:

```text
Evolving software.
```

not:

```text
Generating software again.
```

---

# 4.12 Architectural Mutation Flow

---

## Purpose

Govern high-impact changes.

This is Approval Gate 2.

---

## Trigger Conditions

* entity additions
* entity removals
* entity renames
* interface additions
* interface removals
* interface renames
* dependency restructuring
* execution-target migration
* invariant-affecting changes

---

## User Question Being Answered

```text
Do you approve these architectural changes?
```

---

## Visible Information

Users must see:

* impacted structures
* dependency impact
* execution impact
* architectural diff
* affected scope

---

## Outcomes

### Approved

```text
Approval
→ Re-Execution
```

### Rejected

```text
Approval
→ Iteration Mode
```

with no mutation applied.

---

# 4.13 Repository Ingestion Lifecycle

---

## Purpose

Allow existing software systems to enter semantic evolution workflows.

---

## Core Journey

```text id="4k6g6r"
Repository
→ Analysis
→ Reconstruction
→ Confidence Review
→ Validation
→ Activation
```

---

## User Question Being Answered

```text
Did sembl understand my system correctly?
```

---

## Primary User Activities

* repository connection
* reviewing inferred structures
* resolving ambiguities
* approving reconstruction

---

## Primary System Activities

* repository analysis
* graph reconstruction
* confidence analysis
* validation

---

## Exit Conditions

Repository onboarding exits when:

* validation passes
* low-confidence structures resolved
* graph canonicalization succeeds

---

## Transition

```text
Repository Ingestion
→ Active
```

The project enters Iteration Mode directly.

---

# 4.14 Escalation State

---

## Purpose

Prevent invalid progression.

---

## Escalation Triggers

* repeated validation failure
* repeated reconciliation failure
* unresolved ambiguity
* merge conflict deadlock
* repository reconstruction failure
* invariant conflicts

---

## User Question Being Answered

```text
What must be resolved before progress can continue?
```

---

## Required Visibility

Users must always see:

* root issue
* affected scope
* blocking conditions
* recommended actions

---

## Exit Conditions

Escalation exits only when:

* conflicts resolved
* validation succeeds
* reconciliation succeeds

---

# 4.15 Lifecycle Invariants

---

## LC-I1

Projects always exist in a clearly visible lifecycle state.

---

## LC-I2

Documentation precedes execution.

Except repository ingestion projects.

---

## LC-I3

Execution approval is mandatory before initial execution.

---

## LC-I4

Architectural mutations require approval before re-execution.

---

## LC-I5

Successful execution always creates reconciliation outputs.

---

## LC-I6

Successful reconciliation always creates lineage updates.

---

## LC-I7

Iteration is the default long-term operational state.

---

## LC-I8

Repository ingestion enters Iteration Mode only after validation and confidence resolution.

---

## LC-I9

Escalated projects cannot progress automatically.

---

## LC-I10

Lifecycle visibility is mandatory across all project states.

---

# UI/UX Specification — Section 5

# Core Operational Flows

---

# 5.1 Purpose

Core Operational Flows define how work moves through sembl.

They describe:

* user actions
* system actions
* approval points
* validation points
* reconciliation points
* lifecycle transitions

These flows represent the behavioral architecture of the platform.

They are independent of visual design and implementation.

They define how sembl behaves.

---

# 5.2 Flow Architecture Principles

Every operational flow must obey the following structure:

```text id="n5mz5v"
Trigger
→ Analysis
→ Validation
→ Decision
→ Execution
→ Reconciliation
→ Visibility Update
```

Not all flows contain every stage.

However:

* validation remains mandatory where applicable
* state transitions remain visible
* reconciliation remains visible
* approvals remain explicit

---

# 5.3 Specification Flow

---

## Purpose

Create or modify software specifications.

---

## Primary User Question

```text id="tk8m3z"
What should the software do?
```

---

## Trigger Events

* project creation
* document creation
* document modification
* requirement changes
* architecture changes

---

## Flow

```text id="1qotg0"
Intent
→ Specification Draft
→ Dependency Analysis
→ Validation
→ Review
→ Saved Specification State
```

---

## User Actions

* create specification
* edit specification
* approve suggestions
* reject suggestions
* review dependencies

---

## System Actions

* detect impacts
* identify dependencies
* identify ambiguity
* identify conflicts
* update specification state

---

## Output

Updated specification set.

---

## Exit Conditions

* validation passes
* specification saved

---

# 5.4 Validation Flow

---

## Purpose

Ensure specification and architectural correctness.

Validation is a continuous system process.

---

## Primary User Question

```text id="r2qjv3"
Is the system internally consistent?
```

---

## Trigger Events

* specification changes
* architectural changes
* execution requests
* branch merges
* repository ingestion

---

## Flow

```text id="b7c7zw"
Change Detected
→ Validation Triggered
→ Rule Evaluation
→ Result Generation
→ User Visibility
```

---

## Validation Outcomes

### Passed

```text id="6wrnwx"
Validation
→ Ready
```

---

### Warning

```text id="6s4vwk"
Validation
→ Warning State
→ User Review
```

---

### Failed

```text id="7rjz7n"
Validation
→ Blocked State
→ Resolution Required
```

---

## User Actions

* inspect issue
* navigate to affected artifacts
* resolve issue
* revalidate

---

## System Actions

* identify violations
* classify severity
* identify affected scope
* maintain validation history

---

## Output

Validation result set.

---

# 5.5 Approval Flow

---

## Purpose

Provide governance over consequential actions.

---

## Approval Categories

### Execution Approval

Required before first execution.

---

### Architectural Mutation Approval

Required before major structural changes.

---

### Merge Approval

Required before branch integration.

---

## Flow

```text id="0zv3hx"
Approval Required
→ Impact Summary
→ User Review
→ Decision
→ Outcome
```

---

## User Actions

### Approve

```text id="sccu4x"
Approval
→ Next Workflow
```

---

### Reject

```text id="i8k1i7"
Approval
→ Previous State
```

---

## System Actions

* calculate impact
* summarize changes
* identify risks
* update audit history

---

## Output

Approval decision.

---

# 5.6 Execution Flow

---

## Purpose

Transform semantic state into implementation outputs.

---

## Primary User Question

```text id="jvv7x8"
What is being built right now?
```

---

## Trigger Events

* execution approval
* approved iteration
* approved merge

---

## Flow

```text id="n5lpnh"
Execution Request
→ Context Generation
→ Execution
→ Validation
→ Reconciliation
→ Completion
```

---

## User Actions

* monitor
* inspect progress
* inspect failures

---

## System Actions

* generate context
* perform execution
* validate outputs
* reconcile results

---

## Success Path

```text id="42yl7y"
Execution
→ Reconciliation
→ Deployment
```

---

## Failure Path

```text id="4dphzv"
Execution
→ Escalation
```

---

## Output

Executable implementation state.

---

# 5.7 Reconciliation Flow

---

## Purpose

Integrate execution outcomes into canonical architectural state.

---

## Primary User Question

```text id="fytr2i"
How did the system evolve?
```

---

## Trigger Events

* execution completion
* merge completion
* repository reconstruction

---

## Flow

```text id="3h5mjp"
Execution Output
→ Impact Analysis
→ Graph Update
→ Lineage Update
→ Visibility Update
```

---

## User Actions

* inspect changes
* inspect impacts
* inspect lineage

---

## System Actions

* update graph
* update dependencies
* update lineage
* update versions

---

## Output

Updated canonical state.

---

# 5.8 Iteration Flow

---

## Purpose

Support continuous software evolution.

---

## Primary User Question

```text id="m2e6yn"
How should the software change?
```

---

## Trigger Events

* user requests change
* requirement evolution
* bug resolution
* enhancement request

---

## Flow

```text id="6hh29l"
Change Request
→ Scope Analysis
→ Impact Analysis
→ Validation
→ Approval (if required)
→ Execution
→ Reconciliation
→ Deployment
```

---

## User Actions

* request changes
* review impacts
* approve changes
* review results

---

## System Actions

* determine affected scope
* determine dependency impact
* determine execution scope

---

## Output

Updated software system.

---

# 5.9 Branch Flow

---

## Purpose

Enable isolated evolution.

---

## Primary User Question

```text id="drrqgj"
Can I explore changes safely?
```

---

## Trigger Events

* experimentation
* feature development
* architectural exploration

---

## Flow

```text id="8dz1hl"
Create Branch
→ Isolate State
→ Apply Changes
→ Execute
→ Review
```

---

## User Actions

* create branch
* switch branch
* compare branch
* delete branch

---

## System Actions

* isolate lineage
* isolate mutations
* isolate execution history

---

## Output

Independent evolution path.

---

# 5.10 Merge Flow

---

## Purpose

Integrate approved branch changes.

---

## Primary User Question

```text id="d1vagx"
Can these changes become canonical?
```

---

## Trigger Events

* branch completion
* merge request

---

## Flow

```text id="0y0s0h"
Merge Request
→ Diff Analysis
→ Impact Analysis
→ Validation
→ Approval
→ Reconciliation
→ Canonical Update
```

---

## User Actions

* review diff
* review impact
* approve merge

---

## System Actions

* compare branches
* identify conflicts
* reconcile lineage

---

## Success Path

```text id="ll78yg"
Branch
→ Canonical State
```

---

## Failure Path

```text id="ijm5yr"
Conflict
→ Resolution Workflow
```

---

## Output

Updated canonical branch.

---

# 5.11 Deployment Flow

---

## Purpose

Deliver generated software.

---

## Primary User Question

```text id="sjlwmc"
Is the software available and healthy?
```

---

## Trigger Events

* execution completion
* approved deployment

---

## Flow

```text id="v2e0tl"
Deployment Request
→ Environment Validation
→ Deployment
→ Health Verification
→ Deployment Complete
```

---

## User Actions

* monitor
* inspect deployment
* rollback (if permitted)

---

## System Actions

* deploy artifacts
* verify deployment
* record deployment history

---

## Success Path

```text id="jqutgg"
Deployment
→ Active
```

---

## Failure Path

```text id="6g1frd"
Deployment
→ Failure
→ Rollback
```

or

```text id="0frv3r"
Deployment
→ Escalation
```

---

## Output

Deployed runtime state.

---

# 5.12 Repository Ingestion Flow

---

## Purpose

Convert existing software into canonical semantic state.

---

## Primary User Question

```text id="jly14g"
Did sembl understand my system correctly?
```

---

## Flow

```text id="e4h7tx"
Repository Connection
→ Analysis
→ Reconstruction
→ Confidence Scoring
→ User Review
→ Validation
→ Canonicalization
→ Activation
```

---

## User Actions

* review inferred structures
* resolve ambiguities
* approve reconstruction

---

## System Actions

* reconstruct graph
* infer entities
* infer interfaces
* infer flows
* score confidence

---

## Output

Canonical project state.

---

# 5.13 Escalation Flow

---

## Purpose

Resolve situations where automatic convergence fails.

---

## Primary User Question

```text id="n6g9lj"
What is preventing progress?
```

---

## Trigger Events

* repeated validation failures
* reconciliation failures
* merge deadlocks
* repository reconstruction failures
* invariant violations

---

## Flow

```text id="4vddrw"
Issue Detected
→ Root Cause Analysis
→ Escalation
→ Resolution
→ Revalidation
→ Resume Workflow
```

---

## User Actions

* inspect issue
* resolve issue
* request retry

---

## System Actions

* preserve state
* identify blockers
* generate recommendations

---

## Output

Resolved workflow state.

---

# 5.14 Cross-Flow Visibility Requirements

Every operational flow must expose:

### Current State

```text id="mnr5uv"
Where am I?
```

---

### Next Action

```text id="f1ibpz"
What happens next?
```

---

### Blocking Conditions

```text id="o0r2k0"
What is preventing progress?
```

---

### Scope

```text id="k7xv5g"
What is affected?
```

---

### History

```text id="6o3qmr"
How did we get here?
```

---

# 5.15 Operational Flow Invariants

---

## FLOW-I1

All consequential actions must be visible.

---

## FLOW-I2

Validation must occur before execution-sensitive transitions.

---

## FLOW-I3

Architectural mutations must expose impact before approval.

---

## FLOW-I4

Execution outputs must reconcile into canonical state.

---

## FLOW-I5

Lineage updates must occur after reconciliation.

---

## FLOW-I6

Users must never lose visibility into workflow status.

---

## FLOW-I7

All blocked states must expose actionable resolution paths.

---

## FLOW-I8

Repository ingestion must reach canonical validation before activation.

---

## FLOW-I9

Operational flows must reinforce software evolution rather than software regeneration.

---

## FLOW-I10

Every flow must preserve architectural continuity.

---

# UI/UX Specification — Section 6

# Visibility Architecture

---

# 6.1 Purpose

Visibility Architecture defines how sembl communicates system state to users.

It governs:

* status visibility
* progress visibility
* operational visibility
* audit visibility
* lineage visibility
* notification behavior
* historical visibility

The objective is not merely to inform users.

The objective is to make software evolution understandable.

Users should always be able to answer:

```text
What is happening?

Why is it happening?

What changed?

What requires my attention?

What happens next?
```

without needing to inspect implementation details.

---

# 6.2 Visibility Philosophy

Visibility is a core product capability.

In traditional development systems:

```text
Code → Build → Result
```

Visibility is often fragmented.

In sembl:

```text
Intent
→ Specification
→ Validation
→ Approval
→ Execution
→ Reconciliation
→ Deployment
→ Iteration
```

Every stage must remain observable.

The system should never feel opaque.

Users should never feel:

```text
The AI is doing something.
```

Users should instead feel:

```text
The system is progressing through a visible software evolution process.
```

---

# 6.3 Visibility Layers

Visibility exists across five layers.

```text
Project Visibility
        ↓
Workflow Visibility
        ↓
Change Visibility
        ↓
Architectural Visibility
        ↓
Historical Visibility
```

Each layer serves a distinct purpose.

---

# 6.4 Project Visibility Layer

Project Visibility provides immediate orientation.

It answers:

```text
What is the current state of this project?
```

---

## Visible Elements

Every project must expose:

### Lifecycle State

Examples:

```text
Draft
Ready For Execution
Executing
Reconciling
Deploying
Active
Escalated
```

---

### Current Branch

Examples:

```text
Main
Feature Branch
Experiment Branch
```

---

### Current Version

Latest canonical version.

---

### Execution Status

Examples:

```text
Idle
Queued
Running
Completed
Failed
```

---

### Validation Status

Examples:

```text
Passed
Warning
Failed
```

---

### Approval Status

Examples:

```text
No Approvals Required
Awaiting Approval
Approved
Rejected
```

---

### Deployment Status

Examples:

```text
Not Deployed
Deploying
Healthy
Failed
```

---

## Visibility Rule

Project status must be understandable within seconds of entering the project.

---

# 6.5 Workflow Visibility Layer

Workflow Visibility explains active operational progress.

It answers:

```text
What is currently happening?
```

---

## Visible Workflow States

Examples:

```text
Generating Specifications

Validating Requirements

Awaiting Approval

Executing Build

Reconciling Changes

Deploying System

Analyzing Repository
```

---

## Required Information

Every workflow must expose:

### Current Stage

### Previous Stage

### Next Stage

### Blocking Conditions

### Estimated Completion State

Not necessarily time.

But expected outcome.

---

## Visibility Rule

Users should always understand where they are within a workflow.

---

# 6.6 Change Visibility Layer

Change Visibility explains software evolution.

It answers:

```text
What changed?
```

---

## Visible Change Types

### Specification Changes

Examples:

* requirement added
* requirement removed
* requirement modified

---

### Architectural Changes

Examples:

* entity added
* entity removed
* interface modified
* dependency modified

---

### Behavioral Changes

Examples:

* workflow updated
* validation updated

---

### Deployment Changes

Examples:

* deployment promoted
* deployment rolled back

---

## Required Information

Every change must expose:

### Change Summary

### Impact Scope

### Affected Structures

### Author

### Timestamp

### Lineage Relationship

---

## Visibility Rule

Users should never need to infer what changed.

---

# 6.7 Architectural Visibility Layer

Architectural Visibility supports deeper inspection.

It answers:

```text
How is the system structured?
```

---

## Visible Concepts

### Entities

### Interfaces

### Flows

### Dependencies

### Integrations

### Invariants

### Lineage

---

## Visibility Rule

Architectural information must be available.

Architectural information must not dominate workflows.

---

## Progressive Disclosure

Default:

```text
Requirements
→ Workflows
→ Outcomes
```

Expanded:

```text
Entities
→ Interfaces
→ Dependencies
→ Lineage
```

Advanced:

```text
Graph Relationships
→ Validation Structures
→ Topology
```

---

# 6.8 Historical Visibility Layer

Historical Visibility provides continuity.

It answers:

```text
How did the project reach its current state?
```

---

## Historical Objects

### Executions

### Deployments

### Approvals

### Mutations

### Branches

### Merges

### Reconciliations

### Validations

---

## Historical Capabilities

Users must be able to:

* inspect
* compare
* trace
* review

historical events.

---

## Visibility Rule

Historical state must never be lost.

---

# 6.9 Notification Architecture

Notifications communicate events requiring awareness or action.

Notifications are not the primary status system.

They are attention-routing mechanisms.

---

## Notification Categories

### Informational

Examples:

```text
Execution completed.

Deployment succeeded.

Validation passed.
```

---

### Action Required

Examples:

```text
Approval required.

Validation issue detected.

Merge review required.
```

---

### Warning

Examples:

```text
Execution partially failed.

Repository confidence low.

Dependency impact detected.
```

---

### Critical

Examples:

```text
Deployment failed.

Execution failed.

Invariant violation detected.

Escalation triggered.
```

---

# 6.10 Notification Visibility Rules

---

## NOTIF-I1

Notifications must always include context.

Bad:

```text
Validation failed.
```

Good:

```text
Validation failed for PRD changes affecting User entity.
```

---

## NOTIF-I2

Notifications must support navigation.

Users must be able to reach the affected object directly.

---

## NOTIF-I3

Notifications must never become the primary workflow.

The project remains the primary operational surface.

---

## NOTIF-I4

Critical events remain visible until acknowledged.

---

# 6.11 Activity Timeline Architecture

The Activity Timeline is the operational history surface.

It answers:

```text
What happened recently?
```

---

## Timeline Events

### Specification Events

### Validation Events

### Approval Events

### Execution Events

### Reconciliation Events

### Deployment Events

### Branch Events

### Merge Events

### Escalation Events

---

## Event Structure

Every event must expose:

### Event Type

### Summary

### Actor

### Timestamp

### Affected Scope

### Navigation Link

---

# 6.12 Audit Visibility Architecture

Audit Visibility provides governance-level traceability.

It answers:

```text
Who changed what?
```

---

## Auditable Events

### Specification Mutations

### Architectural Mutations

### Approval Decisions

### Deployments

### Merges

### Branch Creation

### Branch Deletion

### Escalations

---

## Required Audit Information

Every audit record must expose:

### Actor

### Action

### Before State

### After State

### Timestamp

### Reason

if available.

---

# 6.13 Lineage Visibility Architecture

Lineage Visibility is unique to sembl.

It answers:

```text
Why does this structure exist?
```

and

```text
What caused this change?
```

---

## Lineage Relationships

Examples:

```text
Requirement
→ Entity

Entity
→ Interface

Interface
→ Execution

Execution
→ Deployment

Deployment
→ Version
```

---

## Required Lineage Visibility

Users must be able to trace:

### Upstream Sources

### Downstream Effects

### Historical Evolution

### Branch Origins

### Merge Origins

---

## Visibility Rule

Lineage should explain evolution.

Not merely record history.

---

# 6.14 Global Status Model

The entire platform should communicate status using a consistent model.

---

## Healthy

No action required.

---

## Attention Required

User review recommended.

---

## Awaiting Action

User action required.

---

## Blocked

Progress impossible until resolution.

---

## Failed

Operation unsuccessful.

---

## Escalated

Automatic convergence unavailable.

Manual intervention required.

---

# 6.15 Visibility Architecture Invariants

---

## VIS-I1

Users must always understand current project state.

---

## VIS-I2

Users must always understand current workflow state.

---

## VIS-I3

Changes must always expose impact scope.

---

## VIS-I4

Validation outcomes must remain visible until resolved.

---

## VIS-I5

Approval requirements must remain visible until resolved.

---

## VIS-I6

Architectural visibility must support progressive disclosure.

---

## VIS-I7

Historical state must remain inspectable.

---

## VIS-I8

Audit history must be immutable.

---

## VIS-I9

Lineage visibility must connect causes and effects.

---

## VIS-I10

Notifications must provide context and navigability.

---

## VIS-I11

The system must never require users to infer status from absence of information.

Status must always be explicitly communicated.

---

## VIS-I12

Visibility should explain software evolution rather than expose implementation mechanics.

---

# UI/UX Specification — Section 7

# Screen Inventory

---

# 7.1 Purpose

The Screen Inventory defines the complete set of canonical user-facing screens in sembl v1.

This section serves as:

* screen registry
* navigation registry
* generation registry
* Figma generation source
* Stitch generation source
* HTML generation source
* interaction extraction source

No screen should exist outside this inventory without explicit specification updates.

This section defines:

* screen identity
* screen purpose
* ownership domain
* operational mode

Detailed behavior is defined later in Section 8.

---

# 7.2 Screen Classification Model

Screens are organized into six groups.

```text
Workspace
    ↓
Project
    ↓
Operational
    ↓
Governance
    ↓
Technical
    ↓
System
```

This structure mirrors the information architecture.

---

# 7.3 Workspace-Level Screens

These screens operate at workspace scope.

---

## WS-01 — Workspace Home

Purpose:

Primary landing experience.

Users see:

* projects
* active work
* approvals
* recent activity

Primary User:

All users

---

## WS-02 — Project Directory

Purpose:

Browse and manage projects.

Primary User:

All users

---

## WS-03 — Project Creation

Purpose:

Create new projects.

Primary User:

All users

---

## WS-04 — Approval Center

Purpose:

Workspace-wide approval queue.

Primary User:

Approvers

---

## WS-05 — Activity Center

Purpose:

Workspace-wide activity timeline.

Primary User:

All users

---

## WS-06 — Workspace Settings

Purpose:

Workspace administration.

Primary User:

Admins

---

# 7.4 Project-Level Screens

These screens define the primary project experience.

---

## PJ-01 — Project Overview

Purpose:

Project home screen.

Primary User:

All users

---

## PJ-02 — Specifications Workspace

Purpose:

Primary specification management surface.

Primary User:

All users

---

## PJ-03 — Execution Center

Purpose:

Execution monitoring and management.

Primary User:

All users

---

## PJ-04 — Changes Center

Purpose:

Software evolution visibility.

Primary User:

All users

---

## PJ-05 — Branches Center

Purpose:

Branch lifecycle management.

Primary User:

All users

---

## PJ-06 — Deployments Center

Purpose:

Deployment visibility and control.

Primary User:

All users

---

## PJ-07 — Project Activity

Purpose:

Project-specific operational history.

Primary User:

All users

---

## PJ-08 — Graph Explorer

Purpose:

Architectural inspection.

Primary User:

Technical users

---

# 7.5 Specification Screens

These screens exist inside the Specifications Workspace.

---

## SPEC-01 — Specification Dashboard

Purpose:

Specification overview and health.

---

## SPEC-02 — Document Editor

Purpose:

Document editing and review.

Supports:

* PDD
* PRD
* NFR
* UI/UX
* Architecture Docs

---

## SPEC-03 — Specification Validation Center

Purpose:

Specification validation visibility.

---

## SPEC-04 — Dependency Explorer

Purpose:

Specification relationships.

---

## SPEC-05 — Assumption Review Center

Purpose:

Review inferred assumptions and ambiguities.

---

## SPEC-06 — Specification History

Purpose:

Document evolution visibility.

---

# 7.6 Repository Ingestion Screens

---

## REPO-01 — Repository Connection

Purpose:

Connect repository source.

---

## REPO-02 — Repository Analysis

Purpose:

Display ingestion progress.

---

## REPO-03 — Reconstruction Review

Purpose:

Review inferred structures.

---

## REPO-04 — Confidence Resolution Center

Purpose:

Resolve low-confidence interpretations.

---

## REPO-05 — Repository Validation

Purpose:

Validate reconstructed architecture.

---

## REPO-06 — Activation Review

Purpose:

Approve transition into active project state.

---

# 7.7 Execution Screens

---

## EXEC-01 — Execution Dashboard

Purpose:

Primary execution monitoring.

---

## EXEC-02 — Execution Details

Purpose:

Detailed execution visibility.

---

## EXEC-03 — Validation Review

Purpose:

Execution validation outcomes.

---

## EXEC-04 — Reconciliation Review

Purpose:

Execution reconciliation visibility.

---

## EXEC-05 — Execution History

Purpose:

Historical execution review.

---

# 7.8 Change and Iteration Screens

---

## CHANGE-01 — Change Request Center

Purpose:

Create and manage changes.

---

## CHANGE-02 — Scope Analysis Review

Purpose:

Impact and scope visibility.

---

## CHANGE-03 — Change Diff Viewer

Purpose:

Review proposed changes.

---

## CHANGE-04 — Version History

Purpose:

Historical software evolution.

---

## CHANGE-05 — Lineage Explorer

Purpose:

Change causality visibility.

---

# 7.9 Branching Screens

---

## BRANCH-01 — Branch Dashboard

Purpose:

Branch management home.

---

## BRANCH-02 — Branch Creation

Purpose:

Create branch.

---

## BRANCH-03 — Branch Comparison

Purpose:

Compare branch states.

---

## BRANCH-04 — Merge Review

Purpose:

Review merge candidate.

---

## BRANCH-05 — Conflict Resolution

Purpose:

Resolve merge conflicts.

---

# 7.10 Approval Screens

---

## APPROVAL-01 — Approval Review

Purpose:

Review approval request.

---

## APPROVAL-02 — Architectural Impact Review

Purpose:

Review architectural mutations.

---

## APPROVAL-03 — Execution Approval Review

Purpose:

Review execution readiness.

---

## APPROVAL-04 — Merge Approval Review

Purpose:

Review merge impact.

---

# 7.11 Deployment Screens

---

## DEPLOY-01 — Deployment Dashboard

Purpose:

Deployment management home.

---

## DEPLOY-02 — Deployment Details

Purpose:

Deployment visibility.

---

## DEPLOY-03 — Environment Review

Purpose:

Deployment environment inspection.

---

## DEPLOY-04 — Rollback Review

Purpose:

Rollback management.

---

## DEPLOY-05 — Deployment History

Purpose:

Deployment audit trail.

---

# 7.12 Technical Inspection Screens

These remain secondary and progressively disclosed.

---

## TECH-01 — Entity Explorer

Purpose:

Inspect entities.

---

## TECH-02 — Interface Explorer

Purpose:

Inspect interfaces.

---

## TECH-03 — Flow Explorer

Purpose:

Inspect flows.

---

## TECH-04 — Dependency Explorer

Purpose:

Inspect dependencies.

---

## TECH-05 — Lineage Explorer

Purpose:

Inspect architectural evolution.

---

## TECH-06 — Validation Explorer

Purpose:

Inspect validation structures.

---

# 7.13 Visibility Screens

---

## VIS-01 — Notification Center

Purpose:

Central notification management.

---

## VIS-02 — Activity Timeline

Purpose:

Unified activity visibility.

---

## VIS-03 — Audit Explorer

Purpose:

Governance and traceability.

---

## VIS-04 — Status Center

Purpose:

Cross-project operational status.

---

# 7.14 System and Exception Screens

---

## SYS-01 — Escalation Center

Purpose:

Resolve blocked workflows.

---

## SYS-02 — Error Resolution Center

Purpose:

Investigate failures.

---

## SYS-03 — Access Management

Purpose:

Permission visibility.

---

## SYS-04 — Integration Management

Purpose:

External system integrations.

---

# 7.15 Screen Inventory Summary

Total canonical screen groups:

```text
Workspace Screens
Project Screens
Specification Screens
Repository Screens
Execution Screens
Change Screens
Branch Screens
Approval Screens
Deployment Screens
Technical Screens
Visibility Screens
System Screens
```

Total canonical screen count:

```text
Workspace:      6
Project:        8
Specification:  6
Repository:     6
Execution:      5
Changes:        5
Branches:       5
Approvals:      4
Deployments:    5
Technical:      6
Visibility:     4
System:         4
------------------
Total:         64
```

---

# 7.16 Screen Inventory Constraints

---

## SCREEN-I1

Every user-visible workflow must map to at least one canonical screen.

---

## SCREEN-I2

Every screen must belong to exactly one primary domain.

---

## SCREEN-I3

Project-centric workflows take precedence over technical inspection workflows.

---

## SCREEN-I4

Technical inspection screens remain secondary and progressively disclosed.

---

## SCREEN-I5

Specification authoring screens remain primary throughout the product.

---

## SCREEN-I6

No screen may expose raw graph complexity as its primary purpose.

---

## SCREEN-I7

All screens must support lineage-aware navigation where applicable.

---

## SCREEN-I8

Every screen must expose a clear relationship to project state.

---

# 7.17 Screen Architecture Governance

This section defines how the Screen Inventory shall be interpreted and implemented.

The Screen Inventory is a capability registry.

It is not a direct representation of the final application surface structure.

The purpose of this section is to establish authoritative interpretation rules for screen generation, interface generation, Figma generation, Stitch generation, HTML generation, and future implementation activities.

---

## SCREEN-G1 — Capability Coverage Authority

The Screen Inventory is the authoritative registry of user-visible capabilities.

Every workflow, responsibility, interaction, review surface, approval flow, validation flow, reconciliation flow, and visibility requirement defined by the platform must map to at least one inventory item.

The Screen Inventory exists to ensure capability completeness.

No capability may be implemented outside the inventory without explicit specification updates.

---

## SCREEN-G2 — Implementation Authority

The Detailed Screen Specifications defined in Section 8 are the authoritative implementation model.

Inventory items may be implemented as:

* primary screens
* subpages
* tabs
* panels
* drawers
* inspectors
* modals

provided capability coverage is preserved.

The Detailed Screen Specifications determine the actual application structure.

---

## SCREEN-G3 — Generation Authority

Generation systems shall interpret:

* Section 7 as the capability registry
* Section 8 as the implementation architecture
* Secondary Interaction Surfaces as interaction placement rules

When ambiguity exists, Section 8 takes precedence over Section 7 for interface generation.

---

## SCREEN-G4 — Surface Consolidation Principle

Capabilities should be implemented using the smallest viable interaction surface.

Preferred hierarchy:

```text
Primary Screen
    ↓
Subpage
    ↓
Tab
    ↓
Panel
    ↓
Drawer
    ↓
Inspector
    ↓
Modal
````

Capabilities must not automatically become standalone screens.

The existence of a capability does not imply the existence of a primary navigation destination.

---

## SCREEN-G5 — Capability Normalization Principle

The Screen Inventory defines everything the system must support.

The Detailed Screen Specifications define how those capabilities are surfaced.

Multiple inventory items may be implemented within a single workspace when:

* workflow clarity is preserved
* discoverability is preserved
* visibility requirements are preserved

Capability consolidation is preferred over navigation expansion.

---

## SCREEN-G6 — Internal Systems Visibility Principle

Internal platform systems are explanatory constructs rather than primary user workflows.

The following concepts should rarely become primary navigation destinations:

* validation
* reconciliation
* lineage
* dependencies
* graph topology
* execution topology

These concepts should generally appear as:

* contextual tabs
* inspectors
* review surfaces
* impact panels
* supporting workflows

attached to user goals and operational workflows.

---

## SCREEN-G7 — One Question Per Primary Screen Principle

Every primary screen must answer one dominant user question.

Examples:

Project Overview

> What is happening in this project?

Specifications Workspace

> What are we building?

Execution Workspace

> What is being built right now?

Changes Workspace

> How is the software evolving?

Deployments Workspace

> What is currently running?

If a screen answers multiple unrelated questions it should be decomposed.

If multiple screens answer the same question they should be consolidated.

---

## SCREEN-G8 — Navigation Compression Principle

The preferred implementation structure for sembl v1 is:

```text
Workspace
    ↓
Project
        ↓
Overview
Specifications
Execution
Changes
Deployments
```

with:

* branches
* validation
* reconciliation
* lineage
* graph inspection
* dependency analysis

appearing contextually where required.

The system should minimize navigation depth while maximizing contextual visibility.

---

## SCREEN-G9 — Specification Primacy Preservation

The screen architecture must preserve the core user experience of sembl:

```text
Intent
    ↓
Specifications
    ↓
Validation
    ↓
Approval
    ↓
Execution
    ↓
Deployment
    ↓
Iteration
```

Users should experience software evolving through specifications.

Users should not experience the platform as:

* a graph database interface
* an orchestration dashboard
* an agent management system
* a task execution system

Screen architecture decisions must always reinforce specification primacy over implementation visibility.

---

## SCREEN-G10 — Final Architectural Invariant

The final interface architecture of sembl shall optimize for:

* specification-centric workflows
* progressive complexity disclosure
* architectural continuity
* reconciliation visibility
* lineage visibility
* execution transparency
* minimal navigation complexity

The product must feel like:

"building software through evolving specifications"

and never like:

"managing the machinery that builds software."

---

# UI/UX Specification — Section 8

# Detailed Screen Specifications

---

# 8.1 Purpose

This section transforms the capability inventory into a coherent product architecture.

The objective is not to specify every possible page.

The objective is to define the minimum set of primary interaction surfaces required to support all workflows defined in previous sections.

This section becomes the primary source for:

* Figma generation
* Stitch generation
* HTML generation
* interaction modeling
* screen implementation

---

# 8.2 Canonical Screen Hierarchy

After normalization, sembl v1 consists of:

## Workspace Screens

```text
WS-01 Workspace Home
WS-02 Approval Center
WS-03 Activity Center
WS-04 Workspace Settings
```

---

## Project Screens

```text
PJ-01 Project Overview
PJ-02 Specifications Workspace
PJ-03 Execution Workspace
PJ-04 Changes Workspace
PJ-05 Deployments Workspace
```

---

## Workflow Screens

```text
WF-01 Repository Ingestion
WF-02 Approval Review
WF-03 Conflict Resolution
WF-04 Escalation Center
```

---

Total Primary Screens:

```text
13
```

Everything else becomes:

* tabs
* panels
* drawers
* inspectors
* review surfaces

inside these primary workspaces.

The 64 inventory entries remain authoritative for capability coverage.

The 13-screen hierarchy remains authoritative for implementation, navigation, and interaction architecture.

---

# 8.3 WS-01 — Workspace Home

---

## Purpose

Answer:

```text
What requires attention across my workspace?
```

---

## Entry Points

* Login
* Workspace selection
* Navigation

---

## Visible Information

### Projects

* active projects
* recent projects
* project status

### Pending Approvals

### Recent Activity

### Active Executions

### Deployment Alerts

---

## Available Actions

* open project
* create project
* review approval
* inspect activity

---

## Navigation Destinations

```text
Project Overview
Approval Center
Activity Center
Settings
```

---

## State Transitions

```text
Project Selected
→ Project Overview

Approval Selected
→ Approval Review
```

---

# 8.4 WS-02 — Approval Center

---

## Purpose

Answer:

```text
What decisions require my approval?
```

---

## Visible Information

Grouped by:

### Execution Approvals

### Architectural Approvals

### Merge Approvals

---

## Available Actions

* review
* approve
* reject

---

## Supporting Surfaces

### Impact Panel

### Diff Viewer

### Lineage Panel

---

## Navigation

```text
Approval Review
Project Overview
```

---

# 8.5 WS-03 — Activity Center

---

## Purpose

Answer:

```text
What has happened recently?
```

---

## Visible Information

Unified timeline:

* executions
* deployments
* approvals
* changes
* merges
* escalations

---

## Available Actions

* inspect event
* navigate to project
* filter activity

---

# 8.6 PJ-01 — Project Overview

---

## Purpose

Answer:

```text
What is happening in this project?
```

This is the project home.

---

## Entry Points

* Workspace Home
* Project Directory
* Notifications

---

## Visible Information

### Project State

* lifecycle state
* branch
* version

### Specification Health

### Active Work

### Pending Approvals

### Recent Changes

### Deployment Status

### Validation Summary

---

## Available Actions

* continue work
* review changes
* start execution
* review approvals

---

## Embedded Surfaces

### Status Panel

### Validation Summary Panel

### Recent Activity Panel

### Deployment Summary Panel

---

## Navigation Destinations

```text
Specifications
Execution
Changes
Deployments
```

---

# 8.7 PJ-02 — Specifications Workspace

---

## Purpose

Answer:

```text
What are we building?
```

This is the primary authoring environment of sembl.

---

## Visible Information

### Specification Tree

Contains:

* PDD
* PRD
* NFR
* UI/UX
* Architecture
* API
* DB Schema

### Active Document

### Dependency Indicators

### Validation Indicators

### Assumption Indicators

---

## Primary Actions

* create
* edit
* review
* compare
* approve changes

---

## Embedded Tabs

### Documents

### Validation

### Dependencies

### Assumptions

### History

---

## Supporting Drawers

### Dependency Inspector

### Impact Inspector

### Lineage Inspector

---

## Navigation Destinations

```text
Execution
Changes
Overview
```

---

# 8.8 PJ-03 — Execution Workspace

---

## Purpose

Answer:

```text
What is being built right now?
```

---

## Visible Information

### Current Execution

### Progress

### Validation Status

### Reconciliation Status

### Deployment Status

### Execution History

---

## Primary Actions

* inspect progress
* inspect issues
* retry failed execution

Retry is permitted only when:

- execution is not in Escalated state
- retry limits have not been exhausted
- the failure condition is recoverable

Repeated unsuccessful retries must transition the execution into Escalated state.

Retry behavior must remain bounded and must not bypass escalation requirements.

---

## Embedded Tabs

### Progress

### Validation

### Reconciliation

### History

---

## Supporting Panels

### Execution Details

### Impact Summary

### Failure Analysis

---

## Navigation Destinations

```text
Changes
Deployments
Overview
```

---

# 8.9 PJ-04 — Changes Workspace

---

## Purpose

Answer:

```text
How is the software evolving?
```

This becomes the heart of Iteration Mode.

---

## Visible Information

### Requested Changes

### Active Branches

### Diffs

### Version History

### Lineage

### Merge Candidates

---

## Primary Actions

* create change
* create branch
* compare versions
* request merge

---

## Embedded Tabs

### Changes

### Branches

### Versions

### Lineage

---

## Supporting Panels

### Scope Analysis

### Impact Analysis

### Diff Viewer

### Merge Review

---

## Navigation Destinations

```text
Specifications
Execution
Deployments
```

---

# 8.10 PJ-05 — Deployments Workspace

---

## Purpose

Answer:

```text
What is currently running?
```

---

## Visible Information

### Active Deployments

### Deployment History

### Environment Status

### Rollbacks

---

## Primary Actions

* inspect deployment
* review history
* initiate rollback (if permitted)

---

## Embedded Tabs

### Active

### History

### Environments

### Rollbacks

---

## Supporting Panels

### Deployment Details

### Health Status

### Failure Analysis

---

## Navigation Destinations

```text
Overview
Execution
Changes
```

---

# 8.11 Workflow Screens

These are temporary workflow-specific surfaces.

They are not persistent project destinations.

---

## WF-01 Repository Ingestion

Answers:

```text
Did sembl understand my system correctly?
```

Stages:

```text
Connect
→ Analyze
→ Reconstruct
→ Review
→ Validate
→ Activate
```

---

## WF-02 Approval Review

Answers:

```text
Should this action proceed?
```

Contains:

* impact summary
* diff summary
* affected scope
* lineage impact

---

## WF-03 Conflict Resolution

Answers:

```text
How should competing changes be reconciled?
```

Contains:

* conflicting structures
* impact analysis
* resolution choices

---

## WF-04 Escalation Center

Answers:

```text
What is preventing progress?
```

Contains:

* root cause
* blocked workflows
* resolution actions

---

# UI/UX Specification — Section 8 (Part 2)

# Secondary Interaction Surfaces

---

# 8.12 Purpose

Primary screens answer major user questions.

Secondary interaction surfaces provide depth without increasing navigation complexity.

Their purpose is to expose:

* validation
* reconciliation
* lineage
* dependencies
* architectural visibility
* graph visibility
* impact analysis

without creating additional primary destinations.

This section defines how advanced functionality is integrated into the product.

---

# 8.13 Secondary Surface Hierarchy

All non-primary interactions should use the following hierarchy.

```text id="nsmn1i"
Primary Screen
    ↓
Tab
    ↓
Panel
    ↓
Drawer
    ↓
Modal
```

The lower the level:

* the more contextual the information
* the less persistent the interaction

---

# 8.14 Tabs

Tabs represent closely related views within the same user question.

Tabs should never represent separate workflows.

---

## Tab Principles

Good:

```text id="g6c9tx"
Execution
    ├ Progress
    ├ Validation
    ├ Reconciliation
    └ History
```

Bad:

```text id="w8lx2g"
Execution
Validation
Reconciliation
History
```

as separate navigation destinations.

---

## Global Tab Rules

Tabs should:

* answer the same question
* share context
* preserve state
* avoid navigation resets

---

# 8.15 Panels

Panels expose supporting information while preserving workflow continuity.

Panels should remain visible alongside primary content.

---

## Panel Use Cases

### Status Panel

Displays:

* lifecycle state
* execution state
* deployment state

---

### Validation Summary Panel

Displays:

* validation status
* issue counts
* severity breakdown

---

### Activity Panel

Displays:

* recent events
* approvals
* deployments

---

### Dependency Summary Panel

Displays:

* impacted structures
* upstream dependencies
* downstream dependencies

---

## Panel Rule

Panels summarize.

Panels do not become workspaces.

---

# 8.16 Drawers

Drawers expose detailed contextual information without navigation.

Drawers should be used heavily throughout sembl.

They preserve continuity while allowing deep inspection.

---

## Dependency Inspector Drawer

Purpose:

Inspect dependency relationships.

---

### Visible Information

* upstream dependencies
* downstream dependencies
* affected scope

---

### Entry Points

* specifications
* changes
* validation issues

---

# Architectural Impact Drawer

Purpose:

Inspect architectural consequences.

---

### Visible Information

* affected entities
* affected interfaces
* affected flows
* dependency impact

---

### Entry Points

* approvals
* changes
* validation

---

# Lineage Drawer

Purpose:

Explain causality.

---

### Visible Information

```text id="3dbpzs"
Why does this exist?

What created it?

What changed it?

What depends on it?
```

---

### Entry Points

Available from:

* entities
* interfaces
* changes
* approvals

---

# Validation Drawer

Purpose:

Inspect validation outcomes.

---

### Visible Information

* violation
* severity
* affected scope
* remediation path

---

### Entry Points

Anywhere validation appears.

---

# Reconciliation Drawer

Purpose:

Explain canonical updates.

---

### Visible Information

* changes applied
* graph updates
* lineage updates
* affected structures

---

### Entry Points

Execution
Changes
Merge Review

---

# 8.17 Inspectors

Inspectors provide deep technical visibility.

They remain optional.

Most users should rarely need them.

---

## Entity Inspector

Displays:

* fields
* relationships
* lineage
* dependencies

---

## Interface Inspector

Displays:

* inputs
* outputs
* contracts
* integrations

---

## Flow Inspector

Displays:

* participating structures
* execution relationships
* dependencies

---

## Dependency Inspector

Displays:

* dependency graph
* dependency impact

---

## Validation Inspector

Displays:

* rule evaluation
* violation history
* affected structures

---

## Lineage Inspector

Displays:

* evolution history
* mutation chain
* reconciliation chain

---

# Inspector Rule

Inspectors explain architecture.

They do not become architecture editing tools.

---

# 8.18 Graph Visibility Architecture

Graph visibility is one of the most important UX decisions in sembl.

The graph is canonical.

The graph is not primary.

---

## Default User Experience

Users interact with:

* requirements
* specifications
* workflows
* changes

Graph structures remain hidden.

---

## Intermediate Visibility

Users may inspect:

* entities
* interfaces
* flows

through contextual inspection.

---

## Advanced Visibility

Technical users may access Graph Explorer.

Graph Explorer should expose:

### Entity Relationships

### Interface Relationships

### Flow Relationships

### Lineage Relationships

### Dependency Relationships

---

## Graph Editing Rule

Graph Explorer is primarily read-oriented.

Graph mutation continues through:

* specification evolution
* approved change workflows
* repository reconstruction workflows

Graph visibility exists to explain:

* structure
* lineage
* dependencies
* evolution

Graph visibility must remain accessible for architectural inspection without becoming either:

* the primary authoring experience
* a hidden implementation detail

---

# 8.19 Review Surfaces

Review Surfaces support decision making.

They appear before consequential actions.

---

## Execution Review

Appears before initial execution.

Contains:

* specification summary
* validation summary
* assumptions
* execution targets

---

## Architectural Mutation Review

Appears before architectural changes.

Contains:

* affected structures
* dependency impact
* lineage impact
* execution impact

---

## Merge Review

Appears before merge approval.

Contains:

* branch diff
* architectural diff
* validation status
* reconciliation summary

---

## Repository Activation Review

Appears before repository activation.

Contains:

* confidence summary
* unresolved ambiguities
* inferred architecture

---

# 8.20 Modals

Modals should be reserved for short-lived actions.

Not workflows.

---

## Appropriate Modal Use

### Create Branch

### Delete Branch

### Confirm Rollback

### Confirm Approval

### Resolve Minor Conflict

---

## Inappropriate Modal Use

### Specification Editing

### Execution Monitoring

### Validation Review

### Reconciliation Review

### Graph Inspection

These require larger surfaces.

---

# 8.21 Universal Context Bar

Every primary project screen should expose a shared context bar.

This becomes a core product element.

---

## Visible Information

### Project

### Branch

### Version

### Lifecycle State

### Validation State

### Deployment State

### Approval State

---

## Purpose

Allow users to immediately answer:

```text id="5cxikn"
Where am I?

What state is the project in?

Is anything blocked?
```

without navigation.

---

# 8.22 Universal Impact Pattern

Impact visibility should be standardized.

Whenever a user encounters:

* changes
* approvals
* merges
* validation failures
* reconciliation

the system should expose impact using the same structure.

---

## Impact Structure

### Summary

What changed?

---

### Scope

What is affected?

---

### Architectural Impact

What structures change?

---

### Operational Impact

What workflows change?

---

### Deployment Impact

What runtime behavior changes?

---

### Lineage Impact

What evolution path changes?

---

# 8.23 Universal Traceability Pattern

Every major object should support tracing.

Supported objects:

* requirements
* entities
* interfaces
* flows
* executions
* deployments

---

## Trace Directions

### Upstream

```text id="fhg7ee"
What caused this?
```

---

### Downstream

```text id="5k1pqa"
What depends on this?
```

---

### Historical

```text id="ztlf5o"
How did this evolve?
```

---

This becomes the foundation of lineage visibility.

---

# 8.24 Secondary Surface Invariants

---

## SURF-I1

Capabilities should be embedded whenever possible.

---

## SURF-I2

Technical visibility should be contextual.

---

## SURF-I3

Validation should primarily appear within workflows rather than as a separate destination.

---

## SURF-I4

Reconciliation should primarily appear within workflows rather than as a separate destination.

---

## SURF-I5

Graph visibility should be inspection-oriented.

---

## SURF-I6

Lineage should be accessible from any major object.

---

## SURF-I7

Impact visibility should use a consistent structure across the platform.

---

## SURF-I8

Users should not navigate away from workflows merely to understand supporting information.

---

## SURF-I9

Inspectors explain architecture.

Specifications modify architecture.

---

## SURF-I10

The system should minimize navigation depth while maximizing information availability.

---

# UI/UX Specification — Section 9

# State Architecture

---

# 9.1 Purpose

State Architecture defines how sembl represents, communicates, and transitions between states.

This section governs:

* lifecycle states
* workflow states
* screen states
* object states
* loading states
* empty states
* blocked states
* failure states
* recovery states

The purpose of State Architecture is not merely operational correctness.

Its purpose is to create continuous user trust.

Users should never need to guess:

```text id="z0pk3m"
What is happening?

What state am I in?

What happens next?

Can I safely proceed?
```

State should always be explicit.

---

# 9.2 State Philosophy

State is a first-class product concept.

In sembl:

* software evolves through state
* specifications evolve through state
* execution progresses through state
* architecture evolves through state

The platform should communicate state continuously.

Absence of state visibility is considered a UX failure.

---

# 9.3 State Hierarchy

States exist at five levels.

```text id="e3d9yk"
Workspace State
        ↓
Project State
        ↓
Workflow State
        ↓
Object State
        ↓
UI State
```

Each layer inherits context from the layer above.

---

# 9.4 Global State Categories

All states should belong to one of six canonical categories.

---

## Healthy

Meaning:

No action required.

Progress may continue normally.

Examples:

```text id="sm2s9m"
Active

Validated

Deployed

Merged
```

---

## Informational

Meaning:

State change occurred.

Awareness useful.

Action not required.

Examples:

```text id="zh0l2u"
Execution Completed

Deployment Completed

Branch Created
```

---

## Attention Required

Meaning:

Review recommended.

Progress still possible.

Examples:

```text id="hf3hkn"
Validation Warning

Low Repository Confidence

Dependency Change Detected
```

---

## Awaiting Action

Meaning:

User action required.

Progress paused until action occurs.

Examples:

```text id="ld72y7"
Awaiting Approval

Awaiting Review

Awaiting Merge Decision
```

---

## Blocked

Meaning:

Progress impossible.

Resolution required.

Examples:

```text id="h11czm"
Validation Failed

Merge Conflict

Dependency Conflict
```

---

## Escalated

Meaning:

Automatic convergence unavailable.

Manual intervention required.

Examples:

```text id="wr7pl8"
Repeated Validation Failure

Reconciliation Failure

Invariant Conflict
```

---

# 9.5 Project Lifecycle States

Project state is the highest visibility state in the system.

Every project must have exactly one active lifecycle state.

---

## Draft

Meaning:

Project definition in progress.

Allowed Actions:

* edit specifications
* validate

Blocked Actions:

* execute
* deploy

---

## Ready For Execution

Meaning:

Specifications complete.

Allowed Actions:

* review
* approve execution

Blocked Actions:

* deploy

---

## Awaiting Approval

Meaning:

Execution or mutation approval required.

Allowed Actions:

* review
* approve
* reject

Blocked Actions:

* execution
* merge
* deployment

depending on approval type.

---

## Executing

Meaning:

Implementation generation active.

Allowed Actions:

* monitor
* inspect

Blocked Actions:

* conflicting mutations

---

## Reconciling

Meaning:

Canonical state update active.

Allowed Actions:

* inspect

Blocked Actions:

* conflicting mutations
* deployment

---

## Deploying

Meaning:

Deployment workflow active.

Allowed Actions:

* monitor

Blocked Actions:

* deployment mutation

---

## Active

Meaning:

Normal operating state.

Allowed Actions:

* iterate
* deploy
* branch
* review

---

## Escalated

Meaning:

Manual intervention required.

Allowed Actions:

* resolve
* retry

Blocked Actions:

* automatic progression

---

# 9.6 Workflow States

Every operational workflow has a state model.

---

## Not Started

Workflow not initiated.

---

## In Progress

Workflow actively executing.

---

## Waiting

Workflow paused pending dependency.

---

## Awaiting User Action

Workflow blocked on user input.

---

## Completed

Workflow successfully completed.

---

## Failed

Workflow unsuccessful.

---

## Escalated

Workflow requires intervention.

---

# 9.7 Validation States

Validation is one of the most visible systems in sembl.

---

## Passed

Meaning:

No violations.

---

## Passed With Warnings

Meaning:

Violations not execution-blocking.

---

## Failed

Meaning:

Blocking violations exist.

---

## Under Review

Meaning:

User reviewing validation outcomes.

---

## Revalidating

Meaning:

Validation rerunning after modifications.

---

# Validation Transition Model

Passed
   │
   └──────────────┐
                  ↓
           Revalidating
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
     Passed   Passed With   Failed
               Warnings

---

# 9.8 Approval States

Applies to:

* execution approval
* mutation approval
* merge approval

---

## Pending

Approval required.

---

## Under Review

Reviewer evaluating.

---

## Approved

Approved for progression.

---

## Rejected

Progress denied.

---

# Approval Transition Model

```text id="azs6qj"
Pending
     ↓
Under Review
     ↓
Approved
```

or

```text id="vth79f"
Pending
     ↓
Under Review
     ↓
Rejected
```

---

# 9.9 Execution States

---

## Queued

Execution scheduled.

---

## Preparing

Context generation active.

---

## Running

Execution active.

---

## Validating

Output validation active.

---

## Reconciling

Canonical update active.

---

## Completed

Execution successful.

---

## Failed

Execution unsuccessful.

---

## Escalated

Manual intervention required.

---

# Execution Transition Model

```text id="pmwmq8"
Queued
→ Preparing
→ Running
→ Validating
→ Reconciling
→ Completed
```

---

# 9.10 Deployment States

---

## Not Deployed

No deployment exists.

---

## Deploying

Deployment active.

---

## Healthy

Deployment successful.

---

## Degraded

Persistent degradation or repeated degradation events may trigger escalation.
Deployment functional but impaired.

---

## Failed

Deployment unsuccessful.

---

## Rolling Back

Rollback active.

---

## Rolled Back

Rollback completed.

---

# 9.11 Branch States

---

## Active

Branch available.

---

## Diverged

Significant differences exist.

---

## Merge Pending

Ready for merge review.

---

## Merged

Integrated into canonical state.

---

## Rejected

Merge denied.

---

## Archived

Historical branch.

---

# 9.12 Repository Ingestion States

---

## Connected

Repository linked.

---

## Analyzing

Analysis active.

---

## Reconstructing

Semantic reconstruction active.

---

## Confidence Review Required

Low-confidence structures detected.

---

## Validating

Validation active.

---

## Ready For Activation

Review complete.

---

## Activated

Project active.

---

## Failed

Ingestion unsuccessful.

---

# 9.13 Empty States

Empty states should guide users toward progress.

Empty states are instructional surfaces.

---

# Empty State Principles

Every empty state should answer:

```text id="sfpvaw"
Why is this empty?

What can I do next?
```

---

## No Projects

Display:

* explanation
* create project action

---

## No Specifications

Display:

* specification creation entry point

---

## No Executions

Display:

* execution readiness guidance

---

## No Deployments

Display:

* deployment lifecycle explanation

---

## No Branches

Display:

* branching explanation
* create branch action

---

## No Activity

Display:

* activity visibility explanation

---

# Empty State Rule

Empty states should educate.

Never simply display absence.

---

# 9.14 Loading States

Loading states communicate progress.

They should reflect actual system activity.

---

## Lightweight Loading

Examples:

* page loading
* navigation

Display:

* immediate progress indicator

---

## Workflow Loading

Examples:

* validation
* repository analysis
* reconciliation

Display:

* current stage
* expected outcome

---

## Long Running Loading

Examples:

* execution
* deployment
* repository reconstruction

Display:

### Current Stage

### Previous Stage

### Next Stage

### Scope

### Progress Summary

---

# Loading Rule

Long-running operations must never appear opaque.

---

# 9.15 Failure States

Failure states must explain:

```text id="aevv7w"
What failed?

Why did it fail?

What can be done?
```

---

# Failure Structure

Every failure should expose:

### Summary

### Root Cause

### Impact

### Resolution Path

### Retry Option

if available.

---

# Common Failure States

### Validation Failure

### Execution Failure

### Deployment Failure

### Merge Failure

### Repository Failure

### Reconciliation Failure

### Permission Failure

---

# Failure Rule

Failure visibility is mandatory.

Generic error messages are prohibited.

---

# 9.16 Blocked States

Blocked states differ from failures.

A blocked state is awaiting resolution.

---

# Examples

### Awaiting Approval

### Merge Conflict

### Missing Information

### Unresolved Ambiguity

### Dependency Conflict

---

# Required Visibility

### Blocking Cause

### Responsible Party

### Resolution Action

### Affected Scope

---

# 9.17 Recovery States

Recovery states communicate restoration.

---

## Retrying

Operation rerunning.

---

## Recovering

System correcting failure.

---

## Revalidating

Validation re-executing.

---

## Rebuilding

Execution restarting.

---

## Rolling Back

Deployment reverting.

---

# Recovery Rule

Recovery should be visible.

Users should never wonder whether remediation is occurring.

---

# 9.18 State Visibility Rules

---

## STATE-I1

Every major object must expose current state.

---

## STATE-I2

Every workflow must expose next state.

---

## STATE-I3

Blocked states must expose resolution paths.

---

## STATE-I4

Failure states must expose root causes.

---

## STATE-I5

Long-running states must expose progress.

---

## STATE-I6

State transitions must be visible.

---

## STATE-I7

Users must never infer state through absence of information.

---

## STATE-I8

Recovery states must be visible.

---

## STATE-I9

Project lifecycle state remains the dominant state indicator.

---

## STATE-I10

State communication should prioritize clarity over implementation detail.

---

# 9.19 State Architecture Invariants

---

## SA-I1

Every project always has a visible lifecycle state.

---

## SA-I2

Every workflow always has a visible operational state.

---

## SA-I3

Every consequential action produces observable state transitions.

---

## SA-I4

Validation, approval, execution, reconciliation, and deployment states remain independently visible.

---

## SA-I5

Blocked progression must always be explainable.

---

## SA-I6

Failure states must be actionable.

---

## SA-I7

Recovery processes must be observable.

---

## SA-I8

State architecture must reinforce user trust through transparency.

---

# UI/UX Specification — Section 10

# Responsive and Accessibility Requirements

---

# 10.1 Purpose

This section defines the responsiveness and accessibility requirements for sembl v1.

The objective is not compliance.

The objective is ensuring that:

* core workflows remain usable
* state visibility remains preserved
* approvals remain actionable
* software evolution remains understandable

across devices and interaction methods.

All requirements in this section must preserve the interaction architecture defined throughout the specification.

---

# 10.2 Guiding Principle

Responsiveness and accessibility must adapt the interface.

They must not alter the mental model.

A user should experience the same project structure regardless of device.

The following concepts must remain consistent:

```text id="m7nbc4"
Workspace
→ Project
→ Specifications
→ Execution
→ Changes
→ Deployments
```

Only the presentation changes.

The architecture does not.

---

# 10.3 Device Strategy

sembl v1 is desktop-first.

This decision reflects the primary user activities:

* specification authoring
* architecture review
* change analysis
* repository ingestion
* approval review

These activities benefit significantly from large-screen environments.

---

# 10.4 Desktop Experience

Desktop is the canonical experience.

All workflows must be fully supported.

---

## Supported Activities

### Specification Authoring

### Validation Review

### Repository Ingestion

### Change Analysis

### Branch Management

### Merge Review

### Execution Monitoring

### Deployment Management

### Graph Inspection

### Lineage Inspection

---

## Desktop Layout Principle

Desktop should maximize simultaneous context visibility.

Users should be able to view:

```text id="g9h8s3"
Primary Content
+
Context
+
Impact
+
Status
```

without excessive navigation.

---

## Recommended Pattern

```text id="6vg3gc"
Navigation
      +
Content Workspace
      +
Context Panel
```

This aligns with the inspection-heavy nature of sembl.

---

# 10.5 Tablet Experience

Tablet supports review-oriented workflows.

It is not the primary authoring environment.

---

## Supported Activities

### Specification Review

### Approval Review

### Execution Monitoring

### Validation Review

### Deployment Review

### Change Review

### Activity Review

---

## Limited Activities

### Large Specification Editing

### Repository Ingestion

### Deep Graph Inspection

### Complex Merge Resolution

---

## Layout Principle

Tablet prioritizes:

```text id="phh1r5"
Content
→ Context
```

rather than simultaneous visibility.

Context panels may collapse into drawers.

---

# 10.6 Mobile Experience

Mobile is a monitoring and decision surface.

Not a primary construction surface.

---

## Primary Goals

Allow users to answer:

```text id="4gmx2g"
What is happening?

What requires my attention?

Can I approve this?

Did something fail?
```

---

## Supported Activities

### Approval Review

### Approval Decision

### Activity Review

### Project Status Review

### Execution Monitoring

### Deployment Monitoring

### Notification Management

### Escalation Awareness

---

## Limited Activities

### Minor Specification Edits

### Commenting

### Quick Reviews

---

## Unsupported Activities

### Repository Ingestion

### Large Specification Authoring

### Merge Conflict Resolution

### Deep Architectural Inspection

### Complex Change Analysis

---

## Mobile Principle

Mobile should support:

```text id="0w7pxg"
Observe
Review
Approve
Respond
```

not:

```text id="7h3i5i"
Construct
Model
Reconcile
Architect
```

---

# 10.7 Responsive Navigation Rules

Navigation must compress without changing structure.

---

## Desktop

Displays:

```text id="sl3f3e"
Workspace Navigation
Project Navigation
Contextual Navigation
```

simultaneously.

---

## Tablet

Displays:

```text id="a2ujn9"
Workspace Navigation
Project Navigation
```

with contextual navigation collapsed.

---

## Mobile

Displays:

```text id="wyt0s4"
Workspace Navigation
Project Navigation
```

through progressive disclosure.

---

## Rule

Navigation hierarchy must remain recognizable across devices.

---

# 10.8 Responsive Visibility Rules

Visibility architecture must survive responsiveness.

The following information remains mandatory on all devices:

### Project State

### Approval State

### Execution State

### Deployment State

### Blocking Conditions

---

## Visibility Priority Order

If screen space becomes constrained:

```text id="3z0jmx"
State
→ Actions
→ Context
→ Historical Information
→ Deep Technical Information
```

Historical and technical information compress first.

State visibility never compresses away.

---

# 10.9 Responsive Surface Adaptation

Secondary surfaces should adapt according to device.

---

## Desktop

Preferred:

### Panels

### Drawers

### Side Inspectors

---

## Tablet

Preferred:

### Drawers

### Expandable Sections

---

## Mobile

Preferred:

### Full-Screen Sheets

### Step-Based Review Surfaces

---

## Rule

The information remains available.

Only the presentation changes.

---

# 10.10 Accessibility Philosophy

Accessibility is an architectural requirement.

Not an afterthought.

Users must be able to:

* understand state
* navigate workflows
* review changes
* approve actions
* inspect impacts

regardless of interaction method.

---

# 10.11 Semantic Structure Requirements

All major content must have meaningful structure.

Required hierarchy:

```text id="8cmmlz"
Workspace
→ Project
→ Screen
→ Section
→ Object
→ Action
```

The structure should be understandable without visual cues.

---

# 10.12 Keyboard Accessibility

All major workflows must support keyboard navigation.

---

## Required Coverage

### Navigation

### Specification Editing

### Approval Review

### Change Review

### Deployment Review

### Activity Review

---

## Required Behavior

Users must be able to:

* move
* inspect
* approve
* reject
* review

without requiring a pointer device.

---

# 10.13 Focus Management

Focus must remain predictable.

---

## Requirements

After actions:

* focus remains visible
* focus moves logically
* focus never becomes lost

---

## Critical Workflows

### Approval Review

### Validation Review

### Error Resolution

### Merge Review

must preserve clear focus transitions.

---

# 10.14 Screen Reader Requirements

Screen-reader users must be able to understand:

### Current Project

### Current State

### Current Workflow

### Blocking Conditions

### Available Actions

without visual interpretation.

---

## Priority Information

The following should always be announced clearly:

### Lifecycle State

### Validation State

### Approval State

### Deployment State

### Failure State

---

# 10.15 State Accessibility

State communication must not rely on:

* color
* position
* iconography

alone.

All states require explicit textual representation.

Examples:

Bad:

```text id="n8vaf7"
Red badge only.
```

Good:

```text id="s8j6bl"
Validation Failed
```

---

# 10.16 Notification Accessibility

Notifications must expose:

### Event

### Severity

### Scope

### Required Action

through accessible text.

---

# 10.17 Data Density Requirements

sembl is an information-dense system.

Accessibility should not force oversimplification.

Instead:

* information should remain available
* complexity should remain progressive
* structure should remain navigable

The goal is clarity.

Not reduction.

---

# 10.18 Accessibility for Traceability

Lineage and impact systems must remain accessible.

Users must be able to understand:

```text id="j7r0w2"
What caused this?

What changed?

What depends on this?
```

through non-visual interaction methods.

---

# 10.19 Responsive and Accessibility Constraints

---

## RA-I1

Desktop remains the canonical authoring environment.

---

## RA-I2

Mobile prioritizes monitoring, approvals, and response.

---

## RA-I3

Navigation structure remains consistent across devices.

---

## RA-I4

Project state remains visible on all devices.

---

## RA-I5

State communication never depends solely on visual styling.

---

## RA-I6

Keyboard access is required for all major workflows.

---

## RA-I7

Screen-reader users must be able to understand project state and workflow state.

---

## RA-I8

Accessibility must preserve traceability and visibility architecture.

---

## RA-I9

Responsive adaptation may alter presentation but not information architecture.

---

## RA-I10

Accessibility support must not reduce workflow capability.

---

# 10.20 Global UX Invariant Summary

The UI/UX Specification concludes with the following global invariant:

```text id="n7mhhj"
Users build software
through evolving specifications.

The system preserves
architectural continuity,
validation visibility,
reconciliation visibility,
lineage visibility,
and execution transparency.

Complexity is progressively revealed.

Graph canonicality remains preserved.

Graph management never becomes the primary user experience.
```

---






', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('9f4ae953-a561-50fa-b9a3-f2110187bb65', 'afc194d2-a715-54fc-add6-dc9cbd4d1c9e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# UI/UX Specification — Section 1

# Purpose, Scope, and UX Invariants

---

# 1.1 Purpose

This document defines the canonical interaction architecture for sembl v1.

It specifies:

* information architecture
* navigation architecture
* workspace architecture
* operational workflows
* interaction flows
* screen architecture
* visibility architecture
* state architecture
* approval behavior
* validation behavior
* reconciliation behavior
* deployment behavior
* user-visible system behavior

This document is authoritative for:

* UX design
* screen generation
* Figma generation
* Stitch generation
* HTML generation
* interaction modeling
* workflow extraction
* graph extraction

The document defines how users interact with sembl.

It does not define how sembl is visually styled.

---

# 1.2 Relationship to Other Canonical Documents

The UI/UX Specification is downstream of:

* PDD
* PRD
* NFR
* V4.3 Formal Specification
* V4.3 Execution Architecture

This document must remain consistent with all upstream specifications.

If interpretation conflicts occur:

```text
V4.3
→ PDD
→ PRD
→ NFR
→ UI/UX Specification
```

Higher-order documents remain authoritative.

---

# 1.3 Scope

This document defines user-visible behavior for:

* Documentation Mode
* Execution Mode
* Iteration Mode
* Repository Ingestion
* Validation
* Reconciliation
* Branching
* Deployment
* Collaboration
* Approval Workflows
* Audit Visibility
* Operational Visibility

This document defines:

* what users see
* what users can do
* where users can go
* when actions are available
* how state transitions occur

This document does not define:

* visual branding
* colors
* typography
* component styling
* animation systems
* design language

Those are downstream design concerns.

---

# 1.4 Canonical UX Objective

The primary UX objective of sembl is:

> Enable users to build, evolve, validate, and deploy software through specifications while preserving architectural continuity.

The product should feel like:

```text
Software evolves through specifications.
```

The product should not feel like:

```text
Managing repositories.

Managing graph databases.

Operating AI agents.

Managing execution DAGs.

Writing prompts to generate files.
```

The interaction model must continuously reinforce:

* specification primacy
* architectural continuity
* graph canonicality
* scoped execution
* reconciliation-governed mutation

without requiring users to understand those systems directly.

---

# 1.5 User Experience Model

sembl operates through progressive abstraction.

The same system must support:

* non-technical users
* semi-technical users
* highly technical users

without creating separate products.

The system progressively reveals complexity as user needs increase.

---

## Non-Technical User Experience

Primary interaction objects:

* goals
* requirements
* workflows
* specifications
* progress
* approvals
* outputs

The user should rarely need to interact with:

* graph structures
* dependency structures
* execution topology
* reconciliation internals

unless explicitly requested.

---

## Technical User Experience

Technical users may progressively access:

* graph state
* dependency state
* validation state
* lineage state
* execution topology
* reconciliation state
* deployment state

Advanced visibility must remain available without becoming the default workflow.

---

# 1.6 Progressive Complexity Disclosure Principle

Complexity must be revealed gradually.

Users should always encounter:

```text
Intent
→ Specification
→ Workflow
→ Outcome
```

before encountering:

```text
Graph
→ Dependency
→ Validation
→ Reconciliation
→ Topology
```

Advanced operational state should be inspectable.

It should never become mandatory for routine workflows.

---

# 1.7 Specification Primacy Principle

Specifications are the primary user interaction surface.

Users interact with:

* requirements
* workflows
* entities
* APIs
* UX definitions
* architecture definitions

The graph remains the canonical system state.

However:

the graph is not the primary user-facing editing surface.

All major mutations originate through:

* specification mutation
* structured workflows
* repository reconstruction workflows

rather than direct graph editing.

---

# 1.8 Graph Visibility Principle

Graph visibility is required.

Graph management is not.

The graph exists as:

* inspection surface
* diagnostic surface
* architectural visibility surface

The graph must not become:

* primary navigation
* primary editing model
* required operational interface

Users should understand software structure without needing to understand graph mechanics.

---

# 1.9 Workflow-Centric Navigation Principle

Navigation should organize around user goals.

Navigation should not organize around internal architecture.

Preferred user concepts:

* Specifications
* Execution
* Changes
* Branches
* Deployments
* Activity

Avoid exposing internal concepts as primary navigation destinations:

* Task DAGs
* Agent Systems
* Graph Storage
* Context Generation
* Reconciliation Engines

Internal architecture may be inspectable but should not drive navigation.

---

# 1.10 Execution Transparency Principle

Execution must be visible.

Execution internals do not need to be visible.

Users must always understand:

* what is happening
* what has completed
* what is blocked
* what failed
* what requires action

Users are not required to understand:

* agent orchestration
* worker allocation
* DAG execution internals
* planning internals

The system exposes progress.

The system may hide implementation mechanics.

---

# 1.11 Validation Visibility Principle

Validation is a first-class user-visible system.

Validation failures must never be hidden.

Users must always be able to determine:

* what failed
* why it failed
* what is affected
* what must be resolved

Validation outcomes must be actionable.

Validation visibility is mandatory.

---

# 1.12 Reconciliation Visibility Principle

Reconciliation is a core system behavior.

Users must be able to inspect:

* what changed
* why it changed
* affected structures
* architectural impact
* dependency impact

The system must make architectural evolution understandable.

Reconciliation outcomes must remain visible even when reconciliation succeeds.

---

# 1.13 Architectural Continuity Principle

The UX must reinforce continuity rather than regeneration.

Users should experience:

```text
Evolving software
```

rather than:

```text
Generating software again.
```

The interface must continuously surface:

* existing architecture
* existing entities
* existing interfaces
* existing flows
* existing decisions

before presenting mutation options.

---

# 1.14 Approval Visibility Principle

Approval gates are significant system events.

Approval workflows must clearly communicate:

* why approval is required
* what changed
* impact scope
* execution consequences

Approvals must never appear as arbitrary interruptions.

Approvals must be contextualized through visible architectural impact.

---

# 1.15 Visibility Hierarchy Principle

User-visible information should be presented in the following order:

```text
Goals
→ Specifications
→ Progress
→ Outputs
→ Changes
→ Validation
→ Reconciliation
→ Graph State
→ Execution Topology
```

Lower-level system state must not dominate higher-level user intent.

---

# 1.16 UX Invariants

The following invariants are mandatory across all sembl interfaces.

---

## UX-I1 — Specification Primacy

Users interact primarily through specifications.

Direct graph manipulation is not a primary workflow.

---

## UX-I2 — Graph Secondary

The graph is inspectable but not central.

Users can complete normal workflows without entering graph views.

---

## UX-I3 — Workflow First

Navigation prioritizes workflows and outcomes over internal system architecture.

---

## UX-I4 — Progressive Disclosure

Advanced system complexity is revealed only when relevant.

---

## UX-I5 — Validation Visibility

Validation failures must remain visible until resolved.

---

## UX-I6 — Reconciliation Visibility

Reconciliation outcomes must remain inspectable.

---

## UX-I7 — Architectural Mutation Visibility

Architectural mutations must clearly expose impact before approval.

---

## UX-I8 — Approval Before Architectural Mutation

Approval-gated mutations cannot proceed without explicit approval.

---

## UX-I9 — Execution Transparency

Execution progress must always be visible.

---

## UX-I10 — State Transparency

Users must always know:

* current state
* blocked state
* failure state
* required next action

---

## UX-I11 — Architectural Continuity

Interfaces must reinforce evolution of existing architecture rather than regeneration.

---

## UX-I12 — Canonical Consistency

All user-visible interactions must remain consistent with:

* graph canonicality
* specification primacy
* scoped execution
* reconciliation-governed mutation
* lineage preservation

---

# UI/UX Specification — Section 2

# Information Architecture

---

# 2.1 Purpose

The Information Architecture defines the canonical organizational structure of sembl.

It determines:

* what objects exist
* how objects relate
* ownership boundaries
* visibility boundaries
* navigation hierarchy
* workflow hierarchy

The Information Architecture must reflect the core operational model defined by:

```text
Specification
→ Graph
→ Execution
→ Reconciliation
→ Iteration
```

while exposing the system through user-oriented concepts rather than internal implementation structures.

---

# 2.2 Architectural Principle

The Information Architecture is organized around:

```text
Workspace
→ Project
→ Software Evolution
```

not around:

```text
Repositories
Graphs
Agents
Tasks
Files
```

The system should feel like managing an evolving software system rather than managing implementation artifacts.

---

# 2.3 Primary Information Objects

The following are canonical user-visible objects.

---

## Workspace

Highest-level organizational container.

Contains:

* members
* permissions
* projects
* approvals
* activity history

Responsibilities:

* collaboration boundary
* security boundary
* ownership boundary

A user may belong to multiple workspaces.

---

## Project

Primary operational container.

Represents a single software system.

Contains:

* specifications
* graph state
* execution history
* branches
* deployments
* validation history
* reconciliation history

A project is the primary unit of work.

---

## Specification Set

Represents the canonical specification layer.

Includes:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

Responsibilities:

* intent definition
* architecture definition
* execution source definition

Specifications are primary user-editable artifacts.

The specification set is the authoritative source for:

- graph extraction
- validation
- execution planning
- reconciliation
- software evolution

---

## Execution

Represents software generation and implementation activities.

Contains:

* execution runs
* execution progress
* validation results
* reconciliation results
* deployment outputs

Execution is non-canonical.

Execution derives from specifications and graph state.

---

## Branch

Represents an isolated semantic evolution path.

Contains:

* mutations
* diffs
* approvals
* execution history
* lineage references

Branches operate on graph state rather than repositories.

---

## Deployment

Represents a generated runtime output.

Contains:

* deployment metadata
* deployment references
* environment references
* deployment history

Deployments are non-canonical operational outputs.

---

## Approval

Represents a required governance decision.

Approval types:

* execution approval
* architectural mutation approval
* merge approval

Approvals are workflow objects rather than content objects.

---

## Activity

Represents historical operational visibility.

Contains:

* mutations
* executions
* approvals
* validations
* reconciliations
* deployments

Activity is read-only historical state.

---

## Graph

Represents canonical architectural state.

Contains:

* entities
* interfaces
* flows
* dependencies
* invariants
* lineage

Graph visibility exists primarily for inspection.

Graph editing is not a primary workflow.

---

# 2.4 Information Hierarchy

The canonical hierarchy is:

```text
Workspace
│
├ Members
├ Approvals
├ Activity
│
└ Projects
      │
      ├ Overview
      ├ Specifications
      ├ Execution
      ├ Changes
      ├ Branches
      ├ Deployments
      ├ Activity
      └ Graph
```

This hierarchy defines the primary organizational structure of the product.

---

# 2.5 Project Internal Structure

Every project is organized around software evolution.

```text
Project
│
├ Overview
│
├ Specifications
│     ├ PDD
│     ├ PRD
│     ├ NFR
│     ├ UI/UX
│     ├ System Design
│     ├ DB Schema
│     ├ API Spec
│     ├ Tech Architecture
│    
│
├ Execution
│
├ Changes
│
├ Branches
│
├ Deployments
│
├ Activity
│
└ Graph
```

This structure remains consistent regardless of operational mode.

---

# 2.6 Ownership Model

Ownership exists at three levels.

---

## Workspace Ownership

Owns:

* members
* permissions
* projects

Responsible for:

* governance
* access control
* collaboration

---

## Project Ownership

Owns:

* specifications
* graph state
* branches
* deployments
* activity history

Responsible for:

* software evolution
* execution lifecycle

---

## Branch Ownership

Owns:

* isolated mutations
* branch execution state
* branch approvals
* branch lineage

Responsible for:

* safe experimentation
* isolated evolution

---

# 2.7 Visibility Model

Information visibility follows progressive disclosure.

---

## Level 1 — Intent Visibility

Visible to all users by default.

Includes:

* goals
* requirements
* specifications
* progress
* outputs

This is the primary user experience.

---

## Level 2 — Operational Visibility

Visible during execution and iteration workflows.

Includes:

* validation
* approvals
* diffs
* execution progress
* deployments

This is the primary project management layer.

---

## Level 3 — Architectural Visibility

Available on demand.

Includes:

* entities
* interfaces
* flows
* dependencies
* lineage

This is the primary technical inspection layer.

---

## Level 4 — Deep Technical Visibility

Available through advanced inspection.

Includes:

* graph topology
* validation structures
* reconciliation details
* execution topology
* dependency analysis

This visibility exists for diagnosis and review.

It is not required for routine workflows.

---

# 2.8 Canonical User Mental Model

The product should encourage the following mental model:

```text
Workspace
    ↓
Project
    ↓
Specifications
    ↓
Build
    ↓
Deploy
    ↓
Evolve
```

Not:

```text
Workspace
    ↓
Repository
    ↓
Files
    ↓
Code Generation
```

And not:

```text
Workspace
    ↓
Graph
    ↓
Nodes
    ↓
Edges
```

The graph exists beneath the experience.

The user experiences software evolution.

---

# 2.9 Information Architecture Constraints

---

## IA-I1 — Project-Centric Organization

Projects are the primary operational unit.

All major workflows originate from projects.

---

## IA-I2 — Specification-Centric Structure

Specifications remain the primary editable artifacts.

---

## IA-I3 — Graph Secondary

Graph structures remain subordinate to specifications in the information hierarchy.

---

## IA-I4 — Operational Separation

Execution, deployments, branches, and activity remain distinct operational domains.

---

## IA-I5 — Progressive Visibility

Technical detail visibility increases progressively.

Complexity must never be front-loaded.

---

## IA-I6 — Architectural Continuity

Information architecture must reinforce continuity across project evolution.

Historical context must remain discoverable.

---

## IA-I7 — Repository Non-Canonicality

Repositories and generated code must never appear as canonical project state.

Canonical state remains:

* specifications
* graph
* lineage
* validation
* reconciliation

---

## IA-I8 — Workflow Alignment

Information organization must align with software evolution workflows rather than implementation storage structures.

---

# UI/UX Specification — Section 3

# Navigation and Workspace Architecture

---

# 3.1 Purpose

Navigation Architecture defines how users move through sembl.

Workspace Architecture defines the persistent operational environment within which all user activity occurs.

Together they establish:

* navigation hierarchy
* workspace structure
* operational orientation
* state visibility
* context persistence

The navigation model must support:

* Documentation Mode
* Execution Mode
* Iteration Mode
* Repository Ingestion

without requiring users to consciously manage modes.

Modes are system states.

Projects are user-facing constructs.

---

# 3.2 Navigation Philosophy

Navigation is organized around software evolution.

Navigation must prioritize:

```text
Specifications
→ Build
→ Deploy
→ Evolve
```

Navigation must not prioritize:

```text
Graphs
→ Agents
→ Tasks
→ Execution Internals
```

The navigation structure should reinforce the mental model:

```text
I am building software.
```

not:

```text
I am operating a semantic graph system.
```

---

# 3.3 Navigation Hierarchy

Navigation exists across three levels.

```text id="6c9o3y"
Global Navigation
      ↓
Project Navigation
      ↓
Contextual Navigation
```

Each level serves a different purpose.

---

# 3.4 Global Navigation

Global Navigation operates at workspace scope.

Accessible from all screens.

---

## Global Destinations

### Projects

Purpose:

Primary project access surface.

Contains:

* all accessible projects
* project search
* project creation
* project status visibility

---

### Approvals

Purpose:

Centralized approval queue.

Contains:

* pending approvals
* execution approvals
* architectural mutation approvals
* merge approvals

Must surface:

* urgency
* impact
* blocked workflows

---

### Activity

Purpose:

Workspace-wide operational visibility.

Contains:

* project activity
* executions
* deployments
* approvals
* merges
* mutations

Acts as organizational audit surface.

---

### Workspace Settings

Purpose:

Workspace administration.

Contains:

* members
* permissions
* integrations
* workspace configuration

---

# 3.5 Project Navigation

Project Navigation is the primary operational navigation system.

Every project exposes the same navigation structure.

---

## Overview

Purpose:

Project status and orientation.

Provides:

* project health
* current state
* active work
* recent changes
* execution status
* deployment status

Overview acts as the project home.

---

## Specifications

Purpose:

Primary software definition workspace.

Contains:

* PDD
* PRD
* NFR
* UI/UX Specification
* System Design
* DB Schema
* API Specification
* Tech Architecture

This is the primary editing surface of the platform.

---

## Execution

Purpose:

Execution lifecycle visibility.

Contains:

* execution progress
* validation status
* reconciliation status
* deployment status
* execution history

Execution does not expose implementation internals by default.

---

## Changes

Purpose:

Software evolution visibility.

Contains:

* semantic diffs
* mutation history
* version history
* reconciliation summaries

Changes answers:

```text
What changed?
Why did it change?
What was affected?
```

---

## Branches

Purpose:

Parallel software evolution management.

Contains:

* active branches
* branch comparisons
* merge status
* branch lineage

---

## Deployments

Purpose:

Runtime delivery visibility.

Contains:

* deployment history
* deployment environments
* deployment status
* deployment failures
* rollback history

---

## Activity

Purpose:

Project-specific operational timeline.

Contains:

* approvals
* mutations
* validations
* executions
* deployments

---

## Graph

Purpose:

Architectural inspection.

Contains:

* entities
* interfaces
* flows
* dependencies
* lineage

Graph remains an inspection surface.

Graph is never the primary editing surface.

---

# 3.6 Contextual Navigation

Contextual Navigation exists within a destination.

It exposes information relevant to the current workflow.

---

## Specifications Context

Example:

```text id="m8v8sl"
Documents
Dependencies
Validation
Assumptions
History
```

---

## Execution Context

Example:

```text id="g2l88p"
Progress
Validation
Reconciliation
Deployment
History
```

---

## Changes Context

Example:

```text id="q8hns9"
Diffs
Impact
Lineage
Versions
```

---

## Branch Context

Example:

```text id="c2t9jv"
Overview
Changes
Execution
Merge Status
```

---

## Graph Context

Example:

```text id="44j3jm"
Entities
Interfaces
Flows
Dependencies
Lineage
```

Contextual navigation must remain localized and workflow-specific.

---

# 3.7 Workspace Shell

The Workspace Shell is the persistent environment visible across most screens.

The shell must maintain continuity while users move between workflows.

---

## Persistent Elements

The following elements remain consistently available.

### Global Navigation

Provides workspace-level movement.

---

### Project Navigation

Provides project-level movement.

---

### Project Context

Displays:

* current project
* current branch
* current version state

Users must always know where they are.

---

### Status Surface

Displays:

* execution status
* validation status
* approval status

without requiring navigation.

---

### Notifications Surface

Displays:

* approvals required
* execution completion
* validation failures
* deployment failures

---

### User Context

Displays:

* user identity
* workspace identity
* permissions

---

# 3.8 Project Context Model

The system must continuously maintain visible context.

Users should never lose awareness of:

```text id="4nd7um"
Workspace
Project
Branch
State
```

The active context should remain visible across navigation transitions.

---

## Required Context Indicators

At minimum:

### Active Workspace

### Active Project

### Active Branch

### Current State

Examples:

```text
Draft

Ready For Execution

Executing

Awaiting Approval

Iterating

Deployment Failed
```

---

# 3.9 Navigation Behavior by Operational Mode

The navigation structure remains stable across modes.

The visible content changes.

---

## Documentation Mode

Primary emphasis:

```text
Overview
Specifications
Validation
Approval
```

Execution-related sections remain secondary.

---

## Execution Mode

Primary emphasis:

```text
Execution
Validation
Reconciliation
Deployment
```

Specifications remain accessible.

---

## Iteration Mode

Primary emphasis:

```text
Changes
Branches
Execution
Deployments
```

Specifications remain editable.

---

## Repository Ingestion

Temporary emphasis:

```text
Repository
Analysis
Confidence Review
Validation
Activation
```

Once activated, the standard project navigation appears.

---

# 3.10 Navigation Visibility Rules

---

## NAV-I1 — Stable Navigation

Navigation structure must remain consistent throughout the project lifecycle.

Users should not experience major navigation restructuring between modes.

---

## NAV-I2 — Specification Accessibility

Specifications must always remain accessible regardless of current state.

---

## NAV-I3 — Context Persistence

Workspace, project, and branch context must remain continuously visible.

---

## NAV-I4 — Approval Visibility

Pending approvals must be visible globally.

Users should not need to discover blocked work manually.

---

## NAV-I5 — Failure Visibility

Execution failures, validation failures, and deployment failures must surface prominently.

---

## NAV-I6 — Graph Secondary

Graph access must remain available but non-dominant.

Graph navigation must never displace specification workflows.

---

## NAV-I7 — Workflow Orientation

Navigation labels should describe user goals and workflows rather than internal system implementation.

---

## NAV-I8 — Progressive Technical Exposure

Technical navigation destinations should become more prominent only when users enter technical workflows.

---

# 3.11 Workspace Architecture Constraints

---

## WA-I1

Projects are the primary operational unit.

---

## WA-I2

Specifications are the primary authoring surface.

---

## WA-I3

Execution is primarily observed, not manually managed.

---

## WA-I4

Changes are first-class navigation entities.

---

## WA-I5

Branches represent semantic evolution paths, not repository forks.

---

## WA-I6

Graph inspection must remain optional.

---

## WA-I7

Users must always know:

* where they are
* what state the project is in
* what requires action
* what changed recently

---

# UI/UX Specification — Section 4

# Project Lifecycle and Operational Modes

---

# 4.1 Purpose

The Project Lifecycle defines how software evolves inside sembl.

The lifecycle is the primary behavioral structure of the platform.

It governs:

* project creation
* specification generation
* execution
* deployment
* iteration
* repository onboarding
* escalation

The lifecycle defines user-visible progression.

Internal execution systems remain implementation concerns.

---

# 4.2 Lifecycle Principle

Software evolves through semantic state.

The user journey is:

```text
Intent
→ Specification
→ Validation
→ Approval
→ Execution
→ Deployment
→ Iteration
```

The lifecycle must reinforce:

* specification primacy
* architectural continuity
* reconciliation-governed evolution

The lifecycle must avoid:

* prompt-driven regeneration
* repository-centric workflows
* graph-centric workflows

---

# 4.3 Canonical Lifecycle

New projects follow the canonical lifecycle.

```text id="s0r9yt"
Project Creation
        ↓
Documentation Mode
        ↓
Specification Validation
        ↓
Execution Approval
        ↓
Execution Mode
        ↓
Validation
        ↓
Reconciliation
        ↓
Deployment
        ↓
Iteration Mode
```

This is the primary lifecycle for v1.

---

# 4.4 Lifecycle States

Every project exists in one primary lifecycle state.

---

## Draft

Meaning:

Project is being defined.

Characteristics:

* specifications incomplete
* validation incomplete
* execution unavailable

Primary user activity:

* specification creation
* refinement
* review

---

## Ready For Execution

Meaning:

Documentation is complete.

Characteristics:

* specifications validated
* graph extraction readiness achieved
* execution approval pending

Primary user activity:

* review
* approval

---

## Executing

Meaning:

Software generation is underway.

Characteristics:

* execution active
* validation active
* deployment unavailable

Primary user activity:

* monitoring

---

## Reconciling

Meaning:

Execution outputs are being integrated.

Characteristics:

* graph updates active
* validation active
* deployment blocked

Primary user activity:

* monitoring
* issue review

---

## Deploying

Meaning:

Deployment workflows are active.

Characteristics:

* execution completed
* reconciliation completed
* deployment active

Primary user activity:

* monitoring

---

## Active

Meaning:

Project has successfully entered Iteration Mode.

Characteristics:

* deployment completed
* iteration enabled
* mutations allowed

Primary user activity:

* software evolution

---

## Awaiting Approval

Meaning:

Workflow is blocked pending approval.

Characteristics:

* execution paused
* mutation paused
* merge paused

Primary user activity:

* review
* approval

---

## Escalated

Meaning:

Automatic convergence failed.

Characteristics:

* execution blocked
* mutation blocked
* manual intervention required

Primary user activity:

* resolution

---

# 4.5 Project Creation Experience

Project creation is the first interaction with sembl.

The system must immediately orient users toward software creation rather than technical setup.

---

## Supported Entry Paths

### New Project

User begins from intent.

Examples:

```text
I want a fitness coaching platform.

I want an event marketplace.

I want a CRM for consultants.
```

Entry destination:

Documentation Mode.

---

### Existing Repository

User begins from an existing codebase.

Examples:

```text
Import repository.

Continue existing project.

Modernize existing system.
```

Entry destination:

Repository Ingestion Flow.

---

# 4.6 Documentation Mode

---

## Purpose

Transform intent into executable specification state.

Documentation Mode is the specification construction phase.

No software execution occurs during this mode.

---

## Primary User Goal

Answer:

```text
What are we building?
```

---

## Primary User Activities

* defining requirements
* refining specifications
* reviewing assumptions
* resolving ambiguity
* validating completeness

---

## Primary System Activities

* specification generation
* dependency detection
* assumption detection
* validation
* graph extraction readiness analysis

---

## Core User Journey

```text id="8plx0s"
Intent
→ Specification Generation
→ Specification Refinement
→ Validation
→ Approval Readiness
```

---

## User Focus

Users primarily interact with:

* specifications
* requirements
* workflows
* assumptions

Not:

* graph structures
* execution systems
* task orchestration

---

## Exit Conditions

Documentation Mode exits only when:

* specifications validate
* graph extraction readiness passes
* unresolved ambiguity is cleared
* execution approval becomes available

---

# 4.7 Execution Approval State

---

## Purpose

Execution Approval is the final checkpoint before software generation begins.

This is Approval Gate 1.

---

## User Question Being Answered

```text
Are these specifications correct?
```

---

## Visible Information

Users must see:

* specification summary
* execution targets
* inferred assumptions
* validation summary
* architectural assumptions

---

## Available Actions

### Approve

Transitions:

```text
Ready For Execution
→ Executing
```

---

### Return To Documentation

Transitions:

```text
Ready For Execution
→ Draft
```

---

## Blocking Rule

Execution cannot begin until approval is granted.

---

# 4.8 Execution Mode

---

## Purpose

Transform validated semantic state into deployable software.

---

## Primary User Goal

Answer:

```text
What is currently being built?
```

---

## Primary User Activities

* monitoring progress
* reviewing validation
* reviewing failures

---

## Primary System Activities

* graph construction
* normalization
* validation
* DAG generation
* execution
* reconciliation
* deployment preparation

---

## Core User Journey

```text id="rw5wpr"
Execution
→ Validation
→ Reconciliation
→ Deployment
```

---

## User Experience Model

Users experience:

* progress
* milestones
* completion state

Users do not need to manage:

* workers
* DAGs
* orchestration

---

## Exit Conditions

Execution Mode exits when:

### Success

```text
Execution Complete
→ Reconciliation
→ Deployment
```

### Failure

```text
Execution
→ Escalation
```

---

# 4.9 Reconciliation Phase

---

## Purpose

Integrate execution outcomes into canonical graph state.

---

## User Question Being Answered

```text
What changed in the system?
```

---

## Visible Information

* affected structures
* architectural changes
* generated diffs
* dependency impacts

---

## Outcome

Successful reconciliation creates:

* updated graph state
* lineage updates
* version updates

---

## Transition

```text
Reconciliation
→ Deployment
```

---

# 4.10 Deployment Phase

---

## Purpose

Create deployable runtime outputs.

---

## User Question Being Answered

```text
Is the software available?
```

---

## Visible Information

* deployment progress
* deployment status
* environment status
* deployment failures

---

## Outcomes

### Success

```text
Deployment
→ Active
```

### Failure

```text
Deployment
→ Escalated
```

or

```text
Deployment
→ Rollback
```

depending on failure conditions.

---

# 4.11 Iteration Mode

---

## Purpose

Enable long-term software evolution.

Iteration Mode is the steady-state operating mode of sembl.

Most project life is spent here.

---

## Primary User Goal

Answer:

```text
How should the software evolve?
```

---

## Primary User Activities

* requesting changes
* reviewing diffs
* approving mutations
* reviewing deployments

---

## Primary System Activities

* scope analysis
* mutation analysis
* validation
* reconciliation
* localized re-execution

---

## Core User Journey

```text id="9g7vgh"
Change Request
→ Scope Analysis
→ Mutation
→ Validation
→ Reconciliation
→ Deployment
```

---

## Key UX Principle

The experience should feel like:

```text
Evolving software.
```

not:

```text
Generating software again.
```

---

# 4.12 Architectural Mutation Flow

---

## Purpose

Govern high-impact changes.

This is Approval Gate 2.

---

## Trigger Conditions

* entity additions
* entity removals
* entity renames
* interface additions
* interface removals
* interface renames
* dependency restructuring
* execution-target migration
* invariant-affecting changes

---

## User Question Being Answered

```text
Do you approve these architectural changes?
```

---

## Visible Information

Users must see:

* impacted structures
* dependency impact
* execution impact
* architectural diff
* affected scope

---

## Outcomes

### Approved

```text
Approval
→ Re-Execution
```

### Rejected

```text
Approval
→ Iteration Mode
```

with no mutation applied.

---

# 4.13 Repository Ingestion Lifecycle

---

## Purpose

Allow existing software systems to enter semantic evolution workflows.

---

## Core Journey

```text id="4k6g6r"
Repository
→ Analysis
→ Reconstruction
→ Confidence Review
→ Validation
→ Activation
```

---

## User Question Being Answered

```text
Did sembl understand my system correctly?
```

---

## Primary User Activities

* repository connection
* reviewing inferred structures
* resolving ambiguities
* approving reconstruction

---

## Primary System Activities

* repository analysis
* graph reconstruction
* confidence analysis
* validation

---

## Exit Conditions

Repository onboarding exits when:

* validation passes
* low-confidence structures resolved
* graph canonicalization succeeds

---

## Transition

```text
Repository Ingestion
→ Active
```

The project enters Iteration Mode directly.

---

# 4.14 Escalation State

---

## Purpose

Prevent invalid progression.

---

## Escalation Triggers

* repeated validation failure
* repeated reconciliation failure
* unresolved ambiguity
* merge conflict deadlock
* repository reconstruction failure
* invariant conflicts

---

## User Question Being Answered

```text
What must be resolved before progress can continue?
```

---

## Required Visibility

Users must always see:

* root issue
* affected scope
* blocking conditions
* recommended actions

---

## Exit Conditions

Escalation exits only when:

* conflicts resolved
* validation succeeds
* reconciliation succeeds

---

# 4.15 Lifecycle Invariants

---

## LC-I1

Projects always exist in a clearly visible lifecycle state.

---

## LC-I2

Documentation precedes execution.

Except repository ingestion projects.

---

## LC-I3

Execution approval is mandatory before initial execution.

---

## LC-I4

Architectural mutations require approval before re-execution.

---

## LC-I5

Successful execution always creates reconciliation outputs.

---

## LC-I6

Successful reconciliation always creates lineage updates.

---

## LC-I7

Iteration is the default long-term operational state.

---

## LC-I8

Repository ingestion enters Iteration Mode only after validation and confidence resolution.

---

## LC-I9

Escalated projects cannot progress automatically.

---

## LC-I10

Lifecycle visibility is mandatory across all project states.

---

# UI/UX Specification — Section 5

# Core Operational Flows

---

# 5.1 Purpose

Core Operational Flows define how work moves through sembl.

They describe:

* user actions
* system actions
* approval points
* validation points
* reconciliation points
* lifecycle transitions

These flows represent the behavioral architecture of the platform.

They are independent of visual design and implementation.

They define how sembl behaves.

---

# 5.2 Flow Architecture Principles

Every operational flow must obey the following structure:

```text id="n5mz5v"
Trigger
→ Analysis
→ Validation
→ Decision
→ Execution
→ Reconciliation
→ Visibility Update
```

Not all flows contain every stage.

However:

* validation remains mandatory where applicable
* state transitions remain visible
* reconciliation remains visible
* approvals remain explicit

---

# 5.3 Specification Flow

---

## Purpose

Create or modify software specifications.

---

## Primary User Question

```text id="tk8m3z"
What should the software do?
```

---

## Trigger Events

* project creation
* document creation
* document modification
* requirement changes
* architecture changes

---

## Flow

```text id="1qotg0"
Intent
→ Specification Draft
→ Dependency Analysis
→ Validation
→ Review
→ Saved Specification State
```

---

## User Actions

* create specification
* edit specification
* approve suggestions
* reject suggestions
* review dependencies

---

## System Actions

* detect impacts
* identify dependencies
* identify ambiguity
* identify conflicts
* update specification state

---

## Output

Updated specification set.

---

## Exit Conditions

* validation passes
* specification saved

---

# 5.4 Validation Flow

---

## Purpose

Ensure specification and architectural correctness.

Validation is a continuous system process.

---

## Primary User Question

```text id="r2qjv3"
Is the system internally consistent?
```

---

## Trigger Events

* specification changes
* architectural changes
* execution requests
* branch merges
* repository ingestion

---

## Flow

```text id="b7c7zw"
Change Detected
→ Validation Triggered
→ Rule Evaluation
→ Result Generation
→ User Visibility
```

---

## Validation Outcomes

### Passed

```text id="6wrnwx"
Validation
→ Ready
```

---

### Warning

```text id="6s4vwk"
Validation
→ Warning State
→ User Review
```

---

### Failed

```text id="7rjz7n"
Validation
→ Blocked State
→ Resolution Required
```

---

## User Actions

* inspect issue
* navigate to affected artifacts
* resolve issue
* revalidate

---

## System Actions

* identify violations
* classify severity
* identify affected scope
* maintain validation history

---

## Output

Validation result set.

---

# 5.5 Approval Flow

---

## Purpose

Provide governance over consequential actions.

---

## Approval Categories

### Execution Approval

Required before first execution.

---

### Architectural Mutation Approval

Required before major structural changes.

---

### Merge Approval

Required before branch integration.

---

## Flow

```text id="0zv3hx"
Approval Required
→ Impact Summary
→ User Review
→ Decision
→ Outcome
```

---

## User Actions

### Approve

```text id="sccu4x"
Approval
→ Next Workflow
```

---

### Reject

```text id="i8k1i7"
Approval
→ Previous State
```

---

## System Actions

* calculate impact
* summarize changes
* identify risks
* update audit history

---

## Output

Approval decision.

---

# 5.6 Execution Flow

---

## Purpose

Transform semantic state into implementation outputs.

---

## Primary User Question

```text id="jvv7x8"
What is being built right now?
```

---

## Trigger Events

* execution approval
* approved iteration
* approved merge

---

## Flow

```text id="n5lpnh"
Execution Request
→ Context Generation
→ Execution
→ Validation
→ Reconciliation
→ Completion
```

---

## User Actions

* monitor
* inspect progress
* inspect failures

---

## System Actions

* generate context
* perform execution
* validate outputs
* reconcile results

---

## Success Path

```text id="42yl7y"
Execution
→ Reconciliation
→ Deployment
```

---

## Failure Path

```text id="4dphzv"
Execution
→ Escalation
```

---

## Output

Executable implementation state.

---

# 5.7 Reconciliation Flow

---

## Purpose

Integrate execution outcomes into canonical architectural state.

---

## Primary User Question

```text id="fytr2i"
How did the system evolve?
```

---

## Trigger Events

* execution completion
* merge completion
* repository reconstruction

---

## Flow

```text id="3h5mjp"
Execution Output
→ Impact Analysis
→ Graph Update
→ Lineage Update
→ Visibility Update
```

---

## User Actions

* inspect changes
* inspect impacts
* inspect lineage

---

## System Actions

* update graph
* update dependencies
* update lineage
* update versions

---

## Output

Updated canonical state.

---

# 5.8 Iteration Flow

---

## Purpose

Support continuous software evolution.

---

## Primary User Question

```text id="m2e6yn"
How should the software change?
```

---

## Trigger Events

* user requests change
* requirement evolution
* bug resolution
* enhancement request

---

## Flow

```text id="6hh29l"
Change Request
→ Scope Analysis
→ Impact Analysis
→ Validation
→ Approval (if required)
→ Execution
→ Reconciliation
→ Deployment
```

---

## User Actions

* request changes
* review impacts
* approve changes
* review results

---

## System Actions

* determine affected scope
* determine dependency impact
* determine execution scope

---

## Output

Updated software system.

---

# 5.9 Branch Flow

---

## Purpose

Enable isolated evolution.

---

## Primary User Question

```text id="drrqgj"
Can I explore changes safely?
```

---

## Trigger Events

* experimentation
* feature development
* architectural exploration

---

## Flow

```text id="8dz1hl"
Create Branch
→ Isolate State
→ Apply Changes
→ Execute
→ Review
```

---

## User Actions

* create branch
* switch branch
* compare branch
* delete branch

---

## System Actions

* isolate lineage
* isolate mutations
* isolate execution history

---

## Output

Independent evolution path.

---

# 5.10 Merge Flow

---

## Purpose

Integrate approved branch changes.

---

## Primary User Question

```text id="d1vagx"
Can these changes become canonical?
```

---

## Trigger Events

* branch completion
* merge request

---

## Flow

```text id="0y0s0h"
Merge Request
→ Diff Analysis
→ Impact Analysis
→ Validation
→ Approval
→ Reconciliation
→ Canonical Update
```

---

## User Actions

* review diff
* review impact
* approve merge

---

## System Actions

* compare branches
* identify conflicts
* reconcile lineage

---

## Success Path

```text id="ll78yg"
Branch
→ Canonical State
```

---

## Failure Path

```text id="ijm5yr"
Conflict
→ Resolution Workflow
```

---

## Output

Updated canonical branch.

---

# 5.11 Deployment Flow

---

## Purpose

Deliver generated software.

---

## Primary User Question

```text id="sjlwmc"
Is the software available and healthy?
```

---

## Trigger Events

* execution completion
* approved deployment

---

## Flow

```text id="v2e0tl"
Deployment Request
→ Environment Validation
→ Deployment
→ Health Verification
→ Deployment Complete
```

---

## User Actions

* monitor
* inspect deployment
* rollback (if permitted)

---

## System Actions

* deploy artifacts
* verify deployment
* record deployment history

---

## Success Path

```text id="jqutgg"
Deployment
→ Active
```

---

## Failure Path

```text id="6g1frd"
Deployment
→ Failure
→ Rollback
```

or

```text id="0frv3r"
Deployment
→ Escalation
```

---

## Output

Deployed runtime state.

---

# 5.12 Repository Ingestion Flow

---

## Purpose

Convert existing software into canonical semantic state.

---

## Primary User Question

```text id="jly14g"
Did sembl understand my system correctly?
```

---

## Flow

```text id="e4h7tx"
Repository Connection
→ Analysis
→ Reconstruction
→ Confidence Scoring
→ User Review
→ Validation
→ Canonicalization
→ Activation
```

---

## User Actions

* review inferred structures
* resolve ambiguities
* approve reconstruction

---

## System Actions

* reconstruct graph
* infer entities
* infer interfaces
* infer flows
* score confidence

---

## Output

Canonical project state.

---

# 5.13 Escalation Flow

---

## Purpose

Resolve situations where automatic convergence fails.

---

## Primary User Question

```text id="n6g9lj"
What is preventing progress?
```

---

## Trigger Events

* repeated validation failures
* reconciliation failures
* merge deadlocks
* repository reconstruction failures
* invariant violations

---

## Flow

```text id="4vddrw"
Issue Detected
→ Root Cause Analysis
→ Escalation
→ Resolution
→ Revalidation
→ Resume Workflow
```

---

## User Actions

* inspect issue
* resolve issue
* request retry

---

## System Actions

* preserve state
* identify blockers
* generate recommendations

---

## Output

Resolved workflow state.

---

# 5.14 Cross-Flow Visibility Requirements

Every operational flow must expose:

### Current State

```text id="mnr5uv"
Where am I?
```

---

### Next Action

```text id="f1ibpz"
What happens next?
```

---

### Blocking Conditions

```text id="o0r2k0"
What is preventing progress?
```

---

### Scope

```text id="k7xv5g"
What is affected?
```

---

### History

```text id="6o3qmr"
How did we get here?
```

---

# 5.15 Operational Flow Invariants

---

## FLOW-I1

All consequential actions must be visible.

---

## FLOW-I2

Validation must occur before execution-sensitive transitions.

---

## FLOW-I3

Architectural mutations must expose impact before approval.

---

## FLOW-I4

Execution outputs must reconcile into canonical state.

---

## FLOW-I5

Lineage updates must occur after reconciliation.

---

## FLOW-I6

Users must never lose visibility into workflow status.

---

## FLOW-I7

All blocked states must expose actionable resolution paths.

---

## FLOW-I8

Repository ingestion must reach canonical validation before activation.

---

## FLOW-I9

Operational flows must reinforce software evolution rather than software regeneration.

---

## FLOW-I10

Every flow must preserve architectural continuity.

---

# UI/UX Specification — Section 6

# Visibility Architecture

---

# 6.1 Purpose

Visibility Architecture defines how sembl communicates system state to users.

It governs:

* status visibility
* progress visibility
* operational visibility
* audit visibility
* lineage visibility
* notification behavior
* historical visibility

The objective is not merely to inform users.

The objective is to make software evolution understandable.

Users should always be able to answer:

```text
What is happening?

Why is it happening?

What changed?

What requires my attention?

What happens next?
```

without needing to inspect implementation details.

---

# 6.2 Visibility Philosophy

Visibility is a core product capability.

In traditional development systems:

```text
Code → Build → Result
```

Visibility is often fragmented.

In sembl:

```text
Intent
→ Specification
→ Validation
→ Approval
→ Execution
→ Reconciliation
→ Deployment
→ Iteration
```

Every stage must remain observable.

The system should never feel opaque.

Users should never feel:

```text
The AI is doing something.
```

Users should instead feel:

```text
The system is progressing through a visible software evolution process.
```

---

# 6.3 Visibility Layers

Visibility exists across five layers.

```text
Project Visibility
        ↓
Workflow Visibility
        ↓
Change Visibility
        ↓
Architectural Visibility
        ↓
Historical Visibility
```

Each layer serves a distinct purpose.

---

# 6.4 Project Visibility Layer

Project Visibility provides immediate orientation.

It answers:

```text
What is the current state of this project?
```

---

## Visible Elements

Every project must expose:

### Lifecycle State

Examples:

```text
Draft
Ready For Execution
Executing
Reconciling
Deploying
Active
Escalated
```

---

### Current Branch

Examples:

```text
Main
Feature Branch
Experiment Branch
```

---

### Current Version

Latest canonical version.

---

### Execution Status

Examples:

```text
Idle
Queued
Running
Completed
Failed
```

---

### Validation Status

Examples:

```text
Passed
Warning
Failed
```

---

### Approval Status

Examples:

```text
No Approvals Required
Awaiting Approval
Approved
Rejected
```

---

### Deployment Status

Examples:

```text
Not Deployed
Deploying
Healthy
Failed
```

---

## Visibility Rule

Project status must be understandable within seconds of entering the project.

---

# 6.5 Workflow Visibility Layer

Workflow Visibility explains active operational progress.

It answers:

```text
What is currently happening?
```

---

## Visible Workflow States

Examples:

```text
Generating Specifications

Validating Requirements

Awaiting Approval

Executing Build

Reconciling Changes

Deploying System

Analyzing Repository
```

---

## Required Information

Every workflow must expose:

### Current Stage

### Previous Stage

### Next Stage

### Blocking Conditions

### Estimated Completion State

Not necessarily time.

But expected outcome.

---

## Visibility Rule

Users should always understand where they are within a workflow.

---

# 6.6 Change Visibility Layer

Change Visibility explains software evolution.

It answers:

```text
What changed?
```

---

## Visible Change Types

### Specification Changes

Examples:

* requirement added
* requirement removed
* requirement modified

---

### Architectural Changes

Examples:

* entity added
* entity removed
* interface modified
* dependency modified

---

### Behavioral Changes

Examples:

* workflow updated
* validation updated

---

### Deployment Changes

Examples:

* deployment promoted
* deployment rolled back

---

## Required Information

Every change must expose:

### Change Summary

### Impact Scope

### Affected Structures

### Author

### Timestamp

### Lineage Relationship

---

## Visibility Rule

Users should never need to infer what changed.

---

# 6.7 Architectural Visibility Layer

Architectural Visibility supports deeper inspection.

It answers:

```text
How is the system structured?
```

---

## Visible Concepts

### Entities

### Interfaces

### Flows

### Dependencies

### Integrations

### Invariants

### Lineage

---

## Visibility Rule

Architectural information must be available.

Architectural information must not dominate workflows.

---

## Progressive Disclosure

Default:

```text
Requirements
→ Workflows
→ Outcomes
```

Expanded:

```text
Entities
→ Interfaces
→ Dependencies
→ Lineage
```

Advanced:

```text
Graph Relationships
→ Validation Structures
→ Topology
```

---

# 6.8 Historical Visibility Layer

Historical Visibility provides continuity.

It answers:

```text
How did the project reach its current state?
```

---

## Historical Objects

### Executions

### Deployments

### Approvals

### Mutations

### Branches

### Merges

### Reconciliations

### Validations

---

## Historical Capabilities

Users must be able to:

* inspect
* compare
* trace
* review

historical events.

---

## Visibility Rule

Historical state must never be lost.

---

# 6.9 Notification Architecture

Notifications communicate events requiring awareness or action.

Notifications are not the primary status system.

They are attention-routing mechanisms.

---

## Notification Categories

### Informational

Examples:

```text
Execution completed.

Deployment succeeded.

Validation passed.
```

---

### Action Required

Examples:

```text
Approval required.

Validation issue detected.

Merge review required.
```

---

### Warning

Examples:

```text
Execution partially failed.

Repository confidence low.

Dependency impact detected.
```

---

### Critical

Examples:

```text
Deployment failed.

Execution failed.

Invariant violation detected.

Escalation triggered.
```

---

# 6.10 Notification Visibility Rules

---

## NOTIF-I1

Notifications must always include context.

Bad:

```text
Validation failed.
```

Good:

```text
Validation failed for PRD changes affecting User entity.
```

---

## NOTIF-I2

Notifications must support navigation.

Users must be able to reach the affected object directly.

---

## NOTIF-I3

Notifications must never become the primary workflow.

The project remains the primary operational surface.

---

## NOTIF-I4

Critical events remain visible until acknowledged.

---

# 6.11 Activity Timeline Architecture

The Activity Timeline is the operational history surface.

It answers:

```text
What happened recently?
```

---

## Timeline Events

### Specification Events

### Validation Events

### Approval Events

### Execution Events

### Reconciliation Events

### Deployment Events

### Branch Events

### Merge Events

### Escalation Events

---

## Event Structure

Every event must expose:

### Event Type

### Summary

### Actor

### Timestamp

### Affected Scope

### Navigation Link

---

# 6.12 Audit Visibility Architecture

Audit Visibility provides governance-level traceability.

It answers:

```text
Who changed what?
```

---

## Auditable Events

### Specification Mutations

### Architectural Mutations

### Approval Decisions

### Deployments

### Merges

### Branch Creation

### Branch Deletion

### Escalations

---

## Required Audit Information

Every audit record must expose:

### Actor

### Action

### Before State

### After State

### Timestamp

### Reason

if available.

---

# 6.13 Lineage Visibility Architecture

Lineage Visibility is unique to sembl.

It answers:

```text
Why does this structure exist?
```

and

```text
What caused this change?
```

---

## Lineage Relationships

Examples:

```text
Requirement
→ Entity

Entity
→ Interface

Interface
→ Execution

Execution
→ Deployment

Deployment
→ Version
```

---

## Required Lineage Visibility

Users must be able to trace:

### Upstream Sources

### Downstream Effects

### Historical Evolution

### Branch Origins

### Merge Origins

---

## Visibility Rule

Lineage should explain evolution.

Not merely record history.

---

# 6.14 Global Status Model

The entire platform should communicate status using a consistent model.

---

## Healthy

No action required.

---

## Attention Required

User review recommended.

---

## Awaiting Action

User action required.

---

## Blocked

Progress impossible until resolution.

---

## Failed

Operation unsuccessful.

---

## Escalated

Automatic convergence unavailable.

Manual intervention required.

---

# 6.15 Visibility Architecture Invariants

---

## VIS-I1

Users must always understand current project state.

---

## VIS-I2

Users must always understand current workflow state.

---

## VIS-I3

Changes must always expose impact scope.

---

## VIS-I4

Validation outcomes must remain visible until resolved.

---

## VIS-I5

Approval requirements must remain visible until resolved.

---

## VIS-I6

Architectural visibility must support progressive disclosure.

---

## VIS-I7

Historical state must remain inspectable.

---

## VIS-I8

Audit history must be immutable.

---

## VIS-I9

Lineage visibility must connect causes and effects.

---

## VIS-I10

Notifications must provide context and navigability.

---

## VIS-I11

The system must never require users to infer status from absence of information.

Status must always be explicitly communicated.

---

## VIS-I12

Visibility should explain software evolution rather than expose implementation mechanics.

---

# UI/UX Specification — Section 7

# Screen Inventory

---

# 7.1 Purpose

The Screen Inventory defines the complete set of canonical user-facing screens in sembl v1.

This section serves as:

* screen registry
* navigation registry
* generation registry
* Figma generation source
* Stitch generation source
* HTML generation source
* interaction extraction source

No screen should exist outside this inventory without explicit specification updates.

This section defines:

* screen identity
* screen purpose
* ownership domain
* operational mode

Detailed behavior is defined later in Section 8.

---

# 7.2 Screen Classification Model

Screens are organized into six groups.

```text
Workspace
    ↓
Project
    ↓
Operational
    ↓
Governance
    ↓
Technical
    ↓
System
```

This structure mirrors the information architecture.

---

# 7.3 Workspace-Level Screens

These screens operate at workspace scope.

---

## WS-01 — Workspace Home

Purpose:

Primary landing experience.

Users see:

* projects
* active work
* approvals
* recent activity

Primary User:

All users

---

## WS-02 — Project Directory

Purpose:

Browse and manage projects.

Primary User:

All users

---

## WS-03 — Project Creation

Purpose:

Create new projects.

Primary User:

All users

---

## WS-04 — Approval Center

Purpose:

Workspace-wide approval queue.

Primary User:

Approvers

---

## WS-05 — Activity Center

Purpose:

Workspace-wide activity timeline.

Primary User:

All users

---

## WS-06 — Workspace Settings

Purpose:

Workspace administration.

Primary User:

Admins

---

# 7.4 Project-Level Screens

These screens define the primary project experience.

---

## PJ-01 — Project Overview

Purpose:

Project home screen.

Primary User:

All users

---

## PJ-02 — Specifications Workspace

Purpose:

Primary specification management surface.

Primary User:

All users

---

## PJ-03 — Execution Center

Purpose:

Execution monitoring and management.

Primary User:

All users

---

## PJ-04 — Changes Center

Purpose:

Software evolution visibility.

Primary User:

All users

---

## PJ-05 — Branches Center

Purpose:

Branch lifecycle management.

Primary User:

All users

---

## PJ-06 — Deployments Center

Purpose:

Deployment visibility and control.

Primary User:

All users

---

## PJ-07 — Project Activity

Purpose:

Project-specific operational history.

Primary User:

All users

---

## PJ-08 — Graph Explorer

Purpose:

Architectural inspection.

Primary User:

Technical users

---

# 7.5 Specification Screens

These screens exist inside the Specifications Workspace.

---

## SPEC-01 — Specification Dashboard

Purpose:

Specification overview and health.

---

## SPEC-02 — Document Editor

Purpose:

Document editing and review.

Supports:

* PDD
* PRD
* NFR
* UI/UX
* Architecture Docs

---

## SPEC-03 — Specification Validation Center

Purpose:

Specification validation visibility.

---

## SPEC-04 — Dependency Explorer

Purpose:

Specification relationships.

---

## SPEC-05 — Assumption Review Center

Purpose:

Review inferred assumptions and ambiguities.

---

## SPEC-06 — Specification History

Purpose:

Document evolution visibility.

---

# 7.6 Repository Ingestion Screens

---

## REPO-01 — Repository Connection

Purpose:

Connect repository source.

---

## REPO-02 — Repository Analysis

Purpose:

Display ingestion progress.

---

## REPO-03 — Reconstruction Review

Purpose:

Review inferred structures.

---

## REPO-04 — Confidence Resolution Center

Purpose:

Resolve low-confidence interpretations.

---

## REPO-05 — Repository Validation

Purpose:

Validate reconstructed architecture.

---

## REPO-06 — Activation Review

Purpose:

Approve transition into active project state.

---

# 7.7 Execution Screens

---

## EXEC-01 — Execution Dashboard

Purpose:

Primary execution monitoring.

---

## EXEC-02 — Execution Details

Purpose:

Detailed execution visibility.

---

## EXEC-03 — Validation Review

Purpose:

Execution validation outcomes.

---

## EXEC-04 — Reconciliation Review

Purpose:

Execution reconciliation visibility.

---

## EXEC-05 — Execution History

Purpose:

Historical execution review.

---

# 7.8 Change and Iteration Screens

---

## CHANGE-01 — Change Request Center

Purpose:

Create and manage changes.

---

## CHANGE-02 — Scope Analysis Review

Purpose:

Impact and scope visibility.

---

## CHANGE-03 — Change Diff Viewer

Purpose:

Review proposed changes.

---

## CHANGE-04 — Version History

Purpose:

Historical software evolution.

---

## CHANGE-05 — Lineage Explorer

Purpose:

Change causality visibility.

---

# 7.9 Branching Screens

---

## BRANCH-01 — Branch Dashboard

Purpose:

Branch management home.

---

## BRANCH-02 — Branch Creation

Purpose:

Create branch.

---

## BRANCH-03 — Branch Comparison

Purpose:

Compare branch states.

---

## BRANCH-04 — Merge Review

Purpose:

Review merge candidate.

---

## BRANCH-05 — Conflict Resolution

Purpose:

Resolve merge conflicts.

---

# 7.10 Approval Screens

---

## APPROVAL-01 — Approval Review

Purpose:

Review approval request.

---

## APPROVAL-02 — Architectural Impact Review

Purpose:

Review architectural mutations.

---

## APPROVAL-03 — Execution Approval Review

Purpose:

Review execution readiness.

---

## APPROVAL-04 — Merge Approval Review

Purpose:

Review merge impact.

---

# 7.11 Deployment Screens

---

## DEPLOY-01 — Deployment Dashboard

Purpose:

Deployment management home.

---

## DEPLOY-02 — Deployment Details

Purpose:

Deployment visibility.

---

## DEPLOY-03 — Environment Review

Purpose:

Deployment environment inspection.

---

## DEPLOY-04 — Rollback Review

Purpose:

Rollback management.

---

## DEPLOY-05 — Deployment History

Purpose:

Deployment audit trail.

---

# 7.12 Technical Inspection Screens

These remain secondary and progressively disclosed.

---

## TECH-01 — Entity Explorer

Purpose:

Inspect entities.

---

## TECH-02 — Interface Explorer

Purpose:

Inspect interfaces.

---

## TECH-03 — Flow Explorer

Purpose:

Inspect flows.

---

## TECH-04 — Dependency Explorer

Purpose:

Inspect dependencies.

---

## TECH-05 — Lineage Explorer

Purpose:

Inspect architectural evolution.

---

## TECH-06 — Validation Explorer

Purpose:

Inspect validation structures.

---

# 7.13 Visibility Screens

---

## VIS-01 — Notification Center

Purpose:

Central notification management.

---

## VIS-02 — Activity Timeline

Purpose:

Unified activity visibility.

---

## VIS-03 — Audit Explorer

Purpose:

Governance and traceability.

---

## VIS-04 — Status Center

Purpose:

Cross-project operational status.

---

# 7.14 System and Exception Screens

---

## SYS-01 — Escalation Center

Purpose:

Resolve blocked workflows.

---

## SYS-02 — Error Resolution Center

Purpose:

Investigate failures.

---

## SYS-03 — Access Management

Purpose:

Permission visibility.

---

## SYS-04 — Integration Management

Purpose:

External system integrations.

---

# 7.15 Screen Inventory Summary

Total canonical screen groups:

```text
Workspace Screens
Project Screens
Specification Screens
Repository Screens
Execution Screens
Change Screens
Branch Screens
Approval Screens
Deployment Screens
Technical Screens
Visibility Screens
System Screens
```

Total canonical screen count:

```text
Workspace:      6
Project:        8
Specification:  6
Repository:     6
Execution:      5
Changes:        5
Branches:       5
Approvals:      4
Deployments:    5
Technical:      6
Visibility:     4
System:         4
------------------
Total:         64
```

---

# 7.16 Screen Inventory Constraints

---

## SCREEN-I1

Every user-visible workflow must map to at least one canonical screen.

---

## SCREEN-I2

Every screen must belong to exactly one primary domain.

---

## SCREEN-I3

Project-centric workflows take precedence over technical inspection workflows.

---

## SCREEN-I4

Technical inspection screens remain secondary and progressively disclosed.

---

## SCREEN-I5

Specification authoring screens remain primary throughout the product.

---

## SCREEN-I6

No screen may expose raw graph complexity as its primary purpose.

---

## SCREEN-I7

All screens must support lineage-aware navigation where applicable.

---

## SCREEN-I8

Every screen must expose a clear relationship to project state.

---

# 7.17 Screen Architecture Governance

This section defines how the Screen Inventory shall be interpreted and implemented.

The Screen Inventory is a capability registry.

It is not a direct representation of the final application surface structure.

The purpose of this section is to establish authoritative interpretation rules for screen generation, interface generation, Figma generation, Stitch generation, HTML generation, and future implementation activities.

---

## SCREEN-G1 — Capability Coverage Authority

The Screen Inventory is the authoritative registry of user-visible capabilities.

Every workflow, responsibility, interaction, review surface, approval flow, validation flow, reconciliation flow, and visibility requirement defined by the platform must map to at least one inventory item.

The Screen Inventory exists to ensure capability completeness.

No capability may be implemented outside the inventory without explicit specification updates.

---

## SCREEN-G2 — Implementation Authority

The Detailed Screen Specifications defined in Section 8 are the authoritative implementation model.

Inventory items may be implemented as:

* primary screens
* subpages
* tabs
* panels
* drawers
* inspectors
* modals

provided capability coverage is preserved.

The Detailed Screen Specifications determine the actual application structure.

---

## SCREEN-G3 — Generation Authority

Generation systems shall interpret:

* Section 7 as the capability registry
* Section 8 as the implementation architecture
* Secondary Interaction Surfaces as interaction placement rules

When ambiguity exists, Section 8 takes precedence over Section 7 for interface generation.

---

## SCREEN-G4 — Surface Consolidation Principle

Capabilities should be implemented using the smallest viable interaction surface.

Preferred hierarchy:

```text
Primary Screen
    ↓
Subpage
    ↓
Tab
    ↓
Panel
    ↓
Drawer
    ↓
Inspector
    ↓
Modal
````

Capabilities must not automatically become standalone screens.

The existence of a capability does not imply the existence of a primary navigation destination.

---

## SCREEN-G5 — Capability Normalization Principle

The Screen Inventory defines everything the system must support.

The Detailed Screen Specifications define how those capabilities are surfaced.

Multiple inventory items may be implemented within a single workspace when:

* workflow clarity is preserved
* discoverability is preserved
* visibility requirements are preserved

Capability consolidation is preferred over navigation expansion.

---

## SCREEN-G6 — Internal Systems Visibility Principle

Internal platform systems are explanatory constructs rather than primary user workflows.

The following concepts should rarely become primary navigation destinations:

* validation
* reconciliation
* lineage
* dependencies
* graph topology
* execution topology

These concepts should generally appear as:

* contextual tabs
* inspectors
* review surfaces
* impact panels
* supporting workflows

attached to user goals and operational workflows.

---

## SCREEN-G7 — One Question Per Primary Screen Principle

Every primary screen must answer one dominant user question.

Examples:

Project Overview

> What is happening in this project?

Specifications Workspace

> What are we building?

Execution Workspace

> What is being built right now?

Changes Workspace

> How is the software evolving?

Deployments Workspace

> What is currently running?

If a screen answers multiple unrelated questions it should be decomposed.

If multiple screens answer the same question they should be consolidated.

---

## SCREEN-G8 — Navigation Compression Principle

The preferred implementation structure for sembl v1 is:

```text
Workspace
    ↓
Project
        ↓
Overview
Specifications
Execution
Changes
Deployments
```

with:

* branches
* validation
* reconciliation
* lineage
* graph inspection
* dependency analysis

appearing contextually where required.

The system should minimize navigation depth while maximizing contextual visibility.

---

## SCREEN-G9 — Specification Primacy Preservation

The screen architecture must preserve the core user experience of sembl:

```text
Intent
    ↓
Specifications
    ↓
Validation
    ↓
Approval
    ↓
Execution
    ↓
Deployment
    ↓
Iteration
```

Users should experience software evolving through specifications.

Users should not experience the platform as:

* a graph database interface
* an orchestration dashboard
* an agent management system
* a task execution system

Screen architecture decisions must always reinforce specification primacy over implementation visibility.

---

## SCREEN-G10 — Final Architectural Invariant

The final interface architecture of sembl shall optimize for:

* specification-centric workflows
* progressive complexity disclosure
* architectural continuity
* reconciliation visibility
* lineage visibility
* execution transparency
* minimal navigation complexity

The product must feel like:

"building software through evolving specifications"

and never like:

"managing the machinery that builds software."

---

# UI/UX Specification — Section 8

# Detailed Screen Specifications

---

# 8.1 Purpose

This section transforms the capability inventory into a coherent product architecture.

The objective is not to specify every possible page.

The objective is to define the minimum set of primary interaction surfaces required to support all workflows defined in previous sections.

This section becomes the primary source for:

* Figma generation
* Stitch generation
* HTML generation
* interaction modeling
* screen implementation

---

# 8.2 Canonical Screen Hierarchy

After normalization, sembl v1 consists of:

## Workspace Screens

```text
WS-01 Workspace Home
WS-02 Approval Center
WS-03 Activity Center
WS-04 Workspace Settings
```

---

## Project Screens

```text
PJ-01 Project Overview
PJ-02 Specifications Workspace
PJ-03 Execution Workspace
PJ-04 Changes Workspace
PJ-05 Deployments Workspace
```

---

## Workflow Screens

```text
WF-01 Repository Ingestion
WF-02 Approval Review
WF-03 Conflict Resolution
WF-04 Escalation Center
```

---

Total Primary Screens:

```text
13
```

Everything else becomes:

* tabs
* panels
* drawers
* inspectors
* review surfaces

inside these primary workspaces.

The 64 inventory entries remain authoritative for capability coverage.

The 13-screen hierarchy remains authoritative for implementation, navigation, and interaction architecture.

---

# 8.3 WS-01 — Workspace Home

---

## Purpose

Answer:

```text
What requires attention across my workspace?
```

---

## Entry Points

* Login
* Workspace selection
* Navigation

---

## Visible Information

### Projects

* active projects
* recent projects
* project status

### Pending Approvals

### Recent Activity

### Active Executions

### Deployment Alerts

---

## Available Actions

* open project
* create project
* review approval
* inspect activity

---

## Navigation Destinations

```text
Project Overview
Approval Center
Activity Center
Settings
```

---

## State Transitions

```text
Project Selected
→ Project Overview

Approval Selected
→ Approval Review
```

---

# 8.4 WS-02 — Approval Center

---

## Purpose

Answer:

```text
What decisions require my approval?
```

---

## Visible Information

Grouped by:

### Execution Approvals

### Architectural Approvals

### Merge Approvals

---

## Available Actions

* review
* approve
* reject

---

## Supporting Surfaces

### Impact Panel

### Diff Viewer

### Lineage Panel

---

## Navigation

```text
Approval Review
Project Overview
```

---

# 8.5 WS-03 — Activity Center

---

## Purpose

Answer:

```text
What has happened recently?
```

---

## Visible Information

Unified timeline:

* executions
* deployments
* approvals
* changes
* merges
* escalations

---

## Available Actions

* inspect event
* navigate to project
* filter activity

---

# 8.6 PJ-01 — Project Overview

---

## Purpose

Answer:

```text
What is happening in this project?
```

This is the project home.

---

## Entry Points

* Workspace Home
* Project Directory
* Notifications

---

## Visible Information

### Project State

* lifecycle state
* branch
* version

### Specification Health

### Active Work

### Pending Approvals

### Recent Changes

### Deployment Status

### Validation Summary

---

## Available Actions

* continue work
* review changes
* start execution
* review approvals

---

## Embedded Surfaces

### Status Panel

### Validation Summary Panel

### Recent Activity Panel

### Deployment Summary Panel

---

## Navigation Destinations

```text
Specifications
Execution
Changes
Deployments
```

---

# 8.7 PJ-02 — Specifications Workspace

---

## Purpose

Answer:

```text
What are we building?
```

This is the primary authoring environment of sembl.

---

## Visible Information

### Specification Tree

Contains:

* PDD
* PRD
* NFR
* UI/UX
* Architecture
* API
* DB Schema

### Active Document

### Dependency Indicators

### Validation Indicators

### Assumption Indicators

---

## Primary Actions

* create
* edit
* review
* compare
* approve changes

---

## Embedded Tabs

### Documents

### Validation

### Dependencies

### Assumptions

### History

---

## Supporting Drawers

### Dependency Inspector

### Impact Inspector

### Lineage Inspector

---

## Navigation Destinations

```text
Execution
Changes
Overview
```

---

# 8.8 PJ-03 — Execution Workspace

---

## Purpose

Answer:

```text
What is being built right now?
```

---

## Visible Information

### Current Execution

### Progress

### Validation Status

### Reconciliation Status

### Deployment Status

### Execution History

---

## Primary Actions

* inspect progress
* inspect issues
* retry failed execution

Retry is permitted only when:

- execution is not in Escalated state
- retry limits have not been exhausted
- the failure condition is recoverable

Repeated unsuccessful retries must transition the execution into Escalated state.

Retry behavior must remain bounded and must not bypass escalation requirements.

---

## Embedded Tabs

### Progress

### Validation

### Reconciliation

### History

---

## Supporting Panels

### Execution Details

### Impact Summary

### Failure Analysis

---

## Navigation Destinations

```text
Changes
Deployments
Overview
```

---

# 8.9 PJ-04 — Changes Workspace

---

## Purpose

Answer:

```text
How is the software evolving?
```

This becomes the heart of Iteration Mode.

---

## Visible Information

### Requested Changes

### Active Branches

### Diffs

### Version History

### Lineage

### Merge Candidates

---

## Primary Actions

* create change
* create branch
* compare versions
* request merge

---

## Embedded Tabs

### Changes

### Branches

### Versions

### Lineage

---

## Supporting Panels

### Scope Analysis

### Impact Analysis

### Diff Viewer

### Merge Review

---

## Navigation Destinations

```text
Specifications
Execution
Deployments
```

---

# 8.10 PJ-05 — Deployments Workspace

---

## Purpose

Answer:

```text
What is currently running?
```

---

## Visible Information

### Active Deployments

### Deployment History

### Environment Status

### Rollbacks

---

## Primary Actions

* inspect deployment
* review history
* initiate rollback (if permitted)

---

## Embedded Tabs

### Active

### History

### Environments

### Rollbacks

---

## Supporting Panels

### Deployment Details

### Health Status

### Failure Analysis

---

## Navigation Destinations

```text
Overview
Execution
Changes
```

---

# 8.11 Workflow Screens

These are temporary workflow-specific surfaces.

They are not persistent project destinations.

---

## WF-01 Repository Ingestion

Answers:

```text
Did sembl understand my system correctly?
```

Stages:

```text
Connect
→ Analyze
→ Reconstruct
→ Review
→ Validate
→ Activate
```

---

## WF-02 Approval Review

Answers:

```text
Should this action proceed?
```

Contains:

* impact summary
* diff summary
* affected scope
* lineage impact

---

## WF-03 Conflict Resolution

Answers:

```text
How should competing changes be reconciled?
```

Contains:

* conflicting structures
* impact analysis
* resolution choices

---

## WF-04 Escalation Center

Answers:

```text
What is preventing progress?
```

Contains:

* root cause
* blocked workflows
* resolution actions

---

# UI/UX Specification — Section 8 (Part 2)

# Secondary Interaction Surfaces

---

# 8.12 Purpose

Primary screens answer major user questions.

Secondary interaction surfaces provide depth without increasing navigation complexity.

Their purpose is to expose:

* validation
* reconciliation
* lineage
* dependencies
* architectural visibility
* graph visibility
* impact analysis

without creating additional primary destinations.

This section defines how advanced functionality is integrated into the product.

---

# 8.13 Secondary Surface Hierarchy

All non-primary interactions should use the following hierarchy.

```text id="nsmn1i"
Primary Screen
    ↓
Tab
    ↓
Panel
    ↓
Drawer
    ↓
Modal
```

The lower the level:

* the more contextual the information
* the less persistent the interaction

---

# 8.14 Tabs

Tabs represent closely related views within the same user question.

Tabs should never represent separate workflows.

---

## Tab Principles

Good:

```text id="g6c9tx"
Execution
    ├ Progress
    ├ Validation
    ├ Reconciliation
    └ History
```

Bad:

```text id="w8lx2g"
Execution
Validation
Reconciliation
History
```

as separate navigation destinations.

---

## Global Tab Rules

Tabs should:

* answer the same question
* share context
* preserve state
* avoid navigation resets

---

# 8.15 Panels

Panels expose supporting information while preserving workflow continuity.

Panels should remain visible alongside primary content.

---

## Panel Use Cases

### Status Panel

Displays:

* lifecycle state
* execution state
* deployment state

---

### Validation Summary Panel

Displays:

* validation status
* issue counts
* severity breakdown

---

### Activity Panel

Displays:

* recent events
* approvals
* deployments

---

### Dependency Summary Panel

Displays:

* impacted structures
* upstream dependencies
* downstream dependencies

---

## Panel Rule

Panels summarize.

Panels do not become workspaces.

---

# 8.16 Drawers

Drawers expose detailed contextual information without navigation.

Drawers should be used heavily throughout sembl.

They preserve continuity while allowing deep inspection.

---

## Dependency Inspector Drawer

Purpose:

Inspect dependency relationships.

---

### Visible Information

* upstream dependencies
* downstream dependencies
* affected scope

---

### Entry Points

* specifications
* changes
* validation issues

---

# Architectural Impact Drawer

Purpose:

Inspect architectural consequences.

---

### Visible Information

* affected entities
* affected interfaces
* affected flows
* dependency impact

---

### Entry Points

* approvals
* changes
* validation

---

# Lineage Drawer

Purpose:

Explain causality.

---

### Visible Information

```text id="3dbpzs"
Why does this exist?

What created it?

What changed it?

What depends on it?
```

---

### Entry Points

Available from:

* entities
* interfaces
* changes
* approvals

---

# Validation Drawer

Purpose:

Inspect validation outcomes.

---

### Visible Information

* violation
* severity
* affected scope
* remediation path

---

### Entry Points

Anywhere validation appears.

---

# Reconciliation Drawer

Purpose:

Explain canonical updates.

---

### Visible Information

* changes applied
* graph updates
* lineage updates
* affected structures

---

### Entry Points

Execution
Changes
Merge Review

---

# 8.17 Inspectors

Inspectors provide deep technical visibility.

They remain optional.

Most users should rarely need them.

---

## Entity Inspector

Displays:

* fields
* relationships
* lineage
* dependencies

---

## Interface Inspector

Displays:

* inputs
* outputs
* contracts
* integrations

---

## Flow Inspector

Displays:

* participating structures
* execution relationships
* dependencies

---

## Dependency Inspector

Displays:

* dependency graph
* dependency impact

---

## Validation Inspector

Displays:

* rule evaluation
* violation history
* affected structures

---

## Lineage Inspector

Displays:

* evolution history
* mutation chain
* reconciliation chain

---

# Inspector Rule

Inspectors explain architecture.

They do not become architecture editing tools.

---

# 8.18 Graph Visibility Architecture

Graph visibility is one of the most important UX decisions in sembl.

The graph is canonical.

The graph is not primary.

---

## Default User Experience

Users interact with:

* requirements
* specifications
* workflows
* changes

Graph structures remain hidden.

---

## Intermediate Visibility

Users may inspect:

* entities
* interfaces
* flows

through contextual inspection.

---

## Advanced Visibility

Technical users may access Graph Explorer.

Graph Explorer should expose:

### Entity Relationships

### Interface Relationships

### Flow Relationships

### Lineage Relationships

### Dependency Relationships

---

## Graph Editing Rule

Graph Explorer is primarily read-oriented.

Graph mutation continues through:

* specification evolution
* approved change workflows
* repository reconstruction workflows

Graph visibility exists to explain:

* structure
* lineage
* dependencies
* evolution

Graph visibility must remain accessible for architectural inspection without becoming either:

* the primary authoring experience
* a hidden implementation detail

---

# 8.19 Review Surfaces

Review Surfaces support decision making.

They appear before consequential actions.

---

## Execution Review

Appears before initial execution.

Contains:

* specification summary
* validation summary
* assumptions
* execution targets

---

## Architectural Mutation Review

Appears before architectural changes.

Contains:

* affected structures
* dependency impact
* lineage impact
* execution impact

---

## Merge Review

Appears before merge approval.

Contains:

* branch diff
* architectural diff
* validation status
* reconciliation summary

---

## Repository Activation Review

Appears before repository activation.

Contains:

* confidence summary
* unresolved ambiguities
* inferred architecture

---

# 8.20 Modals

Modals should be reserved for short-lived actions.

Not workflows.

---

## Appropriate Modal Use

### Create Branch

### Delete Branch

### Confirm Rollback

### Confirm Approval

### Resolve Minor Conflict

---

## Inappropriate Modal Use

### Specification Editing

### Execution Monitoring

### Validation Review

### Reconciliation Review

### Graph Inspection

These require larger surfaces.

---

# 8.21 Universal Context Bar

Every primary project screen should expose a shared context bar.

This becomes a core product element.

---

## Visible Information

### Project

### Branch

### Version

### Lifecycle State

### Validation State

### Deployment State

### Approval State

---

## Purpose

Allow users to immediately answer:

```text id="5cxikn"
Where am I?

What state is the project in?

Is anything blocked?
```

without navigation.

---

# 8.22 Universal Impact Pattern

Impact visibility should be standardized.

Whenever a user encounters:

* changes
* approvals
* merges
* validation failures
* reconciliation

the system should expose impact using the same structure.

---

## Impact Structure

### Summary

What changed?

---

### Scope

What is affected?

---

### Architectural Impact

What structures change?

---

### Operational Impact

What workflows change?

---

### Deployment Impact

What runtime behavior changes?

---

### Lineage Impact

What evolution path changes?

---

# 8.23 Universal Traceability Pattern

Every major object should support tracing.

Supported objects:

* requirements
* entities
* interfaces
* flows
* executions
* deployments

---

## Trace Directions

### Upstream

```text id="fhg7ee"
What caused this?
```

---

### Downstream

```text id="5k1pqa"
What depends on this?
```

---

### Historical

```text id="ztlf5o"
How did this evolve?
```

---

This becomes the foundation of lineage visibility.

---

# 8.24 Secondary Surface Invariants

---

## SURF-I1

Capabilities should be embedded whenever possible.

---

## SURF-I2

Technical visibility should be contextual.

---

## SURF-I3

Validation should primarily appear within workflows rather than as a separate destination.

---

## SURF-I4

Reconciliation should primarily appear within workflows rather than as a separate destination.

---

## SURF-I5

Graph visibility should be inspection-oriented.

---

## SURF-I6

Lineage should be accessible from any major object.

---

## SURF-I7

Impact visibility should use a consistent structure across the platform.

---

## SURF-I8

Users should not navigate away from workflows merely to understand supporting information.

---

## SURF-I9

Inspectors explain architecture.

Specifications modify architecture.

---

## SURF-I10

The system should minimize navigation depth while maximizing information availability.

---

# UI/UX Specification — Section 9

# State Architecture

---

# 9.1 Purpose

State Architecture defines how sembl represents, communicates, and transitions between states.

This section governs:

* lifecycle states
* workflow states
* screen states
* object states
* loading states
* empty states
* blocked states
* failure states
* recovery states

The purpose of State Architecture is not merely operational correctness.

Its purpose is to create continuous user trust.

Users should never need to guess:

```text id="z0pk3m"
What is happening?

What state am I in?

What happens next?

Can I safely proceed?
```

State should always be explicit.

---

# 9.2 State Philosophy

State is a first-class product concept.

In sembl:

* software evolves through state
* specifications evolve through state
* execution progresses through state
* architecture evolves through state

The platform should communicate state continuously.

Absence of state visibility is considered a UX failure.

---

# 9.3 State Hierarchy

States exist at five levels.

```text id="e3d9yk"
Workspace State
        ↓
Project State
        ↓
Workflow State
        ↓
Object State
        ↓
UI State
```

Each layer inherits context from the layer above.

---

# 9.4 Global State Categories

All states should belong to one of six canonical categories.

---

## Healthy

Meaning:

No action required.

Progress may continue normally.

Examples:

```text id="sm2s9m"
Active

Validated

Deployed

Merged
```

---

## Informational

Meaning:

State change occurred.

Awareness useful.

Action not required.

Examples:

```text id="zh0l2u"
Execution Completed

Deployment Completed

Branch Created
```

---

## Attention Required

Meaning:

Review recommended.

Progress still possible.

Examples:

```text id="hf3hkn"
Validation Warning

Low Repository Confidence

Dependency Change Detected
```

---

## Awaiting Action

Meaning:

User action required.

Progress paused until action occurs.

Examples:

```text id="ld72y7"
Awaiting Approval

Awaiting Review

Awaiting Merge Decision
```

---

## Blocked

Meaning:

Progress impossible.

Resolution required.

Examples:

```text id="h11czm"
Validation Failed

Merge Conflict

Dependency Conflict
```

---

## Escalated

Meaning:

Automatic convergence unavailable.

Manual intervention required.

Examples:

```text id="wr7pl8"
Repeated Validation Failure

Reconciliation Failure

Invariant Conflict
```

---

# 9.5 Project Lifecycle States

Project state is the highest visibility state in the system.

Every project must have exactly one active lifecycle state.

---

## Draft

Meaning:

Project definition in progress.

Allowed Actions:

* edit specifications
* validate

Blocked Actions:

* execute
* deploy

---

## Ready For Execution

Meaning:

Specifications complete.

Allowed Actions:

* review
* approve execution

Blocked Actions:

* deploy

---

## Awaiting Approval

Meaning:

Execution or mutation approval required.

Allowed Actions:

* review
* approve
* reject

Blocked Actions:

* execution
* merge
* deployment

depending on approval type.

---

## Executing

Meaning:

Implementation generation active.

Allowed Actions:

* monitor
* inspect

Blocked Actions:

* conflicting mutations

---

## Reconciling

Meaning:

Canonical state update active.

Allowed Actions:

* inspect

Blocked Actions:

* conflicting mutations
* deployment

---

## Deploying

Meaning:

Deployment workflow active.

Allowed Actions:

* monitor

Blocked Actions:

* deployment mutation

---

## Active

Meaning:

Normal operating state.

Allowed Actions:

* iterate
* deploy
* branch
* review

---

## Escalated

Meaning:

Manual intervention required.

Allowed Actions:

* resolve
* retry

Blocked Actions:

* automatic progression

---

# 9.6 Workflow States

Every operational workflow has a state model.

---

## Not Started

Workflow not initiated.

---

## In Progress

Workflow actively executing.

---

## Waiting

Workflow paused pending dependency.

---

## Awaiting User Action

Workflow blocked on user input.

---

## Completed

Workflow successfully completed.

---

## Failed

Workflow unsuccessful.

---

## Escalated

Workflow requires intervention.

---

# 9.7 Validation States

Validation is one of the most visible systems in sembl.

---

## Passed

Meaning:

No violations.

---

## Passed With Warnings

Meaning:

Violations not execution-blocking.

---

## Failed

Meaning:

Blocking violations exist.

---

## Under Review

Meaning:

User reviewing validation outcomes.

---

## Revalidating

Meaning:

Validation rerunning after modifications.

---

# Validation Transition Model

Passed
   │
   └──────────────┐
                  ↓
           Revalidating
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
     Passed   Passed With   Failed
               Warnings

---

# 9.8 Approval States

Applies to:

* execution approval
* mutation approval
* merge approval

---

## Pending

Approval required.

---

## Under Review

Reviewer evaluating.

---

## Approved

Approved for progression.

---

## Rejected

Progress denied.

---

# Approval Transition Model

```text id="azs6qj"
Pending
     ↓
Under Review
     ↓
Approved
```

or

```text id="vth79f"
Pending
     ↓
Under Review
     ↓
Rejected
```

---

# 9.9 Execution States

---

## Queued

Execution scheduled.

---

## Preparing

Context generation active.

---

## Running

Execution active.

---

## Validating

Output validation active.

---

## Reconciling

Canonical update active.

---

## Completed

Execution successful.

---

## Failed

Execution unsuccessful.

---

## Escalated

Manual intervention required.

---

# Execution Transition Model

```text id="pmwmq8"
Queued
→ Preparing
→ Running
→ Validating
→ Reconciling
→ Completed
```

---

# 9.10 Deployment States

---

## Not Deployed

No deployment exists.

---

## Deploying

Deployment active.

---

## Healthy

Deployment successful.

---

## Degraded

Persistent degradation or repeated degradation events may trigger escalation.
Deployment functional but impaired.

---

## Failed

Deployment unsuccessful.

---

## Rolling Back

Rollback active.

---

## Rolled Back

Rollback completed.

---

# 9.11 Branch States

---

## Active

Branch available.

---

## Diverged

Significant differences exist.

---

## Merge Pending

Ready for merge review.

---

## Merged

Integrated into canonical state.

---

## Rejected

Merge denied.

---

## Archived

Historical branch.

---

# 9.12 Repository Ingestion States

---

## Connected

Repository linked.

---

## Analyzing

Analysis active.

---

## Reconstructing

Semantic reconstruction active.

---

## Confidence Review Required

Low-confidence structures detected.

---

## Validating

Validation active.

---

## Ready For Activation

Review complete.

---

## Activated

Project active.

---

## Failed

Ingestion unsuccessful.

---

# 9.13 Empty States

Empty states should guide users toward progress.

Empty states are instructional surfaces.

---

# Empty State Principles

Every empty state should answer:

```text id="sfpvaw"
Why is this empty?

What can I do next?
```

---

## No Projects

Display:

* explanation
* create project action

---

## No Specifications

Display:

* specification creation entry point

---

## No Executions

Display:

* execution readiness guidance

---

## No Deployments

Display:

* deployment lifecycle explanation

---

## No Branches

Display:

* branching explanation
* create branch action

---

## No Activity

Display:

* activity visibility explanation

---

# Empty State Rule

Empty states should educate.

Never simply display absence.

---

# 9.14 Loading States

Loading states communicate progress.

They should reflect actual system activity.

---

## Lightweight Loading

Examples:

* page loading
* navigation

Display:

* immediate progress indicator

---

## Workflow Loading

Examples:

* validation
* repository analysis
* reconciliation

Display:

* current stage
* expected outcome

---

## Long Running Loading

Examples:

* execution
* deployment
* repository reconstruction

Display:

### Current Stage

### Previous Stage

### Next Stage

### Scope

### Progress Summary

---

# Loading Rule

Long-running operations must never appear opaque.

---

# 9.15 Failure States

Failure states must explain:

```text id="aevv7w"
What failed?

Why did it fail?

What can be done?
```

---

# Failure Structure

Every failure should expose:

### Summary

### Root Cause

### Impact

### Resolution Path

### Retry Option

if available.

---

# Common Failure States

### Validation Failure

### Execution Failure

### Deployment Failure

### Merge Failure

### Repository Failure

### Reconciliation Failure

### Permission Failure

---

# Failure Rule

Failure visibility is mandatory.

Generic error messages are prohibited.

---

# 9.16 Blocked States

Blocked states differ from failures.

A blocked state is awaiting resolution.

---

# Examples

### Awaiting Approval

### Merge Conflict

### Missing Information

### Unresolved Ambiguity

### Dependency Conflict

---

# Required Visibility

### Blocking Cause

### Responsible Party

### Resolution Action

### Affected Scope

---

# 9.17 Recovery States

Recovery states communicate restoration.

---

## Retrying

Operation rerunning.

---

## Recovering

System correcting failure.

---

## Revalidating

Validation re-executing.

---

## Rebuilding

Execution restarting.

---

## Rolling Back

Deployment reverting.

---

# Recovery Rule

Recovery should be visible.

Users should never wonder whether remediation is occurring.

---

# 9.18 State Visibility Rules

---

## STATE-I1

Every major object must expose current state.

---

## STATE-I2

Every workflow must expose next state.

---

## STATE-I3

Blocked states must expose resolution paths.

---

## STATE-I4

Failure states must expose root causes.

---

## STATE-I5

Long-running states must expose progress.

---

## STATE-I6

State transitions must be visible.

---

## STATE-I7

Users must never infer state through absence of information.

---

## STATE-I8

Recovery states must be visible.

---

## STATE-I9

Project lifecycle state remains the dominant state indicator.

---

## STATE-I10

State communication should prioritize clarity over implementation detail.

---

# 9.19 State Architecture Invariants

---

## SA-I1

Every project always has a visible lifecycle state.

---

## SA-I2

Every workflow always has a visible operational state.

---

## SA-I3

Every consequential action produces observable state transitions.

---

## SA-I4

Validation, approval, execution, reconciliation, and deployment states remain independently visible.

---

## SA-I5

Blocked progression must always be explainable.

---

## SA-I6

Failure states must be actionable.

---

## SA-I7

Recovery processes must be observable.

---

## SA-I8

State architecture must reinforce user trust through transparency.

---

# UI/UX Specification — Section 10

# Responsive and Accessibility Requirements

---

# 10.1 Purpose

This section defines the responsiveness and accessibility requirements for sembl v1.

The objective is not compliance.

The objective is ensuring that:

* core workflows remain usable
* state visibility remains preserved
* approvals remain actionable
* software evolution remains understandable

across devices and interaction methods.

All requirements in this section must preserve the interaction architecture defined throughout the specification.

---

# 10.2 Guiding Principle

Responsiveness and accessibility must adapt the interface.

They must not alter the mental model.

A user should experience the same project structure regardless of device.

The following concepts must remain consistent:

```text id="m7nbc4"
Workspace
→ Project
→ Specifications
→ Execution
→ Changes
→ Deployments
```

Only the presentation changes.

The architecture does not.

---

# 10.3 Device Strategy

sembl v1 is desktop-first.

This decision reflects the primary user activities:

* specification authoring
* architecture review
* change analysis
* repository ingestion
* approval review

These activities benefit significantly from large-screen environments.

---

# 10.4 Desktop Experience

Desktop is the canonical experience.

All workflows must be fully supported.

---

## Supported Activities

### Specification Authoring

### Validation Review

### Repository Ingestion

### Change Analysis

### Branch Management

### Merge Review

### Execution Monitoring

### Deployment Management

### Graph Inspection

### Lineage Inspection

---

## Desktop Layout Principle

Desktop should maximize simultaneous context visibility.

Users should be able to view:

```text id="g9h8s3"
Primary Content
+
Context
+
Impact
+
Status
```

without excessive navigation.

---

## Recommended Pattern

```text id="6vg3gc"
Navigation
      +
Content Workspace
      +
Context Panel
```

This aligns with the inspection-heavy nature of sembl.

---

# 10.5 Tablet Experience

Tablet supports review-oriented workflows.

It is not the primary authoring environment.

---

## Supported Activities

### Specification Review

### Approval Review

### Execution Monitoring

### Validation Review

### Deployment Review

### Change Review

### Activity Review

---

## Limited Activities

### Large Specification Editing

### Repository Ingestion

### Deep Graph Inspection

### Complex Merge Resolution

---

## Layout Principle

Tablet prioritizes:

```text id="phh1r5"
Content
→ Context
```

rather than simultaneous visibility.

Context panels may collapse into drawers.

---

# 10.6 Mobile Experience

Mobile is a monitoring and decision surface.

Not a primary construction surface.

---

## Primary Goals

Allow users to answer:

```text id="4gmx2g"
What is happening?

What requires my attention?

Can I approve this?

Did something fail?
```

---

## Supported Activities

### Approval Review

### Approval Decision

### Activity Review

### Project Status Review

### Execution Monitoring

### Deployment Monitoring

### Notification Management

### Escalation Awareness

---

## Limited Activities

### Minor Specification Edits

### Commenting

### Quick Reviews

---

## Unsupported Activities

### Repository Ingestion

### Large Specification Authoring

### Merge Conflict Resolution

### Deep Architectural Inspection

### Complex Change Analysis

---

## Mobile Principle

Mobile should support:

```text id="0w7pxg"
Observe
Review
Approve
Respond
```

not:

```text id="7h3i5i"
Construct
Model
Reconcile
Architect
```

---

# 10.7 Responsive Navigation Rules

Navigation must compress without changing structure.

---

## Desktop

Displays:

```text id="sl3f3e"
Workspace Navigation
Project Navigation
Contextual Navigation
```

simultaneously.

---

## Tablet

Displays:

```text id="a2ujn9"
Workspace Navigation
Project Navigation
```

with contextual navigation collapsed.

---

## Mobile

Displays:

```text id="wyt0s4"
Workspace Navigation
Project Navigation
```

through progressive disclosure.

---

## Rule

Navigation hierarchy must remain recognizable across devices.

---

# 10.8 Responsive Visibility Rules

Visibility architecture must survive responsiveness.

The following information remains mandatory on all devices:

### Project State

### Approval State

### Execution State

### Deployment State

### Blocking Conditions

---

## Visibility Priority Order

If screen space becomes constrained:

```text id="3z0jmx"
State
→ Actions
→ Context
→ Historical Information
→ Deep Technical Information
```

Historical and technical information compress first.

State visibility never compresses away.

---

# 10.9 Responsive Surface Adaptation

Secondary surfaces should adapt according to device.

---

## Desktop

Preferred:

### Panels

### Drawers

### Side Inspectors

---

## Tablet

Preferred:

### Drawers

### Expandable Sections

---

## Mobile

Preferred:

### Full-Screen Sheets

### Step-Based Review Surfaces

---

## Rule

The information remains available.

Only the presentation changes.

---

# 10.10 Accessibility Philosophy

Accessibility is an architectural requirement.

Not an afterthought.

Users must be able to:

* understand state
* navigate workflows
* review changes
* approve actions
* inspect impacts

regardless of interaction method.

---

# 10.11 Semantic Structure Requirements

All major content must have meaningful structure.

Required hierarchy:

```text id="8cmmlz"
Workspace
→ Project
→ Screen
→ Section
→ Object
→ Action
```

The structure should be understandable without visual cues.

---

# 10.12 Keyboard Accessibility

All major workflows must support keyboard navigation.

---

## Required Coverage

### Navigation

### Specification Editing

### Approval Review

### Change Review

### Deployment Review

### Activity Review

---

## Required Behavior

Users must be able to:

* move
* inspect
* approve
* reject
* review

without requiring a pointer device.

---

# 10.13 Focus Management

Focus must remain predictable.

---

## Requirements

After actions:

* focus remains visible
* focus moves logically
* focus never becomes lost

---

## Critical Workflows

### Approval Review

### Validation Review

### Error Resolution

### Merge Review

must preserve clear focus transitions.

---

# 10.14 Screen Reader Requirements

Screen-reader users must be able to understand:

### Current Project

### Current State

### Current Workflow

### Blocking Conditions

### Available Actions

without visual interpretation.

---

## Priority Information

The following should always be announced clearly:

### Lifecycle State

### Validation State

### Approval State

### Deployment State

### Failure State

---

# 10.15 State Accessibility

State communication must not rely on:

* color
* position
* iconography

alone.

All states require explicit textual representation.

Examples:

Bad:

```text id="n8vaf7"
Red badge only.
```

Good:

```text id="s8j6bl"
Validation Failed
```

---

# 10.16 Notification Accessibility

Notifications must expose:

### Event

### Severity

### Scope

### Required Action

through accessible text.

---

# 10.17 Data Density Requirements

sembl is an information-dense system.

Accessibility should not force oversimplification.

Instead:

* information should remain available
* complexity should remain progressive
* structure should remain navigable

The goal is clarity.

Not reduction.

---

# 10.18 Accessibility for Traceability

Lineage and impact systems must remain accessible.

Users must be able to understand:

```text id="j7r0w2"
What caused this?

What changed?

What depends on this?
```

through non-visual interaction methods.

---

# 10.19 Responsive and Accessibility Constraints

---

## RA-I1

Desktop remains the canonical authoring environment.

---

## RA-I2

Mobile prioritizes monitoring, approvals, and response.

---

## RA-I3

Navigation structure remains consistent across devices.

---

## RA-I4

Project state remains visible on all devices.

---

## RA-I5

State communication never depends solely on visual styling.

---

## RA-I6

Keyboard access is required for all major workflows.

---

## RA-I7

Screen-reader users must be able to understand project state and workflow state.

---

## RA-I8

Accessibility must preserve traceability and visibility architecture.

---

## RA-I9

Responsive adaptation may alter presentation but not information architecture.

---

## RA-I10

Accessibility support must not reduce workflow capability.

---

# 10.20 Global UX Invariant Summary

The UI/UX Specification concludes with the following global invariant:

```text id="n7mhhj"
Users build software
through evolving specifications.

The system preserves
architectural continuity,
validation visibility,
reconciliation visibility,
lineage visibility,
and execution transparency.

Complexity is progressively revealed.

Graph canonicality remains preserved.

Graph management never becomes the primary user experience.
```

---






', '6cfd11d6b297a35944ae8e7396b42f3ed5a43eba47de6cdff79850480bd7c1bc', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = '9f4ae953-a561-50fa-b9a3-f2110187bb65', updated_at = '2026-06-02T12:00:00.000Z' where id = 'afc194d2-a715-54fc-add6-dc9cbd4d1c9e';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('4565c1b5-a95b-5d7e-9b65-5a5b8c9fde5e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'system_design', '# System Design — sembl v1

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

---', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('bd542a79-63c4-5042-be0c-7e72d7e5a82b', '4565c1b5-a95b-5d7e-9b65-5a5b8c9fde5e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# System Design — sembl v1

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

---', '67a4eac029248e8608a1e9509717fce58609d41480200cabaced8517f89157d7', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = 'bd542a79-63c4-5042-be0c-7e72d7e5a82b', updated_at = '2026-06-02T12:00:00.000Z' where id = '4565c1b5-a95b-5d7e-9b65-5a5b8c9fde5e';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('97741d29-080a-5c0b-b68f-6f0994cbac72', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'db_schema', '# sembl v1 — Database Schema
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
  ''owner'',
  ''admin'',
  ''member'',
  ''viewer''
);

CREATE TABLE workspace_members (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id  uuid NOT NULL REFERENCES workspaces(id),
  user_id       uuid NOT NULL REFERENCES auth.users(id),
  role          workspace_role NOT NULL DEFAULT ''member'',
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
  provider      text NOT NULL,  -- ''github'' | ''vercel''
  external_id   text NOT NULL,
  metadata      jsonb NOT NULL DEFAULT ''{}'',
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
  ''draft'',
  ''ready_for_execution'',
  ''awaiting_approval'',
  ''executing'',
  ''reconciling'',
  ''deploying'',
  ''active'',
  ''escalated''
);

CREATE TYPE operational_mode AS ENUM (
  ''documentation'',
  ''execution'',
  ''iteration''
);

CREATE TABLE projects (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id            uuid NOT NULL REFERENCES workspaces(id),
  name                    text NOT NULL,
  slug                    text NOT NULL,
  lifecycle_state         project_lifecycle_state NOT NULL DEFAULT ''draft'',
  operational_mode        operational_mode NOT NULL DEFAULT ''documentation'',
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
  provider        text NOT NULL DEFAULT ''github'',
  external_url    text NOT NULL,
  external_id     text NOT NULL,
  default_branch  text NOT NULL DEFAULT ''main'',
  metadata        jsonb NOT NULL DEFAULT ''{}'',
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
  ''pdd'',
  ''prd'',
  ''nfr'',
  ''uiux'',
  ''system_design'',
  ''db_schema'',
  ''api_spec'',
  ''tech_architecture''
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
  ''entity'',
  ''interface'',
  ''integration_contract'',
  ''flow'',
  ''invariant'',
  ''execution_boundary''
);

CREATE TABLE graph_nodes (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  graph_version_id    uuid NOT NULL,   -- FK added after graph_versions is created
  node_type           graph_node_type NOT NULL,
  name                text NOT NULL,
  payload             jsonb NOT NULL DEFAULT ''{}'',
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
  ''dependency'',
  ''implements'',
  ''precedes'',
  ''triggers'',
  ''owns'',
  ''lineage''
);

CREATE TABLE graph_edges (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  graph_version_id  uuid NOT NULL,   -- FK added after graph_versions is created
  edge_type         graph_edge_type NOT NULL,
  source_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  target_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  metadata          jsonb NOT NULL DEFAULT ''{}'',
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
  diff_payload    jsonb NOT NULL DEFAULT ''{}'',
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
  ''active'',
  ''diverged'',
  ''merge_pending'',
  ''merged'',
  ''rejected'',
  ''archived''
);

CREATE TABLE branches (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  name                    text NOT NULL,
  base_graph_version_id   uuid NOT NULL REFERENCES graph_versions(id),
  state                   branch_state NOT NULL DEFAULT ''active'',
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
  ''add'',
  ''modify'',
  ''remove''
);

CREATE TABLE mutation_deltas (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id           uuid NOT NULL REFERENCES branches(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  sequence_number     integer NOT NULL,
  operation           delta_operation NOT NULL,
  target_node_id      uuid REFERENCES graph_nodes(id),
  target_edge_id      uuid REFERENCES graph_edges(id),
  payload             jsonb NOT NULL DEFAULT ''{}'',
  triggering_event_id uuid,   -- FK added after events is created
  created_at          timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  UNIQUE(branch_id, sequence_number)
);
```

### `merge_attempts`

```sql
CREATE TYPE merge_status AS ENUM (
  ''pending'',
  ''validating'',
  ''conflict_detected'',
  ''resolving'',
  ''approved'',
  ''reconciling'',
  ''completed'',
  ''failed'',
  ''rejected''
);

CREATE TABLE merge_attempts (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  source_branch_id    uuid NOT NULL REFERENCES branches(id),
  target_branch_id    uuid REFERENCES branches(id),   -- null = merge into canonical main
  status              merge_status NOT NULL DEFAULT ''pending'',
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
  ''SpecificationCreated'',
  ''SpecificationModified'',
  ''ValidationTriggered'',
  ''ValidationPassed'',
  ''ValidationFailed'',
  ''GraphMutationProposed'',
  ''GraphMutationApproved'',
  ''GraphMutationRejected'',
  ''GraphMutationCommitted'',
  ''ExecutionApprovalRequested'',
  ''ExecutionApproved'',
  ''ExecutionStarted'',
  ''ExecutionCompleted'',
  ''ExecutionFailed'',
  ''ReconciliationStarted'',
  ''ReconciliationCompleted'',
  ''ReconciliationFailed'',
  ''ReconciliationRolledBack'',
  ''DeploymentStarted'',
  ''DeploymentCompleted'',
  ''DeploymentFailed'',
  ''DeploymentRolledBack'',
  ''BranchCreated'',
  ''MergeRequested'',
  ''MergeApproved'',
  ''MergeCompleted'',
  ''MergeRolledBack'',
  ''EscalationTriggered'',
  ''RepositoryIngestionStarted'',
  ''RepositoryIngestionCompleted'',
  ''RepositoryIngestionFailed''
);

CREATE TABLE events (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  event_type              event_type NOT NULL,
  sequence_number         bigint NOT NULL,
  actor_id                uuid REFERENCES auth.users(id),
  originating_subsystem   text NOT NULL,
  affected_scope          jsonb NOT NULL DEFAULT ''{}'',
  source_state            text,
  target_state            text,
  metadata                jsonb NOT NULL DEFAULT ''{}'',
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
  ''specification'',
  ''execution_run'',
  ''reconciliation_attempt'',
  ''merge_attempt'',
  ''repository_ingestion''
);

CREATE TYPE validation_group_status AS ENUM (
  ''running'',
  ''passed'',
  ''passed_with_warnings'',
  ''failed''
);

CREATE TABLE validation_run_groups (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  target_type             validation_target_type NOT NULL,
  target_id               uuid NOT NULL,
  status                  validation_group_status NOT NULL DEFAULT ''running'',
  triggered_by_event_id   uuid REFERENCES events(id),
  completed_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now()
);
```

### `validation_runs`

One row per pass within a group. Pass 1 = Structural, Pass 2 = Semantic, Pass 3 = Consistency.

```sql
CREATE TYPE validation_run_status AS ENUM (
  ''running'',
  ''passed'',
  ''passed_with_warnings'',
  ''failed''
);

CREATE TABLE validation_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id          uuid NOT NULL REFERENCES validation_run_groups(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  pass_number       integer NOT NULL CHECK (pass_number IN (1, 2, 3)),
  status            validation_run_status NOT NULL DEFAULT ''running'',
  completed_at      timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE(group_id, pass_number)
);
```

### `validation_violations`

Violations are immutable after creation. Correction occurs through subsequent validation runs, not by modifying existing violations.

```sql
CREATE TYPE violation_severity AS ENUM (
  ''blocking'',
  ''warning'',
  ''informational'',
  ''escalated''
);

CREATE TABLE validation_violations (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  validation_run_id   uuid NOT NULL REFERENCES validation_runs(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  invariant_id        text NOT NULL,  -- e.g. ''I1'', ''C2'', ''E3'' per V4.3 §3
  affected_node_id    uuid REFERENCES graph_nodes(id),
  affected_scope      jsonb NOT NULL DEFAULT ''{}'',
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
  ''execution_approval'',
  ''mutation_approval'',
  ''merge_approval''
);

CREATE TYPE approval_status AS ENUM (
  ''pending'',
  ''under_review'',
  ''approved'',
  ''rejected'',
  ''expired''
);

CREATE TABLE approvals (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  branch_id           uuid REFERENCES branches(id),
  approval_type       approval_type NOT NULL,
  status              approval_status NOT NULL DEFAULT ''pending'',
  requested_by        uuid NOT NULL REFERENCES auth.users(id),
  reviewed_by         uuid REFERENCES auth.users(id),
  affected_scope      jsonb NOT NULL DEFAULT ''{}'',
  mutation_summary    jsonb NOT NULL DEFAULT ''{}'',
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
  ''queued'',
  ''preparing'',
  ''running'',
  ''validating'',
  ''reconciling'',
  ''completed'',
  ''failed'',
  ''escalated''
);

CREATE TABLE execution_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid NOT NULL REFERENCES branches(id),
  graph_version_id  uuid NOT NULL REFERENCES graph_versions(id),
  approval_id       uuid REFERENCES approvals(id),
  status            execution_run_status NOT NULL DEFAULT ''queued'',
  triggered_by      uuid REFERENCES auth.users(id),
  started_at        timestamptz,
  completed_at      timestamptz,
  failure_reason    text,
  metadata          jsonb NOT NULL DEFAULT ''{}'',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
```

### `execution_tasks`

Individual DAG tasks within an execution run. Each task maps to an Execution Boundary node. Execution context is not stored — only the output produced by the task.

```sql
CREATE TYPE task_status AS ENUM (
  ''pending'',
  ''running'',
  ''completed'',
  ''failed'',
  ''skipped''
);

CREATE TABLE execution_tasks (
  id                           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  execution_run_id             uuid NOT NULL REFERENCES execution_runs(id),
  project_id                   uuid NOT NULL REFERENCES projects(id),
  execution_boundary_node_id   uuid REFERENCES graph_nodes(id),
  sequence_number              integer NOT NULL,
  status                       task_status NOT NULL DEFAULT ''pending'',
  dependency_task_ids          uuid[] NOT NULL DEFAULT ''{}'',
  output_payload               jsonb NOT NULL DEFAULT ''{}'',  -- execution result only, not context
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
  ''pending'',
  ''snapshot_taken'',
  ''diff_generated'',
  ''invariant_validated'',
  ''lineage_updated'',
  ''committed'',
  ''failed'',
  ''rolled_back''
);

CREATE TABLE reconciliation_attempts (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id            uuid NOT NULL REFERENCES projects(id),
  branch_id             uuid REFERENCES branches(id),
  execution_run_id      uuid REFERENCES execution_runs(id),
  merge_attempt_id      uuid REFERENCES merge_attempts(id),
  status                reconciliation_status NOT NULL DEFAULT ''pending'',
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
  ''not_deployed'',
  ''deploying'',
  ''healthy'',
  ''degraded'',
  ''failed'',
  ''rolling_back'',
  ''rolled_back''
);

CREATE TABLE deployments (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid NOT NULL REFERENCES branches(id),
  graph_version_id        uuid NOT NULL REFERENCES graph_versions(id),
  execution_run_id        uuid REFERENCES execution_runs(id),
  provider                text NOT NULL DEFAULT ''vercel'',
  provider_deployment_id  text,
  provider_url            text,
  environment             text NOT NULL DEFAULT ''production'',
  status                  deployment_status NOT NULL DEFAULT ''not_deployed'',
  previous_deployment_id  uuid REFERENCES deployments(id),
  triggered_by            uuid REFERENCES auth.users(id),
  deployed_at             timestamptz,
  health_verified_at      timestamptz,
  failure_reason          text,
  metadata                jsonb NOT NULL DEFAULT ''{}'',
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
  ''connected'',
  ''analyzing'',
  ''reconstructing'',
  ''confidence_review'',
  ''validating'',
  ''ready_for_activation'',
  ''activated'',
  ''failed''
);

CREATE TABLE repository_ingestion_runs (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id                uuid NOT NULL REFERENCES projects(id),
  repository_reference_id   uuid NOT NULL REFERENCES repository_references(id),
  status                    ingestion_status NOT NULL DEFAULT ''connected'',
  output_graph_version_id   uuid REFERENCES graph_versions(id),
  triggered_by              uuid REFERENCES auth.users(id),
  failure_reason            text,
  analysis_metadata         jsonb NOT NULL DEFAULT ''{}'',
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
  ''high'',
  ''medium'',
  ''low''
);

CREATE TYPE confidence_item_status AS ENUM (
  ''pending'',
  ''confirmed'',
  ''rejected'',
  ''escalated''
);

CREATE TABLE ingestion_confidence_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingestion_run_id  uuid NOT NULL REFERENCES repository_ingestion_runs(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  node_type         graph_node_type NOT NULL,
  confidence_level  confidence_level NOT NULL,
  confidence_score  numeric(4,3) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
  proposed_payload  jsonb NOT NULL DEFAULT ''{}'',
  status            confidence_item_status NOT NULL DEFAULT ''pending'',
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
  ''info'',
  ''warning'',
  ''action_required'',
  ''critical''
);

CREATE TABLE notifications (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id      uuid NOT NULL REFERENCES workspaces(id),
  project_id        uuid REFERENCES projects(id),
  recipient_user_id uuid NOT NULL REFERENCES auth.users(id),
  event_id          uuid REFERENCES events(id),
  severity          notification_severity NOT NULL DEFAULT ''info'',
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
  ''repeated_validation_failure'',
  ''repeated_reconciliation_failure'',
  ''unresolved_merge_conflict'',
  ''repository_reconstruction_failure'',
  ''unresolved_ambiguity''
);

CREATE TYPE escalation_status AS ENUM (
  ''open'',
  ''in_resolution'',
  ''resolved'',
  ''closed''
);

CREATE TABLE escalations (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid REFERENCES branches(id),
  trigger_type      escalation_trigger NOT NULL,
  trigger_event_id  uuid REFERENCES events(id),
  status            escalation_status NOT NULL DEFAULT ''open'',
  affected_scope    jsonb NOT NULL DEFAULT ''{}'',
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

*END OF SCHEMA*', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '97741d29-080a-5c0b-b68f-6f0994cbac72', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# sembl v1 — Database Schema
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
  ''owner'',
  ''admin'',
  ''member'',
  ''viewer''
);

CREATE TABLE workspace_members (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id  uuid NOT NULL REFERENCES workspaces(id),
  user_id       uuid NOT NULL REFERENCES auth.users(id),
  role          workspace_role NOT NULL DEFAULT ''member'',
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
  provider      text NOT NULL,  -- ''github'' | ''vercel''
  external_id   text NOT NULL,
  metadata      jsonb NOT NULL DEFAULT ''{}'',
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
  ''draft'',
  ''ready_for_execution'',
  ''awaiting_approval'',
  ''executing'',
  ''reconciling'',
  ''deploying'',
  ''active'',
  ''escalated''
);

CREATE TYPE operational_mode AS ENUM (
  ''documentation'',
  ''execution'',
  ''iteration''
);

CREATE TABLE projects (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id            uuid NOT NULL REFERENCES workspaces(id),
  name                    text NOT NULL,
  slug                    text NOT NULL,
  lifecycle_state         project_lifecycle_state NOT NULL DEFAULT ''draft'',
  operational_mode        operational_mode NOT NULL DEFAULT ''documentation'',
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
  provider        text NOT NULL DEFAULT ''github'',
  external_url    text NOT NULL,
  external_id     text NOT NULL,
  default_branch  text NOT NULL DEFAULT ''main'',
  metadata        jsonb NOT NULL DEFAULT ''{}'',
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
  ''pdd'',
  ''prd'',
  ''nfr'',
  ''uiux'',
  ''system_design'',
  ''db_schema'',
  ''api_spec'',
  ''tech_architecture''
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
  ''entity'',
  ''interface'',
  ''integration_contract'',
  ''flow'',
  ''invariant'',
  ''execution_boundary''
);

CREATE TABLE graph_nodes (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  graph_version_id    uuid NOT NULL,   -- FK added after graph_versions is created
  node_type           graph_node_type NOT NULL,
  name                text NOT NULL,
  payload             jsonb NOT NULL DEFAULT ''{}'',
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
  ''dependency'',
  ''implements'',
  ''precedes'',
  ''triggers'',
  ''owns'',
  ''lineage''
);

CREATE TABLE graph_edges (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  graph_version_id  uuid NOT NULL,   -- FK added after graph_versions is created
  edge_type         graph_edge_type NOT NULL,
  source_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  target_node_id    uuid NOT NULL REFERENCES graph_nodes(id),
  metadata          jsonb NOT NULL DEFAULT ''{}'',
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
  diff_payload    jsonb NOT NULL DEFAULT ''{}'',
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
  ''active'',
  ''diverged'',
  ''merge_pending'',
  ''merged'',
  ''rejected'',
  ''archived''
);

CREATE TABLE branches (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  name                    text NOT NULL,
  base_graph_version_id   uuid NOT NULL REFERENCES graph_versions(id),
  state                   branch_state NOT NULL DEFAULT ''active'',
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
  ''add'',
  ''modify'',
  ''remove''
);

CREATE TABLE mutation_deltas (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id           uuid NOT NULL REFERENCES branches(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  sequence_number     integer NOT NULL,
  operation           delta_operation NOT NULL,
  target_node_id      uuid REFERENCES graph_nodes(id),
  target_edge_id      uuid REFERENCES graph_edges(id),
  payload             jsonb NOT NULL DEFAULT ''{}'',
  triggering_event_id uuid,   -- FK added after events is created
  created_at          timestamptz NOT NULL DEFAULT now(),
  -- No updated_at. Immutable after insert.
  UNIQUE(branch_id, sequence_number)
);
```

### `merge_attempts`

```sql
CREATE TYPE merge_status AS ENUM (
  ''pending'',
  ''validating'',
  ''conflict_detected'',
  ''resolving'',
  ''approved'',
  ''reconciling'',
  ''completed'',
  ''failed'',
  ''rejected''
);

CREATE TABLE merge_attempts (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  source_branch_id    uuid NOT NULL REFERENCES branches(id),
  target_branch_id    uuid REFERENCES branches(id),   -- null = merge into canonical main
  status              merge_status NOT NULL DEFAULT ''pending'',
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
  ''SpecificationCreated'',
  ''SpecificationModified'',
  ''ValidationTriggered'',
  ''ValidationPassed'',
  ''ValidationFailed'',
  ''GraphMutationProposed'',
  ''GraphMutationApproved'',
  ''GraphMutationRejected'',
  ''GraphMutationCommitted'',
  ''ExecutionApprovalRequested'',
  ''ExecutionApproved'',
  ''ExecutionStarted'',
  ''ExecutionCompleted'',
  ''ExecutionFailed'',
  ''ReconciliationStarted'',
  ''ReconciliationCompleted'',
  ''ReconciliationFailed'',
  ''ReconciliationRolledBack'',
  ''DeploymentStarted'',
  ''DeploymentCompleted'',
  ''DeploymentFailed'',
  ''DeploymentRolledBack'',
  ''BranchCreated'',
  ''MergeRequested'',
  ''MergeApproved'',
  ''MergeCompleted'',
  ''MergeRolledBack'',
  ''EscalationTriggered'',
  ''RepositoryIngestionStarted'',
  ''RepositoryIngestionCompleted'',
  ''RepositoryIngestionFailed''
);

CREATE TABLE events (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  event_type              event_type NOT NULL,
  sequence_number         bigint NOT NULL,
  actor_id                uuid REFERENCES auth.users(id),
  originating_subsystem   text NOT NULL,
  affected_scope          jsonb NOT NULL DEFAULT ''{}'',
  source_state            text,
  target_state            text,
  metadata                jsonb NOT NULL DEFAULT ''{}'',
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
  ''specification'',
  ''execution_run'',
  ''reconciliation_attempt'',
  ''merge_attempt'',
  ''repository_ingestion''
);

CREATE TYPE validation_group_status AS ENUM (
  ''running'',
  ''passed'',
  ''passed_with_warnings'',
  ''failed''
);

CREATE TABLE validation_run_groups (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid REFERENCES branches(id),
  target_type             validation_target_type NOT NULL,
  target_id               uuid NOT NULL,
  status                  validation_group_status NOT NULL DEFAULT ''running'',
  triggered_by_event_id   uuid REFERENCES events(id),
  completed_at            timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now()
);
```

### `validation_runs`

One row per pass within a group. Pass 1 = Structural, Pass 2 = Semantic, Pass 3 = Consistency.

```sql
CREATE TYPE validation_run_status AS ENUM (
  ''running'',
  ''passed'',
  ''passed_with_warnings'',
  ''failed''
);

CREATE TABLE validation_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id          uuid NOT NULL REFERENCES validation_run_groups(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  pass_number       integer NOT NULL CHECK (pass_number IN (1, 2, 3)),
  status            validation_run_status NOT NULL DEFAULT ''running'',
  completed_at      timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE(group_id, pass_number)
);
```

### `validation_violations`

Violations are immutable after creation. Correction occurs through subsequent validation runs, not by modifying existing violations.

```sql
CREATE TYPE violation_severity AS ENUM (
  ''blocking'',
  ''warning'',
  ''informational'',
  ''escalated''
);

CREATE TABLE validation_violations (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  validation_run_id   uuid NOT NULL REFERENCES validation_runs(id),
  project_id          uuid NOT NULL REFERENCES projects(id),
  invariant_id        text NOT NULL,  -- e.g. ''I1'', ''C2'', ''E3'' per V4.3 §3
  affected_node_id    uuid REFERENCES graph_nodes(id),
  affected_scope      jsonb NOT NULL DEFAULT ''{}'',
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
  ''execution_approval'',
  ''mutation_approval'',
  ''merge_approval''
);

CREATE TYPE approval_status AS ENUM (
  ''pending'',
  ''under_review'',
  ''approved'',
  ''rejected'',
  ''expired''
);

CREATE TABLE approvals (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id          uuid NOT NULL REFERENCES projects(id),
  branch_id           uuid REFERENCES branches(id),
  approval_type       approval_type NOT NULL,
  status              approval_status NOT NULL DEFAULT ''pending'',
  requested_by        uuid NOT NULL REFERENCES auth.users(id),
  reviewed_by         uuid REFERENCES auth.users(id),
  affected_scope      jsonb NOT NULL DEFAULT ''{}'',
  mutation_summary    jsonb NOT NULL DEFAULT ''{}'',
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
  ''queued'',
  ''preparing'',
  ''running'',
  ''validating'',
  ''reconciling'',
  ''completed'',
  ''failed'',
  ''escalated''
);

CREATE TABLE execution_runs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid NOT NULL REFERENCES branches(id),
  graph_version_id  uuid NOT NULL REFERENCES graph_versions(id),
  approval_id       uuid REFERENCES approvals(id),
  status            execution_run_status NOT NULL DEFAULT ''queued'',
  triggered_by      uuid REFERENCES auth.users(id),
  started_at        timestamptz,
  completed_at      timestamptz,
  failure_reason    text,
  metadata          jsonb NOT NULL DEFAULT ''{}'',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
```

### `execution_tasks`

Individual DAG tasks within an execution run. Each task maps to an Execution Boundary node. Execution context is not stored — only the output produced by the task.

```sql
CREATE TYPE task_status AS ENUM (
  ''pending'',
  ''running'',
  ''completed'',
  ''failed'',
  ''skipped''
);

CREATE TABLE execution_tasks (
  id                           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  execution_run_id             uuid NOT NULL REFERENCES execution_runs(id),
  project_id                   uuid NOT NULL REFERENCES projects(id),
  execution_boundary_node_id   uuid REFERENCES graph_nodes(id),
  sequence_number              integer NOT NULL,
  status                       task_status NOT NULL DEFAULT ''pending'',
  dependency_task_ids          uuid[] NOT NULL DEFAULT ''{}'',
  output_payload               jsonb NOT NULL DEFAULT ''{}'',  -- execution result only, not context
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
  ''pending'',
  ''snapshot_taken'',
  ''diff_generated'',
  ''invariant_validated'',
  ''lineage_updated'',
  ''committed'',
  ''failed'',
  ''rolled_back''
);

CREATE TABLE reconciliation_attempts (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id            uuid NOT NULL REFERENCES projects(id),
  branch_id             uuid REFERENCES branches(id),
  execution_run_id      uuid REFERENCES execution_runs(id),
  merge_attempt_id      uuid REFERENCES merge_attempts(id),
  status                reconciliation_status NOT NULL DEFAULT ''pending'',
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
  ''not_deployed'',
  ''deploying'',
  ''healthy'',
  ''degraded'',
  ''failed'',
  ''rolling_back'',
  ''rolled_back''
);

CREATE TABLE deployments (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id              uuid NOT NULL REFERENCES projects(id),
  branch_id               uuid NOT NULL REFERENCES branches(id),
  graph_version_id        uuid NOT NULL REFERENCES graph_versions(id),
  execution_run_id        uuid REFERENCES execution_runs(id),
  provider                text NOT NULL DEFAULT ''vercel'',
  provider_deployment_id  text,
  provider_url            text,
  environment             text NOT NULL DEFAULT ''production'',
  status                  deployment_status NOT NULL DEFAULT ''not_deployed'',
  previous_deployment_id  uuid REFERENCES deployments(id),
  triggered_by            uuid REFERENCES auth.users(id),
  deployed_at             timestamptz,
  health_verified_at      timestamptz,
  failure_reason          text,
  metadata                jsonb NOT NULL DEFAULT ''{}'',
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
  ''connected'',
  ''analyzing'',
  ''reconstructing'',
  ''confidence_review'',
  ''validating'',
  ''ready_for_activation'',
  ''activated'',
  ''failed''
);

CREATE TABLE repository_ingestion_runs (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id                uuid NOT NULL REFERENCES projects(id),
  repository_reference_id   uuid NOT NULL REFERENCES repository_references(id),
  status                    ingestion_status NOT NULL DEFAULT ''connected'',
  output_graph_version_id   uuid REFERENCES graph_versions(id),
  triggered_by              uuid REFERENCES auth.users(id),
  failure_reason            text,
  analysis_metadata         jsonb NOT NULL DEFAULT ''{}'',
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
  ''high'',
  ''medium'',
  ''low''
);

CREATE TYPE confidence_item_status AS ENUM (
  ''pending'',
  ''confirmed'',
  ''rejected'',
  ''escalated''
);

CREATE TABLE ingestion_confidence_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ingestion_run_id  uuid NOT NULL REFERENCES repository_ingestion_runs(id),
  project_id        uuid NOT NULL REFERENCES projects(id),
  node_type         graph_node_type NOT NULL,
  confidence_level  confidence_level NOT NULL,
  confidence_score  numeric(4,3) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
  proposed_payload  jsonb NOT NULL DEFAULT ''{}'',
  status            confidence_item_status NOT NULL DEFAULT ''pending'',
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
  ''info'',
  ''warning'',
  ''action_required'',
  ''critical''
);

CREATE TABLE notifications (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id      uuid NOT NULL REFERENCES workspaces(id),
  project_id        uuid REFERENCES projects(id),
  recipient_user_id uuid NOT NULL REFERENCES auth.users(id),
  event_id          uuid REFERENCES events(id),
  severity          notification_severity NOT NULL DEFAULT ''info'',
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
  ''repeated_validation_failure'',
  ''repeated_reconciliation_failure'',
  ''unresolved_merge_conflict'',
  ''repository_reconstruction_failure'',
  ''unresolved_ambiguity''
);

CREATE TYPE escalation_status AS ENUM (
  ''open'',
  ''in_resolution'',
  ''resolved'',
  ''closed''
);

CREATE TABLE escalations (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id        uuid NOT NULL REFERENCES projects(id),
  branch_id         uuid REFERENCES branches(id),
  trigger_type      escalation_trigger NOT NULL,
  trigger_event_id  uuid REFERENCES events(id),
  status            escalation_status NOT NULL DEFAULT ''open'',
  affected_scope    jsonb NOT NULL DEFAULT ''{}'',
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

*END OF SCHEMA*', '433659c5a081ec3dc99ae8892a9bc0cd912b1c394816230ed65101eaf993d661', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', updated_at = '2026-06-02T12:00:00.000Z' where id = '97741d29-080a-5c0b-b68f-6f0994cbac72';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('390accf6-ec3a-5dc2-bb66-022c4ba6a279', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'api_spec', '# sembl v1 — API Specification

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
Changes a member''s role.

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
Returns the active graph version''s full node and edge set.

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
Triggers a manual validation run against the project''s active branch and active specification revision.

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

Clients subscribe using Supabase client libraries. Channel access is validated against the authenticated user''s workspace membership and project access. Unauthorized subscription attempts are silently rejected.

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

*END OF API SPECIFICATION*', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('db1e139f-062a-5f48-b152-dddb6661485c', '390accf6-ec3a-5dc2-bb66-022c4ba6a279', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# sembl v1 — API Specification

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
Changes a member''s role.

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
Returns the active graph version''s full node and edge set.

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
Triggers a manual validation run against the project''s active branch and active specification revision.

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

Clients subscribe using Supabase client libraries. Channel access is validated against the authenticated user''s workspace membership and project access. Unauthorized subscription attempts are silently rejected.

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

*END OF API SPECIFICATION*', 'ba08690e1d0d38a309481bef04b852200d8b18e3a777cc9ecd973bd39aeb9b4b', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = 'db1e139f-062a-5f48-b152-dddb6661485c', updated_at = '2026-06-02T12:00:00.000Z' where id = '390accf6-ec3a-5dc2-bb66-022c4ba6a279';

insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)
values ('95ef87b9-2993-592e-a524-b784d3dd2840', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'tech_architecture', '# Section 1 — Architectural Principles

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



', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)
values ('7d905118-e3cc-5d7b-bc94-e614b5f05fa5', '95ef87b9-2993-592e-a524-b784d3dd2840', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, '# Section 1 — Architectural Principles

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



', '2b9aa43c58dac03ad163cd8f3a44bce5b074e3e68537d91a1948639a0ce19ce6', '3b375490-2133-5e97-a59a-a39948a78ff5', null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;
update public.specification_documents set active_revision_id = '7d905118-e3cc-5d7b-bc94-e614b5f05fa5', updated_at = '2026-06-02T12:00:00.000Z' where id = '95ef87b9-2993-592e-a524-b784d3dd2840';

insert into public.graph_versions (id, project_id, version_number, parent_version_id, source_spec_revision_id, created_at)
values ('80243da9-c3a3-5321-a92d-ced459b3178a', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 0, null, '91e635da-2b5a-51b0-9492-21c5027fdea3', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.branches (id, project_id, name, base_graph_version_id, state, created_by, created_at, updated_at)
values ('5699f3c6-4af2-5de7-b302-9e71f368587e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'main', '80243da9-c3a3-5321-a92d-ced459b3178a', 'active', '3b375490-2133-5e97-a59a-a39948a78ff5', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.graph_nodes (id, project_id, graph_version_id, node_type, name, payload, source_spec_type, source_revision_id, created_at) values
('8a6851fc-7016-5219-a328-1ca1b85890aa', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'Workspace', '{"fields":{"id":"string","name":"string","created_by":"string","created_at":"string"},"concept_id":"entity.workspace","semantic_id":"node.entity.workspace","original_source_spec_type":"db_schema","source_refs":["db_schema.md#workspaces","prd.md#workspace-and-project-management"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('6099959a-fd2b-58d0-ab85-207ed4f87a1b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'Project', '{"fields":{"id":"string","workspace_id":"string","name":"string","lifecycle_state":"string","operational_mode":"string"},"concept_id":"entity.project","semantic_id":"node.entity.project","original_source_spec_type":"db_schema","source_refs":["db_schema.md#projects","prd.md#project-creation"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('ebbcad01-59bd-5349-8e00-169a53732a6f', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'SpecificationRevision', '{"fields":{"id":"string","document_id":"string","revision_number":"number","content":"string","authored_by":"string"},"concept_id":"entity.specification_revision","semantic_id":"node.entity.specification_revision","original_source_spec_type":"db_schema","source_refs":["db_schema.md#specification_revisions","api_spec.md#specifications"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('2e92ab68-92a9-52ca-8881-37b9b12ba284', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'GraphNode', '{"fields":{"id":"string","node_type":"string","name":"string","payload":"GraphPayload","source_spec_type":"string"},"concept_id":"entity.graph_node","semantic_id":"node.entity.graph_node","original_source_spec_type":"db_schema","source_refs":["db_schema.md#graph_nodes","api_spec.md#graph"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('1252ffef-4065-54fe-b427-ffc759365bec', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'GraphEdge', '{"fields":{"id":"string","edge_type":"string","source_node_id":"string","target_node_id":"string","metadata":"GraphPayload"},"concept_id":"entity.graph_edge","semantic_id":"node.entity.graph_edge","original_source_spec_type":"db_schema","source_refs":["db_schema.md#graph_edges","api_spec.md#graph"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('c0c9c96a-3f9a-5b04-bd43-a9502aa8f580', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'GraphVersion', '{"fields":{"id":"string","project_id":"string","version_number":"number","parent_version_id":"string","created_at":"string"},"concept_id":"entity.graph_version","semantic_id":"node.entity.graph_version","original_source_spec_type":"db_schema","source_refs":["db_schema.md#graph_versions","prd.md#graph-versioning"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('adde85df-55ed-5141-8f71-1a11efc5e744', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'ExecutionRun', '{"fields":{"id":"string","branch_id":"string","graph_version_id":"string","status":"string","failure_reason":"string"},"concept_id":"entity.execution_run","semantic_id":"node.entity.execution_run","original_source_spec_type":"db_schema","source_refs":["db_schema.md#execution_runs","api_spec.md#execution"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('cb6efe2d-951f-5dfb-a9f7-cb20a6becb43', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'ExecutionTask', '{"fields":{"id":"string","execution_boundary_node_id":"string","sequence_number":"number","status":"string","dependency_task_ids":"array<string>","output_payload":"GraphPayload"},"concept_id":"entity.execution_task","semantic_id":"node.entity.execution_task","original_source_spec_type":"db_schema","source_refs":["db_schema.md#execution_tasks","api_spec.md#execution"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('3ba06e6e-2c89-5daa-9a11-b54ad54c64e1', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'Approval', '{"fields":{"id":"string","project_id":"string","approval_type":"string","status":"string","impact_payload":"GraphPayload"},"concept_id":"entity.approval","semantic_id":"node.entity.approval","original_source_spec_type":"db_schema","source_refs":["db_schema.md#approvals","api_spec.md#approvals"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('78a5a4f8-72f6-5796-81be-554535925119', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'entity', 'ServiceIntegration', '{"fields":{"id":"string","workspace_id":"string","provider":"string","status":"string"},"concept_id":"entity.service_integration","semantic_id":"node.entity.service_integration","original_source_spec_type":"db_schema","source_refs":["db_schema.md#workspace_integrations","api_spec.md#workspace-integrations"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('f3f18b5c-6429-5fbd-8aa1-009b2a8a18a5', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'PublishSpecificationRevision', '{"input":{"project_id":"string","spec_type":"string","content":"string","actor_id":"string"},"output":{"revision":"SpecificationRevision"},"preconditions":["Project exists.","Actor may mutate specifications."],"postconditions":["Immutable revision is recorded.","Validation may be triggered."],"success_example":{"input":{"project_id":"project_1","spec_type":"prd","content":"validated content","actor_id":"user_1"},"output":{"revision":"revision_1"}},"failure_examples":[{"input":{"project_id":"project_1","spec_type":"unknown","content":"x","actor_id":"user_1"},"output":{"error":"invalid_spec_type"}}],"semantic_id":"node.interface.publish_specification_revision","original_source_spec_type":"api_spec","source_refs":["api_spec.md#specifications","prd.md#documentation-mode-requirements"]}'::jsonb, 'api_spec', 'db1e139f-062a-5f48-b152-dddb6661485c', '2026-06-02T12:00:00.000Z'),
('1f7f1a3f-9d9b-5c1c-ba3b-58ffc91d44d0', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'ConstructConceptGraph', '{"input":{"project_id":"string","revision_ids":"array<string>"},"output":{"graph_version":"GraphVersion"},"preconditions":["Specifications are validated."],"postconditions":["Concept graph candidates exist with source references."],"success_example":{"input":{"project_id":"project_1","revision_ids":["revision_1"]},"output":{"graph_version":"graph_version_1"}},"failure_examples":[{"input":{"project_id":"project_1","revision_ids":[]},"output":{"error":"missing_source_revisions"}}],"semantic_id":"node.interface.construct_concept_graph","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#extraction","prd.md#graph-construction"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('dd3b140b-402c-529c-9212-d4947aa37956', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'NormalizeGraph', '{"input":{"concept_graph_id":"string","ui_graph_id":"string"},"output":{"graph_version":"GraphVersion"},"preconditions":["Concept graph and UI graph are structurally valid."],"postconditions":["Normalized graph contains only approved node and edge types."],"success_example":{"input":{"concept_graph_id":"concept_graph_1","ui_graph_id":"ui_graph_1"},"output":{"graph_version":"graph_version_2"}},"failure_examples":[{"input":{"concept_graph_id":"concept_graph_1","ui_graph_id":"ui_graph_with_direct_mutation"},"output":{"error":"ui_graph_mutation_surface_violation"}}],"semantic_id":"node.interface.normalize_graph","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#normalization-strict","prd.md#graph-normalization"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('a61c4195-36a0-5d39-a069-0084624282f7', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'ValidateGraph', '{"input":{"graph_version_id":"string"},"output":{"violations":"array<ValidationViolation>"},"preconditions":["Graph exists."],"postconditions":["Validation result is graph-addressable."],"success_example":{"input":{"graph_version_id":"graph_version_2"},"output":{"violations":[]}},"failure_examples":[{"input":{"graph_version_id":"cyclic_graph"},"output":{"error":"blocking_validation_violations"}}],"semantic_id":"node.interface.validate_graph","original_source_spec_type":"nfr","source_refs":["v_4.3.md#graph-validation-agent-formalized","nfr.md#multi-pass-validation-constraint"]}'::jsonb, 'nfr', '67a0e984-c23d-5374-b639-e4ffaafb36f5', '2026-06-02T12:00:00.000Z'),
('2814fbc2-83d5-5bc2-9bb6-a40b191063b7', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'GenerateTaskGraph', '{"input":{"graph_version_id":"string"},"output":{"task_graph_id":"string"},"preconditions":["Graph validation passed."],"postconditions":["Acyclic task DAG exists with scoped task packets."],"success_example":{"input":{"graph_version_id":"graph_version_2"},"output":{"task_graph_id":"task_graph_1"}},"failure_examples":[{"input":{"graph_version_id":"graph_with_cycle"},"output":{"error":"task_dag_cycle"}}],"semantic_id":"node.interface.generate_task_graph","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#task-graph-enhanced","prd.md#task-dag-generation"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('b071961c-acb3-5d4b-b73c-157e31e69acf', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'StartExecution', '{"input":{"branch_id":"string","approval_id":"string"},"output":{"execution_run":"ExecutionRun"},"preconditions":["Validation passed.","Approval is valid and non-expired.","Manual start action is received."],"postconditions":["Execution run starts and tasks are materialized in DAG order."],"success_example":{"input":{"branch_id":"branch_1","approval_id":"approval_1"},"output":{"execution_run":"run_1"}},"failure_examples":[{"input":{"branch_id":"branch_1","approval_id":"expired"},"output":{"error":"approval_expired"}}],"semantic_id":"node.interface.start_execution","original_source_spec_type":"api_spec","source_refs":["api_spec.md#execution","prd.md#execution-requirements"]}'::jsonb, 'api_spec', 'db1e139f-062a-5f48-b152-dddb6661485c', '2026-06-02T12:00:00.000Z'),
('6c460c56-109e-5c67-a11e-1d79ef95797b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'ReconcileExecutionOutput', '{"input":{"execution_run_id":"string"},"output":{"reconciliation_attempt":"ReconciliationAttempt"},"preconditions":["Execution has completed or failed with reconcilable output."],"postconditions":["Semantic diff and lineage are produced or failure is routed back to owner."],"success_example":{"input":{"execution_run_id":"run_1"},"output":{"reconciliation_attempt":"reconciliation_1"}},"failure_examples":[{"input":{"execution_run_id":"failed_run"},"output":{"error":"execution_not_reconcilable"}}],"semantic_id":"node.interface.reconcile_execution_output","original_source_spec_type":"techarch","source_refs":["techarch.md#reconciliation-module","api_spec.md#reconciliation"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('39739b89-e596-5d6e-847f-76e01eb3c3da', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'interface', 'ConnectWorkspaceIntegration', '{"input":{"workspace_id":"string","provider":"string"},"output":{"integration":"ServiceIntegration"},"preconditions":["Actor has workspace admin authority.","Provider OAuth or CLI state is available."],"postconditions":["Only provider metadata is persisted; credentials remain external."],"success_example":{"input":{"workspace_id":"workspace_1","provider":"github"},"output":{"integration":"integration_1"}},"failure_examples":[{"input":{"workspace_id":"workspace_1","provider":"unknown"},"output":{"error":"unsupported_provider"}}],"semantic_id":"node.interface.connect_workspace_integration","original_source_spec_type":"api_spec","source_refs":["api_spec.md#workspace-integrations","techarch.md#external-runtime-dependencies"]}'::jsonb, 'api_spec', 'db1e139f-062a-5f48-b152-dddb6661485c', '2026-06-02T12:00:00.000Z'),
('d4b6c765-f1fc-5d38-95e4-3c434fbc32e8', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'integration_contract', 'NewProjectToValidatedGraph', '{"steps":[{"interface_id":"node.interface.publish_specification_revision","input_mapping":{"project_id":"Project.id","spec_type":"intent.spec_type","content":"intent.spec_content","actor_id":"session.user_id"}},{"interface_id":"node.interface.construct_concept_graph","input_mapping":{"project_id":"Project.id","revision_ids":"PublishSpecificationRevision.output.revision.id"}},{"interface_id":"node.interface.normalize_graph","input_mapping":{"concept_graph_id":"ConstructConceptGraph.output.graph_version.id","ui_graph_id":"locked_design_artifact.id"}},{"interface_id":"node.interface.validate_graph","input_mapping":{"graph_version_id":"NormalizeGraph.output.graph_version.id"}}],"error_handling":["Stop at first blocking validation failure.","Persist graph-addressable violation output.","Route ambiguity to human review."],"transaction":{"atomic":false,"rollback":"immutable_revision_and_event_lineage_are_preserved"},"semantic_id":"node.contract.new_project_to_validated_graph","original_source_spec_type":"prd","source_refs":["v_4.3.md#docs-concept-graph-normalized-graph","prd.md#canonical-product-flow"]}'::jsonb, 'prd', '91e635da-2b5a-51b0-9492-21c5027fdea3', '2026-06-02T12:00:00.000Z'),
('6226c369-5a47-5df1-a8bd-ab23cf4525aa', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'integration_contract', 'ValidatedGraphToExecution', '{"steps":[{"interface_id":"node.interface.generate_task_graph","input_mapping":{"graph_version_id":"ValidateGraph.input.graph_version_id"}},{"interface_id":"node.interface.start_execution","input_mapping":{"branch_id":"active_branch.id","approval_id":"valid_execution_approval.id"}},{"interface_id":"node.interface.reconcile_execution_output","input_mapping":{"execution_run_id":"StartExecution.output.execution_run.id"}}],"error_handling":["Manual execution requires a valid non-expired approval.","Retry is bounded to three lineage attempts.","Non-convergence escalates."],"transaction":{"atomic":false,"rollback":"reconciliation_rollback_records_lineage_without_mutating_prior_graph_versions"},"semantic_id":"node.contract.validated_graph_to_execution","original_source_spec_type":"api_spec","source_refs":["api_spec.md#execution","prd.md#execution-behavior"]}'::jsonb, 'api_spec', 'db1e139f-062a-5f48-b152-dddb6661485c', '2026-06-02T12:00:00.000Z'),
('4e9fbce2-0516-5e26-aded-e9d15fbe5823', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'integration_contract', 'ProviderPreflight', '{"steps":[{"interface_id":"node.interface.connect_workspace_integration","input_mapping":{"workspace_id":"Workspace.id","provider":"github"}},{"interface_id":"node.interface.connect_workspace_integration","input_mapping":{"workspace_id":"Workspace.id","provider":"vercel"}}],"error_handling":["Do not commit provider secrets.","Record provider metadata only.","Use fresh isolated Supabase branch/project for this attempt."],"transaction":{"atomic":false,"rollback":"unlink_provider_metadata_without_deleting_external_artifacts"},"semantic_id":"node.contract.provider_preflight","original_source_spec_type":"techarch","source_refs":["api_spec.md#workspace-integrations","techarch.md#external-runtime-dependencies"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('d96719f9-62cf-5955-a543-9fa0e7b73062', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'flow', 'DocumentationModeFlow', '{"integration_contract_ids":["node.contract.new_project_to_validated_graph"],"feature_groupings":["Documentation Mode","Graph Construction","Validation"],"semantic_id":"node.flow.documentation_mode","original_source_spec_type":"uiux","source_refs":["prd.md#documentation-mode","uiux.md#documentation-mode"]}'::jsonb, 'uiux', '9f4ae953-a561-50fa-b9a3-f2110187bb65', '2026-06-02T12:00:00.000Z'),
('c75231ca-6f69-5af0-80b6-f275695969f9', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'flow', 'ExecutionModeFlow', '{"integration_contract_ids":["node.contract.validated_graph_to_execution"],"feature_groupings":["Graph Governed Execution","Validation And Reconciliation"],"semantic_id":"node.flow.execution_mode","original_source_spec_type":"uiux","source_refs":["prd.md#execution-mode","uiux.md#execution-mode"]}'::jsonb, 'uiux', '9f4ae953-a561-50fa-b9a3-f2110187bb65', '2026-06-02T12:00:00.000Z'),
('1475869c-d891-5ce5-9235-34a08dce90fb', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'flow', 'ProviderWiringFlow', '{"integration_contract_ids":["node.contract.provider_preflight"],"feature_groupings":["Provider Wiring"],"semantic_id":"node.flow.provider_wiring","original_source_spec_type":"techarch","source_refs":["techarch.md#external-runtime-dependencies","api_spec.md#workspace-integrations"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('5a9721be-5135-510d-82c9-2a711a0e370d', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'invariant', 'GraphSelfContained', '{"rule":"Every graph reference resolves inside the graph or to an explicit source document reference.","scope":"graph","severity":"blocking","invariant_id":"G1","semantic_id":"node.invariant.graph_self_contained","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#graph-invariants","nfr.md#graph-integrity-constraint"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('7ac4f51a-29a8-5424-8522-c6d47f175b78', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'invariant', 'ApprovedNodeTypesOnly', '{"rule":"Normalized graph nodes must use only entity, interface, integration_contract, flow, invariant, and execution_boundary.","scope":"normalized_graph","severity":"blocking","invariant_id":"G2","semantic_id":"node.invariant.approved_node_types_only","original_source_spec_type":"systemdesign","source_refs":["systemdesign.md#canonical-graph-structures","db_schema.md#graph_nodes"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('ac177801-e5a9-52d8-a40a-b182e6f8dd7f', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'invariant', 'ExplicitInterfaceContracts', '{"rule":"Interfaces must define input, output, preconditions, postconditions, success examples, and failure examples.","scope":"interfaces","severity":"blocking","invariant_id":"I1","semantic_id":"node.invariant.explicit_interface_contracts","original_source_spec_type":"nfr","source_refs":["v_4.3.md#interface","nfr.md#interface-integrity-constraint"]}'::jsonb, 'nfr', '67a0e984-c23d-5374-b639-e4ffaafb36f5', '2026-06-02T12:00:00.000Z'),
('21b0156b-289e-5963-a097-f99199517bf4', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'invariant', 'AcyclicTaskDag', '{"rule":"Task graph dependencies must be acyclic and topologically executable.","scope":"task_graph","severity":"blocking","invariant_id":"E2","semantic_id":"node.invariant.acyclic_task_dag","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#task-graph-orchestration","prd.md#task-dag-generation"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('7693e81a-3a83-5ffa-8253-5cf4cd10b4d6', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'invariant', 'UiFromDesignOnly', '{"rule":"UI implementation derives from UI/UX and DESIGN artifacts; UI fixes mutate design artifacts, not logic graph structures.","scope":"ui_graph","severity":"blocking","invariant_id":"D1","semantic_id":"node.invariant.ui_from_design_only","original_source_spec_type":"uiux","source_refs":["v_4.3.md#ui-invariants","uiux.md#graph-visibility-principle","DESIGN.md#brand-style"]}'::jsonb, 'uiux', '9f4ae953-a561-50fa-b9a3-f2110187bb65', '2026-06-02T12:00:00.000Z'),
('17ad7257-a0e5-544d-80bd-a39982caec84', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'execution_boundary', 'DocsToGraphBoundary', '{"included_node_ids":["node.interface.publish_specification_revision","node.interface.construct_concept_graph","node.interface.normalize_graph","node.interface.validate_graph","node.contract.new_project_to_validated_graph","node.flow.documentation_mode"],"dependency_scope":"Docs manifest, concept extraction, normalization, validation.","semantic_id":"node.boundary.docs_to_graph","original_source_spec_type":"v_4_3","source_refs":["v_4.3.md#operational-procedure","prd.md#graph-construction-requirements"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('ad46bf56-1b36-5c34-a0e1-e825cc6adc7c', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'execution_boundary', 'PersistenceBoundary', '{"included_node_ids":["node.entity.graph_node","node.entity.graph_edge","node.entity.graph_version","node.entity.execution_run","node.entity.execution_task","node.entity.approval"],"dependency_scope":"Supabase/Postgres schema, RLS, immutable graph/event tables.","semantic_id":"node.boundary.persistence","original_source_spec_type":"db_schema","source_refs":["db_schema.md#schema-design-principles","techarch.md#supabase-persistence"]}'::jsonb, 'db_schema', 'b3eba076-7f59-5cdf-a9f2-3ff57d77d2e7', '2026-06-02T12:00:00.000Z'),
('648de374-465d-524b-a63b-dfd5e67dc7eb', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'execution_boundary', 'ApiRuntimeBoundary', '{"included_node_ids":["node.interface.generate_task_graph","node.interface.start_execution","node.interface.reconcile_execution_output","node.contract.validated_graph_to_execution"],"dependency_scope":"Next.js server APIs, authorization, service modules.","semantic_id":"node.boundary.api_runtime","original_source_spec_type":"techarch","source_refs":["techarch.md#application-runtime","api_spec.md#execution"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z'),
('aa5e0e6c-9e4d-5f08-8bf7-d15eb4cd3fcc', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'execution_boundary', 'UiRuntimeBoundary', '{"included_node_ids":["node.flow.documentation_mode","node.flow.execution_mode","node.invariant.ui_from_design_only"],"dependency_scope":"UI shell, 13 screen hierarchy, progressive disclosure, graph inspection.","semantic_id":"node.boundary.ui_runtime","original_source_spec_type":"uiux","source_refs":["uiux.md#navigation-and-workspace-architecture","DESIGN.md#components"]}'::jsonb, 'uiux', '9f4ae953-a561-50fa-b9a3-f2110187bb65', '2026-06-02T12:00:00.000Z'),
('972c655c-c498-50b4-9246-c90cef5852b0', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'execution_boundary', 'ServiceWiringBoundary', '{"included_node_ids":["node.interface.connect_workspace_integration","node.contract.provider_preflight","node.flow.provider_wiring","node.entity.service_integration"],"dependency_scope":"GitHub remote, Vercel project, fresh Supabase branch/project, secret isolation.","semantic_id":"node.boundary.service_wiring","original_source_spec_type":"techarch","source_refs":["techarch.md#external-runtime-dependencies","api_spec.md#workspace-integrations"]}'::jsonb, null, null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.graph_edges (id, project_id, graph_version_id, edge_type, source_node_id, target_node_id, metadata, created_at) values
('e0cbc65b-205e-52a3-b973-a31788ae8049', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', '6099959a-fd2b-58d0-ab85-207ed4f87a1b', '8a6851fc-7016-5219-a328-1ca1b85890aa', '{"reason":"Project belongs to a workspace.","semantic_id":"edge.project_depends_workspace","semantic_source_node_id":"node.entity.project","semantic_target_node_id":"node.entity.workspace"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('85cdf0e0-effe-5910-9e69-ce7c33b0954b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', 'ebbcad01-59bd-5349-8e00-169a53732a6f', '6099959a-fd2b-58d0-ab85-207ed4f87a1b', '{"reason":"Specification revisions are project-scoped.","semantic_id":"edge.spec_revision_depends_project","semantic_source_node_id":"node.entity.specification_revision","semantic_target_node_id":"node.entity.project"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('920bf6f2-eeaa-59da-9089-0aa5af65f733', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', '2e92ab68-92a9-52ca-8881-37b9b12ba284', 'c0c9c96a-3f9a-5b04-bd43-a9502aa8f580', '{"reason":"Graph nodes are immutable members of graph versions.","semantic_id":"edge.graph_node_depends_version","semantic_source_node_id":"node.entity.graph_node","semantic_target_node_id":"node.entity.graph_version"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('5373882b-7fb9-5e54-a417-4540830ac861', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', '1252ffef-4065-54fe-b427-ffc759365bec', '2e92ab68-92a9-52ca-8881-37b9b12ba284', '{"reason":"Graph edges connect graph nodes.","semantic_id":"edge.graph_edge_depends_graph_node","semantic_source_node_id":"node.entity.graph_edge","semantic_target_node_id":"node.entity.graph_node"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('20e42deb-e43f-57f4-b2f6-c22c7e291666', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'implements', 'f3f18b5c-6429-5fbd-8aa1-009b2a8a18a5', 'ebbcad01-59bd-5349-8e00-169a53732a6f', '{"output":"revision","semantic_id":"edge.publish_implements_spec_revision","semantic_source_node_id":"node.interface.publish_specification_revision","semantic_target_node_id":"node.entity.specification_revision"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('3133c606-6cb7-50ee-803f-ee6a4d1665ad', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'implements', '1f7f1a3f-9d9b-5c1c-ba3b-58ffc91d44d0', 'c0c9c96a-3f9a-5b04-bd43-a9502aa8f580', '{"output":"graph_version","semantic_id":"edge.construct_implements_graph_version","semantic_source_node_id":"node.interface.construct_concept_graph","semantic_target_node_id":"node.entity.graph_version"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('c4995ace-f2d1-558d-9c5d-628502831c2b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'implements', 'dd3b140b-402c-529c-9212-d4947aa37956', 'c0c9c96a-3f9a-5b04-bd43-a9502aa8f580', '{"output":"graph_version","semantic_id":"edge.normalize_implements_graph_version","semantic_source_node_id":"node.interface.normalize_graph","semantic_target_node_id":"node.entity.graph_version"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('8a6f97ca-5c1f-59a9-938c-2e93ce8b14af', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'implements', 'b071961c-acb3-5d4b-b73c-157e31e69acf', 'adde85df-55ed-5141-8f71-1a11efc5e744', '{"output":"execution_run","semantic_id":"edge.start_implements_execution_run","semantic_source_node_id":"node.interface.start_execution","semantic_target_node_id":"node.entity.execution_run"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('1576e6ae-0f15-5178-9b11-3f875c632a40', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'implements', '39739b89-e596-5d6e-847f-76e01eb3c3da', '78a5a4f8-72f6-5796-81be-554535925119', '{"output":"integration","semantic_id":"edge.integration_implements_service_integration","semantic_source_node_id":"node.interface.connect_workspace_integration","semantic_target_node_id":"node.entity.service_integration"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('f5665896-00ea-532c-9473-8a6bf35694cd', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'precedes', 'f3f18b5c-6429-5fbd-8aa1-009b2a8a18a5', '1f7f1a3f-9d9b-5c1c-ba3b-58ffc91d44d0', '{"contract":"NewProjectToValidatedGraph","semantic_id":"edge.publish_precedes_construct","semantic_source_node_id":"node.interface.publish_specification_revision","semantic_target_node_id":"node.interface.construct_concept_graph"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('c585cb17-d685-592d-861b-08a1ed158ddd', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'precedes', '1f7f1a3f-9d9b-5c1c-ba3b-58ffc91d44d0', 'dd3b140b-402c-529c-9212-d4947aa37956', '{"contract":"NewProjectToValidatedGraph","semantic_id":"edge.construct_precedes_normalize","semantic_source_node_id":"node.interface.construct_concept_graph","semantic_target_node_id":"node.interface.normalize_graph"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('9371ffad-558c-55e6-8fb3-0712c7c96202', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'precedes', 'dd3b140b-402c-529c-9212-d4947aa37956', 'a61c4195-36a0-5d39-a069-0084624282f7', '{"contract":"NewProjectToValidatedGraph","semantic_id":"edge.normalize_precedes_validate","semantic_source_node_id":"node.interface.normalize_graph","semantic_target_node_id":"node.interface.validate_graph"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('b851e5c7-ca80-59ea-81ca-408e7a601a4b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'triggers', 'a61c4195-36a0-5d39-a069-0084624282f7', '2814fbc2-83d5-5bc2-9bb6-a40b191063b7', '{"condition":"validation_passed","semantic_id":"edge.validate_triggers_task_graph","semantic_source_node_id":"node.interface.validate_graph","semantic_target_node_id":"node.interface.generate_task_graph"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('23ae161f-a0b3-55a5-857c-c161a4a43d50', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'precedes', '2814fbc2-83d5-5bc2-9bb6-a40b191063b7', 'b071961c-acb3-5d4b-b73c-157e31e69acf', '{"condition":"valid_non_expired_execution_approval","semantic_id":"edge_task_graph_precedes_execution","semantic_source_node_id":"node.interface.generate_task_graph","semantic_target_node_id":"node.interface.start_execution"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('b0031e2b-e506-5f42-bcd9-bf3bc36ac553', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'precedes', 'b071961c-acb3-5d4b-b73c-157e31e69acf', '6c460c56-109e-5c67-a11e-1d79ef95797b', '{"contract":"ValidatedGraphToExecution","semantic_id":"edge_execution_precedes_reconciliation","semantic_source_node_id":"node.interface.start_execution","semantic_target_node_id":"node.interface.reconcile_execution_output"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('4d90e661-9e94-5678-82b7-b81e1dea94a4', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', 'd96719f9-62cf-5955-a543-9fa0e7b73062', 'd4b6c765-f1fc-5d38-95e4-3c434fbc32e8', '{"relationship":"flow_contract","semantic_id":"edge_contract_owns_doc_flow","semantic_source_node_id":"node.flow.documentation_mode","semantic_target_node_id":"node.contract.new_project_to_validated_graph"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('e971ca37-28a5-5f23-8120-583ec546cb9a', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', 'c75231ca-6f69-5af0-80b6-f275695969f9', '6226c369-5a47-5df1-a8bd-ab23cf4525aa', '{"relationship":"flow_contract","semantic_id":"edge_contract_owns_execution_flow","semantic_source_node_id":"node.flow.execution_mode","semantic_target_node_id":"node.contract.validated_graph_to_execution"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('f81c0392-ad52-53ef-814d-309f65fc45b0', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', '1475869c-d891-5ce5-9235-34a08dce90fb', '4e9fbce2-0516-5e26-aded-e9d15fbe5823', '{"relationship":"flow_contract","semantic_id":"edge_contract_owns_provider_flow","semantic_source_node_id":"node.flow.provider_wiring","semantic_target_node_id":"node.contract.provider_preflight"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('056a5e75-8766-5711-b1b2-837e5b383a21', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', '17ad7257-a0e5-544d-80bd-a39982caec84', 'd96719f9-62cf-5955-a543-9fa0e7b73062', '{"relationship":"execution_scope","semantic_id":"edge_docs_boundary_owns_doc_flow","semantic_source_node_id":"node.boundary.docs_to_graph","semantic_target_node_id":"node.flow.documentation_mode"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('dcd5b35d-3780-5524-b9e8-4e6ba2178384', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', '648de374-465d-524b-a63b-dfd5e67dc7eb', 'c75231ca-6f69-5af0-80b6-f275695969f9', '{"relationship":"execution_scope","semantic_id":"edge_api_boundary_owns_execution_flow","semantic_source_node_id":"node.boundary.api_runtime","semantic_target_node_id":"node.flow.execution_mode"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('2fb35b4d-80b9-5aeb-8014-d1eaa5621b42', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', 'aa5e0e6c-9e4d-5f08-8bf7-d15eb4cd3fcc', '7693e81a-3a83-5ffa-8253-5cf4cd10b4d6', '{"relationship":"ui_scope","semantic_id":"edge_ui_boundary_owns_design_invariant","semantic_source_node_id":"node.boundary.ui_runtime","semantic_target_node_id":"node.invariant.ui_from_design_only"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('dd443932-6f4c-50d9-8da3-525f84158d43', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'owns', '972c655c-c498-50b4-9246-c90cef5852b0', '1475869c-d891-5ce5-9235-34a08dce90fb', '{"relationship":"execution_scope","semantic_id":"edge_service_boundary_owns_provider_flow","semantic_source_node_id":"node.boundary.service_wiring","semantic_target_node_id":"node.flow.provider_wiring"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('59dac055-8776-5f3f-93b0-16155ead98e5', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', 'dd3b140b-402c-529c-9212-d4947aa37956', '7ac4f51a-29a8-5424-8522-c6d47f175b78', '{"relationship":"validation_rule","semantic_id":"edge_invariant_applies_normalize","semantic_source_node_id":"node.interface.normalize_graph","semantic_target_node_id":"node.invariant.approved_node_types_only"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('ef5326cf-403b-5de5-ac4f-89a3f030c1a8', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', '2814fbc2-83d5-5bc2-9bb6-a40b191063b7', '21b0156b-289e-5963-a097-f99199517bf4', '{"relationship":"validation_rule","semantic_id":"edge_invariant_applies_generate_task_graph","semantic_source_node_id":"node.interface.generate_task_graph","semantic_target_node_id":"node.invariant.acyclic_task_dag"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('c2f2a33a-be23-5645-9783-cefc0242053e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '80243da9-c3a3-5321-a92d-ced459b3178a', 'dependency', 'b071961c-acb3-5d4b-b73c-157e31e69acf', 'ac177801-e5a9-52d8-a40a-b182e6f8dd7f', '{"relationship":"validation_rule","semantic_id":"edge_invariant_applies_interfaces","semantic_source_node_id":"node.interface.start_execution","semantic_target_node_id":"node.invariant.explicit_interface_contracts"}'::jsonb, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.semantic_diffs (id, project_id, from_version_id, to_version_id, diff_payload, created_at)
values ('935adb14-6953-5f24-9b4f-a423a14a736c', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', null, '80243da9-c3a3-5321-a92d-ced459b3178a', '{"seeded_from":"graph/normalized_graph.json","node_count":34,"edge_count":25}'::jsonb, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

update public.projects
set active_branch_id = '5699f3c6-4af2-5de7-b302-9e71f368587e', active_graph_version_id = '80243da9-c3a3-5321-a92d-ced459b3178a', updated_at = '2026-06-02T12:00:00.000Z'
where id = '755efd2a-ad2d-5454-b952-9f4d4e72c6c5';

insert into public.events (id, project_id, branch_id, event_type, sequence_number, actor_id, originating_subsystem, affected_scope, source_state, target_state, metadata, created_at) values
('c684b402-1704-5c86-aac2-4ee4dec581ae', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', 'SpecificationCreated', 1, '3b375490-2133-5e97-a59a-a39948a78ff5', 'seed_migration', '{"spec_count":8}'::jsonb, null, 'documents_seeded', '{"migration":"seed_sembl_core_runtime"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('45803f6e-de39-59a9-be90-240f5dcb264b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', 'GraphMutationCommitted', 2, '3b375490-2133-5e97-a59a-a39948a78ff5', 'seed_migration', '{"graph_version_id":"80243da9-c3a3-5321-a92d-ced459b3178a","node_count":34,"edge_count":25}'::jsonb, null, 'graph_seeded', '{"migration":"seed_sembl_core_runtime"}'::jsonb, '2026-06-02T12:00:00.000Z'),
('0cc07d17-ee61-5df3-8f13-136101664e3f', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', 'ExecutionApprovalRequested', 3, '3b375490-2133-5e97-a59a-a39948a78ff5', 'seed_migration', '{"approval_id":"86268e63-ee16-5e39-aa7a-20bfeb553034"}'::jsonb, null, 'awaiting_approval', '{"migration":"seed_sembl_core_runtime"}'::jsonb, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.validation_run_groups (id, project_id, branch_id, target_type, target_id, status, completed_at, created_at)
values ('ed480df7-7d1b-513a-aff2-fd37bc37caec', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', 'repository_ingestion', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'passed', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.validation_runs (id, group_id, project_id, pass_number, status, completed_at, created_at) values
('d952cc4e-4526-5edc-93d7-175376216b82', 'ed480df7-7d1b-513a-aff2-fd37bc37caec', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 1, 'passed', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z'),
('b1b56a9a-9a33-5cd7-96c0-69f6de670e84', 'ed480df7-7d1b-513a-aff2-fd37bc37caec', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 2, 'passed', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z'),
('8fe0a634-a64b-54c1-82c7-27b0e60beb3e', 'ed480df7-7d1b-513a-aff2-fd37bc37caec', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 3, 'passed', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.approvals (id, project_id, branch_id, approval_type, status, requested_by, affected_scope, mutation_summary, expires_at, created_at, updated_at)
values ('86268e63-ee16-5e39-aa7a-20bfeb553034', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', 'execution_approval', 'pending', '3b375490-2133-5e97-a59a-a39948a78ff5', '{"graph_version_id":"80243da9-c3a3-5321-a92d-ced459b3178a","execution_boundary":"node.boundary.api_runtime"}'::jsonb, '{"summary":"Approve graph-scoped execution from the validated V4.3 task DAG.","impact_score":0.74,"impacted_nodes":["node.interface.generate_task_graph","node.interface.start_execution","node.interface.reconcile_execution_output"]}'::jsonb, '2026-06-09T00:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.execution_runs (id, project_id, branch_id, graph_version_id, approval_id, status, triggered_by, metadata, created_at, updated_at)
values ('05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', '80243da9-c3a3-5321-a92d-ced459b3178a', '86268e63-ee16-5e39-aa7a-20bfeb553034', 'queued', null, '{"seeded_from":"graph/task_graph.json"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.execution_tasks (id, execution_run_id, project_id, execution_boundary_node_id, sequence_number, status, dependency_task_ids, output_payload, started_at, completed_at, failure_reason, created_at) values
('163be4dd-d0a9-562b-a4ad-e72f741ff3ca', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', null, 1, 'completed', '{}'::uuid[], '{"task_id":"task.00.reset_and_bootstrap","name":"Reset And Bootstrap Graph Workspace","agent":"Mechanic","graph_scope":["node.invariant.graph_self_contained"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('5facdda0-7f74-5d89-8d7b-f6bc7b8518a7', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '17ad7257-a0e5-544d-80bd-a39982caec84', 2, 'completed', array['163be4dd-d0a9-562b-a4ad-e72f741ff3ca']::uuid[], '{"task_id":"task.01.docs_manifest","name":"Create Canonical Docs Manifest","agent":"Cartographer","graph_scope":["node.invariant.graph_self_contained"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('93f6c81e-6b58-579d-bdea-b0927a0e9fac', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '17ad7257-a0e5-544d-80bd-a39982caec84', 3, 'completed', array['5facdda0-7f74-5d89-8d7b-f6bc7b8518a7']::uuid[], '{"task_id":"task.02.extract_concept_graph","name":"Extract Concept Graph From Canonical Docs","agent":"Cartographer","graph_scope":["node.entity.workspace","node.entity.project","node.entity.specification_revision","node.interface.publish_specification_revision","node.interface.construct_concept_graph"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('ba4f0c1f-5faf-55a4-9faa-5088422cae7c', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'aa5e0e6c-9e4d-5f08-8bf7-d15eb4cd3fcc', 4, 'completed', array['5facdda0-7f74-5d89-8d7b-f6bc7b8518a7']::uuid[], '{"task_id":"task.03.extract_ui_graph","name":"Extract UI Graph And Design Artifact","agent":"UI Steward","graph_scope":["node.invariant.ui_from_design_only","node.boundary.ui_runtime"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('685c09ff-eb6f-5ff4-8ec2-d18e6f43c548', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '17ad7257-a0e5-544d-80bd-a39982caec84', 5, 'completed', array['93f6c81e-6b58-579d-bdea-b0927a0e9fac', 'ba4f0c1f-5faf-55a4-9faa-5088422cae7c']::uuid[], '{"task_id":"task.04.normalize_graph","name":"Normalize Concept And UI Graphs","agent":"Cartographer","graph_scope":["node.interface.normalize_graph","node.invariant.approved_node_types_only","node.invariant.explicit_interface_contracts"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('9d6e9902-518d-52d3-b9c8-f99ec2ec134c', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '17ad7257-a0e5-544d-80bd-a39982caec84', 6, 'completed', array['685c09ff-eb6f-5ff4-8ec2-d18e6f43c548']::uuid[], '{"task_id":"task.05.generate_task_dag","name":"Generate Executable Task DAG And Packets","agent":"Planner","graph_scope":["node.interface.generate_task_graph","node.invariant.acyclic_task_dag"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', null, '2026-06-02T12:00:00.000Z'),
('35adc281-85c0-56ee-ab01-061d8c54e7c7', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '972c655c-c498-50b4-9246-c90cef5852b0', 7, 'running', array['9d6e9902-518d-52d3-b9c8-f99ec2ec134c']::uuid[], '{"task_id":"task.06.service_preflight","name":"Run Fresh Isolated Service Preflight","agent":"Service Steward","graph_scope":["node.interface.connect_workspace_integration","node.contract.provider_preflight","node.boundary.service_wiring"],"context_persisted":false}'::jsonb, '2026-06-02T12:00:00.000Z', null, null, '2026-06-02T12:00:00.000Z'),
('535ae1cc-1516-58df-bce7-05d63502df6f', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'ad46bf56-1b36-5c34-a0e1-e825cc6adc7c', 8, 'pending', array['35adc281-85c0-56ee-ab01-061d8c54e7c7']::uuid[], '{"task_id":"task.07.persistence_foundation","name":"Implement Supabase Persistence Foundation","agent":"Data Steward","graph_scope":["node.boundary.persistence","node.entity.graph_node","node.entity.graph_edge","node.entity.graph_version","node.entity.execution_run","node.entity.execution_task"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z'),
('496239cd-c506-5787-9735-671e3cf56cdb', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '648de374-465d-524b-a63b-dfd5e67dc7eb', 9, 'pending', array['535ae1cc-1516-58df-bce7-05d63502df6f']::uuid[], '{"task_id":"task.08.api_runtime_foundation","name":"Implement API Runtime Foundation","agent":"Interface Steward","graph_scope":["node.boundary.api_runtime","node.interface.publish_specification_revision","node.interface.validate_graph","node.interface.generate_task_graph","node.interface.start_execution","node.interface.reconcile_execution_output"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z'),
('c1deb266-4061-5b9e-8c00-6c89bc1a196f', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '648de374-465d-524b-a63b-dfd5e67dc7eb', 10, 'pending', array['496239cd-c506-5787-9735-671e3cf56cdb']::uuid[], '{"task_id":"task.09.planner_execution_foundation","name":"Implement Planner And Execution Runtime","agent":"Builder","graph_scope":["node.interface.generate_task_graph","node.interface.start_execution","node.entity.execution_run","node.entity.execution_task","node.invariant.acyclic_task_dag"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z'),
('54f5bbce-d49b-53a6-9f8e-0a9c0da9722c', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', 'aa5e0e6c-9e4d-5f08-8bf7-d15eb4cd3fcc', 11, 'pending', array['496239cd-c506-5787-9735-671e3cf56cdb']::uuid[], '{"task_id":"task.10.ui_foundation","name":"Implement UI Foundation","agent":"UI Steward","graph_scope":["node.boundary.ui_runtime","node.invariant.ui_from_design_only"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z'),
('16a64556-35fe-5553-aa4b-e94da452a3e6', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', null, 12, 'pending', array['c1deb266-4061-5b9e-8c00-6c89bc1a196f', '54f5bbce-d49b-53a6-9f8e-0a9c0da9722c']::uuid[], '{"task_id":"task.11.integration_validation","name":"Run Integration Validation And Reconciliation Loop","agent":"Integrator","graph_scope":["node.invariant.graph_self_contained","node.invariant.explicit_interface_contracts","node.invariant.ui_from_design_only","node.invariant.acyclic_task_dag"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z'),
('f6111d8c-1528-5b8b-bd79-24d5dd20a776', '05844cf7-9dcf-5807-a2a2-10c86519b378', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', null, 13, 'pending', array['16a64556-35fe-5553-aa4b-e94da452a3e6']::uuid[], '{"task_id":"task.12_release_readiness","name":"Verify Release Readiness","agent":"Gatekeeper","graph_scope":["node.flow.execution_mode","node.flow.provider_wiring"],"context_persisted":false}'::jsonb, null, null, null, '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.reconciliation_attempts (id, project_id, branch_id, execution_run_id, merge_attempt_id, status, snapshot_version_id, output_version_id, semantic_diff_id, failure_reason, started_at, created_at, updated_at)
values ('9bd04430-73be-54b5-bc34-15ca1c05bf86', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', '05844cf7-9dcf-5807-a2a2-10c86519b378', null, 'diff_generated', '80243da9-c3a3-5321-a92d-ced459b3178a', null, '935adb14-6953-5f24-9b4f-a423a14a736c', null, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.deployments (id, project_id, branch_id, graph_version_id, execution_run_id, provider, provider_deployment_id, provider_url, environment, status, triggered_by, deployed_at, health_verified_at, metadata, created_at, updated_at)
values ('0020e5d0-412b-5593-9b9f-1f21fcb0968e', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '5699f3c6-4af2-5de7-b302-9e71f368587e', '80243da9-c3a3-5321-a92d-ced459b3178a', '05844cf7-9dcf-5807-a2a2-10c86519b378', 'vercel', null, 'https://sembl.vercel.app', 'production', 'healthy', '3b375490-2133-5e97-a59a-a39948a78ff5', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '{"seeded_from":"vercel production alias"}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.repository_ingestion_runs (id, project_id, repository_reference_id, status, output_graph_version_id, triggered_by, analysis_metadata, started_at, activated_at, created_at, updated_at)
values ('6ea7f19b-8958-5a53-8b4c-498209677ba7', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '16794891-b724-57d9-8a53-b33c561569a9', 'activated', '80243da9-c3a3-5321-a92d-ced459b3178a', '3b375490-2133-5e97-a59a-a39948a78ff5', '{"validation_status":"passed","service_preflight":{"github":{"status":"passed","remote":"https://github.com/speedvibecode/sembl.git","reachable":true,"notes":["Remote `origin` is configured for fetch and push.","`git ls-remote --heads origin` exited successfully.","No remote heads were returned because the repository has no pushed branch yet."]},"vercel":{"status":"passed","account":"speedvibecode","scope":"speedvibecodes-projects","project":"sembl","project_id":"prj_rrxojufspyLWE3TzTFYl5lb2i9Ly","org_id":"team_szShy84DGvNei7AjoPrKhtCm","linked":true,"local_metadata":".vercel/project.json","notes":["Created Vercel project `sembl`.","Linked local repo to `speedvibecodes-projects/sembl`.","`.vercel` is ignored by `.gitignore` and contains no provider tokens."]},"supabase":{"status":"takeover_reset_complete","project_url":"https://djquuvkwnjpweubzrsnn.supabase.co","fresh_isolated_state":true,"takeover_existing_project":true,"destructive_approval":{"received":true,"received_at":"2026-06-01T16:33:40.3990886+05:30","approved_scope":"Drop old app-owned public schema state and clear old Sembl migration history for https://djquuvkwnjpweubzrsnn.supabase.co.","execution_status":"reset_complete_verified","verified_at":"2026-06-01T16:54:36.6851277+05:30"},"existing_migration_history_detected":false,"inventory":{"public_tables":[],"public_types":[],"public_table_rows_observed":0,"edge_functions":[],"old_migration_history_rows":0,"system_schema_count":5,"public_schema_exists":true},"existing_migrations":["20260531102807_initial_sembl_v1","20260531103921_deferrable_reconciliation_constraints","20260531105144_security_and_index_hardening","20260531105749_drop_duplicate_fk_indexes","20260531112506_reset_graph_first_rebuild","20260531115309_graph_first_runtime_schema","20260531115421_runtime_schema_advisor_hardening"],"notes":["MCP is connected to an existing Supabase project with old Sembl migration history.","User preference changed from fresh branch/project to destructive takeover of the existing connected project.","Destructive reset approval was received, matching the takeover runbook target and scope.","Reset verification passed: public schema exists, old public tables/types are absent, old Sembl migration rows are absent, and Supabase-managed schemas remain present.","Supabase-backed build tasks may proceed from task.07."]}}}'::jsonb, '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

insert into public.notifications (id, workspace_id, project_id, recipient_user_id, severity, title, body, action_url, created_at)
values ('64d37068-253a-5342-ba85-cd80290fd2d4', '61253f13-ee87-5c45-84fe-668c8fc0e17b', '755efd2a-ad2d-5454-b952-9f4d4e72c6c5', '3b375490-2133-5e97-a59a-a39948a78ff5', 'action_required', 'Sembl Core seeded', 'The Supabase runtime now contains the Sembl Core graph, task DAG, validation state, and deployment record.', 'https://sembl.vercel.app', '2026-06-02T12:00:00.000Z')
on conflict (id) do nothing;

analyze public.workspaces;
analyze public.projects;
analyze public.graph_nodes;
analyze public.graph_edges;
analyze public.execution_tasks;

