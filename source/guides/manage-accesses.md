---
id: manage-accesses
title: 'Manage accesses'
template: default.jade
customer: true
withTOC: true
---

One of the core aspects of Pryv.io is the access management to the data, based on an active consent given by the data owner to others using accesses.

You can find the concepts behind the accesses in Pryv.io in the [API concepts](http://api.pryv.com/concepts/#accesses) page.

## Access creation

To allow an other party to access the data, a user has to deliver an token linked to an access object in Pryv.io.

To do that, let's create our first access, using the creation method among the ones provided by the API and described in the [Access methods reference](http://pryv.github.io/reference/#accesses).

The object used as parameter contains some of the desired access fields. A list of all fields can be found in the [Access data structure reference](http://pryv.github.io/reference/#data-structure-access).

We'll create a shared access which is the default type, giving access to the previously created stream with `read` permissions.

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

The server will return the created access information, containing the most important token that will be used by whoever we allow to access data using this access.

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

Now whoever or whatever algorithm or application query data on the user data storage accessible at `https://jsmith.{domain}` using this token (`cjsg40uzv000411ta8r4n7ax1`) will have read access to all events linked to the stream named `My Stream` that we created at the beginning of this tutorial.

Let's try that now.

## Creating more data

Before trying to use the shared access, let's add some more data in a different stream to visualize the access control in action.

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

The second streams is created. Note the `id` of this new stream that will be used in the following query.

Using this new `streamId` let's create another event, this time with a more complex type like the blood pressure type `blood-pressure/mmhg-bpm`.

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

The server returns the new event with all its necessary fields filled.

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

## Getting data using a shared access

It's now time to use the previously obtained shared access token (`cjsg40uzv000411ta8r4n7ax1`).

Let's change the `Authorization` header in the REST query and see that only the note event is returned.

```bash
curl -X GET \
     -H 'Content-Type: application/json' \
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
     -H 'Content-Type: application/json' \
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
