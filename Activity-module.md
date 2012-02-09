# Activity module

TODO: introductory text

## Authentication

All requests to the activity module must carry a valid [[data access token|Data access tokens]] in the HTTP `Authorization` header. For example:

    GET /types/12345 HTTP/1.1
    Host: johndoe.wactiv.com:1234
    Date: Thu, 09 Feb 2012 17:53:58 +0000
    
    Authorization: <data access token>

TODO: I (SG) think the token should actually be passed in the URL (e.g. `/<token>/types/12345`), as it's really part of the resource state (the token identifies the user who owns the data we're accessing)...

## Common error codes

TODO: review and complete

* 401 (authentication) = invalid data access token

## Requests for activity types

### GET `/types`

Gets the activity types accessible with the given token.

#### Query string parameters

* `include_inactive` ([[boolean|Boolean data type]]): Optional. When `true`, inactive activity types will be included in the result. Default: `false`.
* `time_count_base` ([[timestamp|Timestamp data type]]): Optional. TODO: I forgot what this is supposed to do? Default: now.

#### Response (OK)

* `types` (tree of [[activity types|Activity type data type]]): The tree of the activity types accessible with the given token. TODO: example
* `time_count_base` ([[timestamp|Timestamp data type]]): TODO: I forgot what this is supposed to do?
* `server_now`([[timestamp|Timestamp data type]]): The current server time

### POST `/types`

TODO: add

### POST `/types/<type id>/set-info`

TODO: set info

### POST `/types/<type id>/move`

TODO: move

### DELETE `types/<type id>`

TODO: delete

## Requests for activity events

TODO