---
id: javascript
sectionId: getting-started
title: Getting started (Javascript)
template: default.jade
withTOC: true
---

Using [our Javacript library](https://github.com/pryv/lib-javascript).


### Install the library

On **Node.js or Browserify**, install the module...

```
npm install pryv --save
```

...then require it in your JS:

```
var pryv = require('pryv');
```

On the **browser (old style)**, [download](http://api.pryv.com/lib-javascript/latest/pryv.js) then include the library file:

```html
<script type="text/javascript" src="pryv.js"></script>
```


### Authorize your app

First obtain an app identifier (for now: just [ask us](mailto:developers@pryv.com)), then in your client code:

```html
<!-- Add the "Pryv" auth button somewhere (skip this for custom UI/behavior) -->
<span id="pryv-button"></span>
```

```javascript
var credentials = null;

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
    accepted: function(username, accessToken, languageCode) {
      credentials = { username: username, auth: accessToken };
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

pryv.Auth.setup(settings);
```

See also: [app authorization in the API reference](/reference/#authorizing-your-app)


### Connect to the account

```javascript
var connection = new pryv.Connection(credentials);
```


### Retrieve data

```javascript
var filter = new pryv.Filter({limit : 20});
connection.events.get(filter, function (err, events) {
  // ...
});
```


### Create data

```javascript
var eventData = {
  streamId: 'diary',
  type: 'note/txt',
  content: 'I track, therefore I am.'
};
connection.events.create(eventData, function (err, event) { 
  // ...
});
```


### Update data

```javascript
event.content = 'Updated content.';
event.update(function (err, updatedEvent) {
  // ...
});
```


### Delete data

```javascript
event.delete(function (err, trashedEventOrNull) {
  // ...
});
```


### Further resources

- [API reference](/reference)
- [Library JS docs](/lib-javascript/latest/docs/)
