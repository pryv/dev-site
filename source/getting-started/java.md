---
id: java
parentId: getting-started
title: "Getting started: Java"
template: default.jade
withTOC: true
---

A few initial pointers to get going with [our Java library](https://github.com/pryv/lib-java).<br>
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
Connection connection = new Connection(userID, accessToken, domain);
```

### Manage events

#### Retrieve

```java
try {
	Filter filter = new Filter().addStream('diary');
	List<Event> retrievedEvents = connection.events.get(filter);
	// Do something with the retrieved Events
} catch (IOException e) {
	// Handle the error
}
```

#### Create

```java
try {
	Event newEvent = new Event()
		.setStreamId("diary")
		.setType("note/txt")
		.setContent("I track, therefore I am.");
	newEvent = connection.events.create(newEvent);
	// Do something with the created Event
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
try {
	newEvent.setContent("updated content");
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
try {
	Filter filter = new Filter().setParentId("myRootStreamId");
	Map<String, Stream> retrievedStreams = connection.streams.get(filter);
	// Do something with the retrieved Streams
} catch (IOException e) {
	// Handle the error
}
```

#### Create

```java
try {
	Stream newStream = new Stream()
		.setId("heartRate")
		.setName("Heart rate");
	newStream = connection.streams.create(newStream);
	// Do something with the created Stream
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
try {
	newStream.setName("New name");
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
try {
	Access newAccess = new Access()
		.setName("forMyDoctor")
		.addPermission(new Permission("heartRate", Permission.Level.read, null));
	newAccess = connection.accesses.create(newAccess);
	// Do something with the created access
} catch (IOException e) {
	// Handle the error
}
```

#### Update

```java
try {
	newAccess.setName("forMyFamily");
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
