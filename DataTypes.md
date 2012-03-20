# Data types

TODO: introductory text


### Data access token

A data access token defines how a user's activity data (channels, states and events) is accessed. Personal access tokens are transparently generated (provided the user's credentials) by the [Admin module](/Admin) when requested by client applications, but users can define additional tokens for letting other users view and possibly contribute to their account's activity data.

Fields:

* `name` (string): Unique. The name identifying the token for the user. It can be the client application's name for automatically generated personal tokens, or any user-defined value for manually created tokens.
* `tokenString` (string): Unique. The system-generated identifier that is actually used in requests accessing activity data.
* `type` (`personal` or `shared`): Personal tokens have full access to data, while shared tokens are only granted access to data defined in field `permissions`.
* `permissions`: an array of channel permission objects as described below. Ignored for personal tokens. Shared tokens are only granted access to activity data objects listed in here.
	* `channelId` ([identity](/DataTypes#TODO)): The accessible channel's id.
	* `statePermissions`: an array of state permission objects:
		* `stateId` ([identity](/DataTypes#TODO)): The accessible state's id. A  value of `null` can be used to set permissions for the root of the states structure. If the state has child states, they will be accessible too.
		* `type` (`read-only`, `events-write` or `full-write`): The type of access to the state's data. With `events-write`, the token's holder can see and record events for the state (and its child states, if any); with `full-write`, the token's holder can in addition create, modify and delete child states.


### Activity channel

Each activity channel represents a "stream" or "type" of activity to track. For example, you may have channels tracking:

* Your current working activity
* The people you are with at the moment
* Your geographical location and that of your relatives
* The value of your stock exchange assets
* Etc.

Fields:

* `id` (identity, TODO: link)
* `name` (string): A unique name identifying the channel for users.
* `clientData` (item additional data, TODO: link): Additional client data for the channel.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying channels, indicating the total time tracked in that channel since a given reference date and time.

TODO: example


### Activity state

Activity states are the different possible states the channel's tracked activity can be in. States always belong to an activity channel.

Fields:

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the state.
* `name` (string): A name identifying the state for users. The name must be unique among the state's siblings in the states structure.
*  `isHidden` (`true` or `false`): Optional. Whether the state is currently in use or visible. Default: `true`.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the state.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying states, indicating the total time spent in that state, including sub-states, since a given reference date and time.
* `children` (array of activity states): Optional and read-only. The state's sub-states, if any. This field cannot be set in requests creating a new state: states must be created one by one by design.

TODO: example


### Activity event

Like states, events always belong to an activity channel. Events can be either state changes or "marks":

* State changes are changes of the channel's current state. For example, you change your activity from "drafting a proposal" to "meeting with the customer". The state associated with a state change event is the new state the channel is in.
* Marks are punctual events not associated with a state change. Examples: simple notes, GPS locations, temperature measurements, stock market asset values, etc. The state associated with a mark event is used as a categorization (for example, you may want to track temperature measurements at various locations in the same activity channel).

Fields:

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the event.
* `time` (timestamp): The event's time.
* `clientId` (string): A client-assigned identifier for the event when created offline, for temporary reference. Only used in batch event creation requests (TODO: link).
* `type` (`change` or `mark`): `change` for state change events, `mark` for punctual mark events.
* `stateId`(identity, TODO: link):
	* For state change events: The value must be either a valid state's id, or `null` meaning "no tracked state".
	* For mark events: Optional. Indicates the particular state the event is associated with, if any.
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
* The identity of every activity state or event must be unique within its containing channel


### Timestamp

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Examples:

* PHP -> microtime()
* ...


### Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).
