import { promises as fs } from "node:fs";
import path from "node:path";

const root = process.cwd();

const jsonPath = (...parts) => path.join(root, ...parts);

async function readJson(...parts) {
  const file = jsonPath(...parts);
  const raw = await fs.readFile(file, "utf8");
  try {
    return JSON.parse(raw);
  } catch (error) {
    error.message = `${file}: ${error.message}`;
    throw error;
  }
}

function violation(invariant_id, affected_structure, reason, graph_location, source_ref, severity = "blocking") {
  return { invariant_id, severity, affected_structure, reason, graph_location, source_ref };
}

function requireArray(value, label, out) {
  if (!Array.isArray(value)) {
    out.push(violation("STRUCTURE", label, "Expected array.", label, "validator"));
    return [];
  }
  return value;
}

function detectCycle(nodes, getDeps) {
  const visiting = new Set();
  const visited = new Set();
  const stack = [];

  function visit(id) {
    if (visiting.has(id)) {
      const start = stack.indexOf(id);
      return stack.slice(start).concat(id);
    }
    if (visited.has(id)) return null;
    visiting.add(id);
    stack.push(id);
    for (const dep of getDeps(id)) {
      const cycle = visit(dep);
      if (cycle) return cycle;
    }
    stack.pop();
    visiting.delete(id);
    visited.add(id);
    return null;
  }

  for (const id of nodes) {
    const cycle = visit(id);
    if (cycle) return cycle;
  }
  return null;
}

function validateTaskDag(taskGraph, agents, packets, out) {
  const tasks = requireArray(taskGraph.tasks, "task_graph.tasks", out);
  const taskIds = new Set(tasks.map((task) => task.id));
  const agentNames = new Set(agents.agents.map((agent) => agent.name));
  const packetNames = new Set(packets);

  for (const task of tasks) {
    for (const key of ["id", "name", "agent", "model_policy", "dependencies", "graph_scope", "expected_outputs", "validation_gates", "packet"]) {
      if (!(key in task)) {
        out.push(violation("TASK_STRUCTURE", task.id ?? "unknown_task", `Missing task key: ${key}`, "task_graph.tasks", "graph/task_graph.json"));
      }
    }
    if (!agentNames.has(task.agent)) {
      out.push(violation("TASK_AGENT", task.id, `Unknown agent: ${task.agent}`, "task_graph.tasks.agent", "graph/agents/agent_roster.json"));
    }
    if (!task.model_policy || !task.model_policy.suggested_model || !task.model_policy.reasoning_effort) {
      out.push(violation("TASK_MODEL_POLICY", task.id, "Task lacks explicit model and reasoning policy.", "task_graph.tasks.model_policy", "graph/task_graph.json"));
    }
    if (task.category === "build" && !task.execution_boundary) {
      out.push(violation("TASK_EXECUTION_BOUNDARY", task.id, "Build tasks must map to an execution boundary.", "task_graph.tasks.execution_boundary", "graph/normalized_graph.json"));
    }
    for (const dep of task.dependencies ?? []) {
      if (!taskIds.has(dep)) {
        out.push(violation("TASK_DEPENDENCY", task.id, `Unknown task dependency: ${dep}`, "task_graph.tasks.dependencies", "graph/task_graph.json"));
      }
    }
    if (task.packet && !packetNames.has(task.packet.replaceAll("\\", "/"))) {
      out.push(violation("TASK_PACKET", task.id, `Missing task packet: ${task.packet}`, "task_graph.tasks.packet", "graph/task-packets"));
    }
  }

  const cycle = detectCycle([...taskIds], (id) => {
    const task = tasks.find((item) => item.id === id);
    return (task?.dependencies ?? []).filter((dep) => taskIds.has(dep));
  });
  if (cycle) {
    out.push(violation("E2", "task_graph", `Task DAG has a cycle: ${cycle.join(" -> ")}`, "task_graph.tasks.dependencies", "v_4.3.md#task-graph-orchestration"));
  }

  const models = new Set(tasks.map((task) => task.model_policy?.suggested_model).filter(Boolean));
  const efforts = new Set(tasks.map((task) => task.model_policy?.reasoning_effort).filter(Boolean));
  if (models.size < 3 || efforts.size < 2) {
    out.push(violation("MODEL_POLICY", "task_graph", "Model policy collapsed to too few model/effort levels; expected varied task-specific selection.", "task_graph.tasks.model_policy", "graph/agents/agent_roster.json"));
  }
}

