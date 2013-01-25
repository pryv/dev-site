---
doc: reference
sectionId: data-structure
sectionOrder: 5
---

# Data structure

This section describes the structure of the different types of objects and values exchanged in the API.


## <a id="data-structure-access"></a>Access

An access defines a set of permissions on a user's activity data (channels, folders and events). (See [how sharing works](overview.html#sharing).)

Fields:

- `token` (string): Unique, read-only (except at creation). The token identifying the access. Automatically generated if not set when creating the access; URL-encoded if necessary.
- `type` (`"personal"`, `"app"` or `"shared"`): Optional. The type — or usage — of the access. Default: `"shared"`.
- `name` (string): Unique *per type and device name (if defined)*. The name identifying the access for the user. (Note that for personal and app access, the name is used as a technical identifier and not shown as-is to the user.)
- `deviceName` (string): Optional. Unique *per type and name (if defined)*. For app accesses only. The name of the client device running the app, if applicable.
- `permissions`: an array of channel permission objects as described below. Ignored for personal accesses. Shared accesses are only granted access to activity data objects listed in here.
	- `channelId` ([identity](#data-structure-identity)): The accessible channel's id.
	- `level` (`"read"`, `"contribute"` or `"manage"`): The level of access to the channel. With `"contribute"`, the access's token holder(s) can see and record events in the channel; with `"manage"`, the access's token holder(s) can in addition modify the channel itself. This is overridden if specific folder permissions are defined (see below).
	- `folderPermissions`: Optional. An array of folder permission objects to define specific per-folder permissions. If defined, only the folders listed here will be accessible.
		- `folderId` ([identity](#data-structure-identity)): The accessible folder's id. If the folder has child folders, they will be accessible too. A  value of `null` can be used to set permissions for events that have no folder assigned.
		- `level` (`"read"`, `"contribute"` or `"manage"`): The level of access to the folder. With `"contribute"`, the access's token holder(s) can see and record events for the folder (and its child folders, if any); with `"manage"`, the access's token holder(s) can in addition create, modify and delete child folders.

A note about permissions: if the access defines conflicting permission levels (e.g. a folder set to "manage" but a child folder within it set to "contribute"), only the highest level is considered.

TODO: example


## <a id="data-structure-bookmark"></a>Bookmark

Sharing bookmarks allow the user to keep track of accesses shared with her by other users.

Fields:

- `id` ([identity](#data-structure-identity)): Unique, read-only. The server-assigned identifier for the bookmark.
- `name` (string): Unique. A name identifying the bookmark for the user.
- `url` (string): The url pointing to the shared access's owning user's server. Not modifiable after creation.
- `accessToken` [identity](#data-structure-identity): The token of the shared access itself. Not modifiable after creation.

TODO: example


## <a id="data-structure-channel"></a>Channel

Each activity channel represents a "stream" or "type" of activity to track, acting as a storage bucket for related events.
Fields:

- `id` ([identity](#data-structure-identity)): Unique, read-only (except at creation). The identifier for the channel. Automatically generated if not set when creating the channel; URL-encoded if necessary.
- `name` (string): Unique. The name identifying the channel for users.
- `enforceNoEventsOverlap` (boolean): Optional. If specified and `true`, the system will ensure that period events in this channel never overlap.
- `clientData` ([item additional data](#data-structure-additional-data)): Optional. Additional client data for the channel.
- `timeCount` ([timestamp](#data-structure-timestamp)): Read-only. Only optionally returned when querying channels, indicating the total time tracked in that channel since a given reference date and time. **This will be implemented later.**
- `trashed` (boolean): Optional. `true` if the channel is in the trash.

TODO: example


## <a id="data-structure-event"></a>Event

Activity events can be period events, which are associated with a period of time, or mark events, which are just associated with a single point in time:

- Period events are used to track everything with a duration, like time spent drafting a project proposal, meeting with the customer or staying at a particular location.
- Mark events are used to track everything else, like a note, a log message, a GPS location, a temperature measurement, or a stock market asset value.

Differentiating them is simple: period events carry a duration, while mark events do not. Like folders, events always belong to an activity channel.

Fields:

- `id` ([identity](#data-structure-identity)): Unique, read-only. The server-assigned identifier for the event.
- `channelId` ([identity](#data-structure-identity)): Read-only. The id of the belonging channel.
- `time` ([timestamp](#data-structure-timestamp)): The event's time. For period events, this is the time the event started.
- `duration` ([timestamp](#data-structure-timestamp) difference): Optional. If present, indicates that the event is a period event. Running period events have a duration set to `null`. (We use a dedicated field for duration — instead of using the `value` field — as we do specific processing of event durations, intervals and overlapping.)
- `type` (object): The type of the event. See the [event types directory](event-types.html) for a list of standard types.
	- `class` (string): The type's class. Events in the same class are considered comparable and convertible.
	- `format` (string): The type's format. Depending on the class, it may indicate a measurement unit, a currency, a string format, an object structure, etc. Together with `class`, it indicates how to handle the event's `value`, if any.
- `value` (any type): Optional. The value associated with the event, if any. Depending on the `type`, this may be a mathematical value (e.g. mass, money, length, position, etc.), a link to a page, location coordinates, etc.
- `folderId`([identity](#data-structure-identity)): Optional but always present in read items. Indicates the particular folder the event is associated with; `null` if no folder is assigned.
- `tags` (array of strings): Optional but always present in read items. The tags associated with the event.
- `description` (string): Optional. User description or comment for the event.
- `attachments`: Optional and read-only. An object describing the files attached to the event. Each of its properties corresponds to one file and has the following structure:
	- `fileName` (string): The file's name. The attached file's URL is obtained by appending this file name to the event's resource URL.
	- `type` (string): The MIME type of the file.
	- `size` (number): The size of the file, in bytes.
- `clientData` ([additional item data](#data-structure-additional-data)):  Optional. Additional client data for the event.
- `trashed` (boolean): Optional. `true` if the event is in the trash.
- `modified` ([timestamp](#data-structure-timestamp)): Read-only. The time the event was last modified.

### Example

```javascript
[
  { "time": 1350365877.359, "description" : "Some pics", "id" : "event_0", "folderId" : null,
    "tags": ["foraging", "funny"],
    "type": { "class": "picture", "format": "attached" },
    "attachments" : {
      "Gina": { "fileName": "gina.jpeg", "type": "image/jpeg", "size": 1236701 },
      "Enzo": { "fileName": "enzo.jpeg", "type": "image/jpeg", "size": 1127465 }},
      "modified" : 1350463077.359 },
  { "time" : 1350369477.359, "duration" : 7140, "description": "A period of work",
    "id" : "event_1", "folderId" : "free-veggies",
    "tags": ["proposal"],
    "type": { "class": "activity", "format": "pryv" },
    "modified" : 1350369477.359 },
  { "time" : 1350373077.359, "description" : "A position", "id" : "event_2", "folderId" : null,
    "tags": [],
    "type": { "class": "position", "format": "wgs84" },
    "value": { "location": { "lat": 40.714728, "lng": -73.998672, 12 } },
    "modified" : 1350373077.359 }
]
```


## <a id="data-structure-folder"></a>Folder

Activity folders are the possible states or categories you track the channel's activity events into (folders are always specific to an activity channel). Every period event belongs to one folder, while mark events can be recorded "off-folder" as well. Activity folders follow a hierarchical tree structure: every folder can contain "child" folders (sub-folders).

Fields:

- `id` ([identity](#data-structure-identity)): Unique, read-only (except at creation). The identifier for the folder. Automatically generated if not set when creating the folder; URL-encoded if necessary.
- `channelId` ([identity](#data-structure-identity)): Read-only. The id of the belonging channel.
- `name` (string): A name identifying the folder for users. The name must be unique among the folder's siblings in the folders tree structure.
- `parentId` ([identity](#data-structure-identity)): Optional. The identifier of the folder's parent, if any. A value of `null` indicates that the folder has no parent (i.e. root folder).
- `hidden` (`true` or `false`): Optional. Whether the folder is currently in use or visible. Default: `true`.
- `clientData` ([item additional data](#data-structure-additional-data)):  Optional. Additional client data for the folder.
- `timeCount` ([timestamp](#data-structure-timestamp)): Read-only. Only optionally returned when querying folders, indicating the total time spent in that folder, including sub-folders, since a given reference date and time. **This will be implemented later.**
- `children` (array of folders): Read-only. The folder's sub-folders, if any. This field cannot be set in requests creating a new folders: folders are created individually by design.
- `trashed` (boolean): Optional. `true` if the folder is in the trash.

### Example

A folder structure for activities:

```javascript
[
  { "name": "Sport", "id": "sport", "parentId": null,
    "children": [
      { "name": "Jogging", "id": "jogging", "parentId": "sport", "children": [] },
      { "name": "Bicycling", "id": "bicycling", "parentId": "sport", "children": [] }
  ]},
  { "name": "Work", "id": "work", "parentId": null,
    "children": [
      { "name": "Noble Works Co.", "id": "noble-works","parentId": "work", "children": [
          { "name": "Last Be First", "id": "last-be-first","parentId": "noble-works", "children": [] },
          { "name": "Big Tree", "id": "big-tree","parentId": "noble-works", "children": [] },
          { "name": "Inner Light", "id": "inner-light","parentId": "noble-works", "children": [] }
      ]},
      { "name": "Freelancing", "id": "freelancing","parentId": "work", "children": [
          { "name": "Funky Veggies", "id": "funky-veggies","parentId": "freelancing", "children": [] },
          { "name": "Jojo Lapin & sons", "id": "jojo-lapin","parentId": "freelancing", "children": [] }
      ]}
    ]
  }
];
```


## <a id="data-structure-additional-data"></a>Item additional data

An object (key-value map) for client apps to store additional data about the containing item (channel, event, etc.), such as a color, a reference to an associated icon, or other app-specific metadata.

### Adding, updating and removing client data

When the containing item is updated, additional data fields can be added, updated and removed as follows:

- To add or update a field, just set its value; for example: `{ "clientData": { "keyToAddOrUpdate": "value"}}`
- To delete a field, set its value to `null`; for example: `{ "clientData": { "keyToDelete": null}}`

Fields you don't specify in the update are left untouched.

### Naming convention

The convention is that each app names the keys it uses with an `"{app-id}_"` prefix. For example, an app named "Riki" would store its data in fields such as `"riki_key": "(some value)"`.


## <a id="data-structure-error"></a>Error

Fields:

- `id` (string): Identifier for the error; complements the response's HTTP error code.
- `message` (string): A human-readable description of the error.
- `subErrors` (array of errors): Optional. Lists the detailed causes of the main error, if any.


## Simple types


### <a id="data-structure-identity"></a>Item identity

A string value uniquely identifying an item of a given type (e.g. channel, event) for a given user. For some types of items ("structural" ones such as channels and folders), it is allowed for the identity to be optionally set by API clients; otherwise the identity is generated by the server as an alphanumeric string.


### <a id="data-structure-timestamp"></a>Timestamp

A positive floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Here are some examples of getting a valid timestamp in various environments:

- JavaScript: `Date.now() / 1000`
- PHP (5+): `microtime(true)`
- TODO: more examples


### <a id="data-structure-language-code"></a>Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).
