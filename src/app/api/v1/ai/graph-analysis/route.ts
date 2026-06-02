import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { requireRouteUser } from "@/lib/auth";
import {
  DEFAULT_OPENAI_MODEL,
  getModelCatalog,
  validateModelId
} from "@/lib/openai-models";
import { getRuntimeGraphSummary } from "@/lib/runtime-store";

const graphAnalysisSchema = z.object({
  apiKey: z.string().optional(),
  model: z.string().min(1).default(DEFAULT_OPENAI_MODEL),
  projectId: z.string().optional(),
  prompt: z.string().min(1).max(4000)
});

type OpenAIResponse = {
  output_text?: string;
  output?: Array<{
    content?: Array<{
      text?: string;
      type?: string;
    }>;
  }>;
};

export async function POST(request: NextRequest) {
  try {
    const user = await requireRouteUser(request);
    const body = graphAnalysisSchema.parse(await request.json());
    const apiKey = body.apiKey?.trim() || process.env.OPENAI_API_KEY;

    if (!apiKey) {
      return fail(
        "api_key_required",
        "Enter an OpenAI API key to run AI graph analysis.",
        400
      );
    }

    const catalog = await getModelCatalog(apiKey);
    if (!validateModelId(body.model, catalog)) {
      return fail(
        "unsupported_model",
        "Choose a GPT-5 family model available to this key.",
        422,
        { model: body.model, available_models: catalog.map((entry) => entry.id) }
      );
    }

    const summary = await getRuntimeGraphSummary(user.id, body.projectId);
    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: body.model,
        input: [
          {
            role: "system",
            content:
              "You analyze Sembl v4.3 semantic graph state. Treat the graph as canonical state, specs as first-class source intent, and execution artifacts as derived. Return concise risks, affected graph scope, and next moves. Do not request or reveal secrets."
          },
          {
            role: "user",
            content: `${body.prompt}\n\nGraph summary:\n${JSON.stringify(summary, null, 2)}`
          }
        ]
      })
    });

    if (!response.ok) {
      const details = (await response.json().catch(() => null)) as Record<
        string,
        unknown
      > | null;
      return fail(
        "openai_request_failed",
        "OpenAI graph analysis request failed.",
        response.status,
        details
      );
    }

    const result = (await response.json()) as OpenAIResponse;
    const output =
      result.output_text ??
      result.output
        ?.flatMap((item) => item.content ?? [])
        .map((content) => content.text)
        .filter(Boolean)
        .join("\n") ??
      "No text output returned.";

    return ok({
      model: body.model,
      output,
      key_persisted: false
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return fail("invalid_request", "Graph analysis request is invalid.", 422, {
        issues: error.issues
      });
    }
    if (error instanceof Error && error.message === "unauthorized") {
      return fail("unauthorized", "Sign in to run AI graph analysis.", 401);
    }

    return fail(
      "graph_analysis_failed",
      error instanceof Error ? error.message : "Graph analysis failed.",
      500
    );
  }
}
