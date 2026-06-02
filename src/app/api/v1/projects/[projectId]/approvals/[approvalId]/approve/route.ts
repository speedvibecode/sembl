import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { decideRuntimeApproval } from "@/lib/runtime-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; approvalId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId, approvalId } = await params;

    const approval = await decideRuntimeApproval(user.id, projectId, approvalId, "approved");
    if (!approval) {
      return fail("not_found", "Approval does not exist.", 404);
    }

    return ok(approval);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
