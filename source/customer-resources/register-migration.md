---
id: register-migration
title: 'Pryv.io register migration'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Summary](#summary)
2. [Deploy and launch services on the *destination* machine](#deploy-and-launch-services-on-the-destination-machine)
3. [(Optional) Backup Redis data](#-optional-backup-redis-data)
4. [Transfer user data](#transfer-user-data)
5. [Set NGINX proxying](#set-nginx-proxying)
6. [Set the *source* register as replica of the *dest* register through a SSH tunnel](#set-the-source-register-as-replica-of-the-dest-register-through-a-ssh-tunnel)
7. [Update Name servers](#update-name-servers)
8. [Verify](#verify)
9. [Finalize](#finalize)

## Summary

The register migration procedure only takes into account the master registers. If you need to migrate a slave, simply deploy a new one and replication will take care of the data migration.  

We copy the data from the old master register to the new master register, set the old register to proxy to the new one and enable replication between the 2 so they are synchronized during the DNS propagation phase.

## Setup *dest* machine

We assume that you have installed `docker` and `docker-compose` on the *dest* machine and have authenticated yourself with our private Docker repository.

## Transfer data

We will be transfering data using rsync, therefore, we setup a pair of keys for this:

1- Create an SSH key pair using the following command:  

```bash
ssh-keygen -t rsa -b 4096 -C "migration@remote"
```

2- Copy the private one to `${PATH_TO_PRIVATE_KEY}` in *source*  

3- Add the public one in `~/.ssh/authorized_keys` on *dest*  

4- Shutdown services on *source* to prevent new information from arriving: `${PRYV_CONF_ROOT}/stop-pryv`  

### Transfer config data

5- Transfer config leader, on *source*, run:  

```bash
time rsync --verbose --copy-links \
     --archive --compress -e \
  "ssh -i ${PATH_TO_PRIVATE_KEY}" \
     ${PRYV_CONF_ROOT}/config-leader \
     ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/config-leader/
```

You may have to go via your home user directory on *dest* first if permission issues arise.  

6- Transfer config follower, on *source*, run:  

```bash
time rsync --verbose --copy-links \
     --archive --compress -e \
  "ssh -i ${PATH_TO_PRIVATE_KEY}" \
     ${PRYV_CONF_ROOT}/config-follower \
     ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/config-follower/
```

(Same comment as previous step about permissions.)  

7- Fetch docker images on *dest* by running:  

```bash
${PRYV_CONF_ROOT}/run-config-follower
${PRYV_CONF_ROOT}/run-pryv
```

8- Shutdown Pryv services on *dest* prior to transferring user data:  

```bash
${PRYV_CONF_ROOT}/stop-pryv
```

### Transfer user data and fetch docker images

9- Transfer Redis data: on *source*, run:  

```bash
time rsync --verbose --copy-links \
  --archive --compress --delete -e \
  "ssh -i ${PATH_TO_PRIVATE_KEY}" \
  ${PRYV_CONF_ROOT}/pryv/redis/data \
  ${USERNAME}@${DEST_MACHINE}:${PRYV_CONF_ROOT}/pryv/redis/data/
```

(Same comment as previous step about permissions.)  

### Fix permissions and boot services on *dest*

10- On *dest*, run `${PRYV_CONF_ROOT}/ensure-permissions-reg-master` script to help with enforcing correct permissions on data and log folders.  

11- Then setup the config and boot services on *dest*:  

```bash
${PRYV_CONF_ROOT}/run-pryv
```

If you wish to reactivate service on the *source* machine, simply reboot the stopped services: `${PRYV_CONF_ROOT}/run-pryv`.  

## Set NGINX proxying

Since the DNS changes will take some time to come into effect, the NGINX process on *source* will be set to proxy to the *dest* machine.
The following steps describe the configuration changes to make NGINX proxy calls to the *dest* register. It is advised to comment out the old setting inline using `#` in order to rollback easily in case of need.

- In `${PRYV_CONF_ROOT}/pryv/nginx/conf/site-443.conf`, Replace the following:

```nginx
upstream register_server {
  server register:9000 max_fails=3 fail_timeout=30s;
}

upstream mail_server {
  server mail:9000 max_fails=3 fail_timeout=30s;
}

upstream leader_server {
  server config-leader:7000 max_fails=3 fail_timeout=30s;
}

upstream admin_panel_server {
  server admin_panel:80;
}
```

with

```nginx
upstream register_server {
  server ${DEST_REGISTER_IP_ADDRESS}:443;
}

upstream mail_server {
  server ${DEST_REGISTER_IP_ADDRESS}:443;
}

upstream leader_server {
  server ${DEST_REGISTER_IP_ADDRESS}:443;
}

upstream admin_panel_server {
  server ${DEST_REGISTER_IP_ADDRESS}:80;
}
```

Change proxy protocol from `http` to `https`

- Change: `http://register_server` to `https://register_server`
- Change: `http://mail_server` to `https://mail_server`
- Change: `http://leader_server` to `https://leader_server`
- Change: `http://admin_panel_server` to `https://admin_panel_server`

Run `${PRYV_CONF_ROOT}/run-pryv`

As we are currently using docker-compose to specify the mounted volumes (containing the NGINX config), we just boot all services, even if they will unused as NGINX is proxying to the *dest* machine.

## Set the *source* register as replica of the *dest* register through a SSH tunnel

As DNS requests might still be routed to the old machine, we need to keep its database updated.

1. On the *dest* machine, open the Redis container port 6379 to localhost: Add `- "127.0.0.1:6379:6379"` to the `ports` section of the `redis` service in the `${PRYV_CONF_ROOT}/pryv/pryv.yml` docker-compose file and reboot it running `${PRYV_CONF_ROOT}/restart-pryv`
2. Copy the private key generated earlier to the *source* register in `${PRYV_CONF_ROOT}/pryv/redis/conf` so it is mounted in the container upon startup
3. Set *source* register as replica of *dest* register and add the following to *source* register's redis config file `${PRYV_CONF_ROOT}/pryv/redis/conf/redis.conf`: `replicaof localhost 4567`
4. Reboot services on *source*: `${PRYV_CONF_ROOT}/restart-pryv`
5. On the *source* register, enter the redis container (`docker exec -ti pryvio_redis bash`), open a SSH tunnel: run `ssh -i ${PATH_TO_PRIVATE_KEY} -L 4567:127.0.0.1:6379 root@${DEST_REG_HOSTNAME} -N`.

## Update Name servers

In your hosting provider (or your own system), set the name servers to the domain name associate to your Pryv.io platform as the *dest* register machines.

Update the `NAME_SERVER_ENTRIES` platform parameter accordingly

## Verify

Run a DNS query on the *dest* Register machines and verify that they contain the same data as the *source* ones.

Run `dig @{DEST_REG_MASTER_IP_ADDRESS} USERNAME.DOMAIN` and `dig @{DEST_REG_SLAVE_IP_ADDRESS} USERNAME.DOMAIN`

## Finalize

After some time, all DNS requests will be directed to the *dest* register machines. To verify this, take a look at the logs on the *sources* of the `dns` and `register` containers and ensure that they have served no request in ~24 hours.
