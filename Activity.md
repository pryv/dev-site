# Activity module TODO: update name

TODO: introductory text

## Authentication

All requests to the activity module must carry a valid [data access tokens](/DataAccessTokens) at the root of the resource path. For example:

    GET /<data access token>/types HTTP/1.1
    Host: johndoe.wactiv.com:1234
    Date: Thu, 09 Feb 2012 17:53:58 +0000
    
For the sake of readability, that token is omitted in the resource paths below, but it is assumed to be there. For example, GET `/states` must be understood as GET `/<data access token>/states`.


## Common error codes

TODO: review and complete

* 400 (bad request), code `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
* 403 (forbidden): The given data access token does not grant permission for this operation. TODO: link to explanation about tokens and permissions.
* 404 (not found): Possible cases:
	* Code `UNKNOWN_TOKEN`: The data access token can't be found.
	* Code `UNKNOWN_CHANNEL`: The activity channel can't be found.
	* Code `UNKNOWN_STATE`: The activity state can't be found in the given channel.
	* Code `UNKNOWN_EVENT`: The event can't be found in the given channel.


## Requests for activity channels


### GET `/channels`

Gets the activity channels accessible with the given token.

#### Response (JSON)

* `channels` (array of [channels](/DataTypes#TODO)): The list of the channels accessible with the given token.


### POST `/channels`

Creates a new activity channel.

#### Post parameters (JSON)

The new channel's data: see [activity channel](/DataTypes#TODO).

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The created channel's id.


### POST `/channels/<channel id>/set-info`

TODO: set label, color, payload.
each parameter is optional


### DELETE `/channels/<channel id>`

Irreversibly deletes the given channel with all the states and events it contains. TODO: given the criticality of this operation, make it set an expiration time to data in order to allow undo functionality?


## Requests for activity states

States always belong to an activity channel.


### GET `/<channel id>/states` or `/<channel id>/states/<id>`

Gets the states accessible with the given token, either from the root level or only descending from the given state.

#### Specific path parameters

* `id`([identity](/DataTypes#TODO)): The id of the state to use as root for the request, or nothing to return all accessible states from the root level.

#### Query string parameters

* `includeInactive` (`true` or `false`): Optional. When `true`, inactive states will be included in the result. Default: `false`.
* `timeCountBase` ([timestamp](/DataTypes#TODO)): Optional. If specified, the returned states will include their total time count starting from this timestamp (see `timeCount` in [activity state](/DataTypes#TODO)); otherwise no time count values will be returned.

#### Response (JSON)

* `states` (array of [activity states](/DataTypes#TODO)): The tree of the states accessible with the given token. TODO exemple (with and without time accounting)
* `timeCountBase` ([timestamp](/DataTypes#TODO)): The `timeCountBase` value passed as parameters in the request, for reference.
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.


### POST `/<channel id>/states` or `/<channel id>/states/<parent state id>`

Creates a new state at the root level or as a child state to the given state.

#### Specific path parameters

* `parentId` ([identity](/DataTypes#TODO)): Optional. The id of the parent state, if any. If not specified, the new state will be created at the root of the states tree structure. 

#### Post parameters (JSON)

The new state's data: see [activity state](/DataTypes#TODO).

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The created state's id.


### POST `/<channel id>/states/<state id>/set-info`

TODO: set active state, label, color, payload.
each parameter is optional


### POST `/<channel id>/states/<state id>/move`

TODO

#### Post parameters (JSON)

* `newParentId` ([identity](/DataTypes#TODO)): TODO

#### Response (JSON)

TODO

#### Specific errors

* 400 (bad request), code `UNKNOWN_STATE_ID`: The given parent state's id is unknown.


### DELETE `/<channel id>/states/<state id>`

Irreversibly deletes the state. TODO: will result in adding all activity time to the deleted item's parent. Real deletion may be set with `doNotMergeWithParent`

#### Query string parameters

* `doNotMergeWithParent` (`true` or `false`): Optional. TODO. Default: `false`. 


## Requests for activity events

Like states, events always belong to an activity channel. Events can record state changes or simply "marks" (for punctual events not associated with a state change).


### GET `/<channel id>/events`

Queries the list of events.

#### Query string parameters

* `onlyStates` (array of [identity](/DataTypes#TODO)): Optional. If set, only events linked to those states will be returned. By default, events linked to all accessible states are returned.
* `fromTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is 24 hours before the current time.
* `toTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is the current time.

#### Response (JSON)

* `events` (array of [activity event](/DataTypes#TODO)): Events ordered by time (see `sortAscending` below).
* `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.

#### Specific errors

* 400 (bad request), code `UNKNOWN_STATE_ID`: TODO may happen if one of the specified states doesn't exist
* 400 (bad request), code `INVALID_TIME`: TODO


### POST `/<channel id>/events`

Records a new event.

