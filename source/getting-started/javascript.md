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
  streamId: 'example-app',
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
Link to API reference: [App authorization](/reference/#authorizing-your-app)


### Connect to the account

```javascript
var connection = new pryv.Connection(credentials);
```


### Retrieve & manipulate events

#### Retrieve

```javascript
// Set the number of events to be retrieved, default is 20
var filter = new pryv.Filter({limit : 10});
connection.events.get(filter, function (err, eventList) {
  // ...
});
```
Link to API reference: [Get events](reference/#get-events)

#### Create

```javascript
// This is the minimum required data to create an event
var eventData = {
  streamId: 'String',
  type: 'String',
  content: 'String'
};
connection.events.create(event, function (err, eventCreated) { 
  // ...
});
```
Link to API reference: [Create event](reference/#create-event)

Full documentation: [More about types](/event-types/)

#### Update

```javascript
event.content = 'String';
connection.events.update(event, function (err, eventUpdated) {
  // ...
});
```
Link to API reference: [Upade event](reference/#update-event)

#### Delete

```javascript
// Only the id of an event is needed for removal
connection.events.delete(event, function (err, eventDeleted) {
  // ...
});
```

Link to API reference: [Delete event](/reference/#delete-event)

### Retrieve & manipulate streams

#### Retrieve

```javascript
var option = {
    parentId: 'String',
    state: 'String'
};
connection.streams.get(option, function (err, streamList) {
  // ...
});
```
Link to API reference: [Get streams](reference/#get-streams)

#### Create

```javascript
// If no id is set, one is generated;
// If parentId is null, a "root" stream is created
var streamData = {
  name: 'String',
  id: 'String',
  parentId: 'String'
};

var stream = new pryv.Stream(connection, streamData);
connection.strams.create(stream, function (err, streamCreated) { 
  // ...
});
```
Link to API reference: [Create stream](/reference/#create-stream)

#### Update

```javascript
// Only modified values must be include
var stream = {
  id: 'String',
  update: Object
}

connection.events.update(stream, function (err, streamUpdated) {
  // ...
});
```
Link to API reference: [Update stream](/reference/#update-stream)

#### Delete

```javascript
// Only the id of the stream is needed for removal
connection.streams.delete(stream, function (err, streamDeleted) {
  // ...
}, mergeEventsWithParent);
```
Link to API reference: [Delete stream](/reference/#delete-stream)

### Monitor events

#### Setup Monitor
```javascript
var filter = new pryv.Filter({limit: 5});
var monitor = connection.monitor(filter);

// This whill look in cache before looking online, default is false
monitor.useCacheForEventsGetAllAndCompare = false;
// This whill optimize start up by prefecthing some events, default is 100
monitor.ensureFullCache = false;
// This will fetch all events on start up, default is true
monitor.initWithPrefetch = 0;
```

#### Load
```javascript
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
var onEventChange = pryv.MESSAGES.MONITOR.ON_EVENT_CHANGE;
monitor.addEventListener(onEventChange, function (changes) {
  // ...
});
```

#### Structure change
```javascript
var onStructureChange = pryv.MESSAGES.MONITOR.ON_STRUCTURE_CHANGE;
monitor.addEventListener(onStructureChange, function (changes) {
  // ...
});
```

#### Filter change
```javascript
var onFilterChange = pryv.MESSAGES.MONITOR.ON_FILTER_CHANGE;
monitor.addEventListener(onFilterChange, function (changes) {
  // ...
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
