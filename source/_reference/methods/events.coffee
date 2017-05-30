dataStructure = require('../data-structure.coffee')
examples = require("../examples")
helpers = require("../helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)


module.exports.event =
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
                curl -i https://${username}.pryv.io/events?auth=${token}&streams[]=diary&streams[]=weight
                ```
                """
      result:
        events: [examples.events.picture, examples.events.note, examples.events.position, examples.events.mass]
    ,
      title: "cURL with deletions"
      params: """
                ```bash
                curl -i https://${username}.pryv.io/events?auth=${token}&includeDeletions=true&modifiedSince=#{timestamp.now('-24h')}
                ```
                """
      result:
        events: [examples.events.mass, examples.itemDeletions[0], examples.itemDeletions[1], examples.itemDeletions[2]]
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
          text: "= request body"
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
        event: _.defaults({
          tags: ["home"],
          modified: timestamp.now(),
          modifiedBy: examples.accesses.app.id
        }, examples.events.position)
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
                 curl -i -F "file=@{filename}" https://${username}.pryv.io/events/#{examples.events.picture.id}?auth=${token}
                 ```
                 """
    ]

  ,

    id: "events.getAttachment"
    type: "method"
    title: "Get attachment"
    httpOnly: true
    http: "GET /events/{id}/{fileId}[/{fileName}]"
    description: """
                   Gets the attached file. Accepts an arbitrary filename path suffix (ignored) for easier link creation.
                   """
    params:
      properties: [
        key: "readToken"
        type: "string"
        description: """
                       The file read token to authentify the request if not using the `Authorization` HTTP header. See [`event.attachments[].readToken`](##{dataStructure.getDocId("event")}) for more info.
                       """
      ]
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
        event: _.defaults({
          trashed: true,
          modified: timestamp.now(),
          modifiedBy: examples.accesses.app.id
        }, examples.events.note)
    ]
  ]