---
sectionId: activity
sectionOrder: 2
---

# Activity service

TODO: introductory text


### <a id="activity-activity-socketio"></a>Socket.IO support

The activity service supports real-time interaction with [Socket.IO](http://socket.io), both by accepting equivalent messages for most API methods and by emitting data change notification messages. (Code examples below are in Javascript.)


#### Calling API methods

Every method in the activity service can be called by sending a corresponding Socket.IO `command` message, providing a data object specifying the command (or method) and possible parameters, and a callback function for the response:
```javascript
socket.emit('command', {id: '{id}', params: {/*parameters*/}}, function (error, data) {
  // handle response here
});
```

Command ids are indicated for each API method below and are modeled after the equivalent URL path. For example, here's how you could call `GET /{channel-id}/events`:
 ```javascript
var cmdData = {
  id: '{channel-id}.events.get',
  params: {
    sortAscending: true
  }
};
socket.emit('command', cmdData, function (error, data) {
  // handle response
});
 ```


#### Receiving data change notifications

You can be notified of changes to channels, folders and events by subscribing to the corresponding messages `channelsChanged`, `foldersChanged` and `eventsChanged`. For example:
```javascript
socket.on('eventsChanged', function() {
  // retrieve latest changes and update views
});
```

## <a id="activity-activity"></a>Activity data

TODO: introductory text


### Authorization

All requests for retrieving and manipulating activity data must carry a valid [data access token](#data-types-token) in the HTTP `Authorization` header. (You get the token itself either by retrieving it in the [administration](#activity-admin-tokens) or from sharing.)

Here's what a proper request looks like:
```http
GET /{channel-id}/events HTTP/1.1
Host: yacinthe.pryv.io
Authorization: {valid-token}
```


### Common HTTP headers

Some headers are included in every response to authorized requests:

- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.


### Common errors

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


### Channels

For retrieving [channels](#data-types-channel). Manipulating channels is done in the [administration](#activity-admin-channels).


#### GET `/channels`

*Socket.IO command id: `channels.get`*

Gets the activity channels accessible with the given token (and that are not in the trash).

##### Successful response: `200 OK`

An array of [activity channels](#data-types-channel) containing the channels accessible with the given token.


### Folders

Methods to retrieve and manipulate [folders](#data-types-folder).


#### GET `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.get`*

Gets the folders accessible with the given token, either from the root level or only descending from a specified parent folder.

##### Query string parameters

- `parentId` ([identity](#data-types-identity)): The id of the parent folder to use as root for the request, or nothing to return all accessible folders from the root level.
- `includeHidden` (`true` or `false`): Optional. When `true`, folders that are currently hidden will be included in the result. Default: `false`.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `timeCountBase` ([timestamp](#data-types-timestamp)): Optional. If specified, the returned folders will include the summed duration of all their period events, starting from this timestamp (see `timeCount` in [activity folder](#data-types-folder)); otherwise no time count values will be returned.

##### Successful response: `200 OK`

An array of [activity folders](#data-types-folder) containing the tree of the folders accessible with the given token, sorted by name.

TODO: example (with and without time accounting)


#### POST `/{channel-id}/folders`

*Socket.IO command id: `{channel-id}.folders.create`*

Creates a new folder at the root level or as a child folder to the specified folder.

##### Body parameters

The new folder's data: see [activity folder](#data-types-folder).

##### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created folder's id.

##### Specific errors

- `400 Bad Request`, id `ITEM_NAME_ALREADY_EXISTS`: A sibling folder already exists with the same name.


#### PUT `/{channel-id}/folders/{folder-id}`

*Socket.IO command id: `{channel-id}.folders.update`*

Modifies the activity folder's attributes.

##### Body parameters

New values for the folder's fields: see [activity folder](#data-types-folder). All fields are optional, and only modified values must be included.

TODO: example

##### Successful response: `200 OK`

##### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: The specified parent folder's id is unknown.
- `400 Bad Request`, id `ITEM_NAME_ALREADY_EXISTS`: A sibling folder already exists with the same name.


#### DELETE `/{channel-id}/folders/{folder-id}`

*Socket.IO command id: `{channel-id}.folders.delete`*

Trashes or deletes the specified folder, depending on its current state:

- If the folder is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the folder is already in the trash, it will be irreversibly deleted with its possible descendants. If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter `mergeEventsWithParent`..

##### Query string parameters

- `mergeEventsWithParent` (`true` or `false`): Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If `true`, the linked events will be assigned to the parent of the deleted item; if `false`, the linked events will be deleted.

##### Successful response: `200 OK`

##### Specific errors

- `400 Bad Request`, id `MISSING_PARAMETER`: There are events referring to the deleted items and the `mergeEventsWithParent` parameter is missing.


### Events

Methods to retrieve and manipulate [events](#data-types-event).


#### GET `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.get`*

Queries the list of events.

##### Query string parameters

- `onlyFolders` (array of [identity](#data-types-identity)): Optional. If set, only events linked to those folders (including child folders) will be returned. By default, events linked to all accessible folders are returned.
- `fromTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is 24 hours before `toTime`, if set.
- `toTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is the current time.
- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `modifiedSince` ([timestamp](#data-types-timestamp)): Optional. If specified, only events modified since that time will be returned.

##### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the events ordered by time (see `sortAscending` below).

##### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO may happen if one of the specified folders doesn't exist


#### POST `/{channel-id}/events`

*Socket.IO command id: `{channel-id}.events.create`*

Records a new event. Events recorded this way must be completed events, i.e. either period events with a known duration or mark events. To start a running period event, post a `events/start` request.

In addition to the usual JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.

TODO: example

##### Body parameters

The new event's data: see [activity event](#data-types-event).

##### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The new event's id.
- `stoppedId` ([identity](#data-types-identity)): If set, indicates the id of the previously running period event that was stopped as a consequence of inserting the new event.

##### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: The specified folder cannot be found.


#### POST `/{channel-id}/events/start`

*Socket.IO command id: `{channel-id}.events.start`*

Starts a new period event, stopping the previously running period event if any. See POST `/{channel-id}/events` for details. TODO: detail

##### Successful response: `201 Created`

##### Specific errors

- `400 Bad Request`, id `MISSING_FOLDER`: The mandatory folder is missing.
- `400 Bad Request`, id `INVALID_OPERATION`: A period event cannot start if another period event already exists at a later time.
- `400 Bad request`, id `PERIODS_OVERLAP`: TODO (data: array of overlapped ids)


#### POST `/{channel-id}/events/stop`

*Socket.IO command id: `{channel-id}.events.stop`*

Stops the previously running period event. See POST `/{channel-id}/events` for details. TODO: detail

##### Successful response: `200 OK`

- `stoppedId` ([identity](#data-types-identity)): The id of the previously running period event that was stopped, or null if no running event was found.


#### TODO: GET `/{channel-id}/events/start` and `.../stop` and `.../record` alternatives to the above to allow simple calls via e.g. wget/curl


#### GET `/{channel-id}/events/running`

*Socket.IO command id: `{channel-id}.events.getRunning`*

Gets the currently running period events.

##### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the running period events.


#### PUT `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.update`*

Modifies the activity event's attributes.

##### Body parameters

New values for the event's fields: see [activity event](#data-types-event). All fields are optional, and only modified values must be included. TODO: example

##### Successful response: `200 OK`

- `stoppedId` ([identity](#data-types-identity)): If set, indicates the id of the previously running period event that was stopped as a consequence of modifying the event.

##### Specific errors

- `400 Bad Request`, id `INVALID_OPERATION`: Returned for period events, if attempting to set the event's duration to `undefined` (i.e. still running) while one or more other period events were recorded after it.
- `400 Bad Request`, id `PERIODS_OVERLAP`: Returned for period events, if attempting to change the event's duration to a value that causes an overlap with one or more subsequent period event(s). TODO format (list of unspecified overlapped event ids, or "too many" if more than 10)


#### POST `/{channel-id}/events/{event-id}`

Adds one or more file attachments to the event. This request expects standard multipart/form-data content, with all content parts being the attached files.

TODO: example

##### Successful response: `200 OK`


#### DELETE `/{channel-id}/events/{event-id}`

*Socket.IO command id: `{channel-id}.events.delete`*

Trashes or deletes the specified event, depending on its current state:

- If the event is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).

##### Successful response: `200 OK`


#### GET `/{channel-id}/events/{event-id}/{file-name}`

Gets the attached file.

##### Successful response: `200 OK`


#### DELETE `/{channel-id}/events/{event-id}/{file-name}`

*Socket.IO command id: `{channel-id}.events.deleteAttachedFile`*

Irreversibly deletes the attached file.

##### Successful response: `200 OK`


#### POST `/{channel-id}/events/batch`

TODO: this is currently unimplemented and may stay that way.
Batch upload events that were recorded by the client while offline. If the client-recorded events overlap events on the server, the request will be rejected (see errors below); it is the client's responsibility to retrieve updated server data and adjust its own before uploading.

##### Body parameters

- `events` (array of [activity events](#data-types-event)): The client-recorded events. The `clientId` must be set for each event. Each event's time must be set in server time.

##### Successful response: `200 OK`

- `addedEvents` (array of [activity events](#data-types-event): The successfully added events, with their server-assigned ids and `clientId` for reference.

##### Specific errors

- `400 Bad Request`, id `INVALID_TIME`: TODO
- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO
- `400 Bad Request`, id `PERIODS_OVERLAP`: TODO (list of unspecified overlapped event ids)



## <a id="activity-admin"></a>Administration

**TODO: review (there are mistakes) and possibly relocate the sections below**

The administration service handles user's:

- Identity and profile settings
- Channels and folders organisation
- Sharing management

The Administration server is a part of an AAServer, which also handle activity recording.

[TOC]

### HOSTNAMES
They are several independants Administration/Activity servers (AAServer), they all have a static hostname: **xyz.pryv.net**. [TODO: I think this shouldn't be here; external people don't need to know that. Comment also applies below...]

Each of them have also dynamic hostnames, one for each user they serve: **username.pryv.io**.

To access a user's ressource you should use `https://username.pryv.io/ressource_path`
But the protocol also supports `https://xyz.pryv.net/ressource_path?userName=username` [TODO: ??? clarify]

**Note:** Arguments will override hostnames. In the following case, **username2** will be used. `https://username1.pryv.io/ressource_path?userName=username2`

**See:** [Register module: https://pryv.io/{user-name}/server](Register#server) API call to get the server hostname for a user.

### WEB access

#### Administration login page

`https://username.pryv.io` presents the administration login page. If you known the server *.pryv.net (xyz) hostname, it can also be obtained with `https://xyz.pryv.net/?userName=username`

#### Confirm Success

`https://xyz.pryv.io/?msg=CONFIRMED` presents the administration login page with a registration "confirmed" message.

`https://xyz.pryv.io/?msg=CONFIRMED_ALREADY` presents the administration login page with an "registration already confirmed" message.


### Authorization

Access to admin methods is managed by sessions. To create a session, you must successfully authenticate with a `/admin/login` request, which will return the session ID. Each request sent during the duration of the session must then contain the session ID in its `Authorization` header. The session is terminated when `/admin/logout` is called or when the session times out (TODO: indicate session timeout delay).

Here's what an admin request (with a session open) looks like:
```http
GET /admin/channels HTTP/1.1
Host: cassis.pryv.io
Authorization: {session-id}
```


### Common HTTP headers

- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.


### Common error codes

TODO: review and complete

- `400 Bad Request`, id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
- 401 (unauthorized), id `INVALID_CREDENTIALS`: User credentials are missing or invalid.
- 404 (not found), possible cases:
	- Id `UNKNOWN_TOKEN`: The data access token can't be found.
	- Id `UNKNOWN_CHANNEL`: The activity channel can't be found.



### <a id="activity-admin-session"></a>Session management


#### POST `/admin/login`

Opens a new admin session, authenticating with the provided credentials. TODO: possible support for OAuth/OpenID/BrowserID (for now, only local credentials are supported).

##### Body parameters

- `userName` (string)
- `password` (string)

##### Successful response: `200 OK`

- `sessionID` (string): The newly created session's ID, to include in each subsequent request's `Authorization` header.


#### POST `/admin/logout`

Terminates the admin session.

##### Successful response: `200 OK`


### <a id="activity-admin-user"></a>User information


#### GET `/admin/user-info`

TODO: get user informations
Requires session token.

##### Successful response: `200 OK`

TODO: email, display name, language, ...


#### PUT `/admin/user-info`

TODO: change user information


#### POST `/admin/change-password`

TODO: change user password
Requires session token, old password, new password.

##### Specific errors

TODO: `WRONG_PASSWORD`, `INVALID_NEW_PASSWORD`


### <a id="activity-admin-channels"></a>Channels

TODO: introductory text.


#### GET `/admin/channels`

Gets activity channels.

##### Query string parameters

- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.

##### Successful response: `200 OK`

An array of [activity channels](#data-types-channel)) containing all channels in the user's account matching the specified state, ordered by name.


#### POST `/admin/channels`

Creates a new activity channel.

##### Body parameters

The new channel's data: see [activity channel](#data-types-channel).

##### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created channel's id.


#### PUT `/admin/channels/{channel-id}`

Modifies the activity channel's attributes.

##### Body parameters

New values for the channel's fields: see [activity channel](#data-types-channel). All fields are optional, and only modified values must be included. TODO: example

##### Successful response: `200 OK`


#### DELETE `/admin/channels/{channel-id}`

Trashes or deletes the given channel, depending on its current state:

- If the channel is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the channel is already in the trash, it will be irreversibly deleted with all the folders and events it contains.

##### Successful response: `200 OK`


### <a id="activity-admin-tokens"></a>Tokens

TODO: introductory text


#### POST `/admin/get-my-token`

Gets the identifier of the personal token your app should use when accessing the user's data on her behalf. The token is created if it is the first time your app requests it.

##### Body parameters

- `applicationId` (string): A URL-friendly name uniquely identifying your app. The name you provide is always slugified before use (see [how](https://github.com/dodo/node-slug/blob/master/src/slug.coffee) - CoffeeScript code).

##### Successful response: `200 OK`

- `id` ([identity](#data-types-identity)): Your app's dedicated personal [token](#data-types-token) identifier.


#### GET `/admin/tokens`

Gets all accessible access tokens, which are the shared tokens. (Your private app token identifier is retrieved with `POST /admin/get-my-token`.)

##### Successful response: `200 OK`

An array of [access tokens](#data-types-token) containing all accessible access tokens in the user's account, ordered by name.


#### PUT `/admin/tokens/{token-id}`

Modifies the specified shared token. TODO.


#### DELETE `/admin/tokens/{token-id}`

Deletes the specified shared token. TODO.
