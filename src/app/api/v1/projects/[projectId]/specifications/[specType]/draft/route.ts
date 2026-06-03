import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import { saveSpecDraft } from "@/lib/runtime-store";

const draftSchema = z.object({
  content: z.string().min(1)
});

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; specType: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId, specType } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin", "member"]);
    const body = draftSchema.parse(await request.json());

    return ok(await saveSpecDraft(user.id, projectId, specType, body.content));
  } catch (error) {
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Draft request is invalid.", 422, {
        issues: error.issues
      });
    }

    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "spec_not_found" || message === "invalid_spec_type") {
      return fail("not_found", "Specification does not exist.", 404);
    }

    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
