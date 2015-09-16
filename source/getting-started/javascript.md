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

- [Basic example: authenticate & retrieve data](http://jsfiddle.net/pryv/fr4e834p/11/)
- [Events monitor: manipulate events & monitor changes](http://jsfiddle.net/pryv/bwpv0b3o/18/)


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
    accepted: function (username, accessToken, languageCode) {
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


### Retrieve & manipulate events

#### Retrieve

```javascript
var filter = new pryv.Filter({limit : 20});
connection.events.get(filter, function (err, events) {
  // ...
});
```

#### Create

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

#### Update

```javascript
event.content = 'Updated content.';
event.update(function (err, updatedEvent) {
  // ...
});
```

#### Delete

```javascript
event.delete(function (err, trashedEventOrNull) {
  // ...
});
```


### Further resources

- [API reference](/reference/)
- [Library JS docs](/lib-javascript/latest/docs/)
