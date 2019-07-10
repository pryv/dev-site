dataStructure = require("./data-structure.coffee")
examples = require("./examples")
helpers = require("./helpers")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("basics", sectionId)

module.exports = exports =
  id: "basics"
  title: "Basics"
  sections: [
    id: "endpoint-url"
    title: "Root endpoint URL"
    description: """
                 ```
                 https://{username}.pryv.me
                 ```

                 Each user account has a dedicated root API endpoint as it is potentially served from a different location.

                 """
    examples: [
      title: "For instance, user '#{examples.users.one.username}' would be served from `https://#{examples.users.one.username}.pryv.me`"
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
               Host: {username}.pryv.me
               Authorization: {token}
               ```
               """
    ]
    sections: [
      id: "alternative-http-request-method"
      title: "Alternative HTTP request method"
      description: """
                   For those having trouble with [HTTP access control (CORS) rules](https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS), the API allows web apps to fake POST, PUT and DELETE requests through `application/x-www-form-urlencoded` POST requests with the following fields (all optional):
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
                     <pre><code>https://{username}.pryv.me/socket.io/socket.io.js</code></pre>

                   - For other platforms see the [Socket.IO wiki](https://github.com/learnboost/socket.io/wiki#wiki-in-other-languages).

                   Then initialize the connection with the URL:

                   ```
                   https://{username}.pryv.me:443/{username}?auth={accessToken}&resource=/{username}
                   ```
                   """
      examples: [
        title: "In a web app"
        content: """
                 ```html
                 <script src="https://#{examples.users.one.username}.pryv.me/socket.io/socket.io.js"></script>
                 <script>
                 var socket = io.connect("https://#{examples.users.one.username}.pryv.me:443/#{examples.users.one.username}?auth=#{examples.accesses.app.token}&resource=/#{examples.users.one.username}");
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
      errors: [
        key: "invalid-method"
        http: "404"
        description: """
                     The given method id is invalid.
                     """
      ]
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

    id: "service-infos"
    title: "Service infos"
    http: "GET /service/infos"

    description: """
                 /service/infos is a unfied way for third party services to access the necessary informations related to a Pryv.io implementation as this route is served by any Pryv.io API endpoint.

                 For many applications the first step is to Authenticate a user. Knowing the path to `https://access.{domain}/` is necessary.
                 Fetching `https://{any_endpoint}/service/infos` will return you a list of usefull informations such as `access` containing the path to access.

                 Example
                 ```js
                 // Requires
                 const superagent = require('superagent');
                 const express = require('express');

                 // Fetch infos from register Service Infos
                 const registerUrl = 'https://reg.pryv.li';
                 const serviceInfos = await superagent.get(registerUrl + '/service/infos');

                 // Extract `access` info
                 const accessUrl = serviceInfos.access;

                 // Listen to GET calls on the `access` url.
                 const expressApp = express();
                 expressApp.get(accessUrl, function (req: express$Request, res, next) {
                    api.call('accesses.get', reSpecific errors
                    q.context, req.query, methodCallback(res, next, 200));
                 });
                ```
                 """
    params:
      properties: []
    result:
      http: "200 OK"
      properties: [
        key: "version"
        type: "string"
        description: """
                    The API version.
                    """
      ,
        key: "register"
        type: "string"
        description: """
                    The URL of the registry service.
                    """
      ,
        key: "access"
        type: "string"
        description: """
                    The URL of the access page.
                    """
      ,
        key: "api"
        type: "string"
        description: """
                    The API endpoint format.
                    """
      ,
        key: "name"
        type: "string"
        description: """
                    The platform name.
                    """
      ,
        key: "home"
        type: "string"
        description: """
                    The URL of the platform's home page.
                    """
      ,
        key: "support"
        type: "string"
        description: """
                    The URL or email of the suppport page.
                    """
      ,
        key: "terms"
        type: "string"
        description: """
                    The URL or plain text of the terms and conditions page.
                    """
      ,
        key: "eventTypes"
        type: "string"
        description: """
                    The URL of the list of event types.
                    """
      ,
        key: "data"
        type: "any type"
        description: """
                    Custom field for you to store any additional data.
                    i.e. Platform-dependant information (Android / iOS), ...
                    """
      ,
        key: "meta"
        type: "any type"
        description: """
                    Meta-data is given with each api response and is now enhanced with a `serial` field.
                    The serial will change each time core or register is updated, if you compare it with the serial of a previous response and see a difference you should reload core configuration.
                    """
      ]
    examples: [
          title: "Retrieving service information."
          params: {}
          result:
            examples.serviceInfos.infos
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

    id: "authentication"
    title: "Authentication"
    description: """
                 All requests for retrieving and manipulating activity data must carry a valid [access token](##{dataStructure.getDocId("access")}) in the HTTP `Authorization` header or, alternatively, in the query string's `auth` parameter. With Socket.IO the token is passed in the handshake.

                 Access tokens are obtained via the [app authorization](#authorizing-your-app) or from sharing.

                 You can also use the **Access token generator** to obtain an app token:

                 ```
                 https://api.pryv.com/app-web-access/?pryv-reg=reg.{domain}
                 ```

                 For example:

                 [https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me)
                 """
    examples: [
      title: "HTTP `Authorization` header"
      content: """
               ```http
               GET /events HTTP/1.1
               Host: {username}.pryv.me
               Authorization: {token}
               ```
               """
    ,
      title: "HTTP `auth` query string parameter"
      content: """
               ```http
               GET /events?auth={token} HTTP/1.1
               Host: {username}.pryv.me
               ```
               """
    ]

  ,

    id: "trusted-apps-verification"
    title: "Trusted apps verification"
    trustedOnly: true
    description: """
                 These API methods require that the `appId` parameter and `Origin` (or `Referer`) header are trusted.  

                 This setting can be changed in the Pryv.io servers configuration.  
                 By default, any valid `appId` works and the `Origin` (or `Referer`) header must be in the form `https://*.{domain}`.
                 """
    examples: [
      title: "HTTP `Origin` header"
      content: """
               ```http
               POST /auth/login HTTP/1.1
               Host: {username}.pryv.me
               Origin: https://sw.{domain}
               ```
               """
    ,
      title: "HTTP `Referer` header"
      content: """
               ```http
               POST /auth/login HTTP/1.1
               Host: {username}.pryv.me
               Referer: https://sw.{domain}
               ```
               """
    ]
  ,

    id: "authorizing-your-app"
    title: "Authorizing your app"
    description: """
                 To authenticate users in your app, and thus for users to grant your app access to their data, you must:

                 1. Choose an app identifier (min. length 6 chars)
                 2. Send an auth request from your app
                 3. Open the `url` field of the HTTP response in a browser or webframe. The auth page will prompt the user to sign in using her Pryv credentials (or to create an account if she doesn't have one).
                 4. The result of the sign in process: a valid Access token or a refusal can be obtained in two ways: 
                  - by polling the URL obtained in the `poll` field of the HTTP response to the auth request
                  - by being redirected to the `returnURL` provided in the auth request with the result in query parameters

                 **Note: this auth flow will very likely undergo some changes in the near future.**
                 """
    sections: [
      id: "auth-request"
      title: "Auth request"
      type: "method"
      http:
        text: "POST to `https://reg.pryv.me/access`"
      httpOnly: true
      params:
        properties: [
          key: "requestingAppId"
          type: "string"
          description: """
                       Your app's identifier.
                       """
        ,
          key: "requestedPermissions"
          type: "array of permission request objects"
          description: """
                       The requested permissions. Each permission request has properties:
                       """
          properties: [
            key: "streamId"
            type: "[identifier](##{dataStructure.getDocId("identifier")})"
            description: """
                         The id of the requested stream.
                         """
          ,
            key: "level"
            type: "`read`|`contribute`|`manage`"
            description: """
                         The required permission level.
                         """
          ,
            key: "defaultName"
            type: "string"
            description: """
                         The name to create the stream if needed (in the language of the user).
                         """
          ]
        ,
          key: "languageCode"
          type: "string"
          optional: true
          description: """
                       The two-letter ISO (639-1) code of the language in which to display user instructions, if possible. Default: `en`.
                       """
        ,
          key: "returnURL"
          type: "string"
          optional: true
          description: """
                       The URL to redirect the user to after auth completes.
                       Required if you are not using polling to retrieve the auth result (see Result below).
                       """
        ,
          key: "clientData"
          type: "[key-value](##{dataStructure.getDocId("key-value")})"
          optional: true
          description: """
                       Additional client data that will be transmitted alongside the auth request (see Result below).
                       """
        ]
      result: [
        title: "Result: in progress"
        http: "200"
        properties: [
          key: "status"
          type: "`NEED_SIGNIN`"
          description: """
                       Auth in progress.
                       """
        ,
          key: "url"
          type: "string"
          description: """
                       The URL of the auth page to show the user from your app as popup or webframe.
                       """
        ,
          key: "key"
          type: "string"
          description: """
                       The key used to identify the auth request. It is also part of the poll URL described just below.
                       """
        ,
          key: "poll"
          type: "string"
          description: """
                       The poll URL to use for retrieving the auth result via an HTTP GET request.  
                       Responses to polling requests are the same as those from the auth request.
                       """
        ,
          key: "poll_rate_ms"
          type: "number"
          description: """
                       The rate at which the poll URL can be polled, in milliseconds.
                       """
        ,
          key: "requestingAppId"
          type: "string"
          description: """
                       The app identifier provided during the auth request.
                       """
        ,
          key: "requestedPermissions"
          type: "string"
          description: """
                       The permissions provided during the auth request.
                       """
        ,
          key: "lang"
          type: "string"
          optional: true
          description: """
                       The language code provided during the auth request.
                       """
        ,
          key: "returnURL"
          type: "string"
          optional: true
          description: """
                       The return URL provided during the auth request.
                       """
        ,
          key: "clientData"
          type: "[key-value](##{dataStructure.getDocId("key-value")})"
          optional: true
          description: """
                       The client data provided during the auth request.
                       """
        ]
      ,
        title: "Result: accepted"
        http: "200"
        properties: [
          key: "status"
          type: "`ACCEPTED`"
          description: """
                       Auth successful.
                       """
        ,
          key: "username"
          type: "string"
          description: """
                       The authentified user's username.
                       """
        ,
          key: "token"
          type: "string"
          description: """
                       Your app's API access token.
                       """
        ]
      ,
        title: "Result: refused"
        http: "403"
        properties: [
          key: "status"
          type: "`REFUSED`"
          description: """
                       Auth failed.
                       """
        ,
          key: "reasonID"
          type: "string"
          description: """
                       A code indicating the reason for the failure.
                       """
        ,
          key: "message"
          type: "string"
          description: """
                       A message indicating the reason for the failure.
                       """
        ]
      ]
      examples: [
        title: "Auth request"
        content: """
                 ```http
                 POST /access HTTP/1.1
                 Host: reg.pryv.me

                 {
                   "requestingAppId": "test-app-id",
                   "requestedPermissions": [
                     {
                       "streamId": "diary",
                       "level": "read",
                       "defaultName": "Journal"
                     },
                     {
                       "streamId": "position",
                       "level": "contribute",
                       "defaultName": "Position"
                     }
                   ],
                   "languageCode": "fr"
                 }
                 ```
                 """
      ,
        title: '"In progress" response'
        content: """
                 ```json
                 {
                    "status": "NEED_SIGNIN",
                    "code": 201,
                    "key": "6CInm4R2TLaoqtl4",
                    "requestingAppId": "test-app-id",
                    "requestedPermissions": [
                        {
                            "streamId": "diary",
                            "level": "read",
                            "defaultName": "Journal"
                        },
                        {
                            "streamId": "position",
                            "level": "contribute",
                            "defaultName": "Position"
                        }
                    ],
                    "url": "https://sw.pryv.me/access/access.html?lang=fr&key=6CInm4R2TLaoqtl4&requestingAppId=test-app-id&domain=pryv.io&registerURL=https%3A%2F%2Freg.pryv.me&poll=https%3A%2F%2Freg.pryv.me%2Faccess%2F6CInm4R2TLaoqtl4",
                    "poll": "https://reg.pryv.me/access/6CInm4R2TLaoqtl4",
                    "oauthState": null,
                    "poll_rate_ms": 1000,
                    "lang": "fr"
                }
                 ```
                 """
      ,
        title: 'Polling request'
        content: """
                 ```http
                 GET /access/6CInm4R2TLaoqtl4 HTTP/1.1
                 Host: reg.pryv.me
                 ```
                 """
      ]
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
      ,
        key: "Pryv-Access-Id"
        optional: true
        description: """
                     The id of the [Access](##{dataStructure.getDocId("access")}) used for the API call.
                     Only present if a valid access token has been provided.
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
                     The current server time as a [timestamp](##{dataStructure.getDocId("timestamp")}). Keeping track of server time is necessary to properly handle time in API calls.
                     """
      ]
    ]


  ,

    id: "errors"
    title: "Errors"
    description: """
                 When an error occurs, the API returns a response with an `error` object (see [error](##{dataStructure.getDocId("error")}) detailing the cause. (Over HTTP, the response status is set to 4xx or 5xx.) In this documentation, errors are identified by their `id`.
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
        key: "unknown-referenced-resource"
        http: "400"
        description: """
                     One or more referenced resource(s) can't be found. The error's `data.{method-parameter-key}` (e.g. `data.streamId`) contains the unknown reference(s).
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
        key: "unknown-resource"
        http: "404"
        description: """
                     The resource can't be found.
                     """
      ,
        key: "too-many-results"
        http: "413"
        description: """
                     The `events.get` method in batch or websocket call yielded too many results. Call the API method directly, narrow the request scope or page the request.
                     """
      ,
        key: "user-account-relocated"
        http: "301"
        description: """
                     The user has relocated her account to another server. Both the `Location` header and the error's `data` contain the equivalent URL pointing to the physical server now hosting the user's account. This error can only occur between the moment the account is relocated and the moment your DNS is updated to point to the new server. So we're stretching the HTTP convention a little, in that the returned URL should not be used permanently (only until `{username}.pryv.me` points to the correct server again). It's up to you to decide whether to keep it for the duration of the session (if you use sessions), for a given time, etc.
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

# Returns the in-doc id of the given type, for safe linking from other doc sections
exports.getDocId = (typeId) ->
  typeSection = _.find(exports.sections, (type) -> type.id == typeId)
  if typeSection
    return helpers.getDocId(exports.id, typeId)
  else
    throw new Error("Unknown type id")