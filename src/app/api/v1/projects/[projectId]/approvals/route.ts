import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { PROJECT_ID } from "@/lib/semantic-store";
import { getRuntimeApprovals } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    await requireRouteUser(request);
    const { projectId } = await params;

    if (projectId !== PROJECT_ID) {
      return fail("not_found", "Approvals are not visible.", 404);
    }

    return ok(await getRuntimeApprovals());
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
