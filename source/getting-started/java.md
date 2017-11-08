---
id: java
parentId: getting-started
title: "Getting started: Java"
template: default.jade
withTOC: true
---

A few initial pointers to get going with [the latest release of our Java library](https://github.com/pryv/lib-java).<br>

For previous releases, please look at the following documentation instead:
* [Getting-started v1](https://github.com/pryv/lib-java/blob/master/getting_started_v1.md)
* [Java example app v1](https://github.com/pryv/app-java-examples/tree/bcfedf62e54ac56cfc71f47bef63282e29222bcb/BasicExample)
* [Android example app v1](https://github.com/pryv/app-android-example/tree/a7ca35203e7030b6ca4ef828096fa85e77bc5aa9)

[Feedback and suggestions welcome](http://github.com/pryv/dev-site/issues).


### Examples

- [Java Basic example: authenticate & retrieve data](https://github.com/pryv/app-java-examples/tree/master/BasicExample)<br>

- [Android App example: authenticate, create note Events and retrieve them, with integration guide](https://github.com/pryv/app-android-example)<br>


### Install the library

In order to import the library in your project, please follow [these instructions](https://github.com/pryv/lib-java/blob/master/README.md#import).

### Authorize your app

First choose an app identifier (REQUESTING_APP_ID, min. length 6 chars), then in your client code:

```java
// Here we request full permissions on a custom stream;
// in practice, scope and permission level will vary depending on your needs
Permission permission = new Permission("example-app-id", Permission.Level.manage, "Example App");
List<Permission> permissions = new ArrayList<Permission>();
permissions.add(permission);

AuthView view = new AuthView() {
	public void onAuthSuccess(String username, String token) {
		// Retrieve username and valid token
	}

	public void onAuthError(String message) {
		// Display error message
	}

	public void onAuthRefused(int reasonId, String message, String detail) {
		// Display authentication refused message
	}

	public void displayLoginView(String loginURL) {
		// Generate WebView to load URL and enter credentials
	}
};

AuthController authenticator = new AuthControllerImpl(REQUESTING_APP_ID, permissions, language, returnURL, view);
authenticator.signIn();
```

See also: [app authorization in the API reference](/reference/#authorizing-your-app)


### Setup connection

```java
Connection connection = new Connection(username, accessToken, domain);
```

### Manage events

#### Retrieve

```java
Filter filter = new Filter().addStream('diary');
try {
	List<Event> retrievedEvents = connection.events.get(filter);
	// Do something with the retrieved Events
} catch (IOException e) {
	// Handle the error
}
```

#### Create

```java
Event newEvent = new Event()
	.setStreamId("diary")
	.setType("note/txt")
	.setContent("I track, therefore I am.");
try {
	newEvent = connection.events.create(newEvent);
	// Do something with the created Event
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
newEvent.setContent("updated content");
try {
	Event updatedEvent = connection.events.update(newEvent);
	// Do something with the updated Event
} catch (IOException e) {
	// Handle the error
}
```

#### Delete

```java
try {
	String eventDeletionId = connection.events.delete(newEvent.getId());
	// Do something with the id of the deleted Event
} catch (IOException e) {
	// Handle the error
}
```

### Manage Streams

#### Retrieve

```java
Filter filter = new Filter().setParentId("myRootStreamId");
try {
	Map<String, Stream> retrievedStreams = connection.streams.get(filter);
	// Do something with the retrieved Streams
} catch (IOException e) {
	// Handle the error
}
```

#### Create

```java
Stream newStream = new Stream()
	.setId("heartRate")
	.setName("Heart rate");
try {
	newStream = connection.streams.create(newStream);
	// Do something with the created Stream
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
newStream.setName("New name");
try {
	Stream updatedStream = connection.streams.update(newStream);
	// Do something with the updated Stream
} catch (IOException e) {
	// Handle the error
}
```

#### Delete

```java
try {
	String eventDeletionId = connection.streams.delete(newStream.getId(), false);
	// Do something with the id of the deleted Stream
} catch (IOException e) {
	// Handle the error
}
```

### Manage accesses

#### Retrieve

```java
try {
	List<Access> retrievedAccesses = connection.accesses.get();
	// Do something with the retrieved accesses
} catch (IOException e) {
	// Handle the error
}
```

#### Create

```java
Access newAccess = new Access()
	.setName("forMyDoctor")
	.addPermission(new Permission("heartRate", Permission.Level.read, null));
try {
	newAccess = connection.accesses.create(newAccess);
	// Do something with the created access
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
newAccess.setName("forMyFamily");
try {
	Access updatedAccess = connection.accesses.update(newAccess);
	// Do something with the updated access
} catch (IOException e) {
	// Handle the error
}
```

#### Delete

```java
try {
	String deletionId = connection.accesses.delete(newAccess.getId());
	// Do something with the id of the deleted access
} catch (IOException e) {
	// Handle the error
}
```

### Batch call

Coming soon!

### Further resources

- [API reference](/reference/)
