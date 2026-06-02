import type { ModelCatalogEntry } from "./types";

export const DEFAULT_OPENAI_MODEL = "gpt-5.5";

const configuredCatalog: ModelCatalogEntry[] = [
  {
    id: "gpt-5.5",
    label: "GPT-5.5",
    family: "gpt-5",
    recommended: true,
    description: "Frontier GPT-5.5 model for graph reasoning and architecture analysis.",
    source: "configured"
  },
  {
    id: "gpt-5.4",
    label: "GPT-5.4",
    family: "gpt-5",
    description: "High-capability GPT-5 family model for deep semantic analysis.",
    source: "configured"
  },
  {
    id: "gpt-5.4-mini",
    label: "GPT-5.4 mini",
    family: "gpt-5",
    description: "Efficient GPT-5 family model for fast graph inspection.",
    source: "configured"
  },
  {
    id: "gpt-5.4-nano",
    label: "GPT-5.4 nano",
    family: "gpt-5",
    description: "Small GPT-5 family model for low-latency checks.",
    source: "configured"
  },
  {
    id: "gpt-5",
    label: "GPT-5",
    family: "gpt-5",
    description: "Baseline GPT-5 family model.",
    source: "configured"
  },
  {
    id: "gpt-5-mini",
    label: "GPT-5 mini",
    family: "gpt-5",
    description: "Efficient GPT-5 family model.",
    source: "configured"
  },
  {
    id: "gpt-5-nano",
    label: "GPT-5 nano",
    family: "gpt-5",
    description: "Small GPT-5 family model.",
    source: "configured"
  }
];

export function configuredModelCatalog() {
  return configuredCatalog;
}

export function validateModelId(model: string, catalog = configuredCatalog) {
  return catalog.some((entry) => entry.id === model);
}

export async function getModelCatalog(apiKey?: string): Promise<ModelCatalogEntry[]> {
  if (!apiKey) {
    return configuredCatalog;
  }

  try {
    const response = await fetch("https://api.openai.com/v1/models", {
      headers: {
        authorization: `Bearer ${apiKey}`
      }
    });

    if (!response.ok) {
      return configuredCatalog;
    }

    const payload = (await response.json()) as {
      data?: Array<{ id?: string }>;
    };
    const available = new Set((payload.data ?? []).map((model) => model.id).filter(Boolean));
    const dynamic = configuredCatalog.map((entry) => ({
      ...entry,
      source: available.has(entry.id) ? ("openai" as const) : entry.source
    }));
    const extraGpt5 = [...available]
      .filter((id): id is string => Boolean(id?.startsWith("gpt-5")))
      .filter((id) => !dynamic.some((entry) => entry.id === id))
      .sort()
      .map<ModelCatalogEntry>((id) => ({
        id,
        label: id,
        family: "gpt-5",
        description: "GPT-5 family model available to the supplied API key.",
        source: "openai"
      }));

    return [...dynamic, ...extraGpt5];
  } catch {
    return configuredCatalog;
  }
}
