// for loading .coffee files
require('coffee-script');

module.exports = exports = [
  require('./basics.coffee'),
  // TODO: include authorization flow here?
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = require('../../../api-server/package.json').version;
exports.getDocId = require('./helpers.coffee').getDocId;
