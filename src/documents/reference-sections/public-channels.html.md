---
doc: reference
sectionId: public-channels
sectionOrder: 99
---

# Public channels

*TODO: contents here are probably obsolete but kept for reference until we do implement public channels. This should also be a separate page.*

This section describes the public channel API, both for those of you who want to implement it for publishing their own channels and for those who want to integrate public channels into their app. The public channel API itself is a small subset of the Pryv API.


## Overview

### Definition

Public channels are channels of general interest (like news or weather) that can be integrated into users' Pryv view to add context to their own events (or just browsed independantly as-is). Unlike Pryv users' data and because they are public and read-only, public channels don't have to run on Pryv servers – anyone is free to create and self-host a public channel for users to enrich their Pryv experience. The public channels directory within Pryv lists all the channels that were registered to us and validated, but users are free to add channels from any URL.

TODO: link(s) to example public channel implementation(s)
TODO: and possibly a simple tutorial.

### ***.pryv.io** URLs

Public channels are not limited to ***.pryv.io** URLs; they can be published anywhere. When publishing your own channel, you are free to use any hostname and path you like. If however you'd like to use a ***.pryv.io** URL, just get in touch with us (TODO: add info about how to register for a *.pryv.io name + how to check if a name is available).


### Authorization and encryption

As you can expect, there is no authorization mechanism for accessing public channels. There's no need either to encrypt public channels with TLS (HTTPS), but we don't enforce any restriction there.

TODO: clarify - are we talking about Pryv-served public channels here, or about the security aspects of (any) public channels? SGO: we are saying that there is no auth for public channels whatsoever. BTW there is no distinction between "Pryv-served" channels and others. Hosts of public channels can register for a *.pryv.io URL, but this doesn't mean they're hosted by us (it's just a DNS mapping). BTW about TLS I'm actually not sure we shouldn't enforce it, because we'll have an issue directly serving HTTP content from our HTTPS app. But then we can't require everyone interested to acquire a certificate, so we may have to host a proxy... but anyway this is too much thinking already. We've specified public channels as something we must support in the future, it won't be there in the very next months, so please don't spend special time on this section.

### HTTP headers

The following headers must be included in every response:

- `API-Version`: The version of the public channel API in the form `{major}.{minor}.{revision}`. (TODO: indicate documented version somewhere.)
- `Server-Time`: The current server time as a [timestamp](#data-structure-timestamp), which must of course be consistent with the times of events in the channel.


### Data

The JSON data exchanged is the same as in the Pryv API: see [events](#data-structure-event), [folders](#data-structure-folder) and [errors](#data-structure-error) there.


## Events

At a minimum, public channels publish [events](#data-structure-event).


### GET `{channel base path}/events`

Queries the channel's events. This is the only method that must be implemented in every public channel.

#### Query string parameters

- `fromTime` ([timestamp](#data-structure-timestamp)): Optional. TODO. Default is 24 hours before `toTime`, if set.
- `toTime` ([timestamp](#data-structure-timestamp)): Optional. TODO. Default is the current time.
- `onlyFolders` (array of [identity](#data-structure-identity)): Optional. If set, only events assigned to the specified folders and their sub-folders will be returned. To retrieve events that are not assigned to any folder, just include a `null` value in the array. By default, all accessible events are returned (regardless of their folder assignment).
- `sortAscending` (`true` or `false`): If `true`, events will be sorted from oldest to newest. Default: false (sort descending).
- `skip` (number): Optional. The number of items to skip in the results.
- `limit` (number): Optional. The number of items to return in the results. A default value of 20 items is used if no other range limiting parameter is specified (`fromTime`, `toTime`).
- `modifiedSince` ([timestamp](#data-structure-timestamp)): Optional. If specified, only events modified since that time will be returned.

#### Successful response: `200 OK`

An array of [events](#data-structure-event) containing the accessible events ordered by time (see `sortAscending` above).

#### Errors

- `400 Bad Request`, id `invalid-parameters-format`: The request's parameters do not follow the expected format (e.g. missing required parameter, wrong type of data, etc.)
- `400 Bad Request`, id `unknown-folder`: One (or more) of the specified folders doesn't exist.


### GET `{channel base path}/events/{event-id}/{file-name}`

Gets the attached file. This method does not have to be implemented if the public channel's events never contain attachments; in that case a `404 Not Found` response is returned.

#### Successful response: `200 OK`

#### Errors

- `404 Not Found`, id `unknown-attachment`: The attached file can't be found for the specified event.


## Folders

[Folders](#data-structure-folder) provide an organization structure for channels that need it. Implementing folders in public channels is by no means mandatory; public channels with no need for folders just return a `404 Not Found` response for the method below.


### GET `{channel base path}/folders`

Gets the channel's folders, either from the root level or only descending from a specified parent folder.

#### Query string parameters

- `parentId` ([identity](#data-structure-identity)): Optional. The id of the parent folder to use as root for the request. Default: `null` (returns all folders from the root level).

#### Successful response: `200 OK`

An array of [activity folders](#data-structure-folder) containing the tree of the folders, sorted by name.

#### Errors

- `400 Bad Request`, id `invalid-parameters-format`: The request's parameters do not follow the expected format (e.g. missing required parameter, wrong type of data, etc.)
- `400 Bad Request`, id `unknown-folder`: The specified parent folder can't be found.

TODO: example
