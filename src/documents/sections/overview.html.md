---
sectionId: overview
sectionOrder: 1
---

# Pryv API overview

The API is the HTTP programming interface to Pryv, which allows you to integrate Pryv activity data (and even the Pryv registration process) into your web or native app.


## Structure

The Pryv API is structured into two services, each with its own domain name:

- The [activity](#activity) service manages all the activity data for users as well as account settings. It is accessed on `https://{username}.pryv.io`; the actual server this maps to depends on each user's choice of data storage location. The recording and management of activity data (events and their organization into folders and tags) is protected by [data access tokens](#data-types-token) to allow easy sharing. On the other hand, the administration of a user's settings, including sharing permissions (via data access tokens) and management of activity channels is protected by personal authentication and expiring sessions.
- The [registration](#registration) service manages the registration of new users (registered users are referred to as just "users" in this documentation). It runs on `https://pryv.io`. Access is anonymous, with a captcha protecting the user registration process. [TODO: review]


## Calling API methods

Most of the API follows REST principles, meaning each item has its own unique resource URL and can be read or modified via HTTP verbs:

- GET to read the item(s)
- POST to create a new item
- PUT to modify the item
- DELETE to delete the item (note that logical deletion, or trashing, is supported for items like events, folders and channels)


## Data format

The API uses JSON for serializing data. For example, an event can look like:

```json
{
  "id": "5051941d04b8ffd00500000d",
  "time": 1347864935.964,
  "folderId": "5058370ade44feaa03000015",
  "value": {
    "type": "Position:WGS84",
    "value" : "40.714728, -73.998672, 12"
  }
}
```


## Errors

When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an [error](#data-types-error) object detailing the cause.