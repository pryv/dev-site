---
id: MFA configuration
title: 'Pryv.io Multi-Factor Authentication configuration'
layout: default.pug
customer: true
withTOC: true
---

This document describes how to configure Multi-Factor Authentication (MFA) for the Pryv.io [auth.login](/reference/#login-user) API method.

The prerequisite for this is to have:

- a running [entreprise version](/concepts/#entreprise-version--open-pryvio) of Pryv.io
- an external communication service to send messages over another channel, such as email or SMS.  

Depending on your communication service capabilities, you will either use the **single** or the **challenge-verify** mode.


## Table of contents <!-- omit in toc -->

1. [Flow](#flow)
   1. [Setup](#setup)
   2. [Usage](#usage)
   3. [Deactivation and recovery](#deactivation-and-recovery)
2. [Modes](#modes)
3. [Configuration](#configuration)
   1. [Template](#template)
   2. [User data](#user-data)
   3. [Parameters](#parameters)
      1. [url](#url)
      2. [method](#method)
      3. [body](#body)
      4. [headers](#headers)
4. [Single](#single)
   1. [Single template](#single-template)
   2. [Single user data](#single-user-data)
5. [Challenge-Verify mode](#challenge-verify-mode)
   1. [Challenge-Verify template](#challenge-verify-template)
   2. [Challenge-Verify user data](#challenge-verify-user-data)
6. [References](#references)


## Flow

You will need to define a template for the API call(s) that will be made to your communication service. The user-specific values that will be substituted in the template will be stored in the user's [private profile](/reference/#get-private-profile).

### Setup

MFA must be activated per user account. You can implement this in your onboarding flow or at a later time.  
After obtaining a `personal` token from an [auth.login](/reference/#login-user) API call, you must call the [activate MFA](/reference/#activate-mfa) API method, providing the user's MFA data. This will trigger the challenge sent to the user.

You should [confirm MFA activation](/reference/#confirm-mfa-activation) by sending the obtained challenge in the payload which will be substituted in the related template. If confirmation is successful, the MFA data provided at activation is saved in the user's [private profile](/reference/#get-private-profile), alongside `recoveryCodes` which you receive for [later deactivation](#deactivation-and-recovery).

### Usage

Once MFA has been activated for an account, you will receive a `mfaToken` each time you perform a [Login user](/reference/#login-with-mfa) API call. You will use it to [Trigger the MFA challenge](/reference/#trigger-mfa-challenge) where data saved in the [private profile](/reference/#get-private-profile) will be sent to your communication service.  
You will send the received challenge the same way you did for confirmation, but this time using the [verify MFA challenge](/reference/#verify-mfa-challenge) route.  

### Deactivation and recovery

You may deactivate MFA using a personal token on the [deactivate MFA](/reference/#deactivate-mfa) API method. If you have lost access to your 2nd factor such as phone or email, you can also use the [recover MFA](/reference/#recover-mfa) route to deactivate it using one of the codes


## Modes

The **single** mode is meant when your communication service only supports sending messages. If it supports creating a challenge and verifying it, you can also use **challenge-verify**.  

In **single** mode, the Pryv.io MFA service generates a secret code, sends it to your communication service upon [activation](/reference/#activate-mfa) and [challenge](/reference/#trigger-mfa-challenge), then verifies it itself during [confirmation](/reference/#confirm-mfa-activation) and [verification](/reference/#verify-mfa-challenge).  

In **challenge-verify** mode, the Pryv.io MFA service makes an HTTP request to your communication service to generate and send a code then forwards it during verification.

The templates  are to be set either directly through the platform settings configuration file `platform.yml` or through the admin panel.


## Configuration

### Template

For **single** and **challenge-verify** mode, you will have to define how endpoints will be contacted. The configuration for an endpoint looks like this:

```yaml
url: 'https://api.smsapi.com/mfa/codes?language={{ language }}'
method: 'POST'
body: '{"phone":"{{ phone }}"}'
headers:
  authorization: 'Bearer: YOUR-COMMUNICATION-SERVER-API-KEY'
  'content-type': 'application/json'
```

### User data

When activating MFA for a user account, variables provided in the request body at [activation](/reference/#activate-mfa) will be saved in the user's account. They look like this:  

```json
{
  "language": "en",
  "phone": "41791231212"
}
```

### Parameters

#### url

You can provide the URL, with the query parameters here as a string. Variables are substituted in the string.

#### method

The HTTP method, currently supports HTTP `POST` and `GET` methods.

#### body

The request body that will be sent, provided as a string. Variables are substituted in the string.

#### headers

The request headers that will be sent in the HTTP request. Variables are substituted in the values of these headers.  
As the request body is a string, you will have to provide the corresponding `content-type` header.


## Single

For **single** mode, you can provide a `{{ code }}` variable which will be substituted with a code generated by the Pryv.io MFA service.  
The example hereafter, stores the message in the user-specific data, where `{{ code }}` substitution also works.

### Single template

The configuration for single mode describes the HTTP request made by the Pryv.io MFA service during [activation](/reference/#activate-mfa) and [challenge](/reference/#trigger-mfa-challenge). It looks like this in the platform.yml file:  

```yaml
single:
  url: 'https://api.smsmode.com/http/1.6/sendSMS.do?accessToken=your-api-key&message={{ message }}&emetteur=Pryv%20Lab&numero={{ number }}'
  method: 'GET'
```

or in the admin panel:

```json
{
  "single": {
    "url": "https://api.smsmode.com/http/1.6/sendSMS.do?accessToken=your-api-key&message={{ message }}&emetteur=Pryv%20Lab&numero={{ number }}",
    "method": "GET"
  }
}
```

### Single user data

with the following user data sent during [activation](/reference/#activate-mfa):

```json
{
  "number":"41791231212",
  "message":"Your%20Pryv%20Lab%20MFA%20code%20is%3A%20{{ code }}"
}
```

Note that the message `Your Pryv Lab MFA code is: {{ code }}` has been URL encoded as it will appear in query parameters, but the `{{ code }}` variable is kept as-is since it must be substituted by the Pryv MFA service.

and [confirmation](/reference/#confirm-mfa-activation) / [verification](/reference/#verify-mfa-challenge):

```json
{
  "code": "12345"
}
```


## Challenge-Verify mode

### Challenge-Verify template

The configuration for challenge-verify mode describes the HTTP requests made by the Pryv.io MFA service during [activation](/reference/#activate-mfa) and [challenge](/reference/#trigger-mfa-challenge) under `challenge` and [confirmation](/reference/#confirm-mfa-activation) and [verification](/reference/#verify-mfa-challenge) under `verify`. It looks like this in the platform.yml file:  

The template looks like this in the `platform.yml` file:  

```yaml
challenge:
  url: 'https://api.smsapi.com/mfa/codes'
  method: 'POST'
  body: '{"phone_number":"{{ number }}"}'
  headers:
    authorization: 'Bearer: your-api-key'
    'content-type': 'application/json'
verify:
  url: 'https://api.smsapi.com/mfa/codes/verifications'
  method: 'POST'
  body: '{"phone_number":"{{ number }}","code":"{{ code }}"}'
  headers:
    authorization: 'Bearer: your-api-key'
    'content-type': 'application/json'
```

or in the admin panel:

```json
{
  "challenge": {
    "url": "https://api.smsapi.com/mfa/codes",
    "method": "POST",
    "body": "{\"phone_number\":\"{{ number }}\"}",
    "headers": {
      "authorization": "Bearer: your-api-key",
      "content-type": "application/json"
    }
  },
  "verify": {
    "url": "https://api.smsapi.com/mfa/codes/verifications",
    "method": "POST",
    "body": "{\"phone_number\":\"{{ number }}\",\"code\":\"{{ code }}\"}",
    "headers": {
      "authorization": "Bearer: your-api-key",
      "content-type": "application/json"
    }
  }
}
```

### Challenge-Verify user data

with the following user data sent during [activation](/reference/#activate-mfa):

```json
{
  "number":"41791231212"
}
```

and [confirmation](/reference/#confirm-mfa-activation) / [verification](/reference/#verify-mfa-challenge):

```json
{
  "code": "12345"
}
```


## References

The aforementionned examples use working templates and user data for:

- SMS API: [https://www.smsapi.com/docs/#15-sms-authenticator](https://www.smsapi.com/docs/#15-sms-authenticator)
- SMS mode: [https://www.smsmode.com/api-sms/](https://www.smsmode.com/api-sms/)
