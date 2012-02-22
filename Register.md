# Register module

TODO: introductory text


## Common error codes

TODO: review and complete

* 400 (bad request), code `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.


### GET `/<user name>/check`

Checks whether the given user name already exists.

#### Response (JSON)

* `exists` (`true` or `false`): `true` if the given user name is already in use

#### Specific errors

* 400 (bad request), code `INVALID_USER_NAME`: The given name cannot be used as a user name (TODO: rules)


### POST `/init`

Initializes user creation. The creation must be confirmed with POST `/<user name>/confirm`. Unconfirmed user creations are deleted after TODO: 24 hours.

#### Post parameters (JSON)

* `userName` (string): The user's unique name.
* `email` (string): The user's e-mail address, unique to that user.
* `password` (string): The user's password for accessing administration functions.
* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.

#### Response (JSON)

* `confirmationToken` (string): TODO
* `captchaChallenge` (string): TODO: shouldn't we do like everyone else and send a confirmation e-mail instead?

#### Specific errors

* 400 (bad request), code `EXISTING_USER_NAME`: TODO
* 400 (bad request), code `INVALID_EMAIL`: TODO
* 400 (bad request), code `INVALID_PASSWORD`: TODO


### POST `/<user name>/confirm`

Confirms user creation for the given user. TODO: we should probably have a GET equivalent for this request (for use from email link).

#### Post parameters (JSON)

* `confirmationToken` (string): TODO
* `captchaAnswer` (string): TODO: see remark for `init` above

#### Response (JSON)

* `serverIP`: TODO

#### Specific errors

* 400 (bad request), code `INVALID_TOKEN`: TODO
* 400 (bad request), code `WRONG_CAPTCHA`: TODO: see remarks above
* 404 (not found): There is no pending user creation for the given user name.


### GET `/<user name>/server`

Requests the server IP for the given user. TODO: review and discuss.