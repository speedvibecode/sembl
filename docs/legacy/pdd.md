# PDD — Product Definition Document

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
