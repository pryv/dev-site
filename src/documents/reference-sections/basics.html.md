---
doc: reference
sectionId: basics
sectionOrder: 1
---

# Basics


## API style

Most of the API follows REST principles, meaning each item has its own unique resource URL and can be read or modified via HTTP verbs:

- GET to read the item(s)
- POST to create a new item, with a JSON message in the request body
- PUT to modify the item, with a JSON message in the request body
- DELETE to delete the item (note that logical deletion, or trashing, is supported for items like events, folders and channels)

Example API request:
```http
GET /{channel-id}/events HTTP/1.1
Host: {user-name}.pryv.io
Authorization: {access-token}
```

Note that the API also supports Socket.IO, for both calling API methods and receiving live notifications of changes to activity data. See [the dedicated section](#socketio).


## Base URL

`https://{username}.pryv.io` (where `{username}` is the name of the user whose data you want to access)

Because Pryv potentially stores each user's data in a different location according to the user's choice, the API's base URL is unique for each user.


## Data format

The API exchanges data with the client in JSON.

Example event:
```json
{
  "id": "5051941d04b8ffd00500000d",
  "time": 1347864935.964,
  "folderId": "5058370ade44feaa03000015",
  "type": { "class": "position", "format": "wgs84" },
  "value": { "location": { "lat": 40.714728, "lng": -73.998672 } },
}
```

## Alternative request method

Because we can't fathom out the crazy rationale behind [HTTP access control (CORS) rules](https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS), we offer web apps an alternative way to place POST, PUT and DELETE requests in the API by using `application/x-www-form-urlencoded` POST requests with the following fields (all optional):

- `_method`: The HTTP override method to use (usually `PUT` or `DELETE`; `POST` is used if not set).
- `_auth`: The `Authorization` header value (alternative to sending the header itself).
- `_json`: Considered as the JSON request body if set (overriding all other body content, if any).

This is intended for web apps only; if your app isn't running in browsers you should use regular requests.


## Common HTTP headers

The following headers are included in every response:

- `API-Version`: The version of the API in the form `{major}.{minor}.{revision}`.
- `Server-Time`: The current server time as a [timestamp](#data-structure-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.

## Errors

When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an [error](#data-structure-error) object detailing the cause.

Here's an example "401 Unauthorized" error response:
```json
{
  "id": "invalid-access-token",
  "message": "Cannot find access with token 'bad-token'."
}
```
