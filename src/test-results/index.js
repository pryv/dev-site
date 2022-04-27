// for loading .coffee files
require('coffeescript').register();

function loadTests () {
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
    });
  });
  return result;
}

exports.sections = [
  require('./intro.coffee'),
  loadTests()
];

exports.version = '0.0.1';
exports.helpers = require('./helpers.coffee');
