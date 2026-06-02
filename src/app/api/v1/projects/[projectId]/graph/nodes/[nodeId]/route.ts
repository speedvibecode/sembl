import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getNode, PROJECT_ID } from "@/lib/semantic-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; nodeId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId, nodeId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Graph node is not visible.", 404);
    }

    const node = getNode(nodeId);
    if (!node) {
      return fail("not_found", "Graph node does not exist.", 404);
    }

    return ok(node);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
