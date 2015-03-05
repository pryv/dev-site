// for loading .coffee files
require('coffee-script').register();

exports.sections = [
  require('./basics.coffee'),
  // TODO: include authorization flow here?
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = require('pryv-service-core/package.json').version;
exports.helpers = require('./helpers.coffee');

