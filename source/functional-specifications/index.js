// for loading .coffee files
require('coffee-script').register();

exports.sections = [
  require('./intro.coffee'),
  require('./terms.coffee'),
  require('./requirements.coffee'),
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');


