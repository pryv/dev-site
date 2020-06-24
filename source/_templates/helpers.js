var helpers = module.exports = {};
const _ = require("lodash");

helpers.printJSON = function (content) {
  return JSON.stringify(content, null, 2);
};

helpers.getRestCall = function (params, http) {
  let [method, path] = http.split(" ");
  let myParams = _.clone(params);
  // we can remove {id} as it is exposed in the rest PATH
  delete myParams.id;

  if (myParams.update != null && method === 'PUT') {
    let updateParams = myParams.update; 
    delete myParams.update; 
    _.merge(myParams, updateParams);
  }

  return JSON.stringify(myParams, null, 2);
}

helpers.getWebsocketCall = function(params) { 
  return JSON.stringify(params);
}

helpers.getBatchBlock = function (methodId, params) {
  return JSON.stringify({method: methodId, params: params}, null, 2);
}

helpers.httpOnly = function() {
  return "Only available for HTTP REST";
}
