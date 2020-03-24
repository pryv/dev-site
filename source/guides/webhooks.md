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

For example, let’s imagine that you've created an application using Pryv.io API that tracks the number of steps your user does everyday and you want to be able to notify his doctor when the user reaches 10'000 steps during the day. 

What a webhook does is notify the doctor any time your user reaches 10'000 steps, so you can run any processes that you had in your application once this event is triggered.

The data is then sent over the web from the application where the event originally occurred (here a pedometer), to the receiving application that handles the data (here the doctor's application).

Here’s a visual representation of what that looks like:

------------
insert a graphical explanation
------------

More information on how to set up a 'Webhook' on Pryv.io is provided in the corresponding section of the [API reference](https://api.pryv.com/reference/#webhook). 
This exchange of data happens over the web through a “webhook URL.”

A webhook URL is provided by the receiving application (the doctor's application), and acts as a phone number that the other application can call when an event happens.

