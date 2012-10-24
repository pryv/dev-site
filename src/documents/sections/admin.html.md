---
sectionId: admin
sectionOrder: 3
---

# Administration methods

Administration methods allow to manage the user's [account information](#admin-user), [activity channels](#admin-channels) and [sharing](#admin-accesses) (via accesses).


## Authorization

Access to admin methods is managed by sessions. To create a session, you must successfully authenticate with a `/admin/login` request, which will return the session ID. Each request sent during the duration of the session must then contain the session ID in its `Authorization` header. The session is terminated when `/admin/logout` is called or when the session times out (TODO: indicate session timeout delay).

Here's what an admin request (with a session open) looks like:
```http
GET /admin/channels HTTP/1.1
Host: cassis.pryv.io
Authorization: {session-id}
```


## Common HTTP headers

- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.


## Common errors

TODO: review and complete

- `400 Bad Request`, id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
- 401 (unauthorized), id `INVALID_CREDENTIALS`: User credentials are missing or invalid.
- 404 (not found), possible cases:
	- Id `UNKNOWN_ACCESS`: The data access can't be found.
	- Id `UNKNOWN_CHANNEL`: The activity channel can't be found.



## <a id="admin-session"></a>Session management


### POST `/admin/login`

Opens a new admin session, authenticating with the provided credentials. TODO: possible support for OAuth/OpenID/BrowserID (for now, only local credentials are supported).

#### Body parameters

- `userName` (string)
- `password` (string)
- `appId` (string): A URL-friendly name uniquely identifying your app. The value you provide is in any case slugified before use (see [how](https://github.com/dodo/node-slug/blob/master/src/slug.coffee)).


#### Successful response: `200 OK`

- `sessionID` (string): The newly created session's ID, to include in each subsequent request's `Authorization` header.


### POST `/admin/logout`

Terminates the admin session.

#### Successful response: `200 OK`


## <a id="admin-user"></a>User information


### GET `/admin/user-info`

TODO: get user informations
Requires session token.

#### Successful response: `200 OK`

TODO: email, display name, language, ...


### PUT `/admin/user-info`

TODO: change user information


### POST `/admin/change-password`

TODO: change user password
Requires session token, old password, new password.

#### Specific errors

TODO: `WRONG_PASSWORD`, `INVALID_NEW_PASSWORD`


## <a id="admin-accesses"></a>Accesses

TODO: introductory text


### POST `/admin/get-app-token`

Gets the token of the personal access your app must use when accessing the user's data on her behalf. The access is created if it is the first time your app (identified by its id when logging in) requests it.

#### Successful response: `200 OK`

- `id` ([identity](#data-types-identity)): Your app's dedicated personal [access](#data-types-access) token.


### GET `/admin/accesses`

Gets all manageable accesses, which are the shared accesses. (Your app's own access token is retrieved with `POST /admin/get-app-token`.)

#### Successful response: `200 OK`

An array of [accesses](#data-types-access) containing all manageable accesses in the user's account, ordered by name.


### POST `/admin/accesses`

Creates a new shared access.

#### Body parameters

The new access's data: see [access](#data-types-access).

#### Successful response: `201 Created`

- `token` ([identity](#data-types-identity)): The created access's token.


### PUT `/admin/accesses/{token}`

Modifies the specified shared access.

#### Body parameters

New values for the access's fields: see [access](#data-types-access). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`


### DELETE `/admin/accesses/{token}`

Deletes the specified shared access.

#### Successful response: `200 OK`


## <a id="admin-bookmarks"></a>Bookmarks

TODO: introductory text


### GET `/admin/bookmarks`

Gets all of the user's sharing bookmarks.

#### Successful response: `200 OK`

An array of [bookmarks](#data-types-bookmark) containing all sharing bookmarks in the user's account, ordered by name.


### POST `/admin/bookmarks`

Creates a new sharing bookmark.

#### Body parameters

The new bookmark's data: see [bookmark](#data-types-bookmark).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created bookmark's id.


### PUT `/admin/bookmarks/{bookmark-id}`

Modifies the specified sharing bookmark.

#### Body parameters

New values for the bookmark's fields: see [bookmark](#data-types-bookmark). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`


### DELETE `/admin/bookmarks/{bookmark-id}`

Deletes the specified sharing bookmark.

#### Successful response: `200 OK`


## <a id="admin-channels"></a>Channels

TODO: introductory text.


### GET `/admin/channels`

Gets activity channels.

#### Query string parameters

- `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.

#### Successful response: `200 OK`

An array of [activity channels](#data-types-channel)) containing all channels in the user's account matching the specified state, ordered by name.


### POST `/admin/channels`

Creates a new activity channel.

#### Body parameters

The new channel's data: see [activity channel](#data-types-channel).

#### Successful response: `201 Created`

- `id` ([identity](#data-types-identity)): The created channel's id.


### PUT `/admin/channels/{channel-id}`

Modifies the activity channel's attributes.

#### Body parameters

New values for the channel's fields: see [activity channel](#data-types-channel). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`


### DELETE `/admin/channels/{channel-id}`

Trashes or deletes the given channel, depending on its current state:

- If the channel is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the channel is already in the trash, it will be irreversibly deleted with all the folders and events it contains.

#### Successful response: `200 OK`
