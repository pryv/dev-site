pages = require("../_meta").pages
dataStructure = require("./data-structure.coffee")
examples = require("./examples")
helpers = require("./helpers")
timestamp = require("pryv-api-server-common").utils.timestamp
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("basics", sectionId)

module.exports = exports =
  id: "basics"
  title: "Basics"
  sections: [
    id: "endpoint-url"
    title: "Endpoint URL"
    description: """
                 ```
                 https://{username}.pryv.io
                 ```

                 Because each user account is potentially served from a different machine according to the user's choice, each user has a dedicated API endpoint.
                 """
    examples: [
      title: "For instance, user '#{examples.users.one.username}' would be served from `https://#{examples.users.one.username}.pryv.io`"
    ]

  ,

    id: "calling-with-http"
    title: "Calling with HTTP"
    description: """
                 The API serves regular REST-like HTTP requests, with the usual verbs for reading and manipulating data:

                 - **GET** (parameters: query string)<br>
                   for reading resources
                 - **POST** (parameters: request body)<br>
                   for creating new resources and other methods modifying data
                 - **PUT** (parameters: request body)<br>
                   for modifying resources
                 - **DELETE** (parameters: query string)<br>
                   for removing resources; logical deletion (trashing) is supported for some resources such as events and streams
                 """
    examples: [
      title: "Example request"
      content: """
               ```http
               GET /events HTTP/1.1
               Host: {username}.pryv.io
               Authorization: {token}
               ```
               """
    ]
    sections: [
      id: "alternative-http-request-method"
      title: "Alternative HTTP request method"
      description: """
                   Because we could't fathom out the rationale behind [HTTP access control (CORS) rules](https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS), the API allows web apps to fake POST, PUT and DELETE requests through `application/x-www-form-urlencoded` POST requests with the following fields (all optional):
                   """
      properties: [
        key: "_method"
        description: """
                     The HTTP override method to use (usually `PUT` or `DELETE`; `POST` is used if not set).
                     """
      ,
        key: "_auth"
        description: """
                     The `Authorization` header value (alternative to sending the header itself).
                     """
      ,
        key: "_json"
        description: """
                     Considered as the JSON request body if set (overriding all other body content, if any).
                     """
      ]
    ]

  ,

    id: "calling-with-websockets"
    title: "Calling with websockets"
    description: """
                 The API supports real-time interaction by accepting websocket connections via [Socket.IO](http://socket.io).
                 """
    sections: [
      id: "connecting"
      title: "Connecting"
      description: """
                   First, load the right Socket.IO client library.

                   - For a web app, the Javascript lib is directly served by the API at:
                     <pre><code>https://{username}.pryv.io/socket.io/socket.io.js</code></pre>

                   - For other platforms see the [Socket.IO wiki](https://github.com/learnboost/socket.io/wiki#wiki-in-other-languages).)

                   Then initialize the connection with the URL:

                   ```
                   https://{username}.pryv.io:443/{username}?auth={accessToken}&resource=/{username}
                   ```
                   """
      examples: [
        title: "In a web app"
        content: """
                 ```html
                 <script src="https://#{examples.users.one.username}.pryv.io/socket.io/socket.io.js"></script>
                 <script>
                 var socket = io.connect("https://#{examples.users.one.username}.pryv.io:443/#{examples.users.one.username}?auth=#{examples.accesses.app.token}&resource=/#{examples.users.one.username}");
                 });
                 </script>
                 ```
                 """
      ]
    ,
      id: "calling-methods"
      title: "Calling methods"
      description: """
                   You call API methods by sending a corresponding Socket.IO `{method-id}` message, passing a parameters object and a callback:

                   ```javascript
                   // javascript
                   socket.emit('{method-id}', {/*parameters*/}, function (error, result) {
                     // handle result
                   });
                   ```

                   See each method's doc for its id.
                   """
      examples: [
        title: "Retrieving events (Javascript)"
        content: """
                 ```javascript
                 socket.emit('events.get', {sortAscending: true}, function (error, result) {
                   // ...
                 });
                 ```
                 """
      ]
    ,
      id: "subscribing-to-changes"
      title: "Subscribing to changes"
      description: """
                   Get notified when data changes by subscribing to messages `eventsChanged` and `streamsChanged`.
                   """
      examples: [
        title: "Subscribing to events changes (Javascript)"
        content: """
                 ```javascript
                 socket.on('eventsChanged', function() {
                   // retrieve latest changes and update
                 });
                 ```
                 """
      ]
    ]

  ,

    id: "data-format"
    title: "Data format"
    description: """
                 The API exchanges data with clients in JSON (MIME type `application/json`), except when uploading/downloading attached files.
                 """
    examples: [
      title: "Example event"
      content: examples.events.position
    ]

  ,

    id: "authorization"
    title: "Authorization"
    description: """
                 All requests for retrieving and manipulating activity data must carry a valid [access token](##{dataStructure.getDocId("access")}) in the HTTP `Authorization` header or, alternatively, in the query string's `auth` parameter. With Socket.IO the token is passed in the handshake.

                 (Access tokens are obtained via the [app auth flow](#{pages.linkTo("appAccess")}) or from sharing.)
                 """
    examples: [
      title: "HTTP `Authorization` header"
      content: """
               ```http
               GET /events HTTP/1.1
               Host: {username}.pryv.io
               Authorization: {token}
               ```
               """
    ,
      title: "HTTP `auth` query string parameter"
      content: """
               ```http
               GET /events?auth={token} HTTP/1.1
               Host: {username}.pryv.io
               ```
               """
    ]

  ,

    id: "common-metadata"
    title: "Common metadata"
    description: """
                 General API and server information.
                 """
    sections: [
      id: "http"
      title: "In HTTP headers"
      description: """
                   Every HTTP response has header:
                   """
      properties: [
        key: "API-Version"
        description: """
                     The version of the API in the form `{major}.{minor}.{revision}`. Mirrored in method results as `meta.apiVersion`.
                     """
      ]
    ,
      id: "method-results"
      title: "In method results"
      description: """
                   Every JSON method result has properties:
                   """
      properties: [
        key: "meta.apiVersion"
        description: """
                     The version of the API in the form `{major}.{minor}.{revision}`. Mirrored in HTTP header `API-Version`.
                     """
      ,
        key: "meta.serverTime"
        description: """
                     The current server time as a [timestamp](#{dataStructure.getDocId("timestamp")}). Keeping track of server time is necessary to properly handle time in API calls.
                     """
      ]
    ]


  ,

    id: "errors"
    title: "Errors"
    description: """
                 When an error occurs, the API returns a response with an `error` object (see [error](#{dataStructure.getDocId("error")}) detailing the cause. (Over HTTP, the response status is set to 4xx or 5xx.) In this documentation, errors are identified by their `id`.
                 """
    examples: [
      content: examples.errors.invalidAccessToken
    ]
    sections: [
      id: "usual-errors"
      title: "Usual errors"
      description: """
                   See also [error data structure](##{dataStructure.getDocId("error")}).
                   """
      properties: [
        key: "invalid-request-structure"
        http: "400"
        description: """
                     The request's structure is not that expected; for example: invalid JSON syntax, unexpected multipart structure when uploading file attachments.
                     """
      ,
        key: "invalid-parameters-format"
        http: "400"
        description: """
                     The request's parameters do not follow the expected format. The error's `data` contains an array of validation errors.
                     """
      ,
        key: "unknown-event"
        http: "400"
        description: """
                     The referenced event(s) can't be found. If relevant, the unknown items' ids are listed as an array in the error's `data.unknownIds`.
                     """
      ,
        key: "unknown-stream"
        http: "400"
        description: """
                     The referenced stream(s) can't be found. If relevant, the unknown items' ids are listed as an array in the error's `data.unknownIds`.
                     """
      ,
        key: "unknown-tag"
        http: "400"
        description: """
                     The referenced typed tag(s) can't be found. If relevant, the unknown items' ids are listed as an array in the error's `data.unknownIds`.
                     """
      ,
        key: "invalid-access-token"
        http: "401"
        description: """
                     The access token is missing or invalid.
                     """
      ,
        key: "forbidden"
        http: "403"
        description: """
                     The given access token does not grant permission for this operation. See [accesses](##{dataStructure.getDocId("access")}) for more details about accesses and permissions.
                     """
      ,
        key: "unknown-event"
        http: "404"
        description: """
                     The event can't be found.
                     """
      ,
        key: "unknown-stream"
        http: "404"
        description: """
                     The stream can't be found.
                     """
      ,
        key: "unknown-tag"
        http: "404"
        description: """
                     The tag can't be found.
                     """
      ,
        key: "unknown-attachment"
        http: "404"
        description: """
                     The attached file can't be found for the specified event.
                     """
      ,
        key: "user-account-relocated"
        http: "301"
        description: """
                     The user has relocated her account to another server. Both the `Location` header and the error's `data` contain the equivalent URL pointing to the physical server now hosting the user's account. This error can only occur between the moment the account is relocated and the moment your DNS is updated to point to the new server. So we're stretching the HTTP convention a little, in that the returned URL should not be used permanently (only until `{username}.pryv.io` points to the correct server again). It's up to you to decide whether to keep it for the duration of the session (if you use sessions), for a given time, etc.
                     """
      ,
        key: "user-intervention-required"
        http: "402"
        description: """
                     The request cannot be served temporarily because the user's account has exceeded its limits. The user must log into her account and fix the issue.
                     """
      ]
    ]
  ]
