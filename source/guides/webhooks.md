---
id: webhooks
title: 'Webhooks'
template: default.jade
customer: true
withTOC: true
---

## Target audience

In this guide we address developers that wish to implement notified systems with Webhooks. 
It describes what Webhooks are, why and how they were designed on Pryv.io. It goes through a possible use case to explain how to implement Webhooks with Pryv.io.

## Table of content

1. [Introduction](#introduction)
2. [Webhooks](#webhooks-what-and-why)
  1. [What are Webhooks?](#what-are-webhooks)
  2. [Why using Webhooks?](#why-using-webhooks)
  3. [Why using a notification system?](#why-using-a-notification-system) 
  4. [Separation of reponsibility](#separation-of-reponsibility)
3. [Use case: Counting steps application](#use-case)
4. [Hands-on example](#hands-on-example)
5. [Special features](#special-features)
  1. [Frequency limit](#frequency-limit) 
  2. [Retries](#retries) 
  3. [Reactivation](#reactivation) 
  5. [Stats](#stats) 
  6. [Global parameters](#global-parameters)
  7. [Deletion of the original access](#deletion-of-the-original-access)
6. [Usages](#usages)
  1. [Identifying the user](#identifying-the-user)
  2. [Adding a secret](#adding-a-secret)
7. [Conclusion](#conclusion)

## Introduction

Pryv.io supports webhook integration and therefore allows to notify of data changes. This is extremely useful for your app and your server to get notified as soon as a data change has occured, as it enables to retrieve the up-to-date data directly and to use it in any process or algorithms of your app.

It is no longer necessary to wait until your app or your server goes and checks manually if something new has happened with the data : webhooks update data before you know it.

## Pryv.io Webhooks

### What are Webhooks ?

Webhooks are by definition a way to set up push notifications to an external service. It is triggered by data changes in an account that one wishes to be alerted of, mostly in order to act on it.

### Why using Webhooks ?

Notification systems are used to send and get updates of data changes in real-time. In addition to the Socket.io transport, we have added webhooks to allow push notifications.

You can now setup notifications without requiring to establish a connection and maintain a connection on the client-side. It is recommended for infrequent data updates and scales better for a high volume of users as it is more resource efficient.

### Why only notify of changes? 

Webhooks work through notifications of data changes: in other words, the modified data in itself is not directly shared with the external service, but only the type of resource that was altered.

Providing only an event identifier in the webhook payload will force the recipients to make an API request to fetch the full resource, and will ensure that they are authorized to retrieve the information they are notified about with since they are required to use authorization token.


### Separation of reponsibility 

Importantly, only the app access used to create the webhook (or a personal one) can be used to modify it. This is meant to separate the responsibilities between the webhooks management and services that will consume the data following a notification.

Typically, a certain access will be used to setup one or multiple webhooks per user, while updated data will be fetched using a different set of accesses.

## Use case: Counting steps application

*In this section, we describe a real-life use case : a device (a step counter) connected to a fitness mobile application and the usage of webhooks notifications to alert XXX (find better use case as).*

Let’s imagine that you've created an application storing its data on a Pryv.io platform that tracks the number of steps a user does everyday and you want to be able to notify him when he reaches a certain number of steps during the day.  

Your user wears a step counter, which is connected to your fitness application and sends data on a Pryv.io platform. As soon as your user reaches 10'000 steps a day, you want your server to get notified about it and to send a congratulatory message to your user.

What you need to track is the number of steps your user does, and therefore get notified once he has recorded a certain number of steps to be able to launch your app's process (sending a congratulatory message when the total number of steps sums up to 10'000).

In this case, a webhook will allow to notify a defined service every time a user records a certain number of steps. The service sums up the daily steps and sends a notification to the user on his mobile app when the threshold is reached.

You can easily visualize the whole process on the following schema : 

![Webhook structure in Pryv](/assets/images/Webhook_pryv.png)

1. You first need to create a webhook that will notify your service every time a data change concerning the steps of your app user occurs.
2. You must also provide your service with an access token to retrieve steps information of your app user.
3. Once your user has made some steps, the connected step counter sends the information to your app, which creates an event on the Pryv.io platform.
4. As new data has been posted in the stream about steps, the webhook notifies your service.
5. The server retrieves events since the last change.
6. It performs the implemented process : it sums up the steps of your user, and sends him a congratulatory message on his mobile app when he reaches 10'000 steps (to modify according to use case).

## Hands-on example

*In this section, we will describe how to perform the previous example step-by-step using the Pryv Lab platform.*

Based on the previous use case with the step counter (see the schema above), these are the steps to follow to setup event notifications with webhooks:

1. You first need to create the webhook. You can do so by making an API call on the [webhooks.create](https://api.pryv.com/reference/#create-webhook) route with the necessary parameters. In particular, you need to provide the URL over which the HTTP POST requests will be made. (maybe add code for an HTTP server that reads such notifications)
For example:  
```json
{
  "url": "https://notifications.service.com/pryv/my-username"
}
```

2. You should then provide an Access token to the notified service so that it can retrieve new data when changes occur. You can generate an access token from the [Pryv Access Token Generator](https://api.pryv.com/app-web-access/?pryvServiceInfo=https://reg.pryv.me/service/info).  
You can set the permissions to and leave other parameters unchanged:  
```json
[
  {
    "streamId": "steps-counter",
    "defaultName": "Steps Counter",
    "level": "read"
  }
]
```

3. While the step counter is on, events related to the steps are recorded and added to the `Steps` stream using the [events.create](https://api.pryv.com/reference/#create-event) method.
You can use the following parameters for your steps events:
```json
{
  "streamId": "steps-counter",
  "type": "count/steps",
  "content": 100
  }
```

4. Once the event is created in Pryv.io API, the webhook is triggered. It notifies the external service that an `eventsChanged` has occured in the user account by sending an HTTP POST request to the provided webhook URL.
The request payload will look like this:  
```json
{
  "messages": [
    "eventsChanged"
  ],
  "meta": {
    "apiVersion": "1.4.33",
    "serial": "20190802",
    "serverTime": 1586254000.213
  }
}
```

5. As soon as the server receives the HTTP POST request on the URL, it must retrieve the events since last change from Pryv.io using the provided token.
It does so by performing an HTTP GET request on the events from the stream `steps-counter` using the [events.get](https://api.pryv.com/reference/#get-events) method with the `modifiedSince` parameter set. 
It should then retrieve the new event from the stream `Steps` :
```json
{
  "events": [
    {
      "id": "ck8pqobvr000voopvtlw9ct83",
      "time": 1586254000.167,
      "streamId": "steps-sounter",
      "tags": [],
      "type": "count/steps",
      "content": 100,
      "created": 1586254000.167,
      "createdBy": "ck8pqobua0001oopvu6fhd3a2",
      "modified": 1586254000.167,
      "modifiedBy": "ck8pqobua0001oopvu6fhd3a2"
    } 
  ]
}
```

6. The server processes the data as configured and sends it back to the user app. It can for example send a congratulatory message to the user about the number of steps he did, or perform any algorithm that you may have programmed on the server. (adapt according to new use case)

## Pryv.io Webhook features

*In this section, we give an overview of all the features of the Pryv.io Webhooks.*

### Frequency limit

In case you are dealing with possibly frequent data changes, you might encounter a surge of data changes. In order to avoid notifying the external service too often, webhook executions have a frequency limit `minIntervalMs`. If multiple changes of different resources occur during a short internal, they will be bundled in the `messages` array of the webhook request payload.

The `minIntervalMs` parameter can be configured by the Pryv.io platform administrator.

### Retries

In case of failure to send an HTTP POST request, such as a response status outside the 200-299 range  or timeout, the webhook will retry the request at exponentially increasing intervals.

This backpressure mechanism is in place to allow the external service to stabilise in case it is overloaded.

The number of retries that the webhook will attempt is indicated in its `maxRetries` field, you can monitor its current retry attempt using the `currentRetries` field.

The `maxRetries` parameter can be configured by the Pryv.io platform administrator.

### Reactivation

After a certain amount of consecutive failures to send a request, the webhook will be deactivated and no longer send requests when triggered. This will be indicated by the  `state` parameter which will be set to `inactive` 

It will need to be manually reactivated using the [update.webhook](https://api.pryv.com/reference/#methods-webhooks-webhooks-update) method using the app access that created it or a personal one.

### Stats

Each time a webhook is run, it stores information about the HTTP response status and timestamp, respectively in the  `status` and `timestamp` fields of a `Run` object.

A certain number of `runs` of a webhook are stored in the `runs` field of the Webhook in inverse chronological order (newest first). This parameter allows to monitor a webhook's health.

The latest execution stats can be conveniently accessed in the `lastRun` field.

The number of times the Webhook has been run, including failures, is stored in the parameter `runCount` of the Webhook. Failures count is stored in `failCount`.

The number of stored runs can be configured by the platform administrator.

### Deletion of the original access

In case the app access that has created the webhook is deleted, it does not alter the webhook. It can still be modified using a personal access.

## Usages (find better title)

*In this section, we present possible ways to identify the user from which the data change is originating in the webhook URL and to share a secret between your application and the webhook provider.*

### User identification

In order to idenfy the account which triggered the webhook notification, it is recommended to use the `url` of the webhook. It is possible to store the Pryv.io API endpoint in the URL path or query parameters:

In the path:
```json
{
  "url": "https://my-notifications.com/stefan.pryv.me"
}
```

In the query parameters:
```json
{
  "url": "https://my-notifications.com/?apiEndpoint=stefan.pryv.me"
}
```

### Adding a secret (find better title)

You might need to include a shared secret between your application and the webhook provider in order to control the API usage of your external service.

You can add a "shared secret" to the Pryv.io webhooks that your application trusts. This means that when you will be receiving a webhook notification, you can validate the provided secret and discard the request if it is not trustworthy.

This secret can be provided in the same way as the username, illustrated above. In this example, we use the path parameters to store the secret:  

```json
{
  "url": "https://my-notifications.com/stefan.pryv.me/my-secret"
}
```
## Conclusion

If you wish to set up a Pryv.io webhook or get more information on the data structure, please refer to [its data structure reference](https://api.pryv.com/reference/#webhook), while the methods relative to webhooks can be found in the [API methods section](https://api.pryv.com/reference/#webhooks).