import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeNode } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; nodeId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, nodeId } = await params;

    const node = await getRuntimeNode(user.id, projectId, nodeId);
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
