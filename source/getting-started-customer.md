---
id: getting-started-customer
title: 'Getting started'
template: default.jade
customer: true
withTOC: true
---

## Prerequisites

You'll need your own Pryv.io installation to try out its different features.
If you don't have one yet, please get in contact with our [Sales Team](mailto:sales@pryv.com).

Pryv.io is a middleware. As such, you will have to interact with the server through either a custom application or HTTP calls using your prefered method (e.g. cURL, Postman, etc.).

The following tutorial is based on HTTP calls without using any application.

## Create user

To create a new user, you will need 2 specific information:

- appId: this identifier is chosen by you and has to be unique for the application interacting with Pryv.io, be it a web application, a mobile application or anything else.
- hosting: this piece of information will tell Pryv.io on which storage system to create and link the user. More information is available at the [API concepts](http://api.pryv.com/concepts/#servers) page.

### Get existing hostings

You can query Pryv.io to list the existings hostings know to the system.

Execute the following cURL request to the register URL of your installation.

```bash
curl -X GET \
     https://reg.{domain}/hostings
```

An example of an answer follows:

```json
{
  "regions": {
    "pilot": {
      "name": "Pilot",
      "localizedName": { "fr": "Pilot" },
      "zones": {
        "pilot": {
          "name": "Pilot Core",
          "localizedName": { "fr": "Pilot Core" },
          "hostings": {
            "pilot": {
              "url": "http://{domain}",
              "name": "Self-Contained Pilot Core",
              "description": "Local core inside the pilot deployment",
              "localizedDescription": {},
              "available": true
            }
          }
        }
      }
    }
  }
}
```

In the previous example, the `hostings` part contains only one hosting deployment which name is `pilot`.

### User creation

Using the previously obtained `pilot` hosting and a custom appid `my-own-app`, let's create a user by sending the following request to the register.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{
         "appid": "my-own-app",
         "username": "jsmith",
         "password": "password",
         "email": "jsmith@example.com",
         "hosting": "pilot"
     }' \
     https://reg.{domain}/user
```

The returned answer will contain the username of the created account and its dedicated hostname.

```json
{
  "username": "jsmith",
  "server": "jsmith.{domain}"
}
```

From this point onward, all queries to Pryv.io will be done using the hostname provided in the `server` field, indicating how to interact with a specific user's data.

## Login

Once the user account has been created you'll be able to login and obtain a personal access token to manage data in this account.

More information on the different access types can be found on the [API concepts](http://api.pryv.com/concepts/#accesses) page.

The login request will be done toward our John Smith account.

In the following request, replace the variable `{trusted_origin}` by an [Origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin) that is trusted in your Pryv.io configuration.

Pryv.io default configuration allows all subdomains as trusted. Hence, you can use for example `https://sw.{domain}` as `Origin`.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Origin: {trusted_origin}' \
     -d '{
         "appId": "my-own-app",
         "username": "jsmith",
         "password": "password"
     }' \
     https://jsmith.{domain}/auth/login
```

The answer will contain a token which references a [personal access](http://api.pryv.com/concepts/#accesses) allowing full data management for the account.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550832564.509
  },
  "token": "cjsfxo173000111taf99gp3dv",
  "preferredLanguage": "en"
}
```

From now on, to use the retrieved token and authorize each request made to Pryv.io, you'll need to add an `Authorization` header as shown in the following parts of the tutorial.

## Manage data

As you may already know, data in Pryv.io is modeled using notions of streams and events.

