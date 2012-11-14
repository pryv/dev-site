---
sectionId: overview
sectionOrder: 1
---

# Pryv API overview

The API is the HTTP programming interface to Pryv, which allows you to integrate Pryv activity data (and possibly user account management) into your web or native app.


## Basics

There are two different uses for the API:

- Most apps will want to interact with [Pryv activity data](#activity). Recording and managing of activity data (events and their organization into folders and tags) is protected by [accesses](#data-types-access) to allow easy [sharing](#overview-sharing).
- Some apps may need to access [user account administration](#admin), which includes the management of data sharing (via accesses) and activity channels (in addition to the user account itself). Administration is protected by personal authentication and expiring sessions.

[TODO: add simple schema here]

### What's activity data?

Activity data is, at the core, just **events**: pieces of data attached to moments in time. Events can be thoughts, audio notes, photos, geographical coordinates etc. To allow Pryv apps to play nicely together and help users organize those events, however, there are a few additional things you need to know about:

- Each event belongs to a **channel**. A channel is a stream of events users usually want to see and manage together. For example, a user's thoughts, diary and social activities (Facebook, Twitter,... ) will be recorded in the same channel. There are a few standard channels there for your app to use (TODO: link to upcoming section listing standard channels & folders), but if you manage rather specific stuff you'll probably want your app to create and use its own channel. Most apps will just deal with a single channel.
- Within a channel, events can be classified and organized using folders, tags, or both:
	- **Folders** offer a hierarchical structure for classifying and filtering events. They are exclusive (one event can only be classified into a single folder), and can contain sub-folders (child folders). Depending on your app, you may actively use folders and let the user manage them (as for a time tracking app to classify time spent on particular projects), just use a single folder (as for a social media plugin: a Facebook plugin may store all its events into a "Facebook" folder), or just not care about folders at all (if your app uses its own channel and tags are all you need, for example).
	- **Tags** offer a flat, many-to-many organization for labeling and filtering events. One event can be tagged with multiple tags. TODO: detail when UX is better defined. For example, personal notes could be tagged as *essentials* or *important*, or professional activities could be tagged as *prospection*, *meeting*, *development* or *support*.

Note that as an open system, to provide true interoperability, Pryv does not set or enforce "ownership" of data per app. Provided the necessary permissions, data stored by a given app can be accessed and manipulated by any other app.
See the standard channels, folders and tags (TODO: link) we encourage you to use when appropriate if you want your app to integrate nicely within the user's Pryv experience.

### <a id="overview-sharing"></a>Accesses and sharing

[TODO: schema?]

Apps access a user's activity data by presenting the API with an **access token**, that identifies a specific **access** to the data. An access can be *shared*, associated to an *app* or *personal*.

- **Shared** accesses can be freely defined for letting other users view and possibly contribute to their activity data. They only grant access to a specific set of the user's data (see details below).
- **App** accesses are assigned to most apps to access the user's data on her behalf. They also only grant access to a specific set of data, determined by the app's needs.
- **Personal** accesses are reserved to trusted apps. They grant full access to the user's data.

Note that only trusted apps can view and manage app and personal accesses. To register your app as trusted, please get in touch with us (TODO: email or link).

A **shared access** grants permissions to one or more of the user's channel(s), and further permissions within those channels, like on folder(s), tag(s) and/or a limited time frame, can be defined to filter events. Accesses allow sharing in a variety of ways, such as:

- in-app: the user chooses to share some events with another Pryv user, which is notified and can select to view (and possibly contribute to) the shared data and/or integrate it with her own (add it to her sharing bookmarks).
- URL copy-paste: the user choose to share data with another person (possibly not a Pryv user), and copies the full URL containing the access token into an e-mail or chat message. The other person can open the URL and access the web app to view (and possibly contribute to) the shared data.

Users can store access tokens shared by other users by adding them to their **sharing bookmarks**.

For the present time, accesses are not personal. Access tokens act exactly like digital keys: if you have the token and the name of the user with the access it identifies, you can access the data.

For more details see:

- Accesses [management](#admin-accesses) and [data structure](#data-types-access)
- Bookmarks [management](#admin-bookmarks) and [data structure](#data-types-bookmark)


## What's the URL?

Because Pryv potentially stores each user's data in a different location according to the user's choice, the API's base URL is unique for each user: `https://{username}.pryv.io` (where `{username}` is the name of the user whose data you want to access).


## Calling API methods

Most of the API follows REST principles, meaning each item has its own unique resource URL and can be read or modified via HTTP verbs:

- GET to read the item(s)
- POST to create a new item
- PUT to modify the item
- DELETE to delete the item (note that logical deletion, or trashing, is supported for items like events, folders and channels)

Here's an example API request:
```http
GET /{channel-id}/events HTTP/1.1
Host: {user-name}.pryv.io
Authorization: {access-token}
```

Note that the API also supports Socket.IO, for both calling API methods and receiving live notifications of changes to activity data. See [the dedicated section](#socketio).


## Data format

The API uses JSON for serializing data. Here's what an event can look like:
```json
{
  "id": "5051941d04b8ffd00500000d",
  "time": 1347864935.964,
  "folderId": "5058370ade44feaa03000015",
  "value": {
    "type": "position:WGS84",
    "value" : "40.714728, -73.998672, 12"
  }
}
```


## Common HTTP headers

The following headers are included in every response:

- `API-Version`: The version of the API in the form `{major}.{minor}.{revision}`.
- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp). Keeping reference of the server time is an absolute necessity to properly read and write event times.


## Errors

When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an [error](#data-types-error) object detailing the cause.

Here's an example "401 Unauthorized" error response:
```json
{
  "id": "INVALID_ACCESS_TOKEN",
  "message": "Cannot find access with token 'bad-token'."
}
```
