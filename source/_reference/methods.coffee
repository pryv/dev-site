basics = require('./basics')
dataStructure = require('./data-structure.coffee')
examples = require("./examples")
helpers = require("./helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)

module.exports = exports =
  id: "methods"
  title: "API methods"
  sections: [
    id: "auth"
    title: "Authentication"
    trustedOnly: true
    description: """
                 Methods for trusted apps to login/logout users.
                 """
    sections: [
      id: "auth.login"
      type: "method"
      title: "Login user"
      http: "POST /auth/login"
      description: """
                   Authenticates the user against the provided credentials, opening a personal access session. This is one of the only API methods that do not expect an [auth parameter](#basics-authentication).   
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "username"
          type: "string"
          description: """
                       The user's username.
                       """
        ,
          key: "password"
          type: "string"
          description: """
                       The user's password.
                       """
        ,
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "token"
          type: "string"
          description: """
                       The personal access token to use for further API calls.
                       """
        ,
          key: "preferredLanguage"
          type: "string"
          description: """
                       The user's preferred language as a 2-letter ISO language code.
                       """
        ]
      examples: [
        params:
          username: examples.users.one.username
          password: examples.users.one.password
          appId: "my-app-id"
        result:
          token: examples.accesses.personal.token
          preferredLanguage: examples.users.one.language
      ]

    ,

      id: "auth.logout"
      type: "method"
      title: "Logout user"
      http: "POST /auth/logout"
      description: """
                   Terminates a personal access session by invalidating its access token (the user will have to login again).
                   """
      result:
        http: "200 OK"
      examples: []
    ]

  ,

    id: "events"
    title: "Events"
    description: """
                 Methods to retrieve and manipulate [events](##{dataStructure.getDocId("event")}).
                 """
    sections: [
      id: "events.get"
      type: "method"
      title: "Get events"
      http: "GET /events"
      description: """
                   Queries accessible events.
                   """
      params:
        properties: [
          key: "fromTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The start time of the timeframe you want to retrieve events for. Default is 24 hours before `toTime` if the latter is set; otherwise it is not taken into account.
                       """
        ,
          key: "toTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The end time of the timeframe you want to retrieve events for. Default is the current time. Note: events are considered to be within a given timeframe based on their `time` only (`duration` is not considered).
                       """
        ,
          key: "streams"
          type: "array of [identifier](##{dataStructure.getDocId("identifier")})"
          optional: true
          description: """
                       If set, only events assigned to the specified streams and their sub-streams will be returned. By default, all accessible events are returned regardless of their stream.
                       """
        ,
          key: "tags"
          type: "array of strings"
          optional: true
          description: """
                       If set, only events assigned to any of the listed tags will be returned.
                       """
        ,
          key: "types"
          type: "array of strings"
          optional: true
          description: """
                       If set, only events of any of the listed types will be returned.
                       """
        ,
          key: "running"
          type: "boolean"
          optional: true
          description: """
                       If `true`, only running period events will be returned.
                       """
        ,
          key: "sortAscending"
          type: "`true`|`false`"
          optional: true
          description: """
                       If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
                       """
        ,
          key: "skip"
          type: "number"
          optional: true
          description: """
                       The number of items to skip in the results.
                       """
        ,
          key: "limit"
          type: "number"
          optional: true
          description: """
                       The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
                       """
        ,
          key: "state"
          type: "`default`|`trashed`|`all`"
          optional: true
          description: """
                       Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
                       """
        ,
          key: "modifiedSince"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       If specified, only events modified since that time will be returned.
                       """
        ,
          key: "includeDeletions"
          type: "boolean"
          optional: true
          description: """
                       Whether to include event deletions since `modifiedSince` for sync purposes (only applies when `modifiedSince` is set). Defaults to `false`.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "events"
          type: "array of [events](##{dataStructure.getDocId("event")})"
          description: """
                       The accessible events ordered by time (see `sortAscending` above).
                       """
        ,
          key: "eventDeletions"
          type: "array of [item deletions](##{dataStructure.getDocId("item-deletion")})"
          optional: true
          description: """
                       If requested by `includeDeletions`, the event deletions since `modifiedSince`, ordered by deletion time.
                       """
        ]
      examples: [
        title: "Fetching the last 20 events (default call)"
        params: {}
        result:
          events: [examples.events.picture, examples.events.activity, examples.events.position]
      ,
        title: "cURL for multiple streams"
        params: """
                ```bash
                curl -i https://${username}.pryv.me/events?auth=${token}&streams[]=diary&streams[]=weight
                ```
                """
        result:
          events: [examples.events.picture, examples.events.note, examples.events.position, examples.events.mass]
      ,
        title: "cURL with deletions"
        params: """
                ```bash
                curl -i https://${username}.pryv.me/events?auth=${token}&includeDeletions=true&modifiedSince=#{timestamp.now('-24h')}
                ```
                """
        result:
          events: [examples.events.mass, examples.itemDeletions[0], examples.itemDeletions[1], examples.itemDeletions[2]]
      ]

    ,

      id: "events.getOne"
      type: "method"
      title: "Get one event"
      http: "GET /events/{id}"
      description: """
                   Fetches a specific event. This request is mostly used to fetch an event's version history, allowing to review all the modifications to an event's data.
                   """
      params:
        properties: [
          key: "includeHistory"
          type: "boolean"
          optional: true
          description: """
                       If `true`, the event's history will be added to the response. Default: false (don't include the history).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The event.
                       """
        ,
          key: "history"
          type: "array of [events](##{dataStructure.getDocId("event")})"
          optional: true
          description: """
                       If requested by `includeHistory`, the history of the event as an array of events, ordered by modification time.
                       """
        ]
      examples: [
        title: "Fetching an event's version history"
        params: {"includeHistory": true}
        result:
          event: examples.events.noteWithHistory
          history: [
            examples.events.noteHistory1,
            examples.events.noteHistory2
          ]
      ]

    ,

      id: "events.create"
      type: "method"
      title: "Create event"
      http: "POST /events"
      description: """
                   Records a new event. It is recommended that events recorded this way are completed events, i.e. either period events with a known duration or mark events. To start a running period event, use [Start period](##{_getDocId("events", "events.start")}) instead.

                   In addition to JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.
                   """
      params:
        description: """
                     The new event's data: see [Event](##{dataStructure.getDocId("event")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The created event.
                       """
        ,
          key: "stoppedId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          description: """
                       Only in `singleActivity` streams. If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The referenced stream is in the trash, and we prevent the recording of new events into trashed streams.
                     """
      ,
        key: "periods-overlap"
        http: "400"
        description: """
                     Only in `singleActivity` streams: the new event overlaps existing period events. The overlapped events' ids are listed as an array in the error's `data.overlappedIds`.
                     """
      ]
      examples: [
        title: "Capturing a simple number value"
        params: _.pick(examples.events.mass, "streamId", "type", "content")
        result:
          event: examples.events.mass
      ,
        title: "cURL with attachment"
        content: """
                 ```bash
                 curl -i -F 'event={"streamId":"#{examples.events.picture.streamId}","type":"#{examples.events.picture.type}"}'  -F "file=@#{examples.events.picture.attachments[0].fileName}" https://${username}.pryv.me/events?auth=${token}
                 ```
                 """
        result:
          event: examples.events.picture
      ]

    ,

      id: "events.start"
      type: "method"
      title: "Start period"
      http: "POST /events/start"
      description: """
                   Starts a new period event. This is equivalent to starting an event with a null `duration`. In `singleActivity` streams, also stops the previously running period event if any.

                   See [Create event](##{_getDocId("events", "events.create")}) for details.
                   """
      examples: [
        title: "Starting an activity"
        params: _.pick(examples.events.activityRunning, "streamId", "type")
        resultHTTP: "201 Created" # add here as no result doc present above
        result:
          event: examples.events.activityRunning
      ]

    ,

      id: "events.stop"
      type: "method"
      title: "Stop period"
      http: "POST /events/stop"
      description: """
                   Stops a running period event. In `singleActivity` streams, which guarantee that only one event is running at any given time, that event is automatically determined; for regular streams, the event to stop (or its type) must be specified.
                   """
      params:
        properties: [
          key: "streamId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          description: """
                       The id of the `singleActivity` stream in which to stop the running event. Either this or `id` must be specified.
                       """
        ,
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          description: """
                       The id of the event to stop. Either this or `streamId` (and possibly `type`) must be specified.
                       """
        ,
          key: "type"
          type: "string"
          description: """
                       The type of the event to stop. `streamId` must be specified as well. If there are multiple running events matching, the closest one (by time) will be stopped.
                       """
        ,
          key: "time"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The stop time. Default: now.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "stoppedId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          description: """
                       The id of the event that was stopped or null if no running event was found.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The specified event is not a running period event.
                     """
      ]
      examples: [
        params:
          streamId: examples.events.activityRunning.streamId
          time: timestamp.now()
        result:
          stoppedId: examples.events.activityRunning.id
      ]

    ,

      id: "events.update"
      type: "method"
      title: "Update event"
      http: "PUT /events/{id}"
      description: """
                   Modifies the event.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the event's fields: see [event](##{dataStructure.getDocId("event")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ,
          key: "stoppedId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          description: """
                       Only in `singleActivity` streams. If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     Only in `singleActivity` streams. The duration of the period event cannot be set to `null` (i.e. still running) if one or more other period event(s) exist later in time. The error's `data.conflictingEventId` provides the id of the closest conflicting event.
                     """
      ,
        key: "periods-overlap"
        http: "400"
        description: """
                     Only in `singleActivity` streams. The time and/or duration of the period event cannot be set to overlap with other period events. The overlapping events' ids are listed as an array in the error's `data.overlappedIds`.
                     """
      ]
      examples: [
        title: "Adding a tag"
        params:
          id: examples.events.position.id
          update:
            tags: ["home"]
        result:
          event: _.defaults({ tags: ["home"], modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.events.position)
      ]

    ,

      id: "events.addAttachment"
      type: "method"
      title: "Add attachment(s)"
      httpOnly: true
      http: "POST /events/{id}"
      description: """
                   Adds one or more file attachments to the event. This request expects standard multipart/form-data content, with all content parts being the attached files.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      examples: [
        title: "cURL"
        content: """
                 ```bash
                 curl -i -F "file=@travel-expense.jpg" https://${username}.pryv.me/events/#{examples.events.activityAttachment.id}?auth=${token}
                 ```
                 """
        result:
          event: examples.events.activityAttachment
      ]

    ,

      id: "events.getAttachment"
      type: "method"
      title: "Get attachment"
      httpOnly: true
      http: "GET /events/{id}/{fileId}[/{fileName}]"
      description: """
                   Gets the attached file. Accepts an arbitrary filename path suffix (ignored) for easier link readability.
                   For this function using the `auth` query parameter is not accepted. You can either use the [access token](##{dataStructure.getDocId("access")}) in the `Authorization` header or provide the `readToken` as query parameter.
                   """
      params:
        properties: [
          key: "readToken"
          type: "string"
          http:
            text: "set in request path"
          description: """
                       Required if not using the `Authorization` HTTP header. The file read token to authentify the request. See [`event.attachments[].readToken`](##{dataStructure.getDocId("event")}) for more info.
                       """
        ]
      result:
        http: "200 OK"
        description: """
                     The file's content.
                     """
    ,

      id: "events.deleteAttachment"
      type: "method"
      title: "Delete attachment"
      http: "DELETE /events/{id}/{fileId}"
      description: """
                   Irreversibly deletes the attached file.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "fileId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the attached file.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      examples: [
        params:
          id: examples.events.activityAttachment.id
          fileId: examples.events.activityAttachment.attachments[0].id
        result:
          event: _.omit(examples.events.activityAttachment, "attachments")
      ]

    ,

      id: "events.delete"
      type: "method"
      title: "Delete event"
      http: "DELETE /events/{id}"
      description: """
                   Trashes or deletes the specified event, depending on its current state:

                   - If the event is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
                   - If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ]
      result: [
        title: "Result: trashed"
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The trashed event.
                       """
        ]
      ,
        title: "Result: deleted"
        http: "200 OK"
        properties: [
          key: "eventDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The event deletion record.
                       """
        ]
      ]
      examples: [
        title: "Trashing"
        params:
          id: examples.events.note.id
        result:
          event: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.events.note)
      ,
        title: "Deleting"
        params:
          id: examples.events.note.id
        result: {eventDeletion:{id:examples.events.note.id}}
      ]
    ]

  ,

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
          stream: _.defaults({ name: "Slothing", modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, _.omit(examples.streams.activities[0], "children"))
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
          event: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.streams.health[0].children[2])
      ,
        title: "Deleting"
        params:
          id: examples.streams.health[0].children[2].id
        result: {streamDeletion:{id:examples.streams.health[0].children[2].id}}
      ]
    ]

  ,

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
                   Gets manageable accesses. Only returns accesses that can
                   be managed by the requesting access and that are active when
                   making the request. To include accesses that have expired, use
                   the `includeExpired` parameter.
                   """
      params:
        properties: [
          key: "includeExpired"
          type: "boolean"
          optional: true
          description: """
            If `true`, also includes expired accesses. Defaults to `false`.
          """
        ,
          key: "includeDeletions"
          type: "boolean"
          optional: true
          description: """
            If `true`, also includes deleted accesses. Defaults to `false`.
          """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "accesses"
          type: "array of [accesses](##{dataStructure.getDocId("access")})"
          description: """
                       All manageable accesses in the user's account, ordered by name.
                       """
        ,
          key: "accessDeletions"
          type: "array of deleted [accesses](##{dataStructure.getDocId("access")})"
          description: """
                       If requested by `includeDeletions`, the access deletions, ordered by deletion time.
                       """
        ]
      examples: [
        params: {}
        result:
          accesses: [examples.accesses.shared]
      ,
        title: "cURL with deletions"
        params: """
                ```bash
                curl -i https://${username}.pryv.me/accesses?auth=${token}&includeDeletions=true
                ```
                """
        result:
          accesses: [examples.accesses.shared]
          accessDeletions: [examples.accesses.deleted]
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
        result: {accessDeletion:{id:examples.accesses.shared.id}}
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

  ,

    id: "audit"
    title: "Audit"
    previewOnly: true
    description: """
                 Methods to retrieve [Audit logs](##{dataStructure.getDocId("audit-log")}).
                 These methods expect a token in the 'Authorization' header or as 'auth' query parameter.
                 """
    sections: [
      id: "audit.get"
      type: "method"
      title: "Get audit logs"
      http: "GET /audit/logs"
      description: """
                   Fetches accessible audit logs.
                   By default, only returns logs that involve the access id corresponding to the provided authorization token (self-auditing).
                   """
      params:
        properties: [
          key: "accessId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          optional: true
          description: """
                       The id of a specific access to audit.
                       When specified, it fetches instead the audit logs that involve the given access id.
                       It has to correspond to a valid sub-access in regards to the provided authorization token.
                       """
        ,
          key: "fromTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The start time of the timeframe you want to retrieve audit logs for.
                       Timestamps are considered with a year/month/day precision.
                       """
        ,
          key: "toTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The end time of the timeframe you want to retrieve audit logs for.
                       Timestamps are considered with a year/month/day precision.
                       """
        ,
          key: "status"
          type: "number"
          optional: true
          description: """
                       Filters audit logs by HTTP code, a 3-digits number.
                       It is possible to provide only the first or two first digit(s),
                       in which case the unspecified digit(s) will be wildcarded.
                       """
        ,
          key: "ip"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by client IP present in the forwardedFor property.
                       """
        ,
          key: "httpVerb"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by HTTP verb present in the audited actions.
                       """
        ,
          key: "endpoint"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by API endpoint present in the audited actions.
                       """
        ,
          key: "errorId"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by error id.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "events"
          type: "array of [Audit logs](##{dataStructure.getDocId("audit-log")})"
          description: """
                       The accessible audit logs.
                       """
        ]
      errors: [
        key: "forbidden"
        http: "403"
        description: """
                     Authorization token is not authorized to audit the given access.
                     
                     When providing a specific access id, if the result of [Get Accesses](##{_getDocId("accesses", "accesses.get")})
                     using the provided Authorization token does not contain the given access, then it is not auditable.
                     """
        ]
      examples: [
        params: {
          "auth": examples.audit.auth,
          "accessId": examples.audit.log1.content.accessId,
          "fromTime": 1561000000,
          "toTime": 1562000000,
          "status": examples.audit.log1.content.status,
          "ip": examples.audit.log1.content.forwardedFor,
          "httpVerb": "GET",
          "endpoint": "/events",
          "errorId": examples.audit.log1.content.errorId
        }

        result:
          events: [
            examples.audit.log1,
            examples.audit.log2,
            examples.audit.log3
          ]
      ]

    ]

  ,

    id: "webhooks"
    title: "Webhooks"
    previewOnly: true
    description: """
                 Methods to retrieve and manipulate [webhooks](##{dataStructure.getDocId("webhook")}). These methods are only allowed for app and personal accesses.
                 """
    sections: [
      id: "webhooks.get"
      type: "method"
      title: "Get webhooks"
      http: "GET /webhooks"
      description: """
                   Gets manageable webhooks. Only returns webhooks that were created by the access, unless you are using a personal access which returns all existing webhooks in the user's account.
                   """
      params:
        properties: [
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhooks"
          type: "array of [webhooks](##{dataStructure.getDocId("webhook")})"
          description: """
                       All manageable webhooks by the given access, ordered by modified date.
                       """
        ]
      examples: [
        params: {}
        result:
          webhooks: [
            examples.webhooks.simple
          ,
            examples.webhooks.failing
          ]
      ]

    ,
      id: "webhooks.getOne"
      type: "method"
      title: "Get one webhook"
      http: "GET /webhooks/{id}"
      description: """
                   Fetches a specific webhook. Only returns a webhook if it was created by the access, unless you are using a personal access which is allowed to fetch any existing webhook in the user's account.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The webhook.
                       """
        ]
      examples: [
        params: {}
        result:
          webhook: examples.webhooks.simple
      ]

    ,

      id: "webhooks.create"
      type: "method"
      title: "Create webhook"
      http: "POST /webhooks"
      description: """
                   Creates a new webhook. You can only create webhooks with app accesses. Its permissions will always match the permissions of the access used to create it.
                   """
      params:
        description: """
                     An object with the new webhook's data: see [webhook](##{dataStructure.getDocId("webhook")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The created webhook.
                       """
        ]
      errors: [
        key: "item-already-exists"
        http: "400"
        description: """
                     There is already a webhook for this URL created by the given access.
                     """
      ]
      examples: [
        params: _.pick(examples.webhooks.new, "url")
        result:
          webhook: examples.webhooks.new
      ]

    ,

      id: "webhooks.update"
      type: "method"
      title: "Update webhook"
      http: "PUT /webhooks/{id}"
      description: """
                   Modifies the webhook. You can only modify webhooks with the app access that was used to create them, unless you are using a personal token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the webhook's fields: see [webhook](##{dataStructure.getDocId("webhook")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 Created"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The created webhook.
                       """
        ]
      errors: [
        key: "item-already-exists"
        http: "400"
        description: """
                     There is already a webhook for this URL created by the given access.
                     """
      ]
      examples: [
        params: _.pick(examples.webhooks.failing, "url")
        result:
          webhook: examples.webhooks.failing
      ]
    
    ,

      id: "webhooks.delete"
      type: "method"
      title: "Delete webhook"
      http: "DELETE /webhooks/{id}"
      description: """
                   Deletes the specified webhook. You can only delete webhooks with the app access that was used to create them, unless you are using a personal token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhookDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The deletion record.
                       """
        ]
      examples: [
        params:
          id: examples.webhooks.new.id
        result: {webhookDeletion:{id:examples.webhooks.new.id}}
      ]

    ,

      id: "webhooks.test"
      type: "method"
      title: "Test webhook"
      http: "POST /webhooks/{id}/test"
      description: """
                   Sends a post request to the URL of the specified webhook with a test message. You can only test webhooks with the app access that was used to create them, unless you are using a personal token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The webhook.
                       """
        ]
      examples: [
        params: {}
        result:
          webhook: examples.webhooks.new
      ]

    ]

  ,

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

  ,

    id: "profile"
    title: "Profile sets"
    description: """
                 Methods to read and write profile sets. Profile sets are plain key-value stores of user-level settings.
                 """
    sections: [
      id: "profile.getPublic"
      type: "method"
      title: "Get public user profile"
      http: "GET /profile/public"
      description: """
                   Gets the user's public profile set, which contains the information the user makes publicly available (e.g. avatar image). Available to all accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The user's current public profile set.
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.public
      ]

    ,

      id: "profile.getApp"
      type: "method"
      title: "Get app profile"
      http: "GET /profile/app"
      description: """
                   Gets the app's dedicated user profile set, which contains app-level settings for the user. Available to app accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The app's current profile set. (Empty if the app never defined any setting.)
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.app
      ]

    ,

      id: "profile.updateApp"
      type: "method"
      title: "Update app profile"
      http: "PUT /profile/app"
      description: """
                   Adds, updates or delete app profile keys.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The app's updated profile set.
                       """
        ]
      examples: [
        params:
          setting1: "new value",
          setting2: null
        result:
          profile: _.defaults({setting1: "new value"}, _.omit(examples.profileSets.app, "setting2"))
      ]

    ,

      id: "profile.get"
      type: "method"
      trustedOnly: true
      title: "Get profile"
      http: "GET /profile/{id}"
      description: """
                   Gets the specified user profile set.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the profile set.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The profile set.
                       """
        ]
      examples: []

    ,

      id: "profile.update"
      type: "method"
      trustedOnly: true
      title: "Update profile"
      http: "PUT /profile/{id}"
      description: """
                   Adds, updates or delete profile keys.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the profile set.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The updated profile set.
                       """
        ]
      examples: []
    ]

  ,

    id: "account"
    title: "Account management"
    trustedOnly: true
    description: """
                 Methods to manage the user's account.
                 """
    sections: [
      id: "account.get"
      type: "method"
      title: "Get account information"
      http: "GET /account"
      description: """
                   Retrieves the user's account information.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The user's account information.
                       """
        ]
      examples: [
        params: {}
        result:
          account: _.omit(examples.users.one, "id", "password")
      ]

    ,

      id: "account.update"
      type: "method"
      title: "Update account information"
      http: "PUT /account"
      description: """
                   Modifies the user's account information.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       New values for the account information's fields: see [account information](##{dataStructure.getDocId("account")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The updated account information.
                       """
        ]
      examples: []

    ,

      id: "account.changePassword"
      type: "method"
      title: "Change password"
      http: "POST /account/change-password"
      description: """
                   Modifies the user's password.
                   """
      params:
        properties: [
          key: "oldPassword"
          type: "string"
          description: """
                       The current password.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ]
      result:
        http: "200 OK"
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The given password does not match.
                     """
      ]
      examples: [
        params:
          oldPassword: examples.users.one.password
          newPassword: "//\\_.:o0o:._//\\"
        result: {}
      ]

    ,

      id: "account.requestPasswordReset"
      type: "method"
      title: "Request password reset"
      http: "POST /account/request-password-reset"
      description: """
                   Requests the resetting of the user's password. An e-mail containing an expiring reset token (e.g. in a link) will be sent to the user.  
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          appId: "my-app-id"
        result: {}
      ]

    ,

      id: "account.resetPassword"
      type: "method"
      title: "Reset password"
      http: "POST /account/reset-password"
      description: """
                   Resets the user's password, authenticating the request with the given reset token (see [request password reset](##{_getDocId("account", "account.requestPasswordReset")}) ).  
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "resetToken"
          type: "string"
          description: """
                       The expiring reset token that was sent to the user after requesting the password reset.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ,
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          resetToken: "chtplghfp0000hqjx814u6393"
          newPassword: "Dr0ws$4p"
          appId: "my-app-id"
        result: {}
      ]
    ]

  ,

    id: "utils"
    title: "Utils"
    description: """
                 Utility methods that don't pertain to a particular resource type.
                 """
    sections: [
      id: "getAccessInfo"
      type: "method"
      title: "Get current access info"
      http: "GET /access-info"
      description: """
                   Retrieves the name, type and permissions of the access in use.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "name"
          type: "string"
          description: """
                       The access' name.
                       """
        ,
          key: "type"
          type: "[access](##{dataStructure.getDocId("access")}).type"
          description: """
                       The access' type.
                       """
        ,
          key: "permissions"
          type: "[access](##{dataStructure.getDocId("access")}).permissions"
          description: """
                       The access' permissions.
                       """
        ]
      examples: [
        params: {}
        result: _.pick(examples.accesses.app, "name", "type", "permissions")
      ]

    ,

      id: "callBatch"
      type: "method"
      title: "Call batch"
      http: "POST /"
      description: """
                   Sends a batch of API methods calls in one go (e.g. for to syncing offline changes when resuming connectivity).
                   """
      params:
        description: """
                     Array of method call objects, each defined as follows:
                     """
        properties: [
          key: "method"
          type: "string"
          description: """
                       The method id.
                       """
        ,
          key: "params"
          type: "object or array"
          description: """
                       The call parameters as required by the method.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "results"
          type: "array of call results"
          description: "The results of each method call, in order."
        ]
      examples: [
        title: "Sync some health metrics"
        params: [
          method: "events.create"
          params: _.pick(examples.events.heartRate, "time", "streamId", "type", "content")
        ,
          method: "events.create"
          params: _.pick(examples.events.heartSystolic, "time", "streamId", "type", "content")
        ,
          method: "events.create"
          params: _.pick(examples.events.heartDiastolic, "time", "streamId", "type", "content")
        ]
        result:
          results: [
            event:
              examples.events.heartRate
          ,
            event:
              examples.events.heartSystolic
          ,
            event:
              examples.events.heartDiastolic
          ]
      ]
    ]

  ]

# Returns the in-doc id of the given method, for safe linking from other doc sections
exports.getDocId = (methodId) ->
  result = null
  exports.sections.forEach((section) ->
    methodSection = _.find(section.sections, (subSection) -> subSection.id == methodId)
    if methodSection
      result = helpers.getDocId(exports.id, section.id, methodId)
  )
  return result || throw new Error("Unknown method id")
