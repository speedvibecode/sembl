import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { compileGraphFromSpecs, getRuntimeGraphVersions } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;

    return ok(await getRuntimeGraphVersions(user.id, projectId));
  } catch (error) {
    if (error instanceof Error && error.message === "not_found") {
      return fail("not_found", "Graph versions are not visible.", 404);
    }
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId } = await params;

    return ok(await compileGraphFromSpecs(user.id, projectId));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "not_found") {
      return fail("not_found", "Project is not visible.", 404);
    }
    if (message === "specification_required") {
      return fail("specification_required", "Publish at least one spec before compiling the graph.", 409);
    }
    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
