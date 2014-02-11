timestamp = require("pryv-api-server-common").utils.timestamp
generateId = require("cuid")
accesses = require("./accesses")
streams = require("./streams")

module.exports =
  activity:
    id: generateId()
    time: timestamp.get()
    streamId: streams.activities[0].children[0].id
    tags: []
    type: "activity/pryv"
    content: null
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  activityRunning:
    id: generateId()
    time: timestamp.get()
    duration: null
    streamId: streams.activities[0].children[1].id
    tags: []
    type: "activity/pryv"
    content: null
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  activityAttachment:
    id: generateId()
    time: timestamp.get()
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
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  heartRate:
    id: generateId()
    time: 1385046854.282,
    streamId: "heart"
    tags: []
    type: "frequency/bpm"
    content: 90
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  heartSystolic:
    id: generateId()
    time: 1385046854.282
    streamId: "systolic"
    tags: []
    type: "pressure/mmhg"
    content: 120
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  heartDiastolic:
    id: generateId()
    time: 1385046854.282
    streamId: "diastolic"
    tags: []
    type: "pressure/mmhg"
    content: 80
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  mass:
    id: generateId()
    time: timestamp.get()
    streamId: streams.health[0].children[2].id
    tags: []
    type: "mass/kg"
    content: 90
    created: timestamp.get()
    createdBy: accesses.app.id
    modified: timestamp.get()
    modifiedBy: accesses.app.id

  note:
    id: generateId()
    time: timestamp.getFromNow(-1)
    streamId: streams.diary[0].id
    tags: []
    type: "note/text"
    content: "道可道非常道。。。"
    created: timestamp.getFromNow(10)
    createdBy: accesses.app.id
    modified: timestamp.getFromNow(10)
    modifiedBy: accesses.app.id

  picture:
    id: generateId()
    time: timestamp.getFromNow(-1)
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
    created: timestamp.getFromNow(1)
    createdBy: accesses.shared.id
    modified: timestamp.getFromNow(1)
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
    created: timestamp.getFromNow(-2)
    createdBy: accesses.personal.id
    modified: timestamp.getFromNow(-2)
    modifiedBy: accesses.personal.id
