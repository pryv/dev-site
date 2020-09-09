basics = require('./basics')
dataStructure = require('./data-structure.coffee')
examples = require("./examples")
helpers = require("./helpers")
timestamp = require("unix-timestamp")
_ = require("lodash")
generateId = require("cuid")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId, methodId) ->
  return helpers.getDocId("methods", sectionId, methodId)

module.exports = exports =
  id: "methods"
  title: "API methods"
  sections: [
      id: "registration"
      title: "Registration"
      description: """
                  Methods for user registration and username uniqueness check.
                  """
      sections: [
        id: "users.create"
        type: "method"
        title: "Create user"
        http: "POST /users"
        httpOnly: true
        server: "core"
        description: """
                    Creates a new user account. Method could be customized using the platform config.
                    """
        params:
          properties: [
            key: "appId"
            type: "string"
            description: """
                        Your app's unique identifier.
                        """
          ,
            key: "username"
            type: "string"
            description: """
                        The user's username.
                        """
          ,
            key: "password"
            type: "string"
            description: """
                        The user's password.
                        """
          ,
            key: "email"
            type: "string"
            description: """
                          The user's e-mail address, used for password retrieval.
                          """
          ,
            key: "invitationToken"
            type: "string"
            optional: true
            description: """
                          An invitation token, necessary when users registration is limited to a specific set of users.
                          Platform administrators may limit users registration by configuring a list of authorized invitation tokens.
                          If this is not the case, users registration is open to everyone and this parameter can be omitted.
                          """
          ,
            key: "language"
            type: "string"
            optional: true
            description: """
                          The user's preferred language as a 2-letter ISO language code.
                          """
          ,
            key: "referer"
            type: "string"
            optional: true
            description: "A referer id potentially used for analytics."
          ]
        result:
          http: "200 OK"
          properties: [
            key: "username"
            type: "string"
            description: """
                          A confirmation of the user's username.
                          """
          ,
            key: "server"
            type: "string"
            description: """
                         The server where this account is hosted.
                         """
          ,
            key: "apiEndpoint"
            type: "string"
            description: """
                         The apiEndpoint to reach this account. It includes an access token.
                         """
          ]
        examples: [
          title: "Creating a user"
          params:
            appId: examples.register.appids[0]
            username: examples.users.two.username
            password: examples.users.two.password
            email: examples.users.two.email
            invitationToken: examples.register.invitationTokens[0]
            language: examples.register.languageCodes[0]
            referer: examples.register.referers[0]
          result:
            username: examples.users.five.username
            server: examples.users.five.username + "." + examples.register.platforms[0]
            apiEndpoint: examples.users.five.apiEndpoint.pryvLab
        ]
      ,
        id: "username.check"
        type: "method"
        title: "Check username"
        http: "GET /{username}/check_username"
        httpOnly: true
        server: "core"
        description: """
                    Check the availability and validity of a given username.
                    """
        params:
          properties: [
            key: "username"
            type: "string"
            http:
              text: "set in request path"
            description: """
                        The username to check.
                        """
          ]
        result:
          http: "200 OK"
          properties: [
            key: "reserved"
            type: "boolean"
            description: """
                        Set to `true` if the given username is already taken, `false` otherwise.
                        """
          ]
        examples: [
          title: "Checking availability and validity of a given username"
          params: {
            username: examples.users.two.username
          }
          result:
            reserved: false
        ,
          title: "When username has not correct format (for example is too short)."
          params: {
            username: 'pryv'
          }
          result:
            reserved: false
            error: {
              id: "invalid-parameters-format"
              data: [
                {
                  "code": "username-invalid",
                  "message": "Username should have from 5 to 23 characters and contain letters or numbers or dashes",
                  "param":"username"
                }
              ]
            }
        ,
          title: "When username is already taken."
          params: {
            username: 'testuser'
          }
          result:
            reserved: true
            error: {
              id: "item-already-exists"
              data: [
                {
                  "username": "testuser"
                }
              ]
            }
        ]
    ],
    id: "auth"
    title: "Authentication"
    trustedOnly: true
    description: """
                 Methods for trusted apps to login/logout users.
                 """
    sections: [
      id: "auth.login"
      type: "method"
      title: "Login user"
      http: "POST /auth/login"
      httpOnly: true
      description: """
                   Authenticates the user against the provided credentials, opening a personal access session. This is one of the only API methods that do not expect an [auth parameter](#basics-authorization).   
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "username"
          type: "string"
          description: """
                       The user's username.
                       """
        ,
          key: "password"
          type: "string"
          description: """
                       The user's password.
                       """
        ,
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "token"
          type: "string"
          description: """
                       The personal access token to use for further API calls.
                       """
        ,
          key: "preferredLanguage"
          type: "string"
          description: """
                       The user's preferred language as a 2-letter ISO language code.
                       """
        ]
      examples: [
        params:
          username: examples.users.one.username
          password: examples.users.one.password
          appId: "my-app-id"
        result:
          token: examples.accesses.personal.token
          preferredLanguage: examples.users.one.language
      ]

    ,

      id: "auth.logout"
      type: "method"
      httpOnly: true
      title: "Logout user"
      http: "POST /auth/logout"
      description: """
                   Terminates a personal access session by invalidating its access token (the user will have to login again).
                   Simply provide the Authorization token in own of [the supported ways](/reference/#authorization), no request body is required.
                   """
      result:
        http: "200 OK"
      examples: [
        params: {}
        result: {}
      ]
    ]

  ,

    id: "mfa"
    title: "Multi-factor authentication"
    trustedOnly: true
    entrepriseOnly: true
    description: """
                 Methods for handling multi-factor authentication (MFA) on top of the usual [Login method](##{_getDocId("auth", "auth.login")}).
                 """
    sections: [
      id: "mfa.login"
      type: "method"
      title: "Login with MFA"
      httpOnly: true
      http: "POST /auth/login"
      description: """
                   Proxied [Login](##{_getDocId("auth", "auth.login")}) call that initiates MFA authentication,
                   when MFA is activated for the current user.
                   """
      params:
        description: """
                       Similar to the usual [Login](##{_getDocId("auth", "auth.login")}) parameters.
                       """
      result:
        http: "302 Found"
        properties: [
          key: "mfaToken"
          type: "string"
          description: """
                       An expiring MFA session token to be used all along the MFA flow (challenge, verification).
                       """
        ]
      examples: [
        title: "Login when MFA is activated."
        params:
          username: examples.users.one.username
          password: examples.users.one.password
          appId: "my-app-id"
        result:
          mfaToken: '215bcc40-1296-11ea-9ff7-453ff2437834'
      ]

    ,

      id: "mfa.activate"
      type: "method"
      title: "Activate MFA"
      httpOnly: true
      http: "POST /mfa/activate"
      description: """
                   Initiates the MFA activation flow for a given Pryv.io user, triggering the MFA challenge.
                   
                   Requires a personal token as [authorization](#basics-authorization), which should be obtained during a prior [Login call](##{_getDocId("auth", "auth.login")}).
                   """
      params:
        description: """
              The parameters depend entirely on the chosen MFA method and will be forwarded to the service generating the challenge.
              """
      result:
        http: "302 Found"
        properties: [
          key: "mfaToken"
          type: "string"
          description: """
                       An expiring MFA session token to be used all along the MFA flow (challenge, verification).
                       """
        ]
      examples: [
        title: "Initiating the MFA activation using a phone number."
        params:
          phone_number: '41791234567'
        result:
          mfaToken: '215bcc40-1296-11ea-9ff7-453ff2437834'
      ]

    ,

      id: "mfa.confirm"
      type: "method"
      title: "Confirm MFA activation"
      httpOnly: true
      http: "POST /mfa/confirm"
      description: """
                   Confirms the MFA activation by verifying the MFA challenge triggered by a prior [MFA activation call](##{_getDocId("mfa", "mfa.activate")}).
                   
                   Requires a MFA session token as [authorization](#basics-authorization).
                   """
      params:
        description: """
              The parameters depend entirely on the chosen MFA method and will be forwarded to the service verifying the challenge.
              """
      result:
        http: "200 OK"
        properties: [
          key: "recoveryCodes"
          type: "array of strings"
          description: """
                       An array of recovery codes that can be used for the [MFA recover method](##{_getDocId("mfa", "mfa.recover")}).
                       """
        ]
      errors: [
        key: "forbidden"
        http: "403"
        description: """
                     Invalid MFA session token.
                     """
      ]
      examples: [
        title: "Finalizing the MFA activation."
        params:
          code: '1234'
        result:
          recoveryCodes: [ 
            'fba6e1f6-9f8f-4a0a-9c4f-8cf3458b4c55',
            'eb81be18-3168-4a44-8914-d97187df991c',
            'f7d7e863-0589-4779-8ddd-6c7e33df66af',
            'fb1d579f-2b92-42e3-82fa-8d7154c334f6',
            '52d3f019-3712-41d3-8c13-4924c3a7a703',
            'ac9de48c-a47d-46db-b276-e045ba693672',
            'de1072aa-6ed9-46a7-962c-1f8bb88ece2e',
            'cb5277cf-af86-47c3-a03e-7cc5011314ac',
            '16055dff-bc09-4262-b276-d70df82a9a2b',
            '36c7dd9b-5d23-4fb9-8504-c3e04aeb62c0'
            ]
      ]

    ,

      id: "mfa.challenge"
      type: "method"
      title: "Trigger MFA challenge"
      http: "POST /mfa/challenge"
      description: """
                   Triggers the MFA challenge, depending on the chosen MFA method (e.g. send a verification code by SMS).
                   
                   Requires a MFA session token as [authorization](#basics-authorization).
                   """
      result:
        http: "200 OK"
        properties: [
          key: "message"
          type: "string"
          description: """
                       "Please verify the MFA challenge."
                       """
        ]
      errors: [
        key: "forbidden"
        http: "403"
        description: """
                     Invalid MFA session token.
                     """
      ]
    ,

      id: "mfa.verify"
      type: "method"
      title: "Verify MFA challenge"
      httpOnly: true
      http: "POST /mfa/verify"
      description: """
                   Verifies the MFA challenge triggered by a prior [MFA challenge call](##{_getDocId("mfa", "mfa.challenge")}).
                   
                   Requires a MFA session token as [authorization](#basics-authorization).
                   """
      params:
        description: """
              The parameters depend entirely on the chosen MFA method and will be forwarded to the service verifying the challenge.
              """
      result:
        http: "200 OK"
        properties: [
          key: "token"
          type: "string"
          description: """
                       The personal access token to use for further API calls.
                       """
        ]
      errors: [
        key: "forbidden"
        http: "403"
        description: """
                     Invalid MFA session token.
                     """
      ]
      examples: [
        title: "Verifying the MFA challenge."
        params:
          code: '1234'
        result:
          token: examples.accesses.personal.token
      ]
    ,

      id: "mfa.deactivate"
      type: "method"
      title: "Deactivate MFA"
      httpOnly: true
      http: "POST /mfa/deactivate"
      description: """
                   Deactivate MFA for a given Pryv.io user.
                   
                   Requires a personal token as [authorization](#basics-authorization).
                   """
      result:
        http: "200 OK"
        properties: [
          key: "message"
          type: "string"
          description: """
                       "MFA deactivated."
                       """
        ]
    , 

      id: "mfa.recover"
      type: "method"
      title: "Recover MFA"
      http: "POST /mfa/recover"
      description: """
                   Deactivate MFA for a given Pryv.io user using a MFA recovery code.
                   
                   This is useful when [Deactivate MFA](##{_getDocId("mfa", "mfa.deactivate")}) can not be used (in case of 2nd factor loss).
                   Instead, requires a MFA recovery code (obtained when [confirming the MFA activation](##{_getDocId("mfa", "mfa.confirm")})), as well as the usual [Login](##{_getDocId("auth", "auth.login")}) parameters.
                   """
      params:
        description: """
                     Similar to the usual [Login](##{_getDocId("auth", "auth.login")}) parameters, as well as:
                     """
        properties: [
          key: "recoveryCode"
          type: "string"
          description: """
                       One MFA recovery code.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "message"
          type: "string"
          description: """
                       "MFA deactivated."
                       """
        ]
      errors: [
        key: "missing-parameter"
        http: "400"
        description: """
                     Missing parameter: recoveryCode.
                     """
      ,
        key: "invalid-parameter"
        http: "400"
        description: """
                     Invalid recovery code.
                     """
      ]
      examples: [
        title: "Deactivate MFA using a recovery code."
        params:
          recoveryCode: 'fba6e1f6-9f8f-4a0a-9c4f-8cf3458b4c55'
          username: examples.users.one.username
          password: examples.users.one.password
          appId: "my-app-id"
        result:
          message: "MFA deactivated."
      ]
    ]

  ,

    id: "callBatch"
    type: "method"
    title: "Call batch"
    http: "POST /"
    description: """
                  Sends a batch of API methods calls in one go (e.g. for to syncing offline changes when resuming connectivity).
                  """
    params:
      description: """
                    Array of method call objects, each defined as follows:
                    """
      properties: [
        key: "method"
        type: "string"
        description: """
                      The method id.
                      """
      ,
        key: "params"
        type: "object or array"
        description: """
                      The call parameters as required by the method.
                      """
      ]
    result:
      http: "200 OK"
      properties: [
        key: "results"
        type: "array of call results"
        description: "The results of each method call, in order."
      ]
    examples: [
      title: "Ensure stream path for a new event. In this example the 'health' stream already exists."
      params: [
        method: "streams.create"
        params: _.pick(examples.streams.health[0], "id", "name")
      ,
        method: "streams.create"
        params: _.pick(examples.streams.healthSubstreams[1], "id", "name", "parentId")
      ,
        method: "events.create"
        params: _.pick(examples.events.heartRate, "streamIds", "type", "content")
      ]
      result:
        results: [
          error:
            id: 'item-already-exists'
            message: 'A stream with id \"health\" already exists'
            data: 
              id: 'health'
        ,
          stream:
            examples.streams.healthSubstreams[1]
        ,
          event:
            examples.events.heartRate
        ]
    ]
  ,

    id: "events"
    title: "Events"
    description: """
                 Methods to retrieve and manipulate [events](##{dataStructure.getDocId("event")}).
                 """
    sections: [
      id: "events.get"
      type: "method"
      title: "Get events"
      http: "GET /events"
      description: """
                   Queries accessible events.
                   """
      params:
        properties: [
          key: "fromTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The start time of the timeframe you want to retrieve events for. Default is 24 hours before `toTime` if the latter is set; otherwise it is not taken into account.
                       """
        ,
          key: "toTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The end time of the timeframe you want to retrieve events for. Default is the current time if `fromTime` is set. We recommend to set both `fromTime` and `toTime` (for example by choosing a very small number for `fromTime` or a large one for `toTime` if you want to retrieve all events). Note: events are considered to be within a given timeframe based on their `time` only (`duration` is not considered).
                       """
        ,
          key: "streams"
          type: "array of [identifier](##{dataStructure.getDocId("identifier")})"
          optional: true
          description: """
                       If set, only events assigned to the specified streams and their sub-streams will be returned. By default, all accessible events are returned regardless of their stream.
                       """
        ,
          key: "tags"
          type: "array of strings"
          optional: true
          description: """
                       **(DEPRECATED)**
                       Please use streamIds instead.

                       If set, only events assigned to any of the listed tags will be returned.
                       """
        ,
          key: "types"
          type: "array of strings"
          optional: true
          description: """
                       If set, only events of any of the listed types will be returned.
                       """
        ,
          key: "running"
          type: "boolean"
          optional: true
          description: """
                       If `true`, only running period events will be returned.
                       """
        ,
          key: "sortAscending"
          type: "`true`|`false`"
          optional: true
          description: """
                       If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
                       """
        ,
          key: "skip"
          type: "number"
          optional: true
          description: """
                       The number of items to skip in the results.
                       """
        ,
          key: "limit"
          type: "number"
          optional: true
          description: """
                       The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
                       """
        ,
          key: "state"
          type: "`default`|`trashed`|`all`"
          optional: true
          description: """
                       Indicates what items to return depending on their state. By default, only items that are not in the trash are returned; `trashed` returns only items in the trash, while `all` return all items regardless of their state.
                       """
        ,
          key: "modifiedSince"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       If specified, only events modified since that time will be returned.
                       """
        ,
          key: "includeDeletions"
          type: "boolean"
          optional: true
          description: """
                       Whether to include event deletions since `modifiedSince` for sync purposes (only applies when `modifiedSince` is set). Defaults to `false`.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "events"
          type: "array of [events](##{dataStructure.getDocId("event")})"
          description: """
                       The accessible events ordered by time (see `sortAscending` above).
                       """
        ,
          key: "eventDeletions"
          type: "array of [item deletions](##{dataStructure.getDocId("item-deletion")})"
          optional: true
          description: """
                       If requested by `includeDeletions`, the event deletions since `modifiedSince`, ordered by deletion time.
                       """
        ]
      examples: [
        title: "Fetching the last 20 events (default call)"
        params: {}
        result:
          events: [examples.events.picture, examples.events.activity, examples.events.position]
      ,
        title: "cURL for multiple streams"
        params: """
                ```bash
                curl -i "https://${token}@${username}.pryv.me/events?streams[]=diary&streams[]=weight"
                ```
                """
        result:
          events: [examples.events.picture, examples.events.note, examples.events.position, examples.events.mass]
      ,
        title: "cURL with deletions"
        params: """
                ```bash
                curl -i "https://${token}@${username}.pryv.me/events?includeDeletions=true&modifiedSince=#{timestamp.now('-24h')}""
                ```
                """
        result:
          events: [examples.events.mass]
          eventDeletions: [examples.itemDeletions[0], examples.itemDeletions[1], examples.itemDeletions[2]]
      ]

    ,

      id: "events.getOne"
      type: "method"
      title: "Get one event"
      http: "GET /events/{id}"
      description: """
                   Fetches a specific event. This request is mostly used to fetch an event's version history, allowing to review all the modifications to an event's data.
                   """
      params:
        properties: [
          key: "includeHistory"
          type: "boolean"
          optional: true
          description: """
                       If `true`, the event's history will be added to the response. Default: false (don't include the history).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The event.
                       """
        ,
          key: "history"
          type: "array of [events](##{dataStructure.getDocId("event")})"
          optional: true
          description: """
                       If requested by `includeHistory`, the history of the event as an array of events, ordered by modification time.
                       """
        ]
      examples: [
        title: "Fetching an event's version history"
        params: {"includeHistory": true}
        result:
          event: examples.events.noteWithHistory
          history: [
            examples.events.noteHistory1,
            examples.events.noteHistory2
          ]
      ]

    ,

      id: "events.create"
      type: "method"
      title: "Create event"
      http: "POST /events"
      description: """
                   Records a new event, in addition to JSON, this request accepts standard multipart/form-data content to support the creation of event with attached files in a single request. When sending a multipart request, one content part must hold the JSON for the new event and all other content parts must be the attached files.
                   """
      params:
        description: """
                     The new event's data: see [Event](##{dataStructure.getDocId("event")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The created event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The referenced stream is in the trash, and we prevent the recording of new events into trashed streams.
                     """
      ]
      examples: [
        title: "Capturing a simple number value"
        params: _.pick(examples.events.mass, "streamIds", "type", "content")
        result:
          event: examples.events.mass
      ,
        title: "cURL with attachment"
        content: """
                 ```bash
                 curl -i -F 'event={"streamIds":["#{examples.events.picture.streamId}"],"type":"#{examples.events.picture.type}"}'  -F "file=@#{examples.events.picture.attachments[0].fileName}" "https://${token}@${username}.pryv.me/events"
                 ```
                 """
        result:
          event: examples.events.picture
      ]

    ,

      id: "events.update"
      type: "method"
      title: "Update event"
      http: "PUT /events/{id}"
      description: """
                   Modifies the event.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the event's fields: see [event](##{dataStructure.getDocId("event")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      errors: []
      examples: [
        title: "Changing streams"
        params:
          id: "ckbs54rfh0014ik0sabqobcsb"
          update:
            streamIds: ["position"]
        result:
          event: _.defaults({ id: "ckbs54rfh0014ik0sabqobcsb", streamIds: ["position"], streamId: "position", modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.events.position)
      ]

    ,

      id: "events.addAttachment"
      type: "method"
      title: "Add attachment(s)"
      httpOnly: true
      http: "POST /events/{id}"
      description: """
                   Adds one or more file attachments to the event. This request expects standard multipart/form-data content, with all content parts being the attached files.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      examples: [
        title: "cURL"
        content: """
                 ```bash
                 curl -i -F "file=@travel-expense.jpg" "https://${token}@${username}.pryv.me/events/#{examples.events.activityAttachment.id}""
                 ```
                 """
        result:
          event: examples.events.activityAttachment
      ]

    ,

      id: "events.getAttachment"
      type: "method"
      title: "Get attachment"
      httpOnly: true
      http: "GET /events/{id}/{fileId}[/{fileName}]"
      description: """
                   Gets the attached file. Accepts an arbitrary filename path suffix (ignored) for easier link readability.
                   For this function using the `auth` query parameter is not accepted. You can either use the [access token](##{dataStructure.getDocId("access")}) in the `Authorization` header or provide the `readToken` as query parameter.
                   """
      params:
        properties: [
          key: "readToken"
          type: "string"
          http:
            text: "set in request path"
          description: """
                       Required if not using the `Authorization` HTTP header. The file read token to authentify the request. See [`event.attachments[].readToken`](##{dataStructure.getDocId("event")}) for more info.
                       """
        ]
      result:
        http: "200 OK"
        description: """
                     The file's content.
                     """
    ,

      id: "events.deleteAttachment"
      type: "method"
      title: "Delete attachment"
      http: "DELETE /events/{id}/{fileId}"
      description: """
                   Irreversibly deletes the attached file.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ,
          key: "fileId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the attached file.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The updated event.
                       """
        ]
      examples: [
        params:
          id: examples.events.activityAttachment.id
          fileId: examples.events.activityAttachment.attachments[0].id
        result:
          event: _.omit(examples.events.activityAttachment, "attachments")
      ]
    ,

      id: "events.delete"
      type: "method"
      title: "Delete event"
      http: "DELETE /events/{id}"
      description: """
                   Trashes or deletes the specified event, depending on its current state:

                   - If the event is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
                   - If the event is already in the trash, it will be irreversibly deleted (including all its attached files, if any).
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the event.
                       """
        ]
      result: [
        title: "Result: trashed"
        http: "200 OK"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The trashed event.
                       """
        ]
      ,
        title: "Result: deleted"
        http: "200 OK"
        properties: [
          key: "eventDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The event deletion record.
                       """
        ]
      ]
      examples: [
        title: "Trashing"
        params:
          id: examples.events.note.id
        result:
          event: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.events.note)
      ,
        title: "Deleting"
        params:
          id: examples.events.note.id
        result: {eventDeletion:{id:examples.events.note.id}}
      ]
    ]
  ,

  id: "hfs"
  title: "HF events"
  entrepriseOnly: true
  description: """
                Methods to manipulate high-frequency data through HF events and [HF series](##{dataStructure.getDocId("high-frequency-series")}).
               """
  sections: [
      id: "hfs.create"
      type: "method"
      title: "Create HF event"
      http: "POST /events"
      description: """
                   Creates a new event that will be holding [HF series](##{dataStructure.getDocId("high-frequency-series")}).
                   """
      params:
        description: """
                     The new event's data: see [Event](##{dataStructure.getDocId("event")}).

                     The content of HF events is read-only, so you should not provide any content.
                     However, the event type should correspond to the type of the data points in the series, prefixed with `series:`.
                     For example, to store HF series of `mass/kg` data points, the type of the holder event should be `series:mass/kg`.
                     """
      result:
        http: "201 Created"
        properties: [
          key: "event"
          type: "[event](##{dataStructure.getDocId("event")})"
          description: """
                       The created event.
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The referenced stream is in the trash, and we prevent the recording of new events into trashed streams.
                     """
      ,
        key: "invalid-parameters-format"
        http: "400"
        description: """
                     The event content's format is invalid. Events of type High-frequency have a read-only content.
                     """
      ]
      examples: [
        title: "Creating a new HF event that will hold HF series"
        params: _.pick(examples.events.series.holderEvent, "streamIds", "type")
        result:
          event: examples.events.series.holderEvent

      ]

    ,
      id: "hfs.get"
      type: "method"
      httpOnly: true
      title: "Get HF series data points"
      http: "GET /events/{id}/series"
      description: """
                   Retrieves HF series data points from a HF event.
                   Returns data in order of ascending deltaTime between "fromTime" and "toTime".
                   Data is returned as input, no sampling or aggregation is performed.
                   """
      params:
        properties: [
          key: "fromDeltaTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       Only returns data points later than this deltaTime. If no value is given the query will return data starting at the earliest deltaTime in the series.
                       """
        ,
          key: "toDeltaTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       Only returns data points earlier than this deltaTime. If no value is given the server will return only data that is in the past.
                       """
        ]
      result:
        http: "200 OK"
        description: """
              The [HF series data points](##{dataStructure.getDocId("high-frequency-series")}).
              """
      examples: [
        title: "Retrieving HF series data points from a HF event"
        params: {}
        result:
          examples.events.series.position
      ]

    ,

      id: "hfs.add"
      type: "method"
      httpOnly: true
      title: "Add HF series data points"
      http: "POST /events/{id}/series"
      description: """
                   Adds new HF series data points to a HF event.

                   The HF series data will only store one set of values for any given deltaTime. This means you can update existing data points by 'adding' new data with the original deltaTime.  
                   """
      params:
        description: """
                     The new HF series data point(s), see [HF series](##{dataStructure.getDocId("high-frequency-series")}).
                     """
      result:
        http: "200 OK"
        properties: [
          key: "status"
          type: "string"
          description: """
                       The string "ok".
                       """
        ]
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The event is not a HF event.
                     """
      ,
        key: "invalid-operation"
        http: "400"
        description: """
                     The referenced HF event is in the trash, and we prevent the recording of new data points into trashed events.
                     """
      ]
      examples: [
        title: "Adding new HF series data points to a HF event"
        params: examples.events.series.position
        result:
          status: "ok"
      ]

    ,

      id: "hfs.addBatch"
      type: "method"
      httpOnly: true
      title: "Add HF series batch"
      http: "POST /series/batch"
      description: """
                    Adds data to multiple HF series (stored in multiple HF events) in a single atomic operation. This is the fastest way to append data to Pryv; it allows transferring many data points in a single request.

                    For this operation to be successful, all of the following conditions must be fulfilled:

                      - The access token needs write permissions to all series identified by "eventId".
                      - All events referred to must be HF events (type starts with the string "series:").
                      - Fields identified in each individual message must match those specified by the type of the HF event; there must be no duplicates.
                      - All the values in every data point must conform to the type specification.

                    If any part of the batch message is invalid, the entire batch is aborted and the returned result body identifies the error.
                   """
      params:
        properties: [
          key: "format"
          type: "string"
          description: """
                       The format string "seriesBatch".
                       """
        ,
          key: "data"
          type: "array"
          description: """
                       Array of batch entries. Each batch entry is defined as follows:
                       """
          properties: [
            key: "eventId"
            type: "string"
            description: """
                        The id of the HF event.
                        """
          ,
            key: "data"
            type: "object"
            description: """
                        HF series data to add to the HF event.
                        """
          ]
        ]
      result:
        http: "201 Created"
        properties: [
          key: "status"
          type: "string"
          description: """
                       The string "ok".
                       """
        ]
      errors: [
        key: "invalid-request-structure"
        http: "400"
        description: """
                     The request was malformed and could not be executed. The entire operation was aborted.
                     """
      ]
      examples: [
        title: "Adding a batch of HF series data to multiple HF events"
        params: examples.events.series.batch
        result:
          status: "ok"
      ]

    ,

      id: "hfs.update"
      type: "method"
      title: "Update HF event"
      http: "PUT /events/{id}"
      description: """
                    Similar to the standard [Update event](##{_getDocId("events", "events.update")}) method.

                    You may update all non read-only fields, except `content` which is read-only for HF events.
                   """
      errors: [
        key: "invalid-parameters-format"
        http: "400"
        description: """
                     The event content's format is invalid. Events of type High-frequency have a read-only content.
                     """
      ]

    ,

      id: "hfs.delete"
      type: "method"
      title: "Delete HF event"
      http: "DELETE /events/{id}"
      description: """
                   Similar to the standard [Delete event](##{_getDocId("events", "events.delete")}) method.
                   """
  ]

  ,

    id: "streams"
    title: "Streams"
    description: """
                 Methods to retrieve and manipulate [streams](##{dataStructure.getDocId("stream")}).
                 """
    sections: [
      id: "streams.get"
      type: "method"
      title: "Get streams"
      http: "GET /streams"
      description: """
                   Gets the accessible streams hierarchy.
                   """
      params:
        properties: [
          key: "parentId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          optional: true
          description: """
                       The id of the parent stream from which to retrieve streams. Default: `null` (returns all accessible streams from the root level).
                       """
        ,
          key: "state"
          type: "`default`|`all`"
          optional: true
          description: """
                       By default, only items that are not in the trash are returned; `all` return all items regardless of their state.
                       """
        ,
          key: "includeDeletionsSince"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       Whether to include stream deletions since that time for sync purposes.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "streams"
          type: "array of [streams](##{dataStructure.getDocId("stream")})"
          description: """
                       The tree of the accessible streams, sorted by name.
                       """
        ,
          key: "streamDeletions"
          type: "array of [item deletions](##{dataStructure.getDocId("item-deletion")})"
          optional: true
          description: """
                       If requested by `includeDeletionsSince`, the stream deletions since then, ordered by deletion time.
                       """
        ]
      examples: [
        title: "Retrieving streams for work activities"
        params:
          parentId: examples.streams.activities[1].id
        result:
          streams: examples.streams.activities[1].children
      ]

    ,

      id: "streams.create"
      type: "method"
      title: "Create stream"
      http: "POST /streams"
      description: """
                   Creates a new stream.
                   """
      params:
        description: """
                     The new stream's data: see [stream](##{dataStructure.getDocId("stream")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "stream"
          type: "[stream](##{dataStructure.getDocId("stream")})"
          description: """
                       The created stream.
                       """
        ]
      errors: [
        key: "item-already-exists"
        http: "400"
        description: """
                     A similar stream already exists. The error's `data` contains the conflicting properties.
                     """
      ,
        key: "invalid-item-id"
        http: "400"
        description: """
                     The specified id is invalid (e.g. it's a reserved word such as `null`).
                     """
      ]
      examples: [
        title: "Create sub-stream 'white-cells' of 'blood'"
        params: _.pick(examples.streams.healthSubstreams[0], "id", "name", "parentId")
        result:
          stream: examples.streams.healthSubstreams[0]
      ]

    ,

      id: "streams.update"
      type: "method"
      title: "Update stream"
      http: "PUT /streams/{id}"
      description: """
                   Modifies the stream.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the stream.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the stream's fields: see [stream](##{dataStructure.getDocId("stream")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "stream"
          type: "[stream](##{dataStructure.getDocId("stream")})"
          description: """
                       The updated stream (without child streams).
                       """
        ]
      errors: [
        key: "item-already-exists"
        http: "400"
        description: """
                     A similar stream already exists. The error's `data` contains the conflicting properties.
                     """
      ]
      examples: [
        title: "Renaming a stream"
        params:
          id: examples.streams.activities[0].id
          update:
            name: "Slothing"
        result:
          stream: _.defaults({ name: "Slothing", modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, _.omit(examples.streams.activities[0], "children"))
      ]

    ,

      id: "streams.delete"
      type: "method"
      title: "Delete stream"
      http: "DELETE /streams/{id}"
      description: """
                   Trashes or deletes the specified stream, depending on its current state:

                   - If the stream is not already in the trash, it will be moved to the trash (i.e. flagged as `trashed`)
                   - If the stream is already in the trash, it will be irreversibly deleted with its descendants (if any). If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter `mergeEventsWithParent`.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the stream.
                       """
        ,
          key: "mergeEventsWithParent"
          type: "`true`|`false`"
          description: """
                       Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If `true`, the linked events will be assigned to the parent of the deleted item; if `false`, the linked events will be deleted.
                       """
        ]
      result: [
        title: "Result: trashed"
        http: "200 OK"
        properties: [
          key: "stream"
          type: "[stream](##{dataStructure.getDocId("stream")})"
          description: """
                       The trashed stream.
                       """
        ]
      ,
        title: "Result: deleted"
        http: "200 OK"
        properties: [
          key: "streamDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The stream deletion record.
                       """
        ]
      ]
      examples: [
        title: "Trashing"
        params:
          id: examples.streams.health[0].children[2].id
        result:
          stream: _.defaults({ trashed: true, modified: timestamp.now(), modifiedBy: examples.accesses.app.id }, examples.streams.health[0].children[2])
      ,
        title: "Deleting"
        params:
          id: examples.streams.health[0].children[2].id
        result: {streamDeletion:{id:examples.streams.health[0].children[2].id}}
      ]
    ]

  ,

    id: "accesses"
    title: "Accesses"
    description: """
                 Methods to retrieve and manipulate [accesses](##{dataStructure.getDocId("access")}), e.g. for sharing.
                 Any app token can manage shared accesses it created. Full access management is available to personal tokens.
                 """
    sections: [
      id: "accesses.get"
      type: "method"
      title: "Get accesses"
      http: "GET /accesses"
      description: """
                   Gets accesses that were created by your access token, unless you're using a personal token then it returns all accesses.  
                   Only returns accesses that are active when making the request. To include accesses that have expired or were deleted, use
                   the `includeExpired` or `includeDeletions` parameters respectively.
                   """
      params:
        properties: [
          key: "includeExpired"
          type: "boolean"
          optional: true
          description: """
            If `true`, also includes expired accesses. Defaults to `false`.
          """
        ,
          key: "includeDeletions"
          type: "boolean"
          optional: true
          description: """
            If `true`, also includes deleted accesses. Defaults to `false`.
          """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "accesses"
          type: "array of [accesses](##{dataStructure.getDocId("access")})"
          description: """
                       All manageable accesses in the user's account, ordered by name.
                       """
        ,
          key: "accessDeletions"
          type: "array of deleted [accesses](##{dataStructure.getDocId("access")})"
          description: """
                       If requested by `includeDeletions`, the access deletions, ordered by deletion time.
                       """
        ]
      examples: [
        params: {}
        result:
          accesses: [examples.accesses.shared]
      ,
        title: "cURL with deletions"
        params: """
                ```bash
                curl -i "https://${token}@${username}.pryv.me/accesses?includeDeletions=true
                ```
                """
        result:
          accesses: [examples.accesses.shared]
          accessDeletions: [examples.accesses.deleted]
      ]

    ,

      id: "accesses.create"
      type: "method"
      title: "Create access"
      http: "POST /accesses"
      description: """
                   Creates a new access. You can only create accesses whose permissions are a subset of those granted to your own access token.
                   """
      params:
        description: """
                     An object with the new access's data: see [access](##{dataStructure.getDocId("access")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "access"
          type: "[access](##{dataStructure.getDocId("access")})"
          description: """
                       The created access.
                       """
        ]
      errors: [
        key: "invalid-item-id"
        http: "400"
        description: """
                     The specified token is invalid (e.g. it's a reserved word such as `null`).
                     """
      ]
      examples: [
        params: _.pick(examples.accesses.sharedNew, "name", "permissions")
        result:
          access: examples.accesses.sharedNew
      ]

    ,

      id: "accesses.delete"
      type: "method"
      title: "Delete access"
      http: "DELETE /accesses/{id}"
      description: """
                   Deletes the specified access. Personal accesses can delete any access. App accesses can delete shared accesses they created. Deleting an app access deletes the shared ones it created.  
                   All accesses can also perform a self-delete unless a forbidden `selfRevoke` permission has been set.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the access.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "accessDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The deletion record.
                       """
        ,
          key: "relatedDeletions"
          type: "array of [item deletions](##{dataStructure.getDocId("item-deletion")})"
          optional: true
          description: """
                       The deletion records of all the shared accesses that were generated from this app token when deleting it
                       """
        ]
      examples: [
        params:
          id: examples.accesses.app.id
        result: 
          accessDeletion:
            id: examples.accesses.app.id
          relatedDeletions: [
            id: generateId()
          ,
            id: generateId()
          ]
      ]

    ,

      id: "accesses.checkApp"
      type: "method"
      trustedOnly: true
      title: "Check app authorization"
      http: "POST /accesses/check-app"
      description: """
                   For the app authorization process. Checks if the app requesting authorization already has access with the same permissions (and on the same device, if applicable), and returns details of the requested permissions' streams (for display) if not.
                   """
      params:
        properties: [
          key: "requestingAppId"
          type: "string"
          description: """
                       The id of the app requesting authorization.
                       """
        ,
          key: "deviceName"
          type: "string"
          optional: true
          description: """
                       The name of the device running the app requesting authorization, if applicable.
                       """
        ,
          key: "requestedPermissions"
          type: "array of permission request objects"
          description: """
                       An array of permission request objects, which are identical to stream permission objects of [accesses](##{dataStructure.getDocId("access")}) except that each stream permission object must have a `defaultName` property specifying the name the stream should be created with later if missing.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "checkedPermissions"
          type: "array of permission request objects"
          description: """
                       Set if no matching access already exists.
                       A updated copy of the `requestedPermissions` parameter, with the `defaultName` property of stream permissions replaced by `name` for each existing stream (set to the actual name of the item). (For missing streams the `defaultName` property is left untouched.) If streams already exist with the same name but a different `id`, `defaultName` is updated with a valid alternative proposal (in such cases the result also has an `error` property to signal the issue).
                       """
        ,
          key: "mismatchingAccess"
          type: "[access](##{dataStructure.getDocId("access")})"
          description: """
                       Set if an access already exists for the requesting app, but with different permissions than those requested.
                       """
        ,
          key: "matchingAccess"
          type: "[access](##{dataStructure.getDocId("access")})"
          description: """
                       Set if an access already exists for the requesting app with matching permissions. The existing [access](##{dataStructure.getDocId("access")}).
                       """
        ]
      examples: []
    ]
  ,

    id: "getAccessInfo"
    type: "method"
    title: "Access Info"
    http: "GET /access-info"
    description: """
                  Retrieves information about the access in use.
                  """
    result:
      http: "200 OK"
      description: """
            The current [Access properties](##{dataStructure.getDocId("access")}), as well as:
            """
      properties: [
        key: "calls"
        type: "[key-value](##{_getDocId("key-value")})"
        description: "A map of API methods and the number of time each of them was called using the current access."
      ,
        key: "user"
        type: "[key-value](##{_getDocId("key-value")})"
        description: "A map of user account properties."
      ]
    examples: [
      params: {}
      result: examples.accesses.info
    ]
  ,

    id: "audit"
    title: "Audit"
    entrepriseOnly: true
    description: """
                 Methods to retrieve [Audit logs](##{dataStructure.getDocId("audit-log")}).
                 """
    sections: [
      id: "audit.get"
      type: "method"
      title: "Get audit logs"
      http: "GET /audit/logs"
      description: """
                   Fetches accessible audit logs.
                   By default, only returns logs that involve the access corresponding to the provided authorization token (self-auditing).
                   """
      params:
        properties: [
          key: "accessId"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          optional: true
          description: """
                       The id of a specific access to audit.
                       When specified, it fetches the audit logs that involve the matching access instead of the one used to authorize this call.
                       It has to correspond to a sub-access (expired and deleted included) in regards to the provided authorization token.
                       """
        ,
          key: "fromTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The start time of the timeframe you want to retrieve audit logs for.
                       Timestamps are considered with a day precision.
                       """
        ,
          key: "toTime"
          type: "[timestamp](##{dataStructure.getDocId("timestamp")})"
          optional: true
          description: """
                       The end time of the timeframe you want to retrieve audit logs for.
                       Timestamps are considered with a day precision.
                       """
        ,
          key: "status"
          type: "number"
          optional: true
          description: """
                       Filters audit logs by HTTP response status, a 3-digits number.
                       It is possible to provide only the first digit,
                       in which case the two unspecified digits will be wildcarded.
                       For example, `status=4` will return all logs with status between 400 and 499.
                       """
        ,
          key: "ip"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by client IP address present in the `forwardedFor` property.
                       """
        ,
          key: "httpVerb"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by HTTP verb present in the `action` property.
                       """
        ,
          key: "resource"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by API resource present in the `action` property.
                       """
        ,
          key: "errorId"
          type: "string"
          optional: true
          description: """
                       Filters audit logs by error id.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "auditLogs"
          type: "array of [Audit logs](##{dataStructure.getDocId("audit-log")})"
          description: """
                       The accessible audit logs.
                       """
        ]
      errors: [
        key: "forbidden"
        http: "403"
        description: """
                     Authorization token is not authorized to audit the given access.
                     
                     When providing a specific access id, if the result of [Get Accesses](##{_getDocId("accesses", "accesses.get")})
                     using the provided Authorization token does not contain the given access, then it is not auditable.
                     """
        ]
      examples: [
        params: {
          "auth": examples.audit.auth,
          "accessId": examples.audit.log1.accessId,
          "fromTime": 1561000000,
          "toTime": 1562000000,
          "status": examples.audit.log1.status,
          "ip": examples.audit.log1.forwardedFor,
          "httpVerb": "GET",
          "resource": "/events",
          "errorId": examples.audit.log1.errorId
        }

        result:
          auditLogs: [
            examples.audit.log1,
            examples.audit.log2,
            examples.audit.log3
          ]
      ]

    ]

  ,

    id: "webhooks"
    title: "Webhooks"
    entrepriseOnly: true
    description: """
                 Methods to retrieve and manipulate [webhooks](##{dataStructure.getDocId("webhook")}). These methods are only allowed for app and personal accesses.
                 """
    sections: [
      id: "webhooks.get"
      type: "method"
      title: "Get webhooks"
      http: "GET /webhooks"
      description: """
                   Gets manageable webhooks. Only returns webhooks that were created by the access, unless you are using a personal access which returns all existing webhooks in the user's account.
                   """
      params:
        properties: [
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhooks"
          type: "array of [webhooks](##{dataStructure.getDocId("webhook")})"
          description: """
                       All manageable webhooks by the given access, ordered by modified date.
                       """
        ]
      examples: [
        params: {}
        result:
          webhooks: [
            examples.webhooks.simple
          ,
            examples.webhooks.failing
          ]
      ]

    ,
      id: "webhooks.getOne"
      type: "method"
      title: "Get one webhook"
      http: "GET /webhooks/{id}"
      description: """
                   Fetches a specific webhook. Only returns a webhook if it was created by the access, unless you are using a personal access which is allowed to fetch any existing webhook in the user's account.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The webhook.
                       """
        ]
      examples: [
        params: {}
        result:
          webhook: examples.webhooks.simple
      ]

    ,

      id: "webhooks.create"
      type: "method"
      title: "Create webhook"
      http: "POST /webhooks"
      description: """
                   Creates a new webhook. You can only create webhooks with `app` and `shared` accesses.
                   """
      params:
        description: """
                     An object with the new webhook's data: see [webhook](##{dataStructure.getDocId("webhook")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The created webhook.
                       """
        ]
      errors: []
      examples: [
        params: _.pick(examples.webhooks.new, "url")
        result:
          webhook: examples.webhooks.new
      ]

    ,

      id: "webhooks.update"
      type: "method"
      title: "Update webhook"
      http: "PUT /webhooks/{id}"
      description: """
                   Modifies the webhook. You can only modify webhooks with the access that was used to create them, unless you are using a personal token.  
                   Updating the `state` to `active` resets the `currentRetries` counter.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the webhook's fields: see [webhook](##{dataStructure.getDocId("webhook")}). All fields are optional, and only modified values must be included.  
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The updated webhook.
                       """
        ]
      errors: [
        key: "item-already-exists"
        http: "400"
        description: """
                     There is already a webhook for this URL created by the given access.
                     """
      ]
      examples: [
        title: "Reactivating a webhook"
        params: 
          state: 'active'
        result:
          webhook: examples.webhooks.hasFailed
      ]
    
    ,

      id: "webhooks.delete"
      type: "method"
      title: "Delete webhook"
      http: "DELETE /webhooks/{id}"
      description: """
                   Deletes the specified webhook. You can only delete webhooks with the access that was used to create them, unless you are using a personal token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhookDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The deletion record.
                       """
        ]
      examples: [
        params:
          id: examples.webhooks.new.id
        result: {webhookDeletion:{id:examples.webhooks.new.id}}
      ]

    ,

      id: "webhooks.test"
      type: "method"
      title: "Test webhook"
      http: "POST /webhooks/{id}/test"
      description: """
                   Sends a post request containing a message called `test` to the URL of the specified webhook's `url`. You can only test webhooks with the access that was used to create them, unless you are using a personal token.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the webhook.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "webhook"
          type: "[webhook](##{dataStructure.getDocId("webhook")})"
          description: """
                       The webhook.
                       """
        ]
      examples: [
        params: {}
        result:
          webhook: examples.webhooks.new
      ]
      errors: [
        key: "unknown-referenced-resource"
        http: "400"
        description: """
                     The webhook's `url` is either unreachable or responds with a 4xx/5xx status.
                     """
        ]

    ]

  ,

    id: "followed-slices"
    title: "Followed slices"
    trustedOnly: true
    description: """
                 Methods to retrieve and manipulate [followed slices](##{dataStructure.getDocId("followed-slice")}).
                 """
    sections: [
      id: "followedSlices.get"
      type: "method"
      title: "Get followed slices"
      http: "GET /followed-slices"
      description: """
                   Gets followed slices.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "followedSlices"
          type: "array of [followed slices](##{dataStructure.getDocId("followed-slice")})"
          description: """
                       All followed slices in the user's account, ordered by name.
                       """
        ]
      examples: []

    ,

      id: "followedSlices.create"
      type: "method"
      title: "Create followed slice"
      http: "POST /followed-slices"
      description: """
                   Creates a new followed slice.
                   """
      params:
        description: """
                     An object with the new followed slice's data: see [followed slice](##{dataStructure.getDocId("followed-slice")}).
                     """
      result:
        http: "201 Created"
        properties: [
          key: "followedSlice"
          type: "[followed slice](##{dataStructure.getDocId("followed-slice")})"
          description: """
                       The created followed slice.
                       """
        ]
      examples: []

    ,

      id: "followedSlices.update"
      type: "method"
      title: "Update followed slice"
      http: "PUT /followed-slices/{id}"
      description: """
                   Modifies the specified followed slice.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the followed slice.
                       """
        ,
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the followed slice's fields: see [followed slice](##{dataStructure.getDocId("followed-slice")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "followedSlice"
          type: "[followed slice](##{dataStructure.getDocId("followed-slice")})"
          description: """
                       The updated followed slice.
                       """
        ]
      examples: []

    ,

      id: "followedSlices.delete"
      type: "method"
      title: "Delete followed slice"
      http: "DELETE /followed-slices/{id}"
      description: """
                   Deletes the specified followed slice.
                   """
      params:
        properties: [
          key: "id"
          type: "[identifier](##{dataStructure.getDocId("identifier")})"
          http:
            text: "set in request path"
          description: """
                       The id of the followed slice.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "followedSliceDeletion"
          type: "[item deletion](##{dataStructure.getDocId("item-deletion")})"
          description: """
                       The deletion record.
                       """
        ]
      examples: []
    ]

  ,

    id: "profile"
    title: "Profile sets"
    description: """
                 Methods to read and write profile sets. Profile sets are plain key-value stores of user-level settings.
                 """
    sections: [
      id: "profile.getApp"
      type: "method"
      title: "Get app profile"
      http: "GET /profile/app"
      description: """
                   Gets the app's dedicated profile set, which contains app-level settings for the user. Available to app accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The app profile set. (Empty if the app never defined any setting.)
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.app
      ]

    ,

      id: "profile.updateApp"
      type: "method"
      title: "Update app profile"
      http: "PUT /profile/app"
      description: """
                   Adds, updates or delete app profile keys. Available to app accesses.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The updated app profile set.
                       """
        ]
      examples: [
        params:
          setting1: "new value",
          setting2: null
        result:
          profile: _.defaults({setting1: "new value"}, _.omit(examples.profileSets.app, "setting2"))
      ]

    ,

      id: "profile.getPublic"
      type: "method"
      title: "Get public profile"
      http: "GET /profile/public"
      description: """
                   Gets the public profile set, which contains the information the user makes publicly available (e.g. avatar image). Available to all accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The public profile set.
                       """
        ]
      examples: [
        params: {}
        result:
          profile: examples.profileSets.public
      ]

    ,

      id: "profile.updatePublic"
      type: "method"
      title: "Update public profile"
      http: "PUT /profile/public"
      description: """
                   Adds, updates or delete public profile keys. Available to personal accesses.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       An object with the desired key changes (see above).
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The updated public profile set.
                       """
        ]
      examples: []

    ,

      id: "profile.getPrivate"
      type: "method"
      title: "Get private profile"
      http: "GET /profile/private"
      description: """
                   Gets the private profile set. Available to personal accesses.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The private profile set.
                       """
        ]
      examples: []

    ,

      id: "profile.updatePrivate"
      type: "method"
      title: "Update private profile"
      http: "PUT /profile/private"
      description: """
                   Adds, updates or delete private profile keys. Available to personal accesses.

                   - To add or update a key, just set its value
                   - To delete a key, set its value to `null`

                   Existing keys not included in the update are left untouched.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "profile"
          type: "object"
          description: """
                       The updated private profile set.
                       """
        ]
      examples: []
    ]

  ,

    id: "account"
    title: "Account management"
    trustedOnly: true
    description: """
                 Methods to manage the user's account.
                 """
    sections: [
      id: "account.get"
      type: "method"
      title: "Get account information"
      http: "GET /account (DEPRECATED)"
      description: """
                   Retrieves the user's account information.
                   """
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The user's account information.
                       """
        ]
      examples: [
        params: {}
        result:
          account: _.omit(examples.users.one, "id", "password")
      ]

    ,

      id: "account.update"
      type: "method"
      title: "Update account information"
      http: "PUT /account (DEPRECATED)"
      description: """
                   Modifies the user's account information.
                   """
      params:
        properties: [
          key: "update"
          type: "object"
          http:
            text: "request body"
          description: """
                       New values for the account information's fields: see [account information](##{dataStructure.getDocId("account")}). All fields are optional, and only modified values must be included.
                       """
        ]
      result:
        http: "200 OK"
        properties: [
          key: "account"
          type: "[account information](##{dataStructure.getDocId("account")})"
          description: """
                       The updated account information.
                       """
        ]
      examples: [
        params:
          email: examples.users.two.email
        result:
          account: _.omit(examples.users.two, "id", "password")

      ]

    ,

      id: "account.changePassword"
      type: "method"
      title: "Change password"
      http: "POST /account/change-password"
      description: """
                   Modifies the user's password.
                   """
      params:
        properties: [
          key: "oldPassword"
          type: "string"
          description: """
                       The current password.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ]
      result:
        http: "200 OK"
      errors: [
        key: "invalid-operation"
        http: "400"
        description: """
                     The given password does not match.
                     """
      ]
      examples: [
        params:
          oldPassword: examples.users.one.password
          newPassword: "//\\_.:o0o:._//\\"
        result: {}
      ]

    ,

      id: "account.requestPasswordReset"
      type: "method"
      title: "Request password reset"
      http: "POST /account/request-password-reset"
      description: """
                   Requests the resetting of the user's password. An e-mail containing an expiring reset token (e.g. in a link) will be sent to the user.  
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          appId: "my-app-id"
        result: {}
      ]

    ,

      id: "account.resetPassword"
      type: "method"
      title: "Reset password"
      http: "POST /account/reset-password"
      description: """
                   Resets the user's password, authorizing the request with the given reset token (see [request password reset](##{_getDocId("account", "account.requestPasswordReset")}) ).  
                   This method requires that the `appId` and `Origin` (or `Referer`) header comply with the [trusted app verification](##{basics.getDocId("trusted-apps-verification")}).
                   """
      params:
        properties: [
          key: "resetToken"
          type: "string"
          description: """
                       The expiring reset token that was sent to the user after requesting the password reset.
                       """
        ,
          key: "newPassword"
          type: "string"
          description: """
                       The new password.
                       """
        ,
          key: "appId"
          type: "string"
          description: """
                       Your app's unique identifier.
                       """
        ]
      result:
        http: "200 OK"
      examples: [
        params:
          resetToken: "chtplghfp0000hqjx814u6393"
          newPassword: "Dr0ws$4p"
          appId: "my-app-id"
        result: {}
      ]
    ]
  ]

# Returns the in-doc id of the given method, for safe linking from other doc sections
exports.getDocId = (methodId) ->
  result = null
  exports.sections.forEach((section) ->
    methodSection = _.find(section.sections, (subSection) -> subSection.id == methodId)
    if methodSection
      result = helpers.getDocId(exports.id, section.id, methodId)
  )
  return result || throw new Error("Unknown method id")
