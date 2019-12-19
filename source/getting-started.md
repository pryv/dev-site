---
id: getting-started
title: 'Get started with Pryv.io API'
template: default.jade
withTOC: true
---

In this tutorial, we will help you to try out and evaluate Pryv.io API for your
projects. Throughout these steps, we will use our [Lab platform](https://pryv.com/pryvlab/) for testing the Pryv.io API.

We will guide you through:

1. [Creating a User](#create-a-pryv-lab-user)
2. [Obtaining an Access Token](#obtain-an-access-token)
3. [Data Modelling](#data-modelling)
4. [Managing Accesses](#access-management)

# Create a Pryv Lab User

By registering on our Lab platform, you will have access to a Pryv.io user account in a fully-functional environment perfect for your first tests.

1. Go to the [registration page](https://sw.pryv.me/access/register.html).
2. Fill in the form, choose [where you want to store your data](http://api.pryv.com/concepts/#servers) under 'Hosting' and click on the '**Create**' button.

*Data in Pryv.io has a geographical location that doesn't change. This makes it easier to control what legislations apply.*

Once this is done, you will receive a welcome email from the **Pryv Lab** with your account details. You can sign-in with your Pryv.io account on the following link:

[https://sw.pryv.me/access/signinhub.html](https://sw.pryv.me/access/signinhub.html)

You have now access to your Pryv Lab account through the Pryv.io demo dashboard web application.

## Pryv demo Dashboard

The Pryv demo dashboard is a data visualization tool. 

![Dashboard Image](/assets/images/getting-started/dashboard-image-git.png)

It enables you to visualize the "events" you created, corresponding to timestamped data - that can be in the form of notes, images, GPS location, data points, etc - and to organize them into "streams", while managing the access level to this data.
To get more information on the Pryv data model of events and streams, you can jump to the [**dedicated chapter**](#data-modelling).

The dashboard will therefore be used to get a visual display of the data you will create and add to your account throughout this guide. 
As shown below, once you connect to your account, the home page of your dashboard displays the list of streams of your account, where a default stream `Diary` is automatically created.

![Pryv Lab Dashboard: Streams](/assets/images/getting-started/streams_dashboard.png)

You can easily add content (notes, pictures, positions) directly from the dashboard and select in which stream to put it.
Once data is added to your account, you can select which streams to visualize on the dashboard and which time period to display by using the scroll bar on the bottom of the dashboard.

![Johann Dashboard](/assets/images/getting-started/dashboard_johann.png)

# Obtain an Access Token

Now that your Pryv Lab account has been created, you can start adding data. In order to do so using code or API clients such as cURL or Postman, you need to obtain an access token.

The easiest is to use the **Pryv Access Token Generation** page (which is a raw implementation of [Pryv.io's oAuth-like process](/reference/#authorizing-your-app)).

1. Go to [the Pryv Access Token Generator: https://api.pryv.com/app-web-access/](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me)
2. Set up the required parameters :

   1. Enter the Application ID (ex.: `demopryv-access`)
   2. Setup the streams you want to grant access to in the permissions box
      ![Permissions Box](/assets/images/getting-started/permissions_box.png)

      ```json
      [
        {
          "streamId": "heart",
          "level": "manage",
          "defaultName": "Heart"
        }
      ]
      ```

   3. Click on '**Request Access**' button

3. Now click on the '**Sign in**' button ![sign_in_button](/assets/images/getting-started/sign_in_button.png) - A new tab will open
4. Sign in with your Pryv Lab credentials
   ![Sign In Dialog](/assets/images/getting-started/sign_in.png)
   A popup will open to inform you about the access you are about to grant.
5. Click on '**Accept**' button

   By accepting, you consent that the 'demopryv-access' application can access the stream `Heart` with a "manage" access-level. Since this stream doesn't exist yet, it will be automatically created and carry the name we provided in the `defaultName` parameter above.

   For now, you just have to understand that we are generating a token that gives enough permissions to interact with our Pryv.io account in the scope of our example. You will learn more about accesses in [Access Management](#access-management).

   ![Accept Button](/assets/images/getting-started/accept_button.png)

6. **Your access token has been generated.**
   ![Access Token](/assets/images/getting-started/access_token.png)

# Data Modelling

In this section, we provide you information on the basic concepts of the Pryv.io data model.
When adding data to your account, you need to comply with Pryv's conventions by organizing it into "streams" and "events".

To see examples and possible scenarios you might encounter, please check the [**dedicated page**](/guides/data-modelling) to learn how the data model should be structured and implemented depending on your use case.

The Pryv.io data model is composed of two entities: **events** and **streams**.   

All the data that you collect and aggregate should follow an organisation in streams and events. 
Inside each stream can be found timestamped events : 

![Pryv.io Data Model](/assets/images/getting-started/streams_structure_v2.png)

### Streams

**Streams** are the main way of encoding context for events and are organised in a hierarchical way. They can have sub-streams and usually correspond to organizational levels for the user (e.g. life journal, blood pressure recording, etc.) or encode data sources (e.g. apps and/or devices).

To learn how to perform CRUD (create, read, update, delete) operations on streams, please refer to the guide ["**How to manipulate streams?**"](/guides/manage-streams).

![Stream example](/assets/images/getting-started/stream_level_1.png)

Here is an example of a **stream** with sub-streams (children): the **Pulse Oximeter App** has a dedicated substream, which collects "events" such as the heart rate measurements.

```json
{
  "id": "heart",
  "name": "Heart",
  "parentId": null,
  "created": 1528445539.785,
  "createdBy": "cji5os3u11ntt0b40tg0xhfea",
  "modified": 1528445581.592,
  "modifiedBy": "cjhagb5up1b950b40xsbeh5yj",
  "clientData": {
    "pryv-browser:bgColor": "#e81034"
  },
  "children": [
    {
      "id": "heartRate",
      "name": "Heart Rate",
      "parentId": "heart",
      "created": 1528445684.508,
      "createdBy": "cji5os3u11ntt0b40tg0xhfea",
      "modified": 1528445684.508,
      "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
      "children": [
        {
          "id": "pulseOximeterApp",
          "name": "Pulse Oximeter App",
          "parentId": "heartRate",
          "created": 1528445704.807,
          "createdBy": "cji5os3u11ntt0b40tg0xhfea",
          "modified": 1528445704.807,
          "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
          "children": []
        }
      ]
    }
  ]
}
```

### Events

**Events** are the primary unit of content in Pryv.io. An event is a timestamped piece of typed data, and always occurs in one stream. 
Events either have a type from the list of [**standard event types**](/event-types/#directory) to allow interoperability, or an application-specific type. 

To learn how to perform CRUD (create, read, update, delete) operations on events, please refer to the guide ["**How to manipulate events?**"](/guides/manage-events).

Our athlete will therefore be adding events of different types, each related to specific streams:

![Pryv.io Data Model](/assets/images/getting-started/streams_structure_v2.png)

Here's an example of an event, corresponding to the heart rate collected by the Pulse Oximeter App as described in the streams structure above :

```json
{
  "streamId": "pulseOximeterApp",
  "type": "frequency/bpm",
  "content": 90,
  "time": 1528446260.693,
  "tags": [],
  "created": 1528446260.693,
  "createdBy": "cji5os3u11ntt0b40tg0xhfea",
  "modified": 1528446260.693,
  "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
  "id": "cji5pfumt1nu90b40chlpetyp"
}
```

Pryv offers the possibility to manipulate a broad range of event types that can be all found in the [**event type directory**](http://api.pryv.com/event-types/). 

Basic event types include :
- [**numerical values**](http://api.pryv.com/event-types/#numerical-types) to capture number values. For example, the type `count/steps` can be used to record the counting of objects (eggs, apples, steps etc.). In the case of our athlete, we can use this type to count the daily number of steps recorded by the smartwatch A;

```json
{
  "id": "c3jkdjdt000ze64d8u9z4hap",
  "streamId": "smartwatchA",
  "type": "count/steps",
  "content": 14972,
  "time": 1589358119.329,
  "tags": []
}
```

- [**complex types**](http://api.pryv.com/event-types/#complex-types), which will be relevant for specific activities and measurements. In the case of our athlete, the type `blood-pressure/bpm-mmhg` can be used to record a blood pressure measurement. It will represent an object, the blood pressure measurement, that has three properties : the systolic and diastolic blood pressure stored in mmHg, and the heart rate in bpm.

```json
{
  "id": "c4jghrjkj011ez46d8u4y3pah",
  "streamId": "pulseOximeterApp",
  "type": "blood-pressure/bpm-mmhg",
  "content": {
      "systolic": 100, 
      "diastolic": 70, 
      "rate": 75
      },
  "time": 1682359123.3923,
  "tags": []
}
```

More specific event types also involve :

-  **attachments** that can be added to events, for example for our athlete to post pictures of his meals in the stream `FoodA`. 
![Attachment](/assets/images/getting-started/attachment_example.png)

These events will have the type `picture/attached` :

```json
{
  "id": "ck2bzkjdt000ze64d8u9z4pha",
  "streamId": "foodA",
  "type": "picture/attached",
  "content": null,
  "time": 1572358119.329,
  "tags": [],
  "attachments": [
    {
      "id": "ck2bzkjdt000ze64d8u9z4pha",
      "fileName": "meal1.jpg",
      "type": "image/jpeg",
      "size": 2561,
      "readToken": "ck2bzkjdt0010e64dwu4sy8fe-3yTvQTD630qVT4qBFYtWDwrQ8mb"
    }
  ]
}
```

-  **high-frequency series** that can be used to collect a high volume of data. This data structure, described in the [**corresponding section**](http://api.pryv.com/reference/#data-structure-high-frequency-series), is used for high frequency data to resolve issues with data density. In our example, it can be used for the smartwatch A to collect GPS position in real-time of the athlete. 
![HF](/assets/images/getting-started/hf_example.png)

This data will have the type `position/wgs84` :

```json
{
  "id": "ck2klss8v00124yjx45s3jp5r",
    "time": 1572882785.023,
    "streamId": "position",
    "tags": [],
    "type": "series:position/wgs84",
    "content": {
      "elementType": "position/wgs84",
      "fields": [
        "deltaTime",
        "latitude",
        "longitude"
      ],
  }
}
```

More information on HF series is provided in the [**API reference**](/reference-preview/#hf-series).

- **start** and **stop** events. This can be very useful for time-tracking, enabling the athlete to track and report his activities in real-time (ex.: running, cycling, exercising, etc).
This allows to specify time durations for events or to guarantee that only one event is running at a given time in `singleActivity` streams. More information on these methods is provided [**here**](/reference/#start-period).

To get more details on all possible event types, see the [**events API reference**](/reference/#event).


# Access Management

You might want to give permissions to applications and third-parties to access and manage your account (by reading or adding new data).

In a previous [section](#obtain-an-access-token), we generated a token to be able to give access to Pryv.io user account to an app or a trusted third party of our choice. This token represents the access your application has to a user account; it only expires when the user retracts his consent. 
This token should be stored permanently and securely in your application.

Pryv.io enables you to define accesses with different levels of permissions for third-parties to interact with your data, or only particular folders of your data.

Let's imagine that our athlete wants to share pictures of his meals with his nutritionist Bob, and enable his doctor Tom to check the evolution of his blood oxygenation. 

To do so, he needs to give permission to his nutritionist Bob to "contribute" to the stream `FoodA` on which the pictures of his meals are uploaded. The level "contribute" will enable Bob to not only view the pictures, but also add his comments as new events in the stream `nutritionApp`. 

![Access distribution for Bob](/assets/images/getting-started/access_bob.png)

The access for the nutritionist Bob will be created by a `POST` call on accesses (see [accesses.create](https://api.pryv.com/reference/#create-access)):

```json
{
  "name": "For Nutritionist Bob",
  "permissions": [
    {
      "streamId": "FoodA",
      "level": "contribute"
    }
  ]
}
```
Similarly, the athlete will give access to the stream `heartRate` to doctor Tom on a "read" level for the doctor to be able to consult the evolution of his heart rate.

![Access distribution for Tom](/assets/images/getting-started/access_tom.png)

This will be translated into the creation of a new read access on the stream `heartRate`(see [accesses.create](https://api.pryv.com/reference/#create-access)):

```json
{
  "name": "For Doctor Tom",
  "permissions": [
    {
      "streamId": "heartRate",
      "level": "read"
    }
  ]
}
```

Thus, each access is defined by a "name", a set of "permissions" and a "type" that is optional.

Pryv.io distinguishes between three access types ("shared", "app" and "personal") which are explained in the [corresponding section](http://api.pryv.com/concepts/#accesses).

As you can see from the example above, each permission specifies a `streamId`, the id of the stream to which we want to give access, and an access `level`, which can be one of the following:
- `read`: Enables users to view the stream and its contents (sub-streams and events).
- `contribute`: Enables users to contribute to one or multiple events of the stream. Cannot create, update, delete and move streams.
- `manage`: Enables users to fully control the stream. Can create, update, delete and move the stream.

A more exhaustive explanation of the concept of "Access" and the different "levels" of permissions can be found in the [API reference](http://api.pryv.com/reference/#access).

# What Next?

This concludes our first tour of Pryv.io and some basic things you can do with it. Where to go from here?

- Our [external resources](/external-resources/) page presents some third party and unsupported libraries and sample applications.
- The [API Reference](/reference/) explains all the calls you can make to Pryv.io and their parameters.
- To obtain your own Pryv.io installation, please get in contact with our [Sales Team](mailto:sales@pryv.com).
