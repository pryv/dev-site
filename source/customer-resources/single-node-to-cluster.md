---
id: single-node-to-cluster
title: 'Pryv.io Single-node to Cluster extension'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

*TODO*

## Summary

We migrate a single-node installation from a *source* machine to multiple *dest* machines in a cluster setup.

## *(Optional)* Create user(s) with specific data on source for post-migration verification

Generate a few events and streams by hand for a naked eye comparison for data transferred after the migration.  

## Adapt platform parameters

Fetch cluster configuration files for the same version [here](https://api.pryv.com/config-template-pryv.io/). Extract them, and edit the `config-leader/conf/template-platform.yml` (`platform.yml` for versions prior to 1.7).

The difference between a single and cluster lies in the "Machines and platform settings" section.

1. Copy the `DOMAIN`
2. Set the IP addresses for the new machines, leave unused ones as-is:
  - `STATIC_WEB_IP_ADDRESS`
  - `REG_MASTER_IP_ADDRESS`
  - `REG_MASTER_VPN_IP_ADDRESS`
  - `REG_SLAVE_IP_ADDRESS`
3. Copy the `REGISTER_ADMIN_KEY`
4. Set the IP address of the machine where core data will be migrated to `HOSTINGS_AND_CORES:value:hosting1:co1:ip`
5. Set the `HOSTINGS_PROVIDERS` data if needed

You can overwrite the other sections with the ones from your `platform.yml`

## Migrate data

1. Perform the [Core migration](/customer-resources/core-migration/)
2. Perform the [Register migration](/customer-resources/register-migration/)

## Replace config by cluster

1. On *dest* register, download and untar config files for a cluster deployment of same version
2. Replace or copy the `config-leader/conf/platform.yml` file with the one you prepared earlier
3. On all *dest* machines run: `restart-config-follower` and `restart-pryv`
