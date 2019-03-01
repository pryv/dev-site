---
id: manage-streams
title: 'Manage streams'
template: default.jade
withTOC: true
---

Data will be contextualized partly using streams.

You can find all available REST actions on streams in the [API reference](http://pryv.github.io/reference/#streams).

We will now create a new stream in which to place our data using the [creation stream action](http://pryv.github.io/reference/#create-stream).

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -H 'Authorization: cjsfxo173000111taf99gp3dv' \
     -d '{
         "name": "My Stream"
     }' \
     https://jsmith.pryv.domain/streams
```

The most basic use of this action is to provide a human-readable name for the new stream. A unique and random id will be created upon creation if not provided.

The `Stream` object manipulated by Pryv.io is detailed in the [data structure reference](http://pryv.github.io/reference/#data-structure-stream).

The answer returned by the server will contain the newly created stream object.

```json
{
  "meta": {
    "apiVersion": "1.3.38",
    "serverTime": 1550833364.627
  },
  "stream": {
    "name": "My Stream",
    "parentId": null,
    "created": 1550833364.622,
    "createdBy": "cjsfxo17f000211tair7v6atb",
    "modified": 1550833364.622,
    "modifiedBy": "cjsfxo17f000211tair7v6atb",
    "id": "cjsfy56kv000311ta9dy121ni"
  }
}
```
