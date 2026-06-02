import { SemblWorkspace } from "@/components/sembl-workspace";
import { getRuntimeHomeData } from "@/lib/runtime-store";

export const dynamic = "force-dynamic";

export default async function Home() {
  const { snapshot, graph, approvals, tasks, reconciliations } =
    await getRuntimeHomeData();

  return (
    <SemblWorkspace
      snapshot={snapshot}
      graph={graph}
      approvals={approvals}
      tasks={tasks}
      reconciliations={reconciliations}
    />
  );
}
