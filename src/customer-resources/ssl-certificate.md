---
id: ssl-certificate
title: 'Pryv.io SSL Certificate'
layout: default.pug
customer: true
withTOC: true
---

This document describes how to obtain and install the SSL certificate used by a Pryv.io deployment.

> **Since v2 (2026)** the core no longer ships its own `renew-ssl-certificate` helper. You provide the certificate from a source of your choice — [Let's Encrypt](https://letsencrypt.org/) / [certbot](https://certbot.eff.org/), your internal CA, a commercial CA, or your reverse-proxy's auto-renewal (Caddy, Traefik, `nginx-proxy-manager`, …) — and point the core at the resulting files.

Prerequisite: you have [obtained a domain name](/customer-resources/pryv.io-setup/#obtain-a-domain-name) and installed the core ([INSTALL](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md)).


## Table of contents <!-- omit in toc -->

1. [Which certificate do I need?](#which-certificate-do-i-need)
2. [Where the certificate plugs in](#where-the-certificate-plugs-in)
   1. [Built-in HTTPS (core terminates TLS)](#built-in-https-core-terminates-tls)
   2. [Behind your own reverse proxy](#behind-your-own-reverse-proxy)
3. [Issuing a certificate with Let's Encrypt / certbot](#issuing-a-certificate-with-lets-encrypt--certbot)
   1. [HTTP-01 challenge (single-core, public host)](#http-01-challenge-single-core-public-host)
   2. [DNS-01 challenge (required for wildcards)](#dns-01-challenge-required-for-wildcards)
4. [Renewal](#renewal)
5. [v1 procedure (legacy)](#v1-procedure-legacy)


## Which certificate do I need?

| Deployment                                 | Certificate                                                         |
| ------------------------------------------ | ------------------------------------------------------------------- |
| Single-core with `dnsLess.isActive: true`  | Plain cert for `your-domain.com` (one hostname)                     |
| Multi-core using embedded DNS              | **Wildcard** cert for `*.mc.example.com` (every user gets a subdomain) |
| Multi-core with DNSless overrides          | Per-core plain certs (one cert per `core.url`)                      |

A wildcard certificate requires the **DNS-01** ACME challenge.


## Where the certificate plugs in

### Built-in HTTPS (core terminates TLS)

Set the paths in your override YAML — the core will load them directly:

```yaml
http:
  ip: 0.0.0.0
  port: 443
  ssl:
    keyFile: /etc/ssl/pryv/privkey.pem
    certFile: /etc/ssl/pryv/fullchain.pem
    caFile:  /etc/ssl/pryv/chain.pem        # optional, add the issuer chain if your CA is not in the OS trust store
```

Restart `bin/master.js` to pick up a renewed certificate (future versions may hot-reload — not yet guaranteed).

### Behind your own reverse proxy

Terminate TLS in your proxy and forward plain HTTP to the core on port 3000 (API) and port 4000 (HFS). A sample NGINX block is in [INSTALL — Running behind nginx](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md#running--behind-nginx). The proxy is also the right place to host your auto-renewal (certbot hook, Caddy's built-in ACME, Traefik, etc.).


## Issuing a certificate with Let's Encrypt / certbot

Install certbot from [the project instructions](https://certbot.eff.org/instructions).

### HTTP-01 challenge (single-core, public host)

The core (or your reverse proxy) must serve `/.well-known/acme-challenge/` on port 80 during the challenge. With certbot's standalone mode:

```bash
sudo certbot certonly --standalone -d your-domain.com
# → certs land in /etc/letsencrypt/live/your-domain.com/
```

Then point `http.ssl` at `/etc/letsencrypt/live/your-domain.com/fullchain.pem` and `privkey.pem`, or copy them into the path your reverse proxy expects.

### DNS-01 challenge (required for wildcards)

```bash
sudo certbot certonly --manual --preferred-challenges dns \
    -d "*.mc.example.com" -d "mc.example.com"
```

Certbot prompts you for a `_acme-challenge.mc.example.com` TXT record. Publish it in whichever DNS system answers for that domain (your registrar's zone, the core's embedded DNS if `dns.active: true`, an external provider, …) and wait for propagation:

```bash
dig TXT _acme-challenge.mc.example.com
```

When the right value comes back, continue the certbot prompt.

For a non-interactive pipeline, certbot has DNS plugins for common providers (Route 53, Cloudflare, OVH, …) — see [certbot plugins](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins). An API-driven plugin is the only practical way to run fully-automated wildcard renewal.


## Renewal

- **certbot** auto-registers a systemd timer/cron job (`certbot renew`) that runs twice a day. Reload the core (or your reverse proxy) after each successful renewal:

  ```bash
  # /etc/letsencrypt/renewal-hooks/post/reload-pryv.sh
  #!/usr/bin/env bash
  systemctl reload nginx          # or: systemctl restart pryv-core
  ```

- **Reverse-proxy-managed certificates** (Caddy, Traefik, nginx-proxy-manager, …) take care of renewal transparently — nothing to do on the Pryv.io side.


## v1 procedure (legacy)

Operators still running Pryv.io v1 can use the procedure shipped with the [v1 config template](https://pryv.github.io/config-template-pryv.io/):

- From 1.7.4 onward, run `./renew-ssl-certificate`. Make sure `config-leader/ssl/conf/ssl-certificate.yml` has a valid email address (mandatory since 1.9.0).
- If the pre-check fails with *"Servers are not reachable"* (the `pryvio_ssl_certificate` container cannot reach `pryvio_dns`), flip `acme.skipDnsChecks` to `true` in the same file, or raise `acme.dnsRebootWaitMs` to give DNS containers more time to start.
- Certificate files end up in `${PRYV_CONF_ROOT}/pryv/nginx/conf/secret/` as `${DOMAIN}-bundle.crt` and `${DOMAIN}-key.pem`. Run `./ensure-permissions --ignore-redis` and reboot (`./restart-config-follower && ./restart-pryv`, or *Update* from the admin panel).

None of the paths or scripts above exist in v2 — use the v2 procedures earlier on this page instead.
