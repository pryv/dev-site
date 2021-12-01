---
id: audit-setup
title: 'Pryv.io audit configuration'
layout: default.pug
customer: true
withTOC: true
---

This document describes how to configure the Audit feature for your Pryv.io platform.

Audit is only available in the [entreprise version](/concepts/#entreprise-license-open-source-license) of Pryv.io.


## Table of contents <!-- omit in toc -->

1. [Outputs](#outputs)
2. [Filtering](#filtering)
3. [Rules](#rules)
   1. [1. You must specify at least one of them](#1-you-must-specify-at-least-one-of-them)
   2. [2. You can aggregate per resource](#2-you-can-aggregate-per-resource)
4. [Examples](#examples)
   1. [log everything](#log-everything)
   2. [log nothing](#log-nothing)
   3. [log a few API methods](#log-a-few-api-methods)
   4. [log everything, but a few](#log-everything-but-a-few)
   5. [log all events methods, but get](#log-all-events-methods-but-get)
5. [Syslog](#syslog)
   1. [Templating](#templating)
6. [Support](#support)
7. [Performance](#performance)
8. [Previous version](#previous-version)


## Outputs

Audit data can be written to any or both of the following:

- in a dedicated **storage** where it will be indexed for [querying through the Events API](/guides/audit-logs/)
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

### 1. You must specify at least one of them

At least one of the arrays must contain a valid value.

### 2. You can aggregate per resource

The Pryv.io [API method ids](/reference/#method-ids) are built in the format `{resource}.{verb}`, for example: `events.get`.  
Audit filters accept aggregation of all methods for a particular resource using `all` for the verb, for example: `events.all`


## Examples

### log everything

```json
{
  "methods": {
    "include": ["all"],
    "exclude": []
  }
}
```

### log nothing

```json
{
  "methods": {
    "include": [],
    "exclude": ["all"]
  }
}
```

### log a few API methods

```json
{
  "methods": {
    "include": ["access.create", "accesses.delete"],
    "exclude": []
  }
}
```

### log everything, but a few

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


## Syslog

**Introductory notes about syslog:**  

*The syslog protocol is using a socket in order to transmit messages. For Linux, this socket is a SOCK_STREAM unix socket, which is identified by the name /dev/log. The syslog deamon for Ubuntu is rsyslogd, its configuration files are located in /etc/rsyslog.conf and /etc/rsyslog.d/*. In particular, the default logging rules can be found in /etc/rsyslog.d/50-default.conf. These rules typically tell to which actual log files the socket messages will be pipped to (e.g. /var/log/syslog), according to the message type (see the [Syslog wiki](https://en.wikipedia.org/wiki/Syslog) for more details about Facility and Security levels).*

If activated, the Pryv.io service will write to the host machines syslog. This is useful if you wish to enable security logging, for actions such as blocking an IP address after it has performed too many forbidden requests using tools such as [fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page).

A Pryv.io audit log will look like this in the syslog:

```json
Oct 26 14:58:46 co1-pryv-li pryv-audit[57]: ck6j759f000011ps2octzo1ds audit-log/pryv-api createdBy:system ["access-ck6j78uj600011ss2neygkpub","action-events.get"] {"source":{"name":"http","ip":"85.5.192.175"},"action":"events.get","query":{"toTime":"9900000000","fromTime":"-9900000000","limit":"1","sortAscending":"true","state":"all"}}
```

### Templating

You can edit its template using the `AUDIT_SYSLOG_FORMAT` platform parameter:

```json
{
  "template": "{userid} {type} createdBy:{createdBy} {streamIds} {content}",
  "level": "notice"
}
```


## Support

If you have any question regarding auditing, check out our [forum](https://support.pryv.com/hc/en-us/community/topics) or ask a question at [support@pryv.com](mailto:support@pryv.com).


## Performance

As both syslog and storage logging require additionnal processing, we recommend to activate logging only for the methods that require it.


## Previous version

For audit configuration previous to Pryv.io 1.7, please see the [PDF](/assets/docs/20190718-pryv.io-audit-v5.pdf).
