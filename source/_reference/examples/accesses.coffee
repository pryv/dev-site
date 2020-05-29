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

  deleted:
    id: generateId()
    token: generateId()
    type: "shared"
    name: "Health parameters survey"
    permissions: [
      streamId: "health"
      level: "read"
    ]
    created: timestamp.now('-2m')
    createdBy: idApp
    modified: timestamp.now('-2m')
    modifiedBy: idApp  
    deleted: timestamp.now('-1m')

  info:
    id: generateId()
    token: generateId()
    type: "app"
    name: "Current access"
    deviceName: "My awesome device"
    permissions: [
      streamId: "health"
      level: "read"
    ]
    lastUsed: timestamp.now('-5m')
    expires: timestamp.now('-2m')
    deleted: timestamp.now('-1m')
    clientData: {
      consent: "My custom consent message."
    }
    created: timestamp.now('-2m')
    createdBy: idApp
    modified: timestamp.now('-2m')
    modifiedBy: idApp
    calls:
      getAccessInfo:	12
      'profile:get':	5
      'events:get':	12
      'streams:get':	11
      'accesses:get':	6

  createOnly:
    id: generateId()
    token: "mailbox"
    type: "shared"
    name: "publicly available token"
    permissions: [
      streamId: "inbox"
      level: "create-only"
    , 
      feature: "selfRevoke"
      setting: "forbidden"
    ]
    created: timestamp.now('-1d')
    createdBy: idPersonal
    modified: timestamp.now('-1d')
    modifiedBy: idPersonal