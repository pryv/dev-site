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
  1. [Frequency limit](#frequency-limit) in order to avoid triggering webhooks too frequently, the webhooks have assessing that limit their execution st a certain min interval betwenn 2 executions.
  2. [Retries](#retries) . si le call POST fait une erreur (autre que statut 200) il va essayer de refaire le call. request sur l'URL. backPressure
  3. [Reactivation](#reactivation) after a certain amount of consectuive failures, webhook turns off.need to be manually reactived with webhook update call.
  5. [Stats](#stats) = runs. chaque webhook stocke pour n executions données (les n dernieres), il va stocker timestamp et le statut de la reponse.
  6. [Global parameters](#global-parameters) = minInterval et maxRetries et nb de runs stockés  sont set par admin de la plateforme. c'est de la config de plateforme. gars qui adminstri.n. URL et state sont les seuls qu'on peut modif.
  7. [Deletion of the original access](#deletion-of-the-original-access) deletion of access used to create webhook - does not delete webhook
6. [Usages](#usages)
  1. [Identifying the user](#identifying-the-user)
  2. [Adding a secret](#adding-a-secret)
7. [Conclusion](#conclusion)

## Introduction

Pryv.io supports webhook integration and therefore allows to notify of data changes. This is extremely useful for your app and your server to get notified as soon as a data change has occured, as it enables to retrieve the up-to-date data directly and to use it in any process or algorithms of your app.

It is no longer necessary to wait until your app or your server goes and checks manually if something new has happened with the data : webhooks update data before you know it.

## Webhooks : What and why ?

### What are Webhooks ?

Webhooks are by definition a way to set up push notifications to an external service. It is triggered by some event that one wishes to be alerted of, mostly in order to act on it. It allows to notify another service in real-time whenever a given event occurs.

### Why using Webhooks ?

Notification systems are extremely useful to send and get updates of data changes in real-time.
Before implementing webhooks on Pryv.io, the API only supported real-time notifications using [Socket.io](https://api.pryv.com/reference/#call-with-websockets).

From now on, one can subscribe to notifications of changes in a web application using websockets, or in a web service using webhooks.

The difference is mainly that websockets will keep a socket open on both the client and the server for the duration of the conversation, while webhooks require a socket to stay open on the server side. On the client side, the socket is only opened up for the request (just like any other HTTP request).

As no persistent connection is required with webhooks, it allows an efficient resources usage. That's also why webhooks will be particularly useful for unfrequent updates of data changes.

### Why using a notification system? 

Webhooks work through notifications of changes : in other words, the modified data in itself is not directly shared with the server, but only the notification about the data change that has occured.  
Since webhook notifications payload only contains metadata and the type of resource that has been modified (`eventsChanged`, `streamsChanged` or `accessesChanged`), sensitive data will then always remain secure. 
Providing only an event identifier in the webhook payload will force the recipients to make an API request to fetch the full resource, and will ensure that they are authorized to retrieve the information they are notified with since they are required to use authorization token.


### Separation of reponsibility 

Importantly, only the access used to create the webhook (or a personal one) can be used to modify it. This is meant to separate the responsibilities between the webhooks management and services that will consume the data following a notification.

Typically, a certain access will be used to setup one or multiple webhooks per user, while updated data will be fetched using a different set of accesses.

## Use case: Counting steps application

*In this section, we describe a real-life use case : the example of a device (a step counter) connected to a fitness application and the integration of webhooks in this particular case.*

Let’s imagine that you've created an application storing its data on a Pryv.io platform that tracks the number of steps a user does everyday and you want to be able to notify him when he reaches a certain number of steps during the day.  

Your user wears a step counter, which is connected to your fitness application and sends data on a Pryv.io platform. As soon as your user reaches 10'000 steps a day, you want your server to get notified about it and to send a congratulatory message to your user.

What you need to track is the number of steps your user does, and therefore get notified once he has recorded a certain number of steps to be able to launch your app's process (sending a congratulatory message when the total number of steps sums up to 10'000).

In this case, a webhook will allow to notify a defined service every time a user records a certain number of steps. The service sums up the daily steps and sends a notification to the user on his mobile app when the threshold is reached.

You can easily visualize the whole process on the following schema : 

![Webhook structure in Pryv](/assets/images/Webhook_pryv.png)

You first need to create a webhook that will notify your server every time a data change concerning the steps of your app user occurs.
You must also provide your server with an access token to retrieve information about the steps of your app user.
Once your user has made some steps, the connected step counter sends the information to your app, which creates an event on the Pryv.io platform in the corresponding stream.
As new data has been posted in the stream about steps, the webhook notifies your server on a predefined URL endpoint.
The server finally retrieves events since last change, and performs the implemented process : it sums up the steps of your user, and sends him a congratulatory message on his mobile app when he reaches 10'000 steps.

## Hands-on example

*In this section, we will describe how to implement the previous example step-by-step in your app using Pryv.io API.*

Based on the previous use case with the step counter (see the schema above), these are the steps to follow to setup event notifications with webhooks:

1. You first need to create the webhook. You can do so by making an API call on the [webhooks.create](https://api.pryv.com/reference/#create-webhook) route with the necessary parameters. In particular, you need to provide the URL over which the HTTP POST requests will be made.
For example:  

```json
{
  "url": "https://notifications.service.com/pryv"
}
```

2. You should then provide an Access token to the notified service so that it can retrieve new data when changes occur. You can easily obtain an access token from the [Pryv Access Token Generator](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me) by following [these steps](https://api.pryv.com/getting-started/#obtain-an-access-token).
The app access will look like the following:
```json
{
  "id": "ck8pqobua0001oopvu6fhd3a2",
  "token": "ck8pqobub0003oopvml08cqq0",
  "type": "app",
  "name": "my-fitness-app",
  "permissions": [
    {
      "streamId": "Steps",
      "level": "read"
    }
  ],
  "created": 1586167600.115,
  "createdBy": "ck8pqobua0000oopvdqm2suho",
  "modified": 1586167600.115,
  "modifiedBy": "ck8pqobua0000oopvdqm2suho"
}
```

3. While the step counter is on, events related to the steps are recorded and added to the `Steps` stream using the [events.create](https://api.pryv.com/reference/#create-event) method.
A new event concerning the number of steps will be posted on the Pryv.io account of the user:
```json
{
  "event": {
    "id": "ck8pqobvr000voopvtlw9ct83",
    "time": 1586254000.167,
    "streamId": "Steps",
    "tags": [],
    "type": "count/steps",
    "content": 100,
    "created": 1586254000.167,
    "createdBy": "ck8pqobua0001oopvu6fhd3a2",
    "modified": 1586254000.167,
    "modifiedBy": "ck8pqobua0001oopvu6fhd3a2"
  }
}
```

4. Once the `count/steps` event is created in Pryv.io API, the webhook is triggered. It notifies the server that a data change has occured in the user account (e.g. a new `count/steps` event has been recorded) by sending an HTTP POST request to the provided webhook URL. This URL acts as a phone number that the other application can call when an event happens.
The webhook notification payload will inform the server that a data change has occured in the events resource (in our case, a new event has been created) :
```json
{
  "messages": [
    "eventsChanged"
  ],
  "meta": {
    "apiVersion": "1.4.11",
    "serial": "20190802",
    "serverTime": 1586254000.213
  }
}
```

5. As soon as the server receives the HTTP POST request on the URL, it retrieves the events since last change from Pryv.io using the provided token.
It does so by performing an HTTP GET request on the events from the stream `Steps` using the [events.get](https://api.pryv.com/reference/#get-events) method. 
It should then retrieve the new event from the stream `Steps` :
```json
{
  "events": [
    {
      "id": "ck8pqobvr000voopvtlw9ct83",
      "time": 1586254000.167,
      "streamId": "steps",
      "tags": [],
      "type": "count/steps",
      "created": 1586254000.167,
      "createdBy": "ck8pqobua0001oopvu6fhd3a2",
      "modified": 1586254000.167,
      "modifiedBy": "ck8pqobua0001oopvu6fhd3a2"
    } 
  ]
}
```

6. The server processes the data as configured and sends it back to the user app. It can for example send a congratulatory message to the user about the number of steps he did, or perform any algorithm that you may have programmed on the server.

## Special features

*In this section, we give an overview of all the special features of the Webhook data structure in Pryv.io.*

### Frequency limit

In case you are dealing with frequent data changes, you might encounter a huge flood of webhooks going back to the system. If they are not processed in a timely manner, it can lead to back pressure on the webhook provider. 
A frequency limit, corresponding to the frequency at which HTTP POST requests are sent, is enforced to avoid triggering webhooks too frequently and to limit unintended abuse of a 3rd-party service.  
This is defined by the `minIntervalMs` parameter of the [Webhook data structure](https://api.pryv.com/reference/#webhook) and corresponds to the minimum interval between HTTP calls in milliseconds. Its value is set by the platform admin.

### Retries

In case of failure to send an HTTP POST request, for example if the system is overwhelmed with webhooks requests or if you are facing network connection issues, the webhook will try to send the request multiple times, each of them separated by a certain interval of time. 
This can eventually lead to timeout errors and issues unless there is a proper fall-back system in place.
This is why the maximal number of retries is fixed, and the webhook will retry `maxRetries` times at a growing interval of time before becoming inactive after too many successive failures. Its value is set by the platform admin.

### Reactivation

After a certain amount of consecutive failures to send a request, the webhook `state` will be set as `inactive` and the webhook will be turned off. An inactive Webhook can no longer make any HTTP call when changes occur. 
It will need to be manually reactivated using the [update.webhook](https://api.pryv.com/reference/#methods-webhooks-webhooks-update) method.

### Stats

Each time a webhook is run, it stores information about the `status`, i.e the HTTP response status of the call, and the `timestamp`, i.e the time the call was started, in a new `Run` object.

All the *n* runs of a webhook are stored in an array `runs` (of length *n*) containing the *n* Run objects of a webhook in inverse chronological order (newest first). This parameter allows to monitor a webhook's health.
The number *n* of runs to be stored is set by the platform admin.
The last Webhook call (newest call) is contained in the parameter `lastRun` of the Webhook, comprised of its HTTP response status and timestamp.
The number of times the Webhook has been run, including failures, is stored in the parameter `runCount` of the Webhook.

### Global parameters

Several parameters of the Webhook can only be set by the platform admin.
This includes the frequency limit of sending requests by a webhook - `minIntervalMs`, the maximal number of retries allowed in case of failure - `maxRetries`, and the number *n* of runs of a webhook to be stored.
Only the parameters `url` and `state` of the Webhook can be updated using the [update.webhook](https://api.pryv.com/reference/#methods-webhooks-webhooks-update) method. 

### Deletion of the original access

In case the access that has originally created the Webhook is deleted, it does not cancel the resulting Webhook.

## Usages

*In this section, we present possible ways to identify the user from which the data change is originating in the webhook URL and to share a secret between your application and the webhook provider.*

### Identifying the user 

When a data change occurs on a user account, the webhook will notify your server by sending an HTTP POST request on the provided URL endpoint, for example on **https://notifications.service.com/pryv**.
The webhook notification payload is yet very basic and only contains the information that a resource has been modified (`eventsChanged`, `accessChanged`or `streamsChanged`), without identifying the source account of the data change.
Your server will then need an access token and a username to retrieve information about the data change from the source account.
As the access token should have already been provided to the service at the webhook creation, it needs now to identify the source of the webhook. You will have to make your server able to identify the source account : to do so, you can use the `url`'s hostname, path or query parameters to provide the server with the `username` to be used for data retrieval. 

For example in the host name :
```json
{
  "url": "https://${username}.my-notifications.com/"
}
```

In the path parameter :
```json
{
  "url": "https://my-notifications.com/${username}"
}
```

Or in the query parameter :
```json
{
  "url": "https://my-notifications.com/?username=${username}"
}
```

## Adding a secret

You might need to include a shared secret between your application and the webhook provider. Typically, this is done as a query parameter in the callback URL string. 

You can add a "shared secret" to the webhook provider that your application knows and trusts. This means that when you will be receiving a webhook from that provider, you can check for that shared secret and if it’s not present, then you can assume that the originator of that webhook is not trustworthy.

This secret can be contained in a query parameter *${my-secret}* of the URL endpoint on which the webhook will be sending requests, for example :

```json
{
  "url": "https://${username}.my-notifications.com/${my-secret}/"
}
```
Each time the webhook will be sending a request, it will need to provide the query parameter *${my-secret}* in the URL to be authenticated and trusted by your application. This allows for more traceability and implements security and verification mechanisms into your system.

## Conclusion

If you wish to set up a `Webhook` or get more information on the data structure, please refer to the corresponding section of the [API reference](https://api.pryv.com/reference/#webhook). 
It describes the main features of the data structure, while the methods relative to webhooks can be found in the [API methods section](https://api.pryv.com/reference/#webhooks).