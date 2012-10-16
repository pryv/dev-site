---
sectionId: overview
sectionOrder: 1
---

# Pryv API overview

The API is the HTTP programming interface to Pryv, which allows you to integrate Pryv activity data (and possibly user account management) into your web or native app.


## Basics

There are two different uses for the API:

- Most apps will want to interact with [Pryv activity data](#activity). Recording and managing of activity data (events and their organization into folders and tags) is protected by [data access tokens](#data-types-token) to allow easy [sharing](#overview-sharing).
- Some apps may need to access [user account administration](#admin), which includes the management of data sharing (via data access tokens) and activity channels (in addition to the user account itself). Administration is protected by personal authentication and expiring sessions.

[TODO: add simple schema here]

### What's activity data?

Activity data is, at the core, just **events**: pieces of data attached to moments in time. Events can be thoughts, audio notes, photos, geographical coordinates etc. To allow Pryv apps to play nicely together and help users organize those events, however, there are a few additional things you need to know about:

- Each event belongs to a **channel**. A channel is a stream of events users usually want to see and manage together. For example, a user's thoughts, diary and social activities (Facebook, Twitter,... ) will be recorded in the same channel. There are a few standard channels there for your app to use (TODO: link to upcoming section listing standard channels & folders), but if you manage rather specific stuff you'll probably want your app to create and use its own channel. Most apps will just deal with a single channel.
- Within a channel, events can be classified and organized using folders, tags, or both:
	- **Folders** offer a hierarchical structure for classifying and filtering events. They are exclusive (one event can only be classified into a single folder), and can contain sub-folders (child folders). Depending on your app, you may actively use folders and let the user manage them (as for a time tracking app to classify time spent on particular projects), just use a single folder (as for a social media plugin: a Facebook plugin may store all its events into a "Facebook" folder), or just not care about folders at all (if your app uses its own channel and tags are all you need, for example).
	- **Tags** offer a flat, many-to-many organization for labeling and filtering events. One event can be tagged with multiple tags. TODO: detail when UX is better defined. For example, personal notes could be tagged as *essentials* or *important*, or professional activities could be tagged as *prospection*, *meeting*, *development* or *support*.

Note that as an open system, to provide true interoperability, Pryv does not set or enforce "ownership" of data per app. Provided the necessary permissions, data stored by a given app can be accessed and manipulated by any other app.
See the standard channels, folders and tags (TODO: link) we encourage you to use when appropriate if you want your app to integrate nicely within the user's Pryv experience.

### <a id="overview-sharing"></a>How sharing works

[TODO: schema?]

Apps access a user's activity data by presenting the API with a **data access token** (or just "token" here). A token can be *personal* or *shared*. A personal token is assigned to an app (provided the user's credentials) and used by that app to access the user's data on her behalf (i.e. with full permissions). But end-users don't have to know about personal tokens; end-users care about sharing, which is managed via shared tokens.

A **shared token** grants permissions to a specified set of the user's data: channel(s), and within those channels, folder(s), tag(s) and/or a limited time frame can be defined to filter events. Tokens allow sharing in a variety of ways, such as:

- in-app: the user chooses to share some events with another Pryv user, which is notified and can select to view (and possibly contribute to) the shared data or integrate it with her own
- URL copy-paste: the user choose to share data with another person (possibly not a Pryv user), and copies the full URL containing the token into an e-mail or chat message. The other person can open the URL and access the web app to view (and possibly contribute to) the shared data.

For the present time, tokens are not personal. They act exactly like digital keys: if you have the token and the name of the user it belongs to, you can access the data it exposes.

For more details see tokens [management](#admin-tokens) and [data structure](#data-types-token).


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
Authorization: {token}
```

Note that the API also supports Socket.IO, for both calling API methods and receiving live notifications of changes to activity data. See [our dedicated section](#socketio).


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


## Errors

When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an [error](#data-types-error) object detailing the cause.

Here's an example "401 Unauthorized" error response:
```json
{
  "id": "INVALID_TOKEN",
  "message": "Cannot find token 'bad-token'."
}
```