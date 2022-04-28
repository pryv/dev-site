const helpers = module.exports = {};
const _ = require('lodash');

helpers.printJSON = function (content) {
  return JSON.stringify(content, null, 2);
};

helpers.getRestCall = function (params, http) {
  const method = http.split(' ')[0];
  const myParams = _.clone(params);
  // we can remove {id} & {username} as it is exposed in the rest PATH
  delete myParams.id;
  delete myParams.username;

  if (myParams.update != null && method === 'PUT') {
    const updateParams = myParams.update;
    delete myParams.update;
    _.merge(myParams, updateParams);
  }

  return JSON.stringify(myParams, null, 2);
};

helpers.getWebsocketCall = function (params) {
  return JSON.stringify(params);
};

helpers.getBatchBlock = function (methodId, params) {
  return JSON.stringify({ method: methodId, params: params }, null, 2);
};

helpers.httpOnly = function () {
  return 'Only available for HTTP REST';
};
