import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  splitting: true,
  clean: true,
  format: ['cjs', 'esm'],
  treeshake: true,
  dts: true,
  sourcemap: 'inline',
});
