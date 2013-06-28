---
doc: concepts
sectionId: introduction
sectionOrder: 1
---

# Core concepts

TODO: rewrite this page, quickly introducing the different concepts (events, channels, tags, accesses/sharing...), then detailing each one in a section

Pryv provides a RESTful HTTP API, allowing your web or native app to create or read Pryv activity data, or to provide user account management features.


## Integration objectives

There are two different uses for the API:

- Access activity data: Most apps will want to interact with [Pryv activity data](reference.html#activity). Recording and managing of activity data (events and their organization into folders and tags) is protected by [accesses](reference.html#data-structure-access) to allow easy [sharing](#sharing).

- Administration: Some apps may need to use the administration API to provide user account administration. Administration is protected by personal authentication and sessions, and is reserved for trusted apps.

[TODO: add simple schema here]


## <a id="activity-data"></a>Activity data


### Definition

Activity data are timestamped pieces of typed data, or **events**. Some example events are: thoughts, audio notes, photos, geographical coordinates, etc. (see the [event type directory](event-types.html#directory)).


### Detailed information

TODO reduce verbosity

To allow Pryv apps to play nicely together and help users organize those events, there are a few additional things you need to know about:

- Each event belongs to a **channel**. A channel is a stream of events users usually want to see and manage together. For example, a user's thoughts, diary and social activities (Facebook, Twitter,... ) will be recorded in the same channel. There are a few standard channels there for your app to use (see [standard structure](standard-structure.html)), but if you manage rather specific stuff you'll probably want your app to create and use its own channel. Most apps will just deal with a single channel.
- Within a channel, events can be classified and organized using folders, tags, or both:
	- **Folders** offer a hierarchical structure for classifying and filtering events. They are exclusive (one event can only be classified into a single folder), and can contain sub-folders (child folders). Depending on your app, you may actively use folders and let the user manage them (as for a time tracking app to classify time spent on particular projects), just use a single folder (as for a social media plugin: a Facebook plugin may store all its events into a "Facebook" folder), or just not care about folders at all (if your app uses its own channel and tags are all you need, for example).
	- **Tags** offer typical flat, many-to-many organization for labeling and filtering events. One event can be tagged with multiple tags. For example, personal notes could be tagged as *fun* or *important*, or professional activities could be tagged as *prospection*, *meeting*, *development* or *support*.

Note that as an open system, to provide true interoperability, Pryv does not set or enforce "ownership" of data per app. Provided the necessary permissions, data stored by a given app can be accessed and manipulated by any other app.
See the [standard channels, folders and tags](standard-structure.html) we encourage you to use when appropriate if you want your app to integrate nicely within the user's Pryv experience.


## <a id="sharing"></a>Access / sharing

[TODO: schema?]

### Overview

Apps access a user's activity data by presenting the API with an **access token**, meaning a specific instance of **access** to the data has been granted. An access can be *shared*, associated to an *app* or *personal*.


### Types of access

- **Shared** accesses can be freely defined for letting other users view and possibly contribute to their activity data. They only grant access to a specific set of the user's data (see details below).

	A **shared access** grants permissions to one or more of the user's channel(s), and further permissions within those channels, like on folder(s), tag(s) and/or a limited time frame, can be defined to filter events. Accesses allow sharing in a variety of ways, such as:

	- in-app: the user chooses to share some events with another Pryv user, which is notified and can select to view (and possibly contribute to) the shared data and/or integrate it with her own (add it to her sharing bookmarks).
	- URL copy-paste: the user choose to share data with another person (possibly not a Pryv user), and copies the full URL containing the access token into an e-mail or chat message. The other person can open the URL and access the web app to view (and possibly contribute to) the shared data.

- **App** accesses are assigned to most apps to access the user's data on her behalf. They also only grant access to a specific set of data, determined by the app's needs.

- **Personal** accesses are used by trusted apps only. They grant full access to the user's data.

Note that only trusted apps can view and manage app and personal accesses. To register your app as trusted, please [get in touch with us](mailto:developers@pryv.com).


### Other details

Users can store access tokens shared by other users by adding them to their **sharing bookmarks** (part of the administration; available to trusted apps only).

For the present time, accesses are not personal. Access tokens act exactly like digital keys: if you have the token and the name of the user with the access it identifies, you can access the data.

For more details see the API reference (TODO: fix admin links):

- Accesses [data structure](reference.html#data-structure-access) and [management](reference.html#admin-accesses)
- Bookmarks [data structure](reference.html#data-structure-bookmark) and [management](reference.html#admin-bookmarks)