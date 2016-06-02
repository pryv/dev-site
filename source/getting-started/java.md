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

- [Basic example: authenticate & retrieve data](https://github.com/pryv/lib-java/blob/master/examples/BasicExample/src/main/java/BasicExample.java#L32)<br>
  Run it via `examples/BasicExample/run.sh`
- [Java App example: JavaFX app to view user data](https://github.com/pryv/lib-java/blob/master/examples/JavaApp/src/main/java/com/pryv/ExampleApp.java#L47)<br>
  Run it via `examples/JavaApp/run.sh` (Java 1.8 required)


### Install the library

Install [Maven](http://books.sonatype.com/mvnref-book/reference/installation-sect-maven-install.html) and add the dependency in your project's pom.xml file:

```xml
<dependency>
        <groupId>com.pryv</groupId>
        <artifactId>lib</artifactId>
        <version>0.1.0</version>
</dependency>
```


### Authorize your app

First choose an app identifier (min. length 6 chars), then in your client code:

```java
// Here we request full permissions on a custom stream;
// in practice, scope and permission level will vary depending on your needs
Permission permission = new Permission("example-app-id", Permission.Level.manage, "Example App");
List<Permission> permissions = new ArrayList<Permission>();
permissions.add(permission);

AuthView view = new AuthView() {
	public void onAuthSuccess(String username, String token) {
      // provides username and valid token
      ...
    }

    public void onAuthError(String message) {
      // display error message
      ...
    }

    public void onAuthRefused(int reasonId, String message, String detail) {
  	  // display authentication refused message
  	  ...
    }

    public void displayLoginVew(String loginURL) {
      // generate WebView to load URL to enter credentials
      ...
    }
};

AuthController authenticator = new AuthControllerImpl(REQUESTING_APP_ID, permissions, "en", "", view);
authenticator.signIn();
```

See also: [app authorization in the API reference](/reference/#authorizing-your-app)


### Setup connection

```java
connection = new Connection("bob", "12345678qwertz", "pryv.me", false, new DBinitCallback());

// define the scope of the cached data. Leave null to cache all Pryv data (including data from other apps)
new Filter scope = new Filter();
scope.addStream(myTrackedStream);
connection.setupCacheScope(scope);
```

### Retrieve & manipulate events

#### Retrieve

```java
Filter filter = new Filter();
filter.setLimit(20);
connection.events.get(filter, new GetEventsCallback() {
	@Override
	public void cacheCallback(List<Event> events, Map<String, Double> eventDeletions) {
    	// do something            
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}

	@Override
	public void apiCallback(List<Event> events, Map<String, Double> eventDeletions, Double serverTime) {
		// do something
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}
});
```

#### Create

```java
Event newEvent = new Event()
newEvent.setStreamId("diary");
newEvent.setType("note/txt");
newEvent.setContent("I track, therefore I am.");
connection.events.create(newEvent, new EventsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Event event, String stoppedId, Double serverTime) {
    	// do something            
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Event event) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```

#### Update

```java
event.setContent = "Updated content.";
connection.events.update(event, new EventsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Event event, String stoppedId, Double serverTime) {
    	// do something            
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Event event) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```

#### Delete

```java
connection.events.delete(event, new EventsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Event event, String stoppedId, Double serverTime) {
    	// do something            
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Event event) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```

### Retrieve and manipulate Streams

#### Retrieve

```java
connection.streams.get(null, new GetStreamsCallback() {
	@Override
	public void cacheCallback(Map<String, Stream> streams, Map<String, Double> streamDeletions) {
    	// do something            
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}

	@Override
	public void apiCallback(Map<String, Stream> streams, Map<String, Double> streamDeletions, Double serverTime) {
		// do something
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}
});
```

#### Create

```java
Stream newStream = new Stream();
newStream.setId("heartRate");
newStream.setName("Heart rate");
connection.streams.create(newStream, new StreamsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Stream stream, Double serverTime) {
		// do something
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Stream stream) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```

#### Update

```java
stream.setParentId("health");
connection.streams.update(stream, new StreamsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Stream stream, Double serverTime) {
		// do something
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Stream stream) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```

#### Delete

```java
connection.streams.delete(stream, new StreamsCallback() {
	@Override
	public void onApiSuccess(String successMessage, Stream stream, Double serverTime) {
		// do something
	}

	@Override
	public void onApiError(String errorMessage, Double serverTime) {
		// do something
	}

	@Override
	public void onCacheSuccess(String successMessage, Stream stream) {
		// do something
	}

	@Override
	public void onCacheError(String errorMessage) {
		// do something
	}
});
```


### Further resources

- [API reference](/reference/)
