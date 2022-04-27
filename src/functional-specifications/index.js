// for loading .coffee files
require('coffeescript').register();
const yaml = require('js-yaml');
const fs = require('fs');
const path = require('path');

function loadYaml (filename) {
  try {
    return yaml.load(fs.readFileSync(path.resolve(__dirname, filename), 'utf8'));
  } catch (error) {
    throw (new Error(`while parsing ${path.resolve(__dirname, filename)}\n${error.message}`));
  }
}

exports.sections = [
  require('./intro.coffee'),
  require('./terms.coffee'),
  loadYaml('./requirements.yml')
];

exports.version = '0.0.2';
exports.helpers = require('./helpers.coffee');
