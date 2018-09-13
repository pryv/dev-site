coreErrors = require('../../../dependencies/core/components/errors')
errors = coreErrors.factory
errorHandling = coreErrors.errorHandling

module.exports =
  invalidAccessToken: errorHandling.getPublicErrorData(errors.invalidAccessToken("Cannot find access with token 'bad-token'."))
