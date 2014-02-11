generateId = require("cuid")
timestamp = require("pryv-api-server-common").utils.timestamp

idPersonal = generateId()
idApp = generateId()

module.exports =
  personal:
    id: idPersonal
    token: generateId()
    type: "personal"
    created: timestamp.getFromNow(-24 * 30)
    createdBy: "system"
    modified: timestamp.getFromNow(-24 * 7)
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
    created: timestamp.getFromNow(-24)
    createdBy: idPersonal
    modified: timestamp.getFromNow(-24)
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
    created: timestamp.getFromNow(-12)
    createdBy: idApp
    modified: timestamp.getFromNow(-12)
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
    created: timestamp.get()
    createdBy: idApp
    modified: timestamp.get()
    modifiedBy: idApp
