---
id: webhooks
title: 'Webhooks'
template: default.jade
customer: true
withTOC: true
---

## Introduction

Pryv.io supports webhook integration, and therefore allows to notify of data changes. 

But what exactly are Webhooks ?

## Definition

Webhooks are by definition a way to set up a push notification to a predefined URL endpoint. It is triggered by some event that one wishes to be alerted of, mostly in order to act on it.

It enables you to send real-time data from one application to another whenever a given event occurs.

For example, let’s imagine that you've created an application using Pryv.io API that tracks the number of steps your user does everyday and you want to be able to notify him when he reaches a certain number of steps during the day. 

What a webhook does is notify the receiving application any time the user does a certain number of steps, so you can run any processes that you had in your application once this event is triggered, and send the user a notification on his mobile app for example. 

The data is then sent over the web from the application where the event originally occurred (here the step counter app), to the receiving application that handles the data (the server).

More specifically, these are the few steps to follow to receive event notifications with webhooks : 

1. You first need to create the webhook. You can do so by checking Pryv.io API reference at the [corresponding section](https://api.pryv.com/reference/#webhook) and fill the necessary fields when creating the webhook. In particular, you need to provide a “webhook URL" over which the HTTP POST requests will be made.
For example:
```json
{
  "url": "https://notifications.service.com/pryv"
}
```

2. You should then send a token to the server to give it the access to information when it will be retrieving the data changes. You can easily obtain an access token from the [Pryv Access Token Generator](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me) by following [these steps](https://api.pryv.com/getting-started/#obtain-an-access-token).

3. While the step counter is on, events related to the steps are recorded and added to the corresponding stream, e.g. the stream `Activity`. This is done by performing an HTTP POST call to create an event with Pryv.io API (see method [create.event](https://api.pryv.com/reference/#create-event)). 

4. Once the `count/step` event is created in Pryv.io API, the webhook is triggered. It notifies the server that a data change has occured in the user account (e.g. a new `count/step` event has been recorded) by sending an HTTP POST request to the provided webhook URL. This URL acts as a phone number that the other application can call when an event happens.

5. As soon as the server receives the HTTP POST request on the URL, it retrieves the events since last change from Pryv.io using the provided token.

6. The server processes the data as configured and sends it back to the user app. It can for example send a notification to the user about the number of steps he did, or perform any algorithm that you may have programmed on the server.

Here’s a visual representation of the process : 

![Webhook structure in Pryv](source/assets/images/Webhook_pryv.png)

## Why using Webhooks on Pryv.io

Notification systems are extremely useful to send and get updates of data changes in real-time. 
Before implementing webhooks on Pryv.io, the API only supported real-time interaction by accepting [websocket](https://api.pryv.com/reference/#call-with-websockets) connections via Socket.IO.

From now, one can subscribe to notifications of changes in a web application using websockets, or in a web service using webhooks.

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