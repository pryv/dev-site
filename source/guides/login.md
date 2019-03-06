---
id: login
title: 'Login'
template: customer.jade
withTOC: true
---

Once the user account has been created you'll be able to login and obtain a personal access token to manage data in this account.

More information on the different access types can be found on the [API concepts](http://api.pryv.com/concepts/#accesses) page.

The login request will be done toward our custom account for John Smith.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{
         "appId": "my-own-app",
         "username": "jsmith",
         "password": "password"
     }' \
     https://jsmith.pryv.domain/auth/login
```

The answer will contains a token which is a personal token allowing full management of all data for the account.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550832564.509
  },
  "token": "cjsfxo173000111taf99gp3dv",
  "preferredLanguage": "en"
}
```

From now on, to use the token retrieved and authentify each request made to Pryv.io, you'll need to add an `Authorization` header.
