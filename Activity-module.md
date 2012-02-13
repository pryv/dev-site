# Activity module

TODO: introductory text

## Authentication

All requests to the activity module must carry a valid [[data access token|Data access tokens]] at the root of the resource path. For example:

    GET /<data access token>/types HTTP/1.1
    Host: johndoe.wactiv.com:1234
    Date: Thu, 09 Feb 2012 17:53:58 +0000
    
For the sake of readability, that token is omitted in the resource paths below, but it is assumed to be there. For example, GET `/types` must be understood as GET `/<data access token>/types`.


## Common error codes

TODO: review and complete

* 400 (bad request), code `InvalidParametersFormat`: The request's parameters do not follow the expected format
* 401 (authentication): Invalid data access token (TODO: review after discussion above)


## Requests for activity types

### GET `/types`

Gets the activity types accessible with the given token.

#### Query string parameters

* `includeInactive` ([[boolean|Boolean data type]]): Optional. When `true`, inactive activity types will be included in the result. Default: `false`.
* `timeCountBase` ([[timestamp|Timestamp data type]]): Optional. If specified, the returned activities types will include the **time accounting** calculated from this timestamp; otherwise the time accounting values returned will be empty. 

#### Response (OK)

* `types` (tree of [[activity types|Activity type data type]]): The tree of the activity types accessible with the given token. TODO exemple (with and without time accounting)
* `timeCountBase` ([[timestamp|Timestamp data type]]): The `timeCountBase` value passed as parameters in the request.
* `serverNow`([[timestamp|Timestamp data type]]): The current server time

### POST `/types`

Creates a new activity type (TODO)

#### Post parameters

* `parentId` ([[identity|Object identity data type]]): TODO
* `label` ([[string|String data type]]): TODO

#### Response (OK)

* `id` ([[identity|Object identity data type]]): TODO

#### Specific errors

* 400 (bad request), code `InvalidActivityTypeId`: TODO unknown parent
* 403 (forbidden): TODO

### POST `/types/<id>/set-info`

TODO: set active state, label, color, payload.
each parameter is optional

### POST `/types/<id>/move`

TODO

#### Post parameters

* `newParentId` ([[identity|Object identity data type]]): TODO

#### Response (OK)

TODO

#### Specific errors

* 400 (bad request), code `InvalidActivityTypeId`: TODO unknown parent
* 403 (forbidden): TODO
* 404 (not found): Unknown activity type id

### DELETE `/types/<id>`

TODO: will result in adding all activity time to the deleted item's parent. Real deletion may be set with `doNotMergeWithParent`

#### Query string parameters

* `doNotMergeWithParent` ([[boolean|Boolean data type]]): Optional. TODO. Default: `false`. 

#### Specific errors

* 403 (forbidden): TODO
* 404 (not found): Unknown activity type id


## Requests for activity events

TODO: add requests for mark (or note) events. Mark events will also belong to activity types like activity events.

### GET `/events`

Queries the list of events.

#### Query string parameters

* `onlyTypeIds` (array of [[identity|Object identity data type]]): Optional. TODO. Default is "all activity types".
* `fromTime` ([[timestamp|Timestamp data type]]): Optional. TODO. Default is 24 hours before the current time.
* `toTime` ([[timestamp|Timestamp data type]]): Optional. TODO. Default is the current time.

#### Response (OK)

* `events` (array of [[activity event|Activity event data type]]): Events ordered by time, descending (most recent first). TODO: add parameter to change sorting!
* `serverNow`([[timestamp|Timestamp data type]]): The current server time

#### Specific errors

* 400 (bad request), code `InvalidActivityTypeId`: TODO may happen if one of the filtered types doesn't exist
* 400 (bad request), code `InvalidTime`: TODO
* 403 (forbidden): TODO

### POST `/events`

Starts the given activity.

#### Post parameters

* `typeId` ([[identity|Object identity data type]]): TODO. If zero or empty, the call will be equivalent to POST `/events/current/stop` and other parameters will be ignored.
* `info` ([[string|String data type]]): Optional. TODO
* `eventData`([[event data|Event data data type]]): Optional. TODO

#### Response (OK)

* `id` ([[identity|Object identity data type]]): TODO

#### Specific errors

