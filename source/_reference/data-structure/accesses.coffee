helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.access =
  id: "access"
  title: "Access"
  description: """
                 See also: [core concepts](/concepts/#accesses).
                 """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: true
    description: """
                   The identifier for the access.
                   """
  ,
    key: "token"
    type: "string"
    unique: true
    readOnly: "(except at creation)"
    description: """
                   The token identifying the access. Automatically generated if not set when creating the access; **slugified if necessary**.
                   """
  ,
    key: "type"
    type: "`personal`|`app`|`shared`"
    readOnly: "(except at creation)"
    optional: true
    description: """
                   The type — or usage — of the access. Default: `shared`.
                   """
  ,
    key: "name"
    type: "string"
    unique: "per type and device"
    description: """
                   The name identifying the access for the user. (For personal and app access, the name is used as a technical identifier and not shown as-is to the user.)
                   """
  ,
    key: "deviceName"
    type: "string"
    optional: true
    unique: "per type and name"
    description: """
                   For app accesses only. The name of the client device running the app, if applicable.
                   """
  ,
    key: "permissions"
    type: "array of permission objects"
    description: """
                   Ignored for personal accesses. If permission levels conflict (e.g. stream set to "manage" and child stream set to "contribute"), only the highest level is considered. Each permission object has the following structure:
                   """
    properties: [
      key: ["streamId", "tag"]
      type: "[identifier](##{_getDocId("identifier")}) | string"
      description: """
                     The id of the stream or the tag the permission applies to, or `*` for all streams/tags. Stream permissions are recursively applied to child streams.
                     """
    ,
      key: "level"
      type: "`read`|`contribute`|`manage`"
      description: """
                     The level of access to the stream. With `contribute`, one can see and record events for the stream/tag (and child streams for stream permissions); with `manage`, one can in addition create, modify and delete child streams.
                     """
    ]
  ,
    key: "lastUsed"
    type: "[timestamp](#data-structure-timestamp)"
    optional: true
    readOnly: true
    description: "The time the access was last used."
  ].concat(helpers.changeTrackingProperties("access"))
  examples: [
    title: "An app access"
    content: examples.accesses.app
  ]