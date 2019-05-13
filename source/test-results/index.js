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

    result.sections.push({
      id: service,
      title: service,
      versions: tests[service]
    });

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


