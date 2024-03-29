#!/usr/bin/env node

const metalsmith = require('metalsmith')(__dirname);
const msDefine = require('metalsmith-define');
const msHeadingsId = require('metalsmith-headings-identifier');
const msIgnore = require('metalsmith-ignore');
const msInclude = require('metalsmith-include');
const msLayouts = require('metalsmith-layouts');
const msJSON = require('metalsmith-json');
const msMarkdownIt = require('metalsmith-markdownit');
const msPermalinks = require('metalsmith-permalinks');
const msPug = require('metalsmith-pug');
const msStylus = require('metalsmith-stylus');
const msLinkCheck = require('./metalsmith-plugins/linkcheck');
const msWatch = require('metalsmith-watch');

const args = process.argv.slice(2);
const options = {
  noLinkCheck: args.includes('--nolinkcheck'),
  watch: args.includes('--watch')
};

const markdownItOptions = {
  typographer: true,
  html: true
};
const markdownIt = require('markdown-it')(markdownItOptions);

const globals = {
  _: require('lodash'),
  apiReference: require('./src/_reference'),
  functionalSpecifications: require('./src/_functional-specifications'),
  testResults: require('./src/_test-results'),
  helpers: require('./src/_reference/helpers'),
  markdown: (string) => markdownIt.render(string)
};

metalsmith
  .source('./src')
  .destination('./dist')
  .clean(false) // to keep .git, CNAME etc.
  .use(msDefine(globals))
  .use(msJSON({ key: 'contents' }))
  .use(msInclude())
  .use(msPug({ useMetadata: true }))
  .use(msMarkdownIt(markdownItOptions))
  .use(msStylus({
    paths: ['node_modules/pryv-style/stylus'],
    nib: true,
    compress: true
  }))
  .use(msLayouts({
    directory: 'src/_layouts',
    engineOptions: { useMetadata: true }
  }))
  .use(msHeadingsId({
    // do NOT generate anchor link as the current jQuery ToC plugin does it already
    linkTemplate: '<!--%s-->'
  }))
  .use(msIgnore([
    '_reference/**',
    '_layouts/**',
    '_functional-specifications/**',
    '_test-results/**',
    'event-types/_source/*'
  ]))
  .use(msPermalinks({
    // section id is optional in metadata
    pattern: ':sectionId/:id',
    relative: false
  }));

if (!options.noLinkCheck) {
  metalsmith.use(msLinkCheck({
    ignoreFile: '.linkcheck-ignore.json',
    checkFile: '.linkcheck-cache.json',
    failFile: 'linkcheck-issues.json'
  }));
}

if (options.watch) {
  metalsmith.use(msWatch());
}

metalsmith.build(function (err) {
  if (err) { return console.error(err); }
  console.log('OK');
});
