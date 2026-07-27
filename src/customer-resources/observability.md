---
id: observability
title: 'Observability (APM)'
layout: default.pug
customer: true
withTOC: true
---

Open Pryv.io v2 ships an **optional** observability layer that forwards HTTP transactions, datastore calls, and error reports to a third-party Application Performance Monitoring (APM) provider. It is **off by default**; when enabled it activates a provider-agnostic instrumentation façade with a single concrete provider today: **New Relic**.

The façade is designed so additional providers (Datadog, OpenTelemetry, Sentry…) can be dropped in later without changes to core business code; new providers land as separate plans.

> **Data handling note.** Enabling observability means the operator has decided it is acceptable to ship performance metadata to the provider's cloud. What is and is not forwarded is listed under [What the provider receives](#what-the-provider-receives), and the short version is that route shape and timings are sent while identifiers are not. Read that section before enabling this on a deployment holding personal data: you own the decision, and it is a processing arrangement with a third party.

## Table of contents <!-- omit in toc -->

1. [Overview](#overview)
2. [What the provider receives](#what-the-provider-receives)
3. [Enabling New Relic on a cluster](#enabling-new-relic-on-a-cluster)
4. [Application logs](#application-logs)
5. [High-security mode (optional)](#high-security-mode-optional)
6. [Log-level tuning](#log-level-tuning)
7. [Hostname labelling](#hostname-labelling)
8. [Rotating the license key](#rotating-the-license-key)
9. [Disabling](#disabling)
10. [Validation queries (NRQL)](#validation-queries-nrql)
11. [Caveats](#caveats)
12. [Adding a new provider later](#adding-a-new-provider-later)

## Overview

- **Opt-in**: a cluster with no observability config has no APM code paths loaded and no runtime cost.
- **Cluster-wide config**: license key + app name + log level live in the cluster's PlatformDB. Rotating the key is a single write; no per-core YAML edit + rsync required.
- **Secrets at rest**: the license key is AES-256-GCM encrypted in PlatformDB, with a key derived (via HKDF-SHA256) from `auth.adminAccessKey` and a per-key purpose label.
- **Identifiers are not forwarded**: request URLs, query and route parameters, request bodies, and the `Authorization`, `Cookie`, `Host` and `Referer` headers are all excluded, and outbound paths in span names are obfuscated. See [What the provider receives](#what-the-provider-receives). This is hard-coded, not a setting you can loosen without editing source.
- **High-security mode**: available but **off by default**, because it is an irreversible account-side setting and the agent refuses to connect when the client and account disagree. The exclusions above do not depend on it. See [High-security mode](#high-security-mode-optional).
- **Application log forwarding**: **off by default**. Log messages are not scrubbed for identifiers, so they are not sent unless you opt in. See [Application logs](#application-logs).
- **Hostname reporting**: transactions report under the core's FQDN (parsed from `core.url`) — the same label operators see in `/reg/hostings`, the LE cert SAN, and the core's dashboards.

## What the provider receives

If a reviewer, a DPO or a customer asks "what does your monitoring vendor see?", this is the answer. The authoritative source is the agent configuration shipped at `components/business/src/observability/providers/newrelic/`, and its values are pinned by tests so they cannot be loosened unnoticed.

**Sent**

- Transaction names in **route-pattern form**, for example `GET /:username/events/:id`. Never the filled-in values, and an unmatched request is recorded as `(not found)` rather than as its raw path.
- HTTP status codes, durations, throughput and error counts.
- The core's own FQDN as the reporting host.
- Datastore call timings, and external call timings with the **path fully masked**.
- The `Accept`, `Content-Type` and `Content-Length` request headers, which describe the shape of a request rather than who made it.

**Not sent**

- **Request URLs**, in any attribute (`request.uri`, `http.url`) or trace field. On this API a path carries the username, event ids and attachment ids.
- **Query and route parameters.** This matters twice over: a route parameter would otherwise carry the username as an attribute in its own right, and a credential passed as `?auth=` or `?readToken=` would otherwise be re-emitted as a span attribute when a request is forwarded between cores.
- **The `Host` and `Referer` headers.** In a DNS-ful deployment `Host` carries the username as a subdomain.
- **Request bodies**, so no event content or account data.
- **`Authorization`, `Cookie`, `Proxy-Authorization`, `Set-Cookie` and `X-*` headers**, so no tokens.
- **The `User-Agent` header.** It identifies nobody on its own, but it contributes to fingerprinting, so it is excluded too.
- **SQL statement text.**
- **Error message text.** Messages on captured errors are redacted by the agent, because the platform's own validation errors can quote client-supplied values (an unknown-referenced-streams error names the stream ids it rejected, for example) and an extension can put anything in a message. Error class, stack location, route and timing still reach you.
- **Application log messages**, unless you opt in: see [Application logs](#application-logs).

**Outbound paths are masked entirely.** Attribute exclusion cannot reach the *name* of an external call segment, and those names embed the outbound path, so the whole path is replaced: `/alice/events/c1a2b3.../report-jane-doe.pdf` becomes `*`. An earlier version masked only recognisable identifier shapes (leading segment, record-style ids, query strings) and leaked the rest, including attachment filenames, user-chosen stream ids, and webhook path segments. Enumerating every shape a caller might use is not winnable, so nothing in a path is treated as safe. **What this costs you:** external calls no longer break down per route in the provider UI. Your own routes are unaffected, since transaction names are route patterns.

**The residual, stated plainly: outbound HOST names.** Path masking does not touch hosts, and no agent setting changes that. Calls the core makes are visible by host, which for internal traffic means your own core FQDNs, and for **webhooks means the endpoint hostname the app registered**. If a webhook host is itself identifying, that host reaches the provider. There is no client-side lever for it: the options are not to enable observability on deployments where webhook hostnames are sensitive, or to accept it.

**Correlating back.** Because URLs are not sent, a slow or failing transaction in the provider's UI shows the route, host, status and timing, but not the exact request. Match it against your own audit log by timestamp, route and core: that log stays on your infrastructure, under your control.

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
newrelic highSecurity:   false
```

`show` also prints a summary of what is and is not sent to the provider, so you can answer that question from a shell without reading source.

## Application logs

The provider's agent auto-instruments the logging library and can forward log **records, including their message text**. That is a different channel from the attribute filtering described above: attribute exclusion does not apply to a log message, and the platform's own log redaction covers credential-shaped values, not identifiers such as usernames or record ids.

Because of that, **log forwarding ships off**. Set it on the service process, not in the platform database, since the agent reads it at start-up:

```bash
# in the unit file / process environment, then restart the core
NEW_RELIC_APPLICATION_LOGGING_FORWARDING_ENABLED=true
```

Turn it on only if you accept that whatever your log lines contain will reach the provider. Log-derived *metrics* (counts per level) remain enabled either way, because they carry no message content.

## High-security mode (optional)

The provider offers a High Security Mode that enforces restrictions agent-side. It is **off by default here**, and the scrubbing described above does not depend on it.

Two reasons for the default. First, it is an **account-side** setting: if the client enables it while the account has not, the agent refuses to connect and reports nothing at all, which is a silent monitoring outage. Second, enabling it on the account is **irreversible without provider support**.

If your account has it and you want it:

```bash
# 1. enable High Security Mode on the New Relic ACCOUNT first
# 2. then, on any core:
node bin/observability.js newrelic set-high-security true
# 3. rolling restart every core
```

Be aware it also strips exception messages, disables custom events and custom attributes, forces query obfuscation, and disables application log forwarding.

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

Paste these in the New Relic web console after enabling. The first group proves telemetry is arriving; the second proves the scrubbing works, and is worth keeping as a periodic check.

Scope every query to your own app (`WHERE appName = '<your appName>'`) if the account also receives data from other deployments, and bound it with `SINCE '<time you deployed>'` if the account still holds older data collected under a looser configuration. Otherwise a zero can be a false pass.

```sql
-- 1. Are my cores reporting, under their FQDNs?
--    Facet on host.displayName, not host: `host` is the machine's own
--    hostname (an EC2 instance name, for example), while displayName is the
--    core FQDN this platform reports.
SELECT count(*) FROM Transaction FACET host.displayName SINCE 10 minutes ago

-- 2. Are transaction names route-shaped rather than raw paths?
--    Expected: names like WebTransaction/Expressjs/GET//:username/events
--    and "(not found)" for unmatched requests. No usernames or ids.
SELECT uniques(name) FROM Transaction SINCE 1 hour ago LIMIT MAX

-- 3. External call latency (cross-core forwards, rqlite, ACME, ...)
SELECT average(duration) FROM Span WHERE span.kind = 'client' FACET name SINCE 1 hour ago
```

Scrubbing checks. **Every one of these must return 0.** A non-zero result means the deployment is sending more than this page describes, and is worth investigating before it accumulates:

```sql
-- No credentials, ever
SELECT count(*) FROM Transaction WHERE request.headers.authorization IS NOT NULL SINCE 1 hour ago

-- No request URLs, on transactions, errors or spans
SELECT count(*) FROM Transaction WHERE request.uri IS NOT NULL SINCE 1 hour ago
SELECT count(*) FROM TransactionError WHERE request.uri IS NOT NULL SINCE 1 hour ago
SELECT count(*) FROM Span WHERE http.url IS NOT NULL OR request.uri IS NOT NULL SINCE 1 hour ago

-- No identifying headers
SELECT count(*) FROM Transaction WHERE request.headers.host IS NOT NULL OR request.headers.referer IS NOT NULL SINCE 1 hour ago

-- No application log records, unless you opted in
SELECT count(*) FROM Log SINCE 1 hour ago
```

A stronger check, if you have a test account on the deployment: exercise it, then search for its username across every event type. Expect 0.

```sql
SELECT count(*) FROM Transaction, TransactionError, Span, Log
WHERE name LIKE '%<test-username>%' OR request.uri LIKE '%<test-username>%'
   OR http.url LIKE '%<test-username>%' OR message LIKE '%<test-username>%'
SINCE 1 hour ago
```

An attribute inventory is also useful, since it shows what the provider holds rather than what you expected it to hold:

```sql
SELECT keyset() FROM Transaction SINCE 1 hour ago
SELECT keyset() FROM Span SINCE 1 hour ago
```

Expect no key named `request.uri` or `http.url`, none beginning `request.parameters.`, and no `request.headers.host` or `request.headers.referer`.

## Caveats

- **Agent startup cost**: enabling observability adds ~150–300 ms to each Node process's boot. In `NODE_ENV=test` the boot shim bypasses the agent entirely so test suites are unaffected.
- **Optional dependency**: the `newrelic` package is listed under `optionalDependencies` — installs that can't fetch it still succeed; observability simply refuses to activate.
- **No zero-downtime key rotation**: the agent reads the license key once at `require()` time. Rolling restart is required for rotation.
- **License scope**: the image does not bundle any New Relic license key. Operators bring their own.
- **Third-party processing**: understand your jurisdiction's requirements before shipping performance metadata to New Relic's US or EU cloud. GDPR / HIPAA operators should double-check, and should read [What the provider receives](#what-the-provider-receives) rather than assuming either the best or the worst.
- **Ingested telemetry cannot be deleted on demand**: the provider has no self-service purge. Data expires with your account's retention window, and earlier removal requires a support request. Worth knowing before enabling this on a deployment holding personal data, because a misconfiguration cannot be taken back.
- **Custom adapters own their own filtering**: the façade does not enforce these exclusions across providers. Everything on this page describes the New Relic adapter. If you write or install another adapter, the equivalence check is yours.

## Adding a new provider later

The façade at `components/business/src/observability/` exposes a fixed method set: `isActive()`, `setTransactionName()`, `recordError()`, `recordCustomEvent()`, `startBackgroundTransaction()`.

A new provider is a sibling directory under `components/business/src/observability/providers/<id>/` exporting:
- `boot.js` — `require()`s the vendor agent and calls `observability.init(adapter)`.
- `adapter.js` — object implementing the five façade methods, delegating to the agent.

The boot shim at `bin/_observability-boot.js` dispatches based on `PRYV_OBSERVABILITY_PROVIDER`. No change to business code, CLI base, or PlatformDB shape is required when adding a provider.
