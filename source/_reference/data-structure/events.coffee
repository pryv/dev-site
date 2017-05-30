helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.event =
  id: "event"
  title: "Event"
  description: """
                 See also: [core concepts](/concepts/#events).
                 """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: "(except at creation)"
    description: """
                   The identifier ([collision-resistant cuid](https://usecuid.org/)) for the event. Automatically generated if not set when creating the event.
                   """
  ,
    key: "streamId"
    type: "[identifier](##{_getDocId("identifier")})"
    description: """
                   The id of the belonging stream.
                   """
  ,
    key: "time"
    type: "[timestamp](##{_getDocId("timestamp")})"
    description: """
                   The event's time. For period events, this is the time the event started.
                   """
  ,
    key: "duration"
    type: "[timestamp](##{_getDocId("timestamp")})"
    optional: true
    description: """
                   If present and non-zero, indicates that the event is a period event. **Running period events have a duration set to `null`**. **A duration set to zero is equivalent to no duration**. (We use a dedicated field for duration—instead of using the `content` field—as we do specific processing of event durations, intervals and overlapping.)
                   """
  ,
    key: "type"
    type: "string"
    description: """
                   The type of the event. See the [event type directory](/event-types/#directory) for a list of standard types.
                   """
  ,
    key: "content"
    type: "any type"
    optional: true
    description: """
                   The `type`-specific content of the event, if any.
                   """
  ,
    key: "tags"
    type: "array of strings"
    optional: "(always present in read items)"
    description: """
                   The tags associated with the event.
                   """
  ,
    key: "references"
    type: "array of [identifier](##{_getDocId("identifier")})"
    optional: true #"(always present in read items)"
    description: """
                   Other events associated with the event. *Note: event references are coming in a future version of the API.*
                   """
  ,
    key: "description"
    type: "string"
    optional: true
    description: """
                   User description or comment for the event.
                   """
  ,
    key: "attachments"
    type: "array of attachment objects"
    optional: true
    readOnly: true
    description: """
                   An array describing the files attached to the event. Each item has the following structure:
                   """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      description: """
                     The file's id. The attached file's URL is obtained by appending this id to the event's resource URL.
                     """
    ,
      key: "fileName"
      type: "string"
      description: """
                     The file's name as uploaded.
                     """
    ,
      key: "type"
      type: "string"
      description: """
                     The MIME type of the file.
                     """
    ,
      key: "size"
      type: "number"
      description: """
                     The size of the file, in bytes.
                     """
    ,
      key: "readToken"
      type: "string"
      description: """
                     The auth token to pass in the query string when reading the file (instead of the regular `auth` parameter). The token is unique for the file and the access used to read it. This is a security measure in situations where it is impractical to use the `Authorization` HTTP header and/or where the file's URL is likely to be exposed. See also events method [get attachment](#methods-events-events-getAttachment).
                     """
    ]
  ,
    key: "clientData"
    type: "[key-value](##{_getDocId("key-value")})"
    optional: true
    description: """
                   Additional client data for the event.
                   """
  ,
    key: "trashed"
    type: "boolean"
    optional: true
    description: """
                   `true` if the event is in the trash.
                   """
  ].concat(helpers.changeTrackingProperties("event"))
  examples: [
    title: "A picture"
    content: examples.events.picture
  ,
    title: "An activity"
    content: examples.events.activity
  ,
    title: "A position"
    content: examples.events.position
  ]