# Data types

TODO: introductory text

### Item identity

An unsigned integer number uniquely designating the item within its scope. For example:

* The identity of every activity channel must be unique within its owning user's data
* The identity of every activity state or event must be unique within its containing channel


### Timestamp

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.


### Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).


### Activity channel

* `id` (identity, TODO: link)
* `label` (string): A unique name identifying the channel for users.
* `clientData` (item additional data, TODO: link): Additional client data for the channel.

TODO: example

### Activity state

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the state.
* `label` (string): A unique name identifying the state for users within its channel.
*  `isActive` (`true` or `false`): Optional. Whether the state is currently in use. No events can be recorded for inactive states. Default: `true`.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the state.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying states, indicating the total time spent in that state, including sub-states, since a given reference date and time.
* `children` (array of activity states): Optional. The state's sub-states, if any. This field cannot be set in requests creating a new state: states must be created one by one by design.

TODO: example

### Activity event

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the event.
* `time` (timestamp): The event's time.
* `clientId` (string): A client-assigned identifier for the event when created offline, for temporary reference. Only used in batch event creation requests (TODO: link).
* `stateId`(identity, TODO: link): Optional. If set, the event is considered a state change event, otherwise it is considered a simple mark event. The value must be either a valid state's id, or `null` meaning "no tracked state".
* `comment` (string): Optional. User comment or note for the event.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the event.

TODO: example

### Item additional data

A JSON object offering free storage for clients to support extra functionality. TODO: details (no media files, limited size...) and example

TODO: "commonly used data directory" to help data reuse:

* `color`
* `url`
* ... picture, ... (does not fit the "no media files" restriction)