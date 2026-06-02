import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeExecution } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, runId } = await params;

    const execution = await getRuntimeExecution(user.id, projectId, runId);
    if (!execution) {
      return fail("not_found", "Execution does not exist.", 404);
    }

    return ok(execution);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
