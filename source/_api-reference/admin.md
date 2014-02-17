# TODO: update for API v0.6 (see `api-server/CHANGELOG.md`; no separate "admin" methods anymore) and integrate into main reference

# Administration methods

**Administration is only allowed for trusted apps**; to register your app as trusted, please [get in touch with us](mailto:developers@pryv.com). If you're only interested in obtaining access tokens for your app, see the [app access documentation](app-access.html) instead.

Administration methods allow managing the user's [account information](#admin-user) and [sharing](#admin-accesses) (via accesses).



## Authorization

Access to admin methods is managed by sessions. To create a session, you must successfully authenticate with a `/admin/login` request, which will return the session ID. Each request sent during the duration of the session must then contain the session ID in its `Authorization` header or, alternatively, in the query string's `auth` parameter. The session is terminated when `/admin/logout` is called or when the session times out (TODO: indicate session timeout delay).

Here's what an admin request (with a session open) looks like:
```http
GET /admin/accesses HTTP/1.1
Host: cassis.pryv.io
Authorization: {session-id}
```
Or, alternatively, passing the access token in the query string:
```http
GET /admin/accesses?auth={session-id} HTTP/1.1
Host: cassis.pryv.io
```


## Common errors

TODO: review and complete

- `400 Bad Request`, id `invalid-parameters-format`: The request's parameters do not follow the expected format. The error's `data` contains an array of validation errors.
- `401 Unauthorized`, id `invalid-credentials`: User credentials are missing or invalid.
- `404 Not Found`, possible cases:
	- Id `unknown-access`: The data access can't be found.
	- Id `unknown-followed-slice`: The followed slice can't be found.



## <a id="admin-session"></a>Session management


### Login

`POST /admin/login`

Opens a new admin session, authenticating with the provided credentials. (See also POST `/admin/login/persona`.)

#### Parameters

