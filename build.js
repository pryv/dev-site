var metalsmith = require('metalsmith')(__dirname),
    collections = require('metalsmith-collections'),
    define = require('metalsmith-define'),
    globals = require('./globals'),
    ignore = require('metalsmith-ignore'),
    include = require('metalsmith-include'),
    jade = require('metalsmith-jade'),
    json = require('metalsmith-json'),
    markdown = require('metalsmith-markdown'),
    permalinks = require('metalsmith-permalinks'),
    stylus = require('metalsmith-stylus'),
    templates = require('metalsmith-templates'),
    watch = process.argv[2] === 'watch' ? require('metalsmith-watch') : null;

metalsmith
    .source('./source')
    .destination('./build')
    .clean(false) // to keep .git, CNAME etc.
    .use(define(globals))
    .use(json({key: 'contents'}))
    .use(include())
    .use(collections({
      appAccessSections: {
        pattern: 'app-access/_sections/*.md',
        sortBy: 'sectionOrder'
      }
    }))
    .use(markdown())
    .use(jade({useMetadata: true}))
    .use(stylus({
      paths: ['node_modules/pryv-style/stylus'],
      nib: true,
      compress: true
    }))
    .use(templates({
      engine: 'jade',
      directory: 'source/_templates'
    }))
    .use(ignore([
      '_reference/**',
      '_templates/*',
      'app-access/_sections/*',
      'event-types/_source/*',
      'functional-specifications/**'
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
