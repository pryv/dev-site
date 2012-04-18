# Activity module

TODO: introductory text

## Authentication

All requests to the activity module must carry a valid [data access token](//DataTypes#TODO) in the HTTP `Authorization` header. For example:

    GET /MyChannel/events HTTP/1.1
    Host: johndoe.wactiv.com:1234
    Date: Thu, 09 Feb 2012 17:53:58 +0000
    
    Authorization: <data access token>
    

## Common error codes

TODO: review and complete

* 400 (bad request), id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
* 401 (unauthorized), possible cases:
	* Id `MISSING_TOKEN`: The data access token is missing.
	* Id `UNKNOWN_TOKEN`: The specified data access token can't be found.
* 403 (forbidden): The given data access token does not grant permission for this operation. See [data access tokens](//DataTypes#TODO) for more details about tokens and permissions.
* 404 (not found), possible cases:
	* Id `UNKNOWN_CHANNEL`: The activity channel can't be found.
	* Id `UNKNOWN_CONTEXT`: The activity context can't be found in the given channel.
	* Id `UNKNOWN_EVENT`: The event can't be found in the given channel.


## Requests for activity channels

TODO: introductory text.


### GET `/channels`

Gets the activity channels accessible with the given token.

#### Response (JSON)

* `channels` (array of [activity channels](/DataTypes#TODO)): The list of the channels accessible with the given token.
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.


### POST `/channels`

Creates a new activity channel.

#### Post parameters (JSON)

The new channel's data: see [activity channel](/DataTypes#TODO).

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The created channel's id.


### PUT `/channels/<channel id>`

Modifies the activity channel's attributes.

#### Post parameters (JSON)

New values for the channel's fields: see [activity channel](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example


### DELETE `/channels/<channel id>`

Irreversibly deletes the given channel with all the contexts and events it contains. TODO: given the criticality of this operation, make it set an expiration time to data in order to allow undo functionality?


## Requests for activity contexts

TODO: introductory text (previous description moved to DataTypes page)


### GET `/<channel id>/contexts` or `/<channel id>/contexts/<id>`

Gets the contexts accessible with the given token, either from the root level or only descending from the given context.

#### Specific path parameters

* `id`([identity](/DataTypes#TODO)): The id of the context to use as root for the request, or nothing to return all accessible contexts from the root level.

#### Query string parameters

* `includeHidden` (`true` or `false`): Optional. When `true`, contexts that are currently hidden will be included in the result. Default: `false`.
* `timeCountBase` ([timestamp](/DataTypes#TODO)): Optional. If specified, the returned contexts will include the summed duration of all their period events, starting from this timestamp (see `timeCount` in [activity context](/DataTypes#TODO)); otherwise no time count values will be returned.

#### Response (JSON)

* `contexts` (array of [activity contexts](/DataTypes#TODO)): The tree of the contexts accessible with the given token, sorted by name. TODO exemple (with and without time accounting)
* `timeCountBase` ([timestamp](/DataTypes#TODO)): The `timeCountBase` value passed as parameters in the request, for reference.
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.


### POST `/<channel id>/contexts` or `/<channel id>/contexts/<parent context id>`

Creates a new context at the root level or as a child context to the given context.

#### Specific path parameters

* `parentId` ([identity](/DataTypes#TODO)): Optional. The id of the parent context, if any. If not specified, the new context will be created at the root of the contexts tree structure. 

#### Post parameters (JSON)

The new context's data: see [activity context](/DataTypes#TODO).

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The created context's id.


### PUT `/<channel id>/contexts/<context id>`

Modifies the activity context's attributes.

#### Post parameters (JSON)

New values for the context's fields: see [activity context](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example


### POST `/<channel id>/contexts/<context id>/move`

Relocates the activity context in the contexts tree structure.

#### Post parameters (JSON)

* `newParentId` ([identity](/DataTypes#TODO)): The id of the context's new parent, or `null` if the context should be moved at the root of the contexts tree.

#### Specific errors

* 400 (bad request), id `UNKNOWN_CONTEXT`: The given parent context's id is unknown.


### DELETE `/<channel id>/contexts/<context id>`

Irreversibly deletes the context and its possible descendants. If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter `mergeEventsWithParent`.

#### Query string parameters

* `mergeEventsWithParent` (`true` or `false`): Required if the deleted item (or any of its descendants) has linked events, ignored otherwise. If `true`, the linked events will be assigned to the parent of the deleted item; if `false`, the linked events will be deleted.

#### Specific errors

* 400 (bad request), id `MISSING_PARAMETER`: There are events referring to the deleted items and the `mergeEventsWithParent` parameter is missing.


## Requests for activity events

TODO: introductory text (previous description moved to DataTypes page)


### GET `/<channel id>/events`

Queries the list of events.

#### Query string parameters

* `onlyContexts` (array of [identity](/DataTypes#TODO)): Optional. If set, only events linked to those contexts (including child contexts) will be returned. By default, events linked to all accessible contexts are returned.
* `fromTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is 24 hours before the current time.
* `toTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is the current time.
* `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).

#### Response (JSON)

* `events` (array of [activity events](/DataTypes#TODO)): Events ordered by time (see `sortAscending` below).
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.

#### Specific errors

* 400 (bad request), id `UNKNOWN_CONTEXT`: TODO may happen if one of the specified contexts doesn't exist
* 400 (bad request), id `INVALID_TIME`: TODO


### POST `/<channel id>/events`

Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a `events/start` request.

#### Post parameters (JSON)

The new event's data: see [activity event](/DataTypes#TODO).

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The new event's id.
* `stoppedId` ([identity](/DataTypes#TODO)): If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.

#### Specific errors

* 400 (bad request), id `UNKNOWN_CONTEXT`: The specified context cannot be found.


### POST `/<channel id>/events/start`

Starts a new period event, stopping the previously running period event if any. See POST `/<channel id>/events` for details. TODO: detail

#### Specific errors

* 400 (bad request), id `MISSING_CONTEXT`: The mandatory context is missing.
* 400 (bad request), id `INVALID_OPERATION`: A period event cannot start if another period event already exists at a later time.
* 400  (bad request), id `PERIODS_OVERLAP`: TODO (data: array of overlapped ids)


### POST `/<channel id>/events/stop`

Stops the previously running period event. See POST `/<channel id>/events` for details. TODO: detail

#### Response (JSON)

* `stoppedId` ([identity](/DataTypes#TODO)): The id of the previously running period event that was stopped, or null if no running event was found.


### TODO: GET `/<channel id>/events/start` and `.../stop` and `.../record` non-RESTful (TODO: remove references to "REST" for safety) alternatives to the above to allow simple calls via e.g. wget/curl


### GET `/<channel id>/events/running`

Gets the currently running period events.

#### Response (JSON)

* `events` ([activity event](/DataTypes#TODO)): The running period events.
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.


### PUT `/<channel id>/events/<event id>`

Modifies the activity event's attributes.

#### Post parameters (JSON)

New values for the event's fields: see [activity event](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example

#### Response (JSON)

* `stoppedId` ([identity](/DataTypes#TODO)): If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.

#### Specific errors

* 400 (bad request), id `INVALID_OPERATION`: Returned for period events, if attempting to set the event's duration to `undefined` (i.e. still running) while one or more other period events were recorded after it.
* 400 (bad request), id `PERIODS_OVERLAP`: Returned for period events, if attempting to change the event's duration to a value that causes an overlap with one or more subsequent period event(s). TODO format (list of unspecified overlapped event ids, or "too many" if more than 10)


### POST `/<channel id>/events/<event id>/move` TODO: I suggest removing this; now that we switched to independent period events with durations everything should be done with the PUT request

Modifies an event's recorded time.

#### Post parameters

* `newTime` ([timestamp](/DataTypes#TODO)): The new time for the event. This is a server time.
* `deleteOverlappedIds` (array of ([identity](/DataTypes#TODO))): Optional. If the new time period overlaps other events, they will be deleted if their ids are specified here for safety (otherwise an error is returned, see below).

#### Specific errors

* 400 (bad request), id `INVALID_TIME`: The specified new time is not valid.
* 400 (bad request), id `PERIODS_OVERLAP`: Returned for period events, if attempting to change the event's time to a value that causes an overlap with one or more period event(s). TODO format (list of unspecified overlapped event ids, or "too many" if more than 10)


### DELETE `/<channel id>/events/<event id>`

Irreversibly deletes the event.


### POST `/<channel id>/events/batch`

TODO: batch upload events that were recorded by the client while offline. If the client-recorded events overlap events on the server, the request will be rejected (see errors below); it is the client's responsibility to retrieve updated server data and adjust its own before uploading.

#### Post parameters (JSON)

* `events` (array of [activity events](/DataTypes#TODO)): The client-recorded events. The `clientId` must be set for each event. Each event's time must be set in server time.

#### Response (JSON)

* `addedEvents` (array of [activity events](/DataTypes#TODO): The successfully added events, with their server-assigned ids and `clientId` for reference.

#### Specific errors

* 400 (bad request), id `INVALID_TIME`: TODO
* 400 (bad request), id `UNKNOWN_CONTEXT`: TODO
* 400 (bad request), id `PERIODS_OVERLAP`: TODO (list of unspecified overlapped event ids)
