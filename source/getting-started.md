---
id: getting-started
title: 'Get started with Pryv.io API'
template: default.jade
withTOC: true
---

In this tutorial, we will help you to try out and evaluate Pryv.io API for your
projects. Throughout these steps, we will use **Pryv.me**, our [Lab platform](http://pryv.com/pryvlab/) for testing Pryv.io API.

We will guide you through:

1. [Creating a Pryv.me User](#user-creation)
2. [Data Modelling](#data-modelling)
3. [Authorizing your Application](#authorize-your-application)
4. [Managing Access](#access-management)

# Create a Pryv.me User

By registering with **Pryv.me**, you will have access to a Pryv.io user and a fully-functional Pryv.io environment hosted in our laboratory infrastructure, perfect for your first tests.

1. Go to the [registration page](https://sw.pryv.me/access/register.html) (click the link).
2. Fill in the form, choose [where you want to store your data](http://api.pryv.com/concepts/#servers) and click the '**Create**' button.

That's it! You will receive a welcome email from Pryv.me with your account details.

/!\ Data in Pryv.io has a geographical location that doesn't change. This makes it easier to control what legislations apply.

# Sign-in to Pryv.me

Go to the following address to sign-in with your Pryv.io account:

`'https://${username}.pryv.me/#/SignIn'`

You have now access to your Pryv.me account through the Pryv.io demo dashboard. Alternatively, just click [here](https://sw.pryv.me/access/signinhub.html), enter your username and then your password in the second step.

As shown below, the streams for this account are listed, especially a default stream which is automatically created for you: 'Diary'.

![Pryv.me Dashboard: Streams](/assets/images/getting-started/streams_dashboard.png)

# Data Modelling

To design your own data model and implement it under Pryv's conventions, please check the [**dedicated page**](/guides/data-modelling) providing examples and scenarios of how the data model should be structured depending on the end use.

Pryv.io data model is composed of two entities: **events** and **streams**. 

All the data that you collect and aggregate should follow an organisation in streams and events. 
Inside each stream can be found timestamped events : 

![Pryv.io Data Model](/assets/images/getting-started/streams_structure_v2.png)

### Streams

**Streams** are the main way of encoding context for events and are organised in a hierarchical way. They can have sub-streams and usually match either user-specific, app-specific or organizational levels (e.g. life journal, blood pressure recording, etc.) or encode data sources (e.g. apps and/or devices).

Here is an example of a stream with sub-streams (children), accordingly to the stream structure presented above. The Pulse Oximeter App has a dedicated substream, which collects "events" such as the heart rate measurements.

```json
{
  "name": "Heart",
  "parentId": null,
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
      "children": [
        {
          "name": "Pulse Oximeter App",
          "parentId": "heartRate",
          "created": 1528445704.807,
          "createdBy": "cji5os3u11ntt0b40tg0xhfea",
          "modified": 1528445704.807,
          "modifiedBy": "cji5os3u11ntt0b40tg0xhfea",
          "id": "pulseOximeterApp",
          "children": []
        }
      ]
    }
  ]
}
```

To learn how to perform CRUD (create, read, update, delete) operations on streams, please refer to the guide ["How to manipulate streams?"](/guides/manage-streams).


### Events


**Events** are the primary unit of content in Pryv.io. An event is a timestamped piece of typed data, and always occurs in one stream. 
Events either have a type from the list of [standard event types](/event-types/#directory) to allow interoperability, or an application specific type. 

Our athlete will therefore be adding different types of events, each related to specific streams:

![Pryv.io Data Model](/assets/images/getting-started/streams_structure_v2.png)

Pryv offers the possibility to manipulate a broad range of event types :
-  add **attachments** to events, for example for our athlete to post pictures of his meals in the stream "FoodA". These events will have the type `picture/attached`.
-  use **high-frequency data** to collect a high volume of data, for example for the smartwatch A to collect GPS position in real-time of the athlete. 
More information on HF series is provided in the [API reference](/reference-preview/#hf-series).
- **start** and **stop** events. This allows to specify time periods for events, or to guarantee that only one event is running at a given time in `singleActivity` streams. More information on these methods is provided [here](/reference/#start-period).

To get more details on the event types, see the [events API reference](/reference/#event).

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

To learn how to perform CRUD (create, read, update, delete) operations on events, please refer to the guide ["How to manipulate events?"](/guides/manage-events).


# Authorize your application

Continuing with our previous example we would like the Pulse Oximeter Application to be able to provision our Pryv.me account with streams and events.

For this purpose the application first needs to request access to the Pryv.io account. We present below two methods to generate a new access for our application, which materializes in the form of an app token.

For more information about Pryv.io accesses [see below](#access-management).

## Use Pryv.io Access Token Generator

The easiest way to generate an app access token is to use the Pryv Access Token Generation page.

1. Go to [the Pryv Access Token Generator: http://pryv.github.io/app-web-access](http://pryv.github.io/app-web-access)
2. Set up the required parameters

   1. Enter the Application ID ('demopryv-access')
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

3. Now click on '**Sign in**' button ![sign_in_button](/assets/images/getting-started/sign_in_button.png) - A new tab will open
4. Sign in with your Pryv account
   ![Sign In Dialog](/assets/images/getting-started/sign_in.png)
   A popup will open to inform you about the access you are about to grant.
5. Click on '**Accept**' button

   By accepting you consent that the 'demopryv-access' application can access the stream 'heart' with a 'manage' access-level. Since this stream doesn't exist yet, it will be automatically created and carry the name we provided in the 'defaultName' parameter above.

   For now, you just have to understand that we are generating a token that gives enough permissions to interact with our Pryv.io account in the scope of our example. You will learn more about accesses in [Access Management](#access-management).

   ![Accept Button](/assets/images/getting-started/accept_button.png)

6. **Your access token has been generated.**
   ![Access Token](/assets/images/getting-started/access_token.png)

## Use your own implementation

Instead of using the token generator page, it is also possible to implement the authorization process in code and obtain an access token by following the steps below.

1. Send an access request with a `POST` call to `https://access.${domain}/access`:

```bash
curl -X POST https://reg.pryv.me/access -H 'Content-Type: application/json' \
  -d '{
  "requestingAppId": "demopryv-access",
  "requestedPermissions": [
    {
      "streamId": "heart",
      "level": "manage",
      "defaultName": "Heart"
    }
  ],
  "languageCode": "fr",
  "returnURL": false
}'
```

The server should respond with something similar to this:

```json
{
  "status": "NEED_SIGNIN",
  "code": 201,
  "key": "Rp3NBpMBnkCOuuAo",
  "requestingAppId": "demopryv-access",
  "requestedPermissions": [
    {
      "streamId": "heart",
      "level": "manage",
      "defaultName": "Heart"
    }
  ],
  "url": "https://sw.pryv.me/access/access.html?lang=fr&key=Rp3NBpMBnkCOuuAo&requestingAppId=demopryv-access&returnURL=false&domain=pryv.io&registerURL=https%3A%2F%2Freg.pryv.me%3A443&requestedPermissions=%5B%7B%22streamId%22%3A%22heart%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Heart%22%7D%5D",
  "poll": "https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo",
  "returnURL": false,
  "poll_rate_ms": 1000
}
```

2. Get the url parameter from the previous response and copy it into your web browser.

```raw
https://sw.pryv.me/access/access.html?lang=fr&key=Rp3NBpMBnkCOuuAo&requestingAppId=demopryv-access&returnURL=false&domain=pryv.io&registerURL=https%3A%2F%2Freg.pryv.me%3A443&requestedPermissions=%5B%7B%22streamId%22%3A%22heart%22%2C%22level%22%3A%22manage%22%2C%22defaultName%22%3A%22Heart%22%7D%5D
```

3. Sign in with your Pryv account:

   A popup will open to inform you about the access are about to grant.

4. Click on '**Accept**' button
5. Retrieve the poll url from the previous response.

```json
"poll": "https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo"
```

6. Poll the access token with `GET` calls to the polling url:

```bash
curl -i GET https://reg.pryv.me:443/access/Rp3NBpMBnkCOuuAo
```

Once the access is generated, you should get a response with status _Accepted_ and containing the token :

```json
{
  "status": "ACCEPTED",
  "username": "demopryv",
  "token": "cjhj7i2821eq60b40dzcdx6gt",
  "code": 200
}
```

This token represents the access your application has to a users account; it only expires when the user retracts his consent. You should store this token permanently and securely in your application.


# Access Management

In our previous examples, we used an app token corresponding to a new access we generated at the end of the [Authorization flow](#authorize-your-application).

Each access is defined by a 'name', a 'type' and a set of 'permissions'.

Pryv.io distinguishes between these access types:

- _Shared_: used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels, depending on the sharing user's choice. You will not encounter this access type in your applications.
- _App_: used by applications which don't need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs. This is the type of access we used for our Pulse Oximeter application.
- _Personal_: used by applications that need to access to the entirety of the user's data and/or manage account settings.


Let's imagine that our athlete wants to share the pictures of the meals he is taking with his dietitian Tom. To do so, he needs to give permission to doctor Tom to "read" the stream 'FoodA' on which the pictures of his meals are uploaded :

![Access distribution](/assets/images/getting-started/access.png)

You can easily grant permissions to third parties with Pryv.io and we provide you some concrete examples on how to do so in the command line on the dedicated page ["Access delegation"](/guides/manage-accesses).

Each permission specifies a 'streamId', the id of the stream to which we want to give access, and an access 'level', which can be one of the following:

- `'read'`: Enable users to view the stream and its contents (sub-streams and events).
- `'contribute'`: Enable users to contribute to one or multiple events of the stream. Cannot create, update, delete and move streams.
- `'manage'`: Enable users to fully control the stream. Can create, update, delete and move the stream.

Finally, note that an existing access can be used to create other accesses, but only if the new access has lower permissions (Shared < App < Personal and Read < Contribute < Manage). Also, an access can create other accesses only in the same scope, namely with permissions on the same streams and their childrens.

# What Next?

This concludes our first tour of Pryv.io and some basic things you can do with it. Where to go from here?

- Our [external resources](/external-resources/) page presents some third party and unsupported libraries and sample applications.
- The [API Reference](/reference/) explains all calls you can make to Pryv.io and their parameters.
- To obtain your own Pryv.io installation, please get in contact with our [Sales Team](mailto:sales@pryv.com).
