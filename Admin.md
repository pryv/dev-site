# Admin module

**TODO: only basically transcribed from Perki's mind map, must be reviewed before any implementation.**
TODO: introductory text


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
