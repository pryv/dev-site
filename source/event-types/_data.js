module.exports = {
  "flat": {
    "layout": "../_layouts/event-types-flat",
    "sourceData": require("./hierarchical.json")
  },
  "flat-staging": {
    "layout": "../_layouts/event-types-flat",
    "sourceData": require("./hierarchical-staging.json")
  }
};
