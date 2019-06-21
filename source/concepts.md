---
id: concepts
title: API concepts
template: default.jade
withTOC: true
---

## Basics

Pryv supports any type of timestamped data, modeling individual pieces as **events** (things that happen) and contextualizing them into **streams** and **tags** (the context in which the events happen).

Storage can be decentralized: you access each user account on the specific server hosting its data (e.g. `https://{username}.{domain}/`). There can be as many servers as there are accounts.

Users collect, manipulate and view events on their account (or other users' accounts) via apps, which are granted access to the parts of user data they need (e.g. specific streams). Apps can interoperate provided they support the same event types and are granted access to the same data.

Stored data is all private by default. Users share data by explicitly opening read-only or collaborative accesses to specific parts of their data (**Accesses**).

## User accounts

User accounts represent people or organizations that use Pryv as data subjects. Each account is identified by either a Pryv username or the URL of its corresponding API root endpoint. An account's data usually contains account settings (e.g. credentials, profile), events, contexts (streams, tags) and accesses.

## Servers

Each user account is served from one root API endpoint on a Pryv server; one server can host one or more accounts.
Server hosts can be chosen depending on privacy/legal context and other technical constraints. Data for each account is stored individually, i.e. separately from other accounts.

## Events

Events are the primary units of content in Pryv. An event is a timestamped piece of typed data, possibly with one or more attached files, belonging to a given context. Depending on its type, an event can represent anything related to a particular time (picture, note, location, temperature measurement, and so on).

The API supports versioning, allowing to retrieve all previous versions of a specific event, necessary for audit activities. It is also possible for events to have a duration to represent a period instead of a single point in time, and the API includes specific functionality to deal with periods.

See also [standard event types](/event-types/#directory).

### Streams

Streams are the fundamental contexts in which events occur. Every event occurs in one stream. Streams follow a hierarchical structure—streams can have sub-streams—and usually match either user/app-specific organizational levels (e.g. life journal, work projects, etc.) or data sources (e.g. apps and/or devices).

<!-- TODO: See also [standard streams](/standard-structure/). -->

### Tags

Tags can provide further context to events. Each event can be labeled with one or more tags. Each tag can be no more than 500 characters in size.

## Accesses

Custom applications can access Pryv user accounts via accesses. Each access defines what data it grants access to and how.

- **Shared** accesses are used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), depending on the sharing user's choice. Access is obtained by presenting the access' key, called a **Token** (which can be transmitted via different communication channels depending on use cases).
- **App** accesses are used by the majority of apps which do not need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs; this includes the management of shared accesses with lower or equivalent permissions. App accesses require the app to be registered. Access is obtained by the user authorizing the requesting app after authenticating on Pryv (OAuth2-three-legged-style).
- **Personal** accesses are used by apps that need to access the entirety of the user's data and/or manage account settings. They grant full permissions, including management of other accesses. Personal accesses require the app to be registered as a trusted Pryv app. Access is obtained by the user directly authenticating with her personal credentials within the app.

Accesses can be made to expire after some time; see the `expireAfter` and `expires`
attributes for more information. To disable an access please use `expireAfter=0`.

## Webhooks

External web services can register to data changes by setting up webhooks.  

Webhooks can only be created by app accesses. Once created, they will run, executing a HTTP POST request to the corresponding URL for each data change in the user account. Currently, we support notifications of data changes, a subsequent API call is necessary to fetch the changes content.  
In case of failure to send a request, the webhook will retry a defined number of times at a growing interval of time before becoming inactive after too many succeeding failures. The webhooks run rate is throttled to a minimum time between notifications, sending an array of events that occured during this period.  
All runs are saved which allows to monitor a webhook's health. 

<!-- TODO: See also [registering your app](#TODO). -->

<!-- TODO: Rewrite this part....
## Followed slices

Users can view and possibly manipulate streams shared by other users as **followed slices** of life. A followed slice is a reference to another user's shared access, together with details on how to integrate the shared data within the user's own streams.
-->
