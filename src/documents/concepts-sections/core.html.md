---
doc: concepts
sectionId: core
sectionOrder: 1
---

# Core concepts

## User accounts

User accounts represent people or organizations that use Pryv. Each account is identified by a username. An account's data usually contains account settings, events, streams, tags and accesses.


## Servers

Each user account is served by one Pryv server; one server can host one or more accounts. Users choose what server handles their account depending on their location, privacy/legal needs and/or other constraints. The data for each account is stored individually, i.e. separately from other accounts', except account-to-server mapping information (which is currently kept globally in a central DNS directory, plus locally on each server for the accounts it serves).

See also [available server locations](#TODO).


## Events

Events are the primary units of content in Pryv. An event is a timestamped piece of typed data, possibly with one or more attached files. Depending on its type, an event can represent anything related to a particular time (picture, note, location, temperature measurement, etc.). It is possible for events to have a duration to represent a period instead of a single point in time. In the future we will also add support for references between events (allowing to model things such as albums, comments, versioning, etc.).

See also [standard event types](event-types.html#directory).


## Streams

Streams are the fundamental contexts in which events occur. Every event occurs in one stream. Streams follow a hierarchical structure—streams can have sub-streams—and usually match either user/app-specific organizational levels (e.g. life journal, work projects, etc.) or data sources (e.g. apps and/or devices).

See also [standard streams](standard-structure.html).


## Tags

Tags provide further context to events. Each event can be labeled with one or more tags. Only text tags are available at the moment, but in the future we will support typed tags for better modeling stuff such as people or places.

See also [standard tag types](#TODO).


## Accesses

Apps access Pryv user accounts via accesses. Each access defines what data it grants access to and how.

- **Shared** accesses are used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), depending on the sharing user's choice. Access is obtained by presenting the access' key (which can be transmitted via different communication channels depending on use cases).
- **App** accesses are used by the majority of apps which do not need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs; this includes the management of shared accesses with lower or equivalent permissions. App accesses require the app to be registered. Access is obtained by the user authorizing the requesting app after authenticating on Pryv (OAuth2 three-legged).
- **Personal** accesses are used by apps that need to access the entirety of the user's data and/or manage account settings. They grant full permissions, including management of other accesses. Personal accesses require the app to be registered as a trusted Pryv app. Access is obtained by the user directly authenticating with her personal credentials within the app.

See also [registering your app](#TODO).


## Subscriptions

Users can add streams shared by other users along with theirs via subscriptions (also known as bookmarks for the time being). A subscription is a reference to another user's shared access, together with details on how to integrate the shared data within the user's own streams.
