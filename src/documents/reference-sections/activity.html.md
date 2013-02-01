---
doc: reference
sectionId: activity
sectionOrder: 2
---

# Activity methods

TODO: introductory text


## Authorization

All requests for retrieving and manipulating activity data must carry a valid [access token](#data-structure-access) in the HTTP `Authorization` header or, alternatively, in the query string's `auth` parameter.  (You get the token by using one of the [access SDKs](app-access.html), by retrieving it in the [administration](#admin-accesses) or from sharing.)

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

- `400 Bad Request`, id `invalid-request-structure`: The request's structure is not that expected. This can happen e.g. with invalid JSON syntax, or when using an unexpected multipart structure for uploading file attachments.
- `400 Bad Request`, id `invalid-parameters-format`: The request's parameters do not follow the expected format. The error's `data` contains an array of validation errors.
- `401 Unauthorized`, id `invalid-access-token`: The data access token is missing or invalid.
- `403 Forbidden`: The given access token does not grant permission for this operation. See [accesses](#data-structure-access) for more details about accesses and permissions.
- `404 Not Found`, possible cases:
	- Id `unknown-channel`: The activity channel can't be found.
	- Id `unknown-folder`: The activity folder can't be found in the specified channel.
	- Id `unknown-event`: The event can't be found in the specified channel.
	- Id `unknown-attachment`: The attached file can't be found for the specified event.

And a couple of others, related to the status of the user's account:

- `301 Moved`, id `user-account-relocated`: The user has relocated her account to another Pryv server. Both the `Location` header and the error's `data` contain the equivalent URL pointing to the physical server now hosting the user's account. Note that this error can only occur between the moment the account is relocated and the moment your DNS is updated with the new server. So we're stretching the HTTP convention a little, in that the returned URL should not be used permanently (only until `{username}.pryv.io` points to the correct server again). You can decide whether you keep it for the duration of the session (if you have such a thing), for N hours, etc. (TODO: review and detail more if needed)
- `402 Payment Required`, id `user-intervention-required`: We cannot serve the request at the moment, because the user's account has exceeded the limits of its plan. The user must log into Pryv to fix her account.


## Channels

Methods for retrieving and manipulating [channels](#data-structure-channel).


### GET `/channels`

*Socket.IO command id: `channels.get`*

Gets the accessible activity channels (excluding those in the trash).

#### Query string parameters

- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.

#### Successful response: `200 OK`

An array of [activity channels](#data-structure-channel)) containing the accessible channels in the user's account matching the specified state, ordered by name.

#### cURL example

```bash
curl -i https://{username}.pryv.io/channels?auth={access-token}
```


### POST `/channels`

Creates a new activity channel. Only personal accesses allow creating new channels.

#### Body parameters

The new channel's data: see [activity channel](#data-structure-channel). This can be as simple as:
```json
{ "name": "Undercover Activities" }
```

#### Successful response: `201 Created`

- `id` ([identity](#data-structure-identity)): The created channel's id.

#### Specific errors

- `400 Bad Request`, id `invalid-item-id`: Occurs if trying to set the id to an invalid value (e.g. a reserved word like `"null"`).
- `400 Bad Request`, id `item-id-already-exists`: A channel already exists with the same id.
- `400 Bad Request`, id `item-name-already-exists`: A channel already exists with the same name.

#### cURL example

```bash

```


### PUT `/channels/{channel-id}`

Modifies the activity channel's attributes.

#### Body parameters

New values for the channel's fields: see [activity channel](#data-structure-channel). All fields are optional, and only modified values must be included. For example:
```json
{ "clientData": { "new-or-updated-client-specific-metadata": 42 } }
```

#### Successful response: `200 OK`

#### Specific errors

- `400 Bad Request`, id `item-name-already-exists`: A channel already exists with the same name.

#### cURL example

```bash

```


### DELETE `/channels/{channel-id}`

Trashes or deletes the given channel, depending on its current state:

- If the channel is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the channel is already in the trash, it will be irreversibly deleted with all the folders and events it contains.

Only personal accesses allow deleting channels.

#### Successful response: `200 OK`

#### cURL example

```bash

```


## Events

Methods to retrieve and manipulate [events](#data-structure-event).


### GET `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.get`*

Queries accessible events.

#### Query string parameters

- `fromTime` ([timestamp](#data-structure-timestamp)): Optional. The start time of the timeframe you want to retrieve events for. Default is 24 hours before `toTime` if the latter is set; otherwise it is not taken into account.
- `toTime` ([timestamp](#data-structure-timestamp)): Optional. The end time of the timeframe you want to retrieve events for. Default is the current time. Note: events are considered to be within a given timeframe based on their `time` only (`duration` is not considered).
- `onlyFolders` (array of [identity](#data-structure-identity)): Optional. If set, only events assigned to the specified folders and their sub-folders will be returned. To retrieve events that are not assigned to any folder, just include a `null` value in the array. By default, all accessible events are returned (regardless of their folder assignment).
- `tags` (array of strings): Optional. If set, only events assigned to all of the listed tags will be returned.
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `modifiedSince` ([timestamp](#data-structure-timestamp)): Optional. If specified, only events modified since that time will be returned.

#### Successful response: `200 OK`

An array of [activity events](#data-structure-event) containing the accessible events ordered by time (see `sortAscending` above).

#### Specific errors

- `400 Bad Request`, id `unknown-folder`: one (or more) of the specified folders does not exist. The unknown folders' ids are listed as an array in the error's `data.unknownIds`.

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

The new event's data: see [activity event](#data-structure-event).

#### Successful response: `201 Created`

- `id` ([identity](#data-structure-identity)): The new event's id.
- `stoppedId` ([identity](#data-structure-identity)): Only in channels with `enforceNoEventsOverlap`. If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.

#### Specific errors

- `400 Bad Request`, id `unknown-folder`: The specified folder cannot be found.
- `400 Bad Request`, id `invalid-operation`: The channel or specified folder is in the trash, and we prevent the recording of new events into trashed channels / folders. The error's `data.trashed` property indicates either `"channel"` or `"folder"`.
- `400 Bad request`, id `periods-overlap`: Only in channels with `enforceNoEventsOverlap`: the new event overlaps existing period events. The overlapped events' ids are listed as an array in the error's `data.overlappedIds`.

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -X POST -d '{"folderId":"{folder-id}"}' https://{username}.pryv.io/{channel-id}/events?auth={access-token}
```


### POST `/{channel-id}/events/start`

*Socket.IO command id: `{channel-id}.events.start`*

Starts a new period event. In channels with `enforceNoEventsOverlap`, also stops the previously running period event if any. See POST `/{channel-id}/events` for details. TODO: detail

#### Body parameters

See POST `{channel-id}/events`.

#### Successful response: `201 Created`

#### Specific errors

See POST `/{channel-id}/events`.

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -X POST -d '{"folderId":"{folder-id}"}' https://{username}.pryv.io/{channel-id}/events/start?auth={access-token}
```


### POST `/{channel-id}/events/stop`

*Socket.IO command id: `{channel-id}.events.stop`*

Stops a previously running period event. In channels with `enforceNoEventsOverlap`, which guarantee that only one event is running at any given time, that event is automatically determined; for regular channels, the event to stop must be specified.

#### Body parameters

- `id` ([identity](#data-structure-identity)): The id of the event to stop. Optional in channels with `enforceNoEventsOverlap`.
- `time` ([timestamp](#data-structure-timestamp)): Optional. The stop time. Default: now.

#### Successful response: `200 OK`

- `stoppedId` ([identity](#data-structure-identity)): The id of the previously running period event that was stopped, or null if no running event was found.

#### Specific errors

- `400 Bad Request`, id `unknown-event`: The specified event cannot be found.
- `400 Bad Request`, id `invalid-operation`: The specified event is not a running period event.
- `400 Bad Request`, id `missing-parameter`: No event was specified and the channel does not `enforceNoEventsOverlap` (so that there can be more than one running event).

#### cURL example

```bash

```


### TODO: GET `/{channel-id}/events/start` and `.../stop` and `.../record` alternatives to the above to allow simple calls via e.g. wget/curl


### GET `/{channel-id}/events/running`

*Socket.IO command id: `{channel-id}.events.getRunning`*

Gets the currently running period events.

#### Successful response: `200 OK`

An array of [activity events](#data-structure-event) containing the running period events.

#### cURL example

```bash

```


### PUT `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.update`*

Modifies the activity event's attributes.

#### Body parameters

New values for the event's fields: see [activity event](#data-structure-event). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

- `stoppedId` ([identity](#data-structure-identity)): If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.

#### Specific errors

- `400 Bad Request`, id `invalid-operation`: Returned for period events, if attempting to set the event's duration to `undefined` (i.e. still running) while one or more other period events were recorded after it. The error's `data.conflictingPeriodId` provides the id of the closest conflicting event.
- `400 Bad Request`, id `periods-overlap`: Returned for period events, if attempting to change the event's duration to a value that causes an overlap with one or more subsequent period event(s). The overlapped events' ids are listed as an array in the error's `data.overlappedIds`.

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

Batch upload events that were recorded by the client while offline. The submitted events are added in-order, with results returned individually for each (see response below).

#### Body parameters

An array of client-recorded [activity events](#data-structure-event). In addition to the regular properties, each event must have a unique `tempRefId` defined (as it's temporary it must only be unique within the request). Also, make sure that the events' `time` is set in server time (as for single event requests).

#### Successful response: `200 OK`

An object with one property per event submitted holding the result for that event. Each property's name is the submitted event's client id, and its value contains:

- If the event was successful created, an object with the `id` of the event, and possibly the `stoppedId` of the running period event that was stopped as a result. (For details, see POST `/{channel-id}/events`.)
- If there was an error creating the event: an object with an `error` property holding the encountered [error](#data-structure-error).

Example:
```json
{
	"temp_ref_id_1": {"id": "TTMyhYEZriJ"},
	"temp_ref_id_2": {"error": {
		"id": "unknown-folder",
		"message": "Folder 'bad-folder-id' is unknown."
	}}
}
```

#### cURL example

```bash

```


## Folders

Methods to retrieve and manipulate [folders](#data-structure-folder).


### GET `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.get`*

Gets the accessible folders, either from the root level or only descending from a specified parent folder.

#### Query string parameters

- `parentId` ([identity](#data-structure-identity)): Optional. The id of the parent folder to use as root for the request. Default: `null` (returns all accessible folders from the root level).
- `includeHidden` (`true` or `false`): Optional. When `true`, folders that are currently hidden will be included in the result. Default: `false`.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `timeCountBase` ([timestamp](#data-structure-timestamp)): Optional. If specified, the returned folders will include the summed duration of all their period events, starting from this timestamp (see `timeCount` in [activity folder](#data-structure-folder)); otherwise no time count values will be returned.

#### Successful response: `200 OK`

An array of [activity folders](#data-structure-folder) containing the tree of the accessible folders, sorted by name.

#### Specific errors

- `400 Bad Request`, id `unknown-folder`: The specified parent folder can't be found.

TODO: example (with and without time accounting)


#### cURL example

```bash

```


### POST `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.create`*

Creates a new folder at the root level or as a child folder to the specified folder.

#### Body parameters

The new folder's data: see [activity folder](#data-structure-folder).

#### Successful response: `201 Created`

- `id` ([identity](#data-structure-identity)): The created folder's id.

#### Specific errors

- `400 Bad Request`, id `item-id-already-exists`: A folder already exists with the same id.
- `400 Bad Request`, id `item-name-already-exists`: A sibling folder already exists with the same name.
- `400 Bad Request`, id `invalid-item-id`: Occurs if trying to set the id to an invalid value (e.g. a reserved word like `"null"`).


#### cURL example

```bash

```


### PUT `/{channel-id}/folders/{folder-id}`

*Socket.IO command id: `{channel-id}.folders.update`*

Modifies the activity folder's attributes.

#### Body parameters

New values for the folder's fields: see [activity folder](#data-structure-folder). All fields are optional, and only modified values must be included.

TODO: example

#### Successful response: `200 OK`

#### Specific errors

- `400 Bad Request`, id `unknown-folder`: The specified parent folder's id is unknown.
- `400 Bad Request`, id `item-name-already-exists`: A sibling folder already exists with the same name.


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

- `400 Bad Request`, id `missing-parameter`: There are events referring to the deleted items and the `mergeEventsWithParent` parameter is missing.

#### cURL example

```bash

```


## <a id="activity-accesses"></a>Accesses

While full access management is reserved for trusted apps via [methods in the administration](#admin-accesses), any app can retrieve and manage shared accesses depending on its own permissions. All methods here only deal with shared accesses whose permissions are a subset of that linked to the token used for the requests. (You'll get a `403 Forbidden` error if trying to touch other types of accesses, or shared accesses with greater permissions.)


### GET `/accesses`

Gets all manageable shared accesses.

#### Successful response: `200 OK`

An array of [accesses](#data-structure-access) containing all manageable shared accesses in the user's account, ordered by name.

#### cURL example

```bash
curl -i -H "Authorization: {access-token}" https://{username}.pryv.io/accesses
```


### POST `/accesses`

Creates a new shared access. You can only create accesses whose permissions are a subset of those linked to your own access token.

#### Body parameters

The new access's data: see [access](#data-structure-access).

#### Successful response: `201 Created`

- `token` ([identity](#data-structure-identity)): The created access's token.

#### Specific errors

- `400 Bad Request`, id `invalid-item-id`: Occurs if trying to set the token to an invalid value (e.g. a reserved word like `"null"`).

#### cURL example

```bash

```


### PUT `/accesses/{token}`

Modifies the specified shared access. You can only modify accesses whose permissions are a subset of those linked to your own access token.

#### Body parameters

New values for the access's fields: see [access](#data-structure-access). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

#### cURL example

```bash

```


### DELETE `/accesses/{token}`

Deletes the specified shared access. You can only delete accesses whose permissions are a subset of those linked to your own access token.

#### Successful response: `200 OK`

#### cURL example

```bash

```


## <a id="activity-profile-app"></a>App profile

The app profile is a simple key-value store available for your app to keep user settings. It is exposed as a plain object with free structure. The adding/updating/deleting of settings is designed in the expectation that each setting is a key at the profile object's root, but you can structure your profile differently if you wish.


### GET `/profile/app`

Gets your app profile settings.

#### Successful response: `200 OK`

An object containing your app's current profile settings. The method always returns an object (which will be empty if your app never defined any setting).

#### cURL example

```bash

```


### PUT `/profile/app`

Adds, updates or delete settings.

- To add or update a setting, just set its value; for example: `{"keyToAddOrUpdate": "value"}`
- To delete a field, set its value to `null`; for example: `{"keyToDelete": null}`

Settings you don't specify in the update are left untouched.

#### Body parameters

An object with the desired changes to the settings (see above).

#### Successful response: `200 OK`

#### cURL example

```bash

```

