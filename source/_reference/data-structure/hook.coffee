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
               The maximum consecutive failures to tolerate before the system deactivates this hook by setting the status to `faulty`.
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
               An extensible object used to store context values. Developpers are free to add any key - value

               """
  properties: [
    key: "timedExecutionAt"
    optional: true
    readOnly: false
    type: "[timestamp](#data-structure-timestamp)"
    description: """
                 If defined, determines the next execution of this hook. This will be used only if `on` property of [Hook](##{_getDocId("hook")}) is set.
                 """
  ]
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
                 Javascript code to be executed in the scope of persistentState.
                 """
  ]
,
  key: "processError"
  type: "string"
  optional: true
  description: """
               Javascript code to be executed in the scope of persistentState when an error occurs in the execution of one of the previous processes.
               """
]
examples: [
  title: "TODO - example title"
  content: examples.hooks.heartRateAlert
]
