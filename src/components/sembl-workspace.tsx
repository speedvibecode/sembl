"use client";

import {
  Activity,
  AlertTriangle,
  ArrowRight,
  Check,
  CircleDot,
  Code2,
  GitBranch,
  Layers3,
  Loader2,
  LogOut,
  Play,
  Plus,
  RefreshCw,
  Rocket,
  Save,
  ScrollText,
  Search,
  ShieldCheck,
  SlidersHorizontal,
  Sparkles,
  Timer,
  Workflow,
  X
} from "lucide-react";
import {
  Background,
  Controls,
  MiniMap,
  ReactFlow,
  type Edge as FlowEdge,
  type Node as FlowNode
} from "@xyflow/react";
import { useEffect, useMemo, useState } from "react";
import clsx from "clsx";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";
import type {
  Approval,
  ExecutionRun,
  GraphNode,
  ModelCatalogEntry,
  ProjectDirectory,
  RuntimeHomeData,
  SpecificationDraft
} from "@/lib/types";

type Props = {
  initialData: RuntimeHomeData | null;
  initialDirectory: ProjectDirectory;
};

type View =
  | "Overview"
  | "Specifications"
  | "Execution"
  | "Changes"
  | "Deployments"
  | "Settings";

type RequestState = {
  status: "idle" | "loading" | "success" | "error";
  message: string;
};

type ApiEnvelope<T> = { data: T; meta: Record<string, unknown> | null };
type ApiError = { error: { code: string; message: string } };
type SearchResult = {
  id: string;
  label: string;
  detail: string;
  view: View;
  kind: "spec" | "node" | "run";
};

const views: Array<{ id: View; icon: typeof Layers3 }> = [
  { id: "Overview", icon: Activity },
  { id: "Specifications", icon: ScrollText },
  { id: "Execution", icon: Play },
  { id: "Changes", icon: GitBranch },
  { id: "Deployments", icon: Rocket },
  { id: "Settings", icon: SlidersHorizontal }
];

const statusTone: Record<string, string> = {
  active: "healthy",
  approved: "healthy",
  completed: "healthy",
  committed: "healthy",
  healthy: "healthy",
  passed: "healthy",
  passed_with_warnings: "attention",
  ready_for_execution: "healthy",
  awaiting_approval: "awaiting",
  under_review: "awaiting",
  pending: "awaiting",
  queued: "awaiting",
  running: "informational",
  executing: "informational",
  reconciling: "informational",
  deploying: "informational",
  warning: "attention",
  failed: "blocked",
  rejected: "blocked",
  escalated: "escalated",
  draft: "muted",
  not_deployed: "muted"
};

const nodeColors: Record<string, string> = {
  entity: "#8fd6ff",
  interface: "#9db8ff",
  integration_contract: "#c4b5fd",
  flow: "#86efac",
  invariant: "#facc15",
  execution_boundary: "#f0abfc"
};

function StatusPill({
  label,
  icon: Icon = CircleDot
}: {
  label: string;
  icon?: typeof CircleDot;
}) {
  const tone = statusTone[label] ?? statusTone[label.toLowerCase()] ?? "muted";

  return (
    <span className={clsx("status-pill", `status-${tone}`)}>
      <Icon aria-hidden="true" size={14} />
      {label.replaceAll("_", " ")}
    </span>
  );
}

function SectionHeader({
  title,
  eyebrow,
  action
}: {
  title: string;
  eyebrow?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="section-header">
      <div>
        {eyebrow ? <p className="section-kicker">{eyebrow}</p> : null}
        <h2>{title}</h2>
      </div>
      {action}
    </div>
  );
}

