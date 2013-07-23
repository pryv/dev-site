---
doc: app-access
sectionId: intro
sectionOrder: 1
---

# THIS SECTION IS OBSOLETE AS OF API v0.5; TODO: update

# App access

Get an access token.

TODO what is an access token and why do I need it?

## <a id="intro-initial-requirements"></a>Initial requirements

### 1. Get a Pryv app id for your app

A Pryv app id is a string uniquely identifying your app. For the moment, just [ask us](mailto:developers@pryv.com) to obtain your app id.

### 2. Define the access permissions you need

See the examples below, as well as the `permissions` property in the [access data structure reference](reference.html#data-structure-access).

#### Example app permissions

A "contribute" access on the "diary" channel:

```json
[{
  "channelId" : "diary",
  "defaultName" : "Journal",
  "level" : "contribute"
}]
```

A "manage" access to the "notes" and "mood" folders of the "diary" channel:

```json
[{
  "channelId" : "diary",
  "defaultName" : "Journal",
  "level" : "read",
  "folderPermissions" : [
    {
      "folderId" : "notes",
      "level" : "manage",
      "defaultName" : "Notes"
    },
    {
      "folderId" : "mood",
      "level" : "manage",
      "defaultName" : "Mood"
    }
  ]
}]
```

**About the `defaultName` property**: `defaultName` is the name you'd like the channel or folder to be created with if it does not exist, and should be in the language of the user. The property is mandatory.
