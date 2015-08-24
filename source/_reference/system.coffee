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
                   Unlike user account data, which is fully managed by the core server hosting each account, managing the accounts themselves (e.g. creation, relocation, deletion) is handled by both the central registration server (AKA user account directory) and the core servers.

                   - The **registration server** owns the process of creating a new account, and takes part in the processes of migrating and deleting accounts.
                   - The **core servers** obviously take part in account creation, and own account migration and deletion.
                   """
    ]

  ,

    id: "account-creation"
    title: "Creating an account"
    description: """

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
            key: "appId"
            type: "string"
            description: """
                       Your app's unique identifier.
                       """
          ,
            key: "hosting"
            type: "string"
            description: """
                       The core server that should host the account.
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
            key: "TODO"
            type: "TODO"
            description: "TODO"
          ]
        result:
          http: "200 OK"
          properties: [
            key: "todo"
            type: "string"
            description: """
                       TODO
                       """
          ]
        examples: [
          title: "TODO"
          content: "TODO"
        ]

      ,

        id: "TODO"
        type: "method"
        title: "TODO"
        http: "POST /TODO"
        description: """

                   """
        result:
          http: "200 OK"
        examples: []
      ]
    ]
  ]
