---
id: audit-setup
title: 'Pryv.io audit configuration'
template: default.jade
customer: true
withTOC: true
---

This document describes how to configure the Audit feature for your Pryv.io platform.

Audit is only available in the [entreprise version](/concepts/#entreprise-license-open-source-license) of Pryv.io.

## Outputs

Audit data can be written to any or both of the following:

- in a dedicated **storage** where it will be indexed for [querying through the Events API](/reference/#get-events)
- in the host machine's **syslog** to which you can setup your own listeners

## Filtering

for both of these outputs, you can define which API method you log by filtering per [method-id](/reference/#method-ids).

You can find these settings in the platform configuration under the **Audit settings** tab, in the `AUDIT_STORAGE_FILTER` and `AUDIT_SYSLOG_FILTER` variables:

In the Admin panel:

```json
{
  "methods": {
    "include": ["access.create", "events.all"],
    "exclude": ["events.get"]
  }
}
```

In the `platform.yml` file:

```yaml
methods:
  include: ["accesses.create", "events.all"]
  exclude: ["events.get"]
```

## Rules

#### 1. You must specify at least one of them

At least one of the arrays must contain a valid value.

#### 2. You can aggregate per resource

The Pryv.io [API method ids](/reference/#method-ids) are built in the format `{resource}.{verb}`, for example: `events.get`.  
Audit filters accept aggregation of all methods for a particular resource using `all` for the verb, for example: `events.all`

## Examples

### log all

```json
{
  "methods": {
    "include": ["all"],
    "exclude": []
  }
}
```

### log none

```json
{
  "methods": {
    "include": [],
    "exclude": ["all"]
  }
}
```

### log only a few

```json
{
  "methods": {
    "include": ["access.create", "accesses.delete"],
    "exclude": []
  }
}
```

### log all, but a few

```json
{
  "methods": {
    "include": [],
    "exclude": ["events.get"]
  }
}
```

### log all events methods, but get

```json
{
  "methods": {
    "include": ["events.all"],
    "exclude": ["events.get"]
  }
}
```

## Support

If you have any question regarding auditing, check out our [forum](https://support.pryv.com/hc/en-us/community/topics) or ask a question at [support@pryv.com](mailto:support@pryv.com).

## Performance

As both syslog and storage logging require additionnal processing, we recommend to activate logging only for the methods that require it.

## Previous version

For audit configuration previous to Pryv.io 1.7, please see the [PDF](/assets/docs/20190718-pryv.io-audit-v5.pdf).
