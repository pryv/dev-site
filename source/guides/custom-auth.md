---
id: custom-auth
title: 'Custom Authentication'
template: default.jade
customer: true
withTOC: true
---

# Introduction

bla bla

# How to use it

## function to implement

It is possible to extend the API and previews servers with your own code, via the configuration keys defined under `customExtensions`:

- `defaultFolder`: The folder in which custom extension modules are searched for by default. Unless defined by its specific setting (see other settings in `customExtensions`), each module is loaded from there by its default name (e.g. `customAuthStepFn.js`), or ignored if missing. Defaults to `{app root}/custom-extensions`.
- `customAuthStepFn`: A Node module identifier (e.g. `/custom/auth/function.js`) implementing a custom auth step (such as authenticating the caller id against an external service). The function is passed the method context, which it can alter, and a callback to be called with either no argument (success) or an error (failure). If this setting is not empty and the specified module cannot be loaded as a function, server startup will fail. Undefined by default.

    ```javascript
    // Example of customAuthStepFn.js
    module.exports = function (context, callback) {
      // do whatever is needed here (check LDAP, custom DB, etc.)
      doCustomParsingAndValidating(context, function (err, parsedCallerId) {
        if (err) { return callback(err); }
        context.originalCallerId = context.callerId;
        context.callerId = parsedCallerId;
        callback();
      });
    };
    ```

    Available context properties (as of now):

    - `username` (string)
    - `user` (object): the user object (properties include `id`)
    - `accessToken` (string): as read in the `Authorization` header or `auth` parameter
    - `callerId` (string): optional additional id passed after `accessToken` in auth after a separating space (auth format is thus `<access-token>[ <caller-id>]`)
    - `access` (object): the access object (see [API doc](https://api.pryv.com/reference/#access) for structure) 

## how to turn it on

- what folder
- reboot services

probably not going into details as such might change and depend on the: setup, version

# Examples

## Authenticate authorization token with Pryv.io

INSERT SCHEMA HERE

Bob wants to create an Access exclusive to Alice.

- 1 Alice creates an Access for verification:

```json
{
  "id": "alices-verification-abc",
  "token": "alices-token",
  "type": "shared",
  "name": "alices-access",
  "permissions": [
    {
      "streamId": "verify",
      "level": "read"
    }
  ],
  // ...
}
```

- 2 Alice provides Bob with:
  - her apiEndpoint: `https://alice.pryv.me/`
  - the `id` of her access: `alices-verification-abc`

- 3 Bob creates an Access for Alice that will be verified by the custom auth step:

```json
{
  "id": "ckdoc7cca0001m1pv5ju4msy5",
  "token": "bobs-token-for-alice",
  "type": "shared",
  "name": "bobs-access-for-alice",
  "permissions": [
    {
      "streamId": "health",
      "level": "read"
    }
  ],
  "clientData": {
    "customAuth": {
      "PryvAuthentication": {
        "apiEndpoint": "https://alice.pryv.me/",
        "id": "alices-verification-abc"
      }
    }
  }
  // ...
}
```

- 4 Alice queries Bob's data with the following headers:

```
Authorization: bobs-token-for-alice
PryvAuthentication: alices-token
```

- 5
- 5.1 The Pryv.io API validates `bobs-token-for-alice`
- 5.2 The custom auth function looks for a field `customAuth:PryvAuthentication` in the retrieved Access' `clientData`
- 5.3 Upon finding it, it fetches Alice's token's information
  
  ```
  GET {API_ENDPOINT}/access-info

  Authorization: alices-token
  ```

- 5.4 It receives the access information:

  ```json
  {
    "id": "alices-verification-abc",
    "token": "alices-token",
    "type": "shared",
    "name": "alices-access",
    "permissions": [
      {
        "streamId": "verify",
        "level": "read"
      }
    ],
    // ...
  }
  ```

- 5.5 It compares the Access `id` with the one that was saved in the clientData. If it matches, it allows permission to the data, otherwise refuses it.

### Accesses

### Custom auth function

```javascript
module.exports = function(context, callback) {
  const http = require('http');
  if (context.access.clientData) {
    // aliceApiEndpoint/access-info?auth=alice_token
    http.get(context.access.clientData["customAuthStep/PryvToken"].apiEndPoint + '/access-info?auth=' + context.callerId, (resp) => {
      //alice accessId == clientData.customAuthStep/PryvToken accessId
      if (resp.headers['pryv-access-id'] == context.access.clientData["customAuthStep/PryvToken"].accessId) {
        return callback()
      }
      callback(new Error('AccessIds do not correpond'))
    }).end();
  } else {
    callback(new Error('no clientData in access'));
  }
};

```

## Authenticate authorization token with external service

TBD or not