[REC●la] API: Administration module
============


**TODO: Must be reviewed before any implementation.**

The administration service handles user's:

* Identity and profile settings
* Channels and contexts organisation
* Sharing management

The Administration server is a part of an AAServer, which also handle activity recording.

[TOC]

# HOSTNAMES
They are several independants Administration/Activity servers (AAServer), they all have a static hostname: **xyz.wactiv.com**.

Each of them have also dynamic hostnames, one for each user they serve: **username.rec.la**.

To access a user's ressource you should use `https://username.rec.la/ressource_path`
But the protocol also supports `https://xyz.wactiv.com/ressource_path?userName=username`

**Note:** Arguments will override hostnames. In the following case, **username2** will be used. `https://username1.rec.la/ressource_path?userName=username2`

**See:** [Register module: https://rec.la/&lt;userName>/server](Register#server) API call to get the server hostname for a user.

# WEB access

## Administration login page
### https://username.rec.la
Presents the administration login page
If you known the server *.wactiv.com (xyz) hostname, it can also be obtained with `https://xyz.wactiv.com/?userName=username`

## Confirm Success
### https://xyz.rec.la/?msg=CONFIRMED
Presents the administration login page with a registration "confirmed" message.

### https://xyz.rec.la/?msg=CONFIRMED_ALREADY
Presents the administration login page with an "registration already confirmed" message


# HTTP API


## Authentication

TODO: explain authentication and sessions.


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

#### Response (JSON)

If successful (HTTP code 200), the session cookie to use for the duration of the session is defined in the `set-cookie` HTTP header.


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

#### Response (JSON)

* `channels` (array of [activity channels](/DataTypes#TODO)): All channels in the user's account, ordered by name.
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

#### Query string parameters

* `deleteChannelData` (must be `true`): Required for safety if the deleted channel contains contexts or events, ignored otherwise.

#### Specific errors

* 400 (bad request), id `MISSING_PARAMETER`: There are contexts and/or events in the channel and the `deleteChannelData` parameter is missing.



## Requests for access tokens


### GET `/tokens/<name>` TODO: change to POST request (we potentially create data)

TODO: review this (it is very bad to create data with a GET request unless explicity named): get or create a token associated with a client; based on client key (name), a new token is created or key is retrieved
Requires session token, client info (optional, used only if a token is created)
Response: token string


### GET `/tokens`

Gets access tokens.

#### Response (JSON)

* `tokens` (array of [access tokens](/DataTypes#TODO)): All access tokens in the user's account, ordered by name.


### PUT `/tokens/<token id>`

TODO


### DELETE `/tokens/<token id>`

TODO
