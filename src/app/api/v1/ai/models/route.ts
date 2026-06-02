import type { NextRequest } from "next/server";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import { DEFAULT_OPENAI_MODEL, getModelCatalog } from "@/lib/openai-models";

export async function GET(request: NextRequest) {
  try {
    await requireRouteUser(request);
    const apiKey =
      request.headers.get("x-openai-api-key")?.trim() || process.env.OPENAI_API_KEY;
    const models = await getModelCatalog(apiKey);

    return ok({
      default_model: DEFAULT_OPENAI_MODEL,
      models,
      key_persisted: false
    });
  } catch (error) {
    return fail(
      "unauthorized",
      error instanceof Error ? error.message : "Sign in to view model catalog.",
      401
    );
  }
}