function validateNormalizedGraph(graph, out) {
  const allowedNodeTypes = new Set(["entity", "interface", "integration_contract", "flow", "invariant", "execution_boundary"]);
  const allowedEdgeTypes = new Set(["dependency", "implements", "precedes", "triggers", "owns", "lineage"]);
  const nodes = requireArray(graph.nodes, "normalized_graph.nodes", out);
  const edges = requireArray(graph.edges, "normalized_graph.edges", out);
  const nodeIds = new Set();
  const nameByType = new Set();

  for (const node of nodes) {
    for (const key of ["id", "node_type", "name", "payload", "source_spec_type", "source_refs"]) {
      if (!(key in node)) {
        out.push(violation("G1", node.id ?? "unknown_node", `Missing node key: ${key}`, "normalized_graph.nodes", "graph/normalized_graph.json"));
      }
    }
    if (!allowedNodeTypes.has(node.node_type)) {
      out.push(violation("G2", node.id, `Invalid node type: ${node.node_type}`, "normalized_graph.nodes.node_type", "systemdesign.md#canonical-graph-structures"));
    }
    if (node.node_type === "feature") {
      out.push(violation("G2", node.id, "Feature must not be a persisted graph node type.", "normalized_graph.nodes.node_type", "db_schema.md#graph-nodes-and-edges"));
    }
    if (nodeIds.has(node.id)) {
      out.push(violation("G3", node.id, "Duplicate node id.", "normalized_graph.nodes.id", "v_4.3.md#normalization-strict"));
    }
    nodeIds.add(node.id);
    const nameKey = `${node.node_type}:${node.name}`;
    if (nameByType.has(nameKey)) {
      out.push(violation("G3", node.id, `Duplicate node semantic name: ${nameKey}`, "normalized_graph.nodes.name", "v_4.3.md#normalization-strict"));
    }
    nameByType.add(nameKey);
    if (!Array.isArray(node.source_refs) || node.source_refs.length === 0) {
      out.push(violation("G1", node.id, "Node lacks source references.", "normalized_graph.nodes.source_refs", "graph/docs_manifest.json"));
    }
    if (node.node_type === "interface") {
      for (const key of ["input", "output", "preconditions", "postconditions", "success_example", "failure_examples"]) {
        if (!(key in node.payload)) {
          out.push(violation("I1", node.id, `Interface payload missing ${key}.`, "normalized_graph.nodes.payload", "v_4.3.md#interface"));
        }
      }
    }
  }

  for (const edge of edges) {
    for (const key of ["id", "edge_type", "source_node_id", "target_node_id", "metadata"]) {
      if (!(key in edge)) {
        out.push(violation("G1", edge.id ?? "unknown_edge", `Missing edge key: ${key}`, "normalized_graph.edges", "graph/normalized_graph.json"));
      }
    }
    if (!allowedEdgeTypes.has(edge.edge_type)) {
      out.push(violation("G2", edge.id, `Invalid edge type: ${edge.edge_type}`, "normalized_graph.edges.edge_type", "systemdesign.md#canonical-graph-structures"));
    }
    if (!nodeIds.has(edge.source_node_id)) {
      out.push(violation("G1", edge.id, `Unknown source node: ${edge.source_node_id}`, "normalized_graph.edges.source_node_id", "graph/normalized_graph.json"));
    }
    if (!nodeIds.has(edge.target_node_id)) {
      out.push(violation("G1", edge.id, `Unknown target node: ${edge.target_node_id}`, "normalized_graph.edges.target_node_id", "graph/normalized_graph.json"));
    }
    if (edge.source_node_id === edge.target_node_id) {
      out.push(violation("G1", edge.id, "Self-referential edge is invalid.", "normalized_graph.edges", "db_schema.md#graph_edges"));
    }
  }

  return nodeIds;
}

