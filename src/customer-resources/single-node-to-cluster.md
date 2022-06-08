---
id: single-node-to-cluster
title: 'Pryv.io Single-node to Cluster extension'
layout: default.pug
customer: true
withTOC: true
---

This guide describes how to migrate a single-node installation from a *source* machine to multiple *dest* machines in a cluster setup.


## Table of contents <!-- omit in toc -->

1. [*(Optional)* Create user(s) with specific data on source for post-migration verification](#optional-create-users-with-specific-data-on-source-for-post-migration-verification)
2. [Adapt platform parameters](#adapt-platform-parameters)
3. [Migrate register master](#migrate-register-master)
4. [Replace config by cluster](#replace-config-by-cluster)
5. [Migrate user data to core machine](#migrate-user-data-to-core-machine)


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


## Migrate register master

1. Perform the [register migration](/customer-resources/register-migration/) for the reg-master machine


## Replace config by cluster

2. On *dest* reg-master, download and untar config files for a cluster deployment of same version  
3. Replace or copy the `config-leader/conf/platform.yml` file with the one you prepared earlier  
4. Copy the SSL certificates from `config-leader/data/singlenode/nginx/conf/secret/` to each new `$ROLE` in `config-leader/data/${ROLE}/nginx/conf/secret/`
5. On *dest* reg-master run: `restart-config-follower` and `restart-pryv`  


## Migrate user data to core machine

6. Perform the [core migration](/customer-resources/core-migration/)
