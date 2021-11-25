---
id: core-migration
title: 'Pryv.io core migration'
layout: default.pug
customer: true
withTOC: true
---

## Table of contents <!-- omit in toc -->

1. [Summary](#summary)
2. [*(Optional)* Create user(s) with specific data on source for post-migration verification](#optional-create-users-with-specific-data-on-source-for-post-migration-verification)
3. [Setup *dest* machine](#setup-dest-machine)
4. [Transfer data](#transfer-data)
   1. [Transfer config data and fetch docker images](#transfer-config-data-and-fetch-docker-images)
   2. [Transfer user data from *source* to *dest*](#transfer-user-data-from-source-to-dest)
5. [Launch services on *dest*](#launch-services-on-dest)
6. [Set NGINX redirection for core on *source*](#set-nginx-redirection-for-core-on-source)
7. [Reload NGINX on *source*](#reload-nginx-on-source)
8. [Verify](#verify)
9. [Update core server IP address on register](#update-core-server-ip-address-on-register)


## Summary

We copy the data from the old core to the new one then set the old core to proxy to the new one so we can use it during the DNS propagation phase.


## *(Optional)* Create user(s) with specific data on source for post-migration verification

Generate a few events and streams by hand for a naked eye comparison for data transferred after the migration.  


## Setup *dest* machine

We assume that you have installed `docker` and `docker-compose` on the *dest* machine and have authenticated yourself with our private Docker repository.


## Transfer data

We will be transfering data using rsync, therefore, we setup a pair of keys for this:  

1. Create an SSH key pair using the following command:  

   ```bash
   ssh-keygen -t rsa -b 4096 -C "migration@remote"
   ```

2. Copy the private one to `${PATH_TO_PRIVATE_KEY}` in *source*  

3. Add the public one in `~/.ssh/authorized_keys` on *dest*  


### Transfer config data and fetch docker images

4. Transfer config data: on *source*, run:  

   ```bash
   time rsync --verbose --copy-links \
       --archive --compress -e \
     "ssh -i ${PATH_TO_PRIVATE_KEY}" \
       ${PRYV_CONF_ROOT}/config-follower \
       ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/config-follower/
   ```

   (You may have to go via your home user directory on *dest* first if permission issues arise.)  

5. Fetch docker images on *dest* by running:  

   ```bash
   ${PRYV_CONF_ROOT}/run-config-follower
   ${PRYV_CONF_ROOT}/run-pryv
   ```

6. Shutdown Pryv services prior to transferring user data:  

   ```bash
   ${PRYV_CONF_ROOT}/stop-pryv
   ```


### Transfer user data from *source* to *dest*

7. Shutdown NGINX on *source* to prevent new information from arriving: `docker stop pryvio_nginx`  

8. On *source*, create a dump of the MongoDB database:  

   ```bash
   docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongodump -d pryv-node -o /app/backup/
   ```
   
   The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/mongodb/backup/`  
   
9. Transfer Mongo data: on *source*, run:  

   ```bash
   time rsync --verbose --copy-links \
        --archive --compress -e \
     "ssh -i ${PATH_TO_PRIVATE_KEY}" \
        ${PRYV_CONF_ROOT}/pryv/mongodb/backup \
        ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/pryv/mongodb/backup/ 
   ```
   
   (You may have to go via your home user directory on *dest* first if permission issues arise.)  

10. On *source*, create a dump of the InfluxDB database:  

    ```bash
    docker exec -t pryvio_influxdb /usr/bin/influxd backup -portable /pryv/backup/
    ```
    
    The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/influxdb/backup/`  

11. Transfer InfluxDB data: on *source*, run:  

    ```bash
    time rsync --verbose --copy-links \
         --archive --compress -e \
      "ssh -i ${PATH_TO_PRIVATE_KEY}" \
         ${PRYV_CONF_ROOT}/pryv/influxdb/backup \
         ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/pryv/influxdb/backup/ 
    ```
    
    (Same comment as previous step about permissions.)  

12. Transfer other user data: on *source*, run:  

    ```bash
    time rsync --verbose --copy-links \
         --archive --compress -e \
      "ssh -i ${PATH_TO_PRIVATE_KEY}" \
         ${PRYV_CONF_ROOT}/pryv/core/data \
         ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/pryv/core/data/
    ```
    
    (Same comment as previous step about permissions.)  

13. On *dest*, run `./ensure-permissions-core` script to help with enforcing correct permissions on data and log folders  

If you wish to reactivate service on the *source* machine, simply reboot the stopped services: `${PRYV_CONF_ROOT}/run-pryv`  


## Launch services on *dest*

1. Launch services: run `${PRYV_CONF_ROOT}/run-pryv`  

2. Restore MongoDB files, run:  

   ```bash
   docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongorestore /app/backup/
   ```
   
3. Restore the InDuxDB files:  

   ```bash
   docker exec -t pryvio_influxdb /usr/bin/influxd restore -portable /pryv/backup/
   ```
   
4. and verify that it is running correctly as described in the [core validation guide](/customer-resources/platform-validation/#core)  


## Set NGINX redirection for core on *source*

Since the DNS changes will take some time to come into effect, the NGINX process on *source* will be set to proxy to the *dest* machine.  
The following steps describe the configuration changes to make NGINX proxy calls to the *dest* core. It is advised to comment out the old setting inline using `#` in order to rollback easily in case of need.

- In `${PRYV_CONF_ROOT}/pryv/nginx/conf/site-443.conf`, Replace the following:

  ```nginx
  upstream core_server {
    server core:3000 max_fails=3 fail_timeout=30s;
    server core:3001 max_fails=3 fail_timeout=30s;
    server core:3002 max_fails=3 fail_timeout=30s;
    server core:3003 max_fails=3 fail_timeout=30s;
    server core:3004 max_fails=3 fail_timeout=30s;
    server core:3005 max_fails=3 fail_timeout=30s;
  }

  upstream websocket_server {
    ip_hash;
    server core:3000 max_fails=3 fail_timeout=30s;
    server core:3001 max_fails=3 fail_timeout=30s;
    server core:3002 max_fails=3 fail_timeout=30s;
    server core:3003 max_fails=3 fail_timeout=30s;
    server core:3004 max_fails=3 fail_timeout=30s;
    server core:3005 max_fails=3 fail_timeout=30s;
  }

  upstream hfs_server {
    server hfs:3000 max_fails=3 fail_timeout=30s;
    server hfs:3001 max_fails=3 fail_timeout=30s;
    server hfs:3002 max_fails=3 fail_timeout=30s;
    server hfs:3003 max_fails=3 fail_timeout=30s;
    server hfs:3004 max_fails=3 fail_timeout=30s;
    server hfs:3005 max_fails=3 fail_timeout=30s;
  }

  upstream preview_server {
    server preview:9000 max_fails=3 fail_timeout=30s;
  }

  upstream mfa_server {
    server mfa:7000 max_fails=3 fail_timeout=30s;
  }
  ```

  with

  ```nginx
  upstream core_server {
    server ${DEST_CORE_IP_ADDRESS}:443;
  }

  upstream websocket_server {
    server ${DEST_CORE_IP_ADDRESS}:443;
  }

  upstream hfs_server {
    server ${DEST_CORE_IP_ADDRESS}:443;
  }

  upstream preview_server {
    server ${DEST_CORE_IP_ADDRESS}:443;
  }

  upstream mfa_server {
    server ${DEST_CORE_IP_ADDRESS}:443;
  }
  ```

- In the same file, change the proxy protocol from `http` to `https`:

  - Change: `http://core_server` to `https://core_server`
  - Change: `http://websocket_server` to `http://websocket_server`
  - Change: `http://hfs_server` to `https://hfs_server`
  - Change: `http://preview_server` to `https://preview_server`
  - Change: `http://mfa_server` to `https://mfa_server`


## Reload NGINX on *source*

Run `${PRYV_CONF_ROOT}/run-pryv`

As we are currently using docker-compose to specify the mounted volumes (containing the NGINX config), we just boot all services, even if they won't be used as NGINX is proxying to the *dest* machine.


## Verify

Log onto an account and verify that the data has been moved. You can monitor the services logs (`doker logs ${CONTAINER_NAME}`, which can be found using `docker ps`) to ensure that data is accessed on the new machine.


## Update core server IP address on register

SSH to the reg-master machine and edit **manually** (don't use the admin panel) the following parameters:

In `${PRYV_CONF_ROOT}/config-leader/conf/platform.yml`:

```yaml
vars:
  MACHINES_AND_PLATFORM_SETTINGS:
    name: "Machines and platform settings"
    settings:
      # ...
      HOSTINGS_AND_CORES:
        description: "Defines the distribution of cores among the hostings providers"
        value:
          hosting1: # find the hosting that you have migrated
            co1: 
              ip: CHANGE_ME # change its IP address to the new one
```

Then reboot config-follower and the pryv-services on all register machines:

```bash
${PRYV_CONF_ROOT}/restart-config-follower
${PRYV_CONF_ROOT}/restart-pryv
```
