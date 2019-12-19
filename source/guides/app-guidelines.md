---
id: app-guidelines
title: 'App guidelines'
template: default.jade
customer: true
withTOC: true
---

General guidelines for writing applications and libraries for Pryv.io platforms.

# Cross-Platform URL parameters

Applications should retrieve configuration parameters from the [service information](/reference/#service-info).

Web applications should be implemented to be platform agnostic, for example an app should be easily run for the [Pryv Lab platform](https://pryv.com/pryvlab/) as well as your own.
For this we suggest to implement the following ways to load its configuration:

1. **pryvApiEndpoint** query param

  Example:`https://cdtasdjhashdsa@testuser.pryv.me` as API endpoint

  ```
  https://sample.domain/app/index.html?pryvApiEndpoint=https://cdtasdjhashdsa@testuser.pryv.me
  ```

  Note: service information should be retrieved by appending the path `/service/info` to the value given by `pryvApiEndpoint`.

2. **pryvServiceInfoUrl** query param

  Example: `https://reg.pryv.me/service/info` as service information URL

  ```
  https://sample.domain/app/index.html?pryvServiceInfo=https://reg.pryv.me/service/info
  ```

**Prevalence** 

If multiple parameters are provided, the following order of priority should be used:  

1. `pryvApiEndpoint` as query parameter
2. `pryvServiceInfoUrl` as query parameter
3. `pryvServiceInfoUrl` as default value