function useApiClient(projectId?: string) {
  const supabase = useMemo(() => createSupabaseBrowserClient(), []);

  async function apiFetch<T>(path: string, init: RequestInit = {}) {
    const {
      data: { session }
    } = await supabase.auth.getSession();

    if (!session) {
      throw new Error("Session expired. Sign in again.");
    }

    const response = await fetch(path, {
      ...init,
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${session.access_token}`,
        ...(init.headers ?? {})
      }
    });
    const payload = (await response.json()) as ApiEnvelope<T> | ApiError;

    if (!response.ok || "error" in payload) {
      throw new Error("error" in payload ? payload.error.message : "Request failed.");
    }

    return payload.data;
  }

  async function refresh(nextProjectId = projectId) {
    if (!nextProjectId) {
      throw new Error("Create or open a project first.");
    }
    return apiFetch<RuntimeHomeData>(`/api/v1/projects/${nextProjectId}/state`);
  }

  return { apiFetch, refresh, supabase };
}

function formatSpecLabel(specType: string) {
  return specType
    .replaceAll("_", " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function latestRun(data: RuntimeHomeData) {
  return data.executions[0] ?? null;
}

function latestPendingApproval(data: RuntimeHomeData) {
  return data.approvals.find((approval) => approval.status === "pending");
}

function latestApprovedApproval(data: RuntimeHomeData) {
  return data.approvals.find((approval) => approval.status === "approved");
}

function Metric({
  label,
  value,
  detail
}: {
  label: string;
  value: string | number;
  detail?: string;
}) {
  return (
    <div className="metric-tile">
      <span>{label}</span>
      <strong>{value}</strong>
      {detail ? <small>{detail}</small> : null}
    </div>
  );
}

function OverviewView({
  data,
  onOpenSpecifications,
  onOpenExecution,
  onOpenChanges
}: {
  data: RuntimeHomeData;
  onOpenSpecifications: () => void;
  onOpenExecution: () => void;
  onOpenChanges: () => void;
}) {
  const pendingApproval = latestPendingApproval(data);
  const run = latestRun(data);
  const latestValidation = data.validationGroups[0] ?? null;
  const latestDeployment = data.deployments[0] ?? null;

  return (
    <section className="view-grid overview-view">
      <div className="panel project-brief">
        <SectionHeader
          title="Project Overview"
          eyebrow="Current operating state"
          action={<StatusPill label={data.snapshot.project.lifecycle_state} icon={Activity} />}
        />
        <div className="brief-grid">
          <article>
            <span>Intent source</span>
            <strong>{data.snapshot.counts.specifications} specifications</strong>
            <p>{data.snapshot.counts.dirty_specs} drafts changed since the latest published revision.</p>
            <button type="button" className="secondary-action" onClick={onOpenSpecifications}>
              <ScrollText size={16} />
              Open specifications
            </button>
          </article>
          <article>
            <span>Validation</span>
            <strong>{latestValidation?.status.replaceAll("_", " ") ?? "No validation yet"}</strong>
            <p>{latestValidation ? `${latestValidation.runs.length} validation passes recorded.` : "Publish a spec or compile the graph to create validation evidence."}</p>
            <button type="button" className="secondary-action" onClick={onOpenChanges}>
              <ShieldCheck size={16} />
              Review change health
            </button>
          </article>
          <article>
            <span>Execution</span>
            <strong>{run?.status.replaceAll("_", " ") ?? "No active run"}</strong>
            <p>{data.snapshot.counts.open_tasks} tasks are pending or running in the current execution state.</p>
            <button type="button" className="secondary-action" onClick={onOpenExecution}>
              <Play size={16} />
              Open execution
            </button>
          </article>
          <article>
            <span>Deployment</span>
            <strong>{latestDeployment?.status.replaceAll("_", " ") ?? "No deployment"}</strong>
            <p>{latestDeployment?.provider_url ?? "A completed execution will create deployment evidence."}</p>
          </article>
        </div>
      </div>

      <aside className="side-stack">
        <section className="panel">
          <SectionHeader title="Next Action" eyebrow="Truthful workflow" />
          {pendingApproval ? (
            <div className="empty-state">
              <StatusPill label="approval_required" icon={AlertTriangle} />
              <p>Execution is waiting for approval. Review impact and risk before starting work.</p>
              <button type="button" className="primary-action" onClick={onOpenExecution}>
                Review approval
              </button>
            </div>
          ) : data.snapshot.counts.dirty_specs > 0 ? (
            <div className="empty-state">
              <StatusPill label="draft" />
              <p>Specification drafts changed. Save, publish, then compile the graph to request execution approval.</p>
              <button type="button" className="primary-action" onClick={onOpenSpecifications}>
                Continue specs
              </button>
            </div>
          ) : (
            <div className="empty-state">
              <StatusPill label={data.snapshot.runtimeSource} icon={ShieldCheck} />
              <p>The workspace is connected to Supabase and ready for the next spec-to-execution change.</p>
            </div>
          )}
        </section>

        <section className="panel">
          <SectionHeader title="Recent Lineage" eyebrow="Append-only events" />
          <div className="table-list compact-list">
            {data.events.slice(0, 5).map((event) => (
              <article key={event.id} className="table-row">
                <div>
                  <strong>#{event.sequence_number} {event.event_type}</strong>
                  <span>{event.originating_subsystem}</span>
                </div>
                <small>{new Date(event.created_at).toLocaleString()}</small>
              </article>
            ))}
            {!data.events.length ? (
              <div className="empty-state">
                <p>No events have been recorded for this project yet.</p>
              </div>
            ) : null}
          </div>
        </section>
      </aside>
    </section>
  );
}

function SpecsView({
  data,
  selectedSpec,
  editorContent,
  requestState,
  onSelectSpec,
  onEditorChange,
  onSaveDraft,
  onPublish,
  onCompileGraph
}: {
  data: RuntimeHomeData;
  selectedSpec: SpecificationDraft;
  editorContent: string;
  requestState: RequestState;
  onSelectSpec: (spec: SpecificationDraft) => void;
  onEditorChange: (value: string) => void;
  onSaveDraft: () => void;
  onPublish: () => void;
  onCompileGraph: () => void;
}) {
  return (
    <section className="view-grid specs-view">
      <div className="panel spec-list-panel">
        <SectionHeader
          title="Specifications"
          eyebrow="First-class source"
          action={<StatusPill label={`${data.snapshot.counts.dirty_specs} dirty`} />}
        />
        <div className="spec-list">
          {data.specs.map((spec) => (
            <button
              key={spec.id}
              type="button"
              className={clsx("spec-row", selectedSpec.id === spec.id && "active")}
              onClick={() => onSelectSpec(spec)}
            >
              <span>{formatSpecLabel(spec.spec_type)}</span>
              <small>
                rev {spec.active_revision_number ?? 0}
                {spec.is_dirty ? " - draft changed" : ""}
              </small>
            </button>
          ))}
        </div>
      </div>

      <div className="panel editor-panel">
        <SectionHeader
          title={formatSpecLabel(selectedSpec.spec_type)}
          eyebrow="Draft and publish"
          action={
            <div className="button-row">
              <button type="button" className="secondary-action" onClick={onSaveDraft}>
                <Save size={16} />
                Save draft
              </button>
              <button type="button" className="primary-action" onClick={onPublish}>
                <Check size={16} />
                Publish
              </button>
            </div>
          }
        />
        <textarea
          className="spec-editor"
          value={editorContent}
          onChange={(event) => onEditorChange(event.target.value)}
          spellCheck={false}
        />
        <div className="editor-footer">
          <p className={clsx("request-message", `request-${requestState.status}`)}>
            {requestState.status === "loading" ? <Loader2 size={14} /> : null}
            {requestState.message}
          </p>
          <button type="button" className="secondary-action" onClick={onCompileGraph}>
            <Workflow size={16} />
            Compile graph
          </button>
        </div>
      </div>
    </section>
  );
}

function GraphView({
  data,
  selectedNode,
  onSelectNode,
  apiKey,
  model,
  models,
  analysis,
  onApiKeyChange,
  onModelChange,
  onRefreshModels,
  onAnalyze
}: {
  data: RuntimeHomeData;
  selectedNode: GraphNode;
  onSelectNode: (node: GraphNode) => void;
  apiKey: string;
  model: string;
  models: ModelCatalogEntry[];
  analysis: RequestState & { output?: string };
  onApiKeyChange: (value: string) => void;
  onModelChange: (value: string) => void;
  onRefreshModels: () => void;
  onAnalyze: () => void;
}) {
  const flowNodes = useMemo<FlowNode[]>(
    () =>
      data.graph.nodes.map((node, index) => {
        const column = index % 6;
        const row = Math.floor(index / 6);
        return {
          id: node.id,
          position: {
            x: column * 210 + (row % 2) * 40,
            y: row * 118
          },
          data: {
            label: `${node.name}\n${node.node_type}`
          },
          style: {
            border: `1px solid ${nodeColors[node.node_type] ?? "#9ca3af"}`,
            background: node.id === selectedNode.id ? "#122a4a" : "#111827",
            color: "#e5edff",
            borderRadius: 8,
            fontSize: 12,
            width: 170,
            minHeight: 58,
            boxShadow:
              node.id === selectedNode.id
                ? "0 0 0 3px rgba(173, 198, 255, 0.22)"
                : "0 12px 26px rgba(2, 6, 23, 0.34)",
            whiteSpace: "pre-line"
          }
        };
      }),
    [data.graph.nodes, selectedNode.id]
  );
  const flowEdges = useMemo<FlowEdge[]>(
    () =>
      data.graph.edges.map((edge) => ({
        id: edge.id,
        source: edge.source_node_id,
        target: edge.target_node_id,
        label: edge.edge_type,
        animated:
          edge.source_node_id === selectedNode.id || edge.target_node_id === selectedNode.id,
        style: {
          stroke:
            edge.source_node_id === selectedNode.id || edge.target_node_id === selectedNode.id
              ? "#2563eb"
              : "#94a3b8"
        }
      })),
    [data.graph.edges, selectedNode.id]
  );

  return (
    <section className="view-grid graph-view">
      <div className="panel graph-panel">
        <SectionHeader
          title="Graph Explorer"
          eyebrow={`Version ${data.graph.version_number}`}
          action={<span className="mono">{data.graph.nodes.length} nodes</span>}
        />
        <div className="flow-shell">
          <ReactFlow
            nodes={flowNodes}
            edges={flowEdges}
            fitView
            minZoom={0.25}
            maxZoom={1.6}
            onNodeClick={(_, node) => {
              const match = data.graph.nodes.find((item) => item.id === node.id);
              if (match) onSelectNode(match);
            }}
          >
            <Background gap={20} color="#334155" />
            <Controls />
            <MiniMap pannable zoomable nodeStrokeWidth={3} />
          </ReactFlow>
        </div>
      </div>

      <aside className="side-stack">
        <section className="panel node-panel">
          <SectionHeader title="Node Inspector" eyebrow="Read-only canonical graph" />
          <h3>{selectedNode.name}</h3>
          <StatusPill label={selectedNode.node_type} icon={Code2} />
          <pre>{JSON.stringify(selectedNode.payload, null, 2)}</pre>
        </section>

        <section className="panel ai-panel">
          <SectionHeader title="AI Graph Analysis" eyebrow="GPT-5 family" />
          <label className="field">
            <span>OpenAI API key</span>
            <input
              type="password"
              value={apiKey}
              onChange={(event) => onApiKeyChange(event.target.value)}
              placeholder="Key is used for this request only"
              autoComplete="off"
            />
          </label>
          <label className="field">
            <span>Model</span>
            <select value={model} onChange={(event) => onModelChange(event.target.value)}>
              {models.map((entry) => (
                <option key={entry.id} value={entry.id}>
                  {entry.label}
                </option>
              ))}
            </select>
          </label>
          <div className="button-row">
            <button type="button" className="secondary-action" onClick={onRefreshModels}>
              <RefreshCw size={16} />
              Refresh models
            </button>
            <button type="button" className="primary-action" onClick={onAnalyze}>
              <Sparkles size={16} />
              Analyze
            </button>
          </div>
          <div className={clsx("analysis-output", `request-${analysis.status}`)}>
            {analysis.status === "loading" ? "Analyzing graph state..." : analysis.output ?? analysis.message}
          </div>
        </section>
      </aside>
    </section>
  );
}

function ValidationView({ data }: { data: RuntimeHomeData }) {
  return (
    <section className="view-grid two-column">
      <div className="panel">
        <SectionHeader title="Validation Runs" eyebrow="Three-pass gates" />
        <div className="table-list">
          {data.validationGroups.map((group) => (
            <article key={group.id} className="table-row">
              <div>
                <strong>{group.target_type.replaceAll("_", " ")}</strong>
                <span>{group.id}</span>
              </div>
              <StatusPill label={group.status} icon={ShieldCheck} />
              <small>{group.runs.length} passes</small>
            </article>
          ))}
        </div>
      </div>
      <div className="panel">
        <SectionHeader title="Latest Pass Detail" eyebrow="Deterministic validation" />
        <div className="validation-grid">
          {(data.validationGroups[0]?.runs ?? []).map((run) => (
            <div key={run.id} className="validation-pass">
              <StatusPill label={run.status} icon={Check} />
              <strong>Pass {run.pass_number}</strong>
              <span>{run.completed_at ? "completed" : "running"}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ExecutionView({
  data,
  requestState,
  onApprove,
  onReject,
  onStartExecution,
  onAdvance,
  onRetry
}: {
  data: RuntimeHomeData;
  requestState: RequestState;
  onApprove: (approval: Approval) => void;
  onReject: (approval: Approval) => void;
  onStartExecution: (approval: Approval) => void;
  onAdvance: (run: ExecutionRun) => void;
  onRetry: (run: ExecutionRun) => void;
}) {
  const pendingApproval = latestPendingApproval(data);
  const approvedApproval = latestApprovedApproval(data);
  const run = latestRun(data);

  return (
    <section className="view-grid two-column">
      <div className="panel">
        <SectionHeader
          title="Approvals"
          eyebrow="Execution authority"
          action={pendingApproval ? <StatusPill label={pendingApproval.status} /> : null}
        />
        <div className="approval-card">
          {pendingApproval ? (
            <>
              <p>{String(pendingApproval.mutation_summary.summary)}</p>
              <div className="button-row">
                <button type="button" className="primary-action" onClick={() => onApprove(pendingApproval)}>
                  <Check size={16} />
                  Approve
                </button>
                <button type="button" className="secondary-action" onClick={() => onReject(pendingApproval)}>
                  <X size={16} />
                  Reject
                </button>
              </div>
            </>
          ) : (
            <p>No pending approval. Compile the graph from Specs to request one.</p>
          )}
        </div>
        <div className="button-row">
          <button
            type="button"
            className="primary-action"
            disabled={!approvedApproval}
            onClick={() => approvedApproval && onStartExecution(approvedApproval)}
          >
            <Play size={16} />
            Start execution
          </button>
          {run ? (
            <button type="button" className="secondary-action" onClick={() => onRetry(run)}>
              <RefreshCw size={16} />
              Retry latest
            </button>
          ) : null}
        </div>
        <p className={clsx("request-message", `request-${requestState.status}`)}>
          {requestState.message}
        </p>
      </div>

      <div className="panel">
        <SectionHeader
          title="Execution DAG"
          eyebrow={run ? `Run ${run.id.slice(0, 8)}` : "No run yet"}
          action={run ? <StatusPill label={run.status} /> : null}
        />
        <div className="timeline">
          {data.tasks.map((task) => (
            <article key={task.id} className="timeline-row">
              <div className={clsx("timeline-dot", task.status === "completed" && "timeline-dot-complete")}>
                {task.status === "completed" ? <Check size={13} /> : <Timer size={13} />}
              </div>
              <div>
                <div className="timeline-title">
                  <h3>{String(task.output_payload.name ?? `Task ${task.sequence_number}`)}</h3>
                  <StatusPill label={task.status} />
                </div>
                <p>{String(task.output_payload.agent ?? "Sembl Orchestrator")}</p>
              </div>
            </article>
          ))}
        </div>
        {run && run.status !== "completed" ? (
          <button type="button" className="primary-action full-width" onClick={() => onAdvance(run)}>
            <ArrowRight size={16} />
            Advance next task
          </button>
        ) : null}
      </div>
    </section>
  );
}

function ReconciliationView({ data }: { data: RuntimeHomeData }) {
  return (
    <section className="view-grid two-column">
      <div className="panel">
        <SectionHeader title="Reconciliation" eyebrow="Graph authority preserved" />
        <div className="table-list">
          {data.reconciliations.map((item) => (
            <article key={item.id} className="table-row">
              <div>
                <strong>{item.id}</strong>
                <span>{item.semantic_diff_id ?? "No semantic diff yet"}</span>
              </div>
              <StatusPill label={item.status} icon={GitBranch} />
            </article>
          ))}
        </div>
      </div>
      <div className="panel">
        <SectionHeader title="Event Log" eyebrow="Append-only lineage" />
        <div className="table-list">
          {data.events.map((event) => (
            <article key={event.id} className="table-row">
              <div>
                <strong>#{event.sequence_number} {event.event_type}</strong>
                <span>{event.originating_subsystem}</span>
              </div>
              <small>{new Date(event.created_at).toLocaleString()}</small>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

function ChangesView({
  data,
  selectedNode,
  onSelectNode,
  apiKey,
  model,
  models,
  analysis,
  onApiKeyChange,
  onModelChange,
  onRefreshModels,
  onAnalyze
}: {
  data: RuntimeHomeData;
  selectedNode: GraphNode;
  onSelectNode: (node: GraphNode) => void;
  apiKey: string;
  model: string;
  models: ModelCatalogEntry[];
  analysis: RequestState & { output?: string };
  onApiKeyChange: (value: string) => void;
  onModelChange: (value: string) => void;
  onRefreshModels: () => void;
  onAnalyze: () => void;
}) {
  return (
    <div className="changes-stack">
      <GraphView
        data={data}
        selectedNode={selectedNode}
        onSelectNode={onSelectNode}
        apiKey={apiKey}
        model={model}
        models={models}
        analysis={analysis}
        onApiKeyChange={onApiKeyChange}
        onModelChange={onModelChange}
        onRefreshModels={onRefreshModels}
        onAnalyze={onAnalyze}
      />
      <ValidationView data={data} />
      <ReconciliationView data={data} />
    </div>
  );
}

function DeploymentsView({ data }: { data: RuntimeHomeData }) {
  return (
    <section className="view-grid two-column">
      <div className="panel">
        <SectionHeader title="Deployments" eyebrow="Derived records" />
        <div className="table-list">
          {data.deployments.map((deployment) => (
            <article key={deployment.id} className="table-row">
              <div>
                <strong>{deployment.environment}</strong>
                <span>{deployment.provider_url ?? deployment.failure_reason ?? "No provider URL"}</span>
              </div>
              <StatusPill label={deployment.status} icon={Rocket} />
            </article>
          ))}
        </div>
      </div>
      <div className="panel">
        <SectionHeader title="Notifications" eyebrow="Workspace activity" />
        <div className="table-list">
          {data.notifications.map((notification) => (
            <article key={notification.id} className="table-row">
              <div>
                <strong>{notification.title}</strong>
                <span>{notification.body}</span>
              </div>
              <StatusPill label={notification.severity} />
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

function SettingsView({
  data,
  onSignOut
}: {
  data: RuntimeHomeData;
  onSignOut: () => void;
}) {
  return (
    <section className="view-grid two-column">
      <div className="panel">
        <SectionHeader title="Workspace Settings" eyebrow="Authenticated session" />
        <dl className="settings-list">
          <div>
            <dt>User</dt>
            <dd>{data.snapshot.currentUser.email ?? data.snapshot.currentUser.id}</dd>
          </div>
          <div>
            <dt>Role</dt>
            <dd>{data.snapshot.currentUser.role}</dd>
          </div>
          <div>
            <dt>Runtime source</dt>
            <dd>{data.snapshot.runtimeSource}</dd>
          </div>
        </dl>
        <button type="button" className="secondary-action" onClick={onSignOut}>
          <LogOut size={16} />
          Sign out
        </button>
      </div>
      <div className="panel">
        <SectionHeader title="Backend Health" eyebrow="Truthful state" />
        <div className="metric-grid">
          <Metric label="Specs" value={data.snapshot.counts.specifications} />
          <Metric label="Nodes" value={data.snapshot.counts.nodes} />
          <Metric label="Edges" value={data.snapshot.counts.edges} />
          <Metric label="Runs" value={data.snapshot.counts.runs} />
        </div>
      </div>
    </section>
  );
}

function ProjectLauncher({
  directory,
  projectName,
  projectBrief,
  requestState,
  onProjectNameChange,
  onProjectBriefChange,
  onCreateProject,
  onOpenProject,
  onSignOut
}: {
  directory: ProjectDirectory;
  projectName: string;
  projectBrief: string;
  requestState: RequestState;
  onProjectNameChange: (value: string) => void;
  onProjectBriefChange: (value: string) => void;
  onCreateProject: (event: React.FormEvent<HTMLFormElement>) => void;
  onOpenProject: (projectId: string) => void;
  onSignOut: () => void;
}) {
  return (
    <main className="app-shell launcher-shell">
      <aside className="left-nav" aria-label="Workspace navigation">
        <div className="brand">
          <div className="brand-mark">s</div>
          <div>
            <strong>sembl</strong>
            <span>software factory</span>
          </div>
        </div>
        <div className="nav-footer">
          <button type="button" className="secondary-action full-width" onClick={onSignOut}>
            <LogOut size={16} />
            Sign out
          </button>
        </div>
      </aside>

      <section className="workspace launcher-workspace">
        <header className="topbar">
          <div>
            <p className="section-kicker">Factory launcher</p>
            <h1>Create a project</h1>
          </div>
          <StatusPill label="supabase" icon={ShieldCheck} />
        </header>

        <section className="view-grid two-column">
          <form className="panel project-create-panel" onSubmit={onCreateProject}>
            <SectionHeader title="New Project" eyebrow="Persisted factory state" />
            <label className="field">
              <span>Project name</span>
              <input
                value={projectName}
                onChange={(event) => onProjectNameChange(event.target.value)}
                placeholder="Customer portal"
                minLength={2}
                maxLength={96}
                required
              />
            </label>
            <label className="field">
              <span>Build brief</span>
              <textarea
                className="brief-input"
                value={projectBrief}
                onChange={(event) => onProjectBriefChange(event.target.value)}
                placeholder="Users, workflows, data, integrations, and deployment target"
                maxLength={4000}
              />
            </label>
            <button
              type="submit"
              className="primary-action full-width"
              disabled={requestState.status === "loading"}
            >
              {requestState.status === "loading" ? <Loader2 size={16} /> : <Plus size={16} />}
              Initialize project factory
            </button>
            <p className={clsx("request-message", `request-${requestState.status}`)}>
              {requestState.message}
            </p>
          </form>

          <section className="panel">
            <SectionHeader title="Existing Projects" eyebrow="Your workspaces" />
            <div className="table-list">
              {directory.projects.map((project) => (
                <button
                  key={project.id}
                  type="button"
                  className="project-row"
                  onClick={() => onOpenProject(project.id)}
                >
                  <div>
                    <strong>{project.name}</strong>
                    <span>{project.counts.specifications} specs, {project.counts.graph_versions} graph versions</span>
                  </div>
                  <StatusPill label={project.lifecycle_state} />
                </button>
              ))}
              {!directory.projects.length ? (
                <div className="empty-state">
                  <p>No projects yet.</p>
                </div>
              ) : null}
            </div>
          </section>
        </section>
      </section>
    </main>
  );
}

export function SemblWorkspace({ initialData, initialDirectory }: Props) {
  const [data, setData] = useState<RuntimeHomeData | null>(initialData);
  const [directory, setDirectory] = useState(initialDirectory);
  const [view, setView] = useState<View>("Overview");
  const [selectedSpecId, setSelectedSpecId] = useState(initialData?.specs[0]?.id ?? "");
  const [editorContent, setEditorContent] = useState(initialData?.specs[0]?.draft_content ?? "");
  const [selectedNodeId, setSelectedNodeId] = useState(initialData?.graph.nodes[0]?.id ?? "");
  const [searchTerm, setSearchTerm] = useState("");
  const [projectName, setProjectName] = useState("");
  const [projectBrief, setProjectBrief] = useState("");
  const [requestState, setRequestState] = useState<RequestState>({
    status: "idle",
    message: "Ready."
  });
  const [apiKey, setApiKey] = useState("");
  const [model, setModel] = useState("gpt-5.5");
  const [models, setModels] = useState<ModelCatalogEntry[]>([
    {
      id: "gpt-5.5",
      label: "GPT-5.5",
      family: "gpt-5",
      recommended: true,
      description: "Default GPT-5.5 model.",
      source: "configured"
    }
  ]);
  const [analysis, setAnalysis] = useState<RequestState & { output?: string }>({
    status: "idle",
    message: "Enter a key to analyze the selected graph node."
  });
  const { apiFetch, refresh, supabase } = useApiClient(data?.snapshot.project.id);

  const selectedSpec =
    data?.specs.find((spec) => spec.id === selectedSpecId) ?? data?.specs[0];
  const selectedNode =
    data?.graph.nodes.find((node) => node.id === selectedNodeId) ?? data?.graph.nodes[0];
  const searchResults = useMemo<SearchResult[]>(() => {
    if (!data) return [];
    const term = searchTerm.trim().toLowerCase();
    if (!term) return [];

    const specs = data.specs
      .filter((spec) => formatSpecLabel(spec.spec_type).toLowerCase().includes(term))
      .map<SearchResult>((spec) => ({
        id: spec.id,
        label: formatSpecLabel(spec.spec_type),
        detail: spec.is_dirty ? "Specification draft changed" : `Revision ${spec.active_revision_number ?? 0}`,
        view: "Specifications",
        kind: "spec"
      }));
    const nodes = data.graph.nodes
      .filter(
        (node) =>
          node.id.toLowerCase().includes(term) ||
          node.name.toLowerCase().includes(term) ||
          node.node_type.toLowerCase().includes(term)
      )
      .map<SearchResult>((node) => ({
        id: node.id,
        label: node.name,
        detail: `${node.node_type} node`,
        view: "Changes",
        kind: "node"
      }));
    const runs = data.executions
      .filter((run) => run.id.toLowerCase().includes(term) || run.status.toLowerCase().includes(term))
      .map<SearchResult>((run) => ({
        id: run.id,
        label: `Run ${run.id.slice(0, 8)}`,
        detail: run.status.replaceAll("_", " "),
        view: "Execution",
        kind: "run"
      }));

    return [...specs, ...nodes, ...runs].slice(0, 8);
  }, [data, searchTerm]);

  useEffect(() => {
    void loadModels();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function refreshState(message = "Workspace refreshed.") {
    const next = await refresh();
    const nextSelectedSpec =
      next.specs.find((spec) => spec.id === selectedSpecId) ?? next.specs[0];
    setData(next);
    setDirectory(next.directory);
    if (nextSelectedSpec) {
      setSelectedSpecId(nextSelectedSpec.id);
      setEditorContent(nextSelectedSpec.draft_content);
    }
    setSelectedNodeId((current) =>
      next.graph.nodes.some((node) => node.id === current) ? current : next.graph.nodes[0]?.id ?? ""
    );
    setRequestState({ status: "success", message });
    return next;
  }

  async function runAction(message: string, action: () => Promise<void>) {
    setRequestState({ status: "loading", message });
    try {
      await action();
    } catch (error) {
      setRequestState({
        status: "error",
        message: error instanceof Error ? error.message : "Action failed."
      });
    }
  }

  async function loadModels() {
    try {
      const payload = await apiFetch<{
        default_model: string;
        models: ModelCatalogEntry[];
      }>("/api/v1/ai/models", {
        headers: apiKey.trim() ? { "x-openai-api-key": apiKey.trim() } : undefined
      });
      setModels(payload.models);
      setModel(payload.default_model);
    } catch (error) {
      setAnalysis({
        status: "error",
        message: error instanceof Error ? error.message : "Could not load model catalog."
      });
    }
  }

  function selectSpec(spec: SpecificationDraft) {
    setSelectedSpecId(spec.id);
    setEditorContent(spec.draft_content);
  }

  function selectSearchResult(result: SearchResult) {
    if (!data) return;
    setView(result.view);
    setSearchTerm("");

    if (result.kind === "spec") {
      const spec = data.specs.find((item) => item.id === result.id);
      if (spec) selectSpec(spec);
    }
    if (result.kind === "node") {
      setSelectedNodeId(result.id);
    }
  }

  function hydrateProject(next: RuntimeHomeData) {
    setData(next);
    setDirectory(next.directory);
    setView("Overview");
    setSelectedSpecId(next.specs[0]?.id ?? "");
    setEditorContent(next.specs[0]?.draft_content ?? "");
    setSelectedNodeId(next.graph.nodes[0]?.id ?? "");
    setSearchTerm("");
    window.history.replaceState(null, "", `/?project=${next.snapshot.project.id}`);
  }

  async function openProject(projectId: string) {
    await runAction("Opening project runtime state...", async () => {
      const next = await refresh(projectId);
      hydrateProject(next);
      setRequestState({ status: "success", message: "Project opened." });
    });
  }

  async function createProject(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    await runAction("Initializing project factory in Supabase...", async () => {
      const payload = await apiFetch<{ state: RuntimeHomeData }>("/api/v1/projects", {
        method: "POST",
        body: JSON.stringify({
          name: projectName,
          brief: projectBrief || undefined
        })
      });
      setProjectName("");
      setProjectBrief("");
      hydrateProject(payload.state);
      setRequestState({ status: "success", message: "Project factory initialized." });
    });
  }

  async function saveDraft() {
    if (!data || !selectedSpec) return;
    await runAction("Saving draft to Supabase...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/specifications/${selectedSpec.spec_type}/draft`, {
        method: "PUT",
        body: JSON.stringify({ content: editorContent })
      });
      await refreshState("Draft saved.");
    });
  }

  async function publish() {
    if (!data || !selectedSpec) return;
    await runAction("Publishing revision and running validation...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/specifications/${selectedSpec.spec_type}/draft`, {
        method: "PUT",
        body: JSON.stringify({ content: editorContent })
      });
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/specifications/${selectedSpec.spec_type}/publish`, {
        method: "POST",
        body: JSON.stringify({})
      });
      await refreshState("Revision published and validation recorded.");
    });
  }

  async function compileGraph() {
    if (!data) return;
    await runAction("Compiling graph from active specs...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/specifications/compile`, {
        method: "POST",
        body: JSON.stringify({})
      });
      await refreshState("Graph version compiled and approval requested.");
      setView("Execution");
    });
  }

  async function decideApproval(approval: Approval, path: "approve" | "reject") {
    if (!data) return;
    await runAction(`${path === "approve" ? "Approving" : "Rejecting"} execution request...`, async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/approvals/${approval.id}/${path}`, {
        method: "POST",
        body: JSON.stringify({})
      });
      await refreshState(`Approval ${path === "approve" ? "approved" : "rejected"}.`);
    });
  }

  async function startExecution(approval: Approval) {
    if (!data) return;
    await runAction("Starting execution and creating task DAG...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/executions`, {
        method: "POST",
        body: JSON.stringify({ approval_id: approval.id })
      });
      await refreshState("Execution run created.");
    });
  }

  async function advance(run: ExecutionRun) {
    if (!data) return;
    await runAction("Advancing execution task...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/executions/${run.id}/tasks`, {
        method: "POST",
        body: JSON.stringify({})
      });
      await refreshState("Execution state advanced.");
    });
  }

  async function retry(run: ExecutionRun) {
    if (!data) return;
    await runAction("Creating retry execution run...", async () => {
      await apiFetch(`/api/v1/projects/${data.snapshot.project.id}/executions/${run.id}/retry`, {
        method: "POST",
        body: JSON.stringify({})
      });
      await refreshState("Retry run created.");
    });
  }

  async function analyzeGraph() {
    if (!data || !selectedNode) return;
    if (!apiKey.trim()) {
      setAnalysis({ status: "error", message: "Enter an OpenAI API key first." });
      return;
    }

    setAnalysis({ status: "loading", message: "Analyzing graph state..." });
    try {
      const payload = await apiFetch<{ output: string }>("/api/v1/ai/graph-analysis", {
        method: "POST",
        body: JSON.stringify({
          apiKey,
          model,
          projectId: data.snapshot.project.id,
          prompt: `Analyze node ${selectedNode.id} (${selectedNode.name}) for continuity risk, affected scope, and next action.`
        })
      });
      setAnalysis({ status: "success", message: "Analysis complete.", output: payload.output });
    } catch (error) {
      setAnalysis({
        status: "error",
        message: error instanceof Error ? error.message : "Graph analysis failed."
      });
    }
  }

  async function signOut() {
    await supabase.auth.signOut();
    window.location.assign("/");
  }

  if (!data) {
    return (
      <ProjectLauncher
        directory={directory}
        projectName={projectName}
        projectBrief={projectBrief}
        requestState={requestState}
        onProjectNameChange={setProjectName}
        onProjectBriefChange={setProjectBrief}
        onCreateProject={createProject}
        onOpenProject={openProject}
        onSignOut={signOut}
      />
    );
  }

  const currentView =
    view === "Overview" ? (
      <OverviewView
        data={data}
        onOpenSpecifications={() => setView("Specifications")}
        onOpenExecution={() => setView("Execution")}
        onOpenChanges={() => setView("Changes")}
      />
    ) : view === "Specifications" && selectedSpec ? (
      <SpecsView
        data={data}
        selectedSpec={selectedSpec}
        editorContent={editorContent}
        requestState={requestState}
        onSelectSpec={selectSpec}
        onEditorChange={setEditorContent}
        onSaveDraft={saveDraft}
        onPublish={publish}
        onCompileGraph={compileGraph}
      />
    ) : view === "Execution" ? (
      <ExecutionView
        data={data}
        requestState={requestState}
        onApprove={(approval) => decideApproval(approval, "approve")}
        onReject={(approval) => decideApproval(approval, "reject")}
        onStartExecution={startExecution}
        onAdvance={advance}
        onRetry={retry}
      />
    ) : view === "Changes" && selectedNode ? (
      <ChangesView
        data={data}
        selectedNode={selectedNode}
        onSelectNode={(node) => setSelectedNodeId(node.id)}
        apiKey={apiKey}
        model={model}
        models={models}
        analysis={analysis}
        onApiKeyChange={setApiKey}
        onModelChange={setModel}
        onRefreshModels={loadModels}
        onAnalyze={analyzeGraph}
      />
    ) : view === "Deployments" ? (
      <DeploymentsView data={data} />
    ) : (
      <SettingsView data={data} onSignOut={signOut} />
    );

  return (
    <main className="app-shell">
      <aside className="left-nav" aria-label="Workspace navigation">
        <div className="brand">
          <div className="brand-mark">s</div>
          <div>
            <strong>sembl</strong>
            <span>graph-native engineering</span>
          </div>
        </div>

        <nav className="nav-stack">
          {views.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                type="button"
                className={clsx("nav-item", view === item.id && "active")}
                onClick={() => setView(item.id)}
              >
                <Icon size={17} />
                <span>{item.id}</span>
              </button>
            );
          })}
        </nav>

        <div className="project-switcher">
          <div className="switcher-header">
            <span>Projects</span>
            <button
              type="button"
              aria-label="Create project"
              onClick={() => {
                setRequestState({ status: "idle", message: "Name the project to initialize." });
                setData(null);
              }}
            >
              <Plus size={15} />
            </button>
          </div>
          <div className="project-list">
            {directory.projects.slice(0, 6).map((project) => (
              <button
                key={project.id}
                type="button"
                className={clsx("project-nav-item", project.id === data.snapshot.project.id && "active")}
                onClick={() => {
                  if (project.id !== data.snapshot.project.id) {
                    void openProject(project.id);
                  }
                }}
              >
                <span>{project.name}</span>
                <small>{project.lifecycle_state.replaceAll("_", " ")}</small>
              </button>
            ))}
          </div>
        </div>

        <div className="nav-footer">
          <p>Supabase runtime</p>
          <StatusPill label={data.snapshot.runtimeSource} icon={ShieldCheck} />
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="section-kicker">{data.snapshot.workspace.name}</p>
            <h1>{data.snapshot.project.name}</h1>
          </div>
          <div className="topbar-actions">
            <div className="search-box">
              <Search size={16} />
              <input
                aria-label="Search specs, graph nodes, and runs"
                placeholder="Search specs, graph nodes, runs"
                value={searchTerm}
                onChange={(event) => setSearchTerm(event.target.value)}
              />
              {searchTerm.trim() ? (
                <div className="search-results" role="listbox" aria-label="Search results">
                  {searchResults.length ? (
                    searchResults.map((result) => (
                      <button
                        key={`${result.kind}-${result.id}`}
                        type="button"
                        onClick={() => selectSearchResult(result)}
                      >
                        <strong>{result.label}</strong>
                        <span>{result.detail}</span>
                      </button>
                    ))
                  ) : (
                    <p>No matching graph state.</p>
                  )}
                </div>
              ) : null}
            </div>
            <StatusPill label={data.snapshot.project.lifecycle_state} icon={Activity} />
          </div>
        </header>

        <section className="metric-grid overview-metrics" aria-label="Workspace metrics">
          <Metric
            label="Specifications"
            value={data.snapshot.counts.specifications}
            detail={`${data.snapshot.counts.dirty_specs} drafts changed`}
          />
          <Metric
            label="Graph"
            value={`${data.snapshot.counts.nodes}/${data.snapshot.counts.edges}`}
            detail="nodes / edges"
          />
          <Metric
            label="Approvals"
            value={data.snapshot.counts.approvals}
            detail="open requests"
          />
          <Metric
            label="Execution"
            value={data.snapshot.counts.open_tasks}
            detail="open tasks"
          />
        </section>

        <section className="lifecycle-strip" aria-label="Project lifecycle">
          {["Specifications", "Changes", "Approval", "Execution", "Reconciliation", "Deployments"].map(
            (stage) => (
              <div
                key={stage}
                className={clsx(
                  "lifecycle-step",
                  (view === stage ||
                    (stage === "Approval" && view === "Execution") ||
                    (stage === "Reconciliation" && view === "Changes")) &&
                    "current"
                )}
              >
                <span>
                  {stage === "Specifications" ? <ScrollText size={13} /> : <CircleDot size={13} />}
                </span>
                <strong>{stage}</strong>
              </div>
            )
          )}
        </section>

        {currentView}
      </section>
    </main>
  );
}
