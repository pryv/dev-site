examples = require("./examples")
helpers = require("./helpers")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, subsectionId, methodId) ->
  return helpers.getDocId("system", sectionId, subsectionId, methodId)

module.exports = exports =
  id: "system"
  title: "System-level API"
  sections: [
    id: "overview"
    title: "Overview"
    description: """
                 This document describes Pryv.io's **system-level** API, allowing developers to create and manage user accounts.
                 """
    sections: [
      id: "services-involved"
      title: "Services involved"
      description: """
                   Unlike user account data, which is fully managed by the core server hosting each account, managing the accounts themselves (e.g. retrieval, creation, deletion) is handled by the core servers *and* the central registry server (AKA user account directory).

                   - The **core servers** own the account management processes, i.e. data creation and deletion
                   - The **registry server** maintains the list of account usernames and their hosting locations; it helps account management by providing checks (for creation) and is notified of all relevant changes by the core servers.
                   """
    ]

  ,

    id: "account-creation"
    title: "Creating an account"
    sections: [
      id: "process-steps"
      title: "Process steps"
      description: """
                   1. Client calls the registry server to get a list of available hostings (core server locations)
                   2. Client calls registry server with desired new account data (including which core server should host the account)
                   3. Registry server verifies data, hands it over to specified core server if OK
                   4. Core server verifies data, creates account if OK (sending welcome email to user), returns status (including created account id) to registry server
                   5. Registry server updates directory if OK, returns status to client
                   """
    ,
      id: "api-methods"
      title: "API methods"
      description: """
                   The methods are called via HTTPS on the registry server: `https://reg.{domain}`
                   """
      sections: [

        id: "hostings.get"
        type: "method"
        title: "Get hostings"
        http: "GET /hostings"
        server: "register"
        description: """
                    Get the list of all available hostings for data storage locations.
                    """
        params:
          properties: []
        result:
          http: "200 OK"
          properties: [
            key: "regions"
            type: "Object"
            description: """
                        Object containing multiple regions, containing themselves multiple zones, containing themselves multiple **hostings**.  
                        The value you need to use as `hosting` parameter in the `users.create` method is a key of the `hostings` object.
                        """
          ]
        examples: [
          title: "Fetching the hostings for a Pryv.io platform"
          params: {}
          result:
            examples.register.hostings[0]
        ]
      
      ,

        id: "users.create"
        type: "method"
        title: "Create user"
        http: "POST /user"
        server: "register"
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
                       The name of the core server that should host the account, see [Get Hostings](##{_getDocId("account-creation","api-methods","get.hostings")}).
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
                         The user's e-mail address, used for password retrieval.
                         """
          ,
            key: "invitationtoken"
            type: "string"
            description: "An invitation token, used when limiting registration to a specific set of users."
          ,
            key: "languageCode"
            type: "string"
            optional: true
            description: """
                         The user's preferred language as a 2-letter ISO language code.
                         """
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
        examples: [
          title: "Creating a user"
          params: 
            appid: examples.register.appids[0]
            hosting: Object.keys(examples.register.hostings[0].regions.europe.zones.switzerland.hostings)[0]
            username: examples.users.two.username
            password: examples.users.two.password
            email: examples.users.two.email
            invitationtoken: examples.register.invitationTokens[0]
            languageCode: examples.register.languageCodes[0]
            referer: examples.register.referers[0]
          result:
            username: examples.users.two.username
            server: examples.users.two.username + "." + examples.register.platforms[0]
        ]
      ]
    ]

  ,

    id: "account-manage"
    title: "Manage accounts"
    sections: [
      id: "api-methods"
      title: "API methods"
      description: """
                   The methods are called via HTTPS on the registry server: `https://reg.{domain}`
                   """
      sections: [

        id: "users.get"
        type: "method"
        title: "Get users"
        http: "GET /admin/users"
        server: "register"
        description: """
                    Get the list of all users registered on the platform.
                    """
        params:
          properties: [
            key: "toHTML"
            type: "boolean"
            optional: true
            description: """
                        If `true`, format the resulting users list as HTML tables.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "users"
            type: "array"
            description: """
                        Array of users (TODO: link to user data structure).
                        """
          ]
        examples: [
          title: "Fetching the users list for a Pryv.io platform"
          params: {}
          result:
            users: [
                examples.users.three,
                examples.users.four
            ],
            error: null
        ]

      ,

        id: "servers.get"
        type: "method"
        title: "Get servers"
        http: "GET /admin/servers"
        server: "register"
        description: """
                    Get the list of all servers with the number of users on them.
                    """
        params:
          properties: []
        result:
          http: "200 OK"
          properties: [
            key: "servers"
            type: "object"
            description: """
                        Object mapping each available server to a users count.
                        """
          ]
        examples: [
          title: "Fetching the servers list for a Pryv.io platform"
          params: {}
          result:
            servers: [
                core1: 42,
                core2: 1337
            ]
        ]

      ,

        id: "server.users.get"
        type: "method"
        title: "Get users on server"
        http: "GET /admin/servers/{serverName}/users"
        server: "register"
        description: """
                    Get the list of all users registered on a specific server of the platform.
                    """
        params:
          properties: [
            key: "serverName"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The name of the server in question.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "users"
            type: "array"
            description: """
                        Array of users (TODO: link to user data structure).
                        """
          ]
        examples: [
          title: "Fetching the users list for a specifc server of a Pryv.io platform"
          params: {
            serverName: examples.users.three.server
          }
          result:
            users: [
                examples.users.three,
            ],
        ]

      ,

        id: "email.check.post"
        type: "method"
        title: "Check email availability"
        http: "POST /email/check"
        server: "register"
        description: """
                    Check the availability of an account's email.
                    """
        params:
          properties: [
            key: "email"
            type: "string"
            description: """
                        The email address to check.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "true or false"
            type: "plaintext"
            description: """
                        Plaintext `true` if the email address is valid AND free, `false` otherwise.
                        """
          ]
        examples: [
          title: "Checking the availability of an account's email address."
          params: {
            email: examples.users.two.email
          }
          result: true
        ]

      ,

        id: "email.check.get"
        type: "method"
        title: "Check email existence"
        http: "GET /{email}/check_email"
        server: "register"
        description: """
                    Check the existence of an account's email.
                    """
        params:
          properties: [
            key: "email"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The email address to check.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "exists"
            type: "boolean"
            description: """
                        Set to `true` if the email address is already registered, `false` otherwise.
                        """
          ]
        errors: [
          key: "INVALID_EMAIL"
          http: "400"
          description: """
                      The email address is invalid because of an unrecognized format.
                      """
        ]
        examples: [
          title: "Checking the existence of an account's email address."
          params: {
            email: examples.users.two.email
          }
          result: true
        ]

      ,

        id: "email.uid.get"
        type: "method"
        title: "Get username from email"
        http: "GET /{email}/uid"
        server: "register"
        description: """
                    Get the username of a Pryv.io account according to the given email.
                    """
        params:
          properties: [
            key: "email"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The email address to look for.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "uid"
            type: "string"
            description: """
                        The username linked to the provided email.
                        """
          ]
        examples: [
          title: "Retrieving a username from a given email."
          params: {
            email: examples.users.two.email
          }
          result: examples.users.two.username
        ]

      ]
    ]
  ]
