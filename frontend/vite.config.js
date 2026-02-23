import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:8080',
    },
  },
  optimizeDeps: {
    exclude: ['@yowasp/yosys'],
  },
  assetsInclude: ['**/*.wasm', '**/*.tar'],
})
