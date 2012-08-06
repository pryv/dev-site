# Data types
Note: the names "contexts" and "folders" are equivalent and still mixed in this document. Before chnaging everything to "folders" the impact on the API must be evaluated.

## Introduction

### Definitions 

- A **channel** is an independant set of values to record. For example all the thoughts, diary and social activities (fb, twitter,... ) will be saved in the same channel.
- **folders** (named contexts in the API) are the way such value are organized in the channel, like folders and files. From the previous example the channel could be named **Notes**:  
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
 They are associated with a context and may be tagged for filtering.

#### How the folder hierarchy works
 
A developer can create an app and decide where (in the folder hierarchy) the user events created through this app will be saved.
 
A developer can create a new channel and new folders within the channel if he wants, but the basic idea is to reuse the existing hierarchy if possible. For instance, if a developer creates an app to save pictures, there may already be a channel called « pictures ». The developer could simply create a folder inside the channel « pictures » or directly save the events inside the channel itself.
 
If several developers decide to save their user events in the same folder, each developer will have access to the content of this folder even if it was input through a different app.

### Sharing is made by token 
Sharing is done on a per contexts (folders) basis. 
An authorization token is created and correspond to a set of folders in a unique channel.
For exemple, user: *username* creates the authorization token *XZV6* that matches the share of folders: **A and B**. Tokens are _read and write_ or _read only_ .

http://username.rec.la/events?token=XZV6 will give an access to all events within folders A,a,b,B and e.

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

### Data access token

A data access token defines how a user's activity data (channels, contexts and events) is accessed. Personal access tokens are transparently generated (provided the user's credentials) by the [Admin module](/Admin) when requested by client applications, but users can define additional tokens for letting other users view and possibly contribute to their account's activity data.

Fields:

