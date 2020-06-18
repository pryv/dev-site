// for loading .coffee files
require('coffee-script').register();

exports.sections = [
  require('./basics.coffee'),
  // TODO: include authorization flow here?
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = '1.5.18';
exports.helpers = require('./helpers.coffee');

exports.system = require('./system.coffee');

