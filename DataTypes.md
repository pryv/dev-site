# Data types

TODO: introductory text


### Data access token

A data access token defines how a user's activity data (channels, contexts and events) is accessed. Personal access tokens are transparently generated (provided the user's credentials) by the [Admin module](/Admin) when requested by client applications, but users can define additional tokens for letting other users view and possibly contribute to their account's activity data.

Fields:

* `name` (string): Unique. The name identifying the token for the user. It can be the client application's name for automatically generated personal tokens, or any user-defined value for manually created tokens.
* `tokenString` (string): Unique. The system-generated identifier that is actually used in requests accessing activity data.
* `type` (`personal` or `shared`): Personal tokens have full access to data, while shared tokens are only granted access to data defined in field `permissions`.
* `permissions`: an array of channel permission objects as described below. Ignored for personal tokens. Shared tokens are only granted access to activity data objects listed in here.
	* `channelId` ([identity](/DataTypes#TODO)): The accessible channel's id.
	* `contextPermissions`: an array of context permission objects:
		* `contextId` ([identity](/DataTypes#TODO)): The accessible context's id. A  value of `null` can be used to set permissions for the root of the contexts structure. If the context has child contexts, they will be accessible too.
		* `type` (`read-only`, `events-write` or `full-write`): The type of access to the context's data. With `events-write`, the token's holder can see and record events for the context (and its child contexts, if any); with `full-write`, the token's holder can in addition create, modify and delete child contexts.


### Activity channel

Each activity channel represents a "stream" or "type" of activity to track.
Fields:

* `id` (identity, TODO: link)
* `name` (string): A unique name identifying the channel for users.
* `strictMode` (boolean): If `true`, the system will ensure that timed events in this channel never overlap; if `false`, overlapping will be allowed. TODO: I [SGO] suggest we only implement strict mode for a start.
* `clientData` (item additional data, TODO: link): Additional client data for the channel.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying channels, indicating the total time tracked in that channel since a given reference date and time.

TODO: example


### Activity context

Activity contexts are the possible states or categories you track the channel's activity events into (contexts are always specific to an activity channel). Every period event belongs to one context, while mark events can be recorded "off-context" as well. Activity contexts follow a hierarchical tree structure: every context can contain "child" contexts (sub-contexts).

Fields:

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the context.
* `name` (string): A name identifying the context for users. The name must be unique among the context's siblings in the contexts tree structure.
*  `isHidden` (`true` or `false`): Optional. Whether the context is currently in use or visible. Default: `true`.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the context.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying contexts, indicating the total time spent in that context, including sub-contexts, since a given reference date and time.
* `children` (array of activity contexts): Optional and read-only. The context's sub-contexts, if any. This field cannot be set in requests creating a new contexts: contexts are created one by one by design.

TODO: example


### Activity event

Activity events can be period events, which are associated with a period of time, or mark events, which are just associated with a single point in time:

* Period events are used to track everything with a duration, like time spent drafting a project proposal, meeting with the customer or staying at a particular location.
* Mark events are used to track everything else, like a note, a log message, a GPS location, a temperature measurement, or a stock market asset value.

Differentiating them is simple: period events carry a duration, while mark events do not. Like contexts, events always belong to an activity channel.

Fields:

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the event.
* `time` (timestamp): The event's time.
* `clientId` (string): A client-assigned identifier for the event when created offline, for temporary reference. Only used in batch event creation requests (TODO: link).
* `contextId`(identity, TODO: link):
	* For period events: The value must be a valid context's id. TODO: really???
	* For mark events: Optional. Indicates the particular context the event is associated with, if any.
* `duration`: Optional. If present, indicates that the event is a period event. Running period events have a duration set to `undefined`.
* `value`: Optional. A JSON object holding a value associated with the event. This value object's properties must be booleans, numbers, strings, or null values (no objects allowed).
* `comment` (string): Optional. User comment or note for the event.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the event.

TODO: example


### Item additional data

A JSON object offering free storage for clients to support extra functionality. TODO: details (no media files, limited size...) and example

TODO: "commonly used data directory" to help data reuse:

* `color`
* `url`
* `imageIcon` (! file size)
* ...


### Error

Fields:

* `id` (string): Identifier for the error; complements the response's HTTP error code.
* `message` (string): A human-readable description of the error.
* `subErrors` (array of errors): Optional. Lists the detailed causes of the main error, if any.


### Item identity

TODO: decide depending on the choosen database. The best would be to keep human readable identifier (see slugify). Validation rule in that case: `/^[a-zA-Z0-9._-]{1,100}$/` (alphanum between 3 and 100 chars).

* The identity of every activity channel must be unique within its owning user's data
* The identity of every activity context or event must be unique within its containing channel


### Timestamp

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Examples:

* PHP -> microtime()
* ...


### Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).
