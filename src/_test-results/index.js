module.exports = {
  sections: loadTestResults()
};

function loadTestResults () {
  const testResults = require('../../dependencies/test-results/source');
  const sections = [];
  Object.keys(testResults).forEach(service => {
    testResults[service].forEach(version => {
      sections.push({
        id: service + ' ' + version.version,
        title: service + ' ' + version.version,
        version: version
      });
    });
  });
  return sections;
}
