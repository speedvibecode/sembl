import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import { compileGraphFromSpecs } from "@/lib/runtime-store";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin", "member"]);

    return ok(await compileGraphFromSpecs(user.id, projectId));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "not_found") {
      return fail("not_found", "Project is not visible.", 404);
    }
    if (message === "specification_required") {
      return fail("specification_required", "Publish at least one spec before compiling the graph.", 409);
    }
    return fail(message === "forbidden" ? "forbidden" : "unauthorized", message, message === "forbidden" ? 403 : 401);
  }
}
