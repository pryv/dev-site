---
id: change-log
title: API change log
template: default.jade
---

## V1.4

New features:

 - Release of webhooks to notify of data changes. See Webhook [data structure](https://api.pryv.com/reference/#webhook) and [methods](https://api.pryv.com/reference/#webhooks) for more details
 - Add route /service/info that provides a unified way for third party services to access the necessary information related to a Pryv.io platform. See [description](https://api.pryv.com/reference/#service-info) for more details.
 - Most API calls now present a 'Pryv-Access-Id' response header that contains the id of the access used for the call. This is the case only when a valid authorization token has been provided during the request (even if the token is expired). See [metadata](https://api.pryv.com/reference/#in-http-headers) for more details.

Changes:

 - Improve the update account API call, in particular when it applies a change of email address. It now correctly checks if the email address is not already in use before updating the account and throws consistent errors

## V1.3

New features:

 - High Frequency events allow storing data at high frequency and high data density. Create them by using types that start with 'series:X', where X is a normal Pryv type. The API also supports inputting data into multiple series at once, this is called a 'seriesBatch' (POST /series/batch)
 - Add `clientData` field to Accesses.
 - Add `httpOnly` flag to server-side cookie sent in response to successful `/auth/login` request
 - Deleted accesses can now be retrieved. See [accesses.get method](/reference/#get-accesses) for more details
 - Accesses can now be made to expire. See the [access data structure documentation](/reference/#access) for more details

Changes:

 - Some invalid requests that used to return a HTTP status code of 401 (Unauthorized) now return a 403 (Forbidden). Only the requests that are missing some form of authentication will return a 401 code
 - `updates.ignoreProtectedFields` is now off by default. This means that updates that address protected fields will result in an error being returned

## v1.2

Changes:

 - Fix login with Firefox (and other browsers using Referer but no Origin)
 - Security fix 2018020801: 'accesses.update' was missing an authorisation check
 - Update of the API version in API responses
 - Fix events.get JSON formatting
 - Add configuration options to disable resetPassword and welcome emails
 - Add configuration option to ignore updates of read-only fields
 - Tags have a maximum length of 500 characters. An error is returned from the 
  API when this limit is exceeded.

## v1.1.8

Changes:

- Fix edge-case behaviour on very large `streams.delete` operations.
- Direct `events.get` API call now supports really large results. Changes made have improved this call's performance by around 30%. As a by-product of this change, we now do not send the 'Content-Size' HTTP header anymore.
- Allow custom cuid-like ids when creating events

## v1.1

New feature:

- Versioning:
  - a new endpoint on `/events/{id}` allows to retrieve a specific event by his `id`. Setting the 
  `includeHistory` parameter to `true`, the response will contain an array of the previous versions
   of the event in the `history` field.
   
## v1.0

Validated initial set of API features.

## v0.8

Changes:

- Deletion methods now:
    - Reply to permanent deletions with a `{item}Deletion` field confirming the deleted item's identifier
    - Always return code 200 on HTTP (that's a rollback of the v0.7.x change which was a bit too zealous to be practical)

New features:

- Event and stream deletions are now kept for sync purposes; they're accessible via parameter `includeDeletions` (`events.get`) or `includeDeletionsSince` (`streams.get`). Deletions are cleaned up after some time (currently a year).


## v0.7

Major changes here towards more standardization and flexibility:

- All JSON responses (both in HTTP and Socket.IO) are now structured as follows:
    - `{ "{resource}": {...} }` if a single resource item is expected; for example: `{ "event": {...} }`, `{ "error": {...} }`
    - `{ "{resources}": [ {...}, ... ] }` if an indeterminate number of items is expected; for example: `{ "events": [ {...}, ... ] }`
- All responses to resource creation and update calls now include the full object instead of respectively its id and nothing; for example: `{ "stream": {...} }`
- All JSON responses now include `meta.apiVersion` and `meta.serverTime` properties mirroring the original `API-Version` and `Server-Time` HTTP headers; HTTP header `API-Version` remains
- Deleting a resource now returns code 204 if the item was permanently deleted; it still returns a 200 when trashed (now including the trashed item in the response)
- Method ids for deletion/trashing are now `{resource}.delete` instead of `{resource}.del`
- The `attachments` property of events is now an array (instead of an object), with each attachment now identified by a new `id` property (instead of `fileName`)
- As a security measure, reading attached files now either requires auth via the `Authorization` HTTP header or a new `readToken` query string parameter (`auth` isn't allowed anymore in this case); the token to use is specific to each file and access, and is defined in the `readToken` property of each event attachment
- Event batch creation method has been replaced with generic batch method (`callBatch`, HTTP: `POST /`)
- Bookmarks have been renamed to "followed slices", corresponding method ids to `followedSlices.*` and HTTP routes to `/followed-slices`
- Getting events: setting the `tags` parameter now returns events with *any* of the specified tags, instead of *all* of them
- Error ids:
    - `unknown-*` errors replaced with either `unknown-resource` or `unknown-referenced-resource`
    - `item-*-already-exists` replaced with `item-already-exists`
    - `missing-parameter` replaced with `invalid-parameters-format`
- Other improvements and fixes (data validation performance, minor bugs on auth for trusted apps)

New features:

- Getting events: filter for specific event types with the `types` parameter
- Accesses can now define tag permissions in `permissions` (in addition to the existing stream permissions)
    - If only tag permissions are set, all streams are considered readable, and vice-versa
    - When stream and tag permissions conflict, the highest permission level is considered
- Full support for managing account information, including password change and reset


## v0.6

Changes to HTTP paths and auth for trusted apps:

- Get streams: removed `trashed` option for `state` as it was more trouble than anything useful
- Accesses now includes property `id` (exposed for referencing)
    - Create access response now includes both `id` and `token` properties
    - For existing accesses, `id` and `token` are equal
- Events, streams and accesses now includes change tracking properties:
    - `created` and `modified` (timestamp)
    - `createdBy` and `modifiedBy` (access id or `"system"`)
- Socket.IO method calls now directly use method ids (e.g. `events.create`  and pass method params, instead of using `command` and passing an object with method id and params
- For trusted apps only: removed the distinction between "admin" methods and others; **breaking changes**
    - `/admin/login`, `/admin/logout` and `/admin/who-am-i` moved to `/auth/login`, `/auth/logout` and `/auth/who-am-i` respectively
    - `sessionID` renamed to `token` in login response and SSO cookie data
    - *Personal* accesses are now automatically created on login; they can't be created explicitly anymore
    - `/admin/user-info` moved to `/user-info`
    - `/admin/accesses` merged into `/accesses`
    - `/admin/bookmarks` moved to `/bookmarks`
    - `/admin/profile` merged into `/profile`


## v0.5

This is a major update that will break most libs and clients, which should be updated ASAP.

- Simplified the API by removing channels and renamed folders into "streams"; adjusted the structure of accesses, streams and events accordingly; more details:
	- As a consequence, every event now belongs to a stream
	- Data migration: former channels will be converted into root-level streams, and former folders into sub-streams of those
- Events structure:
	- `event.type` is now a string of format `{class}/{format}` (e.g. `picture/attached`) instead of an object with `class` and `format` properties
	- `event.value` has been renamed to `event.content`
- Get events:
	- Renamed parameter `onlyFolders` to just `streams`
	- Added `running` boolean parameter, replacing "get running periods" method
- Removed "get running periods" (i.e. `GET /events/running`, see above)
- Removed `hidden` property of streams (ex-folders), which was mostly unused and out of place


## v0.4

- New feature: Allow HTTP method overriding by POSTing _method, _json, and _auth parameters in an URL-encoded request
- Improvement: Retrieving events for a specific timeframe now includes all events that overlap that timeframe, including period events that started earlier
- Added event type validation: the API will now check if an event being created or updated has a known type (as listed on our event types directory), and if yes perform data validation on its value (returning a 400 error if invalid)
- All error ids have been changed to use `slug-style` instead of `C_CONSTANT_STYLE` (so that e.g. `INVALID_PARAMETERS_FORMAT` is now `invalid-parameters-format`); this is consistent with the other ids we’re using in the system


## Earlier

Versions earlier than v0.4 are not covered here.
