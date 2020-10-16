---
id: consent
title: 'Consent implementation with Pryv.io'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Introduction](#introduction)
2. [GDPR consent principle](#pryv-io-custom-auth-step)
3. [How to collect consent with Pryv.io](#authenticate-data-access-with-pryv-io)
    1. [Consent request](#introduction)
    2. [Hands-on example](#introduction)

## Introduction

The GDPR is the **first privacy regulation** in history with the capacity to enforce both its requirements and its monetary penalties on virtually any company in the world. This means that if you are dealing with personal data, chances are that data privacy is a matter of concern for your company.  

Consent is ultimately necessary to achieve privacy, because this is how individuals exercise control over their personal data. You already know by now that the GDPR will likely affect the way you do business and that there is no way to avoid it, but rather to master it: ["Master the GDPR Compliance Checklist with Pryv"](https://docs.google.com/document/d/16JiKDiJFbkwMGAJmehRJkZ5Wxfm9Lcnz5X4YuHmuBuA/edit).

This guide will focus on how to satisfy the GDPR requirements for consent as a legal basis with Pryv.io.

For more general information about what the GDPR says for Swiss companies, you can read our article ["GDPR, Swiss DPA & ePrivacy – what Swiss companies should know"](https://www.pryv.com/2019/11/20/gdpr-swiss-dpa-e-privacy/). We show [here](https://docs.google.com/document/d/16JiKDiJFbkwMGAJmehRJkZ5Wxfm9Lcnz5X4YuHmuBuA/edit) how you can leverage Pryv.io technology to achieve GDPR compliance while increasing your business efficiency. It goes over the GDPR checklist items point by point to ensure a complete understanding of the law, and shows how Pryv helps you solving it.

## GDPR consent principle

It is against the law to collect or process personal data of EU residents without a valid legal basis for doing so. Before going any further, you will have to establish which legal basis or bases are considered valid for the type of data you process.  
And among them, consent. Consent is one of the six legal bases outlined in [Article 6](https://gdpr-info.eu/art-6-gdpr/) of the GDPR.
 
### Definition

**Consent** under the GDPR is defined as *“any freely given, specific, informed and unambiguous indication of the data subject's wishes by which he or she, by a statement or by a clear affirmative action, signifies agreement to the processing of personal data relating to him or her”* ([Article 4](https://gdpr.eu/article-4-definitions/) of the GDPR).

### Why consent

Consent is one of the easiest legal basis to satisfy because it allows you to freely manipulate the data you collect — provided you clearly explain what you are willing to do and obtain explicit permission from the data subject. Pryv made it easy for you: in the next few paragraphs, we will show you how to achieve privacy by simply building your app/product on top of Pryv.io.

## How to collect consent with Pryv.io

Privacy is embedded as default in Pryv, with dynamic consent as its cornerstone for organizations to account for privacy when building their products and apps on top of Pryv.io.

### Consent request

Data in Pryv.io accounts is organized in streams and events, and accesses are distributed over streams. This means than when you wish to collect/process particular data from your app user, you actually need to request access on the "stream" in which this particular data is located.  

Let's keep things simple for now; thus, suffice to say that consent from the user will focus on "streams". If you wish to learn more about the **Pryv.io Data Model**, you can do so in this [tech guide](https://api.pryv.com/guides/data-modelling/) or [this video](https://www.youtube.com/watch?v=zl9RTf6JTps).

With Pryv.io, we are aiming at implementing a way of collecting consent that is straightforward, transparent, and meets the very specific requirements of the regulation: *freely given, specific, informed and unambiguous*.

Below are the step-by-step instructions on how to request consent from your user:

1. Define the data you are collecting/processing, and check whether it falls under GDPR requirements: [more on the GDPR scope](https://www.pryv.com/2019/11/20/gdpr-swiss-dpa-e-privacy/) and in the [FAQ](https://api.pryv.com/faq-api/#personal-data).

2. Structure your data into streams and events following our [data modelling guide](https://api.pryv.com/guides/data-modelling/).

3. You are now ready to authenticate your app and request consent from your users. We have created a sample web application available [on Github](https://github.com/pryv/app-web-auth3) to register and authenticate your app users in a GDPR-compliant way by requesting their consent. You can test it [here](https://api.pryv.com/app-web-access/?pryvServiceInfoUrl=https://reg.pryv.me/service/info).  

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
- **Consent needs to be distinguishable**: Consent cannot be included "by default" or implicitely in the terms and conditions. Your app users must be provided an opt-in method that requires them to explicitely answer the consent message by selecting the "Reject" or "Accept" button. You must separate your requests for consent from all other matters and make sure that the request is accessible and written in plain language for your app users. 

The parameter `requestedPermissions` of the auth request contains details about the data that will be collected, meaning the concerned streams from the user's Pryv.io account and the level of permission required on these streams (read, write, contribute or manage):

```json
{
    "streamId": "diary",
    "defaultName": "Journal",
    "level": "read"
}
```

4. Once the auth request has been sent, the web page will prompt the user to sign in using his Pryv.io credentials (or to create an account if he doesn't have one).

<p align="center">
<img src="/assets/images/signin.png" />
</p>

5. Once signed in, the consent message will appear.

<p align="center">
<img src="/assets/images/consent_message.png" />
</p>

If the user decides to "Accept" the consent request, the web page will open the authenticated Pryv API endpoint and grant access to the app on the requested streams:

<p align="center">
<img src="/assets/images/apiendpoint.png" />
</p>

### Hands-on example