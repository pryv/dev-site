common = require('pryv-api-server-common')
errors = common.errors.factory
errorHandling = common.errors.errorHandling

module.exports =
  invalidAccessToken: errorHandling.getPublicErrorData(errors.invalidAccessToken("Cannot find access with token 'bad-token'."))
