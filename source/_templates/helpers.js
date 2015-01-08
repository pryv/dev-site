var helpers = module.exports = {};

helpers.printJSON = function (content) {
  return JSON.stringify(content, null, 2);
};
