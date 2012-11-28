---
doc: reference
sectionId: activity
sectionOrder: 2
---

# Activity methods

TODO: introductory text


## Authorization

All requests for retrieving and manipulating activity data must carry a valid [access token](#data-types-access) in the HTTP `Authorization` header or, alternatively, in the query string's `auth` parameter.  (You get the token itself either by retrieving it in the [administration](#admin-accesses) or from sharing.)

Here's what a proper request looks like:
```http
GET /{channel-id}/events HTTP/1.1
Host: yacinthe.pryv.io
Authorization: {access-token}
```
Or, alternatively, passing the access token in the query string:
```http
GET /{channel-id}/events?auth={access-token} HTTP/1.1
Host: yacinthe.pryv.io
```

## Common errors

Here are errors commonly returned for requests:

- `400 Bad Request`, id `INVALID_REQUEST_STRUCTURE`: The request's structure is not that expected. This can happen e.g. with invalid JSON syntax, or when using an unexpected multipart structure for uploading file attachments.
- `400 Bad Request`, id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
- `401 Unauthorized`, id `INVALID_ACCESS_TOKEN`: The data access token is missing or invalid.
- `403 Forbidden`: The given access token does not grant permission for this operation. See [accesses](#data-types-access) for more details about accesses and permissions.
- `404 Not Found`, possible cases:
	- Id `UNKNOWN_CHANNEL`: The activity channel can't be found.
	- Id `UNKNOWN_FOLDER`: The activity folder can't be found in the specified channel.
	- Id `UNKNOWN_EVENT`: The event can't be found in the specified channel.
	- Id `UNKNOWN_ATTACHMENT`: The attached file can't be found for the specified event.


## Channels

For retrieving and manipulating [channels](#data-types-channel).


### GET `/channels`

*Socket.IO command id: `channels.get`*

Gets the accessible activity channels (excluding those in the trash).

#### Query string parameters

- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.

#### Successful response: `200 OK`

An array of [activity channels](#data-types-channel)) containing the accessible channels in the user's account matching the specified state, ordered by name.

#### cURL example

```bash
curl -i https://{username}.pryv.io/channels?auth={access-token}
```


### POST `/admin/channels`

Creates a new activity channel. Only personal accesses allow creating new channels.

#### Body parameters

The new channel's data: see [activity channel](#data-types-channel).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created channel's id.

#### Specific errors

- `400 Bad Request`, id `INVALID_ITEM_ID`: Occurs if trying to set the id to an invalid value (e.g. a reserved word like `"null"`).

#### cURL example

```bash

```


### PUT `/admin/channels/{channel-id}`

Modifies the activity channel's attributes.

#### Body parameters

New values for the channel's fields: see [activity channel](#data-types-channel). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

#### cURL example

```bash

```


### DELETE `/admin/channels/{channel-id}`

Trashes or deletes the given channel, depending on its current state:

- If the channel is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the channel is already in the trash, it will be irreversibly deleted with all the folders and events it contains.

Only personal accesses allow deleting channels.

#### Successful response: `200 OK`

#### cURL example

```bash

```


## Events

Methods to retrieve and manipulate [events](#data-types-event).


### GET `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.get`*

Queries accessible events.

#### Query string parameters

- `fromTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is 24 hours before `toTime`, if set.
- `toTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is the current time.
- `onlyFolders` (array of [identity](#data-types-identity)): Optional. If set, only events assigned to the specified folders and their sub-folders will be returned. To retrieve events that are not assigned to any folder, just include a `null` value in the array. By default, all accessible events are returned (regardless of their folder assignment).
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `modifiedSince` ([timestamp](#data-types-timestamp)): Optional. If specified, only events modified since that time will be returned.

#### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the accessible events ordered by time (see `sortAscending` above).

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO may happen if one of the specified folders doesn't exist

#### cURL example

```bash
curl -i https://{username}.pryv.io/{channel-id}/events?auth={access-token}
```


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

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -X POST -d '{"folderId":"{folder-id}"}' https://{username}.pryv.io/{channel-id}/events?auth={access-token}
```


### POST `/{channel-id}/events/start`

*Socket.IO command id: `{channel-id}.events.start`*

Starts a new period event, stopping the previously running period event if any. See POST `/{channel-id}/events` for details. TODO: detail

#### Successful response: `201 Created`

#### Specific errors

- `400 Bad Request`, id `MISSING_FOLDER`: The mandatory folder is missing.
- `400 Bad Request`, id `INVALID_OPERATION`: A period event cannot start if another period event already exists at a later time.
- `400 Bad request`, id `PERIODS_OVERLAP`: TODO (data: array of overlapped ids)

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -X POST -d '{"folderId":"{folder-id}"}' https://{username}.pryv.io/{channel-id}/events/start?auth={access-token}
```


### POST `/{channel-id}/events/stop`

*Socket.IO command id: `{channel-id}.events.stop`*

Stops the previously running period event. See POST `/{channel-id}/events` for details. TODO: detail

#### Successful response: `200 OK`

- `stoppedId` ([identity](#data-types-identity)): The id of the previously running period event that was stopped, or null if no running event was found.

#### cURL example

```bash

```


### TODO: GET `/{channel-id}/events/start` and `.../stop` and `.../record` alternatives to the above to allow simple calls via e.g. wget/curl


### GET `/{channel-id}/events/running`

*Socket.IO command id: `{channel-id}.events.getRunning`*

Gets the currently running period events.

#### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the running period events.

#### cURL example

```bash

```


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

#### cURL example

```bash

```


### POST `/{channel-id}/events/{event-id}`

Adds one or more file attachments to the event. This request expects standard multipart/form-data content, with all content parts being the attached files.

TODO: example

#### Successful response: `200 OK`

#### cURL example

```bash

```


### DELETE `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.delete`*

Trashes or deletes the specified event, depending on its current state:

- If the event is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).

#### Successful response: `200 OK`

#### cURL example

```bash

```


### GET `/{channel-id}/events/{event-id}/{file name}`

Gets the attached file.

#### Successful response: `200 OK`


#### cURL example

```bash

```


### DELETE `/{channel-id}/events/{event-id}/{file name}`

*Socket.IO command id: `{channel-id}.events.deleteAttachedFile`*

Irreversibly deletes the attached file.

#### Successful response: `200 OK`


#### cURL example

```bash

```


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


#### cURL example

```bash

```


## Folders

Methods to retrieve and manipulate [folders](#data-types-folder).


### GET `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.get`*

Gets the accessible folders, either from the root level or only descending from a specified parent folder.

#### Query string parameters

- `parentId` ([identity](#data-types-identity)): Optional. The id of the parent folder to use as root for the request. Default: `null` (returns all accessible folders from the root level).
- `includeHidden` (`true` or `false`): Optional. When `true`, folders that are currently hidden will be included in the result. Default: `false`.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `timeCountBase` ([timestamp](#data-types-timestamp)): Optional. If specified, the returned folders will include the summed duration of all their period events, starting from this timestamp (see `timeCount` in [activity folder](#data-types-folder)); otherwise no time count values will be returned.

#### Successful response: `200 OK`

An array of [activity folders](#data-types-folder) containing the tree of the accessible folders, sorted by name.

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: The specified parent folder can't be found.

TODO: example (with and without time accounting)


#### cURL example

```bash

```


### POST `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.create`*

Creates a new folder at the root level or as a child folder to the specified folder.

#### Body parameters

The new folder's data: see [activity folder](#data-types-folder).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created folder's id.

#### Specific errors

- `400 Bad Request`, id `ITEM_NAME_ALREADY_EXISTS`: A sibling folder already exists with the same name.
- `400 Bad Request`, id `INVALID_ITEM_ID`: Occurs if trying to set the id to an invalid value (e.g. a reserved word like `"null"`).


#### cURL example

```bash

```


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


#### cURL example

```bash

```


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

#### cURL example

```bash

```


## <a id="activity-accesses"></a>Accesses

While full access management is reserved for trusted apps via [methods in the administration](#admin-accesses), any app can retrieve and manage shared accesses depending on its own permissions. All methods here only deal with shared accesses whose permissions are a subset of that linked to the token used for the requests. (You'll get a `403 Forbidden` error if trying to touch other types of accesses, or shared accesses with greater permissions.)


### GET `/admin/accesses`

Gets all manageable shared accesses.

#### Successful response: `200 OK`

An array of [accesses](#data-types-access) containing all manageable shared accesses in the user's account, ordered by name.

#### cURL example

```bash
curl -i -H "Authorization: {access-token}" https://{username}.pryv.io/accesses
```


### POST `/accesses`

Creates a new shared access. You can only create accesses whose permissions are a subset of those linked to your own access token.

#### Body parameters

The new access's data: see [access](#data-types-access).

#### Successful response: `201 Created`

- `token` ([identity](#data-types-identity)): The created access's token.

#### Specific errors

- `400 Bad Request`, id `INVALID_ITEM_ID`: Occurs if trying to set the token to an invalid value (e.g. a reserved word like `"null"`).

#### cURL example

```bash

```


### PUT `/admin/accesses/{token}`

Modifies the specified shared access. You can only modify accesses whose permissions are a subset of those linked to your own access token.

#### Body parameters

New values for the access's fields: see [access](#data-types-access). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

#### cURL example

```bash

```


### DELETE `/admin/accesses/{token}`

Deletes the specified shared access. You can only delete accesses whose permissions are a subset of those linked to your own access token.

#### Successful response: `200 OK`

#### cURL example

```bash

```
