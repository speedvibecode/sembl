# UI/UX Specification — Section 1

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






