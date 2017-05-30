examples = require("./examples")
helpers = require("./helpers")
events = require("./data-structure/events")
streams = require("./data-structure/streams")
tags = require("./data-structure/tags")
accesses = require("./data-structure/accesses")
followedSlices = require("./data-structure/followed-slices")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

# Quick macro
changeTrackingProperties = (typeName) ->
  return [
    key: "created"
    type: "[timestamp](#data-structure-timestamp)"
    readOnly: true
    description: "The time the #{typeName} was created."
  ,
    key: "createdBy"
    type: "[identifier](#data-structure-identifier)"
    readOnly: true
    description: "The id of the access used to create the #{typeName}."
  ,
    key: "modified"
    type: "[timestamp](#data-structure-timestamp)"
    readOnly: true
    description: "The time the #{typeName} was last modified."
  ,
    key: "modifiedBy"
    type: "[identifier](#data-structure-identifier)"
    readOnly: true
    description: "The id of the last access used to modify the #{typeName}."
  ]

module.exports = exports =
  id: "data-structure"
  title: "Data structure"
  description: ""
  sections: [

    events.event
  ,

    streams.stream

  ,

    tags.tag

  ,

    accesses.access

  ,

    followedSlices.followedSlice

  ,

    id: "account"
    title: "Account information"
    trustedOnly: true
    description: """
                 User account information.
                 """
    properties: [
      key: "username"
      type: "string"
      unique: true
      readOnly: true
      description: """
                   The user's username.
                   """
    ,
      key: "email"
      type: "string"
      unique: true
      description: """
                   The user's contact e-mail address.
                   """
    ,
      key: "language"
      type: "string"
      description: """
                   The user's preferred language as a 2-letter ISO language code.
                   """
    ,
      key: "storageUsed"
      type: "object"
      description: """
                   The current storage size used by the user account.
                   """
      properties: [
        key: "dbDocuments"
        type: "number"
        description: """
                     Bytes used by documents (records) in the database.
                     """
      ,
        key: "attachedFiles"
        type: "number"
        description: """
                     Bytes used by attached files.
                     """
      ]
    ]
    examples: []

  ,

    id: "item-deletion"
    title: "Item deletion"
    description: """
                 A record of a deleted item for sync purposes. Item deletions are currently kept for a year.
                 """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      description: """
                   The identifier of the deleted item.
                   """
    ,
      key: "deleted"
      type: "[timestamp](#data-structure-timestamp)"
      optional: true
      description: """
                   The time the item was deleted.
                   """
    ]
    examples: []

  ,

    id: "key-value"
    title: "Key-value"
    description: """
                 An object (key-value map) for client apps to store additional data about the containing item (stream, event, etc.), such as a color, a reference to an associated icon, or other app-specific metadata.

                 ### Adding, updating and removing client data

                 When the containing item is updated, additional data fields can be added, updated and removed as follows:

                 - To add or update a field, just set its value; for example: `{"clientData": {"keyToAddOrUpdate": "value"}}`
                 - To delete a field, set its value to `null`; for example: `{"clientData": {"keyToDelete": null}}`

                 Fields you don't specify in the update are left untouched.

                 ### Naming convention

                 The convention is that each app names the keys it uses with an `{app-id}:` prefix. For example, an app with id "riki" would store its data in fields such as `"riki:key": "some value"`.
                 """
    examples: []

  ,

    id: "error"
    title: "Error"
    description: ""
    properties: [
      key: "id"
      type: "string"
      description: """
                   Identifier for the error.
                   """
    ,
      key: "message"
      type: "string"
      description: """
                   A human-readable description of the error.
                   """
    ,
      key: "data"
      type: "any type"
      optional: true
      description: """
                   Additional machine-readable details (specified for each error if relevant).
                   """
    ,
      key: "subErrors"
      type: "array of errors"
      optional: true
      description: """
                   Lists the detailed causes of the main error, if any.
                   """
    ]
    examples: []

  ,

    id: "identifier"
    title: "Item identifier"
    description: """
                 A string uniquely identifying an item for a given user. For some types of items (e.g. "structural" ones such as streams), the identifier can be optionally set by API clients; otherwise it is generated by the server. **Event ids are always [collision-resistant cuids](https://usecuid.org/).**
                 """
    examples: []

  ,

    id: "timestamp"
    title: "Timestamp"
    description: """
                 A positive floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not actually matter (but we do use standard Unix epoch time).
                 """
    examples: [
      title: "Getting a valid timestamp:"
      content: """
               - JavaScript: `Date.now() / 1000`
               - PHP (5+): `microtime(true)`
               - TODO: more
               """
    ]
  ]

# Returns the in-doc id of the given type, for safe linking from other doc sections
exports.getDocId = (typeId) ->
  typeSection = _.find(exports.sections, (type) -> type.id == typeId)
  if typeSection
    return helpers.getDocId(exports.id, typeId)
  else
    throw new Error("Unknown type id")
