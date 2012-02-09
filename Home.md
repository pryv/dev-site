# wActiv API documentation

The wActiv service is exposed as a HTTP REST API for web or native clients to access. The API is structured into three modules:

1. The [[Register]] module allows the registration of new users ("users" refer to "registered users" in this documentation)
2. The [[Admin]] module allows each user to manage her account information and data access tokens (see below) 
3. The [[Data]] module allows each data access token owner to query or manage activity data for the user that issued the token: activity types and activity change events.

