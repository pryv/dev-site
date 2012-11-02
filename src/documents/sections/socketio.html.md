---
sectionId: socketio
sectionOrder: 4
---

# Socket.IO support

The activity service supports real-time interaction with [Socket.IO](http://socket.io), both by accepting equivalent messages for most API methods and by emitting data change notification messages. (Code examples below are in Javascript.)


### Connecting

In order to use Socket.IO, your app must first load the appropriate Socket.IO client library. For a Javascript web app, that's the `socket.io.js` file served by the activity server at the following URL: ```https://{username}.pryv.io/socket.io/socket.io.js```. (For other languages see the related section on the [Socket.IO wiki](https://github.com/learnboost/socket.io/wiki).)

The second step is to initialize the connection. Here's the URL you need to use:
``` 
https://{username}.pryv.io:443/{username}?auth={accessToken}&resource=/{username}
```
For example, in Javascript do:
```javascript
var socket = io.connect("https://mathurin.pryv.io:443/mathurin?auth=TVVro8e8T5&resource=/mathurin")
```


### Calling API methods

Every method in the activity service can be called by sending a corresponding Socket.IO `command` message, providing a data object specifying the command (or method) and possible parameters, and a callback function for the response:
```javascript
socket.emit('command', {id: '{id}', params: {/*parameters*/}}, function (error, data) {
  // handle response here
});
```

Command ids are indicated for each API method below and are modeled after the equivalent URL path. For example, here's how you could call `GET /{channel-id}/events`:
 ```javascript
var cmdData = {
  id: '{channel-id}.events.get',
  params: {
    sortAscending: true
  }
};
socket.emit('command', cmdData, function (error, data) {
  // handle response
});
 ```


### Receiving data change notifications

You can be notified of changes to channels, folders and events by subscribing to the corresponding messages `channelsChanged`, `foldersChanged` and `eventsChanged`. For example:
```javascript
socket.on('eventsChanged', function() {
  // retrieve latest changes and update views
});
```
