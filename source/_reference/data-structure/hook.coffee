helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.hook =
  id: "hook"
  title: "Hook"
  description: """
             See also: [core concepts](/concepts/#hooks).
             """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: "(except at creation)"
    description: """
               The identifier for the hook.
               """
  ,
    key: "name"
    type: "string"
    unique: "among the access\' hooks"
    description: """
               A name identifying the hook. The name must be unique among the access' hooks.
               """
  ,
    key: "status"
    type: "`on`|`off`|`faulty`"
    description: """
               The webhook's status. Can be updated manually. Status `faulty` can be triggered by the system after too many failures occur.
               """
  ,
    key: "timeout"
    type: "number"
    optional: true
    description: """
               In miliseconds, the maximum time allocated to execute the hook. The system provides default and maximum values.
               """
  ,
    key: "maxfail"
    type: "number"
    optional: true
    description: """
               The maximum consecutive failures to tolerate before the system deactivates this hook by setting the status to `faulty`. Set to `-1` to never go faulty.
               """
  ,
    key: "on"
    type: "array of `eventsChanged`|`streamsChanged`|`timer`|`load`|`close`"
    optional: false
    description: """
               The changes or events that will trigger the execution of the hook.

               - *eventsChanged*: One or more event creation or modification occured.
               - *streamsChanged*: One ore more stream creation or modification occured.
               - *timer*: The hook supports triggers from timer (see persistentState:timedExecutionAt).
               - *load*: When the hook is loaded by the system, (can occur after a restart).
               - *close*: When the system is going down, for maintenance as an example (there is no warranty that this will be triggered).
               """
  ,
    key: "persistentState"
    type: "[key-value](##{_getDocId("key-value")})"
    optional: false
    description: """
               An object used to store context values. Developpers are free to add any key-value to the `hookContext` object'.
               See example on the side.
               """
  ,
    key: "processes"
    type: "array of stringified JS code"
    optional: false
    description: """
               A chain of processes that will be executed in sequence.
               """
    properties: [
      key: "name"
      unique: "among the process chain of this hook"
      type: "string"
      description: """
                 An identifier for this process.
                 """
    ,
      key: "code"
      type: "string with valid javascript"
      description: """
                 Javascript code to be executed in a specifc scope. Inside it, you may define or use the following objects:
               - *persistentState*: Key, value object for developper use. See doc before
               - *processesResults*: Holds the results of the previous process in the chain.
                  - processesResults.{process.name}.batchResult (see: BATCH call on API)
                  - httpResult.{process.name}.httpResult
               - *batch*: API [batch call](#call-batch) that will be executed after the process code.
               - *httpRequest*: HTTP request that will be executed after the process code with the following options :
                 - ssl
                 - host
                 - path
                 - method
                 - port
                 - headers
                 - body
               - *log*: logging message that will be printed to the console after the process code.
               - *timedExecutionAt*: timestamp in the serverTime context for the next evaluation of the hook. Only used when `on` hook property define `timer`.
               - *continue*: Each process can stop the exectution of the flow by setting *continue* to false.
                 """
    ]
  ,
    key: "processError"
    type: "code"
    optional: true
    description: """
               Javascript code to be executed in the scope of persistentState when an error occurs in the execution of one of the previous processes.
               An error is defined as following:

               - An uncaught error in the process code execution
               """
  ]
  examples: [
    title: "**Example: keep the last call `events.get` time in order to sync only new events**"
    content: examples.hooks.getLastEvents
  ,
    title: "TODO - example title"
    content: examples.hooks.heartRateAlert
  ]
