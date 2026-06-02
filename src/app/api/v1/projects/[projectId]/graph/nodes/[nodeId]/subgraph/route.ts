import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeSubgraph } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; nodeId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, nodeId } = await params;

    const depth = Number(request.nextUrl.searchParams.get("depth") ?? "2");
    const subgraph = await getRuntimeSubgraph(
      user.id,
      projectId,
      nodeId,
      Number.isFinite(depth) ? depth : 2
    );
    if (!subgraph) {
      return fail("not_found", "Graph node does not exist.", 404);
    }

    return ok(subgraph);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
