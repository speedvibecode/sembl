import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const root = process.cwd();
const outFile = join(
  root,
  "supabase",
  "migrations",
  "20260602134518_seed_sembl_core_runtime.sql"
);

const graph = JSON.parse(
  readFileSync(join(root, "graph", "normalized_graph.json"), "utf8")
);
const taskGraph = JSON.parse(
  readFileSync(join(root, "graph", "task_graph.json"), "utf8")
);
const validationReport = JSON.parse(
  readFileSync(join(root, "graph", "validation_report.json"), "utf8")
);
const servicePreflight = JSON.parse(
  readFileSync(join(root, "graph", "service_preflight.json"), "utf8")
);

const createdAt = "2026-06-02T12:00:00.000Z";
const seedUserEmail = "system@sembl.local";

function uuidFor(key) {
  const hex = createHash("sha1").update(`sembl:${key}`).digest("hex").slice(0, 32);
  const chars = hex.split("");
  chars[12] = "5";
  chars[16] = ((parseInt(chars[16], 16) & 0x3) | 0x8).toString(16);
  return [
    chars.slice(0, 8).join(""),
    chars.slice(8, 12).join(""),
    chars.slice(12, 16).join(""),
    chars.slice(16, 20).join(""),
    chars.slice(20, 32).join("")
  ].join("-");
}

function sql(value) {
  if (value === null || value === undefined) {
    return "null";
  }
  return `'${String(value).replaceAll("'", "''")}'`;
}

function json(value) {
  return `${sql(JSON.stringify(value))}::jsonb`;
}

function uuidArray(values) {
  if (!values.length) {
    return "'{}'::uuid[]";
  }
  return `array[${values.map((value) => sql(value)).join(", ")}]::uuid[]`;
}

const ids = {
  seedUser: uuidFor("auth:system-user"),
  seedIdentity: uuidFor("auth:system-identity"),
  workspace: uuidFor("workspace:workspace_speedvibe"),
  workspaceMember: uuidFor("workspace_member:system-owner"),
  githubIntegration: uuidFor("integration:github"),
  vercelIntegration: uuidFor("integration:vercel"),
  project: uuidFor("project:project_sembl_core"),
  repositoryReference: uuidFor("repository:github:speedvibecode/sembl"),
  graphVersion: uuidFor("graph_version:graph_version.v0_docs_seed"),
  branch: uuidFor("branch:branch_main"),
  semanticDiff: uuidFor("semantic_diff:semantic_diff_seed"),
  approval: uuidFor("approval:approval_execution_preflight"),
  executionRun: uuidFor("execution:execution_seed_ready"),
  reconciliation: uuidFor("reconciliation:reconciliation_seed"),
  deployment: uuidFor("deployment:sembl-vercel-production"),
  ingestionRun: uuidFor("ingestion:github-reconstruction"),
  validationGroup: uuidFor("validation_group:v4_3"),
  notification: uuidFor("notification:seed-ready")
};

const specs = [
  ["pdd", "pdd.md"],
  ["prd", "prd.md"],
  ["nfr", "nfr.md"],
  ["uiux", "uiux.md"],
  ["system_design", "systemdesign.md"],
  ["db_schema", "db_schema.md"],
  ["api_spec", "api_spec.md"],
  ["tech_architecture", "techarch.md"]
].map(([type, file]) => {
  const content = readFileSync(join(root, "sembl_docs", file), "utf8");
  return {
    type,
    file,
    documentId: uuidFor(`spec_document:${type}`),
    revisionId: uuidFor(`spec_revision:${type}:1`),
    content,
    hash: createHash("sha256").update(content).digest("hex")
  };
});

const specRevisionByType = new Map(
  specs.map((spec) => [spec.type, spec.revisionId])
);
const nodeIdBySemanticId = new Map(
  graph.nodes.map((node) => [node.id, uuidFor(`graph_node:${node.id}`)])
);
const edgeIdBySemanticId = new Map(
  graph.edges.map((edge) => [edge.id, uuidFor(`graph_edge:${edge.id}`)])
);
const taskIdBySemanticId = new Map(
  taskGraph.tasks.map((task) => [task.id, uuidFor(`execution_task:${task.id}`)])
);

const lines = [];
const add = (line = "") => lines.push(line);

