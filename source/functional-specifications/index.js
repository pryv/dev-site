// for loading .coffee files
require('coffee-script').register();
const yaml = require('js-yaml');
const fs = require('fs');
const path = require('path');

function loadYaml(filename) {
  try {
    return yaml.safeLoad(fs.readFileSync(path.resolve(__dirname, filename), 'utf8'));
  } catch (error) {
    throw (new Error("while parsing " + path.resolve(__dirname, filename) + '\n' + error.message));
  };
}

exports.sections = [
  require('./intro.coffee'),
  require('./terms.coffee'),
  loadYaml('./requirements.yml'),
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');


