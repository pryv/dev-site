pages = require("../_meta").pages
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
          type: "array of [identity](##{dataStructure.getDocId("identity")})"
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
        ]
      result:
        http: "200 OK"
        properties: [
          key: "events"
          type: "array of [events](##{dataStructure.getDocId("event")})"
          description: """
                       The accessible events ordered by time (see `sortAscending` above).
                       """
        ]
      examples: [
        params: {}
        result:
          events: [examples.events.picture, examples.events.activity, examples.events.position]
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
          type: "[identity](##{dataStructure.getDocId("identity")})"
          description: """
                       Only in `singleActivity` streams. If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The stream is in the trash, and we prevent the recording of new events into trashed streams.
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
                 curl -i -F 'event={"streamId":"#{examples.events.picture.streamId}","type":"#{examples.events.picture.type}"}'  -F "file=@#{examples.events.picture.attachments[0].fileName}" https://${username}.pryv.io/events?auth=${token}
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
                   Stops a running period event. In `singleActivity` streams, which guarantee that only one event is running at any given time, that event is automatically determined; for regular streams, the event to stop must be specified.
                   """
      params:
        properties: [
          key: "streamId"
          type: "[identity](#{dataStructure.getDocId("identity")})"
          description: """
                       The id of the `singleActivity` stream in which to stop the running event. Either this or `id` must be specified.
                       """
        ,
          key: "id"
          type: "[identity](#{dataStructure.getDocId("identity")})"
          description: """
                       The id of the event to stop. Either this or `streamId` must be specified.
                       """
        ,
          key: "time"
          type: "[timestamp](#{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The stop time. Default: now.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "stoppedId"
          type: "[identity](#{dataStructure.getDocId("identity")})"
          description: """
                       The id of the event that was stopped or null if no running event was found.
                       """
        ]
      errors: [
        key: "unknown-event"
        http: "400"
        description: """
                     The specified event cannot be found.
                     """
      ,
        key: "invalid-operation"
        http: "400"
        description: """
                     The specified event is not a running period event.
                     """
      ,
        key: "missing-parameter"
        http: "400"
        description: """
                     No `id` was specified and the specified stream is not a `singleActivity` stream (so that there can be more than one running event).
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       New values for the event's fields: see [event](#{dataStructure.getDocId("event")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](#{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ,
          key: "stoppedId"
          type: "[identity](#{dataStructure.getDocId("identity")})"
          description: """
                       Only in `singleActivity` streams. If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     Only in `singleActivity` streams. The duration of the period event cannot be set to `null` (i.e. still running) if one or more other period event(s) exist later in time. The error's `data.conflictingPeriodId` provides the id of the closest conflicting event.
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
          type: "[event](#{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      examples: [
        title: "cURL"
        content: """
                 ```bash
                 curl -i -F "file=@{filename}" https://${username}.pryv.io/events/#{examples.events.picture.id}?auth=${token}
                 ```
                 """
      ]

    ,

      id: "events.getAttachment"
      type: "method"
      title: "Get attachment"
      httpOnly: true
      http: "GET /events/{id}/{fileId}"
      description: """
                   Gets the attached file.
                   """
      result:
        http: "200 OK"
        description: """
                     The file's contents.
                     """
      examples: [

      ]

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
          type: "[identity](#{dataStructure.getDocId("identity")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "fileId"
          type: "[identity](#{dataStructure.getDocId("identity")})"
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
          type: "[event](#{dataStructure.getDocId("event")})"
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
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
          type: "[event](#{dataStructure.getDocId("event")})"
          description: """
                       The trashed event.
                       """
        ]
      ,
        title: "Result: deleted"
        http: "204 No content"
      ]
      examples: [
        title: "Trashing"
        params:
          id: examples.events.note.id
        result:
          event: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.events.note)
      ]
    ]

  ,

    id: "streams"
    title: "Streams"
    description: """
                 Methods to retrieve and manipulate [streams](#{dataStructure.getDocId("stream")}).
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
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
        ]
      result:
        http: "200 OK"
        properties: [
          key: "streams"
          type: "array of [streams](#{dataStructure.getDocId("stream")})"
          description: """
                       The tree of the accessible streams, sorted by name.
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
                     The new stream's data: see [stream](#{dataStructure.getDocId("stream")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "stream"
          type: "[stream](#{dataStructure.getDocId("stream")})"
          description: """
                       The created stream.
                       """
        ]
      errors: [
        key: "item-id-already-exists"
        http: "400"
        description: """
                     A stream already exists with the same id.
                     """
      ,
        key: "item-name-already-exists"
        http: "400"
        description: """
                     A sibling stream already exists with the same name.
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
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
                       New values for the stream's fields: see [stream](#{dataStructure.getDocId("stream")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "stream"
          type: "[stream](#{dataStructure.getDocId("stream")})"
          description: """
                       The updated stream (without child streams).
                       """
        ]
      errors: [
        key: "item-name-already-exists"
        http: "400"
        description: """
                     A sibling stream already exists with the same name.
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
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
          type: "[stream](#{dataStructure.getDocId("stream")})"
          description: """
                       The trashed stream.
                       """
        ]
      ,
        title: "Result: deleted"
        http: "204 No content"
      ]
      errors: [
        key: "missing-parameter"
        http: "400"
        description: """
                     There are events referring to the deleted item(s) and the `mergeEventsWithParent` parameter is missing.
                     """
      ]
      examples: [
        title: "Trashing"
        params:
          id: examples.streams.health[0].children[2].id
        result:
          event: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.streams.health[0].children[2])
      ]
    ]

  ,

    id: "accesses"
    title: "Accesses"
    description: """
                 Methods to retrieve and manipulate [accesses](#{dataStructure.getDocId("access")}), e.g. for sharing.
                 Any app can manage shared accesses whose permissions are a subset of its own. (Full access management is available to trusted apps.)
                 """
    sections: [
      id: "accesses.get"
      type: "method"
      title: "Get accesses"
      http: "GET /accesses"
      description: """
                   Gets manageable accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "accesses"
          type: "array of [accesses](#{dataStructure.getDocId("access")})"
          description: """
                       All manageable accesses in the user's account, ordered by name.
                       """
        ]
      examples: [
        params: {}
        result:
          accesses: [examples.accesses.shared]
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
                     An object with the new access's data: see [access](#{dataStructure.getDocId("access")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "access"
          type: "[access](#{dataStructure.getDocId("access")})"
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

      id: "accesses.update"
      type: "method"
      title: "Update access"
      http: "PUT /accesses/{id}"
      description: """
                   Modifies the specified access. You can only modify accesses whose permissions are a subset of those granted to your own access token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identity](#{dataStructure.getDocId("identity")})"
          http:
            text: "set in request path"
          description: """
                       The id of the access.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "= request body"
          description: """
                       New values for the access's fields: see [access](#{dataStructure.getDocId("access")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "access"
          type: "[access](#{dataStructure.getDocId("access")})"
          description: """
                       The updated access.
                       """
        ]
      examples: [
        title: "Adjusting permission level"
        params:
          id: examples.accesses.sharedNew.id
          update:
            permissions: [ _.defaults({level: "contribute"}, examples.accesses.sharedNew.permissions[0])]
        result:
          access: _.defaults({ permissions: [ _.defaults({level: "contribute"}, examples.accesses.sharedNew.permissions[0])], modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.accesses.sharedNew)
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
          type: "[identity](#{dataStructure.getDocId("identity")})"
          http:
            text: "set in request path"
          description: """
                       The id of the access.
                       """
        ]
      result:
        http: "204 No content"
      examples: [
        params:
          id: examples.accesses.shared.id
        result: {}
      ]
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
          type: "[access](#{dataStructure.getDocId("access")}).type"
          description: """
                       The access' type.
                       """
        ,
          key: "permissions"
          type: "[access](#{dataStructure.getDocId("access")}).permissions"
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
          methodId: "events.create"
          params: _.pick(examples.events.heartRate, "time", "streamId", "type", "content")
        ,
          methodId: "events.create"
          params: _.pick(examples.events.heartSystolic, "time", "streamId", "type", "content")
        ,
          methodId: "events.create"
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
