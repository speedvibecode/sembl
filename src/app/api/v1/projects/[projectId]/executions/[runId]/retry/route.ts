import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { retryRuntimeExecution } from "@/lib/runtime-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId, runId } = await params;

    return ok(await retryRuntimeExecution(user.id, projectId, runId));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "not_found") {
      return fail("not_found", "Execution does not exist.", 404);
    }
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
