---
id: webhooks
title: 'Webhooks'
template: default.jade
customer: true
withTOC: true
---

## Target audience

developers implementing notified system with webhooks

## Content

1. quick intro on notifications
2. webhooks: what, why
  1. what they are
  2. why use them instead of socket.io
  3. why not sending all data but notification only
  4. separation of reponsibility
3. use case: counting steps
  explain with schema
4. on hands example: step by step with API method links and payload examples
5. special features
  1. frequency limit
  2. retries
  3. reactivation
  5. stats
  6. global parameters
  4. deletion of access used to create webhook - does not delete webhook
6. Usages
  1. identify user: use include it in webhooks's URL: domain, path or query params
  2. add secret in query param

## Introduction

Pryv.io supports webhook integration and therefore allows to notify of data changes.

But what exactly are Webhooks ?

## Definition

Webhooks are by definition a way to set up push notifications to an external service. It is triggered by some event that one wishes to be alerted of, mostly in order to act on it. It allows to notify another service in real-time whenever a given event occurs.

For example, let’s imagine that you've created an application storing its data on a Pryv.io platform that tracks the number of steps a user does everyday and you want to be able to notify him when he reaches a certain number of steps during the day.  
What a webhook does is notify a defined service every time a user records a certain number of steps, the service sums up the daily steps and sends a notification to the user on his mobile app when the threshold is reached.

These are the steps to follow to setup event notifications with webhooks:

1. You first need to create the webhook. You can do so by making an API call on the [webhooks.create](https://api.pryv.com/reference/#create-webhook) route with the necessary parameters. In particular, you need to provide the URL over which the HTTP POST requests will be made.
For example:  

```json
{
  "url": "https://notifications.service.com/pryv"
}
```

2. You should then provide an Access token to the notified service so it can retrieve new data when changes occur. You can easily obtain an access token from the [Pryv Access Token Generator](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me) by following [these steps](https://api.pryv.com/getting-started/#obtain-an-access-token).

3. While the step counter is on, events related to the steps are recorded and added to the `Activity` stream using the [events.create](https://api.pryv.com/reference/#create-event) method.

4. Once the `count/step` event is created in Pryv.io API, the webhook is triggered. It notifies the server that a data change has occured in the user account (e.g. a new `count/step` event has been recorded) by sending an HTTP POST request to the provided webhook URL. This URL acts as a phone number that the other application can call when an event happens.

5. As soon as the server receives the HTTP POST request on the URL, it retrieves the events since last change from Pryv.io using the provided token.

6. The server processes the data as configured and sends it back to the user app. It can for example send a notification to the user about the number of steps he did, or perform any algorithm that you may have programmed on the server.

Here’s a visual representation of the process:

![Webhook structure in Pryv](/assets/images/Webhook_pryv.png)

## Why using Webhooks on Pryv.io

Notification systems are extremely useful to send and get updates of data changes in real-time.
Before implementing webhooks on Pryv.io, the API only supported real-time notifications using [Socket.io](https://api.pryv.com/reference/#call-with-websockets).

From now on, one can subscribe to notifications of changes in a web application using websockets, or in a web service using webhooks.

The difference is mainly that websockets will keep a socket open on both the client and the server for the duration of the conversation, while webhooks require a socket to stay open on the server side. On the client side, the socket is only opened up for the request (just like any other HTTP request).

As no persistent connection is required with webhooks, it allows an efficient resources usage. That's also why webhooks will be particularly useful for unfrequent updates of data changes.

Using webhooks enables to initiate notifications from any point instead of exclusively from the place that will receive them.

## Design

A `Webhook` is associated to an `Access`' permission set, meaning that it is created and manageable only using this `Access`' token.

Once it is created and active, it will be executed up to a defined maximum rate, sending `HTTP POST` requests to the provided URL.

The POST requests contains an array of notifications similar to the ones sent by the current socket.IO notifications system:

```json
{
  "messages": [
    "eventsChanged",
    "streamsChanged",
    "accessesChanged"
  ],
  "meta": {
    "apiVersion": "1.4.8",
    "serverTime:": 1557927701.698,
    "serial": 20190810
  }
}
```
Messages describe what type of resource has been changed (created, updated or deleted). It does not include the contents of the change, which must be retrieved through the API using a valid access token.

Importantly, only the access used to create the webhook (or a personal one) can be used to modify it. This is meant to separate the responsibilities between the webhooks management and services that will consume the data following a notification.

Typically, a certain access will be used to setup one or multiple webhooks per user, while updated data will be fetched using a different set of accesses.


## Conclusion

If you wish to set up a `Webhook` or get more information on the data structure, please refer to the corresponding section of the [API reference](https://api.pryv.com/reference/#webhook). 
It describes the main features of the data structure, while the methods relative to webhooks can be found in the [API methods section](https://api.pryv.com/reference/#webhooks).