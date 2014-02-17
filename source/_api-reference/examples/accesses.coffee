generateId = require("cuid")
timestamp = require("unix-timestamp")

idPersonal = generateId()
idApp = generateId()

module.exports =
  personal:
    id: idPersonal
    token: generateId()
    type: "personal"
    created: timestamp.now('-1M')
    createdBy: "system"
    modified: timestamp.now('-1w')
    modifiedBy: "system"

  app:
    id: idApp
    token: generateId()
    type: "app"
    name: "my-app-id"
    permissions: [
      streamId: "health"
      level: "contribute"
    ]
    created: timestamp.now('-1d')
    createdBy: idPersonal
    modified: timestamp.now('-1d')
    modifiedBy: idPersonal

  shared:
    id: generateId()
    token: generateId()
    type: "shared"
    name: "Arthur"
    permissions: [
      streamId: "family"
      level: "contribute"
    ]
    created: timestamp.now('-12h')
    createdBy: idApp
    modified: timestamp.now('-12h')
    modifiedBy: idApp

  sharedNew:
    id: generateId()
    token: generateId()
    type: "shared"
    name: "For colleagues"
    permissions: [
      streamId: "work"
      level: "read"
    ]
    created: timestamp.now()
    createdBy: idApp
    modified: timestamp.now()
    modifiedBy: idApp
