---
id: single-node-to-cluster
title: 'Pryv.io — single-core to multi-core upgrade'
layout: default.pug
customer: true
withTOC: true
---

This guide describes how to upgrade a running single-core Pryv.io deployment to a multi-core setup, where several cores share the same platform and split users among themselves.

> **Since v2 (2026)** there is **no data migration involved**. The platform DB (rqlite) is already in place on the single-core install — going multi-core is a **config-only** change plus adding one or more cores. No separate register, DNS or static-web machines to provision, and no user data to copy. Users that already existed on the single core stay on that core; new registrations are distributed across all available cores.
>
> This page is the platform-operator narrative around the upstream [SINGLE-TO-MULTIPLE.md](https://github.com/pryv/open-pryv.io/blob/master/SINGLE-TO-MULTIPLE.md), which contains the exact config snippets and verification commands.


## Table of contents <!-- omit in toc -->

1. [Prerequisites](#prerequisites)
2. [Outcome at a glance](#outcome-at-a-glance)
3. [Decide on a DNS strategy](#decide-on-a-dns-strategy)
4. [Pick a wildcard SSL strategy](#pick-a-wildcard-ssl-strategy)
5. [Step 1 — Set up DNS](#step-1--set-up-dns)
6. [Step 2 — Reconfigure the existing core](#step-2--reconfigure-the-existing-core)
7. [Step 3 — Restart and verify the first core](#step-3--restart-and-verify-the-first-core)
8. [Step 4 — Deploy the second core](#step-4--deploy-the-second-core)
9. [Step 5 — Verify cross-core operation](#step-5--verify-cross-core-operation)
10. [Nginx / reverse-proxy notes](#nginx--reverse-proxy-notes)
11. [Rollback](#rollback)


## Prerequisites

- A running single-core Pryv.io v2 install with real users and data.
- DNS control for the target shared domain (you need to publish wildcard A records and an `lsc.{domain}` A record; or, in DNSless mode, NS+A records only).
- At least one more machine or Dokku app for the second core.
- A base-storage database (PostgreSQL or MongoDB) for the second core — separate from the first core's.
- The wildcard (or per-core) SSL certificate covering the new domain.


## Outcome at a glance

|                     | Before                         | After                                                                 |
| ------------------- | ------------------------------ | --------------------------------------------------------------------- |
| Cores               | 1 (single node)                | 2+ (one existing + one or more new)                                   |
| Platform DB         | rqlite (single, embedded)      | rqlite (clustered, embedded on every core, joined via DNS discovery)  |
| Base storage        | 1 (PostgreSQL or MongoDB)      | 1 per core — cores never share the base DB                            |
| User routing        | All users on one instance      | Each core hosts a subset; discovery via `/reg/cores?username=`        |
| Public URL          | `https://api.example.com` (dnsLess) or single domain | `{username}.mc.example.com` or per-core URLs (DNSless)  |
| Config flag         | `dnsLess.isActive: true`       | `dnsLess.isActive: false`, `core.id` + `dns.domain`                   |


## Decide on a DNS strategy

Two shapes of multi-core deployment are supported:

1. **Embedded DNS** — the cores answer DNS queries for `*.mc.example.com`. You publish NS records at the registrar that delegate the Pryv.io subdomain to the cores.
2. **Externally-managed DNS (DNSless multi-core)** — an external DNS provider (Cloudflare, Route 53, internal DNS, load balancer) resolves core hostnames. Cores advertise explicit `core.url` values via the platform DB and the client SDK uses the discovery endpoint rather than DNS to find the right core.

In both cases, an `lsc.{domain}` A record listing every core IP is needed for rqlite peer discovery.

See [INSTALL — DNSless multi-core](https://github.com/pryv/open-pryv.io/blob/master/SINGLE-TO-MULTIPLE.md#dnsless-multi-core-externally-managed-dns) for the externally-managed variant.


## Pick a wildcard SSL strategy

- Embedded DNS: one **wildcard** cert for `*.mc.example.com` used by all cores.
- DNSless: per-core plain certs for each `core.url`.

See the [SSL certificate guide](/customer-resources/ssl-certificate/).


## Step 1 — Set up DNS

**Embedded DNS variant** — publish at the registrar:

```
dns1.mc.example.com  3600  IN  A   <core-a-ip>
dns2.mc.example.com  3600  IN  A   <core-b-ip>
mc                   3600  IN  NS  dns1.mc.example.com.
mc                   3600  IN  NS  dns2.mc.example.com.

# rqlite peer discovery — must list every core
lsc.mc.example.com   60    IN  A   <core-a-ip>
lsc.mc.example.com   60    IN  A   <core-b-ip>
```

If you have a single machine to start with, repeat its IP in both `dns1` / `dns2` and the `lsc` record; add the second IP in Step 4.

**DNSless variant** — publish A records at your provider for each `core.url`, plus the `lsc.{domain}` record.


## Step 2 — Reconfigure the existing core

Edit the existing core's override YAML — see the exact shape in [SINGLE-TO-MULTIPLE.md — Update the first core's config](https://github.com/pryv/open-pryv.io/blob/master/SINGLE-TO-MULTIPLE.md#2-update-the-first-cores-config). The salient changes:

```yaml
# REMOVE (single-core / dnsLess)
# dnsLess:
#   isActive: true
#   publicUrl: https://old-single-core.example.com

dnsLess:
  isActive: false

core:
  id: core-a              # unique identifier for this core
  ip: <host-public-ip>
  available: true

dns:
  domain: mc.example.com  # shared domain for all cores
  active: false           # set to true only if the core itself should answer DNS queries

storages:
  engines:
    rqlite:
      raftPort: 4002      # must be reachable from peer cores
```

`storages.platform.engine` is already `rqlite` — no change needed.


## Step 3 — Restart and verify the first core

Restart `bin/master.js`. On startup the core will:

- Use the embedded rqlited for all platform operations.
- Generate user API URLs as `https://{username}.{dns.domain}/`.
- Identify itself as `core-a` and write its entry (id, ip, available) into PlatformDB.

Sanity checks (commands from upstream):

```bash
# Service info now reports multi-core URLs
curl -s https://core-a.mc.example.com/reg/service/info
# → api: https://{username}.mc.example.com/

# Existing users are reachable at their subdomain
curl -s https://existinguser.mc.example.com/auth/login -X POST ...

# Core discovery works for existing users
curl -s 'https://core-a.mc.example.com/reg/cores?username=existinguser'
# → { core: { url: "https://core-a.mc.example.com" } }
```

Until Step 4, the rqlite cluster has a single node — that's fine.


## Step 4 — Deploy the second core

Install the same core version on a second machine (Docker image or native). Give it its own base-storage DB (PostgreSQL/MongoDB) — cores never share base storage. Override YAML:

```yaml
core:
  id: core-b
  ip: <core-b-ip>
  available: true

dns:
  domain: mc.example.com

storages:
  engines:
    rqlite:
      raftPort: 4002      # same Raft port, must be reachable from core-a
    postgresql:            # or mongodb
      host: <core-b-pg-host>
      database: pryv_db_b
      # … core-b's own credentials
```

Start `bin/master.js` on core-b. Its embedded rqlited uses DNS discovery (`lsc.mc.example.com`) to find core-a and joins the existing cluster — no manual cluster bootstrapping.

**Firewall reminder:** the rqlite Raft port (default 4002) is peer-to-peer and does **not** go through nginx. Open it between cores.


## Step 5 — Verify cross-core operation

Upstream gives the exact curl sequence — [SINGLE-TO-MULTIPLE.md — Verify cross-core operation](https://github.com/pryv/open-pryv.io/blob/master/SINGLE-TO-MULTIPLE.md#5-verify-cross-core-operation). The essentials:

```bash
# 1. Register a new user on core-b — it should land on core-b
curl -s https://core-b.mc.example.com/users -X POST \
  -H 'Content-Type: application/json' \
  -d '{"appId":"test","username":"newuser","password":"pass","email":"new@test.com","invitationtoken":"enjoy","languageCode":"en"}'

# 2. Discover from core-a — should return core-b's URL
curl -s 'https://core-a.mc.example.com/reg/cores?username=newuser'
# → { core: { url: "https://core-b.mc.example.com" } }

# 3. List all cores (admin)
curl -s https://core-a.mc.example.com/system/admin/cores -H 'Authorization: <admin-key>'
# → { cores: [{ id: "core-a", userCount: N }, { id: "core-b", userCount: M }] }
```

Then run the [platform validation checklist](/customer-resources/platform-validation/) and the [healthchecks](/customer-resources/healthchecks/) — once against each core.


## Nginx / reverse-proxy notes

Each core still needs the same two upstreams as before — API on 3000 and HFS on 4000 — see [INSTALL — Running behind nginx](https://github.com/pryv/open-pryv.io/blob/master/INSTALL.md#running--behind-nginx). Extra items to remember in multi-core:

1. **HFS Host header** — keep `proxy_set_header Host 127.0.0.1:4000;` for the HFS locations.
2. **Socket.IO** — WebSocket-only upgrade handling for `/socket.io/`. In cluster mode the core refuses HTTP long-polling.
3. **Upload size** — `client_max_body_size` matches `uploads.maxSizeMb`.
4. **Raft port (4002)** — not through nginx; a straight TCP path between cores.


## Rollback

If something goes wrong, you can revert to single-core without losing data:

1. Stop the second core.
2. Put the first core's config back to `dnsLess.isActive: true` with its previous `dnsLess.publicUrl`, and remove `core.id` / `dns.domain`.
3. Restart — the embedded rqlited runs as a standalone node again with the same platform data.

**No data migration in either direction** — rqlite is authoritative throughout and base storage was never shared, so user data stays where it already is.

If you were running on Pryv.io v1 and still need the legacy procedure, it is archived as the [v1 register migration reference](/customer-resources/register-migration/). None of the v1 steps apply to a v2 install.
