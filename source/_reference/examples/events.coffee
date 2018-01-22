timestamp = require("unix-timestamp")
generateId = require("cuid")
accesses = require("./accesses")
streams = require("./streams")

module.exports =
  activity:
    id: generateId()
    time: timestamp.now()
    streamId: streams.activities[0].children[0].id
    tags: []
    type: "activity/pryv"
    content: null
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  activityRunning:
    id: generateId()
    time: timestamp.now()
    duration: null
    streamId: streams.activities[0].children[1].id
    tags: []
    type: "activity/pryv"
    content: null
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  activityAttachment:
    id: generateId()
    time: timestamp.now()
    duration: null
    streamId: streams.activities[1].children[1].id
    tags: []
    type: "activity/pryv"
    content: null
    attachments: [
      id: generateId()
      fileName: "travel-expense.jpg"
      type: "image/jpeg"
      size: 1111
    ]
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  heartRate:
    id: generateId()
    time: 1385046854.282,
    streamId: "heart"
    tags: []
    type: "frequency/bpm"
    content: 90
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  heartSystolic:
    id: generateId()
    time: 1385046854.282
    streamId: "systolic"
    tags: []
    type: "pressure/mmhg"
    content: 120
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  heartDiastolic:
    id: generateId()
    time: 1385046854.282
    streamId: "diastolic"
    tags: []
    type: "pressure/mmhg"
    content: 80
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  mass:
    id: generateId()
    time: timestamp.now()
    streamId: streams.health[0].children[2].id
    tags: []
    type: "mass/kg"
    content: 90
    created: timestamp.now()
    createdBy: accesses.app.id
    modified: timestamp.now()
    modifiedBy: accesses.app.id

  note:
    id: generateId()
    time: timestamp.now('-1h')
    streamId: streams.diary[0].id
    tags: []
    type: "note/text"
    content: "道可道非常道。。。"
    created: timestamp.now('-1h')
    createdBy: accesses.app.id
    modified: timestamp.now('+10h')
    modifiedBy: accesses.app.id
  noteWithHistory:
    id: generateId()
    time: timestamp.now('-1h')
    streamId: streams.diary[0].id
    tags: []
    type: "note/text"
    content: "Hi, I am the latest version of this event"
    created: timestamp.now('-1h')
    createdBy: accesses.app.id
    modified: timestamp.now('+2h')
    modifiedBy: accesses.app.id
  noteHistory1:
    id: generateId()
    time: timestamp.now('-1h')
    streamId: streams.diary[0].id
    tags: []
    type: "note/text"
    content: "Hi, I am the first modification"
    created: timestamp.now('-1h')
    createdBy: accesses.app.id
    modified: timestamp.now('+1h')
    modifiedBy: accesses.app.id
  noteHistory2:
    id: generateId()
    time: timestamp.now('-1h')
    streamId: streams.diary[0].id
    tags: []
    type: "note/text"
    content: "Hi, I was the initial event"
    created: timestamp.now('-1h')
    createdBy: accesses.app.id
    modified: timestamp.now('0h')
    modifiedBy: accesses.app.id

  picture:
    id: generateId()
    time: timestamp.now('-1h')
    streamId: streams.diary[0].id
    tags: []
    type: "picture/attached"
    content: null
    attachments: [
      id: generateId()
      fileName: "photo.jpg"
      type: "image/jpeg"
      size: 2561
    ]
    created: timestamp.now('-1h')
    createdBy: accesses.shared.id
    modified: timestamp.now('-1h')
    modifiedBy: accesses.shared.id

  position:
    id: generateId()
    time: 1350373077.359
    streamId: streams.diary[0].id
    tags: []
    type: "position/wgs84"
    content:
      latitude: 40.714728
      longitude: -73.998672
    created: timestamp.now('-2h')
    createdBy: accesses.personal.id
    modified: timestamp.now('-2h')
    modifiedBy: accesses.personal.id
