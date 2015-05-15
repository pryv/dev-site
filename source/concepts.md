---
id: concepts
title: API concepts
template: default.jade
withTOC: true
---


## Basics

Pryv supports any type of timestamped data, modeling individual pieces as **events** (stuff that happens) and contextualizing them into **streams** and **tags** (the circumstances in which stuff happens).

Storage is decentralized: you access each user account on the server hosting its data (e.g. `https://{username}.pryv.io/`). There can be as many servers as there are accounts.

Users collect, manipulate and view events on their account (or other users' accounts) via apps, which are granted access to the parts of user data they need (e.g. specific streams). Apps can interoperate provided they support the same event types and are granted access to the same data.

Stored data is all private by default. Users share data by explicitly opening read-only or collaborative accesses to specific parts of their data (**slices of life**).


## User accounts

User accounts represent people or organizations that use Pryv. Each account is identified by either a Pryv username or the URL of its corresponding API root endpoint. An account's data usually contains account settings (e.g. credentials, profile), events, contexts (streams, tags) and accesses.


## Servers

Each user account is served from one root API endpoint on a Pryv server; one server can host one or more accounts.
Server hosts are typically chosen depending on users' location (typically considering network distance, with an obvious tie to performance), privacy/legal context and/or other constraints. Data for each account is stored individually, i.e. separately from other accounts' (except Pryv username-to-server mapping information, currently kept globally in a central DNS directory, plus locally on each server for the accounts it serves).


## Events

Events are the primary units of content in Pryv. An event is a timestamped piece of typed data, possibly with one or more attached files, belonging to a given context. Depending on its type, an event can represent anything related to a particular time (picture, note, location, temperature measurement, etc.).

In the future, the API will support event references, allowing to model things such as albums, comments, versioning, etc. It is also possible for events to have a duration to represent a period instead of a single point in time, and the API includes specific functionality to deal with periods.

See also [standard event types](/event-types/#directory).


## Contexts

Contexts are the circumstances in which events occur. The context of an event is the combination of a stream and tags.


### Streams

Streams are the fundamental contexts in which events occur. Every event occurs in one stream. Streams follow a hierarchical structure—streams can have sub-streams—and usually match either user/app-specific organizational levels (e.g. life journal, work projects, etc.) or data sources (e.g. apps and/or devices).

<!-- TODO: See also [standard streams](/standard-structure/). -->


### Tags

Tags provide further context to events. Each event can be labeled with one or more tags. Tags can be plain text tags or typed tags:

- Plain text tags are the usual tags you've encountered elsewhere. They exist simply by referencing them directly from events: `This is a plain text tag`.
- Typed tags are tags with data, for modelling richer structural concepts such as people, locations, etc. They exist and are managed on their own; events refer to them by their identifier, which differs from a plain text tag by its format: `:example-identifier`.
  ```
  {
    "content": { "this is": "a typed tag", "with": "arbitrary data" },
    "id": ":example-identifier",
    "type": "example/arbitrary"
  }
  ```

*Note: typed tags are coming in a future version of the API.*

<!-- TODO: See also [standard tag types](#TODO). -->


## Accesses

Apps access Pryv user accounts via accesses. Each access defines what data it grants access to and how.

- **Shared** accesses are used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), depending on the sharing user's choice. Access is obtained by presenting the access' key (which can be transmitted via different communication channels depending on use cases).
- **App** accesses are used by the majority of apps which do not need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs; this includes the management of shared accesses with lower or equivalent permissions. App accesses require the app to be registered. Access is obtained by the user authorizing the requesting app after authenticating on Pryv (OAuth2-three-legged-style).
- **Personal** accesses are used by apps that need to access the entirety of the user's data and/or manage account settings. They grant full permissions, including management of other accesses. Personal accesses require the app to be registered as a trusted Pryv app. Access is obtained by the user directly authenticating with her personal credentials within the app.

<!-- TODO: See also [registering your app](#TODO). -->


## Followed slices

Users can view and possibly manipulate streams shared by other users as **followed slices** of life. A followed slice is a reference to another user's shared access, together with details on how to integrate the shared data within the user's own streams.
