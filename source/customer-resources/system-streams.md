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

System streams are predefined structure of streams. It is loaded from the config and is not
saved in the database. 

Each account stream id has a **dot** added to it dynamically, so it could not be modified with the streams API.
Current default streams includes `.account` and `.helpers` streams. There are features in the roadmap that will append
system-streams list with the new ones. 

To filter all events that belongs to the system-streams, you can filter the  events streamIds and
search for the dot before each streamId.

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
    *  string
    *  required
- name: the `name` of the stream
    *  string
    *  required
- type: the `type` of the events that will be stored in the stream
    *  string
    *  required
- isUnique: Wether the field must be unique accross the platform users
    *  boolean
    *  optional, default false
- isIndexed: Whether the field is accessible through the [system administration GET users call](/reference-system/#get-users)
    *  boolean
    *  optional, default false
- isEditable: Whether you can modify the events
    *  boolean
    *  optional, default false
- isShown: Whether the stream and its events will be returned by [streams](/reference/#streams), [events](/reference/#events) or [account](/reference/#account-management) methods
    *  boolean
    *  optional, default false
- isRequiredInValidation: Whether the field must exist in the [user registration call](/reference/#create-user)
    *  boolean
    *  optional, default false
- regexValidation: The `regex string` that would be used for the field validation in the [user registration](/reference/#create-user)
    *  string
    *  optional, default null
    
## Important

Configuration for the field **must not be changed**. The difference between different configs is not saved and will
not be handled by the system.
