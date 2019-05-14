coreErrors = require('../../../dependencies/core/components/errors')
errors = coreErrors.factory
errorHandling = coreErrors.errorHandling

module.exports =
  invalidAccessToken: errorHandling.getPublicErrorData(errors.invalidAccessToken("Cannot find access with token 'bad-token'."))
  invalidEmail:
    id: "INVALID_EMAIL"
    message: "Invalid email address"
    detail: "E-mail address format not recognized"
    errors: []
  unknownEmail:
    id: "UNKNOWN_EMAIL",
    message: "Unknown e-mail",
    detail: "",
    errors: []
  invalidUsername: 
    id: "INVALID_USER_NAME"
    message: "Invalid user name"
    detail: "User name must be made of 5 to 23 alphanumeric characters (- authorized)."
    errors: []
  reservedUsername:
    reserved: true
    reason: "RESERVED_USER_NAME"
