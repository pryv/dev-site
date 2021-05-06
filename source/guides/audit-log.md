---
id: audit-log
title: 'Audit log'
template: default.jade
customer: true
withTOC: true
---

In this guide we address developers that wish to use audit logs on Pryv.io to capture changes to a system and keep records of the interactions that were made with the data.  
It describes what Audit Logs are, why to use them and how they were designed on Pryv.io. It goes through a possible use case to explain how auditing works with Pryv.io.

## Table of content

1. [Introduction](#introduction)
2. [Audit Logs](#audit-logs)
  1. [What are Audit Logs?](#what-are-audit-logs)
  2. [Why using Audit Logs?](#why-using-audit-logs)
  3. [How are logs organized in Pryv.io?](#how-are-logs-organized-in-pryv.io) 
  4. [Retrieving Audit Logs in Pryv.io](#retrieving-audit-logs-in-pryv.io))
3. [Use case: Keeping track of an API call](#use-case)
4. [Hands-on example](#hands-on-example)
5. [Special features](#special-features)
  1. [API endpoints](#api-endpoint)
  2. [Query parameters](#query-parameters)
  3. [Search interface](#search-interface)
  5. [API results](#api-results) 
  6. [Configuration](#configuration)
7. [Conclusion](#conclusion)

## Introduction

In regards to new requirements on data privacy, you need to be able by now to track all activities related to the personal data you hold on your servers. This includes tracking of consents, data accesses, data retrievals, but also tracking of data changes. 

Audit logs are considered to be the best way of demonstrating compliance – and “demonstrating compliance” is a key point of new privacy regulations. Keeping logs of processes made on personal data is not only a best practice, but a must for you to achieve compliance.

Audit capabilities on Pryv.io now enable you to keep track of data in your system and to generate audit logs.


## Audit Logs

### What are Audit Logs ?

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


### Why using Audit Logs on Pryv.io

*Text to keep or replace by the drawing*

In addition to providing proof of compliance and operational integrity, audit logs can help you monitor activity on your servers :

- by tracking access to data : **who** accessed **what** and **when**. You can track all accesses to data and check that only the authorized users have read the data. 
It can be used to see whether a user account has been hacked, or whether user account privileges were escalated to access specific files or directories with sensitive information. 

- by tracking data changes. One of the principles of GDPR being “integrity”, you have to be able to reconstruct the lifecycle of any data flowing in your system. This means keeping the data correct and logging any modification. 

- by logging GDPR-specific activities, e.g. when a data subject invokes his rights. Each request can be securely logged so that you can prove to authorities the exact sequence of events relating to the particular data subject.

- by logging consent and the accompanying context (date, time, IP address, etc). The consent withdrawal must also be logged, so that the whole history of the consent of the data subject is transparent. This way you will be able to prove to regulators when you had and when you did not have consent for processing.

![Why using Audit Logs](/assets/images/Audit_log_why.png)

### How are logs organized in Pryv.io ?

- Organization of the audit logs per username. In other words, the username, extracted from the log message, will be used as log folder name, so one log folder will be created per username.

- Log rotation explanation ?

### Retrieving Audit Logs in Pryv.io

- should I explain audit API setup, configuration (config file `core/audit/conf/audit.json`)?
- log format (example of syslog entry for an incoming API request or for the execution of a request ?)

Importantly, the logs on Pryv.io can only be fetched by presenting an authorization token, allowing to audit the actions that involved a given token.

## Use case: Keeping track of an API call

Go through Emma use case.

![Use case](/assets/images/use_case_audit.png)

## Hands-on example

Explain the use case with API calls description.

## Special features

### API endpoints

- Provide an 'authorization token' as Authorization header
GET {username}.{domain}/audit/logs
Retrieves log entries from syslog logs for a specific user and current access id.

### Query parameters

- Set several search criteria by providing them as query parameters (examples: Access id, Date: fromTime, toTime, Http code: range or single, details such as forwarded for, action HTTP verb, path or error id)

### Search interface

- Explain the Filter class (instanciated with a map of property:value provided by the Express application after extracting the query parameters.)
- Give some examples ?

### API results

- Log format
- Organization of the log records in a structure similar to Events (with type and content) and accumulated in a result array, possibly streamed.
- Give examples ?

### Configuration

- Log location ?
- Service-core endpoint ?

## Conclusion

If you wish to get more information on the data structure of an `Audit Log` in Pryv.io, please refer to the corresponding section of the [API reference](/reference/#audit-log). 
It describes the main features of the data structure, while the methods relative to audit logs can be found in the [API methods section](/reference/#audit).


