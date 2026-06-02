import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { getRuntimeSpecs } from "@/lib/runtime-store";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;

    return ok(await getRuntimeSpecs(user.id, projectId));
  } catch (error) {
    if (error instanceof Error && error.message === "not_found") {
      return fail("not_found", "Specifications are not visible.", 404);
    }

    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}
