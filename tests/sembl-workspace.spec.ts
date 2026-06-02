import { expect, test } from "@playwright/test";

test("workspace renders the first meaningful screen", async ({ page }) => {
  const consoleErrors: string[] = [];
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });

  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Sembl Core" })).toBeVisible();
  await expect(page.getByText("Awaiting Approval")).toBeVisible();
  await expect(page.getByRole("heading", { name: "Specification State" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "Graph Explorer" })).toBeVisible();
  await expect(page.getByPlaceholder("Enter OpenAI API key")).toBeVisible();
  expect(consoleErrors).toEqual([]);
});

test("approval and AI graph key controls respond", async ({ page }) => {
  await page.goto("/");

  await page.getByRole("button", { name: "Approve" }).click();
  await expect(page.getByText("approved")).toBeVisible();

  await page.getByRole("button", { name: "Analyze Graph" }).click();
  await expect(page.getByText("Enter an OpenAI API key")).toBeVisible();
});

test("graph node inspection updates selected node", async ({ page }) => {
  await page.goto("/");

  await page.getByTitle("entity: Project").click();
  await expect(page.getByRole("heading", { name: "Project", exact: true })).toBeVisible();
  await expect(page.getByText("\"workspace_id\": \"string\"")).toBeVisible();
});

test("graph API follows response envelope", async ({ request }) => {
  const response = await request.get("/api/v1/projects/project_sembl_core/graph");
  expect(response.ok()).toBeTruthy();

  const payload = await response.json();
  expect(payload.data.version_id).toBe("graph_version.v0_docs_seed");
  expect(payload.data.nodes.length).toBeGreaterThan(0);
  expect(payload.meta).toBeNull();
});
