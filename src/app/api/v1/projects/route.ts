import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import {
  createRuntimeProject,
  getRuntimeHomeData,
  getRuntimeProjectDirectory
} from "@/lib/runtime-store";

const createProjectSchema = z.object({
  name: z.string().trim().min(2).max(96),
  brief: z.string().trim().max(4000).optional(),
  workspace_id: z.string().uuid().optional(),
  workspace_name: z.string().trim().min(2).max(96).optional()
});

export async function GET(request: NextRequest) {
  try {
    const user = await requireRouteUser(request);
    return ok(await getRuntimeProjectDirectory(user.id));
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Unauthorized request.",
      401
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const user = await requireRouteUser(request);
    const body = createProjectSchema.parse(await request.json());
    const project = await createRuntimeProject(user.id, {
      name: body.name,
      brief: body.brief,
      workspaceId: body.workspace_id,
      workspaceName: body.workspace_name
    });

    return ok({
      project,
      state: await getRuntimeHomeData(user.id, project.id, user.email)
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Project request is invalid.", 422, {
        issues: error.issues
      });
    }

    const message = error instanceof Error ? error.message : "Unauthorized request.";
    if (message === "forbidden") {
      return fail("forbidden", "Workspace is not writable by this user.", 403);
    }
    if (message === "project_name_required") {
      return fail("invalid_request", "Project name is required.", 422);
    }

    return fail("unauthorized", message, 401);
  }
}
