module.exports = {
  "about": {
    "title": "About",
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
    "withTOC": true
  },
  "reference": {
    "title": "Reference",
    "layout": "_layouts/default",
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
