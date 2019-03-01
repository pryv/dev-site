---
id: manage-events
title: 'Manage events'
template: default.jade
withTOC: true
---

Actual data will be stored in events.

You can find all available REST actions on events in the [API reference](http://pryv.github.io/reference/#events).

Data can be stored in events and can be structured using event types. You can find a description of all default event types in Pryv.io in the [event types reference](http://pryv.github.io/event-types/). Note that you can also use your own custom types.

Let's create an event with the `note/txt` type which describes a content consisting of a single text content.

Apart from a content field which inner structure can depend on the declared type, an event can contain a number of other fields acting as metadata around the data stored in Pryv.io.

You can find all fields composing an event object in the [data structure reference](http://pryv.github.io/reference/#data-structure-event).

To create a basic `note/txt` event, we only need the `streamId`, `type` and the `content` fields. We will also use the `description` to give meaning to the data stored in a human-readable way.

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
     https://jsmith.pryv.domain/events
```

The answer returned by the server contains the created event with all additional fields filled in by the server.

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

## Get existing data

Pryv.io comes with many operations and filtering possibilities which can be found described in the [API reference](http://pryv.github.io/reference/).

Let's display the previously created note.

```bash
curl -X GET \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     https://jsmith.pryv.domain/events
```

The object returned is a list of existing events. In this tutorial we have only one even that can be found in this list.

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

Let's try an example of filtering by passing a parameter in our request to filter out all events which happened after the 01.01.2019 at 07:00:00 UTC by using the `toTime` parameter.

This filtering applies to the `time` field which indicates when an event occurred. Note that this is different from the time when the data was stored in Pryv.io, which is encoded in the `created` field. Thus the `time` can be set at the event creation to store data that occurred in the past, or even in the future (e.g. a medical appointment).

```bash
curl -X GET \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     https://jsmith.pryv.domain/events?toTime=1546326000.000
```

As exepected, our only event is filtered out:

```json
{
  "events": [],
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550842585.342
  }
}
```
