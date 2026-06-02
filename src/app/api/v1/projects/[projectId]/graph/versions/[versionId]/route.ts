import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeGraphVersion } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; versionId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, versionId } = await params;

    const version = await getRuntimeGraphVersion(user.id, projectId, versionId);
    if (!version) {
      return fail("not_found", "Graph version does not exist.", 404);
    }

    return ok(version);
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
