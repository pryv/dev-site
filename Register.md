# Register module

TODO: introductory text


## Common error codes

TODO: review and complete

* 400 (bad request), id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.


## User name and password rules

TODO: wording

* User name: `/^[a-zA-Z0-9]]5,21}$/`(alphanum between 5 an 21 chars) case-insensitive.
* Password:   `/^[a-zA-Z0-9]{7,21}$/` (alphanum between 7 and 21 chars) case-sensitive.


### GET `/<user name>/check`

Checks whether the given user name already exists.

#### Response (JSON)

* `exists` (`true` or `false`): `true` if the given user name is already in use

#### Specific errors

* 400 (bad request), id `INVALID_USER_NAME`: The given name cannot be used as a user name (see rules above TODO: link).

### POST `/init`

Initializes user creation. The creation must be confirmed with POST `/<user name>/confirm`. Unconfirmed user creations are deleted after 24 hours.

#### Post parameters (JSON)

* `userName` (string): The user's unique name.
* `password` (string): The user's password for accessing administration functions.
* `email` (string): The user's e-mail address, unique to that user. TODO: validation rule: `/^[^@]+@[a-zA-Z0-9._-]+\.[a-zA-Z]+$/`
* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.

#### Response (JSON)

* `confirmationToken` (string): TODO
* `captchaChallenge` (string): TODO: a confirmation e-mail cycle may be added 
   
#### Specific errors

* 400 (bad request), id `EXISTING_USER_NAME`: TODO
* 400 (bad request), id `INVALID_USER_NAME`: The given name cannot be used as a user name (see rules above TODO: link).
* 400 (bad request), id `INVALID_PASSWORD`: TODO (see rules above TODO: link).
* 400 (bad request), id `INVALID_EMAIL`: TODO

### GET `/<user name>/confirm_by_mail/<confirmationToken>`

#### Response (JSON)

* OK:

#### Specific errors

* 400 (bad request), id `NO_EXISTING_USER_NAME`: TODO
* 400 (bad request), id `INVALID_TOKEN`: TODO
* 400 (bad request), id `USER_ALREADY_CONFIRMED`: TODO

### POST `/<user name>/confirm`

Confirms user creation for the given user. 
TODO: remove this comment: "No need for a GET equivalent for use from email link as we will need a ** Proxy ** web page that will convert this web page could be the same than the one where we validate the Captcha"

#### Post parameters (JSON)

* `confirmationToken` (string): TODO
* `captchaAnswer` (string): TODO: see remark for `init` above

#### Response (JSON)

* `serverIP`: TODO

#### Specific errors

* 400 (bad request), id `INVALID_TOKEN`: TODO
* 400 (bad request), id `WRONG_CAPTCHA`: TODO: see remarks above
* 404 (not found): There is no pending user creation for the given user name.


### GET `/<user name>/server`

Requests the server IP for the given user. TODO: review and discuss.