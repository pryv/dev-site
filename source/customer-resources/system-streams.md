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

System streams are a predefined set of streams. They are loaded in memory by Pryv.io and not stored in the database. The base system streams contain the structure to store user account data, which can be extended in the platform configuration to include additional unique or indexed fields (more on that later in this document).

System streams can be recognized by their id prefixed by a **dot**.

The base system streams are the following:

```
|_.account
  |_.username
  |_.language
  |_.storageUsed
    |_.dbDocuments
    |_.attachedFiles
|_.helpers
  |_.active
```

Please note that we have removed email from the default account, as some Pryv.io platforms don't include email for account anonymity. It can be added through custom streams in the platform configuration and is present in the template configuration we provide.

There are a few settings that you can configure for these system streams outside of their structure:

## Unicity

You can define fields additional to `username` whose unicity constraint will be ensured platform-wide. These are often used for properties such as email or insurance number.

## Indexed

Some account properties can be marked as indexed, meaning they will be available through the system API to fetch accross all accounts: [GET /users](/reference-system/#get-users).

## Editability

Values of the system streams are stored in the [Events data structure](/reference/#event), you can define whether this event is editable or read-only after account registration.

## Mandatory or optional

Some values can be optional during the registration process.

## Format

You can an enforce a property format for these values using a regular expression.

## Event type

you can define the `type` of the events that will be used to store the values.

# Configuration

By default, you platform configuration will contain the single email account stream which will appear as following:

```json
{
  "account": [
    {
      "id": "email",
      "name": "Email",
      "type": "email/string",
      "isUnique": true,
      "isIndexed": true,
      "isEditable": true,
      "isRequiredInValidation": true,
      "isShown": true
    }
  ]
}
```

Unicity and index properties won't work properly if added after the launch of the platform. As the values recorded previously will not be synchronized in the register database.

Here is the detailed list of parameters:

- **id**: the `id` of the stream
    * string
    * required
- **name**: the `name` of the stream
    * string
    * required
- **type**: the `type` of the events that will be stored in the stream
    * string
    * required
- **isUnique**: Wether the field must be unique platform-wide
    * boolean
    * optional, default false
- **isIndexed**: Whether the field is accessible through the [system administration GET users call](/reference-system/#get-users)
    * boolean
    * optional, default false
- **isEditable**: Whether you can modify the events
    * boolean
    * optional, default false
- **isRequiredInValidation**: Whether the field must exist in the [user registration call](/reference/#create-user)
    * boolean
    * optional, default false
- **regexValidation**: The `regex string` that would be used for the field validation in the [user registration](/reference/#create-user)
    * string
    * optional, default null
- **isShown**: Whether the stream and its events will be returned by [streams](/reference/#streams), [events](/reference/#events) or [account](/reference/#account-management) methods
    * boolean
    * optional, default false
