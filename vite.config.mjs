import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
  },
  server: {
    port: 5173,
    proxy: {
      '/download': 'http://localhost:4173',
      '/api': 'http://localhost:4173',
    },
  },
})
