---
id: manage-events
title: 'Manage events'
template: default.jade
customer: true
withTOC: true
---

Events are the primary unit of content in Pryv.io model. They are timestamped piece of typed data, containing different fields that can be found in the [data structure reference](http://pryv.github.io/reference/#data-structure-event). 
All available API methods to work on events are described in the [API reference](http://pryv.github.io/reference/#events).

We provide here concrete examples on how to manipulate events : **create**, **get**, **update** and **delete** events.

### Create an event 

Let's suppose that the structure of streams follows the one displayed below :

![Pryv.me Data Model : Streams](/assets/images/getting-started/streams_structure_v1.png)

The stream 'heartRate' contains a substream 'pulseOximeterApp' in which events related to the heart rate measured by the Pulse Oximeter App can be added. 
To create an event of type 'frequency/bpm' with a pulse rate (integer) as content in the stream 'pulseOximeterApp', we use a ```POST ``` call such as :

```bash
curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: ${token}" \
  -d '{
        "streamId": "pulseOximeterApp",
        "type": "frequency/bpm",
        "content": 90
    }' \
    'https://${username}.${domain}/events'
```

The answer returned by the server contains the created event with all additional fields filled in by the server.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550841167.771
  },
  "event": {
    "streamId": "pulseOximeterApp",
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
}
```

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
      "streamId": "pulseOximeterApp",
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

Let's imagine now that we want to modify the heart rate measurement from the stream 'pulseOximeterApp'. 

We first retrieve the id of the event that we want to update, and we save the id of the concerned event in the variable **${event_id}**. To find this id, you can perform a ```GET``` call as above to save the event id from the response.

```bash
${event_id} = cji5qaxk01nui0b40ec370p94
```

Then, we use a ```PUT``` call to update the event with a new value, for instance a heart rate of "80".

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

As an example, we will show how to delete a specific heart rate event from the stream 'pulseOximeterApp'.  We first retrieve the id of the event we want to delete (by doing a ```GET``` call as above) and we save it in the variable **${event_id}**.

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
    "content": 90,
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
