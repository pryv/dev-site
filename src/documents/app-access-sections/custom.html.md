---
doc: app-access
sectionId: custom
sectionOrder: 10
---

**THIS SECTION IS OBSOLETE AS OF API v0.5; TODO: update**

# Custom

Implementing the authorization process and obtaining an access token all by yourself.

**For testing: **
Use our staging servers: https://access.rec.la/access


**Steps: **

1. start an access request by calling **POST https://access.pryv.io/access**
2. open **response.url**  in a webview
3. poll **response.pollurl** ﻿until you get the an ACCEPTED / REFUSED or ERROR status

## Sequence diagram

![Sequence Diagram](app-access-files/custom-sequence.png)

## Json Examples
You can reporoduce this examples and try other combinations
from [https://sw.rec.la/access/test.html](https://sw.rec.la/access/test.html)


### Access request

**request**: `POST https://reg.rec.la/access`
**payload**:

```
{
  "requestingAppId": "web-page-test",
  "requestedPermissions": [
    {
      "channelId": "diary",
      "defaultName": "Journal",
      "level": "read",
      "folderPermissions": [
        {
          "folderId": "notes",
          "level": "manage",
          "defaultName": "Notes"
        }
      ]
    },
    {
      "channelId": "position",
      "defaultName": "Position",
      "level": "read",
      "folderPermissions": [
        {
          "folderId": "iphone",
          "level": "manage",
          "defaultName": "iPhone"
        }
      ]
    }
  ],
  "languageCode": "en",
  "returnURL": false
}
```


**response**:

```
{
  "status": "NEED_SIGNIN",
  "code": 201,
  "key": "dXRqBezem8v3mNxf",
  "requestingAppId": "web-page-test",
  "requestedPermissions": [
    {
      "channelId": "diary",
      "defaultName": "Journal",
      "level": "read",
      "folderPermissions": [
        {
          "folderId": "notes",
          "level": "manage",
          "defaultName": "Notes"
        }
      ]
    },
    {
      "channelId": "position",
      "defaultName": "Position",
      "level": "read",
      "folderPermissions": [
        {
          "folderId": "iphone",
          "level": "manage",
          "defaultName": "iPhone"
        }
      ]
    }
  ],
  "url": "https://sw.rec.la:2443/access/v1/access.html?lang=en&key=dXRqBezem8v3mNxf&requestingAppId=web-page-test&returnURL=false&domain=rec.la&registerURL=https%3A%2F%2Freg.rec.la%3A443&requestedPermissions=%5B%7B%22channelId%22%3A%22diary%22%2C%22defaultName%22%3A%22Journal%22%2C%22level%22%3A%22read%22%2C%22folderPermissions%22%3A%5B%7B%22folderId%22%3A%22notes%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Notes%22%7D%5D%7D%2C%7B%22channelId%22%3A%22position%22%2C%22defaultName%22%3A%22Position%22%2C%22level%22%3A%22read%22%2C%22folderPermissions%22%3A%5B%7B%22folderId%22%3A%22iphone%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22iPhone%22%7D%5D%7D%5D",
  "poll": "https://reg.rec.la:443/access/dXRqBezem8v3mNxf",
  "returnURL": false,
  "poll_rate_ms": 1000
}
```


### Polling

**request**: GET `https://reg.rec.la/access/dXRqBezem8v3mNxf`

3 response codes:

**1 response**: `NEED_SIGNIN`

Content is the same than for the initial POST request.
**poll** and **poll_rate_ms** may vary

**2 response**: 200 `ACCEPTED`

```
{
  "status": "ACCEPTED",
  "username": "jondoe",
  "token": "VTR7DOKN1J",
  "code": 200
}
```

**3 response**: 403 `REFUSED`

```
{
  "status": "REFUSED",
  "reasonID": "REFUSED_BY_USER",
  "message": "access refused by user",
  "code": 403
}
```


