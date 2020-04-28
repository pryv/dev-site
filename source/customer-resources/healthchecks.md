---
id: healthchecks
title: 'Pryv.io Healthchecks'
template: default.jade
customer: true
withTOC: true
---

|         |                       |
| ------- | --------------------- |
| Author  | Ilia Kebets 		      |
| Reviewer | Guillaume Bassand (v1-3) |
| Date    | 01.02.2019            |
| Version | 4                    |

Pryv.io Healthchecks
{: .doc_title} 

Procedure & API endpoints  
{: .doc_subtitle}  

# Summary

This procedure describes how to perform regular healthcheck API calls to the Pryv.io API in order to remotely monitor its status. You can directly jump to the [Healthchecks section](#healthchecks) to proceed to the healthchecks.

Please note that the current procedure does not cover how to perform healthchecks per core machine, only per hosting. If you require core-level status, get in touch with your Pryv tech contact.

## Variables

As this guide is platform agnostic, we will use variables `${VARIABLE_NAME}` which must be replaced in the commands.

In particular, the following variables should be replaced :
- the domain name, which will be called `${DOMAIN}`,
- the core machines hostings, identified with a `${HOSTING_NAME}`. In a Pryv.io platform, core machines are organized into clusters that we call hostings. Each of these has an identifier `${HOSTING_NAME}`, which can be found at the following URL: https://reg.${DOMAIN}/hostings. The `${HOSTING_NAME}` are the keys of the object `regions:REGION_NAME:zones:ZONE_NAME:hostings`.
- the access token `${ACCESS_TOKEN}`, associated with a dedicated user account and that will be used in the API calls for healthchecks. The preparation chapter describes how to obtain it.

# Tools

## DNS checks:

- dig version 9.12.3+

## HTTP calls

- cURL v7.54.0+

# Preparation

As the current Pryv.io version does not have dedicated API endpoints for a thorough healthcheck, we create a dedicated user account in order to do so.  
This preparation phase describes how to create an account and obtain a non-expirable token. This must be done once and the username/token pairs stored for automatic API healthcheck calls.

## Create account

We start by creating an account. We propose to use the following credentials, but these can be modified at the user's discretion:

- **username** : healthmetrics
- **password** : healthmetrics
- **email** : healthmetrics01@${DOMAIN}

```json
curl -i -X POST -H 'Content-Type: application/json' \
-d '{"hosting":"${HOSTING_NAME}",
"username": "healthmetrics01",
"password":"healthmetrics01",
"email": "healthmetrics01@${DOMAIN}",
"language": "en",
"appid":"pryv-metrics"}' \
"https://reg.${DOMAIN}/user/"
```

If you are using a default configuration, you can use the default web app:

1. Go to https://sw.${DOMAIN}/access/register.html
2. Fill the fields with:
    - **email** : healthmetrics01@${DOMAIN}
    - **username** : healthmetrics
    - **password** : healthmetrics
    - **password conrmation** : healthmetrics

## Create token

In order to obtain a non-expirable access token, we must do 2 calls: first sign in with the user password to obtain a temporary personal token then use it to obtain a non-expirable one.

**- Sign in:**

```json
curl -i -H "Content-Type: application/json" \
-H "Origin: https://sw.${DOMAIN}" \
-X POST \
-d '{"username":"healthmetrics01",
"password":"healthmetrics01",
"appId":"pryv-metrics"}' \
"https://healthmetrics01.${DOMAIN}/auth/login"
```
The response body should contain a valid personal token under the field `token`:

```json
{
"meta":
{
"apiVersion":"1.3.51",
"serverTime":1548952964.
},
"token":"${PERSONAL_TOKEN}",
"preferredLanguage":"en"
}
```
**- Create token**

```json
curl -i -X POST -H 'Content-Type: application/json' \
-H 'Authorization: ${PERSONAL_TOKEN}' \
-d '{"name":"metricsAccess",
"permissions":[{"streamId":"*","level":"manage"}]}' \
"https://healthmetrics01.${DOMAIN}/accesses"
```
The response body should contain a valid access token under the `access:token` field:

```json
"meta":
{
"apiVersion":"1.3.51",
"serverTime":1548953274.
},
"access":
{
"name":"metricsAccess",
"permissions":
[
{"streamId":"*","level":"manage"}
],
"type":"shared",
"token":"${ACCESS_TOKEN}",
"created":1548953274.877,
"createdBy":"cjrkulo5s00040t0cb5xwlupi",
"modified":1548953274.877,
"modifiedBy":"cjrkulo5s00040t0cb5xwlupi",
"id":"cjrkusc1p00060t0czs7ect45"
}
}
```

If you are using a default configuration, you can use the default web app:

1. Go to https://api.pryv.com/app-web-access/?pryv-reg=reg.${DOMAIN}
2. Click on `Master Token`radio button
3. Click on `Request Access` button
4. Click on `Sign in` Pryv button
5. Enter credentials: `healthmetrics01/healthmetrics01` in the pop-up window
6. Click on `Sign in` button
7. Click on `Accept` button
8. Copy the Access token and save it for this machine's healthchecks. We will refer to it as `${ACCESS_TOKEN}`.

# Healthchecks

## Register

The call to perform: `HTTP GET https://reg.${DOMAIN}/healthmetrics01/check_username`

Run `curl https://reg.${DOMAIN}/healthmetrics01/check_username`

The expected result: `Status: 200`

## DNS

Run `Dig A healthmetrics01.${DOMAIN}`

The expected result:
```
An answer.
```

## Core

Authentication header: `${ACCESS_TOKEN}`

The call to perform: `HTTP GET https://healthmetrics01.${DOMAIN}/events?limit=1`

Run `curl -i -H 'Authorization: ${ACCESS_TOKEN}'`
`"https://healthmetrics01.${DOMAIN}/events?limit=1" `

The expected result: `Status: 200`