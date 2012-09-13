---
sectionId: overview
sectionOrder: 1
---

# API overview

The Pryv HTTP API is structured into two services, each with its own URL:

- The [activity](#activity) service manages all the activity data for users as well as account settings. It is accessed on `https://<username>.pryv.io`; the actual server this maps to depends on each user's choice of data storage location. The recording and management of activity data (events and their organization into folders and tags) is protected by [data access tokens](#data-access-tokens) to allow easy sharing. On the other hand, the administration of a user's settings, including sharing permissions (via data access tokens) and management of activity channels is protected by personal authentication and expiring sessions.
- The [registration](#registration) service manages the registration of new users (registered users are referred to as just "users" in this documentation). It runs on `https://pryv.io`. Access is anonymous, with a captcha protecting the user registration process. [TODO: review]
