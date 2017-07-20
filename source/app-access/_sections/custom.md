---
order: 3
---

# Custom

Implementing the authorization process and obtaining an access token all by yourself.

**Steps: **

1. start an access request by calling **POST https://access.pryv.me/access**
2. open **response.url**  in a webview
3. poll **response.pollurl** ﻿until you get the an ACCEPTED / REFUSED or ERROR status

## Sequence diagram

![Sequence Diagram](custom-sequence.png)

## Json Examples
You can reporoduce this examples and try other combinations
from [https://sw.pryv.li/access/test.html](https://sw.pryv.li/access/test.html)


### Access request

**request**: `POST https://reg.pryv.me/access`
**payload**:

```
{
  "requestingAppId": "web-page-test",
  "requestedPermissions": [
    {
      "streamId": "diary",
      "defaultName": "Journal",
      "level": "read",
    },
    {
      "streamId": "notes",
      "level": "manage",
      "defaultName": "Notes"
    },
    {
      "streamId": "position",
      "defaultName": "Position",
      "level": "read"
    },
    {
      "streamId": "iphone",
      "level": "manage",
      "defaultName": "iPhone"
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
     "streamId": "diary",
     "defaultName": "Journal",
     "level": "read",
    },
    {
     "streamId": "notes",
     "level": "manage",
     "defaultName": "Notes"
     }
    },
    {
     "streamId": "position",
     "defaultName": "Position",
     "level": "read"
    }
  ],
  "url": "https://sw.pryv.me:2443/access/v1/access.html?lang=en&key=dXRqBezem8v3mNxf&requestingAppId=web-page-test&returnURL=false&domain=pryv.me&registerURL=https%3A%2F%2Freg.pryv.me%3A443&requestedPermissions=%5B%7B%22streamId%22%3A%22diary%22%2C%22defaultName%22%3A%22Journal%22%2C%22level%22%3A%22read%22%2C%22folderPermissions%22%3A%5B%7B%22streamId%22%3A%22notes%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Notes%22%7D%5D%7D%2C%7B%22streamId%22%3A%22position%22%2C%22defaultName%22%3A%22Position%22%2C%22level%22%3A%22read%22%2C%22folderPermissions%22%3A%5B%7B%22streamId%22%3A%22iphone%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22iPhone%22%7D%5D%7D%5D",
  "poll": "https://reg.pryv.me:443/access/dXRqBezem8v3mNxf",
  "returnURL": false,
  "poll_rate_ms": 1000
}
```


### Polling

**request**: GET `https://reg.pryv.me/access/dXRqBezem8v3mNxf`

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


