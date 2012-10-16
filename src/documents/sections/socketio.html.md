---
sectionId: socketio
sectionOrder: 4
---

# Socket.IO support

The activity service supports real-time interaction with [Socket.IO](http://socket.io), both by accepting equivalent messages for most API methods and by emitting data change notification messages. (Code examples below are in Javascript.)


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
