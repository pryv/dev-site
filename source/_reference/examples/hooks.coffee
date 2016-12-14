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
    name: "Heart rate alert"
    status: "on"
    timeout: 100
    maxfail: 3
    on: ["eventsChanged"]
    persistentState: {}
    processes:
      name: "threshold-check"
      code: "some code that checks values from persistentState?"
    processError: "some error, i think it's not required"
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  getLastEvents:
    id: generateId()
    name: "Sample to get last events"
    status: "on"
    timeout: 1000
    maxFail: 5
    on: ["load", "eventsChange"]
    processError: false
    persistentState: {lastGetEventTime : 0 }
    processes: [
     name: "p1"
     code: "
        {
        batch = [{
          method: 'events.get',
          params: {
            modifiedSince: persistentState.lastGetEventTime || 0,
            limit: 1000
          }
        }];
      }"
    ,
      name: "p2"
      code: "{
        var data = JSON.parse(processesResults.p1.batchResult.data);
        if (data.meta) {
          // the data.meta.serverTime is kept for the next synch
          persistentState.lastGetEventTime = data.meta.serverTime;
          var events = data.results[0].events;
          // do something here with the events
          ......"
    ]