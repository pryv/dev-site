---
id: platform-validation
title: 'ABC'
template: default.jade
customer: true
withTOC: true
---

|         |                       |
| ------- | --------------------- |
| Author  | Ilia Kebets 		      |
| Reviewer | Guillaume Bassand (v1,2) |
| Date    | 31.01.2019            |
| Version | 3                     |



# Summary

This procedure describes the steps to validate that a Pryv.io platform is up and running. Troubleshooting steps can be found at the end of this document in case of validation failure.

# Variables

As this guide is platform agnostic, we will use variables `${VARIABLE_NAME}` which must be replaced in the commands.

## Domain name

This guide considers the platform using a certain domain name, which will be called `${DOMAIN}`.

## Configuration folder

The Pryv.io configuration files are placed in a certain folder on the machine, we will call this folder `${PRYV_CONFIG_FOLDER}`.

## Container name

Pryv.io components are containerized with Docker, so when doing certain actions on them, we address the containers by their name `${APP_CONTAINER_NAME}`. To find the name of a container, use `docker ps -a` to display all containers.

## Core machine hostname

The hostname ${CORE_MACHINE_HOSTNAME} of a machine running the Pryv.io core service. On default configurations, we define the first one as co1.${DOMAIN}.

# Tools

Depending on your skill set, this can be done using CLI tools or a web interface.

## DNS checks:

- dig version 9.12.3+
- If you don't have access to `dig` or the right version, you can use [G Suite's Toolbox dig](https://toolbox.googleapps.com/apps/dig/)

## HTTP checks:

- cURL version 7.54.0+
- Chrome web browser version 71+

# Operations

## DNS is set as domain name server

Run `dig NS ${DOMAIN}`.

The `ANSWER SECTION` should exist and list 2 hostnames such as:  

~~~~~~~~
;; ANSWER SECTION:
${DOMAIN}.  SOME_TTL_NUMBER  IN  NS  dns1.${DOMAIN}.
${DOMAIN}.  SOME_TTL_NUMBER  IN  NS  dns2.${DOMAIN}.
~~~~~~~~

If there is no `ANSWER SECTION`, the name servers for the domain name `${DOMAIN}` are not defined or misconfigured.  
Verify with your domain provider that the name servers are set correctly.

## DNS

Run `dig reg.${DOMAIN}`.

The `ANSWER SECTION` should exist and list a hostname such as:  

~~~~~~~~
;; ANSWER SECTION:
reg.${DOMAIN}.  SOME_TTL_NUMBER  IN  A  ${REGISTER_MACHINE_IP_ADDRESS}
~~~~~~~~

If there is no `ANSWER SECTION`, this means that the DNS is not running or is unreachable. See [DNS section](#dns).

## API

Run `curl -i https://${CORE_MACHINE_HOSTNAME}/status` or open [https://${CORE_MACHINE_HOSTNAME}/status](https://${CORE_MACHINE_HOSTNAME}/status)

- HTTP Status 200: OK
- HTTP Status 502: core service is not running, see [Core section](#core)
- `connection refused` error: core's NGINX is not running, see [NGINX section](#nginx)
- `could not resolve host` error: DNS is not running, see [DNS section](#dns)

## Register

Run `curl -i https://reg.${DOMAIN}/wactiv/check_username` or open [https://reg.${DOMAIN}/wactiv/check_username](https://reg.${DOMAIN}/wactiv/check_username)

HTTP status:  
- 200: OK  
- 500, 502: Register service is not running, see [Register section](#register)  

# Troubleshoot

## DNS

1. SSH to the machine
2. Access the DNS container logs on the Register machine: `docker logs -f --tail 50 ${DNS_CONTAINER_NAME}`.  

### Redis database unreachable

The logs contain the following error `Error: Redis connection to redis:6379 failed - getaddrinfo ENOTFOUND redis redis:6379`.  
See the Redis logs: `tail -f ${PRYV_CONFIG_FOLDER}/reg-master/redis/log/redis.log`  
Fix issue if possible, otherwise send the last 100 lines of the log file to your Pryv tech contact. Run `tail -n 100 ${PRYV_CONFIG_FOLDER}/reg-master/redis/log/redis.log > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Configuration error

If the service keeps rebooting with an error message, fix configuration if possible.  
Otherwise, send the last 100 lines of the DNS log file to your Pryv tech contact. Run `docker logs --tail 100 ${DNS_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

## Core

1. SSH to core machine
2. Read logs & fix issue if possible: `docker logs -f --tail 50 ${CORE_CONTAINER_NAME}`
3. Reboot if necessary: `docker stop ${CORE_CONTAINER_NAME} && ./run-core`
4. Send container log to your Pryv tech contact. Run `docker logs --tail 100 ${CORE_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Configuration error

If the service keeps rebooting with an error message, fix configuration if possible.  
Otherwise, send the last 100 lines of the container log to your Pryv tech contact. Run `docker logs --tail 100 ${CORE_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Waiting on database connection

If the service is waiting on the database to be available for connection: `[database] Cannot connect to mongodb://mongodb:27017/pryv-node, retrying in a sec`  
check MongoDB status: `tail -f ${PRYV_CONFIG_FOLDER}/core/mongodb/log/mongodb.log`  
- Booting: just wait 1-15min depending on the size of your database  
- Error: read logs, fix error if possible & reboot it if needed: `docker stop ${MONGODB_CONTAINER_NAME} && ./run-core`  
- Send MongoDB container log to your Pryv tech contact. Run `tail -n 100 ${PRYV_CONFIG_FOLDER}/core/mongodb/log/mongodb.log > ${DATE}-${ISSUE_NAME}.log` to generate the log file.  

## NGINX

1. SSH to core/register machine
2. Read logs & fix issue if possible: `docker logs ${NGINX_CONTAINER_NAME}`
3. Reboot if necessary: `docker stop ${NGINX_CONTAINER_NAME} && ./run-core`
4. Send error log to your Pryv tech contact. Run `docker logs --tail 100 ${NGINX_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Configuration error

If the log file has a line such as: `2019/01/28 12:44:07 [emerg] ERROR MESSAGE ...`, fix issue if possible.  
Otherwise, send error log to your Pryv tech contact. Run `docker logs --tail 100 ${NGINX_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

## Register

1. SSH to the register machine
2. Read logs & fix issue if possible: `docker logs -f --tail 50 ${REGISTER_CONTAINER_NAME}`  
3. Reboot if necessary: `docker stop ${REGISTER_CONTAINER_NAME} && ./run-reg-master`  
4. Send error log to your Pryv tech contact. Run `docker logs --tail 100 ${REGISTER_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Configuration error

Service keeps rebooting with an error message - fix configuration if possible and reboot the service.

### Redis database unreachable

See [this section under DNS](#redis-database-unreachable).