// for loading .coffee files
require('coffee-script').register();
const fs = require('fs');
const path = require('path');

const testSrcPath = 'source/test-results/_source/code/'

function loadTests() {
  const tests = {};
  fs.readdirSync(testSrcPath).forEach(service => {
    console.log(service);
    fs.readdirSync(service).forEach(version => {
      console.log(version);

    });
  });
}

//loadTests();

exports.sections = [
  require('./intro.coffee'),
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');


