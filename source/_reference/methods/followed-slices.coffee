dataStructure = require('../data-structure.coffee')
examples = require("../examples")
helpers = require("../helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)


module.exports.followedSlice =
  id: "followed-slices"
  title: "Followed slices"
  trustedOnly: true
  description: """
                 Methods to retrieve and manipulate [followed slices](##{dataStructure.getDocId("followed-slice")}).
                 """
  sections: [
    id: "followedSlices.get"
    type: "method"
    title: "Get followed slices"
    http: "GET /followed-slices"
    description: """
                   Gets followed slices.
                   """
    result:
      http: "200 OK"
      properties: [
        key: "followedSlices"
        type: "array of [followed slices](##{dataStructure.getDocId("followed-slice")})"
        description: """
                       All followed slices in the user's account, ordered by name.
                       """
      ]
    examples: []

  ,

    id: "followedSlices.create"
    type: "method"
    title: "Create followed slice"
    http: "POST /followed-slices"
    description: """
                   Creates a new followed slice.
                   """
    params:
      description: """
                     An object with the new followed slice's data: see [followed slice](##{dataStructure.getDocId("followed-slice")}).
                     """
    result:
      http: "201 Created"
      properties: [
        key: "followedSlice"
        type: "[followed slice](##{dataStructure.getDocId("followed-slice")})"
        description: """
                       The created followed slice.
                       """
      ]
    examples: []

  ,

    id: "followedSlices.update"
    type: "method"
    title: "Update followed slice"
    http: "PUT /followed-slices/{id}"
    description: """
                   Modifies the specified followed slice.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the followed slice.
                       """
      ,
        key: "update"
        type: "object"
        http:
          text: "= request body"
        description: """
                       New values for the followed slice's fields: see [followed slice](##{dataStructure.getDocId("followed-slice")}). All fields are optional, and only modified values must be included.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "followedSlice"
        type: "[followed slice](##{dataStructure.getDocId("followed-slice")})"
        description: """
                       The updated followed slice.
                       """
      ]
    examples: []

  ,

    id: "followedSlices.delete"
    type: "method"
    title: "Delete followed slice"
    http: "DELETE /followed-slices/{id}"
    description: """
                   Deletes the specified followed slice.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the followed slice.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "followedSliceDeletion"
        type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
        description: """
                       The deletion record.
                       """
      ]
    examples: []
  ]