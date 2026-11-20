# Architecture — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Engineering owner to be assigned  
**Last updated:** 2026-10-25  
**Source of truth for:** System boundaries, data ownership, provider seams,
deployment environments, and operational architecture  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/DISASTER_RECOVERY.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0001-technology-stack.md`, `docs/ADR/0003-rtc-provider.md`,
`docs/ADR/0006-flutter-client.md`,
`reports/chato-deeper-static-analysis.md`,
`reports/chato-plugin-registration.csv`, `reports/chato-install-run-test-plan.md`,
`replica/architecture.md`, `replica/backend.md`

This document describes a fresh implementation of the product requirements. It
uses the authorized clean-room evidence only to identify generic functional
needs. It does not reproduce the analyzed application's source code, private
APIs, package names, credentials, backend, visual identity, or proprietary
media.

---

## 1. Architectural goals

### 1.1 Primary goals

The architecture must:

1. Keep the mobile client untrusted and the backend authoritative.
2. Support discovery, relationships, messaging, one-to-one RTC calls,
   moderation, notifications, and a future virtual economy.
3. Isolate provider SDKs behind application-owned interfaces.
4. Make retries, duplicate requests, delayed webhooks, reconnects, and partial
   failures safe.
5. Keep the first production implementation small enough to operate without a
   large microservice team.
6. Support local seeded data before external credentials are available.
7. Preserve a migration path from the current local-first Android MVP to a
   server-backed product.
8. Make privacy, financial reconciliation, moderation, and auditability first-
   class concerns rather than post-launch additions.

### 1.2 Non-goals

This architecture does not currently approve:

- a specific commercial provider;
- a production price, payout policy, or legal host relationship;
- public group broadcasting or multi-host rooms;
- real-money purchases or host payouts in the local MVP;
- a microservice fleet before measured scale or team boundaries justify it; or
- copying the target application's backend or bundled SDK arrangement.

### 1.3 Architecture principles

- **Server authority:** prices, balances, entitlements, permissions, call
  eligibility, moderation, and settlement are decided on the server.
- **Explicit state:** model call, billing, moderation, purchase, upload, and
  notification states instead of inferring them from button labels or local
  lifecycle callbacks.
- **Idempotent effects:** every operation that creates a business effect has a
  request key, provider event key, or deterministic deduplication rule.
- **Provider isolation:** RTC, authentication, billing, push, storage, and
  email providers are adapters, not the application's domain model.
- **Least privilege:** users, hosts, moderators, support/finance operators, and
  infrastructure administrators have separate permissions.
- **Evidence honesty:** a mock, seeded repository, or provider stub is never
  described as a live integration.
- **Privacy by design:** collect and retain only what the approved feature
  needs, and redact normal logs.
- **Recoverability:** every important failure has a safe retry, recovery,
  support, or manual-reconciliation path.

---

## 2. Current implementation and target architecture

### 2.1 Current workspace implementation

`replica-android/` is an independent Orbitra Android MVP with:

- native Java;
- platform Android Views;
- minimum SDK 24 and target SDK 35 in the current build script;
- seeded local data and in-memory state;
- limited persistence through the local repository/`SharedPreferences` seam;
- a small dependency surface; and
- a debug APK build path that does not claim live video, real payments, global
  discovery, or production moderation.

The current MVP is useful for validating UI states and navigation. It is not a
production backend and must not be connected directly to production data.

### 2.1.1 Evidence-informed constraints — October 25, 2026

The deeper clean-room analysis changes implementation discipline, not the
independent product identity:

- the supplied base APK is an incomplete Flutter split and cannot establish the
  target's Dart route tree, API contracts, ranking rules, billing rules, or
  moderation behavior;
- the recovered Android host is thin, while 53 registered Flutter plugins show
  bundled capability rather than a required provider or product feature;
- a target-specific native device channel and advertising-ID lookup were
  observed statically; neither may be copied into the independent client or
  treated as a core account-identity design;
- the target's provider arrangement, package name, deep-link host, opaque native
  initialization data, and network configuration are evidence only and are not
  architecture selections; and
- runtime validation remains blocked because this host lacks KVM for the x86_64
  AVD and cannot run the arm64 AVD architecture.

Consequences for this architecture:

1. Select providers through application-owned adapters and ADRs; do not infer
   provider choice from bundled SDK presence.
2. Keep the local MVP on fake/seeded adapters and disable advertising-ID,
   fingerprinting, and non-essential telemetry by default.
3. Treat optional effects, recording, Bluetooth routing, background calls,
   translation, and downloads as feature-flagged capabilities requiring device
   evidence before release.
4. Use HTTPS-only transport by default; do not reproduce the target's permissive
   cleartext network configuration.
5. Keep all target-specific identifiers and private integration details out of
   client, backend, tests, and documentation for the independent product.

### 2.2 Target production shape

The recommended first production shape is a **modular monolith backend plus
background workers**, not a collection of independent microservices:

```text
Flutter Android client
    |
    | HTTPS / authenticated API / realtime signaling
    v
