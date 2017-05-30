helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.tag =
  id: "tag"
  title: "Tag"
  description: """
                 Tags can be plain text or typed tags; this describes the latter. See also: [core concepts](/concepts/#tags). *Note: typed tags are coming in a future version of the API.*
                 """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: true
    description: """
                   The identifier for the tag.
                   """
  ,
    key: "type"
    type: "string"
    description: """
                   The type of the tag. See the [tag type directory](#TODO) for a list of standard types.
                   """
  ,
    key: "content"
    type: "any type"
    optional: true
    description: """
                   The `type`-specific content of the tag, if any.
                   """
  ,
    key: "clientData"
    type: "[key-value](##{_getDocId("key-value")})"
    optional: true
    description: """
                   Additional client data for the tag.
                   """
  ,
    key: "trashed"
    type: "boolean"
    optional: true
    description: """
                   `true` if the tag is in the trash.
                   """
  ].concat(helpers.changeTrackingProperties("tag"))
  examples: []