- `username` (string)
- `password` (string)
- `appId` (string): A URL-friendly name uniquely identifying your app. The value you provide is in any case slugified before use (see [how](https://github.com/dodo/node-slug/blob/master/src/slug.coffee)).

#### Successful response: `200 OK`

- `sessionID` (string): The newly created session's ID, to include in each subsequent request's `Authorization` header.
- `preferredLanguage` ([language code](#data-structure-language-code)): The user's preferred language.

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -X POST -d '{"username":"{username}","password":"{password}","appId":"{appId}"}' https://{username}.pryv.io/admin/login
```


### Login with Mozilla Persona

`POST /admin/login/persona`

Opens a new admin session, authenticating with the provided [Mozilla Persona](https://developer.mozilla.org/en-US/docs/Persona) email and assertion.

#### Parameters

- `email` (string): The user's email.
- `assertion` (string): The Persona identity assertion (generated client-side) to be verified.
- `appId` (string): A URL-friendly name uniquely identifying your app.

TODO: refactor the following as it duplicates the content for POST `/admin/login`.

#### Successful response: `200 OK`

- `sessionID` (string): The newly created session's ID, to include in each subsequent request's `Authorization` header.
- `preferredLanguage` ([language code](#data-structure-language-code)): The user's preferred language.

#### cURL example

```bash

```


### Logout

`POST /admin/logout`

Terminates the admin session.

#### Successful response: `200 OK`

#### cURL example

```bash
curl -i -H "Content-Type: application/json" -H "Authorization: {session-id}" -X POST -d "{}" https://{username}.pryv.io/admin/logout
```


## <a id="admin-user"></a>User information


### Get user info

`GET /admin/user-info`

TODO: get user informations
Requires session token.

#### Successful response: `200 OK`

TODO: email, display name, language, ...

#### Successful response: `200 OK`

#### cURL example

```bash
curl -i -H "Authorization: {session-id}" https://{username}.pryv.io/admin/user-info
```


### Update user info

`PUT /admin/user-info`

TODO: change user information

#### cURL example

```bash

```


### Change password

`POST /admin/change-password`

TODO: change user password
Requires session token, old password, new password.

#### Specific errors

TODO: `WRONG_PASSWORD`, `INVALID_NEW_PASSWORD`

#### cURL example

```bash

```


## <a id="admin-accesses"></a>Accesses

TODO: introductory text


### Get accesses

`GET /admin/accesses`

Gets all manageable accesses, which are the shared accesses. (Your app's own access token is retrieved with `POST /admin/get-app-token`.)

#### Successful response: `200 OK`

An array of [accesses](#data-structure-access) containing all manageable accesses in the user's account, ordered by name.

#### cURL example

```bash
curl -i -H "Authorization: {session-id}" https://{username}.pryv.io/admin/accesses
```


### Create access

`POST /admin/accesses`

Creates a new shared access.

#### Parameters

The new access's data: see [access](#data-structure-access). Additionally, if a `defaultName` property is set on the new access' stream permission objects, the corresponding streams will be created with that name.

#### Successful response: `201 Created`

- `token` ([identity](#data-structure-identity)): The created access's token.

#### Specific errors

- `400 Bad Request`, id `item-id-already-exists`: An access already exists with the same token.
- `400 Bad Request`, id `item-name-already-exists`: An access already exists with the same name and type (and device name, for app accesses).
- `400 Bad Request`, id `invalid-item-id`: Occurs if trying to set the token to an invalid value (e.g. a reserved word like `null`).

#### cURL example

```bash

```


### Update access

`PUT /admin/accesses/{token}`

Modifies the specified shared access.

#### Parameters

New values for the access's fields: see [access](#data-structure-access). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

#### Specific errors

- `400 Bad Request`, id `item-name-already-exists`: An access already exists with the same name and type (and device name, for app accesses).

#### cURL example

```bash

```


### Delete access

`DELETE /admin/accesses/{token}`

Deletes the specified shared access.

#### Successful response: `200 OK`

#### cURL example

```bash

```


### Check app authorization

`POST /admin/accesses/check-app`

For the app authorization process. Checks if the app requesting authorization already has access with the same permissions (and on the same device, if applicable), and returns details of the requested permissions' streams (for display) if not.

#### Parameters

- `requestingAppId` (string): The id of the app requesting authorization.
- `deviceName` (string): Optional. The name of the device running the app requesting authorization, if applicable.
- `requestedPermissions`: An array of stream permission request objects, which are identical to stream permission objects of [accesses](#data-structure-access) with the difference that each permission object must have a `defaultName` property specifying the name the stream should be created with later (in POST `/admin/accesses`) if missing.

#### Successful response: `200 OK`

If no matching access already exists:

- `checkedPermissions`: A updated copy of the `requestedPermissions` array passed in the request, with the `defaultName` property replaced by `name` for each existing stream (set to the actual name of the item). (For missing streams the `defaultName` property is left untouched.) If streams already exist with the same name but a different `id`, `defaultName` is updated with a valid alternative proposal (in such cases the response also has an `error` property to signal the issue; see below).
- `mismatchingAccessToken` ([identity](#data-structure-identity)): Set if an access already exists for the requesting app, but with different permissions than those requested.
- `error` ([error](#data-structure-error)): If there is a duplicate issue with some streams requested for creation (see `checkedPermissions`), this is set to an `item-name-already-exists` error.

If a matching access already exists:

- `matchingAccessToken` ([identity](#data-structure-identity)): The requesting app's existing [access](#data-structure-access) token.

#### cURL example

```bash

```


## <a id="admin-followed-slice"></a>Followed slices

TODO: introductory text


### Get followed slices

`GET /followed-slices`

Gets all of the user's followed slices.

#### Successful response: `200 OK`

An array of [followed slices](#data-structure-followed-slice) containing all followed slices in the user's account, ordered by name.

#### cURL example

```bash

```


### Create followed slice

`POST /followed-slices`

Creates a new followed slice.

#### Parameters

The new followed slice's data: see [followed slice](#data-structure-followed-slice).

#### Successful response: `201 Created`

- `id` ([identity](#data-structure-identity)): The created followed slice's id.

#### cURL example

```bash

```


### Update followed slice

`PUT /followed-slices/{followed-slice-id}`

Modifies the specified followed slice.

#### Parameters

New values for the followed slice's fields: see [followed slice](#data-structure-followed-slice). All fields are optional, and only modified values must be included. TODO: example

#### Successful response: `200 OK`

#### cURL example

```bash

```


### Delete followed slice

`DELETE /followed-slices/{followed-slice-id}`

Deletes the specified followed slice.

#### Successful response: `200 OK`

#### cURL example

```bash

```


## <a id="admin-profile-sets"></a>Profile sets

TODO: for usage see [activity app profile](#activity-profile-app).

### Get public profile `GET /profile/public`: TODO
### Update public profile `PUT /profile/public`: TODO
### Get private profile `GET /profile/private`: TODO
### Update private profile `PUT /profile/private`: TODO