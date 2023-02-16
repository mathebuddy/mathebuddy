import * as esbuild from 'esbuild';

esbuild.buildSync({
  platform: 'browser',
  globalName: 'mathebuddySMPL',
  minify: true,
  target: 'es2020',
  entryPoints: ['../src/index.ts'],
  bundle: true,
  outfile: 'mathebuddy-smpl-web.min.js',
});
