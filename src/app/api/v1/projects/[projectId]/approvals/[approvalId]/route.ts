import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getApproval, PROJECT_ID } from "@/lib/semantic-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; approvalId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId, approvalId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Approval is not visible.", 404);
    }

    const approval = getApproval(approvalId);
    if (!approval) {
      return fail("not_found", "Approval does not exist.", 404);
    }

    return ok(approval);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
