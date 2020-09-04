---
id: system-streams
title: 'Pryv.io system streams'
template: default.jade
customer: true
withTOC: true
---

# Summary

This document explains how to setup system streams.

# System streams

Explain here how they work

# Format

```json
"account": [
    {
        "id": "email",
        "name": "Email",
        "type": "email/string",
        "isUnique": true,
        "isIndexed": true,
        "isEditable": true,
        "isShown": true,
        "isRequiredInValidation": true
    }
],
```

Currently, we only support system streams part of the account. Do not add any streams outside of it for possibly unhandled effects.

- id: the `id` of the stream
- name: the `name` of the stream
- type: the `type` of the events that will be stored in the stream
- isUnique: Wether the field must be unique accross the platform users
- isIndexed: Whether the field is accessible through the [system administration GET users call](/reference-system/#get-users)
- isEditable: Whether you can modify the events
- isShown: Whether the stream and its events will be returned by [streams](/reference/#streams), [events](/reference/#events) or [account](/reference/#account-management) methods
- isRequiredInValidation:
