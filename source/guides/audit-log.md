---
id: audit-log
title: 'Audit log'
template: default.jade
customer: true
withTOC: true
---

https://github.com/pryv/docs-pryv.io/blob/master/pryv.io/pryv.io-audit-api.md
https://github.com/pryv/docs-pryv.io/blob/master/pryv.io/pryv.io-audit.md


## Introduction

In regards to new requirements on data privacy, you need to be able by now to track all activities related to the personal data you hold on your servers. This includes tracking of consents, data accesses, data retrievals, but also tracking of data changes. 

How to answer these points ? 
Audit logs are considered to be the best way of demonstrating compliance – and “demonstrating compliance” is a key point of new privacy regulations. Keeping logs of processes made on personal data is not only a best practice, but a must for you to achieve compliance.

This is why we have added audit capabilities on Pryv.io, which enable you to generate audit logs and help you to keep track of potential security breaches or internal misuses of information.


## Definition

Let’s take a quick overview of what exactly are `Audit logs`.

An audit log shows “who” did “what” activity and “how” the system behaved. It comes in the form of a document that records chronologically all the interactions that were made with the personal data stored on the servers : what resources were accessed, the destination and source addresses, a timestamp and the user login information.

When using Pryv.io, it enables you to keep track of details about the actions performed by clients against Pryv.io accounts through the Pryv.io API. 

You can take a look on how `Audit logs` look like on Pryv.io :

```json
{
  "auditLogs": [
    {
      "id": "ck8g69df1001n1rpv2k650lt3",
      "type": "audit/core",
      "time": 1561988300,
      "forwardedFor": "172.18.0.7",
      "action": "GET /events",
      "query": "streamId=diary",
      "accessId": "ck8g69df1001l1rpvd8u8srl1",
      "status": 403,
      "errorMessage": "Access session has expired.",
      "errorId": "forbidden"
    },
    {
      "id": "ck8g69df1001o1rpvuf1e87s8",
      "type": "audit/core",
      "time": 1561988900,
      "forwardedFor": "172.18.0.7",
      "action": "GET /events",
      "query": "streamId=diary",
      "accessId": "ck8g69df1001l1rpvd8u8srl1",
      "status": 403,
      "errorMessage": "Access session has expired.",
      "errorId": "forbidden"
    },
    {
      "id": "ck8g69df1001p1rpv0gd4kx8k",
      "type": "audit/core",
      "time": 1561989200,
      "forwardedFor": "172.18.0.7",
      "action": "GET /events",
      "query": "streamId=work",
      "accessId": "ck8g69df1001l1rpvd8u8srl1",
      "status": 403,
      "errorMessage": "Access session has expired.",
      "errorId": "forbidden"
    }
  ]
}
```

The available parameters of an `Audit log` in Pryv.io allow you to retrieve exhaustive information about the interactions of your data in Pryv.io. 
It contains the audited action, the IP adress of the client who performed the action, the identifier for the access used to perform the audited action, the time when the action was executed and the result from this action.


## Why using Audit Logs on Pryv.io

%%%work on this part :

Using audit logs on Pryv.io is not only necessary for compliance and auditing capabilities, as it also enables you to :

- Track access to data – **who** accessed **what** and **when**.....you can track all access to data and thus manifest that only the authorized personnel have read the data. 
It can be used to see when a user account may have been hacked, and then if user account privileges were escalated to access specific files or directories with sensitive information. 

- Track data changes – one of the principles of GDPR is “integrity” – you have to keep the data correct, so any modification should be logged. That way, you can reconstruct an old state or prove the modifications that happened for a reason. 
- Log GDPR-specific activities – e.g. when the data subject invokes their rights. Each request can be securely logged so that you can prove to authorities the exact sequence of events relating to the particular data subject

- Log consent and the accompanying circumstances – date, time, IP address, etc. Then you can also log consent withdrawal, and the history of the consent of the data subject will be visible in one place and you will be able to prove to regulators when you had and when you didn’t have consent for processing.


It ensures that the system remains stable and users are held accountable for their actions, which are tracked by event logs. 


## Design

???

Importantly, the logs on Pryv.io can only be fetched by presenting an authorization token, allowing to audit the actions that involved a given token.

## Conclusion

If you wish to get more information on the data structure of an `Audit Log` in Pryv.io, please refer to the corresponding section of the [API reference](/reference/#audit-log). 
It describes the main features of the data structure, while the methods relative to audit logs can be found in the [API methods section](/reference/#audit).


