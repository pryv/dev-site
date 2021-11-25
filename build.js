const metalsmith = require('metalsmith')(__dirname);
const collections = require('metalsmith-collections');
const define = require('metalsmith-define');
const globals = require('./globals');
const ignore = require('metalsmith-ignore');
const include = require('metalsmith-include');
const layouts = require('metalsmith-layouts');
const json = require('metalsmith-json');
const markdown = require('metalsmith-markdownit');
const permalinks = require('metalsmith-permalinks');
const pug = require('metalsmith-pug');
const stylus = require('metalsmith-stylus');
const watch = process.argv[2] === 'watch' ? require('metalsmith-watch') : null;

metalsmith
  .source('./source')
  .destination('./build')
  .clean(false) // to keep .git, CNAME etc.
  .use(define(globals))
  .use(json({ key: 'contents' }))
  .use(include())
  .use(collections({
    appAccessSections: {
      pattern: 'app-access/_sections/*.md',
      sortBy: 'sectionOrder'
    }
  }))
  .use(pug({ useMetadata: true }))
  .use(markdown({
    typographer: true,
    html: true
  }))
  .use(stylus({
    paths: ['node_modules/pryv-style/stylus'],
    nib: true,
    compress: true
  }))
  .use(layouts({
    directory: 'source/_templates',
    engineOptions: { useMetadata: true }
  }))
  .use(ignore([
    '_reference/**',
    '_templates/*',
    'app-access/_sections/*',
    'event-types/_source/*',
    'functional-specifications/**',
    'test-results/**', 'test-results/_source/**', 'test-results/_source/.git'
  ]))
  .use(permalinks({
    // section id is optional in metadata
    pattern: ':sectionId/:id',
    relative: false
  }));

if (watch) {
  metalsmith.use(watch());
}

metalsmith.build(function (err) {
  if (err) { return console.error(err); }
  console.log('OK');
});
