const fs = require('fs');
const path = require('path');
const moment = require('moment');

const testResultsRoot = path.resolve(__dirname, '../../dependencies/test-results');

module.exports = {
  sections: getTestResults()
};

function getTestResults () {
  const testResults = loadTestResults();
  const sections = [];
  for (const [serviceName, serviceVersions] of Object.entries(testResults)) {
    for (const serviceVersion of serviceVersions) {
      sections.push({
        id: serviceName + ' ' + serviceVersion.version,
        title: serviceName + ' ' + serviceVersion.version,
        version: serviceVersion
      });
    }
  }
  return sections;
}

function loadTestResults () {
  const services = {};

  fs.readdirSync(testResultsRoot, { withFileTypes: true }).forEach(function (item) {
    const itemName = item.name;
    const itemPath = path.resolve(testResultsRoot, itemName);
    const stats = fs.statSync(itemPath);
    if (!stats.isDirectory()) {
      return;
    }
    const latestVersionPath = path.join(itemPath, 'latest');
    if (!fs.existsSync(latestVersionPath)) {
      // assume the dir does not contain test results
      return;
    }

    const version = fs.readlinkSync(latestVersionPath);
    const serviceFileName = fs.readlinkSync(path.join(itemPath, version, 'latest'));
    const date = moment(serviceFileName.substring(0, 15), 'YYYYMMDD-HHmmss').toDate();
    const serviceResultsPath = path.join(itemPath, version, serviceFileName);

    const serviceResults = JSON.parse(fs.readFileSync(serviceResultsPath));

    const service = {
      version,
      date,
      stats: {
        tests: 0,
        passes: 0,
        pending: 0,
        failures: 0
      },
      components: []
    };

    const existingIds = {};
    const duplicates = {};

    for (const component of serviceResults) {
      // update total stats
      Object.keys(service.stats).forEach(key => {
        if (component.stats[key]) {
          service.stats[key] += component.stats[key];
        }
      });

      component.sets = {};
      for (const test of component.tests) {
        const testData = parseTestName(test.title);
        if (!testData) {
          // TODO: consider re-enabling this once tests are cleaned up and stable
          // throw new Error(`Missing id for test '${test.title}' in ${test.file}\n`);
          console.log(`Missing id for test '${test.title}' in ${test.file}`, test);
          continue;
        }

        testData.duration = test.duration;
        testData.err = test.err;

        if (!existingIds[testData.id]) {
          existingIds[testData.id] = test.title;
        } else {
          if (!duplicates[testData.id]) {
            duplicates[testData.id] = [existingIds[testData.id]];
          }
          duplicates[testData.id].push(test.title);
        }

        const setTitle = test.fullTitle.slice(0, -1 * test.title.length);
        if (!component.sets[setTitle]) {
          component.sets[setTitle] = { tests: [] };
        }
        component.sets[setTitle].tests.push(testData);
      }
      delete component.tests;

      service.components.push(component);
    }

    if (Object.keys(duplicates).length > 0) {
      let errorMsg = 'Duplicate test ids found:\n';
      for (const [testId, refs] of Object.entries(duplicates)) {
        errorMsg += `· ${testId} in:\n`;
        for (const ref of refs) {
          errorMsg += `  · ${ref}\n`;
        }
      }
      throw new Error(errorMsg);
    }

    services[itemName] = [service];
  });

  return services;
}

/**
 * @param {string} testName
 * @returns {Object} With properties `id` and `title`
 */
function parseTestName (testName) {
  const res = /\[([A-Z0-9]{4,})\]+(.*)/.exec(testName);
  if (!res) {
    return null;
  }
  return {
    id: res[1],
    title: res[2]
  };
}