You can find more information on the API concepts page in the [events section](http://api.pryv.com/concepts/#events) or the [contexts section](http://api.pryv.com/concepts/#contexts).

### Creating a stream

Data will be contextualized here using streams.

You can find all available API methods on stream objects in the [API reference](http://api.pryv.com/reference/#streams).

We will now create a new stream in which to place our data using the [creation stream action](http://api.pryv.com/reference/#create-stream).

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "name": "My Stream"
     }' \
     https://jsmith.{domain}/streams
```

The most basic use of this action only requires a `name` parameter to provide a human-readable name for the new stream. A unique and random id will be created upon creation if not provided.

The `Stream` object manipulated by Pryv.io is detailed in the [data structure reference](http://pryv.github.io/reference/#data-structure-stream).

The returned answer will contain the newly created stream object.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550833364.627
  },
  "stream": {
    "name": "My Stream",
    "parentId": null,
    "created": 1550833364.622,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550833364.622,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsfy56kv000311ta9dy121ni"
  }
}
```

### Creating an event

The subject's data will be stored in events.

You can find all available API methods on event objects in the [API reference](http://api.pryv.com/reference/#events).

Data is stored in events and structured using event types. You can find a description of all default event types in Pryv.io in the [event types reference](http://api.pryv.com/event-types/). Note that you can also define your own custom types.

Let's create an event with the `note/txt` type for which the content is a single text string.

Apart from a content field which inner structure depends on the declared type, an event can contain a number of other fields acting as metadata around the data stored in Pryv.io.

You can find all fields composing an event object in the [data structure reference](http://api.pryv.com/reference/#data-structure-event).

To create a basic `note/txt` event, we only need to provide the `streamId`, `type` and the `content` fields. We will also use the optional `description` field to give meaning to the data stored in a human-readable way.

The `streamId` will reference the previously created Stream object to contextualize the data.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "streamId": "cjsfy56kv000311ta9dy121ni",
         "type": "note/txt",
         "description": "My note event",
         "content": "This is the content of our note"
     }' \
     https://jsmith.{domain}/events
```

The returned answer contains the created event with some additional fields filled in by the server.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550841167.771
  },
  "event": {
    "streamId": "cjsfy56kv000311ta9dy121ni",
    "type": "note/txt",
    "description": "My note event",
    "content": "This is the content of our note",
    "time": 1550841167.72,
    "tags": [],
    "created": 1550841167.72,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550841167.721,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsg2sfhq000014taogk4y0gv"
  }
}
```

### Retrieve existing data

Let's display the previously created note.

```bash
curl -X GET \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     https://jsmith.{domain}/events
```

The returned object is a list of existing events. We can find there the previously created event.

```json
{
  "events": [
    {
      "streamId": "cjsfy56kv000311ta9dy121ni",
      "type": "note/txt",
      "description": "My note event",
      "content": "This is the content of our note",
      "time": 1550841167.72,
      "tags": [],
      "created": 1550841167.72,
      "createdBy": "cjsfxo17f000211tair7v6atb",
      "modified": 1550841167.721,
      "modifiedBy": "cjsfxo17f000211tair7v6atb",
      "id": "cjsg2sfhq000014taogk4y0gv"
    }
  ],
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550841828.951
  }
}
```

Pryv.io comes with many operations and filtering possibilities which can be found described in the [API reference](http://pryv.github.io/reference/).

Let's try an example of filtering by passing a parameter in our request to filter out all events which happened after the 01.01.2019 at 07:00:00 UTC by using the `toTime` parameter.

This filtering applies to the `time` field which indicates when an event occurred. Note that this is different from the time when the data was stored in Pryv.io, which is encoded in the `created` field. Thus the `time` can be set at the event creation to store data that occurred in the past, or even in the future (e.g. a medical appointment).

```bash
curl -X GET \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     https://jsmith.{domain}/events?toTime=1546326000.000
```

As expected, our only event is filtered out:

```json
{
  "events": [],
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550842585.342
  }
}
```

## Manage accesses

One of the core aspects of Pryv.io is data access management. It is based on an active consent given by the data owner to others.

You can find the accesses concepts in Pryv.io in the [API concepts](http://api.pryv.com/concepts/#accesses) page.

### Access creation

To allow another party to access the data, a user has to deliver an token linked to an access object in Pryv.io.

To do that, let's create our first access, using the methods provided by the API and described in the [Access methods reference](http://api.pryv.com/reference/#accesses).

The object used as parameter contains some of the desired access fields. A list of all fields can be found in the [Access data structure reference](http://api.pryv.com/reference/#data-structure-access).

We'll create a shared access which is the default type, giving access to the previously created stream with a `read` permissions.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "name": "My first access",
         "permissions": [
           {
            "streamId": "cjsfy56kv000311ta9dy121ni",
            "level": "read"
           }
         ]
     }' \
     https://jsmith.{domain}/accesses
```

The server will return the created access information, containing the token that will be used by whoever we allow to access data using this access.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550843240.685
  },
  "access": {
    "name": "My first access",
    "permissions": [
      {
        "streamId": "cjsfy56kv000311ta9dy121ni",
        "level": "read"
      }
    ],
    "type": "shared",
    "token": "cjsg40uzv000411ta8r4n7ax1",
    "created": 1550843240.683,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550843240.683,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsg40uzv000511tazp8k74db"
  }
}
```

Now whoever, whatever algorithm or application can query data accessible at `https://jsmith.{domain}` using this token (`cjsg40uzv000411ta8r4n7ax1`). It will have read access to all events linked to the stream named `My Stream` that we created at the beginning of this tutorial.

Let's try that now.

### Creating more data

Before trying to use the shared access, let's add some more data in a different stream to visualize the access control functionality in action.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "name": "My second Stream"
     }' \
     https://jsmith.{domain}/streams
```

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550843657.516
  },
  "stream": {
    "name": "My second Stream",
    "parentId": null,
    "created": 1550843657.513,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550843657.513,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsg49smi000114tao2ritqsj"
  }
}
```

The second stream is created. Note the `id` of this new stream that will be used in the following query.

Using this new `streamId` let's create another event, this time with a more complex type such as the blood pressure type `blood-pressure/mmhg-bpm`.

The reference for this default data type can be found [here](http://pryv.github.io/event-types/#blood-pressure).

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "streamId": "cjsg49smi000114tao2ritqsj",
         "type": "blood-pressure/mmhg-bpm",
         "description": "My blood pressure",
         "time": 1549791135.052,
         "content": {
		       "systolic": 141,
		       "diastolic": 82
	       }
     }' \
     https://jsmith.{domain}/events
```

The server returns the new event.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550844023.884
  },
  "event": {
    "streamId": "cjsg49smi000114tao2ritqsj",
    "type": "blood-pressure/mmhg-bpm",
    "description": "My blood pressure",
    "time": 1549791135.052,
    "content": {
      "systolic": 141,
      "diastolic": 82
    },
    "tags": [],
    "created": 1550844023.879,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550844023.879,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsg4hnbe000611taaj2vmjua"
  }
}
```

### Getting data using a shared access

It's now time to use the previously obtained shared access token (`cjsg40uzv000411ta8r4n7ax1`).

Let's change the `Authorization` header in the HTTP query and see that only the note event is returned.

```bash
curl -X GET \
     -H 'Authorization: cjsg40uzv000411ta8r4n7ax1' \
     https://jsmith.{domain}/events
```

The server returns the following list of one event.

```json
{
  "events": [
    {
      "streamId": "cjsfy56kv000311ta9dy121ni",
      "type": "note/txt",
      "description": "My note event",
      "content": "This is the content of our note",
      "time": 1550841167.72,
      "tags": [],
      "created": 1550841167.72,
      "createdBy": "cjsfxo17f000211tair7v6atb",
      "modified": 1550841167.721,
      "modifiedBy": "cjsfxo17f000211tair7v6atb",
      "id": "cjsg2sfhq000014taogk4y0gv"
    }
  ],
  "meta": { "apiVersion": "1.3.38", "serverTime": 1550844293.294 }
}
```

The blood pressure event is not returned because it is not contained in the stream to which we have an access for.

If we do the same query using the personal token of John Smith, we'll see all existing events.

```bash
curl -X GET \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     https://jsmith.{domain}/events
```

```json
{
  "events": [
    {
      "streamId": "cjsfy56kv000311ta9dy121ni",
      "type": "note/txt",
      "description": "My note event",
      "content": "This is the content of our note",
      "time": 1550841167.72,
      "tags": [],
      "created": 1550841167.72,
      "createdBy": "cjsfxo17f000211tair7v6atb",
      "modified": 1550841167.721,
      "modifiedBy": "cjsfxo17f000211tair7v6atb",
      "id": "cjsg2sfhq000014taogk4y0gv"
    },
    {
      "streamId": "cjsg49smi000114tao2ritqsj",
      "type": "blood-pressure/mmhg-bpm",
      "description": "My blood pressure",
      "time": 1549791135.052,
      "content": {
        "systolic": 141,
        "diastolic": 82
      },
      "tags": [],
      "created": 1550844023.879,
      "createdBy": "cjsfxo17f000211tair7v6atb",
      "modified": 1550844023.879,
      "modifiedBy": "cjsfxo17f000211tair7v6atb",
      "id": "cjsg4hnbe000611taaj2vmjua"
    }
  ],
  "meta": { "apiVersion": "1.3.38", "serverTime": 1550844424.979 }
}
```

The event list contains the 2 events that were created during this tutorial, showing that the access control effectively filtered the events returned by the server based on the actual access rights given by the data owner.

## To conclude

This achieves this small tutorial to get acquainted with the Pryv.io API.

Most of the technical information can be found by following these links:

- [API concepts](http://api.pryv.com/concepts/)
- [API reference](http://pryv.github.io/reference/)

More complete reference and further details is accessible for you if you have an active licence.

For all further enquiries, please feel free to [contact us](http://pryv.com/helpdesk/).