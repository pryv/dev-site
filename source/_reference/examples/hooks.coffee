timestamp = require("unix-timestamp")
generateId = require("cuid")
accesses = require("./accesses")
streams = require("./streams")

module.exports =
  process:
    name: 'p1'
    code: 'this.batch = [{ method: \'event.get\', params: {limit: 1}}]'

  heartRateAlert:
    id: generateId()
    name: "heart rate alert"
    status: "on"
    timeout: 100
    maxfail: 3
    on: ["eventsChanged"]
    persistentState:
      timedExecutionAt: timestamp.now('+1h')
      batch: "TODO"
      clientData:
        param1: "value 1"
        param2: "value 2"
    processes:
      name: "threshold-check"
      code: "some code that checks values from persistentState?"
    processError: "some error, i think it's not required"
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id