API edge and authentication boundary
    |
    v
Application backend (modular domain services)
    |             |              |
    |             |              +--> Provider adapters
    |             |                   auth / RTC / billing / push / storage
    |             |
    |             +--> Queue and scheduled jobs
    |
    +--> Postgres database with row-level ownership policies
    +--> Object storage for approved media
    +--> Cache/rate-limit store where needed
    +--> Audit, metrics, logs, and analytics pipeline

Operations/admin tools
    |
    +--> Moderation and support workflows
    +--> Finance/reconciliation workflows
    +--> Read-only dashboards and audited actions
```

The exact hosting products are open decisions. The existing planning notes
propose managed Postgres/Supabase, a small serverless API, server-issued
LiveKit-style RTC tokens, Google Play Billing, push notifications, and object
storage. Those are reference options, not connected integrations.

### 2.3 Why a modular monolith first

A modular monolith provides:

- one deployable backend and one authorization boundary;
- simpler transactions for relationships, calls, purchases, and ledger writes;
- fewer network failure modes during early development;
- easier local and staging environments; and
- clear internal interfaces that can later be extracted if measured load or
  team ownership requires it.

The code must still separate modules so that billing, moderation, and provider
adapters cannot accidentally become a shared unreviewed utility.

---

## 3. Logical component boundaries

### 3.1 Mobile presentation layer — Flutter client

The new production-oriented mobile client is Flutter/Dart under `flutter_app/`.
The native Java client under `replica-android/` remains the local-first reference
and fallback during migration; it is not the target production client.

Responsibilities:

- render server/local state;
- collect user input;
- explain permissions, pricing, errors, and safety actions;
- manage navigation and accessibility;
- request provider actions through application interfaces; and
- expose loading, empty, offline, retry, blocked, deleted, and unauthorized
  states.

Must not:

- decide final authorization;
- calculate final charges or host payouts;
- mint provider tokens;
- grant entitlements;
- trust local balances or timers as financial truth; or
- include server-role secrets.

### 3.2 Mobile application/domain layer

Responsibilities:

- represent product state and user journeys;
- validate basic input before network submission;
- coordinate repositories and provider adapters through interfaces;
- map backend errors into user-safe states;
- make retry and duplicate-action behavior explicit; and
- expose deterministic state transitions for unit tests.

Examples of application use cases:

```text
LoadDiscovery
ApplyDiscoveryFilter
OpenProfile
ChangeFollowState
StartMatchAttempt
SendMessage
UploadMessageMedia
RequestCall
RespondToCall
JoinCallMedia
EndCall
LoadWallet
StartPurchase
SubmitReport
BlockAccount
RequestAccountDeletion
```

### 3.3 Mobile repository/data layer

Responsibilities:

- call versioned APIs;
- persist safe local session and UI state;
- cache data with expiry and ownership rules;
- queue or reject offline actions according to policy;
- expose provider-independent domain objects; and
- redact sensitive data from local diagnostics.

The repository must distinguish:

- local optimistic state;
- server-accepted state;
- provider state; and
- unresolved/retryable state.

### 3.4 Backend API boundary

Responsibilities:

- authenticate requests;
- authorize every read and write;
- validate types, lengths, enums, ownership, and idempotency keys;
- enforce rate limits and abuse controls;
- invoke domain services;
- return stable error codes and safe messages;
- issue scoped short-lived provider tokens; and
- record audit/reconciliation evidence where required.

The API boundary must not expose stack traces, SQL, private provider payloads,
service credentials, or internal role details.

### 3.5 Domain modules

The initial backend should define explicit modules:

| Module | Owns | Does not own |
| --- | --- | --- |
| Identity and consent | Accounts, sessions, policy consent, account status | Provider secrets or final moderation decisions |
| Profiles and discovery | Profiles, media references, availability, filters, ranking policy | Private messages, balances, or provider tokens |
| Relationships | Follow, favorite, request, block relationships | Host payout state |
| Matching | Match attempts, candidate eligibility, outcomes, tickets if approved | Unapproved ranking rules or direct provider SDK calls |
| Messaging | Conversations, messages, delivery state, message attachments | Store receipt verification or ledger settlement |
| Calls and RTC | Call sessions, call state, provider room/token adapter, call events | Final ledger truth without settlement rules |
| Economy and ledger | Purchases, entitlements, wallet projections, ledger entries, refunds | UI-only balances or provider-specific public models |
| Host earnings and payouts | Earnings states, payout requests, holds, reversals | Moderator enforcement decisions |
| Safety and moderation | Reports, blocks, cases, actions, appeals, audit | Unrelated private data or silent financial edits |
| Notifications | Device registrations, templates, delivery state, deep-link intents | Provider credentials in domain code |
| Support and operations | Tickets, reconciliation exceptions, incident references | Unaudited production data mutation |

### 3.6 Provider adapter boundary

Every provider adapter must:

- have an application-owned interface;
- map provider errors into stable application errors;
- keep secrets on the server or approved platform configuration;
- expose provider IDs only where necessary for reconciliation;
- support timeout, retry, and idempotency behavior; and
- be testable with a fake adapter.

Candidate adapters include:

- authentication provider;
- real-time audio/video provider;
- app-store billing provider;
- push notification provider;
- object storage provider;
- email provider;
- analytics/crash provider; and
- optional content-safety or translation provider.

The clean-room reports list provider SDKs observed in the target artifact only
as capability evidence. They are not approved dependencies for this product.
Any selected provider requires an independent ADR, environment-specific
configuration, server-side credential handling, failure mapping, and tests using
a fake adapter. In particular, no target-specific native method channel,
provider room naming, credential, license payload, or private endpoint may cross
this boundary.

---

## 4. Deployment environments

Each environment must have separate data, provider resources, and secrets.

| Environment | Purpose | Real money | Real user data | Provider rule |
| --- | --- | --- | --- | --- |
| Local | UI/domain development and deterministic tests | No | Seeded/test only | Fake adapters by default |
| Development | Backend integration and team testing | No | Synthetic/test accounts only | Sandbox providers and development projects |
| Staging | Closed beta rehearsal and release validation | Store sandbox only | Approved test accounts | Production-like settings with isolated resources |
| Production | Real users and approved operations | Only after launch approval | Yes, minimized and protected | Production projects, secret manager, monitoring |

### Environment separation requirements

- Separate database and storage namespaces.
- Separate authentication configuration and signing keys.
- Separate RTC projects or namespaces.
- Separate billing sandbox/production configurations.
- Separate push credentials and notification topics.
- Separate analytics and crash-reporting projects where possible.
- Separate service accounts and role grants.
- Block production URLs in local/test builds unless explicitly approved.
- Make environment identity visible in internal builds and admin tools.

---

## 5. Data architecture

### 5.1 Primary database

Use a relational database as the system of record for accounts, profiles,
relationships, conversations, calls, economy, safety cases, and audit records.

Required properties:

- versioned migrations;
- transaction support for multi-row business effects;
- foreign keys and check constraints;
- indexes for ownership, status, cursor pagination, and reconciliation;
- row-level ownership policies where supported;
- UTC timestamps;
- opaque public identifiers;
- soft-delete or retention status where deletion must be auditable; and
- tested backup and restore procedures.

The database schema must be described separately in `docs/DOMAIN_MODEL.md` and
versioned migrations. This architecture document does not replace migrations.

### 5.2 Object storage

Object storage is for approved profile and message media, not arbitrary private
files.

Requirements:

- client uploads use short-lived signed upload instructions;
- server validates ownership, content type, size, dimensions, and status;
- private downloads use short-lived signed URLs or an authenticated proxy;
- filenames are generated by the server and do not contain user-provided paths;
- malware/content-safety scanning is applied where required;
- failed and abandoned uploads are cleaned by an idempotent job;
- retention and deletion are recorded separately from database row deletion; and
- URLs and provider payloads are not written to normal logs.

### 5.3 Cache and rate-limit store

A cache or key-value store may be added for:

- rate-limit counters;
- short-lived sessions or locks;
- availability/presence hints;
- idempotency-key result caching;
- notification deduplication; and
- expensive, non-authoritative feed computations.

The cache must never be the only source of truth for balances, permissions,
settlement, moderation action, or account deletion.

### 5.4 Queue and job system

Use a durable queue or provider-managed job system for retryable work:

- notification delivery;
- media scanning and processing;
- stale call/session expiration;
- purchase and webhook processing;
- ledger reconciliation;
- host earning state transitions;
- account deletion jobs;
- report notifications and escalations;
- analytics export; and
- cleanup of expired media or temporary objects.

Every job must have an idempotency key, retry policy, dead-letter/manual-recovery
path, safe logs, and an owner.

---

## 6. Authentication, authorization, and trust boundaries

### 6.1 Request trust model

The mobile app, device, network, and provider callback payloads are untrusted.
The backend must treat every request as potentially malformed, replayed, stale,
or malicious.

```text
Untrusted mobile/device input
        |
        v
