import { NextResponse, type NextRequest } from "next/server";
import { fail } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { createBuildArchive } from "@/lib/build-archive";
import { getRuntimeBuildFiles, getRuntimeBuildRun } from "@/lib/runtime-store";

function safeName(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "build";
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; buildRunId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, buildRunId } = await params;
    const buildRun = await getRuntimeBuildRun(user.id, projectId, buildRunId);
    if (!buildRun) {
      return fail("not_found", "Build run is not visible.", 404);
    }

    const files = await getRuntimeBuildFiles(user.id, projectId, buildRunId);
    if (!files.length) {
      return fail("artifact_empty", "This build run does not have generated files yet.", 409);
    }

    const archive = createBuildArchive(buildRun, files);
    return new NextResponse(archive, {
      headers: {
        "content-type": "application/zip",
        "content-disposition": `attachment; filename="${safeName(`sembl-${buildRun.id.slice(0, 8)}`)}.zip"`,
        "content-length": String(archive.byteLength),
        "cache-control": "private, no-store"
      }
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Build archive is unavailable.";
    if (message === "unauthorized") {
      return fail("unauthorized", "Sign in to download build artifacts.", 401);
    }
    if (message === "not_found") {
      return fail("not_found", "Project is not visible.", 404);
    }

    return fail("build_archive_failed", message, 500);
  }
}
