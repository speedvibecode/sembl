import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeBuildFiles } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; buildRunId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, buildRunId } = await params;
    return ok({ files: await getRuntimeBuildFiles(user.id, projectId, buildRunId) });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Build files are unavailable.";
    if (message === "unauthorized") {
      return fail("unauthorized", "Sign in to inspect build files.", 401);
    }
    if (message === "not_found") {
      return fail("not_found", "Project is not visible.", 404);
    }

    return fail("build_files_failed", message, 500);
  }
}
