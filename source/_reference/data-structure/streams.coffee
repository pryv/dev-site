helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.stream =
  id: "stream"
  title: "Stream"
  description: """
                 See also: [core concepts](/concepts/#streams).
                 """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: "(except at creation)"
    description: """
                   The identifier for the stream. Automatically generated if not set when creating the stream; **slugified if necessary**.
                   """
  ,
    key: "name"
    type: "string"
    unique: "among siblings"
    description: """
                   A name identifying the stream for users. The name must be unique among the stream's siblings in the streams tree structure.
                   """
  ,
    key: "parentId"
    type: "[identifier](##{_getDocId("identifier")})"
    optional: true
    description: """
                   The identifier of the stream's parent, if any. A value of `null` indicates that the stream has no parent (i.e. root stream).
                   """
  ,
    key: "singleActivity"
    type: "boolean"
    optional: true
    description: """
                   If specified and `true`, the system will ensure that period events in this stream and its children never overlap.
                   """
  ,
    key: "clientData"
    type: "[key-value](##{_getDocId("key-value")})"
    optional: true
    description: """
                   Additional client data for the stream.
                   """
  ,
    key: "children"
    type: "array of streams"
    readOnly: true
    description: """
                   The stream's sub-streams, if any. This field cannot be set in requests creating a new streams: streams are created individually by design.
                   """
  ,
    key: "trashed"
    type: "boolean"
    optional: true
    description: """
                   `true` if the stream is in the trash.
                   """
  ].concat(helpers.changeTrackingProperties("stream"))
  examples: [
    title: "A structure for activities"
    content: examples.streams.activities
  ]