TLS termination -> authentication -> schema validation -> authorization
        |                                      |
        |                                      v
        |                              domain policy checks
        |                                      |
        +-------------------------------> transaction/write
                                               |
                                               v
                                         audit/reconciliation
```

### 6.2 Authentication

The authentication adapter may use an approved managed identity provider or an
independent backend implementation. It must provide:

- short-lived access tokens and refresh/session rotation;
- email verification or equivalent account assurance where required;
- provider cancellation and account-link conflict handling;
- session revocation and device/session management;
- recovery and suspicious-login controls;
- rate limits and abuse detection; and
- clear separation between authentication identity and public profile data.

The client receives only public configuration and user-scoped tokens. Service
roles, database administrator credentials, RTC secrets, billing credentials,
and signing keys remain server-side.

### 6.3 Authorization

Authorization is checked for every read and write using:

- authenticated account ID;
- active account status;
- role and capability;
- target ownership or participant relationship;
- block/suspension/deletion state;
- region, age, verification, and feature eligibility where approved;
- rate and spending limits; and
- current call, purchase, or moderation state.

The client may hide an unavailable action for usability, but the server must
reject the action if the rule does not allow it.

### 6.4 Administrative boundaries

Use separate capability sets for:

- moderation;
- support;
- finance/refunds;
- payouts;
- infrastructure; and
- incident response.

Break-glass access must be time-limited, reason-coded, reviewed, and logged.
No operator should silently alter a financial, moderation, or account record.

---

## 7. API architecture and conventions

### 7.1 API style

Use versioned HTTPS APIs for authoritative commands and queries. A possible
initial shape is:

```text
/v1/auth/*
/v1/me
/v1/profiles
/v1/discovery
/v1/relationships
/v1/matches
/v1/conversations
/v1/messages
/v1/calls
/v1/wallet
/v1/purchases
/v1/reports
/v1/notifications
/v1/support
```

These paths are architecture placeholders, not approved public contracts. The
actual contract belongs in `docs/API_CONTRACT.md` and an executable OpenAPI or
equivalent schema.

### 7.2 Request requirements

Every state-changing request should define:

- authenticated actor;
- target resource and ownership rule;
- validated input schema;
- idempotency key where the operation creates an effect;
- authorization decision;
- transaction boundary;
- response state and stable error codes;
- audit event requirement; and
- retry behavior.

### 7.3 Response requirements

Responses should provide:

- stable machine-readable error code;
- safe user-facing message or message key;
- request/correlation ID for support;
- current server state where useful;
- retryability classification;
- pagination cursor for unbounded lists; and
- no stack trace, SQL, raw provider payload, secret, or private data outside the
  caller's authorization scope.

### 7.4 Error categories

The application should map failures into categories such as:

```text
UNAUTHENTICATED
FORBIDDEN
INVALID_INPUT
NOT_FOUND_OR_UNAVAILABLE
BLOCKED
RATE_LIMITED
CONFLICT_OR_DUPLICATE
INSUFFICIENT_ENTITLEMENT
PROVIDER_UNAVAILABLE
TIMEOUT_RETRYABLE
OFFLINE_RETRYABLE
PURCHASE_PENDING
MODERATION_REVIEW
INTERNAL_RETRYABLE
```

The exact error code list belongs in the API contract. Provider-specific error
strings must not leak through as the public domain model.

### 7.5 Pagination and consistency

- Use cursor pagination for discovery, conversations, messages, notifications,
  reports, and transaction history.
- Return a stable cursor tied to an ordering and filter version.
- Do not rely on client-side sorting for authorization or financial history.
- Use optimistic UI only where the server can safely reject or reconcile it.
- Include freshness or timestamp information for availability and presence.

---

## 8. Realtime and video-call architecture

### 8.1 Separation of responsibilities

The backend owns the application call session. The RTC provider owns media
transport. The client renders both states but owns neither final authorization
nor settlement.

```text
Caller client                    Recipient client
     |                                  |
     | request/accept/end API           |
     +--------------+-------------------+
                    v
            Call domain service
                    |
          eligibility / block / balance
          state / idempotency / audit
                    |
                    +--> issue scoped RTC token
                    |
                    +--> create provider room/session
                    |
                    +--> receive verified callbacks
                    |
                    +--> settlement/reconciliation
```

### 8.2 Call lifecycle

Persist the following application states independently of provider state:

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

Each state transition should record:

- call session ID;
- actor or provider source;
- server timestamp;
- prior and new state;
- idempotency/event key;
- provider reference where necessary; and
- failure category or reason.

### 8.3 RTC token rules

- Tokens are created only by an authorized backend service.
- Tokens are short-lived and scoped to one call/room and participant role.
- Tokens do not grant unrelated rooms or publish/subscribe capabilities.
- Token issuance checks account status, call state, participant identity, and
  provider availability.
- Expired or revoked tokens are handled as recoverable or terminal states.
- Provider secrets never ship in the mobile package.

### 8.4 Media permissions and resources

The client must:

- explain camera/microphone need before requesting permission;
- handle denial, permanent denial, revocation, unavailable hardware, and route
  changes;
- show mute, camera, route, connection, and recording state accurately;
- stop capture when the call ends or authorization is revoked; and
- avoid claiming optional effects or recording until device tests pass.

### 8.5 Reconnect and billing coordination

The RTC provider's reconnect event must not directly settle money. The call
service should combine:

- server call state;
- verified provider events;
- participant heartbeats or connection evidence where approved;
- the documented reconnect grace policy; and
- a single settlement transaction.

If evidence is contradictory, mark the call for reconciliation rather than
silently charging or paying from a client timer.

---

## 9. Messaging and notification architecture

### 9.1 Message write path

```text
Client draft
   |
   v
API authentication/authorization
   |
   v
Block/status/rate/moderation checks
   |
   v
Idempotent message transaction
   |
   +--> persist message and delivery state
   +--> enqueue notification if permitted
   +--> publish realtime update if permitted
   +--> record safe analytics event
```

The message transaction must not depend on a notification provider being
available. A notification failure leaves the message accepted and creates a
retryable delivery job.

### 9.2 Attachments

Attachments use a staged flow:

1. Client asks the backend for an upload instruction.
2. Backend checks conversation membership and upload limits.
3. Client uploads to object storage using a short-lived instruction.
4. Storage or worker scans and validates the object.
5. Backend creates the message attachment reference only after validation.
6. Recipient receives an authorized reference, not an unrestricted object URL.

Failed, abandoned, blocked, or deleted media must have cleanup and retention
behavior.

### 9.3 Notifications

Notifications are generated from application events, not directly from UI
button taps. The notification module must handle:

- device registration and revocation;
- per-user preferences;
- collapse/deduplication keys;
- expiration for calls and time-sensitive events;
- minimal lock-screen content;
- authenticated deep-link intents;
- provider retry and failure; and
- delivery metrics without message bodies or private payloads.

---

## 10. Economy, ledger, and payout architecture

### 10.1 Financial boundary

The economy module is the only module allowed to post financial ledger entries.
Other modules request a financial operation through a typed command.

```text
Call service -> settlement command -> economy/ledger transaction
Billing adapter -> verified purchase event -> fulfillment command
Support/finance -> approved compensating command -> audited ledger transaction
Payout service -> approved payout command -> payout provider + ledger state
```

### 10.2 Monetary model

The current planning assumption is:

```text
User charge:             1,500 paise per billable minute
Host earning assumption:   600 paise per billable minute
Pre-cost contribution:     900 paise per billable minute
```

The architecture does not choose the final billing unit. The economy module must
support a versioned rate/policy record so that historical calls retain the rate
and rules used at settlement time.

### 10.3 Ledger properties

- Entries are append-only.
- Corrections use compensating entries.
- Amounts are integer minor units.
- Currency is explicit on every monetary entry.
- Each business effect has a unique idempotency key.
- Each provider event has a deduplication record.
- Every settlement links to its source call, purchase, refund, or payout.
- Ledger posting and balance projection occur in a transaction or recoverable
  workflow.
- Reconciliation compares internal records with provider records daily or more
  frequently as required.

### 10.4 Purchase flow

```text
Client starts store purchase
        |
        v
Store returns purchase result
        |
        v
Client sends safe purchase reference to backend
        |
        v
Backend verifies receipt with store
        |
        +--> duplicate/already fulfilled -> return existing entitlement
        +--> pending -> keep pending and retry via job/webhook
        +--> valid -> post fulfillment ledger/entitlement
        +--> invalid/revoked -> reject and record safe outcome
```

The mobile callback is never sufficient to grant value.

### 10.5 Host earning and payout flow

```text
Call ends
   |
   v
Server-confirmed settlement
   |
   v
Pending host earning
   |
   +--> refund/chargeback/fraud hold
   |
   +--> policy conditions satisfied -> available
                                  |
                                  v
                           payout request
                                  |
                    eligibility + limits + idempotency
                                  |
                                  v
                           payout provider
                                  |
               paid / failed / held / reversed / disputed
```

The host UI must reflect the server state and never imply guaranteed or
immediately withdrawable money.

---

## 11. Webhooks, jobs, and reconciliation

### 11.1 Webhook processing

Every incoming provider webhook must follow this order:

1. Receive the request over TLS.
2. Verify signature/authentication before trusting the payload.
3. Record a minimal event envelope and provider event ID.
4. Deduplicate already-processed events.
5. Validate event schema and supported event type.
6. Enqueue or execute an idempotent domain command.
7. Commit state and audit/reconciliation result.
8. Return a provider-safe response without exposing internals.

Handle duplicated, delayed, reordered, missing, malformed, and replayed events.

### 11.2 Scheduled jobs

Initial jobs may include:

- expire unanswered or abandoned call requests;
- expire stale RTC sessions;
- retry failed notifications;
- retry pending purchase fulfillment;
- reconcile purchases, refunds, and chargebacks;
- calculate or transition host earning states;
- clean temporary uploads and expired signed references;
- process account deletion steps;
- notify or escalate safety cases;
- refresh safe discovery indexes; and
- produce daily operational and financial reports.

Jobs must be observable, retryable, bounded, and safe to run twice.

### 11.3 Reconciliation

Reconciliation must compare:

- store purchase records versus entitlements and ledger entries;
- refunds/chargebacks versus wallet and host earning reversals;
- RTC/call events versus application call sessions;
- settled calls versus user charges and host earnings;
- payouts versus provider outcomes and internal states; and
- moderation actions versus account status and user-visible restrictions.

Exceptions enter a manual review queue with safe references, not silent data
edits.

---

## 12. Security and privacy architecture

### 12.1 Secrets

- Production secrets live in an approved secret manager or provider dashboard.
- The mobile package contains only public configuration that is safe to recover.
- Local `.env` files, signing keys, service-role keys, RTC secrets, billing
  credentials, access tokens, and cookies are not committed.
- Logs, traces, screenshots, test fixtures, and support notes must not contain
  secrets or unredacted private payloads.
- Secret exposure triggers use cessation, rotation, impact review, and a
  documented incident response.

### 12.2 Network and transport

- Use TLS for all backend and provider communication.
- Validate hostnames, certificates, and provider audiences according to the
  selected platform.
- Do not enable cleartext traffic in production unless a narrowly documented,
  approved exception exists.
- Use request correlation IDs without placing credentials or private messages in
  them.

### 12.3 Data classification

| Classification | Examples | Handling |
| --- | --- | --- |
| Public | Approved display name, public profile media, public availability | User-controlled visibility, moderation, cache rules |
| Private | Messages, call metadata, preferences, support records | Participant/owner authorization, encryption in transit, limited retention |
| Sensitive | Identity documents, payment receipts, payout details, safety evidence | Separate access, minimum retention, audited operators, no normal logs |
| Secret | API keys, signing keys, service-role keys, RTC/billing secrets | Secret manager only; never client, repository, or logs |

### 12.3.1 Device and telemetry minimization

Static analysis of the target found an advertising-ID permission and native
lookup path, plus device-information, attribution, analytics, crash, and
messaging capabilities. The independent architecture does not use those facts
as a data-collection requirement.

- Advertising identifiers and device fingerprints are not core identity fields.
- The local prototype collects no advertising ID and no fingerprinting signal.
- Production telemetry must use an allowlist of event names and minimized
  dimensions, with purpose, consent, retention, access, and deletion documented.
- Device registration stores only the minimum push/session metadata needed for
  the approved feature; raw hardware identifiers and provider tokens are not
  normal domain data.
- Analytics, attribution, crash, and provider logs must not contain message
  bodies, private media URLs, payment payloads, authorization headers, or raw
  device identifiers.
- A telemetry or attribution provider cannot become the source of truth for
  account identity, authorization, billing, moderation, or call settlement.

### 12.4 Account deletion

Account deletion is an orchestrated workflow:

```text
request authenticated deletion
        |
        v
confirm scope and retention exceptions
        |
        v
disable account and revoke sessions
        |
        v
stop discovery/messages/calls/notifications
        |
        v
delete or anonymize user-owned data
        |
        +--> remove provider data where applicable
        +--> retain only documented safety/financial/audit records
        +--> record completion or manual exception
```

The workflow must be retryable, observable, and safe to resume after failure.

### 12.5 Abuse and fraud controls

The architecture should support:

- per-account and per-device rate limits where lawful and necessary;
- message, report, upload, call, purchase, and payout velocity limits;
- suspicious login and account-link detection;
- artificial-minute, self-dealing, collusion, and refund-abuse signals;
- moderation and finance case handoff without exposing internal signals; and
- emergency controls to disable calls, purchases, payouts, or discovery.

Fraud signals are not automatically a final enforcement decision; they should
feed documented review and appeal paths.

---

## 13. Observability and operations

### 13.1 Logging

Application logs should be structured and include:

- timestamp in UTC;
- environment and service/module;
- severity;
- correlation/request ID;
- safe actor category or opaque ID only when necessary;
- operation and outcome;
- latency/duration bucket;
- retryability/failure category; and
- provider or database reference only when safe for reconciliation.

Do not log:

- authorization headers, cookies, access tokens, or secrets;
- message bodies or private media URLs;
- full payment receipts or payout payloads;
- identity documents;
- unnecessary device identifiers;
- raw provider payloads in normal application logs; or
- private moderation evidence outside its controlled system.

### 13.2 Metrics

Minimum operational metrics:

- startup and API error rates;
- authentication success/failure and recovery volume;
- discovery latency, empty results, and pagination failures;
- message accepted, failed, delivered, and notification failure rates;
- call request, acceptance, connection, reconnect, end, and failure rates;
- RTC quality and provider error categories;
- purchase pending, fulfilled, refunded, and reconciliation exceptions;
- wallet/ledger invariant failures;
- host earning and payout exception counts;
- report queue age and moderation time-to-first-review;
- account deletion completion and exception rate; and
- storage, bandwidth, database, queue, and provider cost.

### 13.3 Alerts

Alerts must have severity, owner, runbook, and safe mitigation. Initial alert
families should include:

- crash/startup regression;
- API availability or latency;
- authentication abuse;
- message or notification delivery degradation;
- RTC connection/reconnect degradation;
- purchase or payout reconciliation mismatch;
- ledger invariant failure;
- moderation queue backlog;
- deletion job failure; and
- unexpected cost or traffic spike.

### 13.4 Support and admin tools

Admin tools should be separate from the mobile client and should provide:

- role-based access;
- read-only views by default;
- case-based access to private data;
- reason-required sensitive actions;
- audit history;
- pagination and redaction;
- safe retry/reconciliation actions; and
- no direct database editing as a normal workflow.

---

## 14. Scaling and cost controls

### 14.1 Scaling approach

Start with a single backend deployment that can scale horizontally behind a
load balancer or managed edge. Keep state in managed data services rather than
process memory.

Scale independently when measurements justify it:

- API instances for request volume;
- workers for notifications, media, reconciliation, and deletion;
- database read replicas or indexes for discovery and history;
- object storage/CDN for approved media;
- RTC capacity according to connected participant minutes; and
- moderation/support operations according to queue volume.

Do not add microservices only to make an architecture diagram look complete.

### 14.2 Cost controls

The most important cost drivers are expected to include:

- RTC participant minutes;
- media storage and CDN egress;
- push, email, analytics, and crash-reporting volume;
- database reads/writes and realtime connections;
- moderation and support operations;
- payment/store fees; and
- fraud, refunds, and chargebacks.

Required controls:

- provider quotas and budget alerts;
- maximum media size and retention;
- pagination and cache policies;
- call duration and spend limits;
- disabled or sampled analytics where appropriate;
- staged rollout and feature flags; and
- a kill switch for costly provider paths.

### 14.3 Capacity planning inputs

Capacity estimates must use actual usage, not registrations alone:

- monthly active users;
- percentage of paying users;
- paid minutes per user;
- concurrent calls and peak connection rate;
- messages and attachments per active user;
- storage and download volume;
- report/moderation rate;
- support tickets; and
- purchase/refund/payout event volume.

---

## 15. Backup, disaster recovery, and failure handling

### 15.1 Recovery requirements

The operations documents must define approved RPO/RTO targets. Until approved,
do not claim a recovery guarantee. At minimum:

- database backups are automated and monitored;
- restore is tested on a clean environment;
- object storage deletion/versioning behavior is understood;
- secrets and provider configuration can be recovered or recreated safely;
- migrations have forward-fix/recovery procedures;
- queues have replay/dead-letter handling;
- ledger and purchase reconciliation can reconstruct missing state; and
- incident owners and communication paths are documented.

### 15.2 Failure matrix

| Failure | User behavior | Backend behavior | Operations action |
| --- | --- | --- | --- |
| Auth provider unavailable | Explain unavailable sign-in and retry | Do not create partial account | Monitor provider and support login issues |
| Database read failure | Show cached safe state or retry | Fail closed for protected writes | Restore/fail over according to runbook |
| Database write timeout | Show pending/retry state | Use idempotency and transaction recovery | Check whether effect committed before replay |
| RTC provider unavailable | Calls cannot start; existing calls show provider failure | Do not issue invalid tokens; reconcile existing sessions | Disable new calls if threshold exceeded |
| Push provider failure | In-app refresh remains available | Persist event and retry notification | Monitor queue and provider status |
| Store billing delayed | Show pending purchase | Retry verification; do not double-grant | Reconcile event and support user |
| Duplicate webhook | No visible duplicate value | Deduplicate by provider event ID | Review only if invariant fails |
| Moderation queue outage | Report acknowledgement remains available | Persist case and retry notification | Escalate backlog and use manual path |
| Object storage failure | Upload retry/cancel | Do not create final attachment until validated | Monitor storage and clean temporary objects |
| Account deletion job failure | Show pending status/support path | Retry idempotently and track exception | Manual review for retained data |

### 15.3 Safe shutdown controls

Operations must be able to disable independently:

- new call requests;
- new purchases;
- host payout creation;
- media uploads;
- notifications;
- matching/discovery expansion; and
- selected high-cost providers.

Existing user data and financial records must remain readable and reconcilable
under the safe shutdown mode.

---

## 16. Build and migration plan

### Phase A — Local vertical slice

Keep the current native Android stack and implement deterministic interfaces for:

- account/profile;
- discovery and filters;
- follow relationship;
- matching demo;
- conversation/message state;
- simulated call lifecycle;
- permission education;
- report/block UI; and
- accessibility labels.

Use seeded data and fake adapters. Clearly label all simulated behavior.

### Phase B — Backend foundation

Add:

1. environment configuration and secret boundaries;
2. authentication/session seam;
3. profile and relationship APIs;
4. database migrations and ownership policies;
5. discovery pagination and filters;
6. moderated message write/read path;
7. report/block cases and audit records; and
8. integration tests using at least two accounts.

### Phase C — RTC development integration

Add only after provider selection and privacy/safety review:

- server-issued token endpoint;
- call request/accept/reject/end state;
- provider room adapter;
- permission denial and reconnect behavior;
- server-confirmed call events; and
- call history without production billing.

### Phase D — Economy sandbox

Add:

- policy-versioned rate configuration;
- fake purchase and webhook events;
- append-only ledger;
- entitlement projection;
- call settlement simulation;
- refunds/chargebacks/reversals; and
- reconciliation dashboards.

### Phase E — Closed beta

Add approved store sandbox, host verification, non-production payouts, support,
moderation staffing, crash/RTC/billing monitoring, account deletion, and device
testing.

### Phase F — Production rollout

Enable real-money features only after the release gates in
`docs/PRODUCT_REQUIREMENTS.md`, `docs/PAYMENTS_AND_EARNINGS.md`, and legal and
operations documents are approved.

---

## 17. Architectural decisions and open questions

### Decisions proposed by this document

- Start with a modular monolith and background workers.
- Keep the mobile client untrusted.
- Use a relational database as the system of record.
- Use provider adapters for auth, RTC, billing, push, storage, and email.
- Keep real money and real host payouts disabled in the local MVP.
- Use server-issued RTC tokens.
- Use append-only, policy-versioned financial records.
- Make provider events and business commands idempotent.

### Decisions requiring ADRs

Create an ADR before making these hard-to-reverse decisions:

```text
docs/ADR/0001-technology-stack.md
docs/ADR/0002-payment-ledger.md
docs/ADR/0003-rtc-provider.md
docs/ADR/0004-moderation-model.md
docs/ADR/0005-data-retention.md
docs/ADR/0006-authentication-provider.md
docs/ADR/0007-storage-and-media-processing.md
```

### Open questions

- Which mobile stack will be the long-term production stack: current native
  Java, Kotlin, Flutter, or another approved option?
- Which backend hosting, database, cache, and queue services will be used?
- Which RTC provider satisfies cost, quality, privacy, and geographic needs?
- Which identity providers and account-recovery paths are approved?
- Which payment and payout providers are legally and operationally supported?
- Which countries, currencies, languages, and age restrictions launch first?
- What are the approved call billing and host-earning policies?
- What moderation staffing, response targets, and escalation coverage exist?
- What data retention and deletion commitments apply by data category?

No provider, credential, price, or legal policy is considered approved merely
because it appears in a planning note or static target evidence.

---

## 18. Architecture acceptance checklist

Before implementation is described as production-ready, verify:

- [ ] Product requirements are approved and linked to implementation tickets.
- [ ] Client, domain, API, data, provider, and operations boundaries are clear.
- [ ] Authentication and authorization tests cover at least two accounts.
- [ ] Database migrations, ownership policies, indexes, and backups exist.
- [ ] API contract defines errors, pagination, versioning, and idempotency.
- [ ] RTC provider tokens are server-issued and scoped.
- [ ] Call, reconnect, permission, and settlement states are tested.
- [ ] Purchase, refund, webhook, ledger, and payout flows are sandbox-tested.
- [ ] Report, block, moderation, appeal, and account deletion paths work.
- [ ] Logs, analytics, traces, and support tools are privacy-reviewed.
- [ ] Provider outages, retries, duplicate events, and manual recovery paths are
  documented.
- [ ] Local, development, staging, and production environments are isolated.
- [ ] Monitoring, alerts, backups, restore, and rollback/forward-fix are tested.
- [ ] Real-money and host-payout approvals are recorded before activation.

This checklist is a release gate, not a claim that the current MVP satisfies
it.
