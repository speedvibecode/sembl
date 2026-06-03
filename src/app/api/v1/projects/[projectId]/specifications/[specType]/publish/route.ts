import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import { publishSpecRevision } from "@/lib/runtime-store";

const publishSchema = z.object({
  content: z.string().min(1).optional()
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; specType: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, specType } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin", "member"]);
    const body = publishSchema.parse(await request.json());

    return ok(await publishSpecRevision(user.id, projectId, specType, body.content));
  } catch (error) {
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Publish request is invalid.", 422, {
        issues: error.issues
      });
    }

    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "spec_not_found" || message === "invalid_spec_type") {
      return fail("not_found", "Specification does not exist.", 404);
    }
    if (message === "draft_required") {
      return fail("draft_required", "Save a non-empty draft before publishing.", 409);
    }

    return fail(message === "forbidden" ? "forbidden" : "unauthorized", message, message === "forbidden" ? 403 : 401);
  }
}
