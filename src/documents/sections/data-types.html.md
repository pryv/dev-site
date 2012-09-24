---
sectionId: data-types
sectionOrder: 4
---

# Data types

TODO: review the entire chapter


## Overview

- A **channel** is an independant set of values to record. For example all the thoughts, diary and social activities (fb, twitter,... ) will be saved in the same channel.
- **folders** are the way such value are organized in the channel, like folders and files. From the previous example the channel could be named **Notes**:
*This organisation will vary depending on every user customisation.*

		Notes (channel)
		  |- Diary
		  |  |- My Life <- One, will note everything that happen in his life
		  |  |- Thought <- Texts and Voice recording from various *thoughts*
		  |
		  |- Social activities
		  	 |- Facebook  <- Automatically grabbed by facebookApp
		  	 |- Twitter <- Copy of the all tweets

- **Tags** (not yet fully implemented) are made to classify events into subtypes. Useful for filtering events in a channel.

	Exemple:
  - for Notes a classification such as *Essentials*, *Important* could be used to the filter all the Notes.
  - for Activities tags such as *Prospection*, *Meeting*, *Developpement* and *Support* will help summing all the time spent for propspection in all projects.


- **Events** are the atomic representation of an event, a thought, a position.
 They are associated with a folder and may be tagged for filtering.

#### How the folder hierarchy works

A developer can create an app and decide where (in the folder hierarchy) the user events created through this app will be saved.

A developer can create a new channel and new folders within the channel if he wants, but the basic idea is to reuse the existing hierarchy if possible. For instance, if a developer creates an app to save pictures, there may already be a channel called « pictures ». The developer could simply create a folder inside the channel « pictures » or directly save the events inside the channel itself.

If several developers decide to save their user events in the same folder, each developer will have access to the content of this folder even if it was input through a different app.

### Sharing is made by token
Sharing is done on a per-folder basis.
An authorization token is created and correspond to a set of folders in a unique channel.
For exemple, user: *username* creates the authorization token *XZV6* that matches the share of folders: **A and B**. Tokens are _read and write_ or _read only_ .

http://username.pryv.io/events?token=XZV6 will give an access to all events within folders A,a,b,B and e.

	- Channel 1
	  |- A
	  |  |- a
	  |  |- b
	  |
	  |- B
	  |  |- e
	  |
	  |- C
	     |- f
	     |- g

__Note: When *Slice of life* will be implemented__
Then, we will be able to add a time frame to a set of folders, this will add the needed granularity.

## <a id="data-types-token"></a>Token

A data access token defines how a user's activity data (channels, folders and events) is accessed. Personal access tokens are transparently generated (provided the user's credentials) by the [Admin module](/Admin) when requested by client applications, but users can define additional tokens for letting other users view and possibly contribute to their account's activity data.

Fields:

- `id` (string): Unique, read-only. The server-assigned identifier for the token. This is used to specify the token in requests with token authorization.
- `name` (string): Unique. The name identifying the token for the user. It can be the client application's name for automatically generated personal tokens, or any user-defined value for manually created tokens.
- `type` (`personal` or `shared`): Personal tokens have full access to data, while shared tokens are only granted access to data defined in field `permissions`.
- `permissions`: an array of channel permission objects as described below. Ignored for personal tokens. Shared tokens are only granted access to activity data objects listed in here.
	- `channelId` ([identity](#data-types-identity)): The accessible channel's id.
	- `folderPermissions`: an array of folder permission objects:
		- `folderId` ([identity](#data-types-identity)): The accessible folder's id. A  value of `null` can be used to set permissions for the root of the folders structure. If the folder has child folders, they will be accessible too.
		- `type` (`read-only`, `events-write` or `manage`): The type of access to the folder's data. With `events-write`, the token's holder can see and record events for the folder (and its child folders, if any); with `manage`, the token's holder can in addition create, modify and delete child folders.


## <a id="data-types-channel"></a>Channel

Each activity channel represents a "stream" or "type" of activity to track.
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
- `hidden` (`true` or `false`): Optional. Whether the folder is currently in use or visible. Default: `true`.
- `clientData` ([item additional data](#data-types-additional-data)):  Optional. Additional client data for the folder.
- `timeCount` ([timestamp](#data-types-timestamp)): Read-only. Only optionally returned when querying folders, indicating the total time spent in that folder, including sub-folders, since a given reference date and time. **This will be implemented later.**
- `children` (array of activity folders): Read-only. The folder's sub-folders, if any. This field cannot be set in requests creating a new folders: folders are created individually by design.
- `trashed` (boolean): Optional. `true` if the folder is in the trash.

#### Example of channel & folders for activities

 	Activities (channel)
 		|- Sport
 		|  |- Jogging <- entered on the mobile phone
 		|  |- Bicycle
 		|
 		|- Jobs
 			|- SimpleData
 			|  |- FirstList
 			|  |- Diagmission
 			|  |- Pryv'it
 			|
 			|- FreeLance
 			|- Customer A
 			|- Customer B


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

### exemples
TODO: this set of data is absolutly NOT inline with the def: review an complete the

#### A set of events for the -Activities- channel**
 		- 12.06.2012 17:12:30 - folder:Pryv'it
 							  - tag: setup
 							  - duration: 17:00:00
 							  - value:
 							  - comment: phonecall Frederic
 							  - data:

		- 13.06.2012 09:00:00 - folder: FirstList
							  - tag: prospection
					          - duration: 4:00:00
					          - value:
					          - comment: went to Lyon for a meeting
			                  - data:

 		- 13.06.2012 09:32:00 - folder: FirstList
 							  - tag: prospection, expense report
 							  - duration: 0
 							  - value: money:CHF:68.90
 							  - comment: fuel on the way to Lyon
 							  - data: picture:ABDGVHGSH126.jpg
 							  		type: receipt

#### A set of events for the -Notes- channel**

		- 12.06.2012 17:12:30 - folder:Thought
							  - tag:
							  - duration: 0
							  - value:
							  - comment: To be, or not to be; that is the question;
							  - data:

		- 13.06.2012 09:00:00 - folder: Facebook
							  - tag: important
							  - duration: 0
							  - value: 0
							  - comment: went to the pool with friend
							  - data: <DATA EXTRACTED FROM FB TIMELINE>

		- 13.06.2012 09:32:00 - folder: Twitter
						      - tag:
						      - duration: 0
						      - value:
						      - comment: @recla how are you doing guys?
						      - data: author:johndoe

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

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Here are some examples of getting a valid timestamp in various environments:

- JavaScript: `Date.now() / 1000`
- PHP (5+): `microtime(true)`
- TODO: more examples


### <a id="data-types-language-code"></a>Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).
