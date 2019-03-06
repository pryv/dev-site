---
id: batch-call
title: 'Call methods in a batch'
template: customer.jade
withTOC: true
---

It is possible to send multiple operations in one call to Pryv.io using the batch call mechanism.

Using the API methods' ids and parameters found documented in the [reference](http://api.pryv.com/reference/), it is possible to create a message containing all operations at once:

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '[
          {
            "method": "events.create",
            "params": {
              "time": 1385046854.282,
              "streamId": "heart",
              "type": "frequency/bpm",
              "content": 90
            }
          },
          {
            "method": "events.create",
            "params": {
              "time": 1385046854.282,
              "streamId": "systolic",
              "type": "pressure/mmhg",
              "content": 120
            }
          },
          {
            "method": "events.create",
            "params": {
              "time": 1385046854.282,
              "streamId": "diastolic",
              "type": "pressure/mmhg",
              "content": 80
            }
          }
      ]' \
     https://jsmith.pryv.domain/
```

The batch call will return the responses from the calls that succeeded only.
