import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireProjectRole, requireRouteUser } from "@/lib/auth";
import {
  createRuntimeProjectBuild,
  getRuntimeBuildSnapshot
} from "@/lib/runtime-store";
import { DEFAULT_OPENAI_MODEL } from "@/lib/openai-models";

const createBuildSchema = z.object({
  apiKey: z.string().optional(),
  model: z.string().trim().min(1).default(DEFAULT_OPENAI_MODEL),
  prompt: z.string().trim().max(4000).optional()
});

function buildError(error: unknown) {
  const message = error instanceof Error ? error.message : "Build request failed.";

  if (message === "api_key_required") {
    return fail("api_key_required", "Enter an OpenAI API key to generate a project build.", 400);
  }
  if (message === "unsupported_model") {
    return fail("unsupported_model", "Choose a GPT-5 family model available to this key.", 422);
  }
  if (message === "specification_required") {
    return fail("specification_required", "Publish at least one spec before building.", 409);
  }
  if (message === "unauthorized") {
    return fail("unauthorized", "Sign in to use the project factory.", 401);
  }
  if (message === "forbidden") {
    return fail("forbidden", "Project is not writable by this user.", 403);
  }
  if (message === "not_found") {
    return fail("not_found", "Project is not visible.", 404);
  }

  return fail("build_failed", message, 500);
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;
    return ok(await getRuntimeBuildSnapshot(user.id, projectId));
  } catch (error) {
    return buildError(error);
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  try {
    const user = await requireRouteUser(request);
    const { projectId } = await params;
    await requireProjectRole(user.id, projectId, ["owner", "admin", "member"]);
    const body = createBuildSchema.parse(await request.json());

    return ok(
      await createRuntimeProjectBuild(user.id, projectId, {
        apiKey: body.apiKey,
        model: body.model,
        buildPrompt: body.prompt
      })
    );
  } catch (error) {
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Build request is invalid.", 422, {
        issues: error.issues
      });
    }

    return buildError(error);
  }
}
