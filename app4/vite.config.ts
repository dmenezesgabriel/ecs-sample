import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import fs from "node:fs";

import { URL } from "url";

const prodServerOptions = {
  https: {
    key: fs.readFileSync(new URL("/etc/ssl/private/key.pem", import.meta.url)),
    cert: fs.readFileSync(new URL("/etc/ssl/certs/cert.pem", import.meta.url)),
  },
};

export default defineConfig(({ mode }: { mode: string }) => {
  return {
    plugins: [react()],
    base: "/app4/",
    server: mode === "production" ? prodServerOptions : {},
  };
});
