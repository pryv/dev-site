dataStructure = require('../data-structure.coffee')
examples = require("../examples")
helpers = require("../helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)


module.exports.access =
  id: "accesses"
  title: "Accesses"
  description: """
                 Methods to retrieve and manipulate [accesses](##{dataStructure.getDocId("access")}), e.g. for sharing.
                 Any app can manage shared accesses whose permissions are a subset of its own. (Full access management is available to trusted apps.)
                 """
  sections: [
    id: "accesses.get"
    type: "method"
    title: "Get accesses"
    http: "GET /accesses"
    description: """
                   Gets manageable accesses.
                   """
    result:
      http: "200 OK"
      properties: [
        key: "accesses"
        type: "array of [accesses](##{dataStructure.getDocId("access")})"
        description: """
                       All manageable accesses in the user's account, ordered by name.
                       """
      ]
    examples: [
      params: {}
      result:
        accesses: [examples.accesses.shared]
    ]

  ,

    id: "accesses.create"
    type: "method"
    title: "Create access"
    http: "POST /accesses"
    description: """
                   Creates a new access. You can only create accesses whose permissions are a subset of those granted to your own access token.
                   """
    params:
      description: """
                     An object with the new access's data: see [access](##{dataStructure.getDocId("access")}).
                     """
    result:
      http: "201 Created"
      properties: [
        key: "access"
        type: "[access](##{dataStructure.getDocId("access")})"
        description: """
                       The created access.
                       """
      ]
    errors: [
      key: "invalid-item-id"
      http: "400"
      description: """
                     The specified token is invalid (e.g. it's a reserved word such as `null`).
                     """
    ]
    examples: [
      params: _.pick(examples.accesses.sharedNew, "name", "permissions")
      result:
        access: examples.accesses.sharedNew
    ]

  ,

    id: "accesses.update"
    type: "method"
    title: "Update access"
    http: "PUT /accesses/{id}"
    description: """
                   Modifies the specified access. You can only modify accesses whose permissions are a subset of those granted to your own access token.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the access.
                       """
      ,
        key: "update"
        type: "object"
        http:
          text: "= request body"
        description: """
                       New values for the access's fields: see [access](##{dataStructure.getDocId("access")}). All fields are optional, and only modified values must be included.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "access"
        type: "[access](##{dataStructure.getDocId("access")})"
        description: """
                       The updated access.
                       """
      ]
    examples: [
      title: "Adjusting permission level"
      params:
        id: examples.accesses.sharedNew.id
        update:
          permissions: [_.defaults({level: "contribute"}, examples.accesses.sharedNew.permissions[0])]
      result:
        access: _.defaults({
          permissions: [_.defaults({level: "contribute"}, examples.accesses.sharedNew.permissions[0])],
          modified: timestamp.now(),
          modifiedBy: examples.accesses.app.id
        }, examples.accesses.sharedNew)
    ]

  ,

    id: "accesses.delete"
    type: "method"
    title: "Delete access"
    http: "DELETE /accesses/{id}"
    description: """
                   Deletes the specified access. You can only delete accesses whose permissions are a subset of those granted to your own access token.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the access.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "accessDeletion"
        type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
        description: """
                       The deletion record.
                       """
      ]
    examples: [
      params:
        id: examples.accesses.shared.id
      result: {}
    ]

  ,

    id: "accesses.checkApp"
    type: "method"
    trustedOnly: true
    title: "Check app authorization"
    http: "POST /accesses/check-app"
    description: """
                   For the app authorization process. Checks if the app requesting authorization already has access with the same permissions (and on the same device, if applicable), and returns details of the requested permissions' streams (for display) if not.
                   """
    params:
      properties: [
        key: "requestingAppId"
        type: "string"
        description: """
                       The id of the app requesting authorization.
                       """
      ,
        key: "deviceName"
        type: "string"
        optional: true
        description: """
                       The name of the device running the app requesting authorization, if applicable.
                       """
      ,
        key: "requestedPermissions"
        type: "array of permission request objects"
        description: """
                       An array of permission request objects, which are identical to stream permission objects of [accesses](##{dataStructure.getDocId("access")}) except that each stream permission object must have a `defaultName` property specifying the name the stream should be created with later if missing.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "checkedPermissions"
        type: "array of permission request objects"
        description: """
                       Set if no matching access already exists.
                       A updated copy of the `requestedPermissions` parameter, with the `defaultName` property of stream permissions replaced by `name` for each existing stream (set to the actual name of the item). (For missing streams the `defaultName` property is left untouched.) If streams already exist with the same name but a different `id`, `defaultName` is updated with a valid alternative proposal (in such cases the result also has an `error` property to signal the issue).
                       """
      ,
        key: "mismatchingAccess"
        type: "[access](##{dataStructure.getDocId("access")})"
        description: """
                       Set if an access already exists for the requesting app, but with different permissions than those requested.
                       """
      ,
        key: "matchingAccess"
        type: "[access](##{dataStructure.getDocId("access")})"
        description: """
                       Set if an access already exists for the requesting app with matching permissions. The existing [access](##{dataStructure.getDocId("access")}).
                       """
      ]
    examples: []
  ]