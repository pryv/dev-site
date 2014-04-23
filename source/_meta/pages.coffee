source = [
  id: 'about'
  titleShort: 'About'
  titleFull: 'About the API'
,
  id: 'apps-and-services'
  titleShort: 'Pryv apps & services'
  titleFull: 'Pryv apps and services'
,
  id: 'app-access'
  titleShort: 'App auth'
  titleFull: 'App authorization flow'
  withTOC: true
,
  id: 'change-log'
  titleShort: 'API change log'
  titleFull: 'API change log'
,
  id: 'code-libraries'
  titleShort: 'Code libraries'
  titleFull: 'Code libraries'
,
  id: 'concepts'
  titleShort: 'Concepts'
  titleFull: 'Concepts'
  withTOC: true
,
  id: 'faq'
  titleShort: 'FAQ'
  titleFull: 'Frequently Asked Questions'
,
  id: 'event-types'
  titleShort: 'Event types'
  titleFull: 'Event types reference'
  sourcePath: 'hierarchical.json'
  flatPath: 'flat.json'
  sourceData: require('../event-types/hierarchical.json')
  withTOC: true
  tocSelectors: 'h1:not(.page-title),h2,h3'
,
  id: 'home'
  titleShort: 'Home'
  # no in-page full title
  layout: '_layout'
  landingPage: true
,
  id: 'reference'
  titleShort: 'Reference'
  titleFull: 'API reference'
  markdown: require('marked')
  withExamples: {menu: true}
  withTOC: true
  showTrustedOnlyContent: false
,
  id: 'reference-full'
  titleShort: 'Reference (full)'
  titleFull: 'API reference'
  markdown: require('marked')
  withExamples: {menu: true}
  withTOC: true
  showTrustedOnlyContent: true
,
  id: 'standard-structure'
  titleShort: 'Standard data structure'
  titleFull: 'Standard data structure reference'
  sourcePath: 'standard-structure/channels-folders.json'
  sourceData: require('../standard-structure/channels-folders.json')
  withTOC: true
]

pages = module.exports = {}
source.forEach (pageData) ->
  # set defaults
  pageData.layout ?= '../_layout'
  pageData.withExamples ?= false
  pageData.withTOC ?= false

  # add common metadata to all
  pageData.linkTo = require('./links.coffee')
  pageData.apiReference = require('../_reference')
  pageData.pages = pages

  pages[pageData.id] = pageData
