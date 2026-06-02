import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { PROJECT_ID } from "@/lib/semantic-store";
import { getRuntimeSubgraph } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; nodeId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId, nodeId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Subgraph is not visible.", 404);
    }

    const depth = Number(request.nextUrl.searchParams.get("depth") ?? "2");
    const subgraph = await getRuntimeSubgraph(
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
