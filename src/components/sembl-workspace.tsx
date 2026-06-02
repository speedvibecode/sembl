"use client";

import {
  Activity,
  AlertTriangle,
  ArrowRight,
  Box,
  Braces,
  Check,
  CircleDot,
  Clock,
  Code2,
  GitBranch,
  GitCommitHorizontal,
  KeyRound,
  Layers3,
  Network,
  Play,
  Rocket,
  ScrollText,
  Search,
  ShieldCheck,
  SlidersHorizontal,
  SquareArrowOutUpRight,
  Timer,
  Workflow,
  X
} from "lucide-react";
import { useMemo, useState } from "react";
import clsx from "clsx";
import type {
  Approval,
  GraphEdge,
  GraphNode,
  ReconciliationAttempt
} from "@/lib/types";

type ProjectSnapshot = ReturnType<
  typeof import("@/lib/semantic-store").getProjectSnapshot
>;

type GraphPayload = ReturnType<typeof import("@/lib/semantic-store").getGraph>;

type TaskPayload = ReturnType<
  typeof import("@/lib/semantic-store").getDeterministicDag
>[number];

type Props = {
  snapshot: ProjectSnapshot;
  graph: GraphPayload;
  approvals: Approval[];
  tasks: TaskPayload[];
  reconciliations: ReconciliationAttempt[];
};

type AnalysisState =
  | { status: "idle"; text: string }
  | { status: "running"; text: string }
  | { status: "done"; text: string }
  | { status: "error"; text: string };

const navIcons = [
  Layers3,
  ShieldCheck,
  Activity,
  SlidersHorizontal,
  Box,
  ScrollText,
  Play,
  GitCommitHorizontal,
  Rocket,
  Network
];

const screenIconByName: Record<string, typeof Layers3> = {
  "Workspace Home": Layers3,
  "Approval Center": ShieldCheck,
  "Activity Center": Activity,
  "Workspace Settings": SlidersHorizontal,
  "Project Overview": Box,
  Specifications: ScrollText,
  Execution: Play,
  Changes: GitCommitHorizontal,
  Deployments: Rocket,
  "Repository Ingestion": Network,
  "Approval Review": ShieldCheck,
  "Conflict Resolution": AlertTriangle,
  "Escalation Center": Timer
};

const lifecycle = [
  "Documentation",
  "Validation",
  "Graph",
  "Approval",
  "Execution",
  "Reconciliation",
  "Deploy"
];

