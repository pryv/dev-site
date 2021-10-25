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

System streams are a predefined set of streams. They are loaded in memory by Pryv.io and not stored in the database.  
The base system streams contain the structure to store user account data, which can be extended in the platform configuration with custom streams to include additional unique or indexed fields (more on that later in this document).

System streams can be recognized by their id prefixed by `:_system:` or `:system:`. In versions prior to 1.7 it was `.` (dot), See [backward compatiblity](#backward-compatibility) if you need to migrate your platform.

The base system streams are the following:

```
|_account
  |_username
  |_language
  |_storageUsed
    |_dbDocuments
    |_attachedFiles
|_helpers
  |_active
  |_unique
```

They are prefixed with `:_system:`. Custom system streams that you define for your platform are prefixed with `:system:`.

Please note that we have removed email from the default account, as some Pryv.io platforms don't include email for account anonymity. It can be added through custom streams in the platform configuration and is present by default in the template configuration we provide.

There are 2 sets of custom streams that you may define: "account" and "other" ones. *Account* custom streams are children of the **account** stream and may have additionnal properties such as **unicity**, **indexation** and **requiredness at registration**. *Other* streams are located at the root of the streams and cannot benefit from constraints as account ones do.

Here are the settings that you can configure for these system streams outside of their structure:

## Unicity

You can define fields additional to `username` whose unicity constraint will be ensured platform-wide. These are often used for properties such as email or insurance number. Only available for account.

## Indexed

Some account properties can be marked as indexed, meaning they will be available through the system API to fetch accross all accounts: [GET /users](/reference-system/#get-users). Only available for account.

## Editability

Values of the system streams are stored in the [Events data structure](/reference/#event), you can define whether this event is editable or read-only after account registration. Only available for account.

## Requiredness at registration

Some values can be required during the registration process. Only available for account.

## Format

You can an enforce a property format for these values using a regular expression. Only available for account.

## Event type

You can define the `type` of the events that will be used to store the values. Only available for account.

## Visibility

You can make some values stored at registration and indexed, but not to appear Pryv.io API outside of the administration API. Only available for account.

# Configuration

By default, your platform configuration will contain the single email account system stream which will appear as following:

```json
[
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
```

Regarding *other* streams, it will be empty by default:

```json
[]
```

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
    * optional, default true
- **isRequiredInValidation**: Whether the field must exist in the [user registration call](/reference-system/#create-user)
    * boolean
    * optional, default false
- **regexValidation**: The `regex string` that would be used for the field validation in the [user registration](/reference-system/#create-user)
    * string
    * optional, default null
- **isShown**: Whether the stream and its events will be returned by [streams](/reference/#streams), [events](/reference/#events) or [account](/reference/#account-management) methods
    * boolean
    * optional, default true

## Modification

Unicity and index properties won't affect existing data if added after the launch of the platform. As the values recorded previously will not be synchronized in the register database.

Preferably these values should be modified with care, because fields like isUnique or isIndexed are not be updated accross the platform following a configuration change. They will be set for new user accounts, or through [event updates](/reference/#update-events) for existing ones.  
If you remove system streams that have events, these events will become unreachable.

## Platform settings

You can find these settings in the platform configuration under the **Advanced API settings** tab, in the `ACCOUNT_SYSTEM_STREAMS` and `OTHER_SYSTEM_STREAMS` variables:

```json
"[{\"isIndexed\": true,\"isUnique\": true,\"isShown\": true,\"isEditable\": true,\"type\": \"email/string\",\"name\": \"Email\",\"id\": \"email\",\"isRequiredInValidation\": true}]"
```

# Backward compatibility

Pryv.io 1.7 changes the system streams ids from `.` (dot) to `:_system:` and `:system:`. However, this change might break some customer applications that depended on the old syntax.  

To prevent this, we have introduced a platform setting so your Pryv.io platform accepts and returns system stream ids with the old `.` (dot) prefix.  
You can find the backward compatibility setting in the platform configuration under the **Advanced API settings** tab, in the `BACKWARD_COMPATIBILITY_SYSTEM_STREAMS_PREFIX` variable.

In order to migrate your front-end applications at your pace, you can make API calls with the `disable-backward-compatibility-prefix: true` header to use the new prefix format.
