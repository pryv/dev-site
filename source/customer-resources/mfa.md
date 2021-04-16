---
id: MFA configuration
title: 'Pryv.io Multi-Factor Authentication configuration'
template: default.jade
customer: true
withTOC: true
---

This document describes how to configure Multi-Factor Authentication (MFA) for the Pryv.io [auth.login](https://api.pryv.com/reference/#login-user) API method.

The prerequisite for this is to have an external communication service to send messages over another channel, such as emails or SMS.  
Depending on your service capabilities, you will either use the **single** or the **challenge-verify** mode.

## Flow

### 1. Activation

MFA must be activated per user account. You can implement this in your onboarding flow or at a later time. After obtaining a `personal` token from an [auth.login](https://api.pryv.com/reference/#login-user) API call, you must call the [activate MFA](https://api.pryv.com/reference/#activate-mfa) API method, providing your account's **MFA profile** in the request body.  
The MFA profile is a JSON object with values specific to the account. These values will be substituted to the endpoints' `url`, `body` and `headers` properties in the MFA configuration during the exchanges between the Pryv.io MFA service and your communication service. See 

### 2. Confirmation

### 3. Challenge

### 4. Verification

## Modes

The **single** mode is meant when your communication service only supports sending messages. If it supports creating a challenge and verifying it, you can also use **challenge-verify**.  

In **single** mode, the Pryv.io MFA service generates a secret code, sends it to your communication service upon [activation](/reference/#activate-mfa) and [challenge](/reference/#trigger-mfa-challenge), then verifies it itself during [confirmation](/reference/#confirm-mfa-activation) and [verification](/reference/#verify-mfa-challenge).  

In **challenge-verify** mode, the Pryv.io MFA service makes an HTTP request to your communication service to generate and send a code then forwards it during verification.

The MFA settings are to be set either directly through the platform settings configuration file `platform.yml` or through the admin panel.



## Single

The configuration for single looks like this in the platform.yml file:  

```yaml
MFA_MESSAGE_SETTINGS:
  description: "Allow to configure an external message API handling the MFA flow. See more information on: https://api.pryv.com/customer-resources/mfa/"
  value:
    mode: 'single'
    endpoints:
      single:
        url: 'https://api.smsmode.com/http/1.6/sendSMS.do?language={{ lang }}&auth=my-auth-token'
        method: 'POST'
        body: '{"phone":"{{ phone }}"}'
        headers:
          'content-type': 'application/json'
```

or in the admin panel:

```json
{
  "mode": "single",
  "endpoints": {
    "single": {
      "url": "https://api.smsmode.com/http/1.6/sendSMS.do?language={{ lang }}&auth=my-auth-token",
      "method": "POST",
      "body": "{\"phone\":\"{{ phone }}\"}",
      "headers": {
        "content-type": "application/json"
      }
    }
  }
```

## Endpoints

### Configuration

For single and **challenge-verify** mode, you will have to define how endpoints will be contacted. The configuration for an endpoint looks like this:

```yaml
url: 'https://api.smsapi.com/mfa/codes?language={{ language }}'
method: 'POST'
body: '{"phone":"{{ phone }}"}'
headers:
  authorization: 'Bearer: your-communcation-service-token'
  'content-type': 'application/json'
```

When you will trigger the endpoint, it will make the request according to your settings.

### Profile

When activating MFA for a user account, variables provided in the request body at [activation](/reference/#activate-mfa) will be saved in the user's account. These variables will be substituted in the `url`, `body` and `headers` fields as described below.

Example MFA profile:

```yaml
language: 'en'
phone: '41791231212'
```

### Parameters

#### url

You can provide the URL, with the query parameters here as a string. Variables are substituted in the string.

#### method

Currently supports HTTP POST and GET methods

#### body

The request body that will be sent as a string. Variables are substituted in the string.

#### headers

The request headers that will be sent in the HTTP request. Variables are substituted in the values of these headers are substituted.  
As the request body is a string, you will have to provide the corresponding `content-type` header.

## Examples

### SMS API

Reference: [https://www.smsapi.com/docs/#15-sms-authenticator](https://www.smsapi.com/docs/#15-sms-authenticator)

#### Config

```yaml
mode: 'challenge-verify'
endpoints:
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
    body: '{"phone_number":"{{ number }}"}'
    headers:
      authorization: 'Bearer: your-api-key'
      'content-type': 'application/json'
```

#### Profile

```yaml
number: '41791231212
```

### SMS mode

Reference: [https://www.smsmode.com/api-sms/](https://www.smsmode.com/api-sms/)

SMS mode offers a single API route for sending SMS messages. We use the HTTP GET version to illustrate this method. We have chosen to store the whole message in the user profile

#### Config

```yaml
mode: 'single'
endpoints:
  single:
    url: 'https://api.smsmode.com/http/1.6/sendSMS.do?accessToken=your-api-key&message={{ message }}&emetteur=Pryv%20Lab&numero={{ number }}'
    method: 'GET'
```

#### Profile

```yaml
message: 'Your Pryv Lab MFA code is: {{ token }}'
number: '41791231212'
```