import cloudflare from "@astrojs/cloudflare";
import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://vichisa.com",
  output: "server",
  adapter: cloudflare({
    platformProxy: { enabled: true },
  }),
});