add("-- Seed Sembl Core runtime data from graph artifacts.");
add("-- Deterministic UUIDs preserve relational integrity while original graph IDs live in JSON payloads.");
add("");
add("insert into auth.users (");
add("  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,");
add("  raw_app_meta_data, raw_user_meta_data, created_at, updated_at, is_sso_user, is_anonymous");
add(") values (");
add(`  '00000000-0000-0000-0000-000000000000', ${sql(ids.seedUser)}, 'authenticated', 'authenticated', ${sql(seedUserEmail)}, null, ${sql(createdAt)},`);
add(`  ${json({ provider: "email", providers: ["email"], seed: true })}, ${json({ name: "Sembl System Seed" })}, ${sql(createdAt)}, ${sql(createdAt)}, false, false`);
add(") on conflict (id) do nothing;");
add("");
add("insert into auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)");
add("values (");
add(`  ${sql(ids.seedIdentity)}, ${sql(ids.seedUser)}, ${sql(ids.seedUser)},`);
add(`  ${json({ sub: ids.seedUser, email: seedUserEmail, email_verified: true, seed: true })},`);
add(`  'email', null, ${sql(createdAt)}, ${sql(createdAt)}`);
add(") on conflict do nothing;");
add("");
add("insert into public.workspaces (id, name, slug, created_at, updated_at)");
add(`values (${sql(ids.workspace)}, 'Speedvibe', 'speedvibe', ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.workspace_members (id, workspace_id, user_id, role, joined_at)");
add(`values (${sql(ids.workspaceMember)}, ${sql(ids.workspace)}, ${sql(ids.seedUser)}, 'owner', ${sql(createdAt)})`);
add("on conflict do nothing;");
add("");
add("insert into public.workspace_integrations (id, workspace_id, provider, external_id, metadata, created_at, updated_at) values");
add(`(${sql(ids.githubIntegration)}, ${sql(ids.workspace)}, 'github', 'speedvibecode/sembl', ${json({ url: "https://github.com/speedvibecode/sembl" })}, ${sql(createdAt)}, ${sql(createdAt)}),`);
add(`(${sql(ids.vercelIntegration)}, ${sql(ids.workspace)}, 'vercel', 'sembl', ${json({ url: "https://sembl.vercel.app" })}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.projects (id, workspace_id, name, slug, lifecycle_state, operational_mode, created_by, created_at, updated_at)");
add(`values (${sql(ids.project)}, ${sql(ids.workspace)}, 'Sembl Core', 'sembl-core', 'awaiting_approval', 'execution', ${sql(ids.seedUser)}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.repository_references (id, project_id, provider, external_url, external_id, default_branch, metadata, created_at, updated_at)");
add(`values (${sql(ids.repositoryReference)}, ${sql(ids.project)}, 'github', 'https://github.com/speedvibecode/sembl', 'speedvibecode/sembl', 'master', ${json({ seeded_from: "graph/service_preflight.json" })}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");

for (const spec of specs) {
  add("insert into public.specification_documents (id, project_id, spec_type, draft_content, draft_updated_at, created_at, updated_at)");
  add(`values (${sql(spec.documentId)}, ${sql(ids.project)}, ${sql(spec.type)}, ${sql(spec.content)}, ${sql(createdAt)}, ${sql(createdAt)}, ${sql(createdAt)})`);
  add("on conflict (id) do nothing;");
  add("insert into public.specification_revisions (id, document_id, project_id, revision_number, content, content_hash, authored_by, parent_revision_id, created_at)");
  add(`values (${sql(spec.revisionId)}, ${sql(spec.documentId)}, ${sql(ids.project)}, 1, ${sql(spec.content)}, ${sql(spec.hash)}, ${sql(ids.seedUser)}, null, ${sql(createdAt)})`);
  add("on conflict (id) do nothing;");
  add(`update public.specification_documents set active_revision_id = ${sql(spec.revisionId)}, updated_at = ${sql(createdAt)} where id = ${sql(spec.documentId)};`);
  add("");
}

add("insert into public.graph_versions (id, project_id, version_number, parent_version_id, source_spec_revision_id, created_at)");
add(`values (${sql(ids.graphVersion)}, ${sql(ids.project)}, 0, null, ${sql(specRevisionByType.get("prd"))}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.branches (id, project_id, name, base_graph_version_id, state, created_by, created_at, updated_at)");
add(`values (${sql(ids.branch)}, ${sql(ids.project)}, 'main', ${sql(ids.graphVersion)}, 'active', ${sql(ids.seedUser)}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");

add("insert into public.graph_nodes (id, project_id, graph_version_id, node_type, name, payload, source_spec_type, source_revision_id, created_at) values");
add(
  graph.nodes
    .map((node) => {
      const canonicalSpecType = specRevisionByType.has(node.source_spec_type)
        ? node.source_spec_type
        : null;
      const payload = {
        ...node.payload,
        semantic_id: node.id,
        original_source_spec_type: node.source_spec_type,
        source_refs: node.source_refs ?? []
      };
      return `(${sql(nodeIdBySemanticId.get(node.id))}, ${sql(ids.project)}, ${sql(ids.graphVersion)}, ${sql(node.node_type)}, ${sql(node.name)}, ${json(payload)}, ${sql(canonicalSpecType)}, ${sql(specRevisionByType.get(canonicalSpecType))}, ${sql(node.created_at ?? createdAt)})`;
    })
    .join(",\n")
);
add("on conflict (id) do nothing;");
add("");

add("insert into public.graph_edges (id, project_id, graph_version_id, edge_type, source_node_id, target_node_id, metadata, created_at) values");
add(
  graph.edges
    .map((edge) => {
      const metadata = {
        ...edge.metadata,
        semantic_id: edge.id,
        semantic_source_node_id: edge.source_node_id,
        semantic_target_node_id: edge.target_node_id
      };
      return `(${sql(edgeIdBySemanticId.get(edge.id))}, ${sql(ids.project)}, ${sql(ids.graphVersion)}, ${sql(edge.edge_type)}, ${sql(nodeIdBySemanticId.get(edge.source_node_id))}, ${sql(nodeIdBySemanticId.get(edge.target_node_id))}, ${json(metadata)}, ${sql(edge.created_at ?? createdAt)})`;
    })
    .join(",\n")
);
add("on conflict (id) do nothing;");
add("");

add("insert into public.semantic_diffs (id, project_id, from_version_id, to_version_id, diff_payload, created_at)");
add(`values (${sql(ids.semanticDiff)}, ${sql(ids.project)}, null, ${sql(ids.graphVersion)}, ${json({ seeded_from: "graph/normalized_graph.json", node_count: graph.nodes.length, edge_count: graph.edges.length })}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("update public.projects");
add(`set active_branch_id = ${sql(ids.branch)}, active_graph_version_id = ${sql(ids.graphVersion)}, updated_at = ${sql(createdAt)}`);
add(`where id = ${sql(ids.project)};`);
add("");

add("insert into public.events (id, project_id, branch_id, event_type, sequence_number, actor_id, originating_subsystem, affected_scope, source_state, target_state, metadata, created_at) values");
add(`(${sql(uuidFor("event:specification-created"))}, ${sql(ids.project)}, ${sql(ids.branch)}, 'SpecificationCreated', 1, ${sql(ids.seedUser)}, 'seed_migration', ${json({ spec_count: specs.length })}, null, 'documents_seeded', ${json({ migration: "seed_sembl_core_runtime" })}, ${sql(createdAt)}),`);
add(`(${sql(uuidFor("event:graph-committed"))}, ${sql(ids.project)}, ${sql(ids.branch)}, 'GraphMutationCommitted', 2, ${sql(ids.seedUser)}, 'seed_migration', ${json({ graph_version_id: ids.graphVersion, node_count: graph.nodes.length, edge_count: graph.edges.length })}, null, 'graph_seeded', ${json({ migration: "seed_sembl_core_runtime" })}, ${sql(createdAt)}),`);
add(`(${sql(uuidFor("event:approval-requested"))}, ${sql(ids.project)}, ${sql(ids.branch)}, 'ExecutionApprovalRequested', 3, ${sql(ids.seedUser)}, 'seed_migration', ${json({ approval_id: ids.approval })}, null, 'awaiting_approval', ${json({ migration: "seed_sembl_core_runtime" })}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");

add("insert into public.validation_run_groups (id, project_id, branch_id, target_type, target_id, status, completed_at, created_at)");
add(`values (${sql(ids.validationGroup)}, ${sql(ids.project)}, ${sql(ids.branch)}, 'repository_ingestion', ${sql(ids.project)}, ${sql(validationReport.status === "passed" ? "passed" : "passed_with_warnings")}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.validation_runs (id, group_id, project_id, pass_number, status, completed_at, created_at) values");
add(
  [1, 2, 3]
    .map((passNumber) => `(${sql(uuidFor(`validation_run:${passNumber}`))}, ${sql(ids.validationGroup)}, ${sql(ids.project)}, ${passNumber}, 'passed', ${sql(createdAt)}, ${sql(createdAt)})`)
    .join(",\n")
);
add("on conflict (id) do nothing;");
add("");

add("insert into public.approvals (id, project_id, branch_id, approval_type, status, requested_by, affected_scope, mutation_summary, expires_at, created_at, updated_at)");
add(`values (${sql(ids.approval)}, ${sql(ids.project)}, ${sql(ids.branch)}, 'execution_approval', 'pending', ${sql(ids.seedUser)}, ${json({ graph_version_id: ids.graphVersion, execution_boundary: "node.boundary.api_runtime" })}, ${json({ summary: "Approve graph-scoped execution from the validated V4.3 task DAG.", impact_score: 0.74, impacted_nodes: ["node.interface.generate_task_graph", "node.interface.start_execution", "node.interface.reconcile_execution_output"] })}, '2026-06-09T00:00:00.000Z', ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.execution_runs (id, project_id, branch_id, graph_version_id, approval_id, status, triggered_by, metadata, created_at, updated_at)");
add(`values (${sql(ids.executionRun)}, ${sql(ids.project)}, ${sql(ids.branch)}, ${sql(ids.graphVersion)}, ${sql(ids.approval)}, 'queued', null, ${json({ seeded_from: "graph/task_graph.json" })}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");

const orderedTasks = taskGraph.topological_order.map((taskId) =>
  taskGraph.tasks.find((task) => task.id === taskId)
);
add("insert into public.execution_tasks (id, execution_run_id, project_id, execution_boundary_node_id, sequence_number, status, dependency_task_ids, output_payload, started_at, completed_at, failure_reason, created_at) values");
add(
  orderedTasks
    .map((task, index) => {
      const status = index < 6 ? "completed" : index === 6 ? "running" : "pending";
      const startedAt = index < 7 ? sql(createdAt) : "null";
      const completedAt = index < 6 ? sql(createdAt) : "null";
      return `(${sql(taskIdBySemanticId.get(task.id))}, ${sql(ids.executionRun)}, ${sql(ids.project)}, ${sql(task.execution_boundary ? nodeIdBySemanticId.get(task.execution_boundary) : null)}, ${index + 1}, ${sql(status)}, ${uuidArray(task.dependencies.map((dependency) => taskIdBySemanticId.get(dependency)))}, ${json({ task_id: task.id, name: task.name, agent: task.agent, graph_scope: task.graph_scope, context_persisted: false })}, ${startedAt}, ${completedAt}, null, ${sql(createdAt)})`;
    })
    .join(",\n")
);
add("on conflict (id) do nothing;");
add("");

add("insert into public.reconciliation_attempts (id, project_id, branch_id, execution_run_id, merge_attempt_id, status, snapshot_version_id, output_version_id, semantic_diff_id, failure_reason, started_at, created_at, updated_at)");
add(`values (${sql(ids.reconciliation)}, ${sql(ids.project)}, ${sql(ids.branch)}, ${sql(ids.executionRun)}, null, 'diff_generated', ${sql(ids.graphVersion)}, null, ${sql(ids.semanticDiff)}, null, ${sql(createdAt)}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.deployments (id, project_id, branch_id, graph_version_id, execution_run_id, provider, provider_deployment_id, provider_url, environment, status, triggered_by, deployed_at, health_verified_at, metadata, created_at, updated_at)");
add(`values (${sql(ids.deployment)}, ${sql(ids.project)}, ${sql(ids.branch)}, ${sql(ids.graphVersion)}, ${sql(ids.executionRun)}, 'vercel', null, 'https://sembl.vercel.app', 'production', 'healthy', ${sql(ids.seedUser)}, ${sql(createdAt)}, ${sql(createdAt)}, ${json({ seeded_from: "vercel production alias" })}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.repository_ingestion_runs (id, project_id, repository_reference_id, status, output_graph_version_id, triggered_by, analysis_metadata, started_at, activated_at, created_at, updated_at)");
add(`values (${sql(ids.ingestionRun)}, ${sql(ids.project)}, ${sql(ids.repositoryReference)}, 'activated', ${sql(ids.graphVersion)}, ${sql(ids.seedUser)}, ${json({ validation_status: validationReport.status, service_preflight: servicePreflight.checks })}, ${sql(createdAt)}, ${sql(createdAt)}, ${sql(createdAt)}, ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("insert into public.notifications (id, workspace_id, project_id, recipient_user_id, severity, title, body, action_url, created_at)");
add(`values (${sql(ids.notification)}, ${sql(ids.workspace)}, ${sql(ids.project)}, ${sql(ids.seedUser)}, 'action_required', 'Sembl Core seeded', 'The Supabase runtime now contains the Sembl Core graph, task DAG, validation state, and deployment record.', 'https://sembl.vercel.app', ${sql(createdAt)})`);
add("on conflict (id) do nothing;");
add("");
add("analyze public.workspaces;");
add("analyze public.projects;");
add("analyze public.graph_nodes;");
add("analyze public.graph_edges;");
add("analyze public.execution_tasks;");
add("");

writeFileSync(outFile, `${lines.join("\n")}\n`);
