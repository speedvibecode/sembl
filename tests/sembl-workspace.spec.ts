import { expect, test, type APIResponse } from "@playwright/test";

test("unauthenticated users see the real Supabase Auth gate", async ({ page }) => {
  const consoleErrors: string[] = [];
  page.on("console", (message) => {
    if (message.type() === "error") {
      consoleErrors.push(message.text());
    }
  });

  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Open the canonical workspace" })).toBeVisible();
  await expect(page.getByText("Sembl now requires Supabase Auth.")).toBeVisible();
  await expect(
    page.getByLabel("Authentication mode").getByRole("button", { name: "Sign in" })
  ).toBeVisible();
  await expect(
    page.getByLabel("Authentication mode").getByRole("button", { name: "Create account" })
  ).toBeVisible();
  expect(consoleErrors).toEqual([]);
});

test("protected APIs reject missing sessions", async ({ request }) => {
  const graph = await request.get("/api/v1/projects/project_sembl_core/graph");
  expect(graph.status()).toBe(401);
  await expectUnauthorized(graph);

  const models = await request.get("/api/v1/ai/models");
  expect(models.status()).toBe(401);
  await expectUnauthorized(models);
});

const e2eEmail = process.env.SEMBL_E2E_EMAIL;
const e2ePassword = process.env.SEMBL_E2E_PASSWORD;

test.describe("authenticated v4.3 workflow", () => {
  test.skip(
    !e2eEmail || !e2ePassword,
    "Set SEMBL_E2E_EMAIL and SEMBL_E2E_PASSWORD to run the persisted workflow test."
  );

  test("publishes specs, compiles graph, approves, executes, reconciles, and shows deployment state", async ({
    page
  }) => {
    await page.goto("/");

    await page.getByLabel("Email").fill(e2eEmail ?? "");
    await page.getByLabel("Password").fill(e2ePassword ?? "");
    await page.getByRole("button", { name: "Sign in" }).click();

    await expect(page.getByRole("heading", { name: "Sembl Core" })).toBeVisible({
      timeout: 20_000
    });
    await expect(page.getByRole("heading", { name: "Specifications" })).toBeVisible();

    const editor = page.locator("textarea.spec-editor");
    await expect(editor).toBeVisible();
    await editor.fill(`${await editor.inputValue()}\n\nE2E validation note: ${Date.now()}`);

    await page.getByRole("button", { name: "Save draft" }).click();
    await expect(page.getByText("Draft saved.")).toBeVisible();

    await page.getByRole("button", { name: "Publish" }).click();
    await expect(page.getByText("Revision published and validation recorded.")).toBeVisible();

    await page.getByRole("button", { name: "Compile graph" }).click();
    await expect(page.getByText("Graph version compiled and approval requested.")).toBeVisible();

    await page.getByRole("button", { name: "Approve" }).click();
    await expect(page.getByText("Approval approved.")).toBeVisible();

    await page.getByRole("button", { name: "Start execution" }).click();
    await expect(page.getByText("Execution run created.")).toBeVisible();

    const retry = page.getByRole("button", { name: "Retry latest" });
    if (await retry.isVisible()) {
      await retry.click();
      await expect(page.getByText("Retry run created.")).toBeVisible();
    }

    for (let attempt = 0; attempt < 20; attempt += 1) {
      const advance = page.getByRole("button", { name: "Advance next task" });
      if (!(await advance.isVisible())) break;
      await advance.click();
      await expect(page.getByText("Execution state advanced.")).toBeVisible();
    }

    await page.getByRole("button", { name: "Reconciliation" }).click();
    await expect(page.getByRole("heading", { name: "Reconciliation" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Event Log" })).toBeVisible();

    await page.getByRole("button", { name: "Deployments" }).click();
    await expect(page.getByRole("heading", { name: "Deployments" })).toBeVisible();
    await expect(page.getByText("production")).toBeVisible();
  });
});

async function expectUnauthorized(response: APIResponse) {
  const payload = await response.json();
  expect(payload.error.code).toBe("unauthorized");
}
