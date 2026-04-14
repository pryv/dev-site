---
id: faq
title: 'FAQ - infrastructure'
layout: default.pug
withTOC: true
---

In this FAQ we answer common questions related to the Pryv.io platform. You can contact us on [Github Discussion](https://github.com/orgs/pryv/discussions) if your question is not listed here.

> **Pryv.io v2** — Since v2 (2026) Pryv.io ships as a single binary (`pryvio/open-pryv.io` Docker image, or `node bin/master.js`). Registration, DNS and the admin endpoints are all built into the core — there is no separate `register`, `core`, `hfs`, `preview` or `dns` container. Where a procedure below still references the v1 multi-container layout (`pryvio_*` containers, `run-pryv`, `${PRYV_CONF_ROOT}` scripts) it is kept for operators still on v1; the v2 equivalent is noted inline. For v2 installs see [INSTALL](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md).


## Table of contents <!-- omit in toc -->

1. [Platform prerequisites](#platform-prerequisites)
2. [Customize registration, login, password-reset pages](#customize-registration-login-password-reset-pages)
3. [Host apps, resources on the same domain, and reuse the SSL certificate](#host-apps-resources-on-the-same-domain-and-reuse-the-ssl-certificate)
4. [System administrators](#system-administrators)


## Platform prerequisites

In addition to the **Infrastructure procurement** guide (available on request), a Pryv.io platform requires its own **domain name**, such as `pryv.me` to work. Apps will access data through the https://${username}.${domain} endpoint, e.g. https://user-123.pryv.me. This can be totally hidden from the end user.

To encrypt data in transit, we require a **wildcard SSL certificate** for the domain **\*.domain**, this can be either bought or generated using [let's encrypt](https://letsencrypt.org/).

Since we use our own DNS servers to resolve the domain associated with the platform, it must be possible to **set name servers** for the domain. This must be verified before buying the domain, as some providers do not allow it.

### Do SSL certificates need to be signed by publicly trusted CA or can we use self-signed certificates?

All devices that interact with the Pryv.io platform must be able to verify the certificates and thus see/trust the CA, even if it is internal. That would involve: the mobile application, all machines that perform analytics and display of the data collected.

### SSL certificates are mentioned to be wildcard ones. Are we able to define all the subdomains beforehand and rather create SSL with SANs?

Pryv.io uses a subdomain per user account that is created. So no, you cannot use SAN certificates unless you're able to know the possible user base ahead of time.

### On what cloud offerings can Pryv.io be installed?

Pryv.io can be installed on any cloud offering that runs at least Docker 1.12.6. The real consideration here is compliance and the security of the data storage.

We have run Pryv.io on the following public clouds: AWS, Microsoft Azure, Gandi.net, Exoscale.ch, Joyent, Fengqi.asia.

### What constraints should be considered when choosing a host?

You must take into account the legislation covering the people whose data will be stored in the Pryv.io platform, such as US HIPAA, EU GDPR, Swiss DPA. This often includes requirements on the geographic location where the data is stored.

### How do you address encryption of the data at rest? As medical records will be stored in MongoDB, are you using DB encryption or some other application specific encryption?

Pryv offers three options here:

- Application-level end-to-end encryption: your application(s) that will access Pryv.io encrypt the data before sending it and can decrypt it after reading it back. Pryv.io provides a data type to include metadata concerning the encryption used by your application. See: <http://pryv.github.io/event-types/#encrypted>
- Disk encryption: Linux has a solid story of disk encryption. If stored on such a disk, Pryv data is encrypted at rest as well.

The last option will probably the easiest to implement. It offers good protection against disks being stolen from the datacenter, while not increasing overall system complexity by much.

### Self-managed top-domain

This only applies to **multi-core** deployments that run the embedded DNS (i.e. `dnsLess.isActive: false`). Single-node v2 installs use `dnsLess` mode and do not need any of this.

The embedded DNS served by each core must resolve all requests for the domain. Entries in the top-domain will look like:

```
ns1-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_CORE_1}
ns2-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_CORE_2}

${DOMAIN}	TTL_SECONDS IN NS ns1-${DOMAIN}
${DOMAIN}	TTL_SECONDS IN NS ns2-${DOMAIN}
```

On single-node or PoC installations of a multi-core platform, you will have only one core; both Type A entries point to the same IP address:

```
ns1-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_CORE_1}
ns2-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_CORE_1}

${DOMAIN}	TTL_SECONDS IN NS ns1-${DOMAIN}
${DOMAIN}	TTL_SECONDS IN NS ns2-${DOMAIN}
```

You can verify that the core is set to resolve DNS queries for your domain using: `dig NS ${DOMAIN}`. The answer section must include:

```
${DOMAIN}		${TTL_SECONDS}	IN		NS		ns1-${DOMAIN}.${TOP_DOMAIN}
${DOMAIN}		${TTL_SECONDS}	IN		NS		ns2-${DOMAIN}.${TOP_DOMAIN}
```


## Customize registration, login, password-reset pages

We provide default web apps for registration, login, password-reset and auth request. The code is available on https://github.com/pryv/app-web-auth3.

To customize it, fork the repository and activate [GitHub Pages](https://pages.github.com/) on the `gh-pages` branch (an empty commit is enough to kick the build off).

You then need to point the `/access/` path of your Pryv.io deployment at your fork:

- **v2** — this is handled by your own reverse proxy. Add an `/access/` location to the NGINX config shown in [INSTALL — Running behind nginx](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md#running--behind-nginx):

  ```nginx
  location /access/ {
    proxy_pass https://${CUSTOMER_ACCOUNT}.github.io/app-web-auth3/;
  }
  if ($request_uri !~* "^/access/static/.*$") {
    rewrite ^/access/.*$ /access/index.html;
  }
  ```

- **v1** — edit the bundled NGINX config at `pryv/nginx/site.conf`. Change:

  ```
  proxy_pass        https://pryv.github.io/app-web-auth3/;
  ```

  to:

  ```
  proxy_pass        https://${CUSTOMER_ACCOUNT}.github.io/app-web-auth3/;
  ```

  and add the following in the `sw.${DOMAIN}` server scope:

  ```
  if ($request_uri !~* "^/access/static/.*$") {
    rewrite ^.*$ /access/index.html;
  }
  ```

The following pages will show the changes that you apply to this repository:

- Registration: https://${DOMAIN}/access/register.html
- Reset password: https://${DOMAIN}/access/reset-password.html
- Consent authorization: https://${DOMAIN}/access/access.html


## Host apps, resources on the same domain and reuse the SSL certificate

You can reuse the platform's SSL certificate by hosting additional apps behind the same reverse proxy as Pryv.io.

- **v2** — add `location` blocks to your own NGINX (or other reverse proxy). See [INSTALL — Running behind nginx](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md#running--behind-nginx) for the base configuration, then insert:

  ```nginx
  location /MY_APP/ {
    proxy_pass         MY_APP_URL_WITH_PROTOCOL;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_buffering    off;
  }
  ```

- **v1** — the built-in NGINX proxy can be configured to serve apps under `https://sw.${DOMAIN}/MY_APP/` by adding the same `location` clause in `pryv/nginx/conf/site.conf`.

## System administrators

### Port 53 is already in use (v1 only)

On v1 installs, the DNS container could fail to bind port 53 when Docker's embedded DNS was using the same interface. The fix was to pin the DNS service to an explicit external-interface IP in docker-compose:

```yaml
ports:
	- "EXTERNAL_INTERFACE_IP_ADDRESS:53:5353/udp"
```

In **v2**, the embedded DNS server runs in-process inside the core (when `dnsLess.isActive: false` / multi-core). The DNS port is taken by the core process itself; conflicts with Docker's embedded DNS no longer apply.

### `docker login` X11 error

On a Pryv install using Ubuntu 18.X when running `docker login`: Ubuntu refuses to let you enter the password because it wants you to use a secure means of password entry. The error reads something like 'Cannot autolaunch D-Bus without X11 \$DISPLAY' ([docker-compose issue #6023](https://github.com/docker/compose/issues/6023)).
Our workaround is:

```
sudo apt-get remove golang-docker-credential-helpers
sudo apt install docker-compose
```

The second line is needed because the first removes docker-compose as well.

### Are my containers running?

Show running containers: "docker ps", if the container exited, you can use "docker ps -a". This will allow to find the name of the container.

### Why is container XYZ not running?

By default, our containers write logs into `stdout`, the reason for a failure can be printed using `docker logs ${CONTAINER_NAME}`.

### Permission denied error

During deployment and update, it is possible that some folders have incorrect permissions, preventing the Pryv.io process from reading configuration and data files. The error looks like:

```
Error: EACCES: permission denied
```

- **v2**: inspect the container with `docker logs -f --tail 50 <container-name>` (the default is `pryvio_open_pryv_io`). Ensure that the host paths mounted into the container (typically `data/users`, `data/previews`, `data/rqlite-data` — see [INSTALL](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md)) are owned by the UID the container runs as.
- **v1**: logs live under `pryvio_${CONTAINER_NAME}`; run the provided `ensure-permissions` script on the host and reboot services.

### How do I reset data on my Pryv.io platform?

This step will erase all data from your platform. Perform this at your own risk and make sure that you know what you are doing.

**v2** — stop the core, remove the data directories that back your configured storage engines, then restart. With the defaults from [INSTALL](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md):

```bash
# stop the core (Docker or systemd, depending on your deployment)
rm -rf data/users/*          # SQLite DBs + per-user files (audit, index, account)
rm -rf data/previews/*       # image previews
rm -rf data/rqlite-data/*    # platform DB (rqlite Raft + snapshot)
# if using external MongoDB / PostgreSQL: drop and recreate the database there
# then restart the core
```

**v1**:

```bash
cd ${PRYV_CONF_ROOT}
./stop-pryv
rm -rf pryv/core/data/*
rm -rf pryv/mongodb/data/*
rm -rf pryv/influxdb/data/*
./run-pryv
```

### How can I use the demo dashboard app (_app-web_) on my Pryv.io platform?

App-web is hosted on GitHub pages and can be used for your Pryv.io platform as described in [its documentation](https://github.com/pryv/app-web#usage).

### Can I use my own SSL termination with Pryv.io?

Yes.

**v2** — the core has three modes, all covered in [INSTALL](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md):

1. **Built-in HTTPS**: let the core terminate TLS by setting `http.ssl.keyFile` / `http.ssl.certFile` in the override config.
2. **Behind your own reverse proxy (recommended for production)**: leave `http.ssl` unset, run the core on plain HTTP, and terminate TLS in your NGINX/Caddy/ALB. A ready-to-use NGINX snippet for all three ports (API 3000, HFS 4000) is in [INSTALL — Running behind nginx](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md#running--behind-nginx).
3. **backloop.dev** for dev/test.

**v1** — edit the NGINX config shipped with the stack:

In the `nginx/conf/nginx.conf` file, comment out the following lines by adding a `#` at their beginning:

```nginx
#ssl_certificate      /app/conf/secret/DOMAIN-bundle.crt;
#ssl_certificate_key  /app/conf/secret/DOMAIN-key.pem;
```

In the `nginx/conf/site-443.conf` file, change the `listen` directive from `443 ssl` to `80` for each `server` block:

```nginx
server {
  listen    80;
  # ...
}
```

### My security policy requires that all outgoing traffic goes through a proxy, will Pryv.io work?

Yes.

**v2** — set `http_proxy` / `https_proxy` in the environment of the core process (or pass them through your Docker orchestrator / systemd unit). There are no per-role helper scripts to edit; the single `bin/master.js` process and its workers inherit the environment.

**v1** — add `http_proxy` / `https_proxy` to the reverse-proxy service in `docker-compose.yml`:

```yaml
reverse_proxy:
  image: "eu.gcr.io/pryvio/nginx:1.3.40"
  container_name: pryvio_nginx
  # ...
  environment:
    - http_proxy
    - https_proxy
```

and export them at the top of the `run-config-leader`, `run-config-follower`, `run-pryv` and `restart-*` scripts:

```bash
export http_proxy=${YOUR-PROXY-HOSTNAME-WITH-PORT}
export https_proxy=${YOUR-PROXY-HOSTNAME-WITH-PORT}
```
