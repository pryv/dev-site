# Pryv Activity API: Administration

**TODO: review and possibly relocate the sections below**

The administration service handles user's:

* Identity and profile settings
* Channels and folders organisation
* Sharing management

The Administration server is a part of an AAServer, which also handle activity recording.

[TOC]

# HOSTNAMES
They are several independants Administration/Activity servers (AAServer), they all have a static hostname: **xyz.pryv.net**. [TODO: I think this shouldn't be here; external people don't need to know that. Comment also applies below...]

Each of them have also dynamic hostnames, one for each user they serve: **username.pryv.io**.

To access a user's ressource you should use `https://username.pryv.io/ressource_path`
But the protocol also supports `https://xyz.pryv.net/ressource_path?userName=username` [TODO: ??? clarify]

**Note:** Arguments will override hostnames. In the following case, **username2** will be used. `https://username1.pryv.io/ressource_path?userName=username2`

**See:** [Register module: https://pryv.io/<userName>/server](Register#server) API call to get the server hostname for a user.

# WEB access

## Administration login page
### https://username.pryv.io
Presents the administration login page
If you known the server *.pryv.net (xyz) hostname, it can also be obtained with `https://xyz.pryv.net/?userName=username`

## Confirm Success
### https://xyz.pryv.io/?msg=CONFIRMED
Presents the administration login page with a registration "confirmed" message.

### https://xyz.pryv.io/?msg=CONFIRMED_ALREADY
Presents the administration login page with an "registration already confirmed" message


# HTTP API


## Authentication

Access to admin methods is managed by sessions. To create a session, you must sucessfully authenticate with a `/login` request, which will return the session ID. Each request sent during the duration of the session must then contain the session ID in its `Authorization` header. The session is terminated when `/logout` is called or when the session times out (TODO: indicate session timeout delay).


## Common HTTP headers

* `Server-Time`: The current server time as a [timestamp](/DataTypes#TODO). Keeping reference of the server time is an absolute necessity to properly read and write event times.


## Common error codes

TODO: review and complete

* 400 (bad request), id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
* 401 (unauthorized), id `INVALID_CREDENTIALS`: User credentials are missing or invalid.
* 404 (not found), possible cases:
	* Id `UNKNOWN_TOKEN`: The data access token can't be found.
	* Id `UNKNOWN_CHANNEL`: The activity channel can't be found.



## Requests for session management


### POST `/login`

Opens a new admin session, authenticating with the provided credentials. TODO: possible support for OAuth/OpenID/BrowserID (for now, only local credentials are supported).

#### Post parameters (JSON)

* `userName` (string)
* `password` (string)

#### Successful response: 200 (JSON)

* `sessionID` (string): The newly created session's ID, to include in each subsequent request's `Authorization` header.


### POST `/logout`

Terminates the admin session.


## Requests for user information


### GET `/user-info`

TODO: get user informations
Requires session token.

#### Response (JSON)

TODO: email, display name, language, ...


### PUT `/user-info`

TODO: change user information


### POST `/change-password`

TODO: change user password
Requires session token, old password, new password.

#### Specific errors

TODO: `WRONG_PASSWORD`, `INVALID_NEW_PASSWORD`


## Requests for activity channels

TODO: introductory text.


### GET `/channels`

Gets activity channels.

#### Query string parameters

* `state` (`default`, `trashed` or `all`): Optional. Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.

#### Successful response: 200 (JSON)

An array of [activity channels](/DataTypes#TODO)) containing all channels in the user's account matching the specified state, ordered by name.


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

Trashes or deletes the given channel, depending on its current state:

- If the channel is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
- If the channel is already in the trash, it will be irreversibly deleted with all the folders and events it contains.

#### Successful response: 200 (JSON)


## Requests for access tokens


### GET `/tokens/<name>` TODO: change to POST request (we potentially create data)

TODO: review this (it is very bad to create data with a GET request unless explicity named): get or create a token associated with a client; based on client key (name), a new token is created or key is retrieved
Requires session token, client info (optional, used only if a token is created)
Response: token string


### GET `/tokens`

Gets access tokens.

#### Response (JSON)

An array of [access tokens](/DataTypes#TODO) containing all access tokens in the user's account, ordered by name.


### PUT `/tokens/<token id>`

TODO


### DELETE `/tokens/<token id>`

TODO