* 400 (bad request), code `InvalidActivityTypeId`: TODO
* 403 (forbidden): TODO

### TODO: GET `/events/start` non-RESTful alternative to the above to allow simple calls via e.g. wget

### GET `/events/current`

Gets the currently running activity.

#### Response (OK)

* `typeId` ([[identity|Object identity data type]]): TODO
* `id` ([[identity|Object identity data type]]): TODO
* `startTime` ([[timestamp|Timestamp data type]]): TODO
* `serverNow`([[timestamp|Timestamp data type]]): The current server time

#### Specific errors

* 403 (forbidden): TODO

### POST `/events/current/stop`

TODO: this is more consistent than `/events/<id>/stop`, as we can already stop the current activity with POST `/events`...

#### Response (OK)

TODO same as GET `/events/current`

#### Specific errors

* 403 (forbidden): TODO

### GET `/events/last`

TODO: added for consistency with the next request

### POST `/events/last/restart`

TODO: 

#### Response (OK)

TODO same as GET `/events/current`

#### Specific errors

* 403 (forbidden): TODO
* 404 (not found): There is no last event.

### POST `/events/<id>/set-info`

TODO (ex-"edit", renamed for consistency with types)

#### Post parameters

* `info` ([[string|String data type]]): Optional. TODO
* `eventData`([[event data|Event data data type]]): Optional. TODO

#### Specific errors

* 403 (forbidden): TODO
* 404 (not found): Unknown activity event id

### POST `/events/<id>/move`

TODO move an event's boundaries. Note: caller must be aware of "server now" time.

#### Post parameters

* `newStartTime` ([[timestamp|Timestamp data type]]): Optional. TODO if only the start time needs to be moved
* `newEndTime` ([[timestamp|Timestamp data type]]): Optional. TODO if only the end time needs to be moved
* `adaptPreviousIds` (array of ([[identity|Object identity data type]])): Optional. The preceding events' ids that will be automatically changed as a consequence of the current move. TODO: either end time or delete.
* `adaptNextIds` (array of ([[identity|Object identity data type]])): Optional. The following events' ids that will be automatically changed as a consequence of the current move. TODO: either start time or delete.

#### Specific errors

* 400 (bad request), code `InvalidTime`: TODO (start, end)
* 400 (bad request), code `EventsOverlap`: TODO (list of overlapped event ids, or "too many" if more than 10)
* 403 (forbidden): TODO
* 404 (not found): Unknown activity event id

### POST `/events/batch`

TODO: batch upload events that were recorded by the client while offline.

#### Post parameters

* `clientNow` ([[timestamp|Timestamp data type]]): TODO make clear that the date reference is the client's. Used to calculate the *time delta* to apply to server time for the given events.  See also start and end times for events below.
* `events`: Array of client-recorded events with the following structure:
	* `typeId` ([[identity|Object identity data type]]): The event's activity type id. TODO: explain "stop" (ie "0") + same warning on ignoring other data
	* `clientId` ([[identity|Object identity data type]]): Temporarily event id assigned by the client; used as reference in the request's response (see below).
	* `clientStartTime` ([[timestamp|Timestamp data type]]): The event's start time as recorded by the client.
	* `info` ([[string|String data type]]): Optional. TODO
    * `eventData`([[event data|Event data data type]]): Optional. TODO

#### Response (OK)

* `addedEvents`: Array of event information for successfully added events, with the following structure:
	* `clientId` ([[identity|Object identity data type]]): Client-assigned event id for reference.
	* `id` ([[identity|Object identity data type]]): The added event's id as allocated by the server.
	* `impactedEvents`: Array of previously recorded events impacted by the added event. TODO: clarify... for each: id, stateBefore (startTime, endTime), stateAfter (startTime, endTime)
* `rejectedEvents`: Array of event information for events that could not be added, with the following structure:
	* `clientId` ([[identity|Object identity data type]]): Client-assigned event id for reference.
	* `errorCode`: (TODO: review this, checking consistency with regular request errors...) One of `InvalidActivityTypeId`, `InvalidTime`, `InvalidParametersFormat` (TODO: I (SG) think such errors should cause the entire request to be rejected)
	* `errorMessage`: TODO should indicate e.g. whether start is invalid (review after the above is cleaned up)

#### Specific errors

* 403 (forbidden): TODO
