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
    ,
      id: "admin-system"
      title: "Admin and system calls"
      description: """
                  Some of the calls below are limited to accredited persons and are flagged as `Admin only` or `System only`.
                  
                  These specific calls must carry an admin key, respectively a system key, in the HTTP `Authorization` header.
                  Such keys are defined within the registry configuration (auth:authorizedKeys).
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
        trustedOnly: "Admin only"
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
                        Array of users.
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
        title: "Get core servers"
        http: "GET /admin/servers"
        trustedOnly: "Admin only"
        server: "register"
        description: """
                    Get the list of all core servers with the number of users on them.
                    """
        params:
          properties: []
        result:
          http: "200 OK"
          properties: [
            key: "servers"
            type: "object"
            description: """
                        Object mapping each available core server to a users count.
                        """
          ]
        examples: [
          title: "Fetching the core servers list for a Pryv.io platform"
          params: {}
          result:
            servers: examples.register.usersCount
        ]
      ,
        id: "server.users.get"
        type: "method"
        title: "Get users on core server"
        http: "GET /admin/servers/{serverName}/users"
        trustedOnly: "Admin only"
        server: "register"
        description: """
                    Get the list of all users registered on a specific core server.
                    """
        params:
          properties: [
            key: "serverName"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The name of the core server in question.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "users"
            type: "array"
            description: """
                        Array of users.
                        """
          ]
        examples: [
          title: "Fetching the users list for a specifc core server."
          params: {
            serverName: examples.users.three.server
          }
          result:
            users: [
                examples.users.three,
            ],
        ]
      ,
        id: "server.rename"
        type: "method"
        title: "Rename core server"
        http: "GET /admin/servers/{srcServerName}/rename/{dstServerName}"
        trustedOnly: "Admin only"
        server: "register"
        description: """
                    Rename a core server.
                    """
        params:
          properties: [
            key: "srcServerName"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The current name of the core server to rename.
                        """
          ,
            key: "dstServerName"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The new name of the core server.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "count"
            type: "number"
            description: """
                        The count of renamed occurrences.
                        It can be 0 if `srcServerName` did not match any existing core server.
                        """
          ]
        errors: [
          key: "INVALID_DATA"
          http: "400"
          description: """
                      The server name (source or destination) is invalid because of an unrecognized format.
                      """
        ]
        examples: [
          title: "Renaming a core server."
          params: {
            srcServerName: examples.register.servers[0]
            dstServerName: examples.register.servers[1]
          }
          result:
            count: 1
        ]
      ]
    ,
      id: "service"
      title: "Service"
      description: """
                  Methods for collecting service information.
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
          key: "INVALID_USERNAME"
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
            reserved: false
        ,
          title: "Special case where the username is part of the reserved list."
          params: {
            username: examples.users.reserved.username
          }
          result:
            reserved: true
            reason: "RESERVED_USER_NAME"
        ]
      ,
        id: "server.uid"
        type: "method"
        title: "Get core server"
        http: "POST /{uid}/server"
        server: "register"
        description: """
                    Find the core server hosting a given user.
                    """
        params:
          properties: [
            key: "uid"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The username of the user to look for.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "server"
            type: "string"
            description: """
                        The core server hosting the given user.
                        """
          ,
            key: "alias"
            type: "string"
            description: """
                        The API endpoint for the given user, in the form `username.domain`.
                        """
          ]
        errors: [
          key: "UNKNOWN_USER_NAME"
          http: "404"
          description: """
                      The given username is unknown (unregistered).
                      """
        ]
        examples: [
          title: "Find the core server hosting a given user."
          params: {
            uid: examples.users.two.username
          }
          result: 
            server: examples.register.servers[0]
            alias: examples.users.two.username + "." + examples.register.platforms[0]
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
          result:
            exists: false
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
        ]
      ]
    ]
  ]
