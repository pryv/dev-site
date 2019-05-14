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
    id: "basics"
    title: "Basics"
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
    ,
      id: "account-creation"
      title: "Account creation"
      description: """
                  The steps for creating a new Pryv.io account are the following:

                   1. Client calls the registry server to get a list of available hostings (core server locations), see [Get hostings](#get-hostings).
                   2. Client calls registry server with desired new account data (including which core server should host the account), see [Create user](#create-user).
                   3. Registry server verifies data, hands it over to specified core server if OK
                   4. Core server verifies data, creates account if OK (sending welcome email to user), returns status (including created account id) to registry server
                   5. Registry server updates directory if OK, returns status to client
                   """
    ]
  ,
    id: "api-methods"
    title: "API methods"
    description: """
              The methods are called via HTTPS on the registry server: `https://reg.{domain}`
              """
    sections: [
      id: "access"
      title: "Access"
      description: """
                  Methods for managing app accesses.
                  """
      sections: [
      ]
    ,
      id: "admin"
      title: "Admin"
      description: """
                  Methods for admin management of the platform.
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
      ]
    ,
      id: "email"
      title: "Email"
      description: """
                  Methods for managing emails.
                  """
      sections: [
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
          result:
            exists: false
        ,
          title: "Error case where the email address is invalid."
          params: {
            email: examples.users.invalid.email
          }
          result:
            examples.errors.invalidEmail
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
                        The username linked to the given email.
                        """
          ]
        errors: [
          key: "UNKNOWN_EMAIL"
          http: "404"
          description: """
                      The given email address is unknown (unregistered).
                      """
        ]
        examples: [
          title: "Retrieving a username from a given email."
          params: {
            email: examples.users.two.email
          }
          result: 
            "uid": examples.users.two.username
        ,
          title: "Error case where the email address is unknown."
          params: {
            email: examples.users.one.email
          }
          result: 
            examples.errors.unknownEmail
        ]
      ]
    ,
      id: "server"
      title: "Server"
      description: """
                  Methods for managing servers.
                  """
      sections: [
      ]
    ,
      id: "service"
      title: "Service"
      description: """
                  Methods for managing external services.
                  """
      sections: [
        id: "service.infos.get"
        type: "method"
        title: "Get service infos"
        http: "GET /service/infos"
        server: "register"
        description: """
                    Retrieve service information.
                    """
        params:
          properties: []
        result:
          http: "200 OK"
          properties: [
            key: "version"
            type: "string"
            description: """
                        The API version.
                        """
          ,
            key: "register"
            type: "string"
            description: """
                        The URL of the registry service.
                        """
          ,
            key: "access"
            type: "string"
            description: """
                        The URL of the access page.
                        """
          ,
            key: "api"
            type: "string"
            description: """
                        The base URL of the API.
                        """
          ,
            key: "name"
            type: "string"
            description: """
                        The platform name.
                        """
          ,
            key: "home"
            type: "string"
            description: """
                        The URL of the platform's home page.
                        """
          ,
            key: "support"
            type: "string"
            description: """
                        The URL of the suppport page.
                        """
          ,
            key: "terms"
            type: "string"
            description: """
                        The URL of the terms and conditions page.
                        """
          ]
        examples: [
          title: "Retrieving service information."
          params: {}
          result: 
            examples.register.serviceInfos
        ]
      ,
        id: "apps.get"
        type: "method"
        title: "Get apps"
        http: "GET /apps"
        server: "register"
        description: """
                    Retrieve the list of applications connected to the platform.
                    """
        params:
          properties: []
        result:
          http: "200 OK"
          properties: [
            key: "apps"
            type: "array"
            description: """
                        An array listing all the applications connected to the Pryv.io platform.
                        """
          ]
        examples: [
          title: "Retrieving the list of applications connected to the platform."
          params: {}
          result: 
            "apps": examples.register.apps
        ]
      ,
        id: "app.get"
        type: "method"
        title: "Get app"
        http: "GET /apps/{appid}"
        server: "register"
        description: """
                    Retrieve specific information about a given application.
                    """
        params:
          properties: [
            key: "appid"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The id of the application to look for.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "app"
            type: "object"
            description: """
                        An object listing information about the given application.
                        """
          ]
        examples: [
          title: "Retrieving information about a given application."
          params: {}
          result: 
            "app": examples.register.apps[0]
        ]
      ,
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
      ]
    ,
      id: "users"
      title: "Users"
      description: """
                  Methods for managing users.
                  """
      sections: [
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
      ,
        id: "username.check.get"
        type: "method"
        title: "Check username"
        http: "GET /{username}/check_username"
        server: "register"
        description: """
                    Check the availability and validity of a given username.
                    """
        params:
          properties: [
            key: "username"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The username to check.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "reserved"
            type: "boolean"
            description: """
                        Set to `true` if the given username is already taken, `false` otherwise.
                        """
          ,
            key: "reason"
            type: "string"
            optional: true
            description: """
                        Optional indication of the reason why the username is reserved.
                        If it mentions `RESERVED_USER_NAME`, this means that the given username is part of
                        the reserved usernames list configured within the registry service.
                        """
          ]
        errors: [
          key: "INVALID_USER_NAME"
          http: "400"
          description: """
                      The given username is invalid because of an unrecognized format.
                      """
        ]
        examples: [
          title: "Checking availability and validity of a given username"
          params: {
            username: examples.users.two.username
          }
          result:
            "reserved": false
        ,
          title: "Special case where the username is part of the reserved list."
          params: {
            username: examples.users.reserved.username
          }
          result:
            examples.errors.reservedUsername
        ,
          title: "Error case where the username is invalid."
          params: {
            username: examples.users.invalid.username
          }
          result:
            examples.errors.invalidUsername
        ]
      ]
    ]
  ]