function validateUiGraph(uiGraph, out) {
  if (uiGraph.methodology_constraints?.direct_graph_mutation_surface_allowed !== false) {
    out.push(violation("D1", "ui_graph", "UI graph must not allow direct graph mutation surfaces.", "ui_graph.methodology_constraints", "v_4.3.md#ui-invariants"));
  }
  const screens = requireArray(uiGraph.primary_screen_hierarchy, "ui_graph.primary_screen_hierarchy", out);
  if (screens.length !== 13) {
    out.push(violation("D1", "ui_graph", `Expected 13 primary screens, found ${screens.length}.`, "ui_graph.primary_screen_hierarchy", "uiux.md#screen-hierarchy"));
  }
  const graphExplorer = (uiGraph.secondary_inspection_surfaces ?? []).find((surface) => surface.id === "surface.graph_explorer");
  if (!graphExplorer) {
    out.push(violation("D1", "ui_graph", "Missing Graph Explorer inspection surface.", "ui_graph.secondary_inspection_surfaces", "uiux.md#graph-visibility-principle"));
  } else {
    const forbidden = new Set(graphExplorer.forbidden_actions ?? []);
    for (const action of ["create_node", "edit_node", "delete_node", "mutate_edge"]) {
      if (!forbidden.has(action)) {
        out.push(violation("D1", "surface.graph_explorer", `Graph Explorer does not forbid ${action}.`, "ui_graph.secondary_inspection_surfaces", "uiux.md#graph-visibility-principle"));
      }
    }
  }
  if (!String(uiGraph.design_tokens?.status_rule ?? "").toLowerCase().includes("text")) {
    out.push(violation("D1", "ui_graph", "Status rule must require explicit text, not color alone.", "ui_graph.design_tokens.status_rule", "DESIGN.md#colors"));
  }
}

function validateDocsManifest(manifest, out) {
  const docs = requireArray(manifest.documents, "docs_manifest.documents", out);
  const paths = new Set(docs.map((doc) => doc.path));
  const expected = [
    "sembl_docs/v_4.3.md",
    "sembl_docs/v_43_final_product_statement_and_execution_architecture.md",
    "sembl_docs/pdd.md",
    "sembl_docs/prd.md",
    "sembl_docs/nfr.md",
    "sembl_docs/techarch.md",
    "sembl_docs/systemdesign.md",
    "sembl_docs/api_spec.md",
    "sembl_docs/db_schema.md",
    "sembl_docs/uiux.md",
    "sembl_docs/DESIGN.md"
  ];
  for (const doc of expected) {
    if (!paths.has(doc)) {
      out.push(violation("DOCS", doc, "Missing canonical document from manifest.", "docs_manifest.documents", "graph/docs_manifest.json"));
    }
  }
  if (manifest.methodology_authority?.path !== "sembl_docs/v_4.3.md") {
    out.push(violation("DOCS", "methodology_authority", "V4.3 must be the methodology authority.", "docs_manifest.methodology_authority", "sembl_docs/v_4.3.md"));
  }
  if (manifest.canonical_peer_policy?.no_fixed_peer_priority !== true) {
    out.push(violation("DOCS", "canonical_peer_policy", "Canonical peer docs must not use a fixed priority ladder.", "docs_manifest.canonical_peer_policy", "graph/docs_manifest.json"));
  }
}

async function collectPacketPaths() {
  const dir = jsonPath("graph", "task-packets");
  const names = await fs.readdir(dir);
  return names.filter((name) => name.endsWith(".json")).map((name) => `graph/task-packets/${name}`);
}

async function validateCycleFixture(out) {
  const fixture = await readJson("graph", "fixtures.cyclic_task_graph.json");
  const tasks = fixture.tasks;
  const ids = new Set(tasks.map((task) => task.id));
  const cycle = detectCycle([...ids], (id) => tasks.find((task) => task.id === id)?.dependencies ?? []);
  if (!cycle) {
    out.push(violation("E2", "negative_cycle_fixture", "Expected cycle fixture to fail, but no cycle was detected.", "graph/fixtures.cyclic_task_graph.json", "v_4.3.md#task-graph-orchestration"));
  }
}

