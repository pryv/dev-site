---
sectionId: data-types
sectionOrder: 5
---

# Data types

TODO: introductory text.


## <a id="data-types-access"></a>Access

An access defines a set of permissions on a user's activity data (channels, folders and events). Personal accesses are automatically generated, per app, in the [administration](#admin), but shared accesses can be freely defined for letting other users view and possibly contribute to their activity data. (See [how sharing works](#overview-sharing).)

Fields:

- `token` (string): Unique, read-only. The server-assigned token for the access. This is used to identify the access in requests to activity data.
- `name` (string): Unique. The name identifying the access for the user. It can be the client application's name for automatically generated personal accesses, or any user-defined value for manually created accesses.
- `type` (`"personal"` or `"shared"`): Optional. Personal accesses have full access to data, while shared accesses are only granted access to data defined in field `permissions`. Default: `"shared"`. Note that personal accesses are not open for viewing and management by third party apps by default - if you need to manage personal accesses, please get in touch with us (TODO: link).
- `permissions`: an array of channel permission objects as described below. Ignored for personal accesses. Shared accesses are only granted access to activity data objects listed in here.
	- `channelId` ([identity](#data-types-identity)): The accessible channel's id.
	- `folderPermissions`: an array of folder permission objects:
		- `folderId` ([identity](#data-types-identity)): The accessible folder's id. A  value of `null` can be used to set permissions for the root of the folders structure. If the folder has child folders, they will be accessible too.
		- `type` (`"read"`, `"contribute"` or `"manage"`): The type of access to the folder's data. With `"contribute"`, the access's token holder(s) can see and record events for the folder (and its child folders, if any); with `"manage"`, the access's token holder(s) can in addition create, modify and delete child folders.

TODO: example


## <a id="data-types-bookmark"></a>Bookmark

Sharing bookmarks allow the user to keep track of accesses shared with her by other users.

Fields:

- `id` ([identity](#data-types-identity)): Unique, read-only. The server-assigned identifier for the bookmark.
- `name` (string): Unique. A name identifying the bookmark for the user.
- `url` (string): The url pointing to the shared access's owning user's server. Not modifiable after creation.
- `accessToken` [identity](#data-types-identity): The token of the shared access itself. Not modifiable after creation.

TODO: example


## <a id="data-types-channel"></a>Channel

Each activity channel represents a "stream" or "type" of activity to track, acting as a storage bucket for related events.
Fields:

- `id` ([identity](#data-types-identity)): Unique, read-only. The server-assigned identifier for the channel.
- `name` (string): Unique. The name identifying the channel for users.
- `strictMode` (boolean): Optional. If `true`, the system will ensure that timed events in this channel never overlap; if `false`, overlapping will be allowed. **This will be implemented later: currently all channels are considered "strict".**
- `clientData` ([item additional data](#data-types-additional-data)): Optional. Additional client data for the channel.
- `timeCount` ([timestamp](#data-types-timestamp)): Read-only. Only optionally returned when querying channels, indicating the total time tracked in that channel since a given reference date and time. **This will be implemented later.**
- `trashed` (boolean): Optional. `true` if the channel is in the trash.

TODO: example


## <a id="data-types-folder"></a>Folder

Activity folders are the possible states or categories you track the channel's activity events into (folders are always specific to an activity channel). Every period event belongs to one folder, while mark events can be recorded "off-folder" as well. Activity folders follow a hierarchical tree structure: every folder can contain "child" folders (sub-folders).

Fields:

- `id` ([identity](#data-types-identity)): Unique, read-only. The server-assigned identifier for the folder.
- `name` (string): A name identifying the folder for users. The name must be unique among the folder's siblings in the folders tree structure.
- `parentId` ([identity](#data-types-identity)): Optional. The identifier of the folder's parent, if any. A value of `null` indicates that the folder has no parent (i.e. root folder).
- `hidden` (`true` or `false`): Optional. Whether the folder is currently in use or visible. Default: `true`.
- `clientData` ([item additional data](#data-types-additional-data)):  Optional. Additional client data for the folder.
- `timeCount` ([timestamp](#data-types-timestamp)): Read-only. Only optionally returned when querying folders, indicating the total time spent in that folder, including sub-folders, since a given reference date and time. **This will be implemented later.**
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


## <a id="data-types-event"></a>Event

Activity events can be period events, which are associated with a period of time, or mark events, which are just associated with a single point in time:

- Period events are used to track everything with a duration, like time spent drafting a project proposal, meeting with the customer or staying at a particular location.
- Mark events are used to track everything else, like a note, a log message, a GPS location, a temperature measurement, or a stock market asset value.

Differentiating them is simple: period events carry a duration, while mark events do not. Like folders, events always belong to an activity channel.

Fields:

- `id` ([identity](#data-types-identity)): Unique, read-only. The server-assigned identifier for the event.
- `time` ([timestamp](#data-types-timestamp)): The event's time. For period events, this is the time the event started.
- `clientId` (string): A client-assigned identifier for the event when created offline, for temporary reference. Only used in batch event creation requests. [TODO: currently not implemented; linked to batch creation request.]
- `folderId`([identity](#data-types-identity)): Optional. Indicates the particular folder the event is associated with, if any.
- `duration` ([timestamp](#data-types-timestamp) difference): Optional. If present, indicates that the event is a period event. Running period events have a duration set to `null`. (We use a dedicated field for duration - instead of using the `value` field - as we need specific processing of event durations, intervals and overlapping.)
- `value` (object): Optional. The value associated with the event, if any. This may be a mathematical value (e.g. mass, money, length, position, etc.), or a link to a page, a picture or an attached file. To facilitate interoperability, event values are expected to have the following structure:
	- `type` (TODO: value type): The value's type in the form `{type}:{unit}`, for example `mass:kg`. [TODO: link to the value types directory when ready.]
	- `value` (boolean, number, string or `null`): The actual value in the specified type.
- `comment` (string): Optional. User comment or note for the event.
- `attachments`: Optional and read-only. An object describing the files attached to the event. Each of its properties corresponds to one file and has the following structure:
	- `fileName` (string): The file's name. The attached file's URL is obtained by appending this file name to the event's resource URL.
	- `type` (string): The MIME type of the file.
	- `size` (number): The size of the file, in bytes.
- `clientData` ([additional item data](#data-types-additional-data)):  Optional. Additional client data for the event.
- `trashed` (boolean): Optional. `true` if the event is in the trash.
- `modified` ([timestamp](#data-types-timestamp)): Read-only. The time the event was last modified.

### Example

TODO: review after tags are implemented.

```javascript
[
  { "time" : 1350365877.359, "comment" : "Some pics", "id" : "event_0", "folderId" : null,
    "attachments" : {
      "Gina" : { "fileName" : "gina.jpeg", "type" : "image/jpeg", "size" : 1236701 },
      "Enzo" : { "fileName" : "enzo.jpeg", "type" : "image/jpeg", "size" : 1127465 }},
      "modified" : 1350463077.359 },
  { "time" : 1350369477.359, "duration" : 7140, "comment": "A period of work",
    "id" : "event_1", "folderId" : "free-veggies", "modified" : 1350369477.359 },
  { "time" : 1350373077.359, "comment" : "A position", "id" : "event_2", "folderId" : null,
    "value": { "type": "position:WGS84", "value": "40.714728, -73.998672, 12" },
    "modified" : 1350373077.359 }
]
```


## <a id="data-types-additional-data"></a>Item additional data

A JSON object offering free storage for clients to support extra functionality. TODO: details (no media files, limited size...) and example

TODO: "commonly used data directory" to help data reuse:

- `color`
- `url`
- `imageIcon` (! file size)
- ...


## <a id="data-types-error"></a>Error

Fields:

- `id` (string): Identifier for the error; complements the response's HTTP error code.
- `message` (string): A human-readable description of the error.
- `subErrors` (array of errors): Optional. Lists the detailed causes of the main error, if any.


## Simple types


### <a id="data-types-identity"></a>Item identity

TODO: decide depending on the choosen database. The best would be to keep human readable identifier (see slugify). Validation rule in that case: `/^[a-zA-Z0-9._-]{1,100}$/` (alphanum between 3 and 100 chars).

- The identity of every activity channel must be unique within its owning user's data
- The identity of every activity folder or event must be unique within its containing channel


### <a id="data-types-timestamp"></a>Timestamp

A positive floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Here are some examples of getting a valid timestamp in various environments:

- JavaScript: `Date.now() / 1000`
- PHP (5+): `microtime(true)`
- TODO: more examples


### <a id="data-types-language-code"></a>Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).