// for loading .coffee files
require('coffee-script').register();
const fs = require('fs');
const path = require('path');



function loadTests() {
  const tests = require('../../dependencies/test-results');
  const result = {
    id: 'services',
    title: 'Services',
    sections: []
  };
  Object.keys(tests).forEach(service => {

    tests[service].forEach(version => { 
      result.sections.push({
        id: service + ' ' + version.version,
        title: service + ' ' + version.version,
        version: version
      });
    })

  });
  console.log(result)
  return result;
}

exports.sections = [
  require('./intro.coffee'),
  loadTests()
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');


