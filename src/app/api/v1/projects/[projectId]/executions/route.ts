import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import {
  createRuntimeExecutionRun,
  getRuntimeExecutions
} from "@/lib/runtime-store";

const executionRequestSchema = z.object({
  branch_id: z.string().uuid().optional(),
  approval_id: z.string().uuid()
});

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;

    return ok(await getRuntimeExecutions(user.id, projectId));
  } catch (error) {
    if (error instanceof Error && error.message === "not_found") {
      return fail("not_found", "Executions are not visible.", 404);
    }
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
    const { projectId } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin"]);

    const body = executionRequestSchema.parse(await request.json());

    return ok(await createRuntimeExecutionRun(user.id, projectId, body.approval_id, body.branch_id));
  } catch (error) {
    if (error instanceof Error && error.message === "approval_expired") {
      return fail("approval_expired", "Referenced approval has expired.", 409);
    }
    if (error instanceof Error && error.message === "approval_required") {
      return fail("approval_required", "Execution requires a valid approval.", 409);
    }
    if (error instanceof Error && error.message === "approval_not_approved") {
      return fail("approval_not_approved", "Approve the execution request first.", 409);
    }
    if (error instanceof Error && error.message === "approval_type_mismatch") {
      return fail("approval_type_mismatch", "Approval is not an execution approval.", 409);
    }
    if (error instanceof Error && error.message === "branch_mismatch") {
      return fail("branch_mismatch", "Approval does not belong to the active branch.", 409);
    }
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Execution request is invalid.", 422, {
        issues: error.issues
      });
    }

    const message = error instanceof Error ? error.message : "Unauthorized request.";
    return fail(message === "forbidden" ? "forbidden" : "unauthorized", message, message === "forbidden" ? 403 : 401);
  }
}
