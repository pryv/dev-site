---
id: java
sectionId: getting-started
title: Getting started (Java)
template: default.jade
withTOC: true
---

A few initial pointers to get going with [our Java library](https://github.com/pryv/lib-java).<br>
[Feedback and suggestions welcome](http://github.com/pryv/dev-site/issues).


### Install the library

Install [Maven](http://books.sonatype.com/mvnref-book/reference/installation-sect-maven-install.html) and add the dependency in your project's pom.xml file:

```
<dependency>
        <groupId>com.pryv</groupId>
        <artifactId>lib</artifactId>
        <version>0.1.0</version>
</dependency>
```


### Authorize your app

First obtain an app identifier (for now: just [ask us](mailto:developers@pryv.com)), then in your client code:

```java
// Here we request full permissions on a custom stream;
// in practice, scope and permission level will vary depending on your needs
Permission permission = new Permission("example-app", Permission.Level.manage, "Example App");
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


### Connect to the account

```java
connection = new Connection(username, token, new DBinitCallback());
```


### Retrieve & manipulate events

#### Retrieve

```java
Filter filter = new Filter();
filter.setLimit(20);
// here, 'this' implements EventsCallback
connection.getEvents(filter, this);
```

#### Create

```java
Event newEvent = new Event()
newEvent.setStreamId("diary");
newEvent.setType("note/txt");
newEvent.setContent("I track, therefore I am.");
// here, 'this' implements EventsCallback
connection.createEvent(newEvent, this);
```

#### Update

```java
event.setContent = "Updated content.";
// here, 'this' implements EventsCallback
connection.updateEvent(event, this);
```

#### Delete

```java
// here, 'this' implements EventsCallback
connection.deleteEvent(event, this);
```


### Examples

- [Basic example: authenticate & retrieve data](https://github.com/pryv/lib-java/blob/master/examples/BasicExample/src/main/java/BasicExample.java#L32)

  To run it: `examples/BasicExample/run.sh`


- [Java App example: JavaFX app to view user data](https://github.com/pryv/lib-java/blob/master/examples/JavaApp/src/main/java/com/pryv/ExampleApp.java#L47)


### Further resources

- [API reference](/reference)