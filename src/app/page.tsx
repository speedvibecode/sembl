import { SemblWorkspace } from "@/components/sembl-workspace";
import {
  getApprovals,
  getDeterministicDag,
  getGraph,
  getProjectSnapshot,
  getReconciliations
} from "@/lib/semantic-store";

export default function Home() {
  return (
    <SemblWorkspace
      snapshot={getProjectSnapshot()}
      graph={getGraph()}
      approvals={getApprovals()}
      tasks={getDeterministicDag()}
      reconciliations={getReconciliations()}
    />
  );
}
