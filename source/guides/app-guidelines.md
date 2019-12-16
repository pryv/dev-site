
General guidlines for Applications and Libraries.

# Cross-Platform URL parameters

Web application should retreive initial configuration parameters

1. **pryvApiEndpoint** query param

  Example:`https://cdtasdjhashdsa@testuser.pryv.me` as API endpoint

  ```
  https://sample.domain/app/index.html?pryvApiEndpoint=https%3A%2F%2Fcdtasdjhashdsa%40testuser.pryv.me
  ```

  Note: service infos should be retrieved by appending '/service/info' to the value given by `pryvApiEndpoint`.

1. **pryvServiceInfo** query param

  Example: to pass `https://reg.pryv.me/service/info` as Service Infos

  ```
  https://sample.domain/app/index.html?pryvServiceInfo=https%3A%2F%2Freg.pryv.me%2Fservice%2Finfo
  ```

**Prevalence** 

If `pryvServiceInfo`and `pryvApiEndpoint`are passed as query parameters, `pryvServiceInfo` should be discarded.


