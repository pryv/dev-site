---
doc: sdk-access
sectionId: Introduction
sectionOrder: 1
---

# Access SDKs

Get an access token.

## <a id="intro-initial-requirements"></a>Initial requirements

### 1- Get an appID 
An appID is a unique string, used to map a set of permissions.  


Ask the dev team: [developers@pryv.com](mailto:developers@pryv.com) for your AppID.

### 2- Define the access permissions you need
As a reference look at [Access Data Structure documentation](reference.html#data-structure-access).

**Exemple**: a contribute access on the diary channel

	[{"channelId" : "diary",
	  "defaultName" : "Journal",
	  "level" : "contribute"}]

**Exemple**: a manage access to the **notes** and **mood** folder of the diary channel.


	[{"channelId" : "diary",
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
     
**Special Note: defaultName**  
*defaultName* is optional and should be adapated in the language of the user.
It will be used only if the channel of folder does not exists and is created in the request process.