import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { decideApproval, PROJECT_ID } from "@/lib/semantic-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; approvalId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId, approvalId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Approval is not visible.", 404);
    }

    const approval = decideApproval(approvalId, "rejected");
    if (!approval) {
      return fail("not_found", "Approval does not exist.", 404);
    }

    return ok(approval);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
