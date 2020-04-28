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

This procedure describes how to perform regular healthcheck API calls to the Pryv.io API in order to remotely monitor its status.

## Domain name

This guide considers the platform using a certain domain name, which will be called `${DOMAIN}`.

## Core hosting name

In a Pryv.io platform, core machines are organized into clusters that we call hostings, each of these has an identifier `${HOSTING_NAME}`, which can be found at the following URL: [https://reg.${DOMAIN}/hostings](https://reg.${DOMAIN}/hostings). The `${HOSTING_NAME}` are the keys of the object `regions:REGION_NAME:zones:ZONE_NAME:hostings`.

## Access token

The API calls for the healthcheck will currently require an access token `${ACCESS_TOKEN}` associated with a dedicated user account. The preparation chapter describes how to obtain it.

## Scope and limitations

The current procedure does not cover how to perform healthchecks per core machine, only per hosting. If you require core-level status, get in touch with your Pryv tech contact.

# Tools

## DNS checks:

- dig version 9.12.3+

## HTTP calls

- cURL v7.54.0+

# Preparation

As the current Pryv.io version does not have dedicated API endpoints for a thorough healthcheck, we create a dedicated user account in order to do so.  
This preparation phase describes how to create an account and obtain a non-expirable token. This must be done once and the username/token pairs stored for automatic API healthcheck calls.

## Create account

We begin by creating an account, we propose to use the following credentials, but these can be modified at the user's discretion:

- **username**: healthmetrics01  
- **password**: healthmetrics01  
- **email**: healthmetrics01@${DOMAIN}  

~~~~~~~~
curl -i -X POST -H 'Content-Type: application/json' \
  -d '{"hosting":"${HOSTING_NAME}", 
  "username": "healthmetrics01",    
  "password":"healthmetrics01",     
  "email": "healthmetrics01@${DOMAIN}", 
  "language": "en",                 
  "appid":"pryv-metrics"}' \
  "https://reg.${DOMAIN}/user/"
~~~~~~~~

If you are using a default configuration, you can use the default web app:

1. Go to [https://sw.${DOMAIN}/access/register.html](https://sw.${DOMAIN}/access/register.html)
2. Fill the fields with:  
  - **email**: healthmetrics01@${DOMAIN}  
  - **username**: healthmetrics01  
  - **password**: healthmetrics01  
  - **password confirmation**: healthmetrics01  

## Create token

In order to obtain a non-expirable access token, we must do 2 calls: first sign in with the user password to obtain a temporary personal token then use it to obtain a non-expirable one.

**- Sign in:**

~~~~~~~~
curl -i -H "Content-Type: application/json" \
  -H "Origin: https://sw.${DOMAIN}" \
  -X POST \
  -d '{"username":"healthmetrics01",
  "password":"healthmetrics01",
  "appId":"pryv-metrics"}' \
  "https://healthmetrics01.${DOMAIN}/auth/login"
~~~~~~~~

The response body should contain a valid personal token under the field `token`:

~~~~~~~~
{
  "meta":
    {
      "apiVersion":"1.3.51",
      "serverTime":1548952964.011
    },
  "token":"${PERSONAL_TOKEN}",
  "preferredLanguage":"en"
}
~~~~~~~~

**- Create token**

~~~~~~~~
curl -i -X POST -H 'Content-Type: application/json' \
  -H 'Authorization: ${PERSONAL_TOKEN}' \
  -d '{"name":"metricsAccess",
  "permissions":[{"streamId":"*","level":"manage"}]}' \
  "https://healthmetrics01.${DOMAIN}/accesses"
~~~~~~~~

The response body should contain a valid access token under the `access:token` field:

~~~~~~~~
{
  "meta":
    {
      "apiVersion":"1.3.51",
      "serverTime":1548953274.902
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
~~~~~~~~

If you are using a default configuration, you can use the default web app:

1. Go to [https://api.pryv.com/app-web-access/?pryv-reg=reg.${DOMAIN}](https://api.pryv.com/app-web-access/?pryv-reg=reg.${DOMAIN})
2. Click on `Master Token` radio button
3. Click on `Request Access` button
4. Click on `Sign in` Pryv button
5. Enter credentials: `healthmetrics01`/`healthmetrics01` in pop-up window
6. Click on `Sign in` button
7. Click on `Accept` button
8. Copy the Access token and save it for this machine's healthchecks, we'll refer to it as `${ACCESS_TOKEN}`

# Healthchecks

## Register

### Call

HTTP GET https://reg.${DOMAIN}/healthmetrics01/check_username

`curl https://reg.${DOMAIN}/healthmetrics01/check_username`

### Expected result

Status: 200

## DNS

### Call

Dig A healthmetrics01.${DOMAIN}

### Expected result

An answer.

## Core

### Call

Authentication header: ${ACCESS_TOKEN}  
HTTP GET https://healthmetrics01.${DOMAIN}/events?limit=1

`curl -i -H 'Authorization: ${ACCESS_TOKEN}' "https://healthmetrics01.${DOMAIN}/events?limit=1"`

### Expected result

Status: 200
