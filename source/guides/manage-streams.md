---
id: manage-streams
title: 'Manage streams'
template: default.jade
customer: true
withTOC: true
---

Streams provide the fundamental context in which events occur. They follow a hierarchical structure — streams can have sub-streams — and usually match either user/app-specific organizational levels (e.g. life journal, work projects, etc.) or data sources (e.g. apps and/or devices).
The `Stream` object manipulated by Pryv.io is detailed in the [data structure reference](http://pryv.github.io/reference/#data-structure-stream).
All available API methods to work on streams are described in the [API reference](http://pryv.github.io/reference/#streams).

We provide here concrete examples on how to manipulate streams : **create**, **get**, **update** and **delete** streams.

### Create a stream 

Let's suppose that the structure of streams follows the one displayed below :

![Pryv.me Data Model : Streams](/assets/images/getting-started/streams_structure_v2.png)

We need first to create the root stream "heart".

From the command line, we perform a a ```POST``` call to the streams route, providing the 'id' and 'name' of the root stream to create :

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: ${token}" \
  -d '{
      "id":"heart",
      "name":"Heart"
    }' \
  'https://${username}.${domain}/streams'
```

The answer returned by the server will contain the newly created stream object.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550833364.627
  },
  "stream": {
    "name": "Heart",
    "parentId": null,
    "created": 1550833364.622,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550833364.622,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsfy56kv000311ta9dy121ni"
  }
}
```
Now that the root stream 'heart' has been created, it is possible to attach child streams such as 'heartRate' to the root stream. This sub-stream will be hosting any event related to the heart rate measurement.

Similarly, we perform a ```POST``` call to the streams route, providing the 'id' and 'name' of the stream to create and a 'parentId', the id of the parent stream 'heart':

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: ${token}" \
  -d '{
      "id":"heartRate",
      "name":"Heart Rate",
      "parentId":"heart"
    }' \
  'https://${username}.${domain}/streams'
```

### Get a stream

We can retrieve the streams with a ```GET``` call in the command line :

```bash
curl -i -H "Authorization: ${token}" \
    https://${username}.${domain}/streams
```

The response should look like the following :

```json
{
  "streams": [
    {
      "name": "Heart",
      "created": 1528445539.785,
      "createdBy": "cji5os3u11ntt0b40tg0xhfea",
      "modified": 1528445581.592,
      "modifiedBy": "cjhagb5up1b950b40xsbeh5yj",
      "clientData": {
        "pryv-browser:bgColor": "#e81034"
      },
      "id": "heart",
      "children": [
        {
          "name": "Heart Rate",
          "parentId": "heart",
          "created": 1528445684.508,
          "createdBy": "cji5os3u11ntt0b40tg0xhfea",
          "modified": 1528445684.508,
          "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
          "id": "heartRate",
          "children": []
        }
      ]
    }
  ],
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528815903.187
  }
}
```

To get only one specific stream, replace 'streams' in the command line by the specific stream id that you are wishing to retrieve, e.g. 'heartRate' in the command line :

```bash
curl -i -H "Authorization: ${token}" \
    https://${username}.${domain}/heartRate
```

### Update a stream

Let's imagine now that we want to update the stream 'heartRate' by changing its name. We first retrieve the id of the stream we want to update, and we save the id of the concerned stream ('heartRate') in the variable ${streamId} :

```bash
${streamId} = heartRate
```

Then, we use a `PUT` call to update the name `heartRate` to `heart rate monitoring`.

```bash
curl -X PUT \
  -H "Authorization: ${token}" \
  -H "Content-Type: application/json" \
  -d '{
        "name": "heart rate monitoring"
    }' \
    'https://${username}.${domain}/streams/${streamId}'
```

### Delete a stream

The ```delete``` operation is divided into two phases : trash and delete. When deleting an event or a stream, it is first flagged as trashed (and can still be retrieved) and irreversibly deleted only when repeating the delete operation a second time. 

As an example, we will show how to delete the stream 'heartRate'. 

```bash
${stream_id} = heartRate
```

We repeat the following command two times, one for trashing the stream and another for deleting it :

```bash
curl -X DELETE \
  -H "Authorization: ${token}" \
  'https://${username}.${domain}/streams/${stream_id}'
```

When trying to delete the stream, you may encounter the following error message:

```json
{
  "error": {
    "id": "invalid-parameters-format",
    "message": "There are events referring to the deleted items and the `mergeEventsWithParent` parameter is missing."
  },
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528890640.148
  }
}
```

This means that the stream you are trying to delete still contains some events (*e.g.* previous heart rate measurements) and Pryv.io needs to know what to do with them. You can add the 'mergeEventsWithParent' boolean as query parameter of your delete call. Set it to *true* if you want to merge the events into the parent stream (here 'heart') or to *false* if you want to delete them as well.

Below is the command for deleting the stream and merging the events in the parent stream:

```bash
curl -X DELETE \
  -H "Authorization: ${token}" \
  'https://${username}.${domain}/streams/${streamId}?mergeEventsWithParent=true'
```

Response:

```json
{
  "streamDeletion": {
    "id": "heartRate"
  },
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528890935.505
  }
}
```