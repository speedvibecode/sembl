import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import { decideRuntimeApproval } from "@/lib/runtime-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; approvalId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, approvalId } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin"]);

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
