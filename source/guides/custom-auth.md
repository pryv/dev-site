---
id: custom-auth
title: 'Custom Authentication'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Introduction](#introduction)
2. [Pryv.io Custom Auth Step](#pryv-io-custom-auth-step)
  1. [Why using a custom auth step](#why-using-a-custom-auth-step)
  2. [What is the custom auth step](#what-is-a-custom-auth-step)
  3. [How to set up the custom auth step](#how-to-set-up-the-custom-auth-step)
3. [Authenticate authorization token with Pryv.io](authenticate-authorization-token-with-pryv-io)
  1. [Hands-on example](#hands-on-example)
4. [Custom Auth Step features](#custom-auth-step-features)
  1. [Accesses](#accesses)
  2. [Custom Authentication function](#custom-authentication-function)
5. [Authenticate authorization token with an external service](authenticate-authorization-token-with-an-external-service)


## Introduction

Authentication allows you to validate the identity of a registered user attempting to access resources. You can add a custom authentication step to your Pryv.io platform that verifies **who** is sending a request to access data.    

In this guide, we explain how to provide your Pryv.io instance with this feature and how to use it through a particular use case. 

## Pryv.io Custom Auth Step

### Why using a custom auth step

In some cases, you might want to verify the identity of the user who is trying to access data from another user, and keep it for auditing. You can keep track of actions performed by clients against Pryv.io accounts using [Pryv.io Audit Capabilities](/reference/#audit-log).  

For example, if a user A needs to access data from another user B in your Pryv.io platform, you can implement an authentication step that will allow you to verify the identity of user A when he tries to access data from user B, and keep the identity of user A in the audit logs. The identity of the requester (user A) can be verified through a custom auth step that you can add to your Pryv.io platform implementation as explained below.

### What is the custom auth step

The function you will implement to augment your Pryv.io platform with authentication capabilities will be part of the custom extension modules that need to be added in your platform configuration.  
It is possible to extend the API and servers with your own code. You can do so by calling it in the configuration file of your Pryv.io platform under the `customExtensions` field:

- `defaultFolder`: The folder in which custom extension modules are searched for by default. Unless defined by its specific setting (see other settings in `customExtensions`), each module is loaded from there by its default name (e.g. `customAuthStepFn.js`), or ignored if missing. Defaults to `{app root}/custom-extensions`.  

- `customAuthStepFn`: A Node module identifier (e.g. `/custom/auth/function.js`) implementing a custom auth step (such as authenticating the caller id against an external service). The function takes the following arguments: the method context, which it can alter, and a callback to be called with either no argument (success) or an error (failure). If this setting is not empty and the specified module cannot be loaded as a function, server startup will fail. Undefined by default.

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
    - `callerId` (string): optional additional id passed after `accessToken` in auth after a separating space (auth format is thus `[<access-token> <caller-id>]`)
    - `access` (object): the access object (see [API doc](https://api.pryv.com/reference/#access) for structure) 

### How to set up the custom auth step

--> Alexandre do you have any idea about the set-up ?

- what folder
- reboot services

probably not going into details as such might change and depend on the: setup, version

## Authenticate authorization token with Pryv.io 

In this section, we illustrate the usage of a custom auth step through a basic use case. Bob wants to share his data with Alice, and creates an access for her on the stream "Health" with a "read" permission (more information on the **Access structure** [here](/reference/#data-structure-access)). 

When Alice is requesting access to this stream, the custom auth step will allow to verify Alice's identity using an access for verification and validate her request. This implies the creation of a "verification" access for Alice that will only be used to validate her identity.

### Hands-on example

The following scheme explains the different steps of the process using Pryv.io custom auth step.  

 </p>
 <p align="center">
<img src="/assets/gifs/alice-bob.gif" />
</p>

Bob wants to create an [Access](/reference/#data-structure-access) exclusive to Alice on his stream "Health" with a "read" permission.

- 1 Alice creates an Access for verification, that will only be used by the custom auth step to validate her identity. It implies the creation of a stream "Verify" dedicated to this process.

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
  - the `id` of her access previously created (see above): `alices-verification-abc`

- 3.1 Bob creates an Access for Alice on the stream "Health" that will be verified by the custom auth step. 
- 3.2 In the `clientData` field, he adds her apiEndpoint and the `id` of her access that she provided him with in the previous step.

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

- 4 Alice queries Bob's data with the following header:

```
[<access-token>: bobs-token-for-alice <caller-id>: alices-token]
```

It should follow the auth format as specified in the `context` properties of the function `customAuthStepFn` (see [previous section](#function-to-implement)): `[<access-token> <caller-id>]` .

- 5 
  - 5.1 The Pryv.io API validates `bobs-token-for-alice`.
  - 5.2 The Custom Authentication function looks for a field `customAuth:PryvAuthentication` in the retrieved Access' `clientData`.
  - 5.3 Upon finding it, it fetches Alice's token's information, using Alice's `apiEndpoint` that is provided in the `clientData` field of Bob's access:
  
  ```
  GET {apiEndpoint}/access-info

  Authorization: alices-token
  ```

  - 5.4 It receives the access information of Alice's verification token:

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

- 6 It compares the retrieved Access `id` with the one that was saved in the `clientData` field under `"id": "alices-verification-abc"`. If it matches, it allows permission to the data, otherwise it refuses it.

## Custom Auth Step features

The implementation of the custom auth step requires the creation of different accesses and the function of authentication itself, that you can customize according to your needs using its `context` argument.

### Accesses

As explained in the example below, granting access to a third party and verifying the accessor's identity implies the creation of two distinct accesses:
- the access to Bob's data, defined by Bob
- the "verification" access, used only to validate Alice's identity, created by Alice

These accesses serve different purposes and should be defined similarly as below:

- 1 Alice's "verification" access that enables Pryv.io custom auth step to validate her identity. A "mock" stream (here the stream "Verify") needs to be created to be able to generate an access on it. The id of this access needs to be communicated to Bob so that he integrates it in the `clientData` field of the access he creates for Alice.

**POST \accesses** for Alice's verification access: 

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

- 2 Bob's access for Alice enables Alice to access one or multiple streams of his Pryv.io data, with different permissions. It has the particularity of having a `clientData` field that contains information to verify Alice's identity: her **apiEndpoint** and the **id** of her "verification" access.  
In our example, Bob's defines an access on his stream "Health" with a "read" permission.

**POST \accesses** for Bob's access: 

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

The custom auth step will retrieve Alice's verification **access id** and compare it to the access id stored in the `clientData` of Bob's access for Alice. If it matches, Alice's identity is verified and the authentication is successful. 

### Custom Authentication function

The Custom Authentication function used by the custom auth step to validate Alice's identity is described below.

```javascript
module.exports = function(context, callback) {
  const http = require('http');
  if (context.access.clientData) {
    // aliceApiEndpoint/access-info?auth=alice_token
    http.get(context.access.clientData["customAuth.PryvAuthentication"].apiEndPoint + '/access-info?auth=' + context.callerId, (resp) => {
      //alice accessId == clientData.customAuth.PryvAuthentication accessId
      if (resp.headers['pryv-access-id'] == context.access.clientData["customAuth.PryvAuthentication"].accessId) {
        return callback()
      }
      callback(new Error('AccessIds do not correpond'))
    }).end();
  } else {
    callback(new Error('no clientData in access'));
  }
};
```
The arguments `context` and `callback` need to be passed as arguments to the method. More on this in the section [above](#what-is-a-custom-auth-step).

```javascript
module.exports = function(context, callback) {
  const http = require('http');
```
The method first verifies that the access (`context` property) has a non empty `clientData` field. If it is the case, an error is thrown:

```javascript
else {
    callback(new Error('no clientData in access'));
```

If it is not the case, it fetches the **apiEndpoint** from `clientData` and performs a [**getAccessInfo call**](/reference/#access-info) with the apiEndpoint and the callerId (`context` property), that corresponds to Alice's token.

```javascript
if (context.access.clientData) {
    // aliceApiEndpoint/access-info?auth=alice_token
    http.get(context.access.clientData["customAuth.PryvAuthentication"].apiEndPoint + '/access-info?auth=' + context.callerId, (resp) => {
```
It then compares the access id for Alice's verification token contained in the `clientData` field and the access id that has been passed in the auth header when requesting access to Bob's data. If it matches, the authentication is successful:

```javascript
{
//alice accessId == clientData.customAuth.PryvAuthentication accessId
if (resp.headers['pryv-access-id'] == context.access.clientData["customAuth.PryvAuthentication"].accessId) {
  return callback()
      
}
```
If it doesn't match, an error is thrown:
```javascript
callback(new Error('AccessIds do not correpond'))
```

## Authenticate authorization token with an external service

In the previous section, we presented a way to perform the authentication step inside Pryv.io by calling a custom module that you can add to your platform.
In some cases, you might want to perform the validation step outside Pryv.io using a third party authentication. This will require the validation of an additional token from the chosen external service using its API.  

We invite you to contact us directly if you wish to implement such a verification with Pryv.io.