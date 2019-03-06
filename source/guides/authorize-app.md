---
id: authorize-app
title: 'Authorization application'
template: customer.jade
withTOC: true
---

Before being able to access data from a Pryv.io account, an application should be authorized by said account.

To do so, use the access endpoint

```bash
curl -X POST https://access.pryv.domain/access -H 'Content-Type: application/json' \
 -d '{
 "requestingAppId": "demopryv-access",
 "requestedPermissions": [
   {
     "streamId": "heart",
     "level": "manage",
     "defaultName": "Heart"
   }
 ],
 "languageCode": "fr",
 "returnURL": false
}'
```

The server should respond with something similar to this:

```json
{
  "status": "NEED_SIGNIN",
  "code": 201,
  "key": "Rp3NBpMBnkCOuuAo",
  "requestingAppId": "demopryv-access",
  "requestedPermissions": [
    {
      "streamId": "heart",
      "level": "manage",
      "defaultName": "Heart"
    }
  ],
  "url": "https://sw.pryv.me/access/access.html?lang=fr&key=Rp3NBpMBnkCOuuAo&requestingAppId=demopryv-access&returnURL=false&domain=pryv.io&registerURL=https%3A%2F%2Freg.pryv.me%3A443&requestedPermissions=%5B%7B%22streamId%22%3A%22heart%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Heart%22%7D%5D",
  "poll": "https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo",
  "returnURL": false,
  "poll_rate_ms": 1000
}
```

Get the url parameter from the previous response and copy it into your web browser.

```raw
https://sw.pryv.me/access/access.html?lang=fr&key=Rp3NBpMBnkCOuuAo&requestingAppId=demopryv-access&returnURL=false&domain=pryv.io&registerURL=https%3A%2F%2Freg.pryv.me%3A443&requestedPermissions=%5B%7B%22streamId%22%3A%22heart%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Heart%22%7D%5D
```

Sign in with your Pryv account using your own custom login application.

nrigj 4. Click on '**Accept**' button

5. Retrieve the poll url from the previous response.

```json
"poll": "https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo"
```

6. Poll the access token with `GET` calls to the polling url:

```bash
curl -i GET https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo
```

Once the access is generated, you should get a response with status _Accepted_ and containing the token :

```json
{
  "status": "ACCEPTED",
  "username": "demopryv",
  "token": "cjhj7i2821eq60b40dzcdx6gt",
  "code": 200
}
```
