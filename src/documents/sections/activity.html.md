---
sectionId: activity
sectionOrder: 2
---

# Activity methods

TODO: introductory text


## Authorization

All requests for retrieving and manipulating activity data must carry a valid [data access token](#data-types-token) in the HTTP `Authorization` header. (You get the token itself either by retrieving it in the [administration](#admin-tokens) or from sharing.)

Here's what a proper request looks like:
```http
GET /{channel-id}/events HTTP/1.1
Host: yacinthe.pryv.io
Authorization: {valid-token}
```


## Common HTTP headers

Some headers are included in every response to authorized requests:

- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.


## Common errors

Here are errors commonly returned for requests:

- `400 Bad Request`, id `INVALID_REQUEST_STRUCTURE`: The request's structure is not that expected. This can happen e.g. with invalid JSON syntax, or when using an unexpected multipart structure for uploading file attachments.
- `400 Bad Request`, id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
- `401 Unauthorized`, id `INVALID_TOKEN`: The data access token is missing or invalid.
- `403 Forbidden`: The given data access token does not grant permission for this operation. See [data access tokens](#data-types-token) for more details about tokens and permissions.
- `404 Not Found`, possible cases:
	- Id `UNKNOWN_CHANNEL`: The activity channel can't be found.
	- Id `UNKNOWN_FOLDER`: The activity folder can't be found in the specified channel.
	- Id `UNKNOWN_EVENT`: The event can't be found in the specified channel.
	- Id `UNKNOWN_ATTACHMENT`: The attached file can't be found for the specified event.


## Channels

For retrieving [channels](#data-types-channel). Manipulating channels is done in the [administration](#admin-channels).


### GET `/channels`

*Socket.IO command id: `channels.get`*

Gets the activity channels accessible with the given token (and that are not in the trash).

#### Successful response: `200 OK`

An array of [activity channels](#data-types-channel) containing the channels accessible with the given token.


## Folders

Methods to retrieve and manipulate [folders](#data-types-folder).


### GET `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.get`*

Gets the folders accessible with the given token, either from the root level or only descending from a specified parent folder.

#### Query string parameters

- `parentId` ([identity](#data-types-identity)): The id of the parent folder to use as root for the request, or nothing to return all accessible folders from the root level.
- `includeHidden` (`true` or `false`): Optional. When `true`, folders that are currently hidden will be included in the result. Default: `false`.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `timeCountBase` ([timestamp](#data-types-timestamp)): Optional. If specified, the returned folders will include the summed duration of all their period events, starting from this timestamp (see `timeCount` in [activity folder](#data-types-folder)); otherwise no time count values will be returned.

#### Successful response: `200 OK`

An array of [activity folders](#data-types-folder) containing the tree of the folders accessible with the given token, sorted by name.

TODO: example (with and without time accounting)


### POST `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.create`*

Creates a new folder at the root level or as a child folder to the specified folder.

#### Body parameters

The new folder's data: see [activity folder](#data-types-folder).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created folder's id.

#### Specific errors

- `400 Bad Request`, id `ITEM_NAME_ALREADY_EXISTS`: A sibling folder already exists with the same name.


### PUT `/{channel-id}/folders/{folder-id}`

*Socket.IO command id: `{channel-id}.folders.update`*

Modifies the activity folder's attributes.

#### Body parameters

New values for the folder's fields: see [activity folder](#data-types-folder). All fields are optional, and only modified values must be included.

TODO: example

#### Successful response: `200 OK`

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: The specified parent folder's id is unknown.
- `400 Bad Request`, id `ITEM_NAME_ALREADY_EXISTS`: A sibling folder already exists with the same name.


### DELETE `/{channel-id}/folders/{folder-id}`

*Socket.IO command id: `{channel-id}.folders.delete`*

Trashes or deletes the specified folder, depending on its current state:

- If the folder is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the folder is already in the trash, it will be irreversibly deleted with its possible descendants. If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter `mergeEventsWithParent`..

#### Query string parameters

- `mergeEventsWithParent` (`true` or `false`): Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If `true`, the linked events will be assigned to the parent of the deleted item; if `false`, the linked events will be deleted.

#### Successful response: `200 OK`

#### Specific errors

- `400 Bad Request`, id `MISSING_PARAMETER`: There are events referring to the deleted items and the `mergeEventsWithParent` parameter is missing.


## Events

Methods to retrieve and manipulate [events](#data-types-event).


### GET `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.get`*

Queries the list of events.

#### Query string parameters

- `onlyFolders` (array of [identity](#data-types-identity)): Optional. If set, only events linked to those folders (including child folders) will be returned. By default, events linked to all accessible folders are returned.
- `fromTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is 24 hours before `toTime`, if set.
- `toTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is the current time.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `modifiedSince` ([timestamp](#data-types-timestamp)): Optional. If specified, only events modified since that time will be returned.

#### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the events ordered by time (see `sortAscending` below).

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO may happen if one of the specified folders doesn't exist


### POST `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.create`*

Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a `events/start` request.

In addition to the usual JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.

TODO: example

#### Body parameters

The new event's data: see [activity event](#data-types-event).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The new event's id.
- `stoppedId` ([identity](#data-types-identity)): If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: The specified folder cannot be found.


### POST `/{channel-id}/events/start`

*Socket.IO command id: `{channel-id}.events.start`*

Starts a new period event, stopping the previously running period event if any. See POST `/{channel-id}/events` for details. TODO: detail

#### Successful response: `201 Created`

#### Specific errors

- `400 Bad Request`, id `MISSING_FOLDER`: The mandatory folder is missing.
- `400 Bad Request`, id `INVALID_OPERATION`: A period event cannot start if another period event already exists at a later time.
- `400 Bad request`, id `PERIODS_OVERLAP`: TODO (data: array of overlapped ids)


### POST `/{channel-id}/events/stop`

*Socket.IO command id: `{channel-id}.events.stop`*

Stops the previously running period event. See POST `/{channel-id}/events` for details. TODO: detail

#### Successful response: `200 OK`

- `stoppedId` ([identity](#data-types-identity)): The id of the previously running period event that was stopped, or null if no running event was found.


### TODO: GET `/{channel-id}/events/start` and `.../stop` and `.../record` alternatives to the above to allow simple calls via e.g. wget/curl


### GET `/{channel-id}/events/running`

*Socket.IO command id: `{channel-id}.events.getRunning`*

Gets the currently running period events.

#### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the running period events.


### PUT `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.update`*

Modifies the activity event's attributes.

#### Body parameters

New values for the event's fields: see [activity event](#data-types-event). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

- `stoppedId` ([identity](#data-types-identity)): If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.

#### Specific errors

- `400 Bad Request`, id `INVALID_OPERATION`: Returned for period events, if attempting to set the event's duration to `undefined` (i.e. still running) while one or more other period events were recorded after it.
- `400 Bad Request`, id `PERIODS_OVERLAP`: Returned for period events, if attempting to change the event's duration to a value that causes an overlap with one or more subsequent period event(s). TODO format (list of unspecified overlapped event ids, or "too many" if more than 10)


### POST `/{channel-id}/events/{event-id}`

Adds one or more file attachments to the event. This request expects standard multipart/form-data content, with all content parts being the attached files.

TODO: example

#### Successful response: `200 OK`


### DELETE `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.delete`*

Trashes or deletes the specified event, depending on its current state:

- If the event is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).

#### Successful response: `200 OK`


### GET `/{channel-id}/events/{event-id}/{file-name}`

Gets the attached file.

#### Successful response: `200 OK`


### DELETE `/{channel-id}/events/{event-id}/{file-name}`

*Socket.IO command id: `{channel-id}.events.deleteAttachedFile`*

Irreversibly deletes the attached file.

#### Successful response: `200 OK`


### POST `/{channel-id}/events/batch`

TODO: this is currently unimplemented and may stay that way.
Batch upload events that were recorded by the client while offline. If the client-recorded events overlap events on the server, the request will be rejected (see errors below); it is the client's responsibility to retrieve updated server data and adjust its own before uploading.

#### Body parameters

- `events` (array of [activity events](#data-types-event)): The client-recorded events. The `clientId` must be set for each event. Each event's time must be set in server time.

#### Successful response: `200 OK`

- `addedEvents` (array of [activity events](#data-types-event): The successfully added events, with their server-assigned ids and `clientId` for reference.

#### Specific errors

- `400 Bad Request`, id `INVALID_TIME`: TODO
- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO
- `400 Bad Request`, id `PERIODS_OVERLAP`: TODO (list of unspecified overlapped event ids)