#### Post parameters (JSON)

The new event's data: see [activity event](/DataTypes#TODO).
Note that the event's `stateId` is set to `null`, the call will be equivalent to POST `/<channel id>/events/stop`.

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The new event's id.

#### Specific errors

* 400 (bad request), code `UNKNOWN_STATE_ID`: The specified state cannot be found.


### POST `/<channel id>/events/stop`

This is an alias to POST `/<channel id>/events` with `stateId` set to `null`. See POST `/<channel id>/events` for details.


### TODO: GET `/<channel id>/events/start` non-RESTful alternative to the above to allow simple calls via e.g. wget


### GET `/<channel id>/events/last-state-change`

Gets the last recorded state change event.

#### Response (JSON)

* `typeId` ([identity](/DataTypes#TODO)): TODO
* `id` ([identity](/DataTypes#TODO)): TODO
* `time` ([timestamp](/DataTypes#TODO)): TODO
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time


### POST `/<channel id>/events/restart`

TODO: remove this? Will clients really need such a method? If they want to provide "restart" functionality, they should already have the necessary info to record the event with the generic method.


### POST `/<channel id>/events/<id>/set-info`

TODO (ex-"edit", renamed for consistency with types)

#### Post parameters (JSON)

* `info` (string): Optional. TODO
* `eventData`([activity event data](/DataTypes#TODO)): Optional. TODO


### POST `/<channel id>/events/<id>/move`

Modifies an event's recorded time.

#### Post parameters

* `newTime` ([timestamp](/DataTypes#TODO)): The new time for the event. This is a server time.

#### Specific errors

* 400 (bad request), code `INVALID_TIME`: The specified new time is not valid.


### POST `/<channel id>/events/<id>/move-period`

Allows to modify multiple state change events at once by adjusting the time period from the specified state change event to the next state change event.

#### Post parameters

* `newStartTime` ([timestamp](/DataTypes#TODO)): Optional. The new time for the event, if modified. This is a server time.
* `nextEndTime` ([timestamp](/DataTypes#TODO)): Optional. The new time for the next state change event, if modified. This is a server time.
* `deleteOverlappedIds` (array of ([identity](/DataTypes#TODO))): Optional. If the new time period overlaps other events, they will be deleted; their ids must be specified here for safety.
* `replaceWithNothing` (`true` or `false`)): Optional. Must be set if the new time period does not contain the original period. If `true`, state change events with state "nothing" will be added to cover parts of the original period not contained in the new period.

#### Specific errors

* 400 (bad request), code `INVALID_EVENT`: The event is not a state change event.
* 400 (bad request), code `INVALID_TIME`: TODO (start, end)
* 400 (bad request), code `EVENTS_OVERLAP`: TODO (list of unspecified overlapped event ids, or "too many" if more than 10)


### POST `/<channel id>/events/batch`

TODO: batch upload events that were recorded by the client while offline.

#### Post parameters (JSON)

* `clientNow` ([timestamp](/DataTypes#TODO)): TODO make clear that the date reference is the client's. Used to calculate the *time delta* to apply to server time for the given events.  See also start and end times for events below.
* `events`: Array of client-recorded events with the following structure:
	* `stateId` ([identity](/DataTypes#TODO)): Optional. The event's state id. TODO: explain "stop" (ie "0") + same warning on ignoring other data
	* `clientId` ([identity](/DataTypes#TODO)): Temporarily event id assigned by the client; used as reference in the request's response (see below).
	* `clientTime` ([timestamp](/DataTypes#TODO)): The event's time as recorded by the client.
	* `info` (string): Optional. TODO
    * `eventData`([activity event data](/DataTypes#TODO)): Optional. TODO
* `deleteOverlappedIds` (array of ([identity](/DataTypes#TODO))): Optional. If the specified events include state change events that overlap previously recorded state change events, the latter will be deleted; their ids must be specified here for safety.

#### Response (JSON)

TODO: review this

* `addedEvents`: Array of event information for successfully added events, with the following structure:
	* `clientId` ([identity](/DataTypes#TODO)): Client-assigned event id for reference.
	* `id` ([identity](/DataTypes#TODO)): The added event's id as allocated by the server.
	* `impactedEvents`: Array of previously recorded events impacted by the added event. TODO: clarify... for each: id, stateBefore (startTime, endTime), stateAfter (startTime, endTime)
* `rejectedEvents`: Array of event information for events that could not be added, with the following structure:
	* `clientId` ([identity](/DataTypes#TODO)): Client-assigned event id for reference.
	* `errorCode`: (TODO: review this, checking consistency with regular request errors...) One of `InvalidActivityTypeId`, `InvalidTime`, `InvalidParametersFormat` (TODO: I (SG) think such errors should cause the entire request to be rejected)
	* `errorMessage`: TODO should indicate e.g. whether start is invalid (review after the above is cleaned up)
