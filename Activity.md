# Activity module TODO: update name

TODO: introductory text

## Authentication

All requests to the activity module must carry a valid [data access token](//DataTypes#TODO) at the root of the resource path. For example:

    GET /<data access token>/types HTTP/1.1
    Host: johndoe.wactiv.com:1234
    Date: Thu, 09 Feb 2012 17:53:58 +0000
    
For the sake of readability, that token is omitted in the resource paths below, but it is assumed to be there. For example, GET `/states` must be understood as GET `/<data access token>/states`.


## Common error codes

TODO: review and complete

* 400 (bad request), id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
* 401 (unauthorized): The data access token is missing or invalid.
* 403 (forbidden): The given data access token does not grant permission for this operation. TODO: link to explanation about tokens and permissions.
* 404 (not found): Possible cases:
	* Id `UNKNOWN_TOKEN`: The data access token can't be found.
	* Id `UNKNOWN_CHANNEL`: The activity channel can't be found.
	* Id `UNKNOWN_STATE`: The activity state can't be found in the given channel.
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


### POST `/channels/<channel id>/set-info`

Modifies the activity channel's attributes.

#### Post parameters (JSON)

New values for the channel's fields: see [activity channel](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example


### DELETE `/channels/<channel id>`

Irreversibly deletes the given channel with all the states and events it contains. TODO: given the criticality of this operation, make it set an expiration time to data in order to allow undo functionality?


## Requests for activity states

TODO: introductory text (previous description moved to DataTypes page)


### GET `/<channel id>/states` or `/<channel id>/states/<id>`

Gets the states accessible with the given token, either from the root level or only descending from the given state.

#### Specific path parameters

* `id`([identity](/DataTypes#TODO)): The id of the state to use as root for the request, or nothing to return all accessible states from the root level.

#### Query string parameters

* `includeHidden` (`true` or `false`): Optional. When `true`, states that are currently hidden will be included in the result. Default: `false`.
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

Modifies the activity state's attributes.

#### Post parameters (JSON)

New values for the state's fields: see [activity state](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example


### POST `/<channel id>/states/<state id>/move`

Relocates the activity state in the states tree structure.

#### Post parameters (JSON)

* `newParentId` ([identity](/DataTypes#TODO)): The id of the state's new parent, or `null` if the state should be moved at the root of the states tree.

#### Specific errors

* 400 (bad request), id `UNKNOWN_STATE_ID`: The given parent state's id is unknown.


### DELETE `/<channel id>/states/<state id>`

Irreversibly deletes the state. TODO: will result in adding all activity time to the deleted item's parent. Real deletion may be set with `doNotMergeWithParent`

#### Query string parameters

* `doNotMergeWithParent` (`true` or `false`): Optional. TODO. Default: `false`. 


## Requests for activity events

TODO: introductory text (previous description moved to DataTypes page)

### GET `/<channel id>/events`

Queries the list of events.

#### Query string parameters

* `onlyStates` (array of [identity](/DataTypes#TODO)): Optional. If set, only events linked to those states will be returned. By default, events linked to all accessible states are returned.
* `fromTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is 24 hours before the current time.
* `toTime` ([timestamp](/DataTypes#TODO)): Optional. TODO. Default is the current time.

#### Response (JSON)

* `events` (array of [activity events](/DataTypes#TODO)): Events ordered by time (see `sortAscending` below).
* `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.

#### Specific errors

* 400 (bad request), id `UNKNOWN_STATE_ID`: TODO may happen if one of the specified states doesn't exist
* 400 (bad request), id `INVALID_TIME`: TODO


### POST `/<channel id>/events`

Records a new event.

#### Post parameters (JSON)

The new event's data: see [activity event](/DataTypes#TODO).
Note that if the event's `stateId` is set to `null`, the call will be equivalent to POST `/<channel id>/events/stop`.

#### Response (JSON)

* `id` ([identity](/DataTypes#TODO)): The new event's id.

#### Specific errors

* 400 (bad request), id `UNKNOWN_STATE_ID`: The specified state cannot be found.


### POST `/<channel id>/events/stop`

This is an alias to POST `/<channel id>/events` with `stateId` set to `null`. See POST `/<channel id>/events` for details.


### TODO: GET `/<channel id>/events/start` non-RESTful alternative to the above to allow simple calls via e.g. wget


### GET `/<channel id>/events/last-change`

Gets the last recorded state change event.

#### Response (JSON)

* `event` ([activity event](/DataTypes#TODO)): The requested event.
* `serverNow`([timestamp](/DataTypes#TODO)): The current server time.


### POST `/<channel id>/events/cancel-last-change`

Cancels the last recorded state change event, in effect proceeding with the previously active state.

#### Post parameters (JSON)

* `resumeStateId` ([identity](/DataTypes#TODO)): The id of the previously active state that will be resumed, for control purpose.

#### Specific errors

* 400 (bad request), id `INVALID_STATE`: The specified state id does not match the previously active state.


### POST `/<channel id>/events/<id>/set-info`

Modifies the activity event's attributes.

#### Post parameters (JSON)

New values for the event's fields: see [activity event](/DataTypes#TODO). All fields are optional, and only modified values must be included. TODO: example


### POST `/<channel id>/events/<id>/move-mark`

Modifies a mark event's recorded time. To move state change events, use `move-change`.

#### Post parameters

* `newTime` ([timestamp](/DataTypes#TODO)): The new time for the event. This is a server time.

#### Specific errors

* 400 (bad request), id `INVALID_TIME`: The specified new time is not valid.


### POST `/<channel id>/events/<id>/move-change`

Allows to modify multiple state change events at once by adjusting the time period from the specified state change event to the next state change event.

#### Post parameters

* `newStartTime` ([timestamp](/DataTypes#TODO)): Optional. The new time for the event, if modified. This is a server time.
* `nextEndTime` ([timestamp](/DataTypes#TODO)): Optional. The new time for the next state change event, if modified. This is a server time.
* `deleteOverlappedIds` (array of ([identity](/DataTypes#TODO))): Optional. If the new time period overlaps other events, they will be deleted; their ids must be specified here for safety.
* `replaceWithNothing` (`true` or `false`)): Optional. Must be set if the new time period does not contain the original period. If `true`, state change events with state "nothing" will be added to cover parts of the original period not contained in the new period.

#### Specific errors

* 400 (bad request), id `INVALID_EVENT`: The event is not a state change event.
* 400 (bad request), id `INVALID_TIME`: TODO (start, end)
* 400 (bad request), id `EVENTS_OVERLAP`: TODO (list of unspecified overlapped event ids, or "too many" if more than 10)


### POST `/<channel id>/events/batch`

TODO: batch upload events that were recorded by the client while offline. If the client-recorded events overlap events on the server, the request will be rejected (see errors below); the client must sync its

#### Post parameters (JSON)

* `clientNow` ([timestamp](/DataTypes#TODO)): TODO make clear that the date reference is the client's. Used to calculate the *time delta* to apply to server time for the given events.  See also start and end times for events below.
* `events` (array of [activity events](/DataTypes#TODO)): The client-recorded events. The `clientId` must be set for each event.
* `deleteOverlappedIds` (array of ([identity](/DataTypes#TODO))): Optional. If periods specified by client-recorded state change events overlap existing state change events on the server, they will be deleted; their ids must be specified here for safety.


#### Response (JSON)

* `addedEvents` (array of [activity events](/DataTypes#TODO): The successfully added events, with their server-assigned ids and `clientId` for reference.

#### Specific errors

* 400 (bad request), id `INVALID_TIME`: TODO
* 400 (bad request), id `UNKNOWN_STATE_ID`: TODO
* 400 (bad request), id `EVENTS_OVERLAP`: TODO (list of unspecified overlapped event ids, or "too many" if more than 10)
