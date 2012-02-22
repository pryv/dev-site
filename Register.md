# Register module

TODO: introductory text

### GET `/<user name>/check`

Checks whether the given user name already exists.

#### Response (OK)

* `exists` (`true` or `false`): `true` if the given user name is already in use

#### Specific errors

* 400 (bad request), code `InvalidUserName`: The given name cannot be used as a user name (TODO: rules)

### POST `/<user name>/init`

Initializes user creation for the given user name and information. The creation must be confirmed with POST `/<user name>/confirm`. Unconfirmed user creations are deleted after TODO: 24 hours.

#### Post parameters

* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.
* TODO

TODO