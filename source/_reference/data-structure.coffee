examples = require("./examples")
helpers = require("./helpers")
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
      type: "number"
      optional: true
      description: """
                   In seconds, if present and non-zero, indicates that the event is a period event. **Running period events have a duration set to `null`**. **A duration set to zero is equivalent to no duration**. (We use a dedicated field for duration—instead of using the `content` field—as we do specific processing of event durations, intervals and overlapping.)
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
    ].concat(changeTrackingProperties("event"))
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

  ,

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
    ].concat(changeTrackingProperties("stream"))
    examples: [
      title: "A structure for activities"
      content: examples.streams.activities
    ]

  ,

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
    ].concat(changeTrackingProperties("tag"))
    examples: []

  ,

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
        key: [ "streamId", "tag" ]
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
    ].concat(changeTrackingProperties("access"))
    examples: [
      title: "An app access"
      content: examples.accesses.app
    ]

  ,

    id: "followed-slice"
    title: "Followed slice"
    trustedOnly: true
    description: """
                 See also: [core concepts](/concepts/#followed-slices).
                 """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      unique: true
      readOnly: true
      description: """
                   The server-assigned identifier for the followed slice.
                   """
    ,
      key: "name"
      type: "string"
      unique: true
      description: """
                   A name identifying the followed slice for the user.
                   """
    ,
      key: "url"
      type: "URL"
      description: """
                   The URL of the API endpoint of the account hosting the slice. Not modifiable after creation.
                   """
    ,
      key: "accessToken"
      type: "string"
      description: """
                   The token of the shared access itself. Not modifiable after creation.
                   """
    ]
    examples: []

  ,

    id: "hook"
    title: "Hook"
    description: """
                 See also: [core concepts](/concepts/#hooks).
                 """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      unique: true
      readOnly: "(except at creation)"
      description: """
                   The identifier for the hook.
                   """
    ,
      key: "name"
      type: "string"
      unique: "among the access\' hooks"
      description: """
                   A name identifying the hook. The name must be unique among the access' hooks.
                   """
    ,
      key: "status"
      type: "`on`|`off`|`faulty`"
      optional: true
      description: """
                   The webhook's status. Can be updated manually. Status `faulty` can be triggered by the system after too much failures occur.
                   """
    ,
      key: "timeout"
      type: "number"
      optional: true
      description: """
                   In miliseconds, the maximum time to allocate to execute the hook. The system provides default and maximum values.
                   """
    ,
      key: "maxfail"
      type: "number"
      optional: true
      description: """
                   Maximum consecutive failures to tolerate before the system deactivates this hook by setting the status to `faulty`.
                   """
    ,
      key: "on"
      type: "array of `eventsChanged`|`streamsChanged`|`timer`|`load`|`close`"
      optional: false
      description: """
                   The changes or events that will trigger the execution of the hook

                   - *eventsChanged*: One or more event creation or modfication occured.
                   - *streamsChanged*: One ore more stream creation or modfication occured.
                   - *timer*: The hook supports triggers from timer (see persistantState:timedExecutionAt)
                   - *load*: When the hook is loaded by the system, (can occur after a restart)
                   - *close*: When the system is going down, for maintenance as an example. (their no warranty that this will be triggered)


                   """
    ,
      key: "persistantState"
      type: "object"
      optional: false
      description: """
                   The changes or events that will trigger the execution of the hook

                   - *eventsChanged*: One or more event creation or modfication occured.
                   - *streamsChanged*: One ore more stream creation or modfication occured.
                   - *timer*: The hook supports triggers from timer (see persistantState:timedExecutionAt)
                   - *load*: When the hook is loaded by the system, (can occur after a restart)
                   - *close*: When the system is going down, for maintenance as an example. (their no warranty that this will be triggered)


                   """
     ,
      key: "processes"
      type: "array of [Hook Process](##{_getDocId("hook-process")}) objects"
      optional: false
      description: """
                   Processes will be executed in order.
                   """
    ,
      key: "processError"
      type: "string"
      optional: true
      description: """
                   Javascript code to be executed in the scope of persistantState when an error occurs in the execution of one of the previous processes.
                   """
    ].concat(changeTrackingProperties("hook"))
    examples: [
      title: "TODO - example title"
      content: examples.hooks.todo
    ]

  ,


    id: "hook-persistantState"
    title: "Hook PersistantState"
    description: """
                 A persitant object that will be passed to all the processes and processError executions of a [Hook](##{_getDocId("hook")}).
                 """
    properties: [
      key: "timedExecutionAt"
      optional: true
      readOnly: false
      type: "[timestamp](#data-structure-timestamp)"
      description: """
                   If defined, define the next execution of this hook. This will be used only if `on` property of [Hook](##{_getDocId("hook")}).
                   """
    ,
      key: "batch"
      optional: true
      readOnly: false
      type: "[timestamp](#data-structure-timestamp)"
      description: """
                   If defined, define the next execution of this hook. This will be used only if `on` property of [Hook](##{_getDocId("hook")}).
                   """
    ,
      key: "*"
      type: "objects, numbers, strings"
      optional: true
      description: """
                   In a persistantState object any properties can be added for the usage of processes.
                   """
    ]
    examples: [
    ]
  ,

    id: "hook-process"
    title: "Hook Process"
    description: """
                 A single process of a hook chain
                 """
    properties: [
        key: "name"
        optional: false
        unique: "among the processes chain of this hook"
        type: "string"
        description: """
                     An identifier for this process
                     """
      ,
        key: "code"
        type: "string with valid javascript"
        optional: false
        description: """
                     Javascript code to be executed in the scope of persistantState
                     """
    ]
    examples: [
      title: "TODO - example title"
      content: examples.hooks.process
    ]
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
