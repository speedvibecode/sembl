import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { PROJECT_ID } from "@/lib/semantic-store";
import { getRuntimeExecution } from "@/lib/runtime-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId, runId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Execution is not visible.", 404);
    }

    const execution = await getRuntimeExecution(runId);
    if (!execution) {
      return fail("not_found", "Execution does not exist.", 404);
    }

    return ok({
      ...execution,
      id: `retry_${Date.now()}`,
      status: "queued",
      triggered_by: user.id,
      created_at: new Date().toISOString()
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
