import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getExecutionTasks, PROJECT_ID } from "@/lib/semantic-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId, runId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Execution tasks are not visible.", 404);
    }

    return ok(getExecutionTasks(runId));
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
