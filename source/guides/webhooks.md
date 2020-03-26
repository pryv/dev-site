---
id: webhooks
title: 'Webhooks'
template: default.jade
customer: true
withTOC: true
---

Pryv.io supports webhook integration, and therefore allows to notify of data changes. 

Webhooks are one of a few ways web applications can communicate with each other.

It enables you to send real-time data from one application to another whenever a given event occurs.

For example, let’s imagine that you've created an application using Pryv.io API that tracks the number of steps your user does everyday and you want to be able to notify him when he reaches a certain number of steps during the day. 

What a webhook does is notify the receiving application any time the user does a certain number of steps, so you can run any processes that you had in your application once this event is triggered, and send the user a notification on his mobile app for example. 

The data is then sent over the web from the application where the event originally occurred (here the step counter app), to the receiving application that handles the data (the server).

More specifically, there is a few steps to follow to receive event notifications with webhooks : 
1. You first need to create the webhook. You can do so by checking Pryv.io API reference at the [corresponding section](https://api.pryv.com/reference/#webhook) and fill the necessary fields when creating the webhook. In particular, you need to provide a “webhook URL" over which the exchange of data will happen.
For example:
```json
{
  "url": "https://${username}.my-notifications.com/${my-secret}/?param1=value1&param2=value2"
}
```
2. You should then send a token to the server to give it the access to information when it will be retrieving the data changes.
3. While the step counter is on, events related to the steps are recorded and added to the corresponding stream, e.g. the stream `Activity`. This is done by performing an HTTP POST call to create an event with Pryv.io API (see method [create.event](https://api.pryv.com/reference/#create-event)). 
4. Once the `count/step` event is created in Pryv.io API, the webhook is triggered. It notifies the server that a data change has occured in the user account (e.g. a new `count/step` event has been recorded) by sending a HTTP POST request to the provided "webhook URL". This URL acts as a phone number that the other application can call when an event happens.
5. As the server receives the HTTP POST request, it retrieves the events since last change from Pryv.io using the provided token.
6. The server processes the data as configured and sends it back to the user app. It can for example send a notification to the user about the number of steps he did, or perform any programmed algorithm that you may have.

Here’s a visual representation of the process : 

------------
insert a graphical explanation
------------

More information on how to set up a `Webhook` on Pryv.io is provided in the corresponding section of the [API reference](https://api.pryv.com/reference/#webhook). It describes the main features of the data structure of webhooks, while the methods related to webhooks can be found in the [API methods section](https://api.pryv.com/reference/#webhooks).

Importantly, only the app access used to create the webhook in the first step or a personal access can retrieve and modify it. This allows for ...



