module.exports = {
  _: require('lodash'),
  apiReference: require('./source/_reference'),
  functionalSpecifications: require('./source/functional-specifications'),
  testResults: require('./source/test-results'),
  helpers: require('./source/_templates/helpers'),
  markdown: require('marked')
};