async function validateSecretScan(out) {
  const forbiddenFiles = [".env", ".env.local", ".env.production", ".env.development"];
  for (const file of forbiddenFiles) {
    try {
      await fs.stat(jsonPath(file));
      out.push(violation("S1", file, "Forbidden environment file is present in repo root.", file, "techarch.md#external-runtime-dependencies"));
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
  }
  const servicePreflight = await readJson("graph", "service_preflight.json");
  const raw = JSON.stringify(servicePreflight);
  for (const pattern of ["service_role", "SUPABASE_SERVICE_ROLE_KEY", "ghp_", "vercel_token"]) {
    if (raw.includes(pattern)) {
      out.push(violation("S1", "service_preflight", `Potential secret pattern found: ${pattern}`, "graph/service_preflight.json", "techarch.md#external-runtime-dependencies"));
    }
  }
}

async function main() {
  const out = [];
  const warnings = [];
  const manifest = await readJson("graph", "docs_manifest.json");
  const concept = await readJson("graph", "concept_graph.json");
  const uiGraph = await readJson("graph", "ui_graph.json");
  const normalized = await readJson("graph", "normalized_graph.json");
  const agents = await readJson("graph", "agents", "agent_roster.json");
  const taskGraph = await readJson("graph", "task_graph.json");
  const servicePreflight = await readJson("graph", "service_preflight.json");
  const semanticState = await readJson("graph", "semantic_state_store.json");
  const packetPaths = await collectPacketPaths();

  validateDocsManifest(manifest, out);
  validateUiGraph(uiGraph, out);
  validateNormalizedGraph(normalized, out);
  validateTaskDag(taskGraph, agents, packetPaths, out);
  await validateCycleFixture(out);
  await validateSecretScan(out);

  if (!Array.isArray(concept.ambiguities)) {
    out.push(violation("G1", "concept_graph", "Concept graph must contain an ambiguities array.", "concept_graph.ambiguities", "graph/concept_graph.json"));
  }

  const supabaseStatus = servicePreflight.checks?.supabase?.status;
  if (supabaseStatus !== "passed" && supabaseStatus !== "takeover_reset_complete") {
    warnings.push({
      code: "SERVICE_PREFLIGHT_SUPABASE_TAKEOVER_PENDING",
      severity: "warning",
      affected_structure: "service_preflight.checks.supabase",
      reason: "Existing Supabase project takeover reset is not complete; do not start Supabase-backed build tasks until resolved.",
      source_ref: "graph/service_preflight.json"
    });
  }

  if (!semanticState.current_version_id || !Array.isArray(semanticState.versions)) {
    out.push(violation("STATE_STORE", "semantic_state_store", "Semantic state store must define current_version_id and versions.", "graph/semantic_state_store.json", "v_4.3.md#graph-versioning"));
  }
  const currentVersion = semanticState.versions?.find((version) => version.id === semanticState.current_version_id);
  if (!currentVersion) {
    out.push(violation("STATE_STORE", "semantic_state_store", "current_version_id does not resolve to a semantic state version.", "graph/semantic_state_store.json", "v_4.3.md#graph-versioning"));
  }

  const passStatus = out.length === 0 ? "passed" : "failed";
  const report = {
    schema_version: "sembl.v4_3.validation_report.v1",
    generated_at: new Date().toISOString(),
    status: passStatus,
    passes: [
      { name: "structural", status: passStatus, violations: out.filter((item) => ["STRUCTURE", "TASK_STRUCTURE", "DOCS"].includes(item.invariant_id)) },
      { name: "semantic", status: passStatus, violations: out.filter((item) => ["G1", "G2", "G3", "I1"].includes(item.invariant_id)) },
      { name: "mapping", status: passStatus, violations: out.filter((item) => ["TASK_DEPENDENCY", "TASK_AGENT", "TASK_PACKET"].includes(item.invariant_id)) },
      { name: "completeness", status: passStatus, violations: out.filter((item) => ["TASK_MODEL_POLICY", "MODEL_POLICY"].includes(item.invariant_id)) },
      { name: "execution_boundary", status: passStatus, violations: out.filter((item) => ["TASK_EXECUTION_BOUNDARY", "E2"].includes(item.invariant_id)) },
      { name: "ui_consistency", status: passStatus, violations: out.filter((item) => item.invariant_id === "D1") },
      { name: "service_secret_safety", status: passStatus, violations: out.filter((item) => item.invariant_id === "S1") },
      { name: "negative_cycle_fixture", status: "passed", violations: [] }
    ],
    blocking_violations: out.filter((item) => item.severity === "blocking"),
    warnings,
    summary: out.length === 0
      ? warnings.length === 0
        ? "Graph artifacts passed local V4.3 validation."
        : "Graph artifacts passed local V4.3 validation with recorded service preflight warnings."
      : "Graph artifacts have blocking validation failures."
  };

  await fs.writeFile(jsonPath("graph", "validation_report.json"), `${JSON.stringify(report, null, 2)}\n`);

  if (out.length > 0) {
    console.error(JSON.stringify(report, null, 2));
    process.exitCode = 1;
    return;
  }
  console.log("Graph artifacts passed local V4.3 validation.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
