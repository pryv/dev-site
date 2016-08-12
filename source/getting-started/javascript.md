---
id: javascript
parentId: getting-started
title: "Getting started: Javascript"
template: default.jade
withTOC: true
---

A few initial pointers to get going with [our Javacript library](https://github.com/pryv/lib-javascript).<br>
[Feedback and suggestions welcome](http://github.com/pryv/dev-site/issues).


### Quick examples

On JSFiddle:

- [Basic example: authenticate & retrieve data](http://jsfiddle.net/pryv/fr4e834p/)
- [Second step: create notes & numerical values](https://jsfiddle.net/pryv/kmtyxj37/)
- [Events monitor: manipulate events & monitor changes](http://jsfiddle.net/pryv/bwpv0b3o/)


### Install the library

<div class="row">

<div class="col-md-6">
<h6>Node.js / Browserify</h6>
<p>Install the module...</p>
<pre><code class="lang-bash">npm install pryv --save</code></pre>
<p>...then require it in your JS:</p>
<pre><code class="lang-javascript">var pryv = require('pryv');</code></pre>
</div>

<div class="col-md-6">
<h6>Browser, old style</h6>
<p>[Download](https://api.pryv.com/lib-javascript/latest/pryv.js) then include the library file:</p>
<pre><code class="lang-html">&lt;script type="text/javascript" src="pryv.js"&gt;&lt;/script&gt;</code></pre>
</div>

</div>


### Authorize your app

First choose an app identifier (min. length 6 chars), then in your client code:

```html
<!-- Add the "Pryv" auth button somewhere (skip this for custom UI/behavior) -->
<span id="pryv-button"></span>
```
```javascript
var credentials = null;
var pryvDomain = 'pryv.io';
var requestedPermissions = [{
  // Here we request full permissions on a custom stream;
  // in practice, scope and permission level will vary depending on your needs
  streamId: 'example-app-id',
  defaultName: 'Example app',
  level: 'manage'
}];

var settings = {
  requestingAppId: 'example-app-id',
  requestedPermissions: requestedPermissions,
  spanButtonID: 'pryv-button',
  callbacks: {
    initialization: function () {
      // ...
    },
    needSignin: function (popupUrl, pollUrl, pollRateMs) {
      // ...
    },
    signedIn: function (authData) {
      credentials = authData;
      // ...
    },
    refused: function (code) {
      // ...
    },
    error: function (code, message) {
      // ...
    }
  }
};

pryv.Auth.config.registerURL.host = 'reg.' + pryvDomain;
pryv.Auth.setup(settings);
```
See also: [App authorization](/reference/#authorizing-your-app)


### Connect to the account

```javascript
var connection = new pryv.Connection(credentials);
```

### Initialize the datastore

```javascript
// Required by the monitors
connection.fetchStructure(function (err, streamList) {
  // ...
})
```

### Manage events

#### Retrieve

```javascript
var filter = new pryv.Filter({limit : 10});
connection.events.get(filter, function (err, eventList) {
  // ...
});
```

#### Create

```javascript
// This is the minimum required data to create an event
var event = {
  streamId: 'valid-stream-id',
  type: 'note/txt',
  content: 'This is an example.'
};
connection.events.create(event, function (err, eventCreated) { 
  // ...
});
```
See also: [More about types](/event-types/)

#### Update

```javascript
event.content = 'This is an update.';
connection.events.update(event, function (err, eventUpdated) {
  // ...
});
```

#### Delete

```javascript
connection.events.delete(event, function (err, eventDeleted) {
  // ...
});
```

### Manage streams

#### Retrieve

```javascript
var options;

// Here we will get all streams (including root and trashed streams)
option = {
    // If null, retrieve active streams only
    state: 'all'
};

// Same as above but in a selected stream structure
options = {
    parentId: 'valid-stream-id',
    state: 'all'
};

connection.streams.get(options, function (err, streamList) {
  // ...
});
```

#### Create

```javascript
// If no id is set, one is generated;
// If parentId is null, a "root" stream is created
var stream = {
  name: 'A Stream',
  id: 'a-stream-id',
  parentId: 'valid-stream-id'
};

connection.streams.create(stream, function (err, streamCreated) { 
  // ...
});
```

#### Update

```javascript
// Here we update the name of the stream created above
stream.name: 'An Updated Stream';
connection.streams.update(stream, function (err, streamUpdated) {
  // ...
});
```

#### Delete

```javascript
connection.streams.delete(stream, function (err, streamDeleted) {
  // ...
}, mergeEventsWithParent);
```

### Manage accesses

#### Retrieve

```javascript
connection.accesses.get(function (err, accesses) {
  // ...
});
```

#### Create

```javascript
var access = {
  name: 'An Access',
  permissions: [
    {
      streamId: 'valid-stream-id',
      level: 'manage'
    }
  ]
};

connection.accesses.create(access, function (err, accessCreated) { 
  // ...
});
```

#### Update

```javascript
// Here we update the name and permissions of the access created above;
access.name: 'An Updated Access';
access.permissions[0].level: 'contribute';
connection.accesses.update(access, function (err, accessUpdated) {
  // ...
});
```

#### Delete

```javascript
connection.accesses.delete(access, function (err, accessDeletion) {
  // ...
});
```

### Batch call

```javascript
var methodsData = [
  {
    'method': 'streams.create',
    'params': {
      'id': 'a-new-stream',
      'name': 'A New Stream'
    }
  },
  {
    'method': 'events.create',
    'params': {
      'streamId': 'a-new-stream',
      'type': 'note/txt',
      'content': 'This is a new event.'
    }
  },
  {
    'method': 'accesses.create',
    'params': {
      'name': 'A New Access',
      'permissions': [
        {
          'streamId': 'a-new-stream',
          'level': 'read'
        }
      ]
    }
  }
];

connection.batchCall(methodsData, function (err, results) {
  //...
});
```

### Monitors

Monitors will watch the changes from a selected structure of data (i.e: Errors, Events, Streams or Filters), made within a user account in an app. They are used to fetch the current state of all the elements in an app after load. Therefore it allows to manage data in a user account while an app in running.

To use monitors you will need to:
- Setup a monitor variable (see below in 'Setup Monitors').
- Call any of the monitors (i.e: Load, Error, Event, Stream, Filter).
- Call the `monitor.start` method to start monitoring (see below in 'Start').


#### Setup Monitors
```javascript
var filter = new pryv.Filter({limit: 5});
var monitor = connection.monitor(filter);


//This will use the local cache before fetching data online, default is true
monitor.useCacheForEventsGetAllAndCompare = false;
// This will fetch all events on start up, default is true
monitor.ensureFullCache = false;
// This will optimize start up by prefecthing some events, default is 100
monitor.initWithPrefetch = 0;
```

#### Load  
```javascript
// Will fetch events depending of the filter set in 'Setup Monitors' above
var onLoad = pryv.MESSAGES.MONITOR.ON_LOAD;
monitor.addEventListener(onLoad, function (events) {
  // ...
});
```

#### Error
```javascript
var onError = pryv.MESSAGES.MONITOR.ON_ERROR;
monitor.addEventListener(onError, function (error) {
  // ...
});
```

#### Event change
```javascript
// Will trigger if any event is created, modified or trashed;
// the array of index is used to distinguish which type of change was made
var onEventChange = pryv.MESSAGES.MONITOR.ON_EVENT_CHANGE;
monitor.addEventListener(onEventChange, function (changes) {
  [ 'created', 'modified', 'trashed'  ].forEach(function (action) {
  changes[action].forEach(function (event) {
    // ...
  });
});
```

#### Structure change
```javascript
// Will trigger if any stream is created, modified, trashed or deleted;
// the array of index is used to distinguish which type of change was made
var onStructureChange = pryv.MESSAGES.MONITOR.ON_STRUCTURE_CHANGE;
monitor.addEventListener(onStructureChange, function (changes) {
  [ 'created', 'modified', 'trashed', 'deleted' ].forEach(function (action) {
    changes[action].forEach(function (stream) {
      // ...
    });

});
```

#### Filter change
```javascript
// Will trigger if any filter is modified ;
// the array of index gives informations about the new filter ('enter'),
// and the old filter ('leave')
var onFilterChange = pryv.MESSAGES.MONITOR.ON_FILTER_CHANGE;
monitor.addEventListener(onFilterChange, function (changes) {
  [ 'enter', 'leave' ].forEach(function (action) {
    changes[action].forEach(function (filter) {
      // ...
    });
});
```

#### Start
```javascript
monitor.start(function (err) {
  // ...
});
```

### Further resources

- [API reference](/reference/)
- [Library JS docs](/lib-javascript/latest/docs/)
