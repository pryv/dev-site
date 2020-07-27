---
id: data-modelling
title: 'Data Modelling'
template: default.jade
customer: true
withTOC: true
---

In the following section, you will find all the necessary information to design your own data model.

The general introduction describes Pryv.io data modelling conventions to help you understand how you should build your own data model. Then we provide you with a broad range of use cases that you can encounter while building your data model.

## Table of contents

1. [Introduction](#introduction)
2. [Use cases](#use-cases)
  1. [Declaring the stream structure](#declaring-the-stream-structure)
  2. [Storing Profile/Account information](#storing-profile-account-information) 
  3. [Avoiding event types multiplication](#avoiding-event-types-multiplication)
  4. [Defining a custom event type](#defining-a-custom-event-type)
  5. [Storing an event in multiple streams](#storing-an-event-in-multiple-streams)
  6. [Handling multiple devices](#handling-multiple-devices)  
  7. [Referencing events](#referencing-events) 
  8. [Storing technical data from devices](#storing-technical-data-from-devices)
  9. [Defining accesses to the streams](#defining-accesses-to-the-streams)
  10. [Performing an access delegation](#performing-an-access-delegation)
  11. [Storing patient accesses](#storing-patient-accesses)
  

## Introduction

Data in Pryv is organized in "streams" and "events":
- **Streams** are the main way of encoding context for events. They act as folders in which data is stored ("Health", "Geolocation", etc), and follow a tree structure.
- **Events** are the primary unit of content in Pryv.io. They correspond to files that are inserted in corresponding folders. An event is a timestamped piece of typed data (e.g `note/txt`), and belongs to one or multiple streams. It can either have a type from the [list of standard event types](https://api.pryv.com/event-types/) or a custom type that can be created for the intended use case.

Let's take the example of a Pryv.io user who wants to keep track of his health metrics and his physical activity using a smartwatch. A simple and intuitive way to model his data would be to use two streams, "Health Profile" and "Smartwatch":
- "**Health Profile**" corresponds to the health metrics of the user, with for example, the sub-streams "**Height**" and "**Weight**" in which the height and weight measurements are respectively added (events of type `length/cm` and `mass/kg` respectively).
- "**Smartwatch**" contains the collected data from the smartwatch, in particular the geolocation of the user - sub-stream "**Position**" - and the "**Energy**", that can be either the "**Energy-intake**" or the "**Energy-burnt**" (events of type `energy/cal`).

The stream structure of this data model can be visually represented as below:

![Simplified Streams Structure](/assets/images/data_model_simplified.svg)

This stream structure allows you to:

- aggregate data from different data sources
- provide enough context to the data
- control on a granular level accesses to the data

Different permissions can be defined for each stream and substream, therefore enabling to share only necessary information with third-parties (apps, doctors, family, etc). If multiple actors are involved in the process, this allows to precisely control the access level to the different streams. 

![Access Structure](/assets/images/data_model_access.svg)

In the example above, access to particular streams of data can be restricted:

- the **Smartwatch app** has a `manage` access on the streams **Position** and **Energy**, and a `read` access on the streams **Height** and **Weight**
- the **Dietetician** has a `read` access on the stream **Energy**

Available levels of permissions (read, manage, contribute, create-only) are defined and explained [here](https://api.pryv.com/reference/#access).

## Use cases

### Declaring the stream structure

When building your own data model, we advise you to write down your streams and events structure following this [template](https://docs.google.com/spreadsheets/d/1UUb94rovSegFucEUtl9jcx4UcTAClfkKh9T2meVM5Zo/).
This template file describes a very simple data model that can be adapted to your own use case, and provides you with an idea of how to keep track of your streams and events.

The "Allergen data model" on which the file is based is described in this structure:
![Example Streams Structure](/assets/images/data_model_allergens.svg)

The use cases below can help you to design and implement your structure according to your own data flow.

Once your data model is set, you can declare the stream structure at each user account creation on Pryv.io in one call by using a [batch call](https://api.pryv.com/reference/#call-batch). 

Let's assume that you have the following stream structure :

```js
├── Profile
│   ├── Name
│   └── ...
├── Smartwatch
│    ├── Position
│    │   └── `position/wgs84` events
│    └── Biometrics
└── Health
```
To add a `position/wgs84` event in the stream "Position", two options are available:
- Create the whole stream structure before adding the event in the concerned stream:
```json
[
  {
    "method": "streams.create",
    "params": {
      "id": "smartwatch",
      "name": "Smartwatch"
    }
  },
  {
    "method": "streams.create",
    "params": {
      "id": "position",
      "name": "Position",
      "parentId": "smartwatch"
    }
  },
  {
    "method": "events.create",
    "params": {
      "streamIds": [
        "position"
      ],
      "type": "position/wgs84",
      "content": {
    "latitude": 40.714728,
    "longitude": -73.998672
    }
    }
  }
]
```
- Use the "try and fail" method (recommended):
```json
{
res = events.create(Event, "streamIds": ["position"])
if (res.error.id == ’unknown-referenced-resource’) {
   - streams.create: Smartwatch
   - streams.create: Position
   - res = events.create({"streamIds": ["position"], "type": "position/wgs84", ...}) 
 }
```
This method allows to minimize the number of operations and to ensure the existence of the stream structure. However, it requires to link the batch calls when a lot of events needs to be added at once: in this case, you can choose the first solution.

### Storing Profile/Account information

We recommend our customers to create dedicated streams to store account information (e.g [credentials](https://api.pryv.com/event-types/#credentials)) of their users.

For example:
```js
├── Profile
    ├── Name
    │   └── `id/name` events
    ├── Username
    │   └── `id/username` events
    ├── Credentials
    │    └── `credentials/pryvApiEndpoint` events
    └── ...
```

The [Public profile set](https://api.pryv.com/reference/#get-public-profile) can be used to store any information the user makes publicly available (e.g. avatar image). Other profile sets are likely to be deprecated soon.

### Avoiding event types multiplication

One general advice is to limit the number of different event types per stream, but rather to multiply the number of different streams.

Let's imagine that you are recording your daily medication intake (daily consumption of paracetamol, spasfon and levothyrox in mg).
Two options are available to organize your stream structure:
- Create an event-type per medication
```json
├── Medication
    ├── Intake
    │   ├── "paracetamol/mg" events
    │   ├── "spasfon/mg" events
    │   └── "levothyrox/mg" events
    └── ...
```
An intake of 500mg of paracetamol will be recorded this way:
```json
{
    "method": "events.create",
    "params": {
      "streamIds": [
        "intake"
      ],
      "type": "paracetamol/mg",
      "content": {
        "dose": 500
    }
    }
  }
```
In addition to bringing more complexity to the model, this structure lacks flexibilty as it implies the creation of a new event type every time a new medication is added on the user's track record.

- Create a substream per medication (recommended)
```json
├── Medication
    ├── Paracetamol
    │   └── "mass/mg" events
    ├── Spasfon
    │   └── "mass/mg" events   
    └── Levothyrox
        └── "mass/mg" events
```
An intake of 500mg of paracetamol will be recorded this way:
```json
{
    "method": "events.create",
    "params": {
      "streamIds": [
        "paracetamol"
      ],
      "type": "mass/mg",
      "content": {
        "dose": 500
    }
    }
  }
```
This solution has the advantage of resolving the forementioned problems by providing an easily adaptable structure. Adding a new medication only requires to create a new stream instead of creating a new event type and performing additional content validation.

There is no limit to the number of substreams of a stream. In this regard, multiplying the number of streams is a preferable solution when you need to enter data measurements for different types of components (e.g medications, diseases, multiple devices, etc) recording a similar type of measure.

### Defining a custom event type

If your event type is not referenced [here](https://api.pryv.com/event-types/), you can create your own event type for your use case as long as its type follows the specification `{class}/{format}` (e.g `note/txt`, more information on this in the [section](https://api.pryv.com/event-types/#basics)). Events with undeclared types are allowed but their content is not validated.

For example, let's say that you need to create a custom event type for your 12-lead ECG recording `ecg/12-lead-recording`. If you want to perform content validation and ensure that every time you create a new event it has the right structure, the procedure is the following:
1. Define your event type in a JSON file, in this case `ecg.json`:
```json
{
  "ecg": {
  "formats": {
    "12-lead-recording": {
      "description": "Conventional 12-lead ECG measuring voltage with ten electrodes.",
      "type": "number"
      }
    }
  }
}
```
2. Fork the [Data Type repository](https://github.com/pryv/data-types) and add your `ecg.json` file
3. Validate the JSON schema of your event type
4. Publish the corresponding URL in the platform parameters to be loaded at the platform boot :
```json
EVENT_TYPES_URL: "https://api.pryv.com/event-types/flat.json"
```
### Storing an event in multiple streams

Pryv.io allows you to store an event in one or multiple streams. This enables you to add a different context to the same event according to your needs, and to facilitate the sharing of particular events.

For example, let's say you are storing your blood analysis results in a substream "Blood" under your "Health" profile. You might need to share with your nutritionist your last blood analysis. 
To do so, you can store your last blood analysis in a stream "Sharing" that you can then easily share with your nutritionist.

```js

├── Health
│    ├── Blood
│    │   └── `file/attached` events ("blood-analysis-may", "blood-analysis-june", "blood-analysis-july" events, etc)
│    └── ...
└── Sharing
    └── `file/attached` event corresponding to the last blood analysis, e.g "blood-analysis-july" event
```

You can then create an access for your nutritionist on the stream "Sharing":
```json
{
"method": "access.create",
  "params": {
  "type": "shared",
  "name": "For my Nutritionist",
  "permissions": [
    {
    "streamId": "sharing",
    "level": "read"
  }
]}
```
This method allows you to share particular events (e.g "blood-analysis-july" event) with third parties, while retainining the original event in another stream.

### Handling multiple devices

Let's imagine that you are storing data from multiple devices/data sources in a Pryv.io user's account:
- a **Smartwatch** that collects the heart rate of the user during his sleep (`blood-pressure/mmhg-bpm` events)
- a **Sleep Control Mobile App** that controls the sleep quality using data from the smartwatch (`sleep/analysis` events)
- a **Glucose Monitoring Device** thats is used at home to daily monitor glucose levels (`density/mmol-l` events) and added in the health profile of the user

One general advice is to use one stream or substream per device. Each event can be stored across one or multiple streams: this enables you to save an event, e.g a `sleep/analysis` event, in both streams **Sleep Control Mobile App** and **Health** and to contextualize the event (more on this [here](#storing-an-event-in-multiple-streams)).

Given this situation, we would recommend a stream structure similar to the following:
```js
├── Health
│   ├── Sleep
│   │    └── `sleep/analysis` events
│   ├── Height
│   │    └── `length/cm` events
│   ├── Sugar
│   │    └── `density/mmol-l` events
│   └── Weight
│        └── `mass/kg` events
├── Smartwatch
│    ├── Position
│    │   └── `position/wgs84` events
│    └── Heart rate
│        └── `blood-pressure/mmhg-bpm` events
├── Glucose Monitoring Device
│    └── Glucose level
│        └── `density/mmol-l` events
└── Sleep Control Mobile App
     └── Sleep quality
         └── `sleep/analysis` events
```
This allows you to easily retrieve all events related to one device (e.g "Smartwatch" or "Glucose Monitoring Device"): 

```json
{
  "method": "events.get",
  "params": {
    "streamIds": [ "smartwatch"],
  }
}
```
At the same time, events related to the device can also be stored in other streams of data to be placed in the necessary context (e.g "Physical activity" or "Health").

### Referencing events

As some of your Pryv.io events may be linked to one another, you might need to reference events between themselves.
To do so, multiple options are available depending on your use case:
- **View data jointly**
Let's say you want to visualize all events that happened at the same time frame of the day, for example during your ECG recording on Monday morning.
To do so, it is sufficient to get all the events related to the ECG recording using the time reference:
1. Find the time reference you are searching for (`time` parameter of your ECG event)
2. Get all events occuring in the time frame that includes the ECG recording

This will allow you to retrieve all time-related events to your ECG recording: the weight associated to the recording if measured, the device associated to the recording, etc.

- **Keep memory of the raw event for a processed result**
In case you want to keep in memory the raw event from which the processed result of your algorithm is coming from, you can reference the raw event in the `clientData` field of your processed result.
For example, let's say that your Allergen Exposure app computes the allergen exposure of your app user using his geolocation.

Your raw ECG measurement:
```json
{
  "id": "ckd0br289000o5csm15xw6776",
  "time": 1595601190.665,
  "streamIds": ["geolocation"],
  "type": "position/wgs84",
  "content": {"latitude": 40.714728, "longitude": -73.998672}
}
```

The processed result from your algorithm:
```json
{
  "id": "csh1rb4560567p5mst35sy9876",
  "time": 1786234164.463,
  "streamIds": ["pollen-exposure"],
  "type": "density/kg-m3",
  "content": 320,
  "clientData": {"raw-event:key": "ckd0br289000o5csm15xw6776"}
}
```

The field `clientData` enables you to reference the event from which the processed result is originating and to make references across different events.

- **Make a query on different events** 
To get all the different events associated to the same event, we recommend to store all the references to these events in a single event on a dedicated stream, e.g "Session".
Let's say you want to get the weight (event stored in the stream "Weight" of type `mass/kg`) associated to the ECG recording (event stored in the stream "Recording" of type `ecg/6-lead-recording`).
Pryv.io does not allow to filter events in the same way as a classic database when performing an "events.get" API call.

A possible solution is to create an event of type `session/record` that contains all references to related events in a dedicated stream "Session-1":
```js
├── Recording
│   └── ECG-recording
│       └── "ecg/6-lead-recording" event ("id": "ckd0br28a000z5csmi4f1cn8y")
├── Health
│    ├── Weight
│    │   └── "mass/kg" event ("id": "czj2re389000o5csm15xw6776")
│    └── Heart rate
│        └── "blood-pressure/mmhg-bpm" event ("id": "czj2pk293847o5lsk35xw0987")
├── Devices
│    └── ECG-device
│        └── "ecg-device/parameters" event ("id": "cql2tz098234o5cjr12xw9034")
└── Sessions
     ├── Session-1
     │  └── "session/record" event ("id": "crt2lk039111r4wrt252xw3445")
     └── ...
```
The event containing all references across related events:
```json
{
  "id": "crt2lk039111r4wrt252xw3445",
  "time": 1595601190.345,
  "streamIds": ["Session-1"],
  "type": "session/record",
  "content": {"ckd0br28a000z5csmi4f1cn8y","czj2re389000o5csm15xw6776", "czj2pk293847o5lsk35xw0987", "crt2lk039111r4wrt252xw3445"},
}
```
This method allows you to store all related events to a measurement in order to facilitate the query.

All the forementioned solutions can be used together to reference events across them, but some of them will be more suitable than others depending on the use case. 

### Storing technical data from devices
### Defining accesses to the streams](#defining-accesses-to-the-streams)
### Performing an access delegation](#performing-an-access-delegation)
### Storing patient accesses

You are conducting an Allergology Exposition research, in which you analyze the exposition of subjects to allergens by tracking their geolocation through your app.
You have been collecting consent from your app users to use their data and you need to store these accesses on Pryv.io. You will therefore need a "campaign" stream structure which allows you to store the accesses for your app.






## Storing patient accesses

Let's imagine now a slightly different use case. You are conducting an Allergology Exposition research, in which you analyze the exposition of subjects to allergens by tracking their geolocation through your app.

- Stream structure

You have been collecting consent from your app users to use their data and you need to store these accesses on Pryv.io. You will therefore need a "campaign" stream structure which allows you to store the accesses for your app.

![Example Campaign Structure](/assets/images/Campaign.svg)

The "campaign" data structure will contain the following streams:

- The stream **Campaign description**, in which you will store information about the authorization you are requesting. You can do a [streams.create](/reference/#create-stream) call with the following data:

```json
{
  "id": "campaign-description",
  "name": "Campaign description",
  "parentId": "allergology-exposition-campaign"
}
```
Its events will include the fields necessary to perform an [Auth request](/reference/#auth-request):

  - `requestingAppId`, your app's identifier that wishes to access data from the users
  - `requestedPermissions`, containing the streams your app wants to access and their associated level of permission
  - `clientData`, containing the consent information of your user

You can do an [events.create](/reference/#create-event) call containing this information:

```json
{
  "event": {
    "id": "ck9ckvwfo000vt4pvrudxci9b",
    "time": 1385046854.282,
    "streamIds": ["campaign-description]",
    "type": "campaign/auth-request",
    "content": {
      "requestingAppId": "allergen-exposure-app-id",
      "requestedPermissions": [
      {
          "streamId": "geolocation",
          "level": "read",
          "defaultName": "Geolocation"
      }],
      "clientData": {
        "app-web-auth:description": {
          "type": "note/txt",
          "content": "This is a consent message."
        }
      }
    }
  }
}
```
- The stream **Patient accesses** that will store the credentials in `pryvApiEndpoint` format (see [App guidelines](/guides/app-guidelines/)) for every subject that granted access to their data. You can do a [streams.create](/reference/#create-stream) call with the following data:

```json
{
  "id": "patient-accesses",
  "name": "Patient accesses",
  "parentId": "allergology-exposition-campaign"
}
```
The events of this stream will contain the credentials of every subject that granted access to their data, in particular the `pryvApiEndpoint` associated with their Pryv.io account.

You can do an [events.create](/reference/#create-event) call to store the credentials of "Subject 01" for example:
```json
{
  "event": {
    "id": "jk8ujvwfo000vt4vprfriwd5a",
    "time": 1385046854.285,
    "streamIds": ["patient-accesses"],
    "type": "access/pryv-api-endpoint",
    "content": "https://ck0qmnwo40007a8ivbxn12zt7@subject01.pryv.me/"
  }
}
```
- Implementation

For this stream structure, you can create the streams as explained [here](/reference/#create-stream) or all in one by doing a "batch call" :
```json
[
  {
    "method": "streams.create",
    "params": {
      "id": "allergology-exposition-campaign",
      "name": "Allergology Exposition Campaign"
    }
  },
    {
    "method": "streams.create",
    "params": {
      "id": "campaign-description",
      "parentId": "allergology-exposition-campaign",
      "name": "Campaign description"
    }
  },
  {
    "method": "streams.create",
    "params": {
      "id": "patient-accesses",
      "parentId": "allergology-exposition-campaign",
      "name": "Patient accesses"
    }
  }
]
```
