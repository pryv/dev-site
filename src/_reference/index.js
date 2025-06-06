// for loading .coffee files
require('coffeescript').register();

exports.sections = [
  require('./basics.coffee'),
  require('./methods.coffee'),
  require('./data-structure.coffee')
];

exports.version = '1.9.2';

exports.system = require('./system.coffee');
exports.admin = require('./admin.coffee');