- `id` (string): Unique. The system-generated identifier that is actually used in requests accessing activity data.
- `name` (string): Unique. The name identifying the token for the user. It can be the client application's name for automatically generated personal tokens, or any user-defined value for manually created tokens.
- `type` (`personal` or `shared`): Personal tokens have full access to data, while shared tokens are only granted access to data defined in field `permissions`.
- `permissions`: an array of channel permission objects as described below. Ignored for personal tokens. Shared tokens are only granted access to activity data objects listed in here.
	- `channelId` ([identity](/DataTypes#TODO)): The accessible channel's id.
	- `contextPermissions`: an array of context permission objects:
		- `contextId` ([identity](/DataTypes#TODO)): The accessible context's id. A  value of `null` can be used to set permissions for the root of the contexts structure. If the context has child contexts, they will be accessible too.
		- `type` (`read-only`, `events-write` or `manage`): The type of access to the context's data. With `events-write`, the token's holder can see and record events for the context (and its child contexts, if any); with `manage`, the token's holder can in addition create, modify and delete child contexts.


### Activity channel

Each activity channel represents a "stream" or "type" of activity to track.
Fields:

- `id` (identity, TODO: link)
- `name` (string): A unique name identifying the channel for users.
- `strictMode` (boolean): If `true`, the system will ensure that timed events in this channel never overlap; if `false`, overlapping will be allowed. TODO: I [SGO] suggest we only implement strict mode for a start.
- `clientData` (item additional data, TODO: link): Additional client data for the channel.
- `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying channels, indicating the total time tracked in that channel since a given reference date and time.

TODO: example


### Activity context (folders)
TODO: Evaluate the possibility to rename it to folders

Activity contexts are the possible states or categories you track the channel's activity events into (contexts are always specific to an activity channel). Every period event belongs to one context, while mark events can be recorded "off-context" as well. Activity contexts follow a hierarchical tree structure: every context can contain "child" contexts (sub-contexts).

Fields:

* `id` (identity, TODO: link): Read-only. The server-assigned identifier for the context.
* `name` (string): A name identifying the context for users. The name must be unique among the context's siblings in the contexts tree structure.
*  `isHidden` (`true` or `false`): Optional. Whether the context is currently in use or visible. Default: `true`.
* `clientData` (item additional data, TODO: link):  Optional. Additional client data for the context.
* `timeCount` (timestamp, TODO: link): Read-only. Only optionally returned when querying contexts, indicating the total time spent in that context, including sub-contexts, since a given reference date and time.
* `children` (array of activity contexts): Optional and read-only. The context's sub-contexts, if any. This field cannot be set in requests creating a new contexts: contexts are created one by one by design.

#### Exemple of channel & contexts (folders) for activities

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


### Activity event

Activity events can be period events, which are associated with a period of time, or mark events, which are just associated with a single point in time:

* Period events are used to track everything with a duration, like time spent drafting a project proposal, meeting with the customer or staying at a particular location.
* Mark events are used to track everything else, like a note, a log message, a GPS location, a temperature measurement, or a stock market asset value.

Differentiating them is simple: period events carry a duration, while mark events do not. Like contexts, events always belong to an activity channel.

Fields:

- `id` (identity, TODO: link): Read-only. The server-assigned identifier for the event.
- `time` (timestamp): The event's time. (When it happend or started)
- `clientId` (string): A client-assigned identifier for the event when created offline, for temporary reference. Only used in batch event creation requests (TODO: link).
- `contextId`(identity, TODO: link):
	* For period events: The value must be a valid context's id. TODO: really???
	* For mark events: Optional. Indicates the particular context the event is associated with, if any.
- `duration`: Optional. If present, indicates that the event is a period event. Running period events have a duration set to `undefined`.
- `value`: (json structure) Optional - A processable and recognizable typed value. This may be a mathematical value (mass, duration, money, length, position, .. ) ex: [www.qudt.org](http://www.qudt.org/), but also a picture or or file. There is a special document about the kind of value: project/value-type.md 
- `comment` (string): Optional. User comment or note for the event.
- `attachments`: Optional. An object describing the files attached to the event. Each of its properties corresponds to one file and has the following structure:
	- `fileName` (string): The file's name. The attached file's URL is obtained by appending this file name to the event's resource URL.
	- `type` (string): The MIME type of the file.
	- `size` (number): The size of the file, in bytes.
- `clientData` (a complex data structure, that will be processed by the client software., TODO: link):  Optional. Additional client data for the event.

*Technical note:* Why the _duration_ is not set in the _value_ part of the event?  
Because activties events needs a fast processing of durations and intervals, duration is a field that can be trusted (ie with no customisation possible). La logique métier a besoin de la duréé.

### exemples
TODO: this set of data is absolutly NOT inline with the def: review an complete the 

#### A set of events for the -Activities- channel**
 		- 12.06.2012 17:12:30 - context:Pryv'it
 							  - tag: setup
 							  - duration: 17:00:00
 							  - value:
 							  - comment: phonecall Frederic
 							  - data: 

		- 13.06.2012 09:00:00 - context: FirstList
							  - tag: prospection
					          - duration: 4:00:00
					          - value:
					          - comment: went to Lyon for a meeting
			                  - data: 
			                  
 		- 13.06.2012 09:32:00 - context: FirstList
 							  - tag: prospection, expense report
 							  - duration: 0
 							  - value: money:CHF:68.90
 							  - comment: fuel on the way to Lyon
 							  - data: picture:ABDGVHGSH126.jpg
 							  		type: receipt

#### A set of events for the -Notes- channel**

		- 12.06.2012 17:12:30 - context:Thought 
							  - tag: 
							  - duration: 0
							  - value:
							  - comment: To be, or not to be; that is the question; 
							  - data: 
							  
		- 13.06.2012 09:00:00 - context: Facebook 
							  - tag: important
							  - duration: 0
							  - value: 0
							  - comment: went to the pool with friend
							  - data: <DATA EXTRACTED FROM FB TIMELINE>
							  
		- 13.06.2012 09:32:00 - context: Twitter
						      - tag:
						      - duration: 0
						      - value:
						      - comment: @recla how are you doing guys?
						      - data: author:johndoe

### Item additional data

A JSON object offering free storage for clients to support extra functionality. TODO: details (no media files, limited size...) and example

TODO: "commonly used data directory" to help data reuse:

- `color`
- `url`
- `imageIcon` (! file size)
- ...


### Error

Fields:

- `id` (string): Identifier for the error; complements the response's HTTP error code.
- `message` (string): A human-readable description of the error.
- `subErrors` (array of errors): Optional. Lists the detailed causes of the main error, if any.


### Item identity

TODO: decide depending on the choosen database. The best would be to keep human readable identifier (see slugify). Validation rule in that case: `/^[a-zA-Z0-9._-]{1,100}$/` (alphanum between 3 and 100 chars).

- The identity of every activity channel must be unique within its owning user's data
- The identity of every activity context or event must be unique within its containing channel


### Timestamp

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.

Examples:

- PHP -> microtime()
- ...


### Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).
