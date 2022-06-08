// for loading .coffee files
require('coffeescript').register();

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

exports.sections = [
  require('./intro.coffee'),
  require('./terms.coffee'),
  loadYaml('./requirements.yml')
];

function loadYaml (filename) {
  try {
    return yaml.load(fs.readFileSync(path.resolve(__dirname, filename), 'utf8'));
  } catch (error) {
    throw (new Error(`while parsing ${path.resolve(__dirname, filename)}\n${error.message}`));
  }
}
