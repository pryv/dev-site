source = [
  id: 'about'
  titleShort: 'About'
  titleFull: 'About the API'
  layout: '_layouts/default'
  withExamples: false
  withTOC: false
,
  id: 'apps-and-services'
  titleShort: 'Pryv apps & services'
  titleFull: 'Pryv apps and services'
  layout: '_layouts/default'
  withExamples: false
  withTOC: false
,
  id: 'app-access'
  titleShort: 'App auth'
  titleFull: 'App authorization flow'
  layout: '_layouts/default'
  withExamples: false
  withTOC: true
,
  id: 'code-libraries'
  titleShort: 'Code libraries'
  titleFull: 'Code libraries'
  layout: '_layouts/default'
  withExamples: false
  withTOC: false
,
  id: 'concepts'
  titleShort: 'Concepts'
  titleFull: 'Concepts'
  layout: '_layouts/default'
  withExamples: false
  withTOC: true
,
  id: 'dev-index'
  titleShort: 'Home'
  # no in-page full title
  layout: '_layouts/default'
  withExamples: false
  withTOC: false
  landingPage: true
,
  # TODO: rename to event-types: https://github.com/sintaxi/harp/issues/106
  id: 'event-typez'
  titleShort: 'Event types'
  titleFull: 'Event types reference'
  layout: '_layouts/default'
  sourcePath: 'event-types/hierarchical.json'
  flatPath: 'event-types/flat.json'
  sourceData: require('../event-types/hierarchical.json')
  withExamples: false
  withTOC: true
  tocSelectors: 'h1:not(.page-title),h2,h3'
,
  id: 'reference'
  titleShort: 'Reference'
  titleFull: 'API reference'
  layout: '_layouts/default'
  markdown: require('marked')
  withExamples: {menu: true}
  withTOC: true
,
  id: 'standard-structure'
  titleShort: 'Standard data structure'
  titleFull: 'Standard data structure reference'
  layout: '_layouts/default'
  # TODO: 'standard-structure' when abovementioned issue fixed
  sourcePath: 'standard-struct/channels-folders.json'
  sourceData: require('../standard-struct/channels-folders.json')
  withExamples: false
  withTOC: true
]

pages = module.exports = {}
source.forEach (pageData) ->
  pageData.linkTo = require('./links.coffee')
  pageData.apiReference = require('../_api-reference')
  pages[pageData.id] = pageData
