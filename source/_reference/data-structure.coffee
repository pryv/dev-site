examples = require("./examples")
helpers = require("./helpers")
_ = require("lodash")
timestamp = require('unix-timestamp')

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
      key: "streamIds"
      type: "array of [identifier](##{_getDocId("identifier")})"
      description: """
                   The ids of the belonging streams.
                   """
    ,
      key: "streamId"
      type: "[identifier](##{_getDocId("identifier")})"
      description: """
                   **(DEPRECATED)** Please use streamIds instead.

                   The id of the first element of the streamIds array.
                   """
    ,
      key: "time"
      type: "[timestamp](##{_getDocId("timestamp")})"
      description: """
                   The event's time. For period events, this is the time the event started. Automatically set to the server time if not provided when creating the event.
                   """
    ,
      key: "duration"
      type: "[timestamp](##{_getDocId("timestamp")})"
      optional: true
      description: """
                   If present and non-zero, indicates that the event is a period event. **Running period events have a duration set to `null`**. **A duration set to zero is equivalent to no duration**.
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
                   **(DEPRECATED)** Please use streamIds instead.
                   
                   The tags associated with the event.
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
        key: [ "streamId", "tag"]
        type: "[identifier](##{_getDocId("identifier")}) | string"
        description: """
                     To be used with `level` property only.   
                     The id of the stream or the tag the permission applies to, or `*` for all streams/tags. Stream permissions are recursively applied to child streams. 
                     """
      ,
        key: "level"
        type: "`read`|`contribute`|`manage`|`create-only`"
        description: """
                     Used only with `streamId` or `tag` permissions.  
                     The level of access to the stream. With `contribute`, one can see and manipulate events for the stream/tag (and child streams for stream permissions); with `manage`, one can in addition create, modify and delete child streams.  
                     
                     The `create-only` level - only available for stream-based permissions - allows to read the stream and create events on it and its children.
                     """
      ,
        key: [ "feature"]
        type: "`selfRevoke`"
        description: """
                     To be used only with `setting` property.  
                     The only supported feature is `selfRevoke`
                     """
      ,
        key: "setting"
        type: "`forbidden`"
        description: """
                     To be used only with `feature` permission. 
                     If given in the permission list, this will forbid this access to call `accesses.delete {id}` and perform a self revocation.  
                     """
      ]
    ,
      key: "lastUsed"
      type: "[timestamp](#data-structure-timestamp)"
      optional: true
      readOnly: true
      description: "The time the access was last used."
    ,
      key: "expireAfter"
      type: "number"
      optional: true
      readOnly: false
      description: """
        (Only on create) If set, controls access expiry in seconds.
        When given a number in this attribute (positive or zero),
        the access will expire (and not be accessible any more) after this many
        seconds.
        """
    ,
      key: "expires"
      type: "[timestamp](#data-structure-timestamp)"
      optional: true
      readOnly: true
      description: """
        If the access was set to expire: The timestamp after which the access
        will be deactivated.
        """
    ,
      key: "deleted"
      type: "[timestamp](#data-structure-timestamp)"
      optional: true
      readOnly: true
      description: """
        If the access has been deleted: The timestamp of the deletion.
        """
    ,
      key: "clientData"
      type: "[key-value](##{_getDocId("key-value")})"
      optional: true
      description: """
                   Additional client data for the access.
                   """
    ].concat(changeTrackingProperties("access"))
    examples: [
      title: "An app access"
      content: examples.accesses.app
    ,
      title: "An app access with create-only and forbidden selfRevoke permissions"
      content: examples.accesses.createOnly
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

    id: "audit-log"
    title: "Audit log"
    description: """
                 Audit logs keep track of details about the actions performed by clients against Pryv.io accounts through the Pryv.io API.
                 These logs can be fetched by presenting an authorization token, allowing to audit the actions that involved a given token.
                 """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      readOnly: true
      description: """
                   The identifier for the action that generated this log.
                   """
    ,
      key: "type"
      type: "string"
      readOnly: true
      description: """
                   The type of log.
                   """
    ,
      key: "time"
      type: "[timestamp](#data-structure-timestamp)"
      readOnly: true
      description: """
                   The time the API call was executed.
                   """
    ,
      key: "forwardedFor"
      type: "string"
      readOnly: true
      description: """
                    The IP address of the client who performed the audited action.
                    """
    ,
      key: "action"
      type: "string"
      readOnly: true
      description: """
                    The audited action, typically an API method call, composed by the HTTP verb and the API resource.
                    """
    ,
      key: "query"
      type: "string"
      readOnly: true
      description: """
                    The query string that accompanied the audited action, if any.
                    """
    ,
      key: "accessId"
      type: "string"
      readOnly: true
      description: """
                    The identifier for the access used to perform the audited action.
                    """
    ,
      key: "status"
      type: "number"
      readOnly: true
      description: """
                    The HTTP response status resulting from the audited action.
                    """
    ,
      key: "errorMessage"
      type: "string"
      readOnly: true
      optional: true
      description: """
                    The error message resulting from the audited action, if any.
                    """
    ,
      key: "errorId"
      type: "string"
      readOnly: true
      optional: true
      description: """
                    The identifier for the error resulting from the audited action, if any.
                    """
    ]
    examples: [
      title: "A single audit log"
      content: examples.audit.log1
    ]
  ,

    id: "high-frequency-series"
    title: "HF series"
    description: """
                 High-frequency series are collections of homogenous data points. 

                 To store a HF series in Pryv.io, you must first [create a HF event](#create-hf-event).

                 Series data is encoded in the "flatJSON" format:
                 - Each data point in a series has a `"deltaTime"` field that indicates its time difference, since the holder event's [timestamp](#data-structure-timestamp).
                   If a `"timestamp"` field is instead provided, the corresponding `"deltaTime"` will be automatically computed from the holder event's timestamp.
                 - For [types](/event-types/#directory) that store a single value (e.g. "mass/kg"), a single additional field named `"value"` is created.
                 - Types that contain multiple properties (e.g. "position/wgs84") will have many fields, whose names can be inferred from the [type reference](/event-types/#position).
                 - Optional fields can either be provided or not; omitted values will be set as null.
                 """
    properties: [
      key: "format"
      type: "string"
      description: """
                   The data format (for now only "flatJSON" format is supported).
                   """
    ,
      key: "fields"
      type: "Array of fields"
      description: """
                   The "fields" array lists all the fields that you will be providing in the "points" array, including the "deltaTime" field in first position.
                   If the data type contains a single field (ex.: mass/kg), the second field is "value", otherwise, it is the list of fields with the required ones first.
                   """
    ,
      key: "points"
      type: "Array of data points"
      description: """
                   The "points" array contains the data points, each data point is represented by a simple array.
                   This makes the bulk of the message (your data points) very space-efficient; values are encoded positionally.
                   The first value corresponds to the first field, and so on.
                   """
    ]
    examples: [
      title: "High-frequency series for the type 'mass/kg', encoded as flatJSON"
      content: examples.events.series.mass
    ,
      title: "High-frequency series for the type 'position/wgs84', encoded as flatJSON"
      content: examples.events.series.position
    ]
  ,
    id: "webhook"
    title: "Webhook"
    description: """
                 Webhooks provide push notifications to web servers using HTTP POST requests.  
                 
                 Once created, they will run, executing a HTTP POST request to the provided URL for each [data change](#with-webhooks) in the user account. 

                 When the webhooks service is booted, it will send a `webhooksServiceBoot` message to all active webhooks. This allows to query the API for potentially missed notifications during its down time.

                 Only the app access used to create the webhook or a personal access can retrieve and modify it. This is meant to separate the responsibilities between the actor that sets the webhooks and the one(s) that consume the data following the webhook setup.
                 

                 """
    properties: [
      key: "id"
      type: "[identifier](##{_getDocId("identifier")})"
      readOnly: true
      description: """
                   The identifier of the Webhook.
                   """
    ,
      key: "accessId"
      type: "[identifier](##{_getDocId("identifier")})"
      readOnly: true
      description: """
                   The identifier of the access that was used to create the Webhook.
                   """
    ,
      key: "url"
      type: "string"
      unique: "per app access"
      readOnly: "(except at creation)"
      description: """
                   The URL where the HTTP POST requests will be made. To identify the source of the webhook on your notifications server, you can use the `url`'s hostname, path or query parameters. For example: 

                   ```json
                   {
                     "url": "https://${username}.my-notifications.com/${my-secret}/?param1=value1&param2=value2"
                   }
                   ```
                   """
    ,
      key: "minIntervalMs"
      type: "number"
      readOnly: true
      description: """
                   The webhooks run rate is throttled by a minimum interval between HTTP calls in milliseconds, sending an array of changes that occured during this period. Its value is set by the platform admin. 
                   """
    ,
      key: "maxRetries"
      type: "number"
      readOnly: true
      description: """
                   In case of failure to send a request, the webhook will retry `maxRetries` times at a growing interval of time before becoming `inactive` after too many successive failures. Its value is set by the platform admin.
                   """
    ,
      key: "currentRetries"
      type: "number"
      readOnly: true
      description: """
                   The number of retries iterations since the last failed HTTP call. This number is 0 if the last HTTP call was successful.
                   """
    ,
      key: "state"
      type: "`active`|`inactive`"
      description: """
                   The current state of the Webhook. An inactive Webhook will not make any HTTP call when changes occur. It must be activated using the [update webhook](#methods-webhooks-webhooks-update) method.
                   """
    ,
      key: "runCount"
      type: "number"
      readOnly: true
      description: """
                   The number of times the Webhook has been run, including failures.
                   """
    ,
      key: "failCount"
      type: "number"
      readOnly: true
      description: """
                   The number of times the Webhook has failed HTTP calls. Failed runs are HTTP requests that received a response with a status outside of the 200-299 range or no response at all.
                   """
    ,
      key: "lastRun"
      type: "Run object"
      readOnly: true
      description: """
                   Represents the last Webhook call, comprised of its HTTP response status and timestamp.
                   """
      properties: [
        key: "status"
        type: "number"
        description: """
                     The HTTP response status of the call.
                     """
      ,
        key: "timestamp"
        type: "[timestamp](#data-structure-timestamp)"
        description: """
                     The time the call was started.
                     """
      ]
    ,
      key: "runs"
      type: "array of Run objects"
      readOnly: true
      description: """
                   Array of Run objects in inverse chronological order (newest first) which allows to monitor a webhook's health. Its length is set by the platform admin. 
                   """
    ].concat(changeTrackingProperties("webhook"))
    examples: [
      title: "A simple Webhook"
      content: examples.webhooks.simple
    ]
  ,

    id: "item-deletion"
    title: "Item deletion"
    description: """
                 A record of a deleted item for sync purposes.
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

    id: "streams-query"
    title: "streams query"
    description: """
                 The `streams` parameter for [events.get](#get-events) query accepts an **array** of streamIds or a **streams query** for more complex requests.

                 **Syntax:**

                 The streams query must have at least an `any` or `all` property, with an optional `not`:  

                 ```json
                 { "any": ["streamA", "streamB"], "all": ["streamC"], "not": ["streamD"] }
                 ```

                 - **any**: any streamId must match  
                 - **all**: all streamIds must match  
                 - **not**: none of the streamIds must match  
                 
                 The returned events will be those matching all of the provided criteria.
                 
                 **Example:**  

                 To select all the events that are in `activity` or `nutrition`, tagged in `health`, but not in `running`:

                 ```json
                 {
                   "any": ["activity", "nutrition"],
                   "all": ["health"],
                   "not": ["running"]
                 }
                 ```

                 **Format:**  
                 
                 The JSON object representing the query must be sent [stringified](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify) when passed as query parameter in a `GET /events` HTTP call. 
                 It can be sent as-is for [batch](#call-batch) and [socket.io](#call-with-websockets) calls.  
                 """
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
