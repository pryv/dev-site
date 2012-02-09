# wActiv API documentation

The wActiv service is exposed as a HTTP REST API for web or native clients to access. The API is structured into three modules:

1. The [[Register]] module allows the registration of new users (registered users are referred to as just "users" in this documentation)
2. The [[Admin]] module allows each user to manage her account information and data access tokens (see below)
3. **TODO: handle data access URL dispatching via a separate "Dispatch" module??**
4. The [[Activity]] module allows each data access token owner to query or manage activity data for the user that issued the token: activity types and activity change events.

Each module is accessed through its own URL and authentication scheme:

1. The [[Register]] module is located at TODO:[[http://register.wactiv.com]]. Access is anonymous, with a captcha protecting the user registration process.
2. The [[Admin]] module is located at TODO:[[http://<username>.wactiv.com]]. Access is managed by regular username / password authentication and expiring sessions.
3. TODO: possible Dispatch module access (access protected by data access token)
4. The [[Activity]] module's location is provided by the TODO:[[Register]] module. Access is managed with data access tokens.