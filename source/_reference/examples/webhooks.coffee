timestamp = require("unix-timestamp")
generateId = require("cuid")

idA = generateId()
idB = generateId()

module.exports = exports =
  simple: 
    id: generateId()
    accessId: generateId()
    url: 'https://notifications.service.com/pryv'
    minIntervalMs: 15000
    maxRetries: 5
    currentRetries: 0
    state: 'active'
    runCount: 2
    failCount: 0
    runs: [
      status: 200
      timestamp: timestamp.now('-1h')
    ,
      status: 200
      timestamp: timestamp.now('-2h')
    ]
  
