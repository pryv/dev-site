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

# REST API
 

## Authentication

TODO: explain authentication and sessions.


## Common error codes

TODO: review and complete

* 400 (bad request), id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
* 403 (forbidden): TODO
* 404 (not found): TODO


## Requests


### POST `/login`

TODO: get an admin sessiontoken.

#### Post parameters (JSON)

TODO: username, password

#### Response (JSON)

TODO: session token

#### Specific errors

TODO: `WRONG_CREDENTIALS`


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


### GET `/tokens/<client key>`

TODO: get or create a token associated with a client; based on client key, a new token is created or key is retrieved
Requires session token, client info (optional, used only if a token is created)
Response: token string


### GET `/tokens`

TODO


### PUT `/tokens/<client key>`

TODO


### DELETE `/tokens/<client key>`

TODO


### POST `/logout`

TODO
