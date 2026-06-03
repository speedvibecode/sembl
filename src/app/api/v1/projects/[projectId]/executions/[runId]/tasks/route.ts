import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import {
  advanceRuntimeExecution,
  getRuntimeExecutionTasks
} from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, runId } = await params;

    return ok(await getRuntimeExecutionTasks(user.id, projectId, runId));
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; runId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, runId } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin"]);

    return ok(await advanceRuntimeExecution(user.id, projectId, runId));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "not_found") {
      return fail("not_found", "Execution does not exist.", 404);
    }
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
