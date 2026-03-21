import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: "dist",
  },
  server: {
    proxy: {
      "/auth": "http://localhost:8080",
      "/reader": "http://localhost:8080",
      "/admin": "http://localhost:8080",
      "/sys": "http://localhost:8080",
      "/img": "http://localhost:8080",
      "/dav": "http://localhost:8080",
      "/m4t": "http://localhost:8080",
      "/user": "http://localhost:8080",
      "/sync": "http://localhost:8080",
      "/healthz": "http://localhost:8080",
    },
  },
});
