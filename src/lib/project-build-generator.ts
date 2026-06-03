import { createHash } from "node:crypto";
import { z } from "zod";
import {
  DEFAULT_OPENAI_MODEL,
  getModelCatalog,
  validateModelId
} from "./openai-models";
import type { ProjectBuildFileRole, SpecificationDraft } from "./types";

const buildFileRoleSchema = z.enum(["source", "config", "test", "doc", "asset"]);

const generatedBuildSchema = z.object({
  summary: z.string().trim().min(1).max(2000),
  files: z
    .array(
      z.object({
        path: z.string().trim().min(1).max(180),
        role: buildFileRoleSchema.default("source"),
        language: z.string().trim().max(48).optional().nullable(),
        content: z.string().min(1).max(60000)
      })
    )
    .min(4)
    .max(28)
});

export type GeneratedProjectBuild = z.infer<typeof generatedBuildSchema>;

type OpenAIResponse = {
  output_text?: string;
  output?: Array<{
    content?: Array<{
      text?: string;
      type?: string;
    }>;
  }>;
};

export type BuildGenerationInput = {
  apiKey?: string;
  model?: string;
  projectName: string;
  projectId: string;
  graphVersionId: string;
  specs: SpecificationDraft[];
  graphSummary: unknown;
  buildPrompt?: string;
};

export type NormalizedGeneratedFile = {
  path: string;
  role: ProjectBuildFileRole;
  language: string | null;
  content: string;
  checksum: string;
  byteSize: number;
};

export type NormalizedProjectBuild = {
  model: string;
  promptHash: string;
  summary: string;
  files: NormalizedGeneratedFile[];
  providerState: {
    github: {
      status: "blocked" | "configured";
      reason: string | null;
    };
    vercel: {
      status: "blocked" | "configured";
      reason: string | null;
    };
  };
};

function excerpt(value: string, limit = 4500) {
  const compact = value.replace(/\r\n/g, "\n").trim();
  return compact.length > limit ? `${compact.slice(0, limit)}\n[truncated]` : compact;
}

function outputText(payload: OpenAIResponse) {
  return (
    payload.output_text ??
    payload.output
      ?.flatMap((item) => item.content ?? [])
      .map((content) => content.text)
      .filter(Boolean)
      .join("\n") ??
    ""
  );
}

function parseJsonObject(text: string) {
  const trimmed = text.trim();
  const fenced = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  const source = fenced?.[1] ?? trimmed;
  const firstBrace = source.indexOf("{");
  const lastBrace = source.lastIndexOf("}");

  if (firstBrace < 0 || lastBrace < firstBrace) {
    throw new Error("invalid_generation_json");
  }

  return JSON.parse(source.slice(firstBrace, lastBrace + 1)) as unknown;
}

function validatePath(path: string) {
  if (
    path.startsWith("/") ||
    path.startsWith("./") ||
    path.startsWith("../") ||
    path.includes("..") ||
    path.includes("\\") ||
    /(^|\/)\.env($|\.|\/)/i.test(path)
  ) {
    throw new Error(`unsafe_generated_path:${path}`);
  }
}

function normalizeFiles(files: GeneratedProjectBuild["files"]): NormalizedGeneratedFile[] {
  const seen = new Set<string>();
  const normalized = files.map((file) => {
    const path = file.path.replace(/^\/+/, "").trim();
    validatePath(path);
    if (seen.has(path)) {
      throw new Error(`duplicate_generated_path:${path}`);
    }
    seen.add(path);

    if (path === "package.json") {
      JSON.parse(file.content);
    }

    const checksum = createHash("sha256").update(file.content).digest("hex");
    return {
      path,
      role: file.role,
      language: file.language?.trim() || null,
      content: file.content,
      checksum,
      byteSize: Buffer.byteLength(file.content, "utf8")
    };
  });

  const paths = new Set(normalized.map((file) => file.path));
  for (const required of ["package.json", "README.md"]) {
    if (!paths.has(required)) {
      throw new Error(`required_generated_file_missing:${required}`);
    }
  }

  return normalized;
}

export function providerState() {
  const githubConfigured = Boolean(
    process.env.GITHUB_TOKEN &&
      (process.env.SEMBL_FACTORY_GITHUB_OWNER || process.env.GITHUB_OWNER)
  );
  const vercelConfigured = Boolean(process.env.VERCEL_TOKEN);

  return {
    github: {
      status: githubConfigured ? ("configured" as const) : ("blocked" as const),
      reason: githubConfigured
        ? null
        : "GitHub export requires GITHUB_TOKEN and SEMBL_FACTORY_GITHUB_OWNER on the deployed backend."
    },
    vercel: {
      status: vercelConfigured ? ("configured" as const) : ("blocked" as const),
      reason: vercelConfigured
        ? null
        : "Vercel deployment requires VERCEL_TOKEN on the deployed backend."
    }
  };
}

export async function generateProjectBuild(
  input: BuildGenerationInput
): Promise<NormalizedProjectBuild> {
  const apiKey = input.apiKey?.trim() || process.env.OPENAI_API_KEY;
  const model = input.model?.trim() || DEFAULT_OPENAI_MODEL;

  if (!apiKey) {
    throw new Error("api_key_required");
  }

  const catalog = await getModelCatalog(apiKey);
  if (!validateModelId(model, catalog)) {
    throw new Error("unsupported_model");
  }

  const activeSpecs = input.specs.filter((spec) => spec.active_revision_id);
  if (!activeSpecs.length) {
    throw new Error("specification_required");
  }

  const promptPayload = {
    project: {
      id: input.projectId,
      name: input.projectName,
      graph_version_id: input.graphVersionId
    },
    build_prompt: input.buildPrompt?.trim() || null,
    graph_summary: input.graphSummary,
    specs: activeSpecs.map((spec) => ({
      type: spec.spec_type,
      revision: spec.active_revision_number,
      content: excerpt(spec.active_content)
    }))
  };
  const promptHash = createHash("sha256").update(JSON.stringify(promptPayload)).digest("hex");

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: "system",
          content: [
            "You are the Sembl v4.3 project compiler.",
            "Compile published specifications and canonical graph state into a concrete, inspectable software artifact.",
            "Return only JSON with shape { summary: string, files: [{ path, role, language, content }] }.",
            "Generate a small but usable Next.js/React project unless the specs clearly require another web stack.",
            "The file bundle must include package.json, README.md, source files, styling, and any small tests or data modules needed to run.",
            "Do not include secrets. Use .env.example only for placeholders. Do not claim GitHub or Vercel deployment succeeded.",
            "Prefer clean accessible UI, real local state, truthful empty/error states, and implementation details derived from the specs."
          ].join(" ")
        },
        {
          role: "user",
          content: JSON.stringify(promptPayload, null, 2)
        }
      ]
    })
  });

  if (!response.ok) {
    const details = (await response.json().catch(() => null)) as
      | { error?: { message?: string } }
      | null;
    throw new Error(details?.error?.message || "openai_request_failed");
  }

  const payload = (await response.json()) as OpenAIResponse;
  const parsed = generatedBuildSchema.parse(parseJsonObject(outputText(payload)));
  const files = normalizeFiles(parsed.files);

  return {
    model,
    promptHash,
    summary: parsed.summary,
    files,
    providerState: providerState()
  };
}
