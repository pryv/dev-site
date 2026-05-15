---
id: cross-account-messaging
title: 'Cross-account Messaging & Consent (CMC)'
layout: default.pug
customer: true
withTOC: true
---

This guide describes how to use **CMC** — Pryv.io's built-in protocol for federated, cross-account consent, chat and system notifications. With CMC, two Pryv accounts (which may live on different platforms) can mutually issue and receive data-grants, exchange chat messages, and send system alerts — all on top of standard Pryv events / streams / accesses.

It complements the [Consent request guide](/guides/consent/), which covers the classical single-account consent flow (one app obtaining an access token on one user's account). CMC is what you reach for when consent flows BETWEEN two end-user accounts.

## Table of contents <!-- omit in toc -->
<!-- no toc -->
1. [When to use CMC](#when-to-use-cmc)
2. [Concepts](#concepts)
3. [Streams reserved by the plugin](#streams-reserved-by-the-plugin)
4. [Event types](#event-types)
5. [The handshake — a worked example](#the-handshake-a-worked-example)
6. [Sending chat messages](#sending-chat-messages)
7. [Sending system notifications](#sending-system-notifications)
8. [Revoking](#revoking)
9. [Lib-js helpers](#lib-js-helpers)
10. [Further reading](#further-reading)

## When to use CMC

Use CMC when:

- Two **end-user accounts** need to share data (e.g. a patient grants their doctor read access to selected streams; a study collector receives data from N participants).
- The data flow is **bi-directional** — chat exchanges, system alerts back-and-forth — not just one-shot reads.
- You want **scope changes** (widening / narrowing the data-grant) to be a first-class user action with audit trail.
- The two accounts may be on **different Pryv.io platforms** (federated). The plugin handles the inter-platform HTTPS plumbing for you.

If your use-case is "one app authenticating to one user's account", stick with the standard [access-request flow](/reference/#authenticate-your-app).

## Concepts

A CMC interaction always involves **two parties**:

- **Requester** — the actor asking for consent (e.g. the doctor's app, a study collector, a research institution).
- **Accepter** — the data-owner whose account is being asked.

The handshake creates **two paired accesses**:

- A **data-grant** access on the accepter's account, issued to the requester. Carries the offer's permissions (e.g. `fertility:read`).
- A **back-channel** access on the requester's account, issued to the accepter. Carries delivery rights for chat and system messages flowing in the reverse direction.

Together these two accesses form a **CMC consent**. Either party may revoke at any time.

## Streams reserved by the plugin

The plugin auto-provisions a small reserved namespace on every account on first CMC use:

```
:_cmc:                      reserved root
  :_cmc:inbox               one-shot lifecycle delivery (consent/* events from peers)
  :_cmc:apps                parent of user-creatable app scopes
    :_cmc:apps:<app-code>   user-creatable, one per app
      <user-defined paths>  e.g. :study-A, :campaign-2026
        :chats              auto-created at acceptance time
          :chats:<peer>     one chat thread per peer
        :collectors         auto-created at acceptance time
          :collectors:<peer> one system channel per peer
  :_cmc:_internal           plugin-internal hidden region (capability mint, retry queue)
```

Apps must NEVER write to `:_cmc:_internal:*`. They write to their own `:_cmc:apps:<app-code>:*` streams; the plugin handles everything inside `:_cmc:_internal:*` and `:_cmc:inbox`.

## Event types

CMC types follow the Pryv `<class>/<format>` convention. Implementation formats are suffixed with `-cmc` so the [data-types directory](/event-types/) groups CMC entries together within shared classes.

| Type | When you write it |
|---|---|
| `consent/request-cmc` | Requester writes to start a request. The plugin mints a capability URL. |
| `consent/accept-cmc` | Accepter writes to accept (carries the capability URL from the request). |
| `consent/refuse-cmc` | Accepter writes to refuse. |
| `consent/revoke-cmc` | Either party writes to revoke an established consent. |
| `message/chat-cmc` | Either party writes a chat to their per-peer chat stream. |
| `notification/alert-cmc` | Either party sends a system alert (level + title + body). |
| `notification/ack-cmc` | Acknowledge a previously-received alert. |
| `consent/scope-request-cmc` | Collector proposes a scope change. |
| `consent/scope-update-cmc` | User-side accepts / applies a scope change. |
| `consent/back-channel-cmc` | Plugin-internal handshake step. Apps don't write these. |

`consent/back-channel-cmc` is not app-facing — the plugin emits and consumes it transparently as part of the handshake.

## The handshake — a worked example

Imagine **Alice** (a study participant) wants to grant **Bob** (a research collector) read access to her `fertility` stream, with chat enabled.

**1. Alice creates an app-scope stream.** Once per app:

```js
await aliceConn.api([{ method: 'streams.create', params: {
  id: ':_cmc:apps:my-study', parentId: ':_cmc:apps', name: 'My Study'
}}]);
// Optionally a per-request sub-path for finer-grained scoping:
await aliceConn.api([{ method: 'streams.create', params: {
  id: ':_cmc:apps:my-study:cohort-2026', parentId: ':_cmc:apps:my-study', name: 'Cohort 2026'
}}]);
```

**2. Alice writes the consent request.** This triggers the capability mint:

```js
const res = await aliceConn.api([{ method: 'events.create', params: {
  streamIds: [':_cmc:apps:my-study:cohort-2026'],
  type: 'consent/request-cmc',
  content: {
    to: null,                               // null = open invite via capability URL
    capabilityRequested: true,
    request: {
      title:       { en: 'Cohort 2026 — share fertility data' },
      description: { en: 'Sharing fertility data with the cohort 2026 research team.' },
      consent:     { en: 'I consent to share my fertility data for cohort 2026 research.' },
      permissions: [ { streamId: 'fertility', level: 'read' } ]
    },
    requesterMeta: { username: 'alice', appId: 'my-study' }
  }
}}]);
const triggerId = res[0].event.id;
```

The plugin stamps `content.capabilityUrl` on the trigger event within milliseconds. Alice's app reads it back and shares it with Bob (via email, QR code, etc.).

**3. Bob accepts via the capability URL:**

```js
await bobConn.api([{ method: 'events.create', params: {
  streamIds: [':_cmc:apps:my-study'],   // Bob's local app-scope stream
  type: 'consent/accept-cmc',
  content: { capabilityUrl, accessName: 'cmc-cohort-2026' }
}}]);
```

The plugin on Bob's side:
- reads the offer via the capability,
- mints a **data-grant access** on Bob's account (with `fertility:read` + the chat / system anchor permissions),
- delivers `consent/accept-cmc` back to Alice's `:_cmc:_internal:responses:<capId>` stream.

**4. Alice's side automatically:**
- mints the **back-channel access** for Bob,
- provisions the chat / collectors anchor streams,
- POSTs `consent/back-channel-cmc` to Bob's `:_cmc:inbox` (so Bob's data-grant gets the back-channel apiEndpoint stamped on it),
- mirrors a copy of the accept event onto Alice's own `:_cmc:inbox` so Alice's app sees it.

Alice's app subscribes to `:_cmc:inbox` to be notified:

```js
const aliceConn2 = new pryv.Connection(aliceApiEndpoint);
const monitor = aliceConn2.monitor({ streams: [':_cmc:inbox'] });
monitor.on('event', (event) => {
  if (event.type === 'consent/accept-cmc' && event.content?.from?.username === 'bob') {
    console.log('Bob accepted! Data-grant URL:', event.content.grantedAccess.apiEndpoint);
  }
});
```

After the handshake, both sides have:
- a chat stream `:_cmc:apps:my-study:cohort-2026:chats:<peer-slug>`,
- a system channel `:_cmc:apps:my-study:cohort-2026:collectors:<peer-slug>`,
- the access pair pre-wired for bi-directional delivery.

## Sending chat messages

To chat, write `message/chat-cmc` to your per-peer chat stream:

```js
const peerSlug = pryv.cmc.counterpartySlug({ username: 'bob', host: 'pryv.example' });
const myChatStream = pryv.cmc.chatStreamUnder(':_cmc:apps:my-study:cohort-2026', peerSlug);

await aliceConn.api([{ method: 'events.create', params: {
  streamIds: [myChatStream],
  type: 'message/chat-cmc',
  content: { content: 'Hello from Alice' }
}}]);
```

The plugin delivers the chat to Bob's matching chat stream within ~100ms. Bob's app subscribes to the same stream-id pattern (with Alice's slug) to read incoming chats.

## Sending system notifications

System notifications carry richer structure than chats — a level (info / warning / critical), localised title + body, and optionally an ack-request:

```js
const myCollectorStream = pryv.cmc.collectorStreamUnder(':_cmc:apps:my-study:cohort-2026', peerSlug);

await collectorConn.api([{ method: 'events.create', params: {
  streamIds: [myCollectorStream],
  type: 'notification/alert-cmc',
  content: {
    level: 'warning',
    title: { en: 'Daily survey reminder' },
    body:  { en: 'You haven\'t submitted today\'s survey yet.' },
    code:  'survey-reminder',
    ackRequired: true
  }
}}]);
```

If `ackRequired` is true, the recipient sends a `notification/ack-cmc` back referencing the alert event-id.

## Revoking

Either party can revoke the consent at any time:

```js
await aliceConn.api([{ method: 'events.create', params: {
  streamIds: [':_cmc:apps:my-study:cohort-2026'],
  type: 'consent/revoke-cmc',
  content: {
    accessId: backChannelAccessId,         // the local access being revoked
    reason: { en: 'study complete' }
  }
}}]);
```

The plugin tears down both sides of the access pair. The chat / collectors history is preserved (events are not deleted) but no further messages will be delivered.

## Lib-js helpers

The `pryv` JS library exposes a `pryv.cmc` namespace with pure helpers for stream-id and slug computation:

```js
const pryv = require('pryv');

pryv.cmc.NS;                                     // ':_cmc:'
pryv.cmc.appScope('my-app');                     // ':_cmc:apps:my-app'
pryv.cmc.counterpartySlug({ username: 'bob', host: 'pryv.example' });  // 'bob--pryv-example'
pryv.cmc.chatStreamUnder(':_cmc:apps:my-app:study-A', 'bob--pryv-example');
// → ':_cmc:apps:my-app:study-A:chats:bob--pryv-example'

// Extract { username, host } from an apiEndpoint URL using your service.api template:
const serviceInfo = await pryv.utils.fetchAndAssertServiceInfo(serviceInfoUrl);
const actor = pryv.cmc.extractActor(apiEndpoint, serviceInfo.api);
// → { username: 'alice', host: 'pryv.example' }
```

The full set of helpers + event-type constants are in [`pryv.cmc`](https://github.com/pryv/lib-js/blob/master/components/pryv/src/cmc.js).

## Further reading

- [Implementer's Guide (open-pryv.io)](https://github.com/pryv/open-pryv.io/blob/master/components/cmc/IMPLEMENTERS-GUIDE.md) — the deep-dive reference for app developers integrating CMC.
- [Internals (open-pryv.io)](https://github.com/pryv/open-pryv.io/blob/master/components/cmc/INTERNALS.md) — operator / contributor reference, with full sequence diagrams.
- [Consent request guide](/guides/consent/) — the classical single-account consent flow; pair this guide with that one when designing your data-collection architecture.
- [Event types directory](/event-types/) — the canonical class/format catalogue, including the `consent/*`, `message/chat-cmc`, and `notification/*-cmc` types.
