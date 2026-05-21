---
id: privacy-by-design
title: 'Privacy by design and by default with Pryv.io'
layout: default.pug
customer: true
withTOC: true
---

## Table of contents <!-- omit in toc -->
<!-- no toc -->
1. [Why a developer should care](#why-a-developer-should-care)
2. [Glossary](#glossary)
3. [Pryv's architecture is privacy-by-design](#pryvs-architecture-is-privacy-by-design)
4. [The data model: subject + context segregation](#the-data-model-subject--context-segregation)
5. [Privacy-by-default UI pattern](#privacy-by-default-ui-pattern)
6. [Twelve platform defaults that satisfy Art.25(2)](#twelve-platform-defaults-that-satisfy-art252)
7. [Still in the implementer's hands](#still-in-the-implementers-hands)
8. [Privacy-enhancing technologies](#privacy-enhancing-technologies)
9. [References](#references)

## Why a developer should care

Personal data has shifted from a **data asset** to a **data
debt**. Organisations collected vast amounts of personal data
over the past decade; regulations and user expectations have
caught up; established data-governance practices became
outdated. The FADP (Swiss Federal Act on Data Protection) and
the GDPR require any organisation handling personal data to be
able to answer, on demand:

- *"Send me a copy of all my records, including personal data."*
- *"Tell me what data you have about me."*
- *"Tell me who has or had access to my data. When. What for."*
- *"Prove that you have my consent to collect it."*
- *"I want to modify who can access my data at any time."*
- *"Delete all or part of my personal data, including in backups."*

These obligations land on developers and IT engineering, not
just on legal and compliance teams. And **developers are not
lawyers**. The platform you build on either makes these answers
easy to produce — or it doesn't.

Pryv.io was designed from the ground up so that **the platform
answers most of these questions for you, by construction**. This
guide walks through what that means in practice.

## Glossary

- **Data Subject**: the individual the personal data relates to.
- **Data Controller**: the organisation that determines the
  purposes and means of processing personal data.
- **Data Processor**: the organisation that processes personal
  data on behalf of the data controller.
- **Processing register** (Art.30): a record of general
  information on the type of personal data you process and to
  what end.
- **Subcontractor agreement** (Art.28): defines the conditions
  under which a data processor undertakes to carry out personal
  data processing on behalf of a data controller.

The official text of the regulations is the authoritative
source — see [GDPR.eu](https://gdpr.eu) and the
[Swiss Federal Act on Data Protection](https://www.fedlex.admin.ch/eli/cc/2022/491/en).

## Pryv's architecture is privacy-by-design

GDPR Art.25(1) requires controllers to **integrate
data-protection principles** at the time the means for
processing are determined. Most platforms retrofit privacy
controls onto an existing architecture; Pryv's architecture is
built around them from the start.

### The standard pattern (privacy anti-pattern)

```
Processes ──direct access──► Personal Data
              │
              ▼
         Audit / Logs (after-the-fact, manual)
```

- Processes have direct access to personal data.
- Per-resource access is not tracked — audit is procedural and
  retroactive.
- The process registry is maintained manually; it drifts;
  when an auditor asks "show me your Art.30 register" the
  operator runs a spreadsheet exercise.

### Pryv's privacy-by-design pattern

```
       Data Governance
              │
              ▼
Processes ─►Access Control ─►Personal Data
              │
              ▼
   Audit / Logs per-Data-Subject (invariant, automatic)
```

- Access Control is a **separate layer** that every process
  call traverses. No process talks directly to storage; every
  request resolves through an Access object (a token granting
  specific permissions on specific streams).
- Governance is applied **per-process AND per-data-subject** —
  every access on every subject's account carries its own
  permission scope, its own audit trail, its own version
  chain.
- The **process registry is self-documented**: `GET /accesses`
  + the audit log together IS the Art.30 records-of-processing
  register, derivable on demand. No spreadsheet exercise.

This isn't a recommended deployment pattern — it's what the
platform ships.

## The data model: subject + context segregation

### Standard relational model (privacy anti-pattern)

```
[Customer] ─► [Account] ─► [Service-Record]
    │              │              │
    ▼              ▼              ▼
   PII          billing          health
```

- One schema organised for **processing purposes** (customer
  table, account table, service-record table).
- Not related to the **data subject's understanding** — "which
  rows in the customer table are mine?" doesn't have a clean
  answer.
- Access enforcement is difficult to track per-record.
- Consent text becomes a wall-of-text privacy policy that very
  few users read.

### Pryv's streams + events model

Data is segregated by **data subject AND context**:

- Every event belongs to one subject's account.
- Events are organised in **streams** representing context —
  `health/vitals/temperature`, `health/sleep`, `diary/notes`,
  `nutrition/meals`, etc.
- Each access permission targets a specific stream (or subtree)
  — `{ streamId: "health", level: "read" }` grants read access
  to everything under `health/*` and nothing else.
- The subject sees explicit grants when accepting an
  application:

> *App "Personal Log Book" requests:*
> *— Edit "Nutrition"*
> *— Edit "Diary"*
> *— Read "Advices"*
>
> [Accept] [Refuse]

instead of a wall of legalese.

This segregation is the structural substrate for:

- **Granular consent** (Art.7) — each requested permission is
  separately presentable + acceptable.
- **Data minimisation** (Art.5(1)(c)) — the application reads
  exactly what its grant covers, nothing else.
- **Portability** (Art.20) — per-stream-subtree export is a
  natural operation.
- **Erasure** (Art.17) — per-stream-subtree deletion is too.
- **Adapt data collection** per subject without schema
  migration — adding a new context = adding a new stream.

And the data is still usable by machines — events carry a
structured `type: class/format` JSON Schema; analytics + ML
pipelines consume them just like any tabular store.

## Privacy-by-default UI pattern

GDPR Art.25(2) requires that **by default, only personal data
necessary for each specific purpose are processed**.

### Standard "by continuing" pattern (anti-pattern)

> *"This site uses cookies to provide you with an optimal
> browsing experience. By continuing to visit this site, you
> agree to the use of these cookies."*

Privacy is **opt-out**: the user must navigate to preferences
to **deactivate** processing they didn't actively choose.

### Privacy-by-default pattern (what Pryv enables)

> *"By default, non-necessary cookies are deactivated. You can
> help us improving our website by activating analytics
> cookies."*
>
> [ACTIVATE] [CONTINUE]

Privacy is **opt-in**: the user must explicitly **activate**
the processing categories they want to enable. The reference
auth flow shipped with Pryv — `app-web-auth3` — implements
this pattern by default:

- The auth screen surfaces the requested permissions
  explicitly, per stream + per level (read / write /
  contribute / manage).
- Accept and Refuse buttons are visually balanced.
- The granted permissions are stored on the access — auditable
  + revocable at any time via `DELETE /accesses/:id`.

The auth UI primitive doesn't support the anti-pattern; you
can't accidentally ship a "by continuing you agree" flow even
if you wanted to. Privacy-by-default **raises the level of
trust** with your users, which translates into material
business advantage — more sign-ups, better retention, more
willingness to share data.

## Twelve platform defaults that satisfy Art.25(2)

When an auditor asks "show me what's privacy-protective by
default", point at this catalogue:

1. **Default-deny on permissions.** Every access starts with
   empty `permissions: []`. The implementer EXPLICITLY grants
   scope; nothing is read by default.
2. **Audit-on by default.** The audit primitive is invariant —
   no config flag turns it off. Every API call against every
   subject's account is captured at write time.
3. **TLS enforced.** Let's Encrypt integration makes HTTPS the
   default. HTTP-only is a deliberate dev-mode opt-in.
4. **Hosting region pinned per user.** Once a subject is
   assigned to a core (`user-core` mapping in PlatformDB), all
   their event data lives on that core exclusively. Residency
   is architectural, not configurable per event.
5. **Stream-permission granularity.** Permissions are per-
   stream-subtree. There's no "public" permission tier;
   sensitive data can't be accidentally exposed to a "world-
   readable" surface that doesn't exist.
6. **Data-minimal audit.** The audit log captures method +
   access reference + URL query + integrity hash; **never the
   request body**. Audit storage is safe to retain at long
   horizons because it contains no event content.
7. **Schema validation at ingest.** Every event is validated
   against the declared event type's JSON Schema (`ajv-draft-
   04`) on `create` AND `update`. Out-of-shape or out-of-range
   payloads are rejected with HTTP 400.
8. **Zero mandatory subprocessors.** Default deployment talks
   to zero third-party services beyond your chosen cloud
   provider. SMTP, SMS, observability, Let's Encrypt — every
   integration is opt-in.
9. **Audit-minimal logger.** Every log call passes through a
   credential-redaction layer that strips `auth=...` tokens
   and `password` / `passwordHash` fields. Verified by the
   `[BIH1-6]` test set. Credentials don't leak via logs to
   external aggregators.
10. **Cross-account sharing requires explicit subject
    consent.** Pryv's CMC primitive requires the subject to
    write a `consent/accept-cmc` event before any cross-
    account data flow begins.
11. **Operator secrets encrypted at rest.** Let's Encrypt
    account keys, observability license keys, SMTP credentials
    (when migrated to PlatformDB) are AES-256-GCM encrypted
    with HKDF-derived keys.
12. **Withdrawal API exists by default.** `DELETE /accesses/:id`
    is always available; a subject holding their personal
    token can revoke any access without third-party
    participation.

## Still in the implementer's hands

The defaults above are **structural** — Pryv enforces them.
But Art.25(2) also has axes the platform can't decide for you:

- Are app tokens minted with the **smallest possible scope**?
  Pryv lets you grant any scope; choosing the smallest is your
  editorial discipline.
- Is your subject's **notice-of-collection presented by
  default**? The consent text + the access's `clientData`
  conventions ([Consent implementation guide](consent.html))
  give you the durable, audit-traceable record; what the
  notice SAYS is yours to write.
- Is **data retention set to the shortest necessary period**?
  Pryv doesn't enforce retention; your operational pruning
  pipeline does.
- Is your custom auth UI using the **opt-in pattern** rather
  than the "by continuing you agree" anti-pattern? If you
  rebrand `app-web-auth3`, the default pattern is opt-in;
  custom UI is your responsibility to align.

## Privacy-enhancing technologies

Cryptography-based PETs you can layer on Pryv's substrate:

| Technology | What it enables | Status on Pryv |
|---|---|---|
| **Pseudonymisation** | PII fields replaced by artificial identifiers before analysis / sharing. | Partial — accesses + streams provide structural pseudonymisation; `auth.randomAlias` (planned) will add a native randomised-alias primitive. |
| **Proxy re-encryption** | Data is encrypted per segment with the data subject's public keys; the backend re-crypts for accredited recipients on demand. Defends against full-dataset breach. | Planned; proof of concept at [github.com/perki/test-proxy-re-encrypt](https://github.com/perki/test-proxy-re-encrypt). |
| **Multiparty computation / Federated learning** | Multiple parties compute over their private inputs without revealing them. | Out-of-scope at platform layer; implementer-side analytics layer. |
| **Homomorphic encryption** | Computations performed on encrypted data without decrypting. | Out-of-scope at platform layer; implementer-side layer. |
| **Differential privacy** | Adds calibrated noise to statistical releases so individual data points cannot be re-identified. | Out-of-scope at platform layer; implementer-side analytics layer. |

The choice of which PETs to layer on is yours — Pryv's
architecture doesn't preclude any of them.

## References

- [GDPR full text — gdpr.eu](https://gdpr.eu)
- [Swiss Federal Act on Data Protection — fedlex.admin.ch](https://www.fedlex.admin.ch/eli/cc/2022/491/en)
- [Article 25 — Data protection by design and by default](https://gdpr.eu/article-25-data-protection-by-design)
- [Consent implementation with Pryv.io](/guides/consent.html) — companion guide.
- [Audit logs in Pryv.io](/guides/audit-logs.html) — companion guide.
- [Cross-account messaging with Pryv.io](/guides/cross-account-messaging.html) — CMC consent flow.
- [App guidelines](/guides/app-guidelines.html) — implementer-facing patterns.
- [Article 29 Working Party Opinion 05/2014 on Anonymisation Techniques](https://ec.europa.eu/justice/article-29/documentation/opinion-recommendation/files/2014/wp216_en.pdf) — distinguishes pseudonymisation from anonymisation; relevant for the PET catalogue.
