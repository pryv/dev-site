---
id: data-modelling
title: 'Data Modelling'
template: default.jade
customer: true
withTOC: true
---

In the following section, you will find all the necessary information to design your own data model.

Please be aware that this guide is NOT intended to be read cover to cover (even *Clean Code* from [Uncle Bob](https://fr.wikipedia.org/wiki/Robert_C._Martin) can sound more exciting), but rather to be used as a training manual to assist you in designing your data model.

The general introduction describes Pryv.io data modelling conventions to help you understand how you should build your own data model. Then we provide you with a broad range of use cases that you can encounter while building your data model.

<p align="center">
*To savour fresh and in moderation.*
 </p>
 <p align="center">
<img src="https://media.giphy.com/media/g9582DNuQppxC/giphy.gif" width="400" />
</p>

# Table of contents

- 1 [Introduction](#introduction)
- 2 [Use cases](#use-cases)
  - 1 [Declare the stream structure](#declare-the-stream-structure)
  - 2 [Store account information](#store-account-information) 
  - 3 [Avoid event types multiplication](#avoid-event-types-multiplication)
  - 4 [Define a custom event type](#define-a-custom-event-type)
  - 5 [Share a single event](#share-a-single-event)
  - 6 [Handle multiple devices](#handle-multiple-devices)  
  - 7 [Reference events](#reference-events) 
  - 8 [Store technical data from devices](#store-technical-data-from-devices)
  - 9 [Define accesses to the streams](#define-accesses-to-the-streams)
  - 10 [Perform an access delegation](#performe-an-access-delegation)
  - 11 [Store patient accesses](#store-patient-accesses)
  

## Introduction

Data in Pryv is organized in "streams" and "events". Ok, hold on. 
What are "Streams" ?
- **Streams** are the main way of encoding context for events. They act as folders in a file system ("Health", "Geolocation", etc), and follow a tree structure with multiple roots.  

And what are "Events" ?
- **Events** are the primary unit of content in Pryv.io. They are similar to files that are inserted in their corresponding folders. An event is a timestamped piece of typed data (e.g `note/txt`), and belongs to one or multiple streams. It can either have a type from the [list of standard event types](https://api.pryv.com/event-types/) or a custom type that can be created for the intended use case.  

Be patient, it is going to become crystal-clear for you with the next example. 

Let's suppose that your app, "Best Health App", enables your user to track his health metrics and his physical activity using a smartwatch. A simple way to model his data would be to use two streams, "Health Profile" and "Smartwatch":
- "**Health Profile**" corresponds to the health metrics of the user, with for example, the sub-streams "**Height**" and "**Weight**" in which, as you can guess, the height and weight measurements are respectively added (events of type `length/cm` and `mass/kg`).
- "**Smartwatch**" contains the collected data from the smartwatch. It can be for example the geolocation of the user in the stream "**Position**" (`position/wgs84` events), the stream "**Energy-intake**" (positively correlated with the number of burgers your user has eaten during the day) and the stream "**Energy-burnt**" (corresponding to attempts to burn this fat), both containing `energy/cal` events.

The stream structure of this data model can be visually represented as below:

![Simplified Streams Structure](/assets/images/data_model_simplified.svg)

This stream structure allows you to:

- combine different type of data (attachement, notes, health records, pictures, videos) coming from different data sources
- contextualize your data into an organization similar to folders
- control on a granular level accesses to the data

Different permissions can be defined for each stream and substream, therefore enabling to share only necessary information with third-parties (apps, doctors, family, etc). If multiple actors are involved in the process, this allows to precisely control the access level to the different streams. So that your grandma doesn't have a heart attack when looking at your stream "Weight" if you don't allow her to do so.

![Access Structure](/assets/images/data_model_access.svg)

In the example above, access to particular streams of data can be restricted:

- the **Best Health App** has a `manage` access on the streams **Position** and **Energy**, and a `read` access on the streams **Height** and **Weight**
- the **Dietetician** has a `read` access on the stream **Energy**, **Height** and **Weight**

Available levels of permissions (read, manage, contribute, create-only) are defined and explained [here](/reference/#access).


## Use cases

### Declare the stream structure

> In the beginning was the Event, and the Event was in the Stream. 

Here is your starting point.  

<p align="center">
<img src="https://media.giphy.com/media/mz1kJeDVueKC4/giphy.gif" width="400" />
</p>

Building your own data model means defining your streams and events structure following this [template](https://docs.google.com/spreadsheets/d/1UUb94rovSegFucEUtl9jcx4UcTAClfkKh9T2meVM5Zo/). Such a document serves as reference for the potentially multiple actors that will implement apps for a single Pryv.io platform.
This template file describes a very simple data model that needs to be adapted to your own use case.

The Allergen data model on which the file is based is described in this structure:
![Example Streams Structure](/assets/images/data_model_allergens.svg)

*N.B.: The User's beard is for illustrative purposes solely. However you can check [here](https://www.lung.org/blog/beards-and-lung-health) what the American Lung Association thinks about the association between beard and allergy.*

Now that your data model is set, you need to declare the stream structure at each user account creation on Pryv.io. Sounds like lots of work. Well, luckily, the Creator thought about it: you can do it all in one call by using a [batch call](https://api.pryv.com/reference/#call-batch). 

Let's take the previous stream structure :

```json
├── Smartwatch
│    └── Position ("position/wgs84" events)
├── Allergen Exposure App
│    ├── Pollen ("density/kg-m" events)
│    ├── Cereal crops ("density/kg-m" events )
│    └── Hazelnut tree ("density/kg-m" events )
└── Health Profile
     ├── Digital tensiometer
     │    └── Blood pressure ("blood-pressure/mmhg-bpm" events)
     └── Weight ("mass/kg" events )
```
To add a `position/wgs84` event in the stream "Position", two options are available:

- **Use the "try and fail" method (recommended)**
```json
{
res = events.create(Event, "streamIds": ["position"])
if (res.error.id == ’unknown-referenced-resource’) {
   - streams.create: Smartwatch
   - streams.create: Position
   - res = events.create({"streamIds": ["position"], "type": "position/wgs84", ...}) 
 }
```
You **try** to add your event in the desired stream, and if it **fails** you create the stream structure. To be used sparingly when multiple events need to be added at once.

- **Create the whole stream structure before adding the event in the concerned stream** (long and tedious)
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
<!--
### Store account information

Now that you start getting a feeling of how the structure of streams and events works, you might wonder what you will do about the account information of your users.

We recommend to create dedicated streams to store account information (e.g [credentials/pryvApiEndpoint](https://api.pryv.com/event-types/#credentials)) of your users.

For example:
```js
├── Profile
    ├── Name ("id/name" events)
    ├── Credentials ("credentials/pryvApiEndpoint" events)
    └── ...
```

The [Public profile set](https://api.pryv.com/reference/#get-public-profile) can be used to store any information the user makes publicly available (e.g. avatar image). Other profile sets are likely to be deprecated soon.
-->

### Avoid event types multiplication

> Everything should be made as simple as possible, but not simpler. *- Albert Einstein*

This is what we had in mind when designing our data model in streams and events. Streams should provide the necessary context to events, so that the meaning of events can be directly understood from the stream they are in. Simple.  
The number of different event types per stream should therefore be limited, but rather the number of different streams. Not simpler.  

Let's illustrate it. Grandma needs to record her daily medication intake (daily consumption of paracetamol, spasfon and levothyrox in mg).
Two options are available to organize her stream structure:
- **Create an event-type per medication**
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
      "streamIds": ["intake"],
      "type": "paracetamol/mg",
      "content": {
        "dose": 500
      }
    }
  }
```
Problem is... Every time Grandma will need to add a new medication in her daily cocktail (and God knows she will, she's not getting younger), we will have to create a new event type. And perform some additional content validation by cloning the [Data Types Github repository](https://github.com/pryv/data-types).

- **Create a substream per medication (recommended)**
```json
├── Medication
    ├── Paracetamol ("mass/mg" events)
    ├── Spasfon ("mass/mg" events)
    └── Levothyrox ("mass/mg" events)
```
An intake of 500mg of paracetamol will be recorded this way:
```json
{
    "method": "events.create",
    "params": {
      "streamIds": ["paracetamol"],
      "type": "mass/mg",
      "content": {
        "dose": 500
       }
    }
  }
```
This solution has the advantage of resolving the forementioned problem by providing an easily adaptable structure. Every time Grandma needs to add a new medication to her cocktail, we only need to create a new stream.

As there is no limit to the number of substreams of a stream, the only limit is the sky (and Grandma's health, incidentally). 

<p align="center">
<img src="https://media.giphy.com/media/l4KibOaou932EC7Dy/giphy.gif" width="400" />
</p>

In this regard, multiplying the number of streams is a preferable solution when you need to enter data measurements for different types of components (e.g medications, diseases, multiple devices, etc) recording a similar type of measure.

### Define a custom event type

Time to get hands-on.  
If your event type is not referenced in the [default Event Types list](https://api.pryv.com/event-types/), you can create your own for your use case.  

Does it mean you can create absolutely any event type you want? Well, not exactly. It will need to follow the specification `{class}/{format}` (e.g `note/txt`). You can find more information on this in the [corresponding section](https://api.pryv.com/event-types/#basics). Events with undeclared types are allowed but their content is not validated.  

For example, let's say that you need to create a custom event type for your 12-lead ECG recording `ecg/12-lead-recording`. If you want to perform content validation and ensure that every time you retrieve a new event it has the right structure, the procedure is the following:
1. Define your event type in a JSON file, in this case `ecg.json`:
```json
{
  "ecg": {
  "formats": {
    "12-lead-recording": {
      "description": "Conventional 12-lead ECG measuring voltage with ten electrodes.",
      "type": "number"}}}
}
```
2. Fork the [Data Type repository](https://github.com/pryv/data-types) and add your `ecg.json` file
3. Validate the JSON schema of your event type
4. Publish the corresponding URL in the platform parameters to be loaded at the platform boot :
```json
EVENT_TYPES_URL: "https://api.pryv.com/event-types/flat.json"
```  

### Share a single event

Sometimes, your user might need to share a single event (and not a whole stream) with third parties. Pryv.io allows you to store an event in one or multiple streams, wich can facilitate the sharing of particular events.  
How so ?  

Let's take the example of your Grandma (again). She is storing her blood analysis results in a substream "Blood" under her "Health" profile. She usually shares the whole stream with her hematologist, but now she only needs to share her last blood analysis with her general practitioner.  

<p align="center">
<img src="https://media.giphy.com/media/efyEShk2FJ9X2Kpd7V/giphy.gif" width="400" />
</p>

To do so, you can store her last blood analysis in a stream "Sharings" that you can then easily share with her general practitioner.

```js
├── Health
│    ├── Blood
│    │   └── "file/attached" events ('blood-analysis-may', 'blood-analysis-july' events, etc)
│    └── ...
└── Sharings
    └── "file/attached" event corresponding to the last blood analysis, e.g 'blood-analysis-july' event
```

You can then create an access for her doctor on the stream "Sharings":
```json
{
"method": "access.create",
  "params": {
  "type": "shared",
  "name": "For Grandma's doctor",
  "permissions": [
    {
    "streamId": "sharings",
    "level": "read"
  }
]}
```
This method allows to share particular events (e.g the "blood-analysis-july" event) with third parties, while retainining the original event in another stream.

### Handle multiple devices

Forget about the good old times when we would have one fixed-line telephone per building, and you'd have to climb to the last floor to tell your neighboor John to answer the phone (who had lost his keys again, and that were found again). 

<p align="center">
<img src="https://media.giphy.com/media/TlG9WaojXmx3y/giphy.gif" width="400" />
</p>

Now, John not only has his own smartphone and smartwatch, but even a smart key chain that helps him to retrieve his keys.  

So how to model John's data coming from multiple devices ?  

Let's list all the possible data sources for John:
- a **Smartwatch** that collects his heart rate during his sleep (`blood-pressure/mmhg-bpm` events)
- a **Sleep Control Mobile App** that controls the sleep quality using data from the smartwatch (`sleep/analysis` events)
- a **Smart key chain** that tracks the geolocation of John's keys at any time (`position/wgs84` events) 

One general advice is to use one stream or substream per device. Each event can be stored across one or multiple streams: this enables you to save an event, e.g a `sleep/analysis` event, in both streams **Sleep Control Mobile App** and **Health** and to contextualize the event.  

Given this situation, we would recommend a stream structure similar to the following:
```js
├── Health
│   ├── Sleep ("sleep/analysis" events)
│   ├── Blood pressure ("blood-pressure/mmhg-bpm" events)
│   ├── Height ("length/cm" events)
│   └── Weight ("mass/kg" events)
├── Smartwatch
│    └── Heart rate ("blood-pressure/mmhg-bpm" events)
├── Sleep Control Mobile App
│     └── Sleep quality ("sleep/analysis" events)
└── Smart key chain
      └── Geolocation ("position/wgs84" events)
```
This allows you to easily retrieve all events related to one device (e.g "Smartwatch"): 

```json
{
  "method": "events.get",
  "params": {
    "streamIds": [ "smartwatch"],
  }
}
```
Answer:

```json
{
  "events": [
    {
      "id": "ckdfruqua000z7ppvzspqsnyz",
      "time": 1596531629.026,
      "streamIds": ["heart-rate"],
      "tags": [],
      "type": "blood-pressure/mmhg-bpm",
      "content": 85,
      "created": 1596531629.026,
      "createdBy": "ckdfruqs700047ppvzjoxu1jo",
      "modified": 1596531629.026,
      "modifiedBy": "ckdfruqs700047ppvzjoxu1jo"
    },
    {
      "id": "ckdfruqua000v7ppv37k7gokc",
      "time": 1596341634.567,
      "streamIds": ["heart-rate"],
      "tags": [],
      "type": "blood-pressure/mmhg-bpm",
      "content": 90,
      "created": 1596341634.567,
      "createdBy": "ckdfruqs700017ppvj4rci1cg",
      "modified": 1596341634.567,
      "modifiedBy": "ckdfruqs700017ppvj4rci1cg"
    }
  ]
}
```

At the same time, events related to the device can also be stored in other streams of data to be placed in the necessary context (e.g "Health").

```json
{
  "method": "events.get",
  "params": {
    "streamIds": [ "health"],
  }
}
```
Answer:

```json
{
  "events": [
    {
      "id": "ckdfruqua000z7ppvzspqsnyz",
      "time": 1596531629.026,
      "streamIds": ["heart-rate"],
      "tags": [],
      "type": "blood-pressure/mmhg-bpm",
      "content": 85
    },
    {
      "id": "ckdfruqua000v7ppv37k7gokc",
      "time": 1596341634.567,
      "streamIds": ["heart-rate"],
      "tags": [],
      "type": "blood-pressure/mmhg-bpm",
      "content": 90
    },
    {
      "id": "cfgtrzqua999f7ppv45g3zuit",
      "time": 1596341634.567,
      "streamIds": ["weight"],
      "tags": [],
      "type": "mass/kg",
      "content": 88
    },
    {
      "id": "cghztrwfs345r3llk3j69port",
      "time": 1596341634.567,
      "streamIds": ["height"],
      "tags": [],
      "type": "length/cm",
      "content": 185
    },
    {
      "id": "crtkophui678t3plk37k7tzui",
      "time": 1596341634.567,
      "streamIds": ["sleep"],
      "tags": [],
      "type": "sleep/analysis",
      "content": "inBed"
    }
  ]
}
```

### Reference events

Some of your Pryv.io events may be linked to one another, and you might need to reference events between themselves.
To do so, multiple options are available depending on your use case:

#### View data jointly  
  
Grandma went to do an ECG recording on Monday morning.

```json
{
  "id": "ckdfruqua00127ppvue8jwrpk",
  "time": 1350373077.359,
  "streamIds": ["ecg"],
  "type": "ecg/6-lead-recording",
  "content": {...},
}
```
Did the doctor take her blood pressure, or her weight along with the ECG recording ? As usual, she cannot remember. But you can easily visualize all events that happened at the same time frame of the day around her ECG recording.
To do so, it is sufficient to display all the events related to the ECG recording using the time reference:
  1. Find the time reference you are searching for (`time` parameter of the ECG event, here `time: 1350373077.359`)
  2. Get all events occuring in the time frame that includes the ECG recording
```json
{
  "method": "events.get",
  "params": {
    "fromTime": 1350373000.100,
    "toTime": 135037400.100,
    "limit": 20
  }
}
```

This will allow you to retrieve all time-related events to the ECG recording: the weight associated to the recording if measured, the device associated to the recording, etc.

#### Keep memory of the raw event for a processed result

This time, no need to visualize data but rather keep in memory the raw event from which the processed result of your algorithm is coming from.  
Let's say that your **Allergen Exposure app** computes the allergen exposure (processed result) of your user John using his geolocation (original event). You need to keep a reference to the original event (John's geolocation), in case you want to test a different algorithm to compute his allergen exposure.
To do so, you can reference the raw event in the `clientData` field of your processed result.  

John's raw event (geolocation):
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
  "clientData": { "raw-event": {
    "id": "ckd0br289000o5csm15xw6776"
  }}
}
```

The field `clientData` enables you to reference the event from which the processed result is originating and to make references across different events. 

#### Make a query on different events   
  
Grandma went to do an ECG recording on Monday morning, and still cannot remember the weight that was associated to her recording. Can you help her ?
To get all the different events associated to the same event (here the ECG recording), we recommend to store all the references to these events in a single event on a dedicated stream, e.g "Session".  
Here we want to get the weight (`mass/kg` event stored in the stream "Weight") associated to the ECG recording (`ecg/6-lead-recording` event stored in the stream "Recording").   
Pryv.io does not allow to filter events in the same way as a classic database when performing an "events.get" API call.   

A possible solution is to create a `session/record` event that contains all references to related events in a dedicated stream "ECG-Session":
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
     ├── ECG-Session
     │  └── "session/record" event ("id": "crt2lk039111r4wrt252xw3445")
     └── ...
```
The `session/record` event in "ECG-Session" contains the *eventIds* of related events:
```json
{
  "id": "crt2lk039111r4wrt252xw3445",
  "time": 1595601190.345,
  "streamIds": ["ECG-Session"],
  "type": "session/record",
  "content": {
    "ECG-recording":"ckd0br28a000z5csmi4f1cn8y",
    "Weight":"czj2re389000o5csm15xw6776",
    "Heart rate":"czj2pk293847o5lsk35xw0987",
    "ECG-device":"crt2lk039111r4wrt252xw3445"
  }
}
```
This method allows you to store all related events to a measurement in order to facilitate the query. Grandma can continue to forget stuff, her Pryv.io account is here to remember.  

<p align="center">
<img src="https://media.giphy.com/media/3o7TKDmvzlxnkkPoSA/giphy.gif" width="400" />
</p>

All the aforementioned solutions can be used together to reference events across them, but some of them will be more suitable than others depending on the use case. 

### Store technical data from devices

This might not be the most insightful data to store in a Pryv.io account, but sometimes you need to store technical data from devices you are using as it can be considered as "personal data" from your user (see [here](https://api.pryv.com/faq-api/#personal-data) for more on personal data).  

Let's imagine that you are performing an MRI scan on your patient John and you want to keep the technical data from the MRI device you are using during the scan.  
Multiple options are available to store this data:

#### Create an allocated stream in John's account (recommended)  

You can create a custom event type `mri-device/parameters` to store technical parameters of the MRI device used during the scan, and you add a new event containing the technical data in the stream "MRI-device" for each MRI scan.

```js
├── Recording
│   └── MRI-recording ("mri/signal" event)
├── Devices
│    └── MRI-device ("mri-device/parameters" event)
└── Sessions
     ├── MRI-Session ("session/record" event)
     └── ...
```
The `session/record` event in "MRI-Session" will contain all references to the MRI scan, corresponding to the *eventsIds* of all events related to the MRI scan (MRI signal, device parameters, etc).

#### Add it in the `clientData` field of the MRI scan  
  
When creating the `mri/signal` event related to the measured MRI signal during the scan, you can add the technical MRI data in the `clientData` field as in the following example:
```json
{
  "method": "events.create",
  "params": {
    "streamIds": [ "mri-recording"],
    "type": "mri/signal",
    "clientData": {
      "device-parameters":
        {
          "magneticField":"1.5",
          "FOV":30,
          "sliceThickness":5
        }
    }
  }
}
```

#### Store in a separate account 
  
Instead of storing this information in the patient account, you can choose to keep all technical data in a dedicated "System" account.
If you prefer storing this data in a separate account, you must keep in mind that the user can ask for a copy of it anytime if it is “personal” data.
You will therefore need to define a shared access for him on this data.

### Define accesses to the streams

Pryv.io streams structure allows you to define granular accesses on data and to share only necessary information with different access levels ("read", "manage", "contribute", "create-only").  
The data sharing is made on streams (acting as "folders" in your computer) instead of particular events (similar to "files"). 

Let's imagine you want to give a "manage" access to your doctor on the stream "Health" to enable him to read and update your medical data in your account:

```js
├── Health
│   ├── Sleep
│   │    └── "sleep/analysis" events
│   ├── Height
│   │    └── "length/cm" events
│   ├── Glucose
│   │    └── "density/mmol-l" events
│   └── Weight
│        └── "mass/kg" events
├── Smartwatch
│    ├── Position
│    │   └── "position/wgs84" events
│    └── Heart rate
│        └── "blood-pressure/mmhg-bpm" events
└── Sleep Control Mobile App
     └── Sleep quality
         └── "sleep/analysis" events
``` 

The data sharing involves two steps:  
1. **The access creation using the [HTTP POST /accesses](https://api.pryv.com/reference/#create-access) method**

```json
{
  "method": "accesses.create",
  "params": {
    "name": "For my doctor",
    "permissions": [
      {
        "streamId": "Health",
        "level": "manage"
      }
    ]
}
```

2. **The access token distribution**

The "HTTP POST /accesses" call will create an access token to be shared with the doctor to enable him to manage data from the stream "Health" (**"token"**: "ckd0br26e00075csmifuhrlad"):
```json
{
  "access": {
    "id": "ckd0br26e00065csmktc33x11",
    "token": "ckd0br26e00075csmifuhrlad",
    "type": "shared",
    "name": "For my doctor",
    "permissions": [{"streamId": "Health", "level": "manage"}],
    "created": 1595601190.598,
    "createdBy": "ckd0br26d00015csmbqeu11pe",
    "modified": 1595601190.598,
    "modifiedBy": "ckd0br26d00015csmbqeu11pe"
  }
}
```
The access token should be kept in a separate stream in the doctor's account to enable him to easily retrieve his patient's data (see ["Store patient accesses" section](#store-patient-accesses)), or in some database for an app access. (????)  
  
Each created access will generate a different token that can be shared with the concerned third-party (doctor, app, family, etc). Pryv.io supports three types of accesses: "personal", "app", "shared" that are hierarchically ordered (more information on accesses type [here](https://api.pryv.com/concepts/#accesses)).

### Perform an access delegation

It can happen that you need an access delegation from your app users if they cannot connect on the app to authorize apps and grant access to their data for some period of time.

To do so, you can send an auth request to your users at their first login to grant your app access to all or specific streams (see [here](https://api.pryv.com/reference/#authenticate-your-app) for more information on the auth request).

This works as a delegation of access, and the “app” token will be able to generate sub-tokens of the “shared” type and give access to data that was in its scope.

Let's imagine that your "Sleep Control Mobile App" needs to access the "Position" data from your user to perform sleep analysis, but also his "Health" data to share it with hospitals if needed:
```js
├── Health
│   ├── Sleep
│   │    └── "sleep/analysis" events
│   ├── Height
│   │    └── "length/cm" events
│   ├── Glucose
│   │    └── "density/mmol-l" events
│   └── Weight
│        └── "mass/kg" events
├── Smartwatch
│    ├── Position
│    │   └── "position/wgs84" events
│    └── Heart rate
│        └── "blood-pressure/mmhg-bpm" events
└── Sleep Control Mobile App
     └── Sleep quality
         └── "sleep/analysis" events
```
Your app will first make an auth request at the user's login:  
<p align="center">
<img src="/assets/images/delegate-access.png" alt="delegate-access" width=250 />
</p>

Once the app request is accepted by the user, the generated token will be saved by your app and used to create future shared accesses.  
This will allow your app to create a shared access whose permissions must be a subset of those granted to your app. For example:  
```json
{
  "method": "accesses.create",
  "params": {
    "name": "For the hospital",
    "permissions": [
      {
        "streamId": "glucose",
        "level": "read"
      }
    ]
}
```

### Store patient accesses

Once you have obtained an access token to a user's account, for example for a doctor to access particular streams of his patients' data, we advise you to store it in a dedicated stream.

Let's illustrate it with a basic example. The patient Ana accepts to give a "manage" access to Doctor Tom on her stream "Health", which generates the access token "ckd0br26d00035csmdqvtjfla".

Stream structure for patient Ana:
```js
├── Health
│   ├── Sleep
│   │    └── "sleep/analysis" events
│   ├── Weight
│   │    └── "mass/kg" events
│   └── Heart rate
│        └── "blood-pressure/mmhg-bpm" events
└── Sleep Control Mobile App
     └── Sleep quality
         └── "sleep/analysis" events
```

Stream structure for doctor Tom:
```js
├── Personal profile
│   ├── Name
│   │    └── "name/id" events
│   ├── Hospital
│   │    └── "name/id" events
│   └── ...
└── Patient accesses
     └── "credentials/pryvApiEndpoint" events
```

Doctor Tom will need to keep all access tokens to his patients' accounts in the dedicated stream **"Patient accesses"**.   
Every time a patient grants him access to his data, the access token to his Pryv.io account will be saved in a `credentials/pryvApiEndpoint` event under the stream "Patient accesses" (see [App guidelines](/guides/app-guidelines/) for why we use this format).   

In the case of patient Ana, the following event will be created in the stream "Patient accesses" of Doctor Tom: 
```json
{
    "method": "events.create",
    "params": {
      "streamIds": ["patient-accesses"],
      "type": "credentials/pryvApiEndpoint",
      "content": "https://ckd0br26d00035csmdqvtjfla@ana.pryv.me/"
    }
  }
```

