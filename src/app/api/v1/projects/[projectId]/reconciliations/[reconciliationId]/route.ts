import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getReconciliation, PROJECT_ID } from "@/lib/semantic-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; reconciliationId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId, reconciliationId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Reconciliation is not visible.", 404);
    }

    const reconciliation = getReconciliation(reconciliationId);
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
