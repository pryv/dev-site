---
id: dns-config
title: 'Pryv.io DNS zone configuration'
template: default.jade
customer: true
withTOC: true
---

## Table of contents <!-- omit in toc -->
<!-- no toc -->
1. [Usage](#usage)  
  1. [Settings location](#settings-location)  
  2. [Key format](#key-format)  
2. [A Record](#a-record)
3. [CNAME Record](#cname-record)
4. [TXT Record](#txt-record)
5. [SPF Record](#spf-record)
6. [MX Record](#mx-record)

This guide describes how to add DNS records in your Pryv.io associated domain DNS zone.  

## Usage

This document is useful for you if you wish to do one of the following with the Pryv.io associated domain:  

- Define hostnames or aliases in the domain such as my_service.${DOMAIN}, as it is done for the pryv.me Register: reg.pryv.me  
- Send emails from some-name.${DOMAIN}, such as noreply@pryv.me  
- Perform a DNS validation for a SSL certificate  

Technically, this document describes how to add DNS records of type:  

- A  
- CNAME  
- TXT  
- SPF  

### Settings location

These settings can either be changed through the admin panel or through the `config-leader/conf/platform.yml` file under `DNS_SETTINGS`:

```yaml
DNS_SETTINGS:
  name: "DNS settings"
  settings:
    ...
```

As YAML is not error-resilient, make sure that you do not leave formatting errors during editing, otherwise the configuration will not be applied.  
Using the admin panel, you will be provided with an error when applying the update. When editing the `platform.yml` file directly, you will find an error in the *config-leader* logs when followers will fetch their confiuration.

### Key format

All DNS lookups are made in **lower case**, so make sure that the keys that you define for A, CNAME and TXT records are set in lower case.  
This requires to manually lower casing keys such as the ones provided for DNS validation.  

## A Record

To associate the `123.123.123.123` IP address to the hostname `my-service.${DOMAIN}`, enter:

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_CUSTOM_ENTRIES:
      ...
      value:
        my-service:
          ip: "123.123.123.123"
```

### Root

You can also define a TYPE A record for your root domain `${DOMAIN}`, such as [pryv.me](http://pryv.me).

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_ROOT_DOMAIN_A_RECORD: 
      description: "DNS A record for ${DOMAIN} (The IP adress serving an eventual web page accessible by: http://{DOMAIN})"
      value: "123.123.123.123"
```

## CNAME Record

To associate a CNAME alias pointing to `my-site.my-domain.com` from `www.${DOMAIN}`, enter:  

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_CUSTOM_ENTRIES:
      ...
      value:
        my-service:
          alias:
            name: "my-site.my-domain.com"
```

## TXT Record

To associate the strings `"hi there"` and `"my-dns-challenge"` to the TXT records of `challenge.${DOMAIN}`, enter:

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_CUSTOM_ENTRIES:
      ...
      value:
        challenge:
          description:
            - "hi there"
            - "my-dns-challenge"
```

### Root TXT

In order to set a TXT record at the root of your domain hostname, such as `"root-dns-challenge"`, enter under `DNS_ROOT_TXT_ARRAY`:

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_ROOT_TXT_ARRAY:
      description: "DNS TXT records for @ value for ${DOMAIN}. Ex.: [\"_globalsign-domain-verification=n3PT\",\"v=spf1 include:_mailcust.gandi.net ?all\"]"
      value:
        - "hi there"
        - "my-dns-challenge"
```

## SPF Record

SPF records are simply TXT records located at the root of the domain. They are defined as following:

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_ROOT_TXT_ARRAY:
      ...
      value:
        - "${SPF_RECORD}"
```

## MX Record

You can enter an array of MX Records, providing the `name`, `priority` and `ttl` (Time To Live) values for each of these as following:

```yaml
DNS_SETTINGS:
  ...
  settings:
    DNS_MX_RECORDS:
      ...
      value:
        - name: my.mail.com
          priority: 10
          ttl: 10800
        - name: my.other.mail.org
          priority: 50
          ttl: 10800
```

## Previous version

The previous guide for DNS configuration is still available [here](/assets/docs/20190501-dns-config-v3.pdf).
