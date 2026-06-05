# Sembl Build Failure Report

## Context

This document records why the Sembl build attempt failed and what should be avoided in the next clean-slate approach.

The intended product was not just a website. Sembl was meant to become a V4.3 software factory: specifications as first-class state, the semantic graph as canonical architecture, execution derived from that graph, durable Supabase persistence, provider-backed repository and deployment flows, and visible progress from intent to working software.

The delivered attempt did not reach that bar.

## What Went Wrong

### 1. The core workflow was not proven first

The most important path should have been proven before building broad UI surface area:

```text
sign in -> create project -> write spec -> compile graph -> approve -> generate build -> export repo -> deploy -> reconcile state
```

Instead, work spread across many product surfaces before one complete factory loop was durable and verifiable. That made the app look busy without making it trustworthy.

### 2. The backend was treated as an implementation detail too late

For Sembl, Supabase should have been the first truth test. Every meaningful action needed to create real rows, enforce ownership through RLS, and expose clear failure states when persistence was unavailable.

The build initially allowed too much behavior to exist as static state, seed data, generated artifacts, or local fallbacks. Even after later fixes pushed more logic through Supabase-backed APIs, the project had already accumulated a weak foundation and unclear trust boundaries.

### 3. The app did not feel like a software factory

The UI exposed concepts such as specs, graph, validation, execution, and artifacts, but it did not guide a user toward successfully building a new project. The product needed a clear factory console with a dominant creation flow, not just panels that described parts of the philosophy.

The experience should have made the next action obvious at every stage. It did not.

### 4. V4.3 became documentation instead of operating law

The V4.3 documents were strong, but the implementation did not consistently enforce them:

- specifications were not always the only mutation path
- the graph was not always the canonical operational state
- execution was not always derived from validated graph state
- validation did not always block false progress
- reconciliation was not the only path back into durable state

That gap is the central product failure.

### 5. The system overpromised through UI states

The user-visible interface made too many states look complete before the backend could prove them. A software factory cannot have fake green paths. If a provider, credential, database transition, model call, repo export, or deployment is missing, the product must show a blocked state instead of simulating success.

### 6. Provider integration was not made narrow and real enough

The real acceptance bar required working GitHub, Vercel, Supabase, and OpenAI paths. The attempt did not reduce those integrations into a small verified slice soon enough:

- GitHub should have been proven with a generated repository or commit export
- Vercel should have been proven with a deployed generated project
- Supabase should have been proven with authenticated mutations and RLS checks
- OpenAI should have been proven with a server-validated GPT-5 family model path and no persisted user key by default

Without that slice, the product could not honestly claim to build software.

### 7. Testing did not match the risk

The app needed an authenticated end-to-end test that exercised the full factory loop against real backend state. Build, typecheck, and isolated API checks were not enough.

The correct test should have failed unless all of these were true:

- a real user session exists
- project/spec mutations persist
- graph compilation creates durable graph records
- approval changes state
- execution creates tasks and outputs
- generated code can be exported
- deployment state is recorded
- no fake fallback is used

That test should have been the main release gate.

### 8. The implementation attempted too much in one pass

The scope combined product architecture, database design, auth, graph compilation, AI model tooling, execution orchestration, reconciliation, UI redesign, GitHub export, Vercel deployment, seed data, E2E testing, and production rollout.

That was too much to stabilize in one build pass. The result was breadth without enough depth.

### 9. The deployment made the failure more visible

Shipping a partial Sembl to production made the gap impossible to ignore. The production site existed, but it did not deserve the confidence implied by a live deployment.

The deployment should have been held until the factory path could be proven from a clean account and a clean project.

## Root Cause

The root cause was sequencing.

Sembl needed a small, real, vertical slice first:

```text
Auth + Project + Spec + Graph + Build Artifact + GitHub Export + Vercel Deploy
```

Only after that loop worked should the system have expanded into richer graph visualization, validation dashboards, reconciliation history, notifications, and multi-stage orchestration.

Instead, the implementation tried to represent the whole V4.3 operating system before proving the smallest useful software factory.

## What A Better Rebuild Should Do

Start from a clean slate and build in this order:

1. Real Supabase Auth and workspace/project ownership.
2. One durable project creation flow.
3. One specification editor that saves every change.
4. One graph compiler that persists a canonical graph revision.
5. One approval gate that blocks execution.
6. One generator that creates a small real app from graph state.
7. One export path to GitHub.
8. One deployment path to Vercel.
9. One reconciliation record that proves what was produced.
10. One E2E test that starts from sign-in and ends at a live deployed app.

Everything else should wait.

## Cleanup Decision

The current implementation is not worth preserving as application code. The useful remnants are the product documents, this failure report, and the Supabase reset SQL needed to return the backend to a clean state.

The repository should be reduced to documentation only so the next approach starts without inherited implementation debt.
