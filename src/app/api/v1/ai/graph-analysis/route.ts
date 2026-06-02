import type { NextRequest } from "next/server";
import { z } from "zod";
import { fail, ok } from "@/lib/api-response";
import { getGraphSummary } from "@/lib/semantic-store";

const graphAnalysisSchema = z.object({
  apiKey: z.string().optional(),
  model: z.string().min(1).default("gpt-4.1-mini"),
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
    const body = graphAnalysisSchema.parse(await request.json());
    const apiKey = body.apiKey?.trim() || process.env.OPENAI_API_KEY;

    if (!apiKey) {
      return fail(
        "api_key_required",
        "Enter an OpenAI API key to run AI graph analysis.",
        400
      );
    }

    const summary = getGraphSummary();
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
              "You analyze Sembl semantic graph state. Return actionable, concise graph observations with risks and next moves. Do not request secrets."
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

    return fail(
      "graph_analysis_failed",
      error instanceof Error ? error.message : "Graph analysis failed.",
      500
    );
  }
}
