---
id: dns-config
title: 'Pryv.io DNS Configuration'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Usage](#usage)
  1. [File location](#file-location)
  2. [File organization](#file-organization)
  3. [Key format](#key-format)
2. [A Record](#a-record)
3. [CNAME Record](#cname-record)
4. [TXT Record](#txt-record)
5. [SPF Record](#spf-record)
6. [MX Record](#mx-record)


This guide describes how to add entries in your Pryv.io associated domain DNS zone.  

## Usage

This document is useful for you if you wish to do one of the following with the Pryv.io associated domain:  
- Define hostnames or aliases in the domain such as my_service.${DOMAIN}, as it is done for the pryv.me Register: reg.pryv.me  
- Send emails from some-name.${DOMAIN}, such as noreply@pryv.me  
- Perform a DNS validation for a SSL certificate  

Technically, this document describes how to set DNS records of type:  
- A  
- CNAME  
- TXT  
    - SPF  
- MX  


### File location

The configuration file can be found in the provided templates in the DNS directory.  

For cluster configurations, it is:  
- `reg-master/dns/conf/dns.json`  
- `reg-slave/dns/conf/dns.json`  

For single-node configuration, it is:  
- `pryv/dns/conf/dns.json`  


### File organization

The DNS configuration uses the JSON format with all customizable properties located under the `dns` property such as:  

```json
{
  "dns": {
    ...
    "staticDataInDomain": {
      "sw": {
        "ip": "123.123.123.123"
      },
      ...
    }
  }
}
```

As JSON is not error-resilient, make sure that you do not leave formatting errors during editing, otherwise the DNS server will not boot. In this case, you will see the error in its logs.  


### Key format

All DNS lookups are made in **lower case**, so make sure that the keys that you define for A, CNAME and TXT records are set in lower case.  
This requires to manually lower casing keys such as the ones provided for DNS validation.  


## A Record

```json
{
  "dns": {
    ...
    "staticDataInDomain": {
      ...
      "sw": {
       "ip": "123.123.123.123"
      }    
    }
}
```

### Root 

You can also define TYPE A record for your root domain ${DOMAIN}, such as [pryv.me](http://pryv.me). This entry is defined at the root of the `dns` property.  

```json
{
  "dns": {
    ...
    "domain_A": "123.123.123.123"
  }
}
```

## CNAME Record

```json
{
  "dns": {
    ...
    "staticDataInDomain": {
      ...
      "www": {
        "alias": {
          "name":"my-site.my-domain.com"
        }
      }
    }    
  }
}
```

## TXT Record

```json
{
  "dns": {
    ...
    "staticDataInDomain": {
      ...
      "${TXT_RECORD_SUBDOMAIN}": {
        "description": [
          "${TXT_RECORD_VALUE_1}",
          "${TXT_RECORD_VALUE_2}",
      ]
    }    
  }
}
```

*old format:*

```json
{
  "dns": {
    ...
    "staticDataInDomain": {
      ...
      "${TXT_RECORD_SUBDOMAIN}": {
        "description": "${TXT_RECORD_VALUE}"
      }
    }    
  }
}
```

### Root

In order to set a TXT record at the root of the domain, define a `rootTXT` field under `dns` as following:

```json
{
  "dns": {
    ...
    "rootTXT": {
      "description: [
        "${TXT_RECORD_VALUE_1}",
        "${TXT_RECORD_VALUE_2}",
      ]
    }    
  }
}
```

## SPF Record

SPF records are simply TXT records located at the root of the domain. They are defined as following:

```json
{
  "dns": {
    ...
    "rootTXT": {
      "description: [
        "${SPF_RECORD}"
      ]
    }    
  }
}
```

## MX Record

MX records are located directly under the `dns` property. They use the following strucutre:  

```json
{
  "dns": {
    ...
    "mail": [
      "name": "${SMTP_SERVER_HOSTNAME}",
      "ip": "${OPTIONAL_IP_ADDRESS}",
      "ttl": ${TTL_NUMBER},
      "priority": ${PRIORITY_NUMBER}
    ]
  }
}
```

This will create a MX entry as:  

`${DOMAIN}.  ${TTL_NUMBER} IN MX ${PRIORITY_NUMBER} ${SMTP_SERVER_HOSTNAME}.`
