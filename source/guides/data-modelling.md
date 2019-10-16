---
id: data-modelling
title: 'Data Modelling'
template: default.jade
customer: true
withTOC: true
---

# Guides

In the following mini-guides, you will find all the necessary information The first step in order to be able to manage entities such as events, streams and accesses on Pryv.com requires to login.

## How to manage streams ?

Streams represent the fundamental context in which events occur and are organized in a hierarchical way. 

They should reflect the user/app-specific organizational levels (e.g. life journal, blood pressure recording, etc.) or data sources (e.g. apps and/or devices). Different operations can be performed on streams, listed in the [API methods](https://api.pryv.com/reference/#api-methods) : ```GET```, ```CREATE```, ```UPDATE```and ```DELETE```.

Let's take the case of a patient John who is recording his heart rate on a daily basis using the *Pulse Oximeter* app, and his nutrition. He will therefore need a stream organization as below :

![john_streams](/Users/anastasiabouzdine/Desktop/john_streams.png)

Using the login from the guide ["How to create login?"](xxx), John has created an account on Pryv.io with the username '*john*', the domain '*pryv.me*' and the access token '*ck1ge42ay6i411md3fua2lboq*'.

### Create a stream

How does it work in practice to create a root stream "heart" or "nutrition", and the corresponding sub-streams ?

We need first to create the root stream "heart".

From the command line [Should we add more info ? About login, access, etc], we perform a a ```POST``` call to the streams route, providing the 'id' and 'name' of the root stream to create :

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

Any sub streams can be added to the parent stream.

### Get a stream

Now that the 'heart' stream and its children were created for John, we can try to retrieve them. 

To do so, we use a ```GET``` call, replacing {token}, {username} and {domain} by John's profile variables.

In the command line :

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

 

## How to manage events ?

### Create an event 

Let's suppose that the structure of streams is the one that has been described [previously](ref: john_streams).

The stream 'heart' contains a substream 'heartRate' in which events related to heart rate measurements can be added :

![Capture d’écran 2019-10-10 à 15.43.12](/Users/anastasiabouzdine/Desktop/Capture d’écran 2019-10-10 à 15.43.12.png)

To create an event of type 'frequency/bpm' with a pulse rate (integer) as content in the stream 'heartRate', we use a ```POST ``` call such as :

```bash
curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: ${token}" \
  -d '{
        "streamId": "heartRate",
        "type": "frequency/bpm",
        "content": 90
    }' \
    'https://${username}.${domain}/events'
```

Any sub streams can be added to the parent stream.

### Get an event

The events from a stream can be easily retrieved using a ```GET``` call in the command line :

```bash
curl     -H "Authorization: ${token}" \
    -i https://${username}.${domain}/events
```

Response :

```json
{
  "events": [
    {
      "streamId": "heartRate",
      "type": "frequency/bpm",
      "content": 90,
      "time": 1528447710.816,
      "tags": [],
      "created": 1528447710.816,
      "createdBy": "cji5os3u11ntt0b40tg0xhfea",
      "modified": 1528447710.816,
      "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
      "id": "cji5qaxk01nui0b40ec370p94"
    }
  ],
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528467864.397
  }
}
```

### Update an event

Let's imagine now that we want to modify the heart rate measurement from the stream 'heartRate'. 

We first retrieve the id of the event that we want to update, and we save the id of the concerned event  in the variable ${event_id}. To find this id, you can perform a ```GET``` call as above to save the event id from the response.

```bash
${event_id} = cji5qaxk01nui0b40ec370p94
```

Then, use a ```PUT``` call to update the event with a new value, for instance a heart rate of "80".

```bash
curl -X PUT \
  -H "Authorization: ${token}" \
  -H "Content-Type: application/json" \
  -d '{
        "content": 80
    }' \
    'https://${username}.${domain}/events/${event_id}'
```

### Delete an event

The ```delete``` operation is divided into two phases : trash and delete. When deleting an event or a stream, it is first flagged as trashed (and can still be retrieved) and irreversibly deleted only when repeating the delete operation a second time. 

As an example, we will show how to delete a specific heart rate event from the stream 'heartRate'.  We first retrieve the id of the event we want to delete (by doing a read operation) and we save it in the variable ${event_id}.

```bash
${event_id} = cji5qaxk01nui0b40ec370p94
```

We will use a ```DELETE``` call to trash it first and a second ```DELETE``` call to delete it completely. 

```bash
curl -X DELETE \
  -H "Authorization: ${token}" \
  'https://${username}.${domain}/events/${event_id}'
```

Response:

```json
{
  "event": {
    "streamId": "pulseOximeterApp",
    "type": "frequency/bpm",
    "content": 105,
    "time": 1528878365.385,
    "tags": [],
    "created": 1528878365.385,
    "createdBy": "cji5os3u11ntt0b40tg0xhfea",
    "modified": 1528895740.264,
    "modifiedBy": "cjicv106i1q580b40678kjb17",
    "trashed": true,
    "id": "cjicupcqx1q530b40oao5ob02"
  },
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528895740.267
  }
}
```

As we trashed the event, the boolean response "trashed" is true.

Finally, we delete the event completely by a second ```DELETE``` call. 

```bash
curl -X DELETE \
  -H "Authorization: ${token}" \
  'https://${username}.${domain}/events/${event_id}'
```

The API should return a list of deletion :

```json
{
  "eventDeletion": {
    "id": "cji5qaxk01nui0b40ec370p94"
  },
  "meta": {
    "apiVersion": "1.2.18",
    "serverTime": 1528817673.092
  }
}
```




