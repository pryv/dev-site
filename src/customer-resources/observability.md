---
id: observability
title: 'Observability (APM)'
layout: default.pug
customer: true
withTOC: true
---

Open Pryv.io v2 ships an **optional** observability layer that forwards HTTP transactions, datastore calls, and error reports to a third-party Application Performance Monitoring (APM) provider. It is **off by default**; when enabled it activates a provider-agnostic instrumentation façade with a single concrete provider today: **New Relic**.

The façade is designed so additional providers (Datadog, OpenTelemetry, Sentry…) can be dropped in later without changes to core business code; new providers land as separate plans.

> **Data handling note** — enabling observability means the operator has decided it is acceptable to ship request metadata (paths, status codes, timings, external host URLs) to the provider's cloud. Request bodies, authorisation headers and cookies are **never** forwarded (high-security mode is hard-coded on).

## Table of contents <!-- omit in toc -->

1. [Overview](#overview)
2. [Enabling New Relic on a cluster](#enabling-new-relic-on-a-cluster)
3. [Log-level tuning](#log-level-tuning)
4. [Hostname labelling](#hostname-labelling)
5. [Rotating the license key](#rotating-the-license-key)
6. [Disabling](#disabling)
7. [Validation queries (NRQL)](#validation-queries-nrql)
8. [Caveats](#caveats)
9. [Adding a new provider later](#adding-a-new-provider-later)

## Overview

- **Opt-in**: a cluster with no observability config has no APM code paths loaded and no runtime cost.
- **Cluster-wide config**: license key + app name + log level live in the cluster's PlatformDB. Rotating the key is a single write; no per-core YAML edit + rsync required.
- **Secrets at rest**: the license key is AES-256-GCM encrypted in PlatformDB, with a key derived (via HKDF-SHA256) from `auth.adminAccessKey` and a per-key purpose label.
- **High-security mode**: enforced on the underlying agent. Request bodies and auth/cookie headers are stripped.
- **Default log forwarding**: errors only. Operators explicitly raise verbosity when they want warnings / info / debug to ship.
- **Hostname reporting**: transactions report under the core's FQDN (parsed from `core.url`) — the same label operators see in `/reg/hostings`, the LE cert SAN, and the core's dashboards.

## Enabling New Relic on a cluster

Prerequisites:

- A New Relic **Ingest – License** key (40-char hex). Get it at **Administration → API keys → Ingest License** in the New Relic web console.
- `auth.adminAccessKey` must be set and identical across every core in the cluster (operator-sync secret; same requirement as `letsEncrypt.atRestKey`).

On any core in the cluster, set the license key and enable the provider:

```bash
node bin/observability.js newrelic set-license-key <LICENSE_KEY>
node bin/observability.js enable newrelic
```

Then perform a rolling restart of every core (one at a time, wait until healthy before restarting the next). The agent loads the license key once per process at `require()` time, so an in-place config change on a running core is a no-op until that core restarts.

Verify:

```bash
node bin/observability.js show
```

```
enabled:          true
provider:         newrelic
appName:          open-pryv.io (pryv.me)
logLevel:         error
hostname:         core-use1.pryv.me
newrelic licenseKey set: yes
```

## Log-level tuning

Default is **error-only**: only `logger.error()` calls reach the provider. `info` / `warn` / `debug` are captured by the usual boiler file + console logs.

Raise verbosity during active debugging:

```bash
node bin/observability.js set-log-level warn    # errors + warnings
node bin/observability.js set-log-level info    # errors + warnings + info
```

Followed by a rolling restart. Higher log levels cost more New Relic events and ship lower-signal chatter; revert to `error` when the incident is closed.

## Hostname labelling

Transactions, infrastructure rows and external segments are labelled with the core's FQDN, taken from `new URL(core.url).hostname`. For a typical multi-core deployment that means New Relic shows:

- `core-use1.pryv.me`
- `core-euc1.pryv.me`

…matching the values operators already see in `/reg/hostings` and in LE certs. No separate "APM host name" field to curate.

Single-core / DNSless deployments fall back to `single.<dns.domain>` when `core.url` is not set.

## Rotating the license key

```bash
node bin/observability.js newrelic set-license-key <NEW_KEY>
```

Then a rolling restart of every core. The key is stored AES-256-GCM encrypted in PlatformDB; the CLI's `show` command never echoes it.

## Disabling

Two ways:

1. **Cluster-wide, via PlatformDB (recommended)**:
   ```bash
   node bin/observability.js disable
   ```
   Then rolling restart.

2. **Local kill-switch (emergency)**: set `observability.enabled: false` in that core's `override-config.yml`. The local override always wins over PlatformDB — useful when one core is misbehaving and you need to silence it immediately without touching cluster state. Restart the affected core only.

## Validation queries (NRQL)

Useful queries to paste in the New Relic web console after enabling on a staging cluster:

```sql
-- Are my cores showing transactions?
SELECT count(*) FROM Transaction WHERE host LIKE 'core-%.pryv.me' FACET host SINCE 10 minutes ago

-- Is sensitive data being stripped?
SELECT count(*) FROM Transaction WHERE request.headers.authorization IS NOT NULL SINCE 1 hour ago
-- Expected: 0 (high-security mode strips the header)

-- Log forwarding at the current log level
SELECT count(*) FROM PryvLog FACET level SINCE 30 minutes ago

-- External call latency (cross-core forwards, rqlite, ACME, etc.)
SELECT average(duration) FROM ExternalService FACET externalHostname SINCE 1 hour ago
```

## Caveats

- **Agent startup cost**: enabling observability adds ~150–300 ms to each Node process's boot. In `NODE_ENV=test` the boot shim bypasses the agent entirely so test suites are unaffected.
- **Optional dependency**: the `newrelic` package is listed under `optionalDependencies` — installs that can't fetch it still succeed; observability simply refuses to activate.
- **No zero-downtime key rotation**: the agent reads the license key once at `require()` time. Rolling restart is required for rotation.
- **License scope**: the image does not bundle any New Relic license key. Operators bring their own.
- **Third-party processing**: understand your jurisdiction's requirements before shipping transaction metadata to New Relic's US or EU cloud. GDPR / HIPAA operators should double-check.

## Adding a new provider later

The façade at `components/business/src/observability/` exposes a fixed method set: `isActive()`, `setTransactionName()`, `recordError()`, `recordCustomEvent()`, `startBackgroundTransaction()`.

A new provider is a sibling directory under `components/business/src/observability/providers/<id>/` exporting:
- `boot.js` — `require()`s the vendor agent and calls `observability.init(adapter)`.
- `adapter.js` — object implementing the five façade methods, delegating to the agent.

The boot shim at `bin/_observability-boot.js` dispatches based on `PRYV_OBSERVABILITY_PROVIDER`. No change to business code, CLI base, or PlatformDB shape is required when adding a provider.
