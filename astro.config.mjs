import cloudflare from "@astrojs/cloudflare";
import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://vichisa.com",
  output: "server",
  // No Astro sessions: authentication uses our own signed cookie (PP-13/PP-14).
  // This also stops the adapter from auto-injecting a SESSION KV binding without
  // a namespace id, which `wrangler deploy` rejects (error 10021).
  session: false,
  adapter: cloudflare({
    platformProxy: { enabled: true },
  }),
});
