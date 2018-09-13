var helpers = module.exports = {};
const _ = require("lodash");

helpers.printJSON = function (content) {
  return JSON.stringify(content, null, 2);
};

helpers.getRawCall = function (params, http) {
  let [method, path] = http.split(" ");
  let myParams = _.clone(params);

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


