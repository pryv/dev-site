// for loading .coffee files
require('coffee-script').register();
const fs = require('fs');
const path = require('path');

function loadTests(filename) {
 
}

exports.sections = [
  require('./intro.coffee'),
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');


