examples = require("./examples")
helpers = require("./helpers")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("system", sectionId)

module.exports = exports =
  id: "system"
  title: "System-level API"
  sections: [
    id: "overview"
    title: "Overview"
    description: """
                 This document describes Pryv's "system-level" API, allowing developers to control the creation of user accounts.
                 """
    sections: [
      id: "services-involved"
      title: "Services involved"
      description: """
                   Unlike user account data, which is fully managed by the core server hosting each account, managing the accounts themselves (e.g. creation, relocation, deletion) is handled by the core servers _and_ the central registration server (AKA user account directory).

                   - The **core servers** own the account management processes, i.e. account creation, migration and deletion
                   - The **registration server** maintains the list of account names and their hosting locations; it helps account management by providing checks (for creation) and is notified of all relevant changes by the core servers.
                   """
    ]

  ,

    id: "account-creation"
    title: "Creating an account"
    description: """
                 **Attention, this process will change**: the creation call will no longer happen on the registration server but on the core server, and the registration server will only provide checks and get notified of changes.
                 """
    sections: [
      id: "process-steps"
      title: "Process steps"
      description: """
                   1. Client calls registration server with desired new account data (including which core server should host the account)
                   2. Registration server verifies data, hands it over to specified core server if OK
                   3. Core server verifies data, creates account if OK (sending welcome email to user), returns status (including created account id) to registration server
                   4. Registration server updates directory if OK, returns status to client
                   """
    ,
      id: "api-methods"
      title: "API methods"
      description: """
                   The methods are called via HTTPS on the registration server.
                   """
      sections: [
        id: "users.create"
        type: "method"
        title: "Create user"
        http: "POST /users"
        description: """
                   Creates a new user account on the specified core server.
                   """
        params:
          properties: [
            key: "appid"
            type: "string"
            description: """
                       Your app's unique identifier.
                       """
          ,
            key: "hosting"
            type: "string"
            description: """
                       The name of the core server that should host the account.
                       """
          ,
            key: "username"
            type: "string"
            description: """
                       The user's username.
                       """
          ,
            key: "password"
            type: "string"
            description: """
                       The user's password.
                       """
          ,
            key: "email"
            type: "string"
            description: """
                         The user's e-mail.
                         """
          ,
            key: "languageCode"
            type: "string"
            optional: true
            description: """
                         The user's preferred language as a 2-letter ISO language code.
                         """
          ,
            key: "invitationtoken"
            type: "string"
            description: "An invitation token; used when limiting registration to a specific set of users."
          ,
            key: "referer"
            type: "string"
            optional: true
            description: "A referer id potentially used for analytics."
          ]
        result:
          http: "200 OK"
          properties: [
            key: "username"
            type: "string"
            description: """
                         A confirmation of the user's username.
                         """
          ,
            key: "server"
            type: "string"
            description: """
                         The hostname of the core server hosting the new account.
                         """
          ]
        examples: []
      ]
    ]
  ]
