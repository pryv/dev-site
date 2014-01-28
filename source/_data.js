var serverDoc = require("../../api-server/doc");

module.exports = exports = {
  "about": {
    "title": "About",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": false
  },
  "apps-and-services": {
    "title": "Apps and services",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": false
  },
  "app-access": {
    "title": "Another Example Title",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": true
  },
  "code-libraries": {
    "title": "Code libraries",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": false
  },
  "concepts": {
    "title": "Concepts",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": true
  },
  "dev-index": {
    "title": "Home",
    "layout": "_layouts/default",
    "withExamples": false,
    "withTOC": false,
    "landingPage": true
  },
  // TODO: rename to "event-types" when this issue fixed: https://github.com/sintaxi/harp/issues/106
  "event-typez": {
    "title": "Event types",
    "layout": "_layouts/default",
    "sourcePath": "event-types/hierarchical.json",
    "flatPath": "event-types/flat.json",
    "sourceData": require("./event-types/hierarchical.json"),
    "withExamples": false,
    "withTOC": true,
    "tocSelectors": "h1,h2,h3"
  },
  "reference": {
    "title": "Reference",
    "layout": "_layouts/default",
    "withExamples": true,
    "withTOC": true
  },
  "reference-new": {
    "title": "Reference",
    "layout": "_layouts/default",
    "markdown": require('marked'),
    "withExamples": true,
    "withTOC": true
  },
  "standard-structure": {
    "title": "Standard data structure",
    "layout": "_layouts/default",
    // TODO: rename subfolder to "standard-structure" when abovementioned issue fixed
    "sourcePath": "standard-struct/channels-folders.json",
    "sourceData": require("./standard-struct/channels-folders.json"),
    "withExamples": false,
    "withTOC": true
  }
};

// add server doc data to all
Object.keys(exports).forEach(function(key) {
  exports[key].serverDoc = serverDoc;
});
