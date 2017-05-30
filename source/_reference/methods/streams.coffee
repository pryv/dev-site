dataStructure = require('../data-structure.coffee')
examples = require("../examples")
helpers = require("../helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)


module.exports.stream =
  id: "streams"
  title: "Streams"
  description: """
                 Methods to retrieve and manipulate [streams](##{dataStructure.getDocId("stream")}).
                 """
  sections: [
    id: "streams.get"
    type: "method"
    title: "Get streams"
    http: "GET /streams"
    description: """
                   Gets the accessible streams hierarchy.
                   """
    params:
      properties: [
        key: "parentId"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        optional: true
        description: """
                       The id of the parent stream from which to retrieve streams. Default: `null` (returns all accessible streams from the root level).
                       """
      ,
        key: "state"
        type: "`default`|`all`"
        optional: true
        description: """
                       By default, only items that are not in the trash are returned; `all` return all items regardless of their state.
                       """
      ,
        key: "includeDeletionsSince"
        type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
        optional: true
        description: """
                       Whether to include stream deletions since that time for sync purposes.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "streams"
        type: "array of [streams](##{dataStructure.getDocId("stream")})"
        description: """
                       The tree of the accessible streams, sorted by name.
                       """
      ,
        key: "streamDeletions"
        type: "array of [item deletions](##{dataStructure.getDocId("item-deletion")})"
        optional: true
        description: """
                       If requested by `includeDeletionsSince`, the stream deletions since then, ordered by deletion time.
                       """
      ]
    examples: [
      title: "Retrieving streams for work activities"
      params:
        parentId: examples.streams.activities[1].id
      result:
        streams: examples.streams.activities[1].children
    ]

  ,

    id: "streams.create"
    type: "method"
    title: "Create stream"
    http: "POST /streams"
    description: """
                   Creates a new stream.
                   """
    params:
      description: """
                     The new stream's data: see [stream](##{dataStructure.getDocId("stream")}).
                     """
    result:
      http: "201 Created"
      properties: [
        key: "stream"
        type: "[stream](##{dataStructure.getDocId("stream")})"
        description: """
                       The created stream.
                       """
      ]
    errors: [
      key: "item-already-exists"
      http: "400"
      description: """
                     A similar stream already exists. The error's `data` contains the conflicting properties.
                     """
    ,
      key: "invalid-item-id"
      http: "400"
      description: """
                     The specified id is invalid (e.g. it's a reserved word such as `null`).
                     """
    ]
    examples: [
      title: "Create sub-stream 'diastolic' of 'heart'"
      params: _.pick(examples.streams.healthSubstreams[0], "id", "name", "parentId")
      result:
        stream: examples.streams.healthSubstreams[0]
    ]

  ,

    id: "streams.update"
    type: "method"
    title: "Update stream"
    http: "PUT /streams/{id}"
    description: """
                   Modifies the stream.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the stream.
                       """
      ,
        key: "update"
        type: "object"
        http:
          text: "= request body"
        description: """
                       New values for the stream's fields: see [stream](##{dataStructure.getDocId("stream")}). All fields are optional, and only modified values must be included.
                       """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "stream"
        type: "[stream](##{dataStructure.getDocId("stream")})"
        description: """
                       The updated stream (without child streams).
                       """
      ]
    errors: [
      key: "item-already-exists"
      http: "400"
      description: """
                     A similar stream already exists. The error's `data` contains the conflicting properties.
                     """
    ]
    examples: [
      title: "Renaming a stream"
      params:
        id: examples.streams.activities[0].id
        update:
          name: "Slothing"
      result:
        stream: _.defaults({
          name: "Slothing",
          modified: timestamp.now(),
          modifiedBy: examples.accesses.app.id
        }, _.omit(examples.streams.activities[0], "children"))
    ]

  ,

    id: "streams.delete"
    type: "method"
    title: "Delete stream"
    http: "DELETE /streams/{id}"
    description: """
                   Trashes or deletes the specified stream, depending on its current state:

                   - If the stream is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
                   - If the stream is already in the trash, it will be irreversibly deleted with its descendants (if any). If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter `mergeEventsWithParent`.
                   """
    params:
      properties: [
        key: "id"
        type: "[identifier](##{dataStructure.getDocId("identifier")})"
        http:
          text: "set in request path"
        description: """
                       The id of the stream.
                       """
      ,
        key: "mergeEventsWithParent"
        type: "`true`|`false`"
        description: """
                       Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If `true`, the linked events will be assigned to the parent of the deleted item; if `false`, the linked events will be deleted.
                       """
      ]
    result: [
      title: "Result: trashed"
      http: "200 OK"
      properties: [
        key: "stream"
        type: "[stream](##{dataStructure.getDocId("stream")})"
        description: """
                       The trashed stream.
                       """
      ]
    ,
      title: "Result: deleted"
      http: "200 OK"
      properties: [
        key: "streamDeletion"
        type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
        description: """
                       The stream deletion record.
                       """
      ]
    ]
    examples: [
      title: "Trashing"
      params:
        id: examples.streams.health[0].children[2].id
      result:
        event: _.defaults({
          trashed: true,
          modified: timestamp.now(),
          modifiedBy: examples.accesses.app.id
        }, examples.streams.health[0].children[2])
    ]
  ]