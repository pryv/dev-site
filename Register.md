# Register module

TODO: introductory text


## Common error codes

TODO: review and complete

* 400 (bad request), code `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.


## User name and password rules

TODO: wording

* User name: `/^[a-zA-Z0-9]{5,21}$/`(alphanum between 5 an 21 chars) case-insensitive.
* Password:   `/^[a-zA-Z0-9]{7,21}$/` (any chars between 6 and 99 chars) with no trailing spaces.


### GET `/<user name>/check`

Checks whether the given user name already exists.

#### Response (JSON)

* `exists` (`true` or `false`): `true` if the given user name is already in use

#### Specific errors

* 400 (bad request), code `INVALID_USER_NAME`: The given name cannot be used as a user name (see rules above TODO: link).

### POST `/init`

Initializes user creation. The creation must be confirmed with POST `/<user name>/confirm`. Unconfirmed user creations are deleted after 24 hours.

#### Post parameters (JSON)

* `userName` (string): The user's unique name.
* `password` (string): The user's password for accessing administration functions.
* `email` (string): The user's e-mail address, unique to that user. TODO: validation rule: `/^[^@]+@[a-zA-Z0-9._-]+\.[a-zA-Z]+$/`
* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.

#### Response (JSON)

* `captchaChallenge` (string): TODO: a confirmation e-mail cycle may be added 
   
#### Specific errors

* 400 (bad request), code `EXISTING_USER_NAME`: TODO
* 400 (bad request), code `INVALID_USER_NAME`: The given name cannot be used as a user name (see rules above TODO: link).
* 400 (bad request), code `INVALID_PASSWORD`: TODO (see rules above TODO: link).
* 400 (bad request), code `INVALID_EMAIL`: TODO

### POST `/<user name>/confirm`

Confirms user creation for the given user. 
Note: if user is already confirmed, this will send no error, just the serverIP of the use

#### Post parameters (JSON)

* `challenge` (string): TODO: see remark for `init` above

#### Response (JSON)

* `server`: may be an IPv4, iPv6 or a fully qualified hostname

#### Specific errors

* 400 (bad request), code `WRONG_CHALLENGE`: the response is not the string expected.
* 400 (bad request), code `INVALID_CHALLENGE`: the response is badly formatted.
* 404 (not found): There is no pending user creation for the given user name.


### GET `/<user name>/server`

#### Response (JSON)

* `serverIP`: TODO