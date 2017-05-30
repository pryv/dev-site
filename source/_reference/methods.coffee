dataStructure = require('./data-structure.coffee')
examples = require("./examples")
helpers = require("./helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

events = require("./methods/events")
streams = require("./methods/streams")
accesses = require("./methods/accesses")
followedSlices = require("./methods/followed-slices")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)

module.exports = exports =
  id: "methods"
  title: "API methods"
  sections: [
    id: "auth"
    title: "Authentication"
    trustedOnly: true
    description: """
                 Methods for trusted apps to login/logout users.
                 """
    sections: [
      id: "auth.login"
      type: "method"
      title: "Login user"
      http: "POST /auth/login"
      description: """
                   Authenticates the user against the provided credentials, opening a personal access session. This is one of the only API methods that do not expect an [auth parameter](#basics-authentication).
                   """
      params:
        properties: [
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
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "token"
          type: "string"
          description: """
                       The personal access token to use for further API calls.
                       """
        ,
          key: "preferredLanguage"
          type: "string"
          description: """
                       The user's preferred language as a 2-letter ISO language code.
                       """
        ]
      examples: [
        params:
          username: examples.users.one.username
          password: examples.users.one.password
          appId: "my-app-id"
        result:
          token: examples.accesses.personal.token
          preferredLanguage: examples.users.one.language
      ]

    ,

      id: "auth.logout"
      type: "method"
      title: "Logout user"
      http: "POST /auth/logout"
      description: """
                   Terminates a personal access session by invalidating its access token (the user will have to login again).
                   """
      result:
        http: "200 OK"
      examples: []
    ]

  ,

    events.event

  ,

    streams.stream

  ,

    accesses.access

  ,

    followedSlices.followedSlice

  ,

    id: "profile"
    title: "Profile sets"
    description: """
                 Methods to read and write profile sets. Profile sets are plain key-value stores of user-level settings.
                 """
    sections: [
      id: "profile.getPublic"
      type: "method"
      title: "Get public user profile"
      http: "GET /profile/public"
      description: """
                   Gets the user's public profile set, which contains the information the user makes publicly available (e.g. avatar image). Available to all accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The user's current public profile set.
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.public
      ]

    ,

      id: "profile.getApp"
      type: "method"
      title: "Get app profile"
      http: "GET /profile/app"
      description: """
                   Gets the app's dedicated user profile set, which contains app-level settings for the user. Available to app accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The app's current profile set. (Empty if the app never defined any setting.)
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.app
      ]

    ,

      id: "profile.updateApp"
      type: "method"
      title: "Update app profile"
      http: "PUT /profile/app"
      description: """
                   Adds, updates or delete app profile keys.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The app's updated profile set.
                       """
        ]
      examples: [
        params:
          setting1: "new value",
          setting2: null
        result:
          profile: _.defaults({setting1: "new value"}, _.omit(examples.profileSets.app, "setting2"))
      ]

    ,

      id: "profile.get"
      type: "method"
      trustedOnly: true
      title: "Get profile"
      http: "GET /profile/{id}"
      description: """
                   Gets the specified user profile set.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the profile set.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The profile set.
                       """
        ]
      examples: []

    ,

      id: "profile.update"
      type: "method"
      trustedOnly: true
      title: "Update profile"
      http: "PUT /profile/{id}"
      description: """
                   Adds, updates or delete profile keys.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the profile set.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The updated profile set.
                       """
        ]
      examples: []
    ]

  ,

    id: "account"
    title: "Account management"
    trustedOnly: true
    description: """
                 Methods to manage the user's account.
                 """
    sections: [
      id: "account.get"
      type: "method"
      title: "Get account information"
      http: "GET /account"
      description: """
                   Retrieves the user's account information.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The user's account information.
                       """
        ]
      examples: [
        params: {}
        result:
          account: _.omit(examples.users.one, "id", "password")
      ]

    ,

      id: "account.update"
      type: "method"
      title: "Update account information"
      http: "PUT /account"
      description: """
                   Modifies the user's account information.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       New values for the account information's fields: see [account information](##{dataStructure.getDocId("account")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The updated account information.
                       """
        ]
      examples: []

    ,

      id: "account.changePassword"
      type: "method"
      title: "Change password"
      http: "POST /account/change-password"
      description: """
                   Modifies the user's password.
                   """
      params:
        properties: [
          key: "oldPassword"
          type: "string"
          description: """
                       The current password.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ]
      result:
        http: "200 OK"
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The given password does not match.
                     """
      ]
      examples: [
        params:
          oldPassword: examples.users.one.password
          newPassword: "//\\_.:o0o:._//\\"
        result: {}
      ]

    ,

      id: "account.requestPasswordReset"
      type: "method"
      title: "Request password reset"
      http: "POST /account/request-password-reset"
      description: """
                   Requests the resetting of the user's password. An e-mail containing an expiring reset token (e.g. in a link) will be sent to the user. This method does not expect an [auth parameter](#basics-authentication).
                   """
      params:
        properties: [
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          appId: "my-app-id"
        result: {}
      ]

    ,

      id: "account.resetPassword"
      type: "method"
      title: "Reset password"
      http: "POST /account/reset-password"
      description: """
                   Resets the user's password, authenticating the request with the given reset token (see "request password reset" above). This method does not expect an [auth parameter](#basics-authentication).
                   """
      params:
        properties: [
          key: "resetToken"
          type: "string"
          description: """
                       The expiring reset token that was sent to the user after requesting the password reset.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ,
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          resetToken: "chtplghfp0000hqjx814u6393"
          newPassword: "Dr0ws$4p"
          appId: "my-app-id"
        result: {}
      ]
    ]

  ,

    id: "utils"
    title: "Utils"
    description: """
                 Utility methods that don't pertain to a particular resource type.
                 """
    sections: [
      id: "getAccessInfo"
      type: "method"
      title: "Get current access info"
      http: "GET /access-info"
      description: """
                   Retrieves the name, type and permissions of the access in use.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "name"
          type: "string"
          description: """
                       The access' name.
                       """
        ,
          key: "type"
          type: "[access](##{dataStructure.getDocId("access")}).type"
          description: """
                       The access' type.
                       """
        ,
          key: "permissions"
          type: "[access](##{dataStructure.getDocId("access")}).permissions"
          description: """
                       The access' permissions.
                       """
        ]
      examples: [
        params: {}
        result: _.pick(examples.accesses.app, "name", "type", "permissions")
      ]

    ,

      id: "callBatch"
      type: "method"
      title: "Call batch"
      http: "POST /"
      description: """
                   Sends a batch of API methods calls in one go (e.g. for to syncing offline changes when resuming connectivity).
                   """
      params:
        description: """
                     Array of method call objects, each defined as follows:
                     """
        properties: [
          key: "method"
          type: "string"
          description: """
                       The method id.
                       """
        ,
          key: "params"
          type: "object or array"
          description: """
                       The call parameters as required by the method.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "results"
          type: "array of call results"
          description: "The results of each method call, in order."
        ]
      examples: [
        title: "Sync some health metrics"
        params: [
          method: "events.create"
          params: _.pick(examples.events.heartRate, "time", "streamId", "type", "content")
        ,
          method: "events.create"
          params: _.pick(examples.events.heartSystolic, "time", "streamId", "type", "content")
        ,
          method: "events.create"
          params: _.pick(examples.events.heartDiastolic, "time", "streamId", "type", "content")
        ]
        result:
          results: [
            event:
              examples.events.heartRate
          ,
            event:
              examples.events.heartSystolic
          ,
            event:
              examples.events.heartDiastolic
          ]
      ]
    ]

  ]

# Returns the in-doc id of the given method, for safe linking from other doc sections
exports.getDocId = (methodId) ->
  result = null
  exports.sections.forEach((section) ->
    methodSection = _.find(section.sections, (subSection) -> subSection.id == methodId)
    if methodSection
      result = helpers.getDocId(exports.id, section.id, methodId)
  )
  return result || throw new Error("Unknown method id")