const statusTone: Record<string, string> = {
  active: "healthy",
  completed: "healthy",
  passed: "healthy",
  approval_required: "awaiting",
  awaiting_approval: "awaiting",
  pending: "awaiting",
  running: "informational",
  executing: "informational",
  reconciling: "informational",
  warning: "attention",
  blocked: "blocked",
  failed: "blocked",
  escalated: "escalated",
  draft: "muted"
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

function GraphCanvas({
  nodes,
  edges,
  selectedNodeId,
  onSelectNode
}: {
  nodes: GraphNode[];
  edges: GraphEdge[];
  selectedNodeId: string;
  onSelectNode: (nodeId: string) => void;
}) {
  const visibleNodes = nodes.slice(0, 18);
  const nodePositions = visibleNodes.map((node, index) => {
    const column = index % 3;
    const row = Math.floor(index / 3);
    return {
      node,
      x: 58 + column * 178 + (row % 2) * 28,
      y: 42 + row * 74
    };
  });
  const positionById = new Map(
    nodePositions.map((position) => [position.node.id, position])
  );
  const visibleEdges = edges
    .filter(
      (edge) => positionById.has(edge.source_node_id) && positionById.has(edge.target_node_id)
    )
    .slice(0, 24);

  return (
    <div className="graph-canvas" role="img" aria-label="Read-only semantic graph">
      <svg viewBox="0 0 610 510" className="graph-svg" aria-hidden="true">
        {visibleEdges.map((edge) => {
          const source = positionById.get(edge.source_node_id);
          const target = positionById.get(edge.target_node_id);
          if (!source || !target) {
            return null;
          }

          const selected =
            edge.source_node_id === selectedNodeId || edge.target_node_id === selectedNodeId;

          return (
            <line
              key={edge.id}
              x1={source.x + 56}
              y1={source.y + 22}
              x2={target.x + 56}
              y2={target.y + 22}
              className={clsx("graph-edge", selected && "graph-edge-selected")}
            />
          );
        })}
      </svg>
      {nodePositions.map(({ node, x, y }) => (
        <button
          type="button"
          key={node.id}
          className={clsx(
            "graph-node",
            `graph-node-${node.node_type}`,
            node.id === selectedNodeId && "graph-node-active"
          )}
          style={{ left: `${x}px`, top: `${y}px` }}
          onClick={() => onSelectNode(node.id)}
          title={`${node.node_type}: ${node.name}`}
        >
          <span>{node.name}</span>
          <small>{node.node_type}</small>
        </button>
      ))}
    </div>
  );
}

function SpecPanel({ snapshot }: { snapshot: ProjectSnapshot }) {
  const visibleScreens = snapshot.screens.slice(0, 5);

  return (
    <section className="panel spec-panel">
      <SectionHeader
        title="Specification State"
        eyebrow="Documentation Mode"
        action={<StatusPill label={snapshot.validation.status} icon={ShieldCheck} />}
      />
      <div className="spec-summary">
        <div>
          <p className="metric-label">Canonical source</p>
          <strong>V4.3 graph artifacts</strong>
          <span>Specifications feed graph extraction, execution, and reconciliation.</span>
        </div>
        <div>
          <p className="metric-label">Active branch</p>
          <strong>{snapshot.branch.name}</strong>
          <span>Branch execution is isolated until reconciliation completes.</span>
        </div>
      </div>
      <div className="screen-list">
        {visibleScreens.map((screen) => (
          <article key={screen.id} className="screen-row">
            <div className="screen-index">{screen.id.split(".").at(-1)?.slice(0, 2)}</div>
            <div>
              <h3>{screen.name}</h3>
              <p>{screen.purpose}</p>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function ExecutionPanel({ tasks }: { tasks: TaskPayload[] }) {
  return (
    <section className="panel execution-panel">
      <SectionHeader
        title="Execution DAG"
        eyebrow="Graph-scoped workers"
        action={<StatusPill label="approval_required" icon={Clock} />}
      />
      <div className="timeline">
        {tasks.slice(0, 8).map((task, index) => (
          <article key={task.id} className="timeline-row">
            <div className={clsx("timeline-dot", index < 6 && "timeline-dot-complete")}>
              {index < 6 ? <Check size={13} /> : <Timer size={13} />}
            </div>
            <div>
              <div className="timeline-title">
                <h3>{task.name}</h3>
                <span>{task.agent}</span>
              </div>
              <p>
                {task.dependencies.length
                  ? `Depends on ${task.dependencies.join(", ")}`
                  : "Root task"}
              </p>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function ValidationPanel({ snapshot }: { snapshot: ProjectSnapshot }) {
  return (
    <section className="panel validation-panel">
      <SectionHeader
        title="Validation"
        eyebrow="Multi-pass gate"
        action={<span className="mono">{snapshot.validation.passes.length} passes</span>}
      />
      <div className="validation-grid">
        {snapshot.validation.passes.map((pass) => (
          <div key={pass.name} className="validation-pass">
            <StatusPill label={pass.status} icon={Check} />
            <strong>{pass.name.replaceAll("_", " ")}</strong>
            <span>{pass.violations.length} violations</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function AiGraphPanel({
  selectedNode
}: {
  selectedNode: GraphNode;
}) {
  const [apiKey, setApiKey] = useState("");
  const [model, setModel] = useState("gpt-4.1-mini");
  const [analysis, setAnalysis] = useState<AnalysisState>({
    status: "idle",
    text: "Enter an API key, then run a graph analysis on the selected semantic node."
  });

  async function runAnalysis() {
    setAnalysis({ status: "running", text: "Analyzing graph state..." });

    try {
      const response = await fetch("/api/v1/ai/graph-analysis", {
        method: "POST",
        headers: {
          "content-type": "application/json"
        },
        body: JSON.stringify({
          apiKey,
          model,
          prompt: `Analyze selected node ${selectedNode.id} (${selectedNode.name}) for architectural continuity risk, affected scope, and next actions.`
        })
      });
      const payload = (await response.json()) as
        | { data: { output: string } }
        | { error: { message: string } };

      if (!response.ok || "error" in payload) {
        setAnalysis({
          status: "error",
          text: "error" in payload ? payload.error.message : "Graph analysis failed."
        });
        return;
      }

      setAnalysis({ status: "done", text: payload.data.output });
    } catch (error) {
      setAnalysis({
        status: "error",
        text: error instanceof Error ? error.message : "Graph analysis failed."
      });
    }
  }

  return (
    <section className="impact-module ai-module">
      <div className="module-title">
        <KeyRound size={16} />
        <h3>AI Graph Key</h3>
      </div>
      <label className="field">
        <span>OpenAI API key</span>
        <input
          type="password"
          placeholder="Enter OpenAI API key"
          value={apiKey}
          onChange={(event) => setApiKey(event.target.value)}
          autoComplete="off"
        />
      </label>
      <label className="field">
        <span>Model</span>
        <select value={model} onChange={(event) => setModel(event.target.value)}>
          <option value="gpt-4.1-mini">gpt-4.1-mini</option>
          <option value="gpt-4.1">gpt-4.1</option>
          <option value="gpt-4o-mini">gpt-4o-mini</option>
        </select>
      </label>
      <button className="primary-action" type="button" onClick={runAnalysis}>
        <Workflow size={16} />
        Analyze Graph
      </button>
      <div className={clsx("analysis-output", `analysis-${analysis.status}`)}>
        {analysis.text}
      </div>
    </section>
  );
}

function ImpactPanel({
  approval,
  selectedNode,
  reconciliations
}: {
  approval: Approval;
  selectedNode: GraphNode;
  reconciliations: ReconciliationAttempt[];
}) {
  const [decision, setDecision] = useState(approval.status);

  async function decide(path: "approve" | "reject") {
    const response = await fetch(
      `/api/v1/projects/${approval.project_id}/approvals/${approval.id}/${path}`,
      {
        method: "POST"
      }
    );
    const payload = (await response.json()) as { data?: Approval };
    if (payload.data) {
      setDecision(payload.data.status);
    }
  }

  return (
    <aside className="impact-panel" aria-label="Impact and required actions">
      <section className="impact-module required-action">
        <div className="module-title">
          <AlertTriangle size={16} />
          <h3>Required Action</h3>
        </div>
        <StatusPill label={decision} icon={Clock} />
        <p>{String(approval.mutation_summary.summary)}</p>
        <div className="action-row">
          <button className="primary-action" type="button" onClick={() => decide("approve")}>
            <Check size={16} />
            Approve
          </button>
          <button className="secondary-action" type="button" onClick={() => decide("reject")}>
            <X size={16} />
            Reject
          </button>
        </div>
      </section>

      <section className="impact-module">
        <div className="module-title">
          <SquareArrowOutUpRight size={16} />
          <h3>Impact</h3>
        </div>
        <div className="impact-score">
          <span>74</span>
          <small>impact score</small>
        </div>
        <dl className="impact-list">
          <div>
            <dt>Scope</dt>
            <dd>{String(approval.affected_scope.execution_boundary)}</dd>
          </div>
          <div>
            <dt>Selected node</dt>
            <dd>{selectedNode.name}</dd>
          </div>
          <div>
            <dt>Reconciliation</dt>
            <dd>{reconciliations[0]?.status.replaceAll("_", " ")}</dd>
          </div>
        </dl>
      </section>

      <AiGraphPanel selectedNode={selectedNode} />

      <section className="impact-module">
        <div className="module-title">
          <GitBranch size={16} />
          <h3>Traceability</h3>
        </div>
        <ul className="trace-list">
          {(selectedNode.source_refs ?? []).slice(0, 4).map((sourceRef) => (
            <li key={sourceRef}>
              <Braces size={14} />
              <span>{sourceRef}</span>
            </li>
          ))}
        </ul>
      </section>
    </aside>
  );
}

export function SemblWorkspace({
  snapshot,
  graph,
  approvals,
  tasks,
  reconciliations
}: Props) {
  const [selectedNodeId, setSelectedNodeId] = useState(graph.nodes[0]?.id ?? "");
  const selectedNode = useMemo(
    () => graph.nodes.find((node) => node.id === selectedNodeId) ?? graph.nodes[0],
    [graph.nodes, selectedNodeId]
  );
  const approval = approvals[0];

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
          {[
            ...snapshot.navigation.global_navigation,
            ...snapshot.navigation.project_navigation,
            ...snapshot.navigation.contextual_navigation
          ].map((item, index) => {
            const Icon = screenIconByName[item] ?? navIcons[index % navIcons.length];
            const active = item === "Project Overview";
            return (
              <button key={item} type="button" className={clsx("nav-item", active && "active")}>
                <Icon size={17} />
                <span>{item}</span>
              </button>
            );
          })}
        </nav>

        <div className="nav-footer">
          <p>Service Preflight</p>
          <StatusPill label="active" icon={ShieldCheck} />
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="section-kicker">{snapshot.workspace.name}</p>
            <h1>{snapshot.project.name}</h1>
          </div>
          <div className="topbar-actions">
            <div className="search-box">
              <Search size={16} />
              <span>Search specifications, graph nodes, runs</span>
            </div>
            <StatusPill label={snapshot.project.lifecycle_state} icon={Clock} />
          </div>
        </header>

        <section className="lifecycle-strip" aria-label="Project lifecycle">
          {lifecycle.map((stage, index) => (
            <div
              key={stage}
              className={clsx(
                "lifecycle-step",
                index < 3 && "complete",
                index === 3 && "current"
              )}
            >
              <span>{index < 3 ? <Check size={13} /> : index === 3 ? <Clock size={13} /> : index + 1}</span>
              <strong>{stage}</strong>
              {index < lifecycle.length - 1 ? <ArrowRight size={14} /> : null}
            </div>
          ))}
        </section>

        <section className="workspace-grid">
          <div className="primary-column">
            <SpecPanel snapshot={snapshot} />
            <ExecutionPanel tasks={tasks} />
            <ValidationPanel snapshot={snapshot} />
          </div>

          <section className="panel graph-panel">
            <SectionHeader
              title="Graph Explorer"
              eyebrow="Read-only inspection"
              action={<span className="mono">{graph.nodes.length} nodes</span>}
            />
            <GraphCanvas
              nodes={graph.nodes}
              edges={graph.edges}
              selectedNodeId={selectedNode.id}
              onSelectNode={setSelectedNodeId}
            />
            <div className="node-inspector">
              <div>
                <p className="metric-label">Selected node</p>
                <h3>{selectedNode.name}</h3>
                <StatusPill label={selectedNode.node_type} icon={Code2} />
              </div>
              <pre>{JSON.stringify(selectedNode.payload, null, 2)}</pre>
            </div>
          </section>
        </section>
      </section>

      {approval && selectedNode ? (
        <ImpactPanel
          approval={approval}
          selectedNode={selectedNode}
          reconciliations={reconciliations}
        />
      ) : null}
    </main>
  );
}
