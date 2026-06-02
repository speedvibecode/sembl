import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeApprovals } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; approvalId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, approvalId } = await params;

    const approval = (await getRuntimeApprovals(user.id, projectId)).find(
      (item) => item.id === approvalId
    );
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
