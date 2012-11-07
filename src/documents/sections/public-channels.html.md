---
sectionId: public-channels
sectionOrder: 99
---

# Public channels

*TODO: this should be a separate page. Wait till the final dev site structure is defined.*

Public channels are channels of general interest (like news or weather) that can be integrated into users' Pryv view to add context to their own events (or just browsed independantly as-is). Unlike Pryv users' data and because they are public and read-only, public channels can be hosted anywhere – that means you can create your own public channel for users to enrich their Pryv experience. The public channels directory within Pryv lists all the channels that were registered to us and validated, but users are free to add channels from any URL.

This section describes the public channel API, both for those of you who want to implement it for publishing their own channels and for those who want to integrate public channels into their app. The public channel API itself is a small subset of the Pryv API.

TODO: add link(s) to example public channel implementation(s), and possibly a simple tutorial.


## General stuff

### ***.pryv.io** URLs

Public channels are not limited to ***.pryv.io** URLs; they can be published anywhere. When publishing your own channel, you are free to use any hostname and path you like. If however you'd like to use a ***.pryv.io** URL, just get in touch with us (TODO: add info about how to register for a *.pryv.io name + how to check if a name is available).


### Authorization and encryption

As you can expect, there is no authorization mechanism for accessing public channels. There's no need either to encrypt public channels with TLS (HTTPS), but we don't enforce any restriction there.


## HTTP headers

The following headers must be included in every response:

- `API-Version`: The version of the public channel API in the form `{major}.{minor}.{revision}`. (TODO: indicate documented version somewhere.)
- `Server-Time`: The current server time as a [timestamp](#data-types-timestamp), which must of course be consistent with the times of events in the channel.


## Common errors

Here are errors commonly returned for requests:

- `400 Bad Request`, id `INVALID_PARAMETERS_FORMAT`: The request's parameters do not follow the expected format.
- `404 Not Found`, possible cases:
	- Id `UNKNOWN_FOLDER`: The activity folder can't be found in the specified channel.
	- Id `UNKNOWN_ATTACHMENT`: The attached file can't be found for the specified event.


## Events

Methods to retrieve [events](#data-types-event). The events on public channels are the same as those in the Pryv API.


### GET `{channel base path}/events`

Queries the channel's events. This is the only method that must be implemented for every public channel.

#### Query string parameters

- `fromTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is 24 hours before `toTime`, if set.
- `toTime` ([timestamp](#data-types-timestamp)): Optional. TODO. Default is the current time.
- `onlyFolders` (array of [identity](#data-types-identity)): Optional. If set, only events assigned to the specified folders and their sub-folders will be returned. To retrieve events that are not assigned to any folder, just include a `null` value in the array. By default, all accessible events are returned (regardless of their folder assignment).
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `modifiedSince` ([timestamp](#data-types-timestamp)): Optional. If specified, only events modified since that time will be returned.

#### Successful response: `200 OK`

An array of [activity events](#data-types-event) containing the accessible events ordered by time (see `sortAscending` above).

#### Specific errors

- `400 Bad Request`, id `UNKNOWN_FOLDER`: TODO may happen if one of the specified folders doesn't exist


### GET `{channel base path}/events/{event-id}/{file-name}`

Gets the attached file. This method must be implemented if some of your public channel's events contain attachments.

#### Successful response: `200 OK`


## Folders

[Folders](#data-types-folder) provide an organization structure for channels that need it; implementing folders in public channels is by no means mandatory. The folders on public channels are the same as those in the Pryv API.


### GET `{channel base path}/folders`

Gets the channel's folders, either from the root level or only descending from a specified parent folder.

#### Query string parameters

- `parentId` ([identity](#data-types-identity)): Optional. The id of the parent folder to use as root for the request. Default: `null` (returns all folders from the root level).

#### Successful response: `200 OK`

An array of [activity folders](#data-types-folder) containing the tree of the folders, sorted by name.

TODO: example