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
    maxFail: 3
    persistentState:
      user:
        heartRateThreshold: 130
    on: ["eventsChanged"]
    processes: [
        name: "get-last-value"
        code: "{
              batch = [{
                method: 'events.get',
                params: {
                  streams: ['heart'],
                  type: 'frequency/bpm',
                  limit: 1
                }
              },
              {
                method: 'events.get',
                params: {
                  streams: ['heart'],
                  type: 'parameters/heart-rate-monitoring',
                  limit: 1
                }
              ];
            }
            "
      ,
        name: "send-alert-if-needed"
        code: "{
              var result = JSON.parse(processesResults['get-last-value'].batchResult.body);
              var lastEvent = result.results[0].events[0];

              persistentState.user.hearRateThreshold = result.results[1].events[0].content;

              if (lastValue.content > persistentState.user.heartRateThreshold) {

                var message = JSON.stringify({
                  heartRate: lastValue.content,
                  time: lastValue.time
                });
                httpRequest = {
                  ssl: true,
                  host: 'sms-alert.com',
                  path: '/alert/api',
                  method: 'POST',
                  port: 443,
                  headers: [
                    {'Content-Type': 'application/json'},
                    {'Content-length': message.length},
                    {'Authorization': 'abcdefghik123'}],
                  body: message
                };
              }
            }
            "
    ]
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id