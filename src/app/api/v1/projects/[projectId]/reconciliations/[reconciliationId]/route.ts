import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeReconciliation } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; reconciliationId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, reconciliationId } = await params;

    const reconciliation = await getRuntimeReconciliation(
      user.id,
      projectId,
      reconciliationId
    );
    if (!reconciliation) {
      return fail("not_found", "Reconciliation does not exist.", 404);
    }

    return ok(reconciliation);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
