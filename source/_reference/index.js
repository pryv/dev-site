// for loading .coffee files
require('coffee-script').register();

exports.sections = [
  require('./basics.coffee'),
  // TODO: include authorization flow here?
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = '1.7.0';
exports.helpers = require('./helpers.coffee');

exports.system = require('./system.coffee');
exports.admin = require('./admin.coffee');

