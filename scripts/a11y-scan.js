import { chromium } from "playwright";
import AxeBuilder from "@axe-core/playwright";

const BASE = process.env.BASE_URL || "http://127.0.0.1:8787";

const PATHS = ["/", "/boda", "/viaje", "/belleza", "/vigo", "/regalo", "/rsvp", "/noexiste"];

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ viewport: { width: 375, height: 812 } });
let failed = false;

for (const path of PATHS) {
  const page = await context.newPage();
  const url = `${BASE}${path}`;
  await page.goto(url, { waitUntil: "networkidle" });

  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  const serious = results.violations.filter((v) => v.impact === "serious");
  const critical = results.violations.filter((v) => v.impact === "critical");

  console.log(`\n${path}`);
  console.log(
    `  violations: ${results.violations.length} (${critical.length} critical, ${serious.length} serious)`,
  );

  for (const v of [...critical, ...serious]) {
    console.log(`  ❌ ${v.impact}: ${v.help} (${v.id})`);
    for (const node of v.nodes.slice(0, 3)) {
      console.log(`     ${node.html.replace(/\s+/g, " ").slice(0, 120)}`);
    }
  }

  if (critical.length || serious.length) failed = true;
  await page.close();
}

await browser.close();

if (failed) {
  console.log("\nA11y scan failed: critical or serious issues found.");
  process.exit(1);
} else {
  console.log("\nA11y scan passed: no critical or serious issues.");
}
