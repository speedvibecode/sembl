import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireAdmin, requireRouteUser } from "@/lib/auth";
import { publishSpecRevision } from "@/lib/runtime-store";

const publishSchema = z.object({
  content: z.string().min(1)
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string; specType: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    requireAdmin(user);
    const { projectId, specType } = await params;
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

    return fail(message === "forbidden" ? "unauthorized" : "unauthorized", message, 401);
  }
}
