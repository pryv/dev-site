---
id: platform-validation
title: 'Pryv.io platform validation guide'
layout: default.pug
customer: true
withTOC: true
---

<!--
|         |                       |
| ------- | --------------------- |
| Author  | Ilia Kebets 	      |
| Reviewer | Guillaume Bassand (v1,2), Anastasia Bouzdine (v3) |
| Date    | 28.04.2020            |
| Version | 4                     |
-->

This procedure describes the steps to validate that a Pryv.io platform is up and running. You can directly jump to the [Checklist section](#checklist) to proceed to a quick check-up of your Pryv.io platform.
Troubleshooting steps can be found at the end of this document in case of validation failure.


## Table of contents <!-- omit in toc -->

1. [Variables](#variables)
2. [Tools](#tools)
   1. [DNS checks:](#dns-checks)
   2. [HTTP checks:](#http-checks)
3. [Checklist](#checklist)
   1. [DNS is set as domain name server](#dns-is-set-as-domain-name-server)
   2. [DNS](#dns)
   3. [Core](#core)
   4. [Register](#register)
4. [Troubleshoot](#troubleshoot)
   1. [File permissions](#file-permissions)
   2. [DNS issues](#dns-issues)
      1. [Redis database unreachable](#redis-database-unreachable)
      2. [Configuration error](#configuration-error)
      3. [Port is unreachable from the Internet](#port-is-unreachable-from-the-internet)
   3. [Core issues](#core-issues)
      1. [Configuration error](#configuration-error-1)
      2. [Waiting on database connection](#waiting-on-database-connection)
   4. [NGINX issues](#nginx-issues)
      1. [Configuration error](#configuration-error-2)
   5. [Register issues](#register-issues)
      1. [Configuration error](#configuration-error-3)
      2. [Redis database unreachable](#redis-database-unreachable-1)


## Variables

As this guide is platform-agnostic, we will use variables `${VARIABLE_NAME}` which must be replaced in the commands.

In particular, the following variables should be replaced :
- the **domain name**, which will be called `${DOMAIN}`,
- the **configuration root folder** `${PRYV_CONF_ROOT}`, corresponding to the folder on the machine containing the Pryv.io configuration files,
- the **container name**. Pryv.io components are containerized with Docker, so when doing certain actions on them, we address the containers by their name `${APP_CONTAINER_NAME}`. To find the name of a container, use `docker ps -a` to display all containers,
- the **core machine hostname** `${CORE_MACHINE_HOSTNAME}`, corresponding to the machine running the Pryv.io core service. On default configurations, we define the first one as `co1.${DOMAIN}`.


## Tools

Depending on your skill set, this can be done using CLI tools or a web interface.

### DNS checks:

- dig version 9.12.3+

### HTTP checks:

- cURL version 7.54.0+
- Chrome web browser version 71+


## Checklist

### DNS is set as domain name server

Run the following command:

```
dig NS +trace +nodnssec ${DOMAIN}
```

The **2 last blocks** should display hostnames that resolve to the machine running your Pryv.io DNS such as:  

```
${YOUR-DOMAIN}.		SOME_TTL_VALUE	IN	NS	dns1-pryv.${YOUR-DOMAIN}.
${YOUR-DOMAIN}.		SOME_TTL_VALUE	IN	NS	dns2-pryv.${YOUR-DOMAIN}.
```

The last block should be followed by a line indicating that it is coming from your Pryv.io DNS such as:

```
;; Received 123 bytes from ${YOUR-DNS-IP-ADDRESS}#53(dns1-pryv.${YOUR-DOMAIN}) in 15 ms
```

- If there are no blocks containing your machine's hostname, the name servers for the Pryv.io domain name `${DOMAIN}` are not defined or misconfigured. Verify with your domain provider that the name servers are set correctly.
- If there is a single block displaying your machine's hostname, then your Pryv.io DNS is not running. See [DNS issues section](#dns-issues).

### DNS

Run the following command:  

```
dig reg.${DOMAIN}
```

The `ANSWER` section should exist and list a hostname such as:  

~~~~~~~~
;; ANSWER :
reg.${DOMAIN}.  SOME_TTL_NUMBER  IN  A  ${REGISTER_MACHINE_IP_ADDRESS}
~~~~~~~~

If there is no `ANSWER` section, this means that the DNS is not running or is unreachable. See [DNS section](#dns-issues).

### Core

Run `curl -i https://${CORE_MACHINE_HOSTNAME}/status` or open [https://${CORE_MACHINE_HOSTNAME}/status](https://${CORE_MACHINE_HOSTNAME}/status).  

The hostname of the first core should be `co1.${DOMAIN}` by default (`co2.${DOMAIN}` and so on for the other ones in case of cluster deployment).

- HTTP Status 200: OK
- HTTP Status 502: core service is not running, see [core issues section](#core-issues)
- `connection refused` error: core's NGINX is not running, see [NGINX section](#nginx-issues)
- `could not resolve host` error: DNS is not running, see [DNS section](#dns-issues)

### Register

Run `curl -i https://reg.${DOMAIN}/wactiv/check_username` or open [https://reg.${DOMAIN}/wactiv/check_username](https://reg.${DOMAIN}/wactiv/check_username). For DNS-less, use `curl -i https://${HOSTNAME}/reg/wactiv/check_username` or open [https://${HOSTNAME}/reg/wactiv/check_username](https://${HOSTNAME}/reg/wactiv/check_username).

HTTP status:  
- 200: OK  
- 500, 502: Register service is not running, see [register issues section](#register-issues)  


## Troubleshoot

### File permissions

If you encounter permission issues on data and log files, those handy scripts make sure they are set correctly:

- On a single node setup: `./ensure-permissions`; after that run `${PRYV_CONF_ROOT}/restart-pryv` to ensure Redis picks up possible changes
- On a cluster setup:
  - On register: `./ensure-permissions-reg-master`; after that run `${PRYV_CONF_ROOT}/restart-pryv` to ensure Redis picks up possible changes
  - On core: `./ensure-permissions-core`

### DNS issues

1. SSH to the machine
2. Access the DNS container logs on the register machine: `docker logs -f --tail 50 ${DNS_CONTAINER_NAME}`.  

#### Redis database unreachable

The logs contain the following error `Error: Redis connection to redis:6379 failed - getaddrinfo ENOTFOUND redis redis:6379`.  
See the Redis logs: `tail -f ${PRYV_CONF_ROOT}/reg-master/redis/log/redis.log`  
Fix issue if possible, otherwise send the last 100 lines of the log file to your Pryv tech contact. Run `tail -n 100 ${PRYV_CONF_ROOT}/reg-master/redis/log/redis.log > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Configuration error

If the service keeps rebooting with an error message, fix configuration if possible.  
Otherwise, send the last 100 lines of the DNS log file to your Pryv tech contact. Run `docker logs --tail 100 ${DNS_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Port is unreachable from the Internet

If there are no errors in the logs, the machine might simply not be reachable from the Internet on port UDP/53.

1. SSH to the register machine
2. Make a DNS request: `dig @localhost reg.${DOMAIN}`

If the request yields an answer, your firewall settings might be set wrong. You must allow INGRESS UDP/53 as defined in the **Infrastructure procurement guide** from the [Customer Resources page](/customer-resources/#guides-and-documents).


### Core issues

1. SSH to core machine
2. Read logs & fix issue if possible: `docker logs -f --tail 50 ${CORE_CONTAINER_NAME}`
3. Reboot if necessary: `docker stop ${CORE_CONTAINER_NAME} && ./run-core`
4. Send container log to your Pryv tech contact. Run `docker logs --tail 100 ${CORE_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Configuration error

If the service keeps rebooting with an error message, fix configuration if possible.  
Otherwise, send the last 100 lines of the container log to your Pryv tech contact. Run `docker logs --tail 100 ${CORE_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Waiting on database connection

If the service is waiting on the database to be available for connection: `[database] Cannot connect to mongodb://mongodb:27017/pryv-node, retrying in a sec`  
check MongoDB status: `tail -f ${PRYV_CONF_ROOT}/core/mongodb/log/mongodb.log`  
- Booting: just wait 1-15min depending on the size of your database  
- Error: read logs, fix error if possible & reboot it if needed: `docker stop ${MONGODB_CONTAINER_NAME} && ./run-core`  
- Send MongoDB container log to your Pryv tech contact. Run `tail -n 100 ${PRYV_CONF_ROOT}/core/mongodb/log/mongodb.log > ${DATE}-${ISSUE_NAME}.log` to generate the log file.  

### NGINX issues

1. SSH to core/register machine
2. Read logs & fix issue if possible: `docker logs ${NGINX_CONTAINER_NAME}`
3. Reboot if necessary: `docker stop ${NGINX_CONTAINER_NAME} && ./run-core`
4. Send error log to your Pryv tech contact. Run `docker logs --tail 100 ${NGINX_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Configuration error

If the log file has a line such as: `2019/01/28 12:44:07 [emerg] ERROR MESSAGE ...`, fix issue if possible.  
Otherwise, send error log to your Pryv tech contact. Run `docker logs --tail 100 ${NGINX_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

### Register issues

1. SSH to the register machine
2. Read logs & fix issue if possible: `docker logs -f --tail 50 ${REGISTER_CONTAINER_NAME}`  
3. Reboot if necessary: `docker stop ${REGISTER_CONTAINER_NAME} && ./run-reg-master`  
4. Send error log to your Pryv tech contact. Run `docker logs --tail 100 ${REGISTER_CONTAINER_NAME} > ${DATE}-${ISSUE_NAME}.log` to generate the log file.

#### Configuration error

Service keeps rebooting with an error message - fix configuration if possible and reboot the service.

#### Redis database unreachable

See [this section under DNS](#redis-database-unreachable).