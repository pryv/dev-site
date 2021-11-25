---
id: concepts
title: API concepts
layout: default.pug
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

The API supports versioning, allowing to retrieve all previous versions of a specific event, necessary for audit activities. It is also possible for events to have a duration to represent a period instead of a single point in time.

See also [standard event types](/event-types/#directory).

### Streams

Streams are the fundamental contexts in which events occur. Every event occurs in at least one stream. Streams follow a hierarchical structure—streams can have sub-streams—and usually match either user/app-specific organizational levels (e.g. life journal, work projects, etc.) or data sources (e.g. apps and/or devices).

### System streams

System streams are the predefined structure of streams. It is loaded from the config and is not
saved in the database. It could not be edited using streams API endpoints.

Before each account stream id would see a **dot**.
Current default streams include `.account` and `.helpers` streams and there will be more with 
future features. 

To filter all events that belong to the system-streams, you can filter the  events streamIds and
search for the dot before each stream id.


### Tags

**(DEPRECATED)** Please use streamIds instead.

Tags can provide further context to events. Each event can be labeled with one or more tags. Each tag can be no more than 500 characters in size.

### HF series

High-frequency series are collections of homogenous data points. They should be used when the structure of the data doesn't change and when a high volume of data at possibly high speeds (O(1Hz)) is expected.

You can read more about the [HF series data structure](/reference-preview/#hf-series) through the preview reference.

## Accesses

Custom applications can access Pryv user accounts via accesses. Each access defines what data it grants access to and how.

- **Shared** accesses are used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), depending on the sharing user's choice. Access is obtained by presenting the access' key, called a **Token** (which can be transmitted via different communication channels depending on use cases). This type of access can not create other accesses.
- **App** accesses are used by the majority of apps that do not need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs. An app Access is obtained by the user authorizing the requesting app after authenticating on Pryv (OAuth2-three-legged-style). This type of access can only create shared accesses with lower or equivalent permissions. If an app token is destroyed, it automatically destroys the shared tokens that were generated from this app token. 
- **Personal** accesses are used by apps that need to access the entirety of the user's data and/or manage account settings. They grant full permissions, including management of other accesses. Personal accesses require the app to be registered as a trusted Pryv app. Access is obtained by the user directly authenticating with her personal credentials within the app. This type of access can create app accesses.

Accesses can be made to expire after some time; see the `expireAfter` and `expires` attributes for more information.

Accesses **cannot be updated**, to change Access properties it should be revoked with [`accesses.delete`](/reference/#delete-access) and re-created with [`accesses.create`](/reference/#create-access). The token can be preserved if provided during creation.

For security reason, unless explicitly indicated by the permission `{ "feature": "selfRevoke", "setting": "forbidden"}` all accesses can be used to revoke (delete) themselves. In very specific cases, for example when a token is distributed publicly the `selfRevoke` feature should be set to `forbidden`.  

## Entreprise License & Open-Source License

Pryv.io is released under two licenses:

1. **Open-Pryv.io**: Is distributed freely under [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause) 
2. **Pryv.io Entreprise**: Is distributed under a commercial license and comes with more features. In the API documentation these features are indicated with a <span class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>label.
For more information about Pryv.io Entreprise edition, visit [pryv.com](https://pryv.com)


