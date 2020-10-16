---
id: consent
title: 'Consent implementation with Pryv.io'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Introduction](#introduction)
2. [GDPR consent principle](#gdpr-consent-principle)
3. [How to collect consent with Pryv.io](#how-to-collect-consent-with-pryv-io)
    1. [Consent request](#consent-request)
    2. [Hands-on example](#hands-on-example)

## Introduction

The GDPR is the **first privacy regulation** in history that can enforce both its requirements and its fines on virtually any company in the world. This means that if you are dealing with personal data, data privacy is a matter of concern in any way; and chances are, GDPR compliance specifically is a concern too.

Consent is ultimately necessary to achieve privacy, because this is how individuals exercise control over their personal data. You already know by now that the GDPR will likely affect the way you do business and that there is now way to avoid it, but rather to [master it](https://docs.google.com/document/d/16JiKDiJFbkwMGAJmehRJkZ5Wxfm9Lcnz5X4YuHmuBuA/edit).

This guide will focus on how to satisfy the GDPR requirements for consent as a legal basis with Pryv.io.

For more general information about how the GDPR affects Swiss companies, you can read our article ["GDPR, Swiss DPA & ePrivacy – what Swiss companies should know"](https://www.pryv.com/2019/11/20/gdpr-swiss-dpa-e-privacy/). More generally, we show [here](https://docs.google.com/document/d/16JiKDiJFbkwMGAJmehRJkZ5Wxfm9Lcnz5X4YuHmuBuA/edit) how you can leverage Pryv.io technology to achieve GDPR compliance while increasing your business efficiency. It goes over the GDPR checklist point by point to ensure a global understanding of the law, and shows how Pryv helps you solve it.

## GDPR consent principle

It is against the law to collect or process personal data of EU residents without a valid legal justification for doing so. Before going any further, you will have to establish which legal basis or bases are considered valid for the type of data you process.  
And among them, consent. Consent is one of the six legal bases outlined in [Article 6](https://gdpr-info.eu/art-6-gdpr/) of the GDPR.
 
### Definition

**Consent** under the GDPR is defined as *“any freely given, specific, informed and unambiguous indication of the data subject's wishes by which he or she, by a statement or by a clear affirmative action, signifies agreement to the processing of personal data relating to him or her”* ([Article 4](https://gdpr.eu/article-4-definitions/) of the GDPR).

### Why consent

Consent is one of the most challenging legal basis to satisfy, as it only allows you to collect data for specific purposes the data subject consented to; meaning that you must provide him with a clear explanation on what you are willing to do and obtain explicit permission. Pryv made it easy for you: in the next few paragraphs, we will show you how to achieve privacy by simply building your app/product on top of Pryv.io.

## How to collect consent with Pryv.io

Privacy is embedded as default in Pryv, with dynamic consent as its cornerstone for organizations to account for privacy when building their products and apps on top of Pryv.io.

### Consent request

Data in Pryv.io accounts is organized in streams and events, and accesses are distributed over streams. This means that when you wish to collect/process particular data from your app user, you actually need to request access on the "stream" in which this particular data is located.  

Let's keep things simple for now; thus, suffice to say that consent from the user will focus on "streams". If you wish to learn more about the **Pryv.io Data Model**, you can do so in this [tech guide](https://api.pryv.com/guides/data-modelling/) or [this video](https://www.youtube.com/watch?v=zl9RTf6JTps).

With Pryv.io, we are aiming at implementing a way of collecting consent that is straightforward, transparent, and meets the very specific requirements of the regulation: *freely given, specific, informed and unambiguous*.

Below are the step-by-step instructions on how to request consent from your user:

- **1** Define the data you are collecting/processing, and check whether it falls under GDPR requirements: more on [the GDPR scope here](https://www.pryv.com/2019/11/20/gdpr-swiss-dpa-e-privacy/) and in the [FAQ](https://api.pryv.com/faq-api/#personal-data).

- **2** Structure your data into streams and events following our [data modelling guide](https://api.pryv.com/guides/data-modelling/).

- **3** You are now ready to authenticate your app and request consent from your users. We have created a sample web application available [on Github](https://github.com/pryv/app-web-auth3) to register and authenticate your app users in a GDPR-compliant way by requesting their consent. You can test it [here](https://api.pryv.com/app-web-access/?pryvServiceInfoUrl=https://reg.pryv.me/service/info).  

You will need to customize a few parameters to adapt it to your needs and ensure that you collect data from your users in the right way. In the [auth request](https://api.pryv.com/reference/#auth-request) that the app will perform, the parameter `clientData` will be the one containing the consent information:

```json
{
    "app-web-auth:description":
        {
            "type": "note/txt",
            "content": "This is a consent message."
        }
}
```

The consent request must follow very specific requirements that you need to keep in mind when customizing your consent message:

- **Consent must be informed**: Your app users must be fully informed of the data processing before granting consent. This means that your consent message should notify them of:

    - the name or title of the app/entity processing their data;
    - the purpose and the lawful basis (or bases) for processing their data;
    - the type of data that will be collected/processed. The concerned data streams will need to be described in the parameter `requestedPermissions` of the auth request; 
    - their rights to access, erasure, and withdrawal.
- **Consent needs to be distinguishable**: Consent cannot be included "by default" or implicitly in the terms and conditions. Your app users must be provided an opt-in method that requires them to explicitly answer the consent message by selecting the "Reject" or "Accept" button. You must separate your requests for consent from all other matters and make sure that the request is accessible and written in plain language for your app users. 

The parameter `requestedPermissions` of the auth request contains details about the data that will be collected, meaning the concerned streams from the user's Pryv.io account and the level of permission required on these streams (read, write, contribute or manage):

```json
{
    "streamId": "diary",
    "defaultName": "Journal",
    "level": "read"
}
```


- **4** Once the auth request has been sent, the web page will prompt the user to sign in using his Pryv.io credentials (or to create an account if he doesn't have one).

<p align="center">
<img src="/assets/images/signin.png" />
</p>

- **5** Once signed in, the consent message will appear.

<p align="center">
<img src="/assets/images/consent_message.png" />
</p>

If the user decides to "Accept" the consent request, the web page will open the authenticated Pryv API endpoint and grant access to the app on the requested streams:

<p align="center">
<img src="/assets/images/apiendpoint.png" />
</p>

- **6** You can test the created access by performing a [getAccessInfo](https://api.pryv.com/reference/#access-info) call: `https://ckg9hiq4n008m1ld3uhaxi9yr@mariana.pryv.me/access-info`.

This will return information about the access in use:

```json
{
    "meta": {
        "apiVersion": "1.6.2",
        "serverTime": 1602860299.642,
        "serial": "2019061301"
    },
    "type": "app",
    "name": "demo-request-consent",
    "permissions": [
        {
            "streamId": "diary",
            "level": "read"
        }
    ],
    "id": "ckg9hiq4o008n1ld3xy7t46d6",
    "token": "ckg9hiq4n008m1ld3uhaxi9yr",
    "clientData": {
        "app-web-auth:description": {
            "type": "note/txt",
            "content": "This is a consent message."
        }
    },
    "created": 1602685422.023,
    "createdBy": "ckbi19ena00p11xd3eemmdv2o",
    "modified": 1602685422.023,
    "modifiedBy": "ckbi19ena00p11xd3eemmdv2o",
    "user": {
        "username": "mariana"
    }
}
```

### Hands-on example

Let's illustrate the consent request process with a practical example. Bob wishes to invite Alice on a date to a restaurant but doesn't know her food preferences.
He wants to request access on Alice's stream "Nutrition" to subtly analyze what she likes to eat...How can he do so?  

Both Alice and Bob have already their Pryv.io accounts settled and furnished with structured data (in streams and events). The only thing Bob needs to do is customize the consent message, and send a request to Alice:

- **1** In the sample web app for [authentication](https://github.com/pryv/app-web-auth3), he will set the parameter `Application ID` to his name (corresponding to the app/entity processing the requested data).

He will then write the consent information under the parameter `clientData`:
```json
{
    "app-web-auth:description":
        {
            "type": "note/txt",
            "content": "Hi there! This is Bob. I'd really like to know more about what your tastes and preferences, and I'd need your approval to read personal information from your stream Nutrition. If you consent to share it with me, please click on Accept. 

            You have a certain number of rights under the GDPR: the right to access personal data I may hold about you, the right to request that I amend any personal data which is incorrect or out-dated, and the right to request that I delete any personal information that I have about you. If you'd like to exercise any of these rights, please contact me at bob@privacy.com."
        }
}
```

Of course, Bob can also use interfaces and forms to make it more convenient and easy for Alice to make adjustments, and clickable links directing to simple forms that allow Alice to take a number of different actions and make requests about her personal data.

- **2** In the parameter `requestedPermissions`, Bob will indicate the streams for Alice's Pryv.io account that he would want to access, and the level of permission required on these streams (read, write, contribute or manage):

<p align="center">
<img src="/assets/images/permissions1.png" />
</p>


- **3** By clicking on "Request Access", Alice will be prompted to sign in to her Pryv.io account. Once signed in, she will receive the following consent message:
<p align="center">
<img src="/assets/images/consent2.png" width="300" height="300"/>
</p>

- **4** If she accepts, Bob will receive Alice's Pryv.io API endpoint that will allow him to read the stream "Nutrition": `https://ckgceupbk009u1md3tx9wnseo@alice123.pryv.me/`

<p align="center">
<img src="/assets/images/endpointalice.png" />
</p>

- **5** Bob is now ready to discover what Alice really likes...


<p align="center">
<img src="/assets/images/bigmac.png" />
</p>
