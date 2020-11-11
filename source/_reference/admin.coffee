examples = require("./examples")
helpers = require("./helpers")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, subsectionId, methodId) ->
  return helpers.getDocId("admin", sectionId, subsectionId, methodId)

module.exports = exports =
  id: "admin"
  title: "Admin API"
  sections: [
    id: "basics"
    title: "Basics"
    description: """
                 This document describes Pryv.io's **administration** API, allowing to configure the platform parameters and manage platform users.  
                 This service is only available with an [**Entreprise license**](https://api.pryv.com/concepts/#entreprise-license-open-source-license).
                 """
    sections: [
      id: "admin-service"
      title: "Administration service"
      description: """
                   The administration service has its own API and authentication mechanism.
                   """
    ,
      id: "authorization"
      title: "Authorization"
      description: """
                   All requests for retrieving and manipulating admin data must carry a valid JSON web token that is obtained at login. 
                   
                   It must be assigned to the `authorization` header. 
                   """
    ]
  ,
    id: "api-methods"
    title: "API methods"
    description: """
              The methods are called via HTTPS on the administration server: `https://lead.{domain}`.
              """
    sections: [
      id: "auth"
      title: "Authentication"
      description: """
                  Methods for authenticating admin users.
                  """
      sections: [
        id: "auth.login"
        type: "method"
        title: "Login user"
        http: "POST /auth/login"
        httpOnly: true
        server: "admin"
        description: """
                    Authenticates the user against the provided credentials.
                    """
        params:
          properties: [
            key: "username"
            type: "string"
            description: """
                        The user's username
                        """
          ,
            key: "password"
            type: "string"
            description: """
                        The user's password
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "token"
            type: "string"
            description: """
                        JSON web token to use for further API calls.
                        """
          ]
        examples: [
          title: "Authenticating admin user"
          params: {
            username: "quaid",
            password: "my-secret-password"
          }
          result:
            token: "eyJ1c2VybmFtZSI6ImlsaWEiLCJwZXJtaXNzaW9ucyI6eyJ1c2VycyI6WyJyZWFkIiwiY3JlYXRlIiwiZGVsZXRlIiwicmVzZXRQYXNzd29yZCIsImNoYW5nZVBlcm1pc3Npb25zIl0sInNldHRpbmdzIjpbInJlYWQiLCJ1cGRhdGUiXX0sImlhdCI6MTU5OTIyNDM4MywiZXhwIjoxNTk5MzEwNzgzfQ"
        ]
      ,
        id: "auth.logout"
        type: "method"
        title: "Logout user"
        http: "POST /auth/logout"
        httpOnly: true
        server: "admin"
        description: """
                     Terminates a session by invalidating its JSON web token (the user will have to login again). Simply provide the JSON web token in own of the [the supported ways](/reference-admin/#authorization), no request body is required.
                    """
        result:
          http: "200 OK"
        examples: [
          params: {}
          result: {}
        ]
      ]
    ,
      id: "platform-settings"
      title: "Platform settings"
      description: """
                  Methods for managing platform settings.
                  """
      sections: [
        id: "settings.update"
        type: "method"
        title: "Update platform settings"
        http: "PUT /admin/settings"
        description: """
                    Updates the platform settings and saves them.
                    """
        params:
          properties: [
            key: "update"
            type: "object"
            http:
              text: "request body"
            description: """
                        JSON config file containing the new values for the platform settings' fields.
                        """
          ] 
        result:
          http: "200 OK"
          properties: [
            key: "platform-settings"
            type: "object"
            description: """
                        The updated platform settings.
                        """
          ],
        errors: [
          key: "invalid-input"
          http: "400"
          description: """
                      The configuration format is invalid.
                      """
        ]
      ,
        id: "settings.notify"
        type: "method"
        title: "Notifies about configuration changes"
        http: "POST /admin/notify"
        description: """
                    Notifies followers about platform settings' changes.
                    """
        params:
          properties: [
            key: "services"
            optional: true 
            type: "object"
            description: """
                        The services.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "successes"
            type: "array of services"
            description: """
                        Services successfully updated.
                        """
            properties: [
              key: "key"
              type: "string"
              description: """
                          replace me
                          """
            ,
              key: "url"
              type: "string"
              description: """
                          replace me
                          """
            ,
              key: "role"
              type: "string"
              description: """
                          The role of the machine (core, static, reg).
                          """
            ]
          ,
            key: "failures"
            type: "array of services"
            description: """
                        Services failed to update.
                        """
            properties: [
              key: "key"
              type: "string"
              description: """
                          replace me
                          """
            ,
              key: "url"
              type: "string"
              description: """
                          replace me
                          """
            ,
              key: "role"
              type: "string"
              description: """
                          The role of the machine (core, static, reg).
                          """
            ,
              key: "error"
              type: "object"
              description: """
                          The error information.
                          """
            ]
          ]
      ]
    
    ,

      id: "platform-users"
      title: "Platform users"
      description: """
                  Methods for managing platform users.
                  """
      sections: [
        id: "users.delete"
        type: "method"
        title: "Delete user"
        http: "DELETE /platform-users/:username"
        httpOnly: true
        description: """
                    Delete user account from the Pryv.io platform. **This deletion is final**.
                    """
        params:
          properties: [
            key: "username"
            type: "string"
            http:
              text: "set in request path"
            description: """
                         The username of the platform user to delete.
                         """
          ]
        result: 
          http: "200 OK"
          properties: [
            key: "username"
            type: "string"
            description: """
                         The username of the deleted platform user.
                         """
          ]
        examples: [
          title: "Deleting a platform user"
          params:
            username: 'dutch'
          result:
            username: 'dutch'
        ]
      ]
    ]
  ]
