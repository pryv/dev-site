# wActiv API documentation

The wActiv service is exposed as a HTTP REST API for web or native clients to access. The API is structured into three modules, each one accessed through its own URL and authentication scheme: [[Register|Register module]], [[Admin|Admin module]] and [[Activity|Activity module]]. **TODO: handle data access URL dispatching via a separate "Dispatch" module??**

## Register

The [[Register module]] allows the registration of new users (registered users are referred to as just "users" in this documentation).

Located at TODO:http://register.wactiv.com. Access is anonymous, with a captcha protecting the user registration process.

## Admin

The [[Admin module]] allows each user to manage her account information and [[data access tokens|Data access tokens]].

Located at TODO:http://*username*.wactiv.com. Access is managed by regular username / password authentication and expiring sessions.

## TODO: Dispatch?

TODO: access protected by data access token?

## Activity

The [[Activity module]] allows each data access token owner to query or manage activity data for the user that issued the token: activity types and activity change events.

Location is provided by the TODO:which? module. Access is managed by [[data access tokens|Data access tokens]].