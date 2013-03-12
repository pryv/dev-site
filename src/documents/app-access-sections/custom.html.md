---
doc: app-access
sectionId: custom
sectionOrder: 10
---

# Custom

Implementing the authorization process and obtaining an access token all by yourself.

**For testing: **
Use our staging servers: https://access.rec.la/access 


**Steps: **

1. start an access request by calling **POST https://access.pryv.io/access**
2. open **response.url**  in a webview
3. poll **response.pollurl** ﻿until you get the an ACCEPTED / REFUSED or ERROR status

## Sequence diagram

![Sequence Diagram](app-access-files/custom-sequence.png)

