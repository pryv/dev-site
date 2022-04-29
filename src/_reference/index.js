// for loading .coffee files
require('coffeescript').register();

exports.sections = [
  require('./basics.coffee'),
  // TODO: include authorization flow here?
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = '1.7.10';

exports.system = require('./system.coffee');
exports.admin = require('./admin.coffee');
