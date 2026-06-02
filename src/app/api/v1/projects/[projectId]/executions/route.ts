import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { getRuntimeExecutions } from "@/lib/runtime-store";
import {
  BRANCH_ID,
  createExecutionRun,
  PROJECT_ID
} from "@/lib/semantic-store";

const executionRequestSchema = z.object({
  branch_id: z.string(),
  approval_id: z.string()
});

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Executions are not visible.", 404);
    }

    return ok(await getRuntimeExecutions());
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
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Project is not visible.", 404);
    }

    const body = executionRequestSchema.parse(await request.json());
    if (body.branch_id !== BRANCH_ID) {
      return fail("invalid_state", "Execution branch is not active.", 409);
    }

    return ok(createExecutionRun(body.approval_id, user.id));
  } catch (error) {
    if (error instanceof Error && error.message === "approval_expired") {
      return fail("approval_expired", "Referenced approval has expired.", 409);
    }
    if (error instanceof Error && error.message === "approval_required") {
      return fail("approval_required", "Execution requires a valid approval.", 409);
    }
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Execution request is invalid.", 422, {
        issues: error.issues
      });
    }

    const message = error instanceof Error ? error.message : "Unauthorized request.";
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
