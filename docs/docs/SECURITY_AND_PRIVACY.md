# Security and Privacy — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Security/privacy owner to be assigned; product and legal reviewers required  
**Last updated:** 2026-10-25  
**Source of truth for:** Security controls, privacy-by-design requirements,
data handling, retention, access, deletion, incident response, and release gates  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/DISASTER_RECOVERY.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/COST_MODEL.md`, `docs/ADR/0005-data-retention.md`

This document defines independent security and privacy requirements for the
product. It does not reproduce a target application's security configuration,
private services, package identifiers, provider credentials, device channel,
advertising-ID behavior, or opaque native initialization data.

This document is a product and engineering control plan, not legal advice or a
claim of compliance with a specific law, store policy, or certification. Legal
owners must approve the applicable notices, consent language, contracts,
retention periods, age rules, regional requirements, and user-rights workflows
before production launch.

Security and privacy are release requirements. A passing build, a working UI,
or a provider's default configuration does not prove that the application is
safe to release.

---

## 1. Decision labels and release scope

### 1.1 Decision labels

- **Required:** must be implemented and tested for the stated release.
- **Proposed:** independent design choice awaiting product, engineering,
  security, privacy, or legal approval.
- **Gated:** disabled until the listed policy, provider, legal, and test gates
  are complete.
- **Deferred:** intentionally outside the current release.
- **Unknown:** not established; do not silently invent a behavior.
- **Observed/static:** evidence from the supplied artifact or workspace, not a
  runtime or production security fact.

### 1.2 Current security scope

The first server-backed product must protect:

- account identity, authentication sessions, recovery, and consent;
- public profiles and private profile fields;
- profile, message, report, and support media;
- conversations, messages, delivery state, and call metadata;
- camera, microphone, notification, storage, and network permissions;
- call eligibility, RTC tokens, provider references, and connection events;
- reports, moderation evidence, enforcement actions, and appeals;
- wallet, purchases, receipts, ledger entries, earnings, and payout details when
  those modules are enabled;
- support records, audit records, jobs, webhooks, and operational logs; and
- secrets, signing keys, provider credentials, and infrastructure access.

### 1.3 Security maturity gates

| Capability | Local MVP | Development/staging | Production |
| --- | --- | --- | --- |
| Seeded profile/discovery data | Allowed | Allowed | Not a substitute for authorized backend data |
| Demo call state | Allowed if labeled | Allowed with fake provider events | Must use approved RTC controls and device tests |
| Real authentication | Not required | Required for protected API tests | Required with recovery and abuse controls |
| Real user messages | No private user data | Test accounts only | Requires moderation, retention, access, and deletion controls |
| Store purchases | Disabled or sandbox | Sandbox only | Receipt validation, ledger, refund, and reconciliation gates |
| Host payouts | Disabled | Fake provider events only | Legal, tax, identity, fraud, support, and reconciliation approval |
| Advertising IDs/fingerprints | Must not collect | Must not be core identity | Only separately approved purpose with consent and retention controls |
| Recording and background capture | Disabled | Disabled unless separately tested | Separate product, privacy, consent, and device approval |

Real-money purchases, host payouts, private user data, production moderation
queues, and production RTC must not be enabled merely because a client screen or
mock provider exists.

---

## 2. Security objectives and threat model

### 2.1 Security objectives

The product must:

1. Preserve confidentiality of private account, message, call, financial,
   moderation, support, and operational data.
2. Preserve integrity of authorization, balances, entitlements, call state,
   moderation decisions, and audit records.
3. Maintain availability with safe degradation, rate limits, retry behavior,
   provider isolation, and recovery procedures.
4. Minimize data collection, access, retention, and exposure.
5. Make sensitive actions attributable to an actor, capability, timestamp,
   reason, and request/event reference.
6. Fail closed when identity, authorization, policy, provider, or data state is
   missing or contradictory.
7. Give users understandable controls for permissions, privacy, blocking,
   reporting, deletion, support, and spending.

### 2.2 Trust boundaries

```text
User/device/client input       untrusted
Network and client storage     untrusted or observable
Provider callbacks             untrusted until verified
Uploads and media metadata     untrusted until scanned/validated
Realtime events                advisory until authorized/reconciled
API edge                       authentication, validation, rate limiting
Application services           authorization and domain policy
Database/ledger                authoritative server-side state
Secret manager                 restricted production trust boundary
Operator tools                 capability-scoped and audited
```

The mobile application, device, network, push provider, RTC provider, billing
provider, storage provider, and webhook payloads are not trusted sources of
authorization, prices, balances, call duration, moderation outcomes, or payout
amounts.

### 2.3 Threat and control register

| Threat | Protected asset | Required control |
| --- | --- | --- |
| Stolen or replayed session | Account and private data | Short-lived tokens, rotation, revocation, secure storage, anomaly handling |
| Account recovery abuse | Identity and account ownership | Rate limits, verification, recovery audit, anti-enumeration behavior |
| Broken object-level authorization | Profiles, messages, calls, reports, money | Server-side ownership/participant checks and two-account tests |
| Malicious or modified client | Balances, prices, duration, permissions | Server authority; never trust client-calculated business values |
| Duplicate or reordered request | Messages, calls, purchases, payouts | Idempotency keys, unique constraints, transaction boundaries, reconciliation |
| Provider webhook forgery | Wallet, RTC, payout, subscription state | Signature verification, replay protection, event deduplication |
| Media or upload abuse | Users, storage, devices, moderation | Type/size limits, scanning, scoped URLs, quotas, retention, reporting |
| Message harassment or scams | Users and trust | Rate limits, block/report, moderation state, evidence access, appeals |
| Insider misuse | Private data, moderation, finance | Least privilege, case scope, break-glass review, immutable audit |
| Secret leakage | Infrastructure and user data | Secret manager, scans, rotation, no secrets in APK/logs/repository |
| Provider outage | Calls, notifications, purchases | Adapter boundaries, pending states, retry/dead-letter, safe disable controls |
| Excessive telemetry | Privacy and identity | Allowlisted events, no advertising ID by default, retention/access controls |
| Account deletion failure | User rights and retained data | Retryable workflow, status visibility, exception inventory, audit |
| Backup or log exposure | Historical private data | Encryption, access controls, retention expiry, restore testing, redaction |

### 2.4 Security assumptions

- Any value shipped in the APK can be recovered by a user.
- A user can modify requests, timestamps, local storage, UI state, and client
  binaries.
- A provider can send duplicated, delayed, reordered, malformed, or malicious
  callbacks.
- Operators can make mistakes and must be constrained by capability and audit
  controls rather than trusted implicitly.
- A deleted, blocked, suspended, or restricted account may retain records that
  are required for safety, legal, tax, fraud, or financial reconciliation.
- “Private” means access-controlled and minimized; it does not automatically
  mean end-to-end encrypted. End-to-end encryption is a separate architecture
  decision and must not be claimed unless implemented and tested.

---

## 3. Privacy-by-design principles

### 3.1 Data minimization

Collect only data required for an approved feature. Before adding a field,
document:

- the user-visible purpose;
- the product owner and system owner;
- the source and collection point;
- whether collection is required, optional, or inferred;
- the user notice and consent requirement where applicable;
- the access roles and provider recipients;
- the retention class and deletion behavior;
- the security controls; and
- the test and monitoring evidence.

Do not add a field because a provider SDK can collect it or because the analyzed
artifact appeared to query it. In particular, advertising IDs, raw hardware
identifiers, precise location, contact lists, clipboard content, and stable
device fingerprints are not part of core account identity.

### 3.2 Purpose limitation

Data collected for one purpose must not silently be reused for another purpose.
Examples:

- A push token is for notification delivery, not user identity.
- A payment receipt is for verification and reconciliation, not analytics
  payloads.
- A moderation report is for safety review, not public profile ranking.
- A call event is for connection and settlement policy, not undisclosed user
  surveillance.
- An approved analytics event is for the documented metric, not identity
  enrichment.

New purposes require a product, privacy, security, and where appropriate legal
review before collection or reuse.

### 3.3 Privacy-preserving defaults

The product defaults should be:

- no precise location collection;
- no advertising ID collection in the local MVP;
- no stable device fingerprinting;
- no contact-book upload;
- no recording unless separately approved and clearly indicated;
- no background camera or microphone capture;
- no private message bodies in normal logs or analytics;
- no permanent public media URLs for private content;
- no default public display of email, phone, payout, or verification data;
- no lock-screen notification content beyond the approved minimum; and
- no production private data in development, test, screenshots, fixtures, or
  examples.

### 3.4 User transparency

User-facing copy must explain, in understandable language:

- why a permission is needed before requesting it where practical;
- what profile fields are public or private;
- whether a call is billable and when the meter starts/stops;
- what a report or block does;
- what happens after account deletion;
- which records may be retained and why;
- when a purchase, refund, payout, or deletion is pending;
- whether a feature uses a third-party provider; and
- how to contact support or exercise approved privacy rights.

The UI must not make a security, privacy, billing, recording, or deletion claim
that the backend and policy documents do not support.

---

## 4. Data classification and inventory

### 4.1 Classification levels

| Class | Meaning | Examples | Minimum handling |
| --- | --- | --- | --- |
| Public | Approved for public projection | Display name, approved avatar, public tags | Moderation, visibility policy, cache controls |
| Internal | Operational data not intended for users | Feature flags, aggregate metrics, deployment metadata | Role-limited access, normal retention policy |
| Private | User or participant data requiring access control | Messages, call metadata, preferences, support cases | Encryption in transit, scoped access, limited retention |
| Sensitive | High-impact or regulated-risk data | Identity documents, payment receipts, payout details, safety evidence | Separate access, stronger audit, minimum retention, no normal logs |
| Secret | Credential or cryptographic material | API keys, service-role keys, signing keys, RTC/billing secrets | Secret manager only, never client/repository/logs |

Classification is based on the data and context, not only the database table.
Publicly visible data can become sensitive when combined with private or
operational information.

### 4.2 Data inventory

The following inventory is the starting point. The privacy owner must complete
the missing retention and regional-policy decisions before launch.

| Data category | Purpose | Classification | Owner/access | Provider exposure | Retention/deletion |
| --- | --- | --- | --- | --- | --- |
| Account identity and login links | Authenticate and recover account | Private | User; auth/support under case scope | Approved auth provider | Account lifecycle; retain only required audit/security records |
| Sessions and refresh metadata | Revoke and secure access | Sensitive | User, security, auth service | Auth provider if required | Short-lived tokens; session records expire/revoke by policy |
| Profile and public media | Discovery and user presentation | Public/private by field | Owner; public projection; moderation | Storage/CDN if approved | Until changed/deleted, subject to safety/legal holds |
| Private profile fields | Account operation and support | Private | Owner and narrowly scoped support | Approved backend providers only | Account lifecycle and documented support retention |
| Messages and attachments | User communication and safety | Private | Participants; moderators only by case scope | Storage, notification, moderation providers if approved | Documented message retention; removal is not erasure of required evidence |
| Call metadata | Connection, safety, history, settlement | Private/sensitive | Participants, support/finance/moderation by scope | RTC provider minimum necessary | Policy-defined; never retain media by default |
| Camera/microphone stream | Real-time call media | Sensitive while active | Call participants and RTC adapter | Approved RTC provider | Not stored unless recording is separately approved |
| Push/device registration | Deliver notifications | Private | Account and notification service | Push provider | Until revoked, replaced, or account deleted |
| Advertising/attribution identifiers | Not required by default | Sensitive | None in local MVP | None by default | Do not collect; separately approved purpose only |
| Coarse app/device diagnostics | Compatibility and reliability | Internal/private | Engineering/security, limited support | Crash/analytics provider if approved | Allowlisted, short retention, no stable identity |
| Reports and moderation evidence | Safety enforcement and appeals | Sensitive | Assigned moderators, appeals, legal/support scope | Approved moderation/storage provider only | Safety/legal retention class; reporter privacy preserved |
| Payment receipts and purchases | Store verification and reconciliation | Sensitive | Finance/support by case; ledger service | App store/payment provider | Financial/tax/fraud retention; no silent deletion |
| Wallet and ledger history | Value accounting | Sensitive | User projection; finance/audit backend | Approved billing/payout providers minimum necessary | Immutable/retained as required; corrections are compensating entries |
| Host verification and payout data | Eligibility and payouts | Sensitive | Host and approved finance/support | Verification/payout providers | Legal/tax/fraud policy; strict access and holds |
| Support tickets | Resolve user and finance issues | Private/sensitive | User and assigned support role | Support provider only if approved | Support retention policy; redact unnecessary data |
| Audit, webhook, and job records | Accountability and recovery | Internal/sensitive | Security, operations, finance, moderation by scope | No third-party by default | Append-only retention class; redact payloads |

### 4.3 Data-flow inventory requirement

For every production data category, maintain a data-flow record containing:

```text
source -> collection point -> service/table -> provider/subprocessor
       -> user-facing use -> operator access -> logs/analytics
       -> backup/replica -> retention class -> deletion path
```

The record must identify cross-environment movement. Development and staging
must use synthetic or explicitly approved test data, never copied production
messages, media, receipts, identity documents, or moderation evidence.

---

## 5. Identity, authentication, and session security

### 5.1 Account creation and linking

The account system must:

- create one opaque account ID after successful account creation;
- separate authentication identity from public profile data;
- normalize and validate provider identities without exposing account existence;
- prevent unauthorized account-linking or identity takeover;
- handle provider cancellation, duplicate identity, and link conflict safely;
- require verification or additional assurance where the approved risk policy
  requires it;
- record security-relevant account changes in an audit trail; and
- rate-limit account creation, login, recovery, verification, and linking.

An email address, phone number, or external provider subject must not be used as
a public identifier. Sensitive account lookup failures should use equivalent
user-safe responses so attackers cannot enumerate accounts.

### 5.2 Passwords and credentials

If the product stores passwords, the authentication service must use an approved
modern password-hashing scheme with unique salts, protected configuration, and a
documented upgrade path. The application team must not implement ad hoc password
cryptography or log passwords, recovery codes, reset links, or provider tokens.

If a managed identity provider is used, the application still owns:

- account-to-provider identity mapping;
- session revocation behavior;
- role and capability assignment;
- account deletion orchestration;
- suspicious-login handling;
- support and recovery escalation; and
- safe error behavior at the application boundary.

### 5.3 Access and refresh tokens

- Access tokens are short-lived and scoped to the application and environment.
- Refresh/session rotation is required where supported by the selected auth
  architecture.
- Token audience, issuer, signature, scope, subject, and expiration are
  validated server-side.
- Revoked, expired, malformed, or wrong-environment tokens fail closed.
- Tokens are stored only in platform-protected client storage approved for the
  mobile stack; never in logs, URLs, analytics, screenshots, or ordinary
  preferences.
- Provider access tokens are not returned to unrelated application services.
- Service-role tokens, database administrator credentials, RTC secrets, billing
  credentials, signing keys, and webhook secrets remain server-side.

### 5.4 Session lifecycle

The session system must support:

```text
created -> active -> refreshed -> revoked
active -> expired
active -> forced_reauthentication
active -> locked_or_restricted
```

Security-sensitive events that revoke or restrict sessions include:

- explicit logout or revoke-all;
- account deletion or suspension;
- recovery or identity-link change;
- confirmed credential compromise;
- provider token invalidation;
- suspicious session or device activity; and
- administrator action through an audited capability.

The client must clear protected local state after logout, revocation, account
switch, deletion, or authentication failure. Relaunch must not display a prior
user's private data under a new or signed-out session.

### 5.5 Account recovery

Recovery is a high-risk workflow. It must:

- use rate limits, attempt budgets, and abuse monitoring;
- avoid revealing whether an account exists;
- expire recovery links or codes quickly;
- prevent code reuse and replay;
- notify the account through an approved security channel where appropriate;
- revoke or review existing sessions after material recovery changes;
- require additional verification for financial, payout, or identity changes;
- provide a support escalation path without bypassing authorization; and
- record the result without storing recovery secrets in normal logs.

### 5.6 Device and push registration

Device registration is for notification delivery and compatibility, not identity.
It must:

- bind a push target to the authenticated account through a server operation;
- accept only approved platform and token formats;
- protect push tokens as sensitive provider references;
- allow revocation on logout, account deletion, token rotation, or abuse;
- avoid raw hardware identifiers, advertising IDs, and stable fingerprints;
- record coarse app version and device family only when needed; and
- limit notification payloads to the minimum necessary data.

### 5.7 Account state enforcement

Every protected request checks account status before the operation. The server
must not rely on the mobile client to hide actions for suspended, deleted,
restricted, or deletion-pending accounts.

Account deletion must be authenticated, idempotent, observable, and retryable.
It must distinguish user-owned data that can be deleted from records retained
for safety, legal, tax, fraud, or financial reconciliation purposes.

---

## 6. Authorization and privileged access

### 6.1 Capability model

Use narrow capabilities rather than one broad `admin` role.

| Capability | Allowed scope | Must not do |
| --- | --- | --- |
| `user.read_self` / `user.write_self` | Own account, profile, preferences, consent | Read another account's private data |
| `host.manage_profile` | Approved host profile and availability | Grant host status or alter earnings |
| `host.accept_calls` | Eligible call requests | Bypass block, account, or spending policy |
| `moderation.review_case` | Assigned safety cases and minimum evidence | Browse unrelated private messages |
| `moderation.enforce` | Documented enforcement actions | Alter financial ledger or silently delete evidence |
| `support.manage_case` | Assigned support cases | Read unrelated safety evidence or payment payloads |
| `finance.reconcile` | Financial reconciliation and approved cases | Change posted entries silently |
| `finance.refund` | Approved refunds and compensating entries | Grant arbitrary credits or bypass receipt checks |
| `payout.manage` | Host payout eligibility and provider outcomes | Mark a payout paid without confirmation |
| `operations.manage` | Feature flags, provider controls, incident actions | Read routine user content without case scope |
| `infrastructure.deploy` | Environments, deployments, secrets by need | Use production data for development |
| `incident.break_glass` | Time-limited emergency scope | Become a permanent unrestricted role |

Role assignment, removal, and capability changes are server-owned, audited, and
never accepted from a normal mobile request.

### 6.2 Object-level authorization

For every read or write, the server checks:

1. authenticated account and session validity;
2. account status and region/age restrictions where approved;
3. role and capability;
4. resource ownership, participant membership, or assigned case;
5. relationship block and safety restrictions;
6. resource status and lifecycle transition;
7. rate, spending, entitlement, and concurrency limits; and
8. environment and provider scope.

A guessed ID, hidden UI action, client-supplied role, or cached resource must
never grant access. `NOT_FOUND` may be used instead of `FORBIDDEN` where that
prevents safe resource enumeration, but the behavior must be consistent and
documented.

### 6.3 Operator access

Operator tools must provide:

- separate authentication and capability grants;
- least-privilege case assignment;
- scoped search and pagination;
- redacted default views;
- explicit reason codes for sensitive actions;
- time-limited access to sensitive evidence;
- dual review or approval for high-impact finance/payout actions where required;
- immutable audit events; and
- an appeal or correction path that does not rewrite history.

Moderators should see the minimum evidence needed to decide a case. Support
staff should not receive moderation evidence unless assigned and authorized.
Finance staff should not receive private message bodies unless a documented
fraud or reconciliation case requires restricted access.

### 6.4 Break-glass access

Emergency access must be:

- explicitly enabled by an authorized incident or security capability;
- limited to a defined duration and resource scope;
- reason-coded before or immediately after use;
- logged with actor, target, purpose, time, and result;
- reviewed after the incident; and
- revoked automatically at expiry.

Break-glass access must not become a routine support workflow or a way to bypass
normal authorization.

---

## 7. Secrets, cryptography, and environments

### 7.1 Secret inventory

The following values are secrets unless a security owner explicitly classifies a
safe public counterpart:

- service-role and database administrator keys;
- authentication signing keys and private certificates;
- RTC API secrets and token-signing material;
- billing, store, payout, and refund credentials;
- webhook signing secrets;
- object-storage private keys and encryption keys;
- email, push, analytics, crash, and support provider credentials;
- deployment, CI/CD, repository, and infrastructure credentials; and
- recovery, break-glass, and operator credentials.

Public project IDs, public API origins, and client-side configuration are not a
substitute for server authorization and must still be reviewed for unnecessary
exposure.

### 7.2 Secret handling

- Store production secrets in an approved secret manager or provider dashboard.
- Use separate secret sets for local, development, staging, and production.
- Never commit passwords, secrets, tokens, keys, or certificates to the
  repository, APK, Markdown, screenshots, test fixtures, logs, crash reports, or
  AI prompts.
- Keep `.env.example` files to variable names and safe placeholders only.
- Grant access to services and operators by least privilege and environment.
- Rotate secrets on a schedule appropriate to risk and after suspected exposure.
- Record secret identity, owner, environment, rotation date, and recovery path,
  but never record the secret value.
- Remove unused keys and revoke old credentials after rotation.
- Scan source, history, build artifacts, logs, and generated outputs for secret
  patterns before release.

### 7.3 Exposure response

If a secret may be exposed:

1. Stop using the suspected credential where safe.
2. Revoke or rotate it without copying the value into tickets or logs.
3. Identify affected environments and services.
4. Inspect access logs for unauthorized use.
5. Preserve only redacted evidence needed for the incident.
6. Patch the source, build, configuration, or process that exposed it.
7. Re-run secret scans and relevant security tests.
8. Notify security, operations, support, and legal/privacy owners as required.
9. Document customer impact and remediation without publishing the secret.

### 7.4 Encryption and key management

- Use modern TLS for production API, storage, auth, push, email, billing, and
  RTC control-plane connections.
- Validate certificates through the platform/provider-supported trust model and
  do not disable certificate validation for convenience.
- Encrypt sensitive data at rest through the approved database, storage, backup,
  and secret-manager controls.
- Separate encryption keys by environment and, where practical, by data class.
- Restrict key management operations independently from ordinary data access.
- Rotate keys with a documented compatibility and recovery procedure.
- Do not claim end-to-end encryption unless the product has a reviewed,
  implemented, and tested end-to-end design.

### 7.5 Environment separation

Local, development, staging, and production must have separate:

- databases and storage namespaces;
- authentication projects and signing keys;
- RTC projects or room namespaces;
- billing sandbox/production configuration;
- notification and email credentials;
- analytics and crash-reporting projects where practical;
- service accounts, role grants, and secret sets; and
- backup and restore destinations.

Local and test builds must not point at production billing, payout,
moderation, private user data, or production notification topics without an
explicit approved exception and time limit.

---

## 8. API and backend security controls

### 8.1 Request processing pipeline

Every protected request follows this order:

```text
TLS / transport boundary
  -> request size and content checks
  -> request correlation ID
  -> authentication and token validation
  -> schema/type/length validation
  -> rate and abuse controls
  -> object ownership and role authorization
  -> block/suspension/deletion/eligibility policy
  -> idempotency and concurrency checks
  -> transaction/domain command
  -> audit/outbox/reconciliation
  -> safe response
```

Failure at any earlier boundary must prevent the protected write. The server
must not perform a provider side effect before the local authorization and
idempotency decision is durable.

### 8.2 Input validation

Validate at the API boundary and again at the domain/database boundary where
needed:

- type, required/optional fields, and unknown-field policy;
- Unicode length, encoding, normalization, and control characters;
- enums, IDs, timestamps, ranges, and currency;
- ownership, participant membership, and state transitions;
- attachment type, size, dimensions, and malware/content-safety state;
- rate, spend, concurrency, entitlement, and quota limits;
- pagination cursor, filter, and sort compatibility; and
- idempotency-key format and request fingerprint.

Use parameterized queries and safe serialization. Never concatenate untrusted
input into SQL, shell commands, storage paths, provider URLs, log formats, or
HTML/Markdown output.

### 8.3 API error and response safety

The API follows `docs/API_CONTRACT.md`:

- stable machine-readable error codes;
- safe user-facing messages or localization keys;
- request/correlation IDs;
- no stack traces, SQL, provider payloads, secrets, or unrelated private data;
- explicit retryability and pending states;
- cursor pagination for unbounded data; and
- idempotency results for retryable business operations.

Do not use detailed error differences to reveal whether a private account,
message, report, payment, or provider object exists.

### 8.4 Rate limits and abuse prevention

Rate-limit and monitor at least:

- account creation, login, recovery, verification, and linking;
- profile and discovery reads where abuse or scraping is possible;
- follow, favorite, match, block, and unblock actions;
- message, attachment, report, and support-case creation;
- call requests, acceptance, cancellation, and RTC token issuance;
- uploads, purchase verification, restore, refund, and payout operations; and
- operator searches, exports, and break-glass actions.

Limits should be scoped by the least sensitive combination needed, such as
account, IP, route, resource, or approved coarse device context. Do not use a
stable hardware fingerprint as a hidden identity system.

### 8.5 Idempotency and business effects

All messages, calls, reports, purchases, refunds, payouts, deletion requests,
and other value or access effects use a durable idempotency record or equivalent
unique constraint. The server must safely handle:

- double taps;
- client retries;
- app restarts;
- network timeouts after commit;
- duplicate provider callbacks;
- delayed/reordered events; and
- worker retries.

An idempotency key must not be reused with a different request payload. A
timeout must not cause the client to create a second key blindly.

### 8.6 Webhooks and provider callbacks

Before business parsing or state changes:

1. Verify the provider signature.
2. Validate event timestamp and audience/replay window.
3. Validate provider event ID and event type.
4. Deduplicate against a durable `WebhookEvent` record.
5. Map the event into an application command.
6. Apply the command transactionally.
7. Enqueue notifications or side effects through an outbox/job.
8. Acknowledge according to the provider retry contract.
9. Route failures to dead-letter/manual recovery.

Provider event payloads are untrusted input and must be redacted in normal logs.

---

## 9. Database, repository, and storage security

### 9.1 Database authority

The production database is the authoritative store for account-owned resources,
relationships, conversations, calls, safety cases, audit records, and the
financial ledger when enabled. Client state, cache state, provider state, and
analytics state are not authoritative.

Every schema change must use a versioned migration owned by the service that
owns the database. Migrations must include, where applicable:

- primary keys and opaque public IDs;
- foreign keys and deletion behavior;
- ownership constraints;
- status/state constraints;
- indexes for ownership, status, cursors, and reconciliation;
- row-level security or an equivalent repository authorization policy;
- audit/outbox/idempotency records;
- backfill and lock behavior;
- rollback or forward-fix strategy; and
- clean-database and representative-existing-data test evidence.

Production tables must not be edited manually as a normal workflow.

### 9.2 Row-level and repository authorization

RLS or repository policies must fail closed for:

- profiles with private fields;
- conversation membership and messages;
- call participants and metadata;
- reports and moderation evidence;
- support cases;
- wallet and purchase projections;
- host earnings and payouts; and
- device/session records.

Policies must be tested with at least:

- the owner/participant account;
- a second unrelated account;
- a blocked account;
- a suspended/deleted account;
- an approved operator with assigned scope; and
- an unassigned operator or wrong capability.

Application authorization and database authorization must reinforce each other.
Passing a database policy must not bypass business state, block, eligibility,
spending, or moderation rules.

### 9.3 Sensitive fields and projections

Keep private and sensitive fields separate from public projections where
practical. Public APIs should use explicit response projections rather than
serializing entire database objects.

Do not expose:

- email, phone, recovery, or provider identity details without purpose;
- precise location or hidden availability reasons;
- identity-document contents or verification evidence;
- private payout destination or tax information;
- moderation evidence, reporter identity, or staff notes;
- private message bodies outside participant/case scope;
- raw provider payloads, receipts, tokens, or authorization headers; or
- internal risk, ranking, fraud, or investigation signals.

### 9.4 Backups, replicas, and exports

Backups and replicas are production data and require the same or stronger
controls as the source:

- encryption at rest and in transit;
- separate access roles and audit trails;
- environment and region documentation;
- retention and expiry schedules;
- restore testing;
- deletion/retention exception handling; and
- no unapproved download or local copy.

Database exports must be purpose-limited, encrypted, time-limited, access-logged,
redacted where possible, and destroyed after the approved use. Do not use a
production dump to seed local development.

### 9.5 Cache, search, and queues

Caches, search indexes, rate-limit stores, job queues, dead-letter queues, and
outbox records may contain private data. They must have:

- access controls and environment separation;
- TTL/retention rules;
- invalidation behavior after deletion, blocking, or suspension;
- redacted payloads where full content is unnecessary;
- encryption where supported; and
- recovery and deletion procedures.

Do not assume that deleting a primary row deletes copies in caches, search,
backups, notifications, provider systems, or logs.

---

## 10. Media, uploads, and real-time communications

### 10.1 Upload security

Uploads must use a server-issued, purpose-scoped upload intent. The client must
not choose an arbitrary storage path or receive a permanent public credential.

The upload flow must:

1. Authenticate the owner.
2. Validate purpose, content type, size, dimensions, and quota.
3. Issue a short-lived scoped upload instruction.
4. Store the object in an isolated quarantine or private namespace.
5. Verify completion and object metadata server-side.
6. Run malware/content-safety checks where applicable.
7. Apply moderation and visibility state.
8. Create a media reference only after validation.
9. Return a controlled, expiring access reference.
10. Clean up failed, expired, rejected, and abandoned objects idempotently.

Never trust a filename, MIME type, extension, image dimensions, or client-side
scan result. Server-generated filenames must not contain user-controlled paths.

### 10.2 Media access

- Private media uses short-lived signed URLs or an equivalent access boundary.
- URLs are not placed in normal logs, analytics, messages, screenshots, or
  support notes unless redacted and necessary.
- Public media still requires ownership, moderation, visibility, cache, and
  deletion controls.
- Media deletion must account for thumbnails, transcodes, caches, backups,
  provider copies, moderation evidence, and legal holds.
- Metadata such as EXIF or precise location is removed or minimized unless an
  approved feature explicitly needs it.
- Download, share, and export behavior must be documented rather than implied.

### 10.3 Camera and microphone

The client must:

- explain why camera/microphone access is needed before requesting it where
  practical;
- request only the permission required for the current feature;
- handle denial, permanent denial, revocation, missing hardware, and route
  changes;
- provide a useful fallback or settings path;
- show active camera, microphone, mute, route, and connection state accurately;
- stop capture when the call ends, authorization is revoked, or the feature
  leaves the foreground according to approved policy; and
- never capture silently or claim recording when no recording exists.

### 10.4 RTC and call privacy

The backend owns the application call session. The RTC provider owns media
transport. The client owns neither final authorization nor settlement.

RTC controls must include:

- short-lived tokens scoped to one call, room, participant, and role;
- provider project/namespace separation per environment;
- token audience, scope, and expiration validation;
- no provider secret in the APK;
- revocation or safe expiry after block, suspension, call end, or account
  deletion;
- provider callback verification and reconciliation;
- explicit reconnect and failure states;
- no recording by default; and
- provider data retention and deletion review.

Call metadata may be private or sensitive even when media is not stored. Limit
participant, timing, quality, provider, and billing references to the approved
purpose and retention class.

### 10.5 Recording and screenshots

Recording, screen capture, background calls, picture-in-picture, camera effects,
and overlays are deferred unless separately approved. If recording is later
enabled, the product must document consent, indicators, storage, access,
retention, deletion, download, reporting, and regional restrictions before
implementation.

---

## 11. Android and client security

### 11.1 Client trust model

The Android client is an untrusted presentation and input environment. It may:

- render server state;
- collect user input;
- hold short-lived user-scoped tokens in protected platform storage;
- request device permissions;
- submit idempotent commands; and
- display recoverable errors.

It must not decide final authorization, prices, balances, call duration, host
rates, payout amounts, moderation outcomes, or account status.

### 11.2 Local storage

Do not persist private data longer than necessary. Protect or avoid storing:

- access and refresh tokens;
- recovery data;
- private message bodies and media references;
- payment receipts;
- identity documents;
- moderation evidence;
- call tokens;
- payout details; and
- full account data after logout or deletion.

Use platform-protected storage for secrets and clear protected local state on
logout, account switch, revocation, deletion, or security reset. Shared
preferences, screenshots, crash dumps, clipboard contents, and backups must not
be treated as secure secret stores.

### 11.3 Deep links and notifications

Deep links must:

- use independent product identifiers and hosts;
- validate scheme, host, path, parameters, and authorization;
- never contain access tokens, receipts, private message bodies, or signed media
  URLs;
- fail closed for malformed or expired intents;
- re-check account, resource, block, and deletion state after navigation; and
- use short-lived server-generated intent references for sensitive destinations.

Push notifications must minimize private content. A notification tap must fetch
current authorized data rather than trusting payload content.

### 11.4 Client and build hardening

Before a release, review:

- manifest permissions and exported components;
- release/debug configuration separation;
- network security configuration and cleartext exceptions;
- dependency licenses and vulnerabilities;
- signing and keystore access;
- embedded URLs, IDs, certificates, and public configuration;
- logs, crash reports, and debug menus;
- backup and screenshot behavior;
- WebView, custom URL, and intent handling if used; and
- generated build artifacts for secrets or private data.

Anything shipped in an APK must be assumed recoverable. Obfuscation is not a
replacement for server authorization or secret management.

### 11.5 Accessibility and privacy UX

Security and privacy controls must remain understandable with:

- large fonts and translations;
- screen readers;
- color-blindness or low contrast;
- denied permissions;
- offline or timeout states;
- long names and messages; and
- reduced-motion or device accessibility settings.

The user must be able to find permission settings, block/report controls,
privacy settings, account deletion, support, and purchase history without
precise tapping or hidden gestures.

---

## 12. Messaging, moderation, and trust & safety privacy

### 12.1 Message confidentiality and access

Messages are private to authorized conversation participants unless a documented
safety, support, legal, or fraud workflow grants minimum necessary access.

- Conversation membership is server- and database-authorized.
- A client-known conversation ID does not authorize access.
- Message bodies are not used as authorization, pricing, ranking, or fraud
  decisions without a separately approved process.
- Delivery and read state do not imply a person read content unless the product
  contract supports that claim.
- Removed content is replaced with a safe user projection; required safety or
  legal evidence is retained separately and access-controlled.
- Blocked, deleted, suspended, and read-only participants receive the documented
  restricted behavior rather than private explanations.

### 12.2 Reporting privacy

Reports must protect the reporter:

- the reported account does not receive reporter identity;
- report acknowledgements contain only a safe case ID/status;
- moderation evidence is available only to assigned capabilities;
- evidence access is logged and reviewable;
- operators receive the minimum context needed to act;
- duplicate or abusive reports are rate-limited without punishing legitimate
  safety reports; and
- appeals do not reveal protected reporter information unnecessarily.

### 12.3 Moderation data

Moderation records should distinguish:

```text
received -> triaged -> reviewing -> actioned -> appealed -> resolved
                                     \-> no_action
```

Every moderation action records actor, capability, target, reason code, server
timestamp, prior/new state, evidence references, and appeal/reversal linkage.
Do not overwrite the audit history to make a moderation result appear simpler.

### 12.4 High-risk content and escalation

The safety program must define handling for harassment, spam, scams,
impersonation, exploitation, coordinated abuse, age concerns, emergency reports,
and legally required escalation. The operational procedure must identify:

- intake and prioritization;
- evidence minimization and access;
- response targets;
- user notification where appropriate;
- temporary and permanent enforcement;
- appeals and correction;
- emergency escalation; and
- retention and deletion exceptions.

The detailed process belongs in `docs/TRUST_AND_SAFETY.md`; this document defines
the security and privacy controls around the data.

---

## 13. Payments, earnings, and financial privacy

Financial features are gated until the payment and earnings policy is approved.

### 13.1 Financial data controls

- Store integer minor units and explicit currency on the server.
- Treat receipts, purchase tokens, payout details, tax forms, and identity
  verification as sensitive.
- Verify store purchases and provider events server-side.
- Do not log receipts, payment payloads, authorization headers, or full payout
  destinations.
- Separate user-facing transaction projections from raw provider records.
- Restrict finance/support access by case and capability.
- Preserve posted ledger records; correct with compensating entries.
- Record policy/rate version, source effect, actor, request/event ID, and server
  time for every financial effect.

### 13.2 Client and wallet boundaries

The client may display server-provided wallet and entitlement projections. It
must not:

- set or increment a balance;
- choose the charge, host rate, payout amount, or settlement duration;
- mark a purchase fulfilled;
- mark earnings available or paid;
- refund a purchase directly; or
- bypass spending, hold, identity, or fraud limits.

### 13.3 Host and payout privacy

Host verification and payout data are restricted to the host and approved
finance/support workflows. The public profile must not expose legal name,
identity documents, payout destination, tax details, risk holds, or private
earnings calculations unless explicitly approved and required.

Pending, held, disputed, reversed, and paid states must be understandable to the
host without revealing private fraud or investigation signals.

---

## 14. Logging, analytics, and telemetry

### 14.1 Logging principles

Logs are operational evidence, not a secondary product database. Normal logs
must be structured, bounded, access-controlled, and redacted.

Do not log:

- passwords, reset codes, access/refresh tokens, cookies, or authorization
  headers;
- private message bodies, report explanations, support messages, or media
  contents;
- signed media URLs or private storage paths containing active credentials;
- payment receipts, purchase tokens, payout destinations, identity documents, or
  raw provider payloads;
- full device identifiers, advertising IDs, stable fingerprints, or contact data;
- unnecessary precise location, IP address, or user-agent detail; or
- secrets embedded in exception messages or dependency output.

If an incident requires temporary protected capture, it must be narrowly scoped,
time-limited, approved by a security owner, encrypted, access-logged, and
destroyed after the documented investigation period.

### 14.2 Safe request metadata

Allowed request/operation metadata may include:

```text
request_id
route_family
method
status_code
safe_error_code
latency_bucket
retryable
actor_category or opaque actor ID when necessary
resource_type and opaque resource ID when necessary
environment
app_version
provider_adapter name
```

Do not place raw request bodies, query strings containing private values, tokens,
or provider payloads into tracing spans.

### 14.3 Analytics events

Analytics must use an allowlist and documented purpose. Each event definition
must state:

- event name and schema version;
- product purpose and owner;
- required/optional properties;
- consent or notice requirement;
- privacy classification;
- retention and deletion behavior;
- approved consumers and dashboards; and
- prohibited fields.

The local MVP must not collect advertising IDs, stable device fingerprints,
precise location, message bodies, private media URLs, payment payloads, or raw
provider tokens for analytics.

Product events should use opaque account/resource references only when necessary
and should not become a second source of truth for account, call, moderation, or
financial state. The detailed event catalog belongs in
`docs/ANALYTICS_EVENTS.md`.

### 14.4 Crash and support diagnostics

Crash reports and support diagnostics must:

- use separate environment projects where possible;
- scrub tokens, URLs, message text, receipts, and private identifiers;
- permit user/account deletion handling where applicable;
- restrict staff access by role and case;
- document provider retention; and
- avoid attaching full database or local-storage dumps.

### 14.5 Monitoring and alerting

Security monitoring should alert on:

- authentication and recovery abuse;
- unusual session revocation or token failures;
- authorization-denied spikes or cross-account access attempts;
- rate-limit and scraping patterns;
- webhook signature failures and replay attempts;
- duplicate ledger, purchase, payout, or call effects;
- bulk downloads, export, or operator searches;
- secret-manager access anomalies;
- unusual moderation or break-glass activity; and
- data deletion, backup, or restore failures.

Alerts must avoid including the sensitive data they protect.

---

## 15. Retention, deletion, export, and legal holds

### 15.1 Retention principles

Retention periods are product, privacy, legal, safety, tax, fraud, and finance
decisions. The app must not invent a universal deletion period. Each data class
requires an approved retention owner and schedule.

Retention must be:

- no longer than the approved purpose requires;
- applied consistently across primary data, caches, search, queues, logs,
  backups, provider copies, and exports where feasible;
- paused only for a documented legal, safety, fraud, tax, or reconciliation
  hold;
- reviewed periodically; and
- tested through deletion and expiry jobs.

### 15.2 Retention classes

Use controlled retention classes rather than arbitrary per-row dates:

```text
active
short_operational
private_content
safety_evidence
financial_reconciliation
tax_or_legal
security_audit
backup_recovery
purge_eligible
legal_hold
```

Each class must define owner, access roles, storage locations, expiry action,
backup behavior, legal-hold behavior, and evidence of purge.

### 15.3 Account deletion workflow

The deletion workflow should be:

```text
requested -> identity_confirmed -> scheduled -> processing
processing -> completed | blocked_for_review | failed_retryable
requested -> canceled (only during approved window)
```

The server must:

1. Authenticate the request and prevent unauthorized deletion.
2. Show the user what will be removed, anonymized, or retained.
3. Revoke sessions and protected device registrations at the approved stage.
4. Stop new messages, calls, purchases, payouts, and sensitive actions as
   policy requires.
5. Remove or anonymize account-owned profile, relationship, media, and private
   content according to retention rules.
6. Handle provider copies, storage objects, caches, search indexes, push tokens,
   analytics references, and queued jobs.
7. Preserve only documented safety, legal, tax, fraud, financial, or audit
   records, with identity minimization where possible.
8. Retry failed cleanup idempotently and expose status to the user/support.
9. Record completion, exceptions, and operator intervention in an audit trail.

Financial records must not be silently deleted to correct a balance. Safety and
financial exceptions must be explainable to the user at an appropriate level
without disclosing private investigation information.

### 15.4 User access, correction, and export

Where applicable to the launch regions and approved legal policy, the product
must provide a verified workflow for:

- access to personal data;
- correction of inaccurate account/profile information;
- export in a usable format;
- withdrawal of optional consent;
- objection or restriction requests where supported; and
- deletion requests.

The workflow must verify the requester, protect other users' data, exclude
secrets and internal security signals, distinguish pending from completed work,
and record fulfillment or refusal reasons. Legal owners must approve the exact
regional rights and timelines.

### 15.5 Legal, safety, and financial holds

A hold must:

- have an owner, reason code, scope, start time, and review date;
- identify the exact data categories and systems affected;
- prevent automatic purge only where necessary;
- preserve minimum identity and evidence needed for the purpose;
- be access-controlled and audited; and
- expire or be renewed through an explicit review.

Do not use an indefinite hold as a substitute for a retention policy.

---

## 16. Consent, notices, and privacy operations

### 16.1 Consent and notice records

Consent records must be versioned and append-only where evidence is required.
Record:

- consent or notice type;
- policy/notice version;
- decision and effective timestamp;
- withdrawal timestamp where applicable;
- account and authenticated session reference;
- collection purpose and region where required; and
- source/channel without raw device identifiers.

Consent is not a substitute for authorization, security controls, or a lawful
purpose. The product must not make optional analytics or advertising consent a
condition for an unrelated core feature without approved product and legal
review.

### 16.2 Privacy settings

Privacy settings must be server-authoritative and include, where approved:

- profile visibility;
- availability visibility;
- notification preferences;
- message/contact eligibility;
- optional analytics or personalization controls;
- media visibility and sharing controls; and
- account deletion/access/export entry points.

Changing a setting must invalidate or update affected caches, notifications,
search projections, and provider subscriptions within the documented time.

### 16.3 Privacy requests and support

Support must not ask users to send passwords, access tokens, payment credentials,
identity documents, or full private message exports through ordinary chat or
email. Sensitive verification must use an approved protected workflow.

Support staff receive the minimum data needed for the case. Every access to
sensitive data is logged with actor, capability, reason, target, and timestamp.

### 16.4 Privacy incident handling

Potential unauthorized access, loss, disclosure, or deletion of personal data
must be handled through the incident process in section 18. Do not make legal or
customer-notification claims from an engineering ticket alone; involve the
privacy/legal owner for assessment.

---

## 17. Provider, vendor, and subprocessor controls

Before a provider receives production data, record:

- provider name, service, and environment;
- data categories and fields shared;
- purpose and processing behavior;
- region/data residency and transfer considerations;
- security and privacy review owner;
- contract/DPA or equivalent legal review where applicable;
- retention and deletion behavior;
- encryption and access-control model;
- breach/incident notification path;
- subprocessors and support access;
- exit/export/deletion plan; and
- cost, availability, and lock-in risks.

Provider adapters must expose application states rather than provider-specific
payloads. A provider's feature or SDK registration is not approval to collect
its optional data. The product must disable unused SDK capabilities, permissions,
telemetry, and background services where practical.

Provider changes require regression review for:

- data fields and permissions;
- token scope and lifetime;
- retention and deletion;
- webhook verification;
- outage and retry behavior;
- cost and rate limits;
- user-facing notices; and
- legal/privacy documentation.

---

## 18. Incident response and security operations

### 18.1 Incident categories

At minimum, classify incidents as:

- account takeover or credential abuse;
- unauthorized data access or disclosure;
- secret or signing-key exposure;
- malicious upload or content-safety failure;
- authorization or RLS bypass;
- payment, ledger, purchase, refund, or payout integrity issue;
- RTC token or call privacy failure;
- moderation or reporter-privacy failure;
- availability, denial-of-service, or provider outage;
- backup, deletion, or retention failure; and
- operator or break-glass misuse.

### 18.2 Response stages

```text
detect -> triage -> contain -> preserve evidence -> eradicate
       -> recover -> verify -> communicate -> review -> improve
```

The incident record must include:

- detection time and reporting source;
- incident owner and severity;
- affected environments, services, data, and users;
- known and suspected timeline;
- safe containment and feature-disable actions;
- preserved evidence location and access list;
- secret rotation or credential revocation;
- recovery and validation steps;
- support/customer guidance;
- privacy/legal/store/provider notification assessment;
- decision log and approvals; and
- follow-up actions with owners and due dates.

Do not place tokens, passwords, message bodies, payment payloads, identity
documents, or unnecessary personal data in the incident record.

### 18.3 Emergency controls

Operations must be able to disable or limit, with audit and rollback:

- new account creation or recovery;
- discovery or search;
- messaging or uploads;
- call requests or RTC token issuance;
- purchases, refunds, or payouts;
- notifications or deep-link delivery; and
- a compromised provider or webhook integration.

Emergency controls must have safe user-facing errors, environment scope,
authorized operators, timestamps, and recovery criteria.

### 18.4 Secret and account compromise

For suspected account or credential compromise:

1. Revoke affected sessions/tokens or credentials.
2. Preserve redacted evidence and request IDs.
3. Identify access and business effects.
4. Place affected purchases, payouts, calls, or moderation actions into review
   when necessary.
5. Rotate secrets or recovery mechanisms.
6. Restore safe account access through verified recovery.
7. Notify support/privacy/legal owners according to the assessment.
8. Document corrective controls and test the fix.

---

## 19. Security testing and assurance

### 19.1 Static and dependency checks

Before release, run and record:

- formatter/linter/type/static checks appropriate to each service;
- secret scans over source, history where available, artifacts, and logs;
- dependency vulnerability and license review;
- Android manifest, exported-component, permission, and network-policy review;
- build reproducibility and signing/keystore access review;
- infrastructure and environment configuration review; and
- Markdown, schema, migration, and OpenAPI validation.

### 19.2 Security and privacy tests

Required server/integration tests include:

- unauthenticated, expired-token, wrong-audience, and revoked-token requests;
- two-account object-level authorization;
- role/capability and operator-scope enforcement;
- blocked, suspended, deleted, restricted, and deletion-pending accounts;
- malformed input, size limits, enum validation, and safe error redaction;
- rate limits, retry-after behavior, and abuse controls;
- duplicate, replayed, timed-out, delayed, and reordered commands/events;
- webhook signature, timestamp, audience, and event-deduplication checks;
- RLS/repository policies on every user-owned and sensitive table;
- media access, signed URL expiry, upload scanning, and deletion;
- account deletion across primary data, caches, queues, providers, and backups;
- ledger, receipt, refund, payout, and compensating-entry integrity;
- call token scope, expiration, revocation, reconnect, and end behavior;
- report privacy and moderator least-privilege access; and
- audit completeness for sensitive actions.

### 19.3 Mobile and device tests

On supported devices, test:

- fresh install, upgrade, logout, account switch, and deletion;
- secure local-state clearing;
- camera/microphone/notification/storage permission denial and revocation;
- lock/background/foreground and process death;
- network loss, reconnect, provider timeout, and token expiry;
- deep-link validation and notification privacy;
- screenshots, backups, clipboard, logs, and crash output;
- accessibility labels, large text, contrast, and localization; and
- supported audio routes and media-resource release.

If a device or provider check cannot run, mark it blocked/pending. A successful
compile does not prove camera, microphone, RTC, billing, notification, or
background behavior.

### 19.4 External review

Before broad launch, consider independent review appropriate to risk, including:

- threat-model review;
- penetration testing of API and operator tools;
- mobile application security review;
- privacy impact assessment;
- payment/ledger reconciliation review;
- moderation and safety operations review;
- backup/restore and disaster-recovery exercise; and
- legal/store-policy/tax review.

The required review scope and acceptance evidence must be recorded by the
security/privacy owner rather than assumed from provider certifications.

---

## 20. Release and change-management gates

### 20.1 Security/privacy release gate

Do not release a production build until the applicable checklist is complete:

- [ ] Product scope, regions, roles, age policy, and data purposes are approved.
- [ ] Security/privacy owner and operational owners are assigned.
- [ ] Threat model and data-flow inventory are current.
- [ ] Authentication, recovery, session revocation, and account deletion are
  implemented and tested.
- [ ] Authorization tests cover two accounts, roles, blocks, suspensions,
  deletion, and operator scopes.
- [ ] Database migrations, ownership constraints, RLS/repository policies, and
  backup/restore checks pass.
- [ ] API validation, rate limits, idempotency, safe errors, webhook security,
  and audit events pass.
- [ ] Secrets are in the approved manager; scans find no committed or embedded
  credentials.
- [ ] Android manifest, permissions, exported components, network policy,
  release signing, local storage, and deep links are reviewed.
- [ ] Media upload, signed URL, scanning, deletion, and retention controls pass.
- [ ] RTC tokens, permission denial, reconnect, revocation, and media cleanup
  are tested on supported devices if calls are enabled.
- [ ] Reports, blocks, moderation access, appeals, and reporter privacy work.
- [ ] Payment, ledger, receipt, refund, payout, and host-earnings controls are
  disabled or sandbox-tested; real money requires separate approvals.
- [ ] Logging, analytics, crash reports, support diagnostics, and notification
  payloads pass privacy/redaction review.
- [ ] Retention, deletion, export, consent, privacy notices, and legal holds are
  documented for the launch regions.
- [ ] Monitoring, alerts, incident contacts, emergency controls, and runbooks
  are available.
- [ ] Open security/privacy risks have owners, severity, mitigation, and an
  explicit release decision.

### 20.2 Change review triggers

A security/privacy review is required before changing:

- authentication, recovery, session, role, or authorization behavior;
- profile visibility, messaging, call, media, or notification data;
- retention, deletion, export, consent, or privacy settings;
- analytics, attribution, crash, or device data;
- RTC, storage, push, email, payment, payout, moderation, or support providers;
- database ownership, RLS, migrations, backups, or exports;
- API error, webhook, idempotency, or token behavior;
- operator access, break-glass, or audit records; and
- production logging or incident-capture configuration.

The change record must identify affected data categories, users, environments,
providers, tests, documentation, rollback/forward-fix behavior, and required
approvals.

### 20.3 Security exception process

An exception must be:

- specific to a control and environment;
- time-limited with an expiry date;
- owned by an accountable approver;
- risk-assessed with compensating controls;
- tracked in a restricted register;
- reviewed before renewal; and
- closed with evidence or formally re-approved.

Exceptions must not authorize secret commits, unsafe client trust, silent
financial edits, unrestricted operator access, or target-artifact reuse.

---

## 21. Documentation and evidence requirements

Every important security/privacy control document, implementation, migration,
and runbook should state:

- status: draft, proposed, approved, deprecated, or superseded;
- owner/reviewer;
- last-updated date;
- source of truth for related code/configuration;
- assumptions and unresolved questions;
- data categories and access roles affected;
- test commands and evidence links;
- dashboards, alerts, or runbooks involved; and
- rollback, deletion, or recovery behavior where applicable.

Security evidence must be redacted. Do not commit target APK extracts, private
user data, credentials, tokens, production receipts, raw moderation evidence,
or unapproved screenshots/media to the independent product repository.

When behavior is only planned, label it **Proposed** or **Gated**. Do not claim
that a mock provider, seeded database, local wallet, demo call, or unrun device
test is production security evidence.

---

## 22. Open decisions before approval

The following decisions must be resolved before this document changes from
**Draft / proposed** to **Approved**:

1. Launch countries, regions, currencies, age requirements, and data-residency
   expectations.
2. Authentication provider, token/session architecture, recovery assurance, and
   whether high-risk actions require MFA or step-up verification.
3. Account-linking, device/session management, suspicious-login, and support
   recovery policy.
4. Exact public/private profile fields and visibility defaults.
5. Whether precise location, contacts, advertising IDs, attribution IDs, or
   other diagnostics are collected at all.
6. Exact message, attachment, call metadata, notification, and support
   retention periods.
7. Whether end-to-end encryption is required; if not, the approved server-side
   confidentiality and operator-access model.
8. RTC provider, storage provider, push/email providers, and their regions,
   subprocessors, retention, deletion, and incident terms.
9. Recording, screen capture, background calls, camera effects, and Bluetooth
   feature policy.
10. Moderation roles, evidence access, legal escalation, appeals, and safety
    response targets.
11. Payment/store/payout providers, financial data retention, tax records,
    refund/chargeback policy, and host verification.
12. Privacy rights, consent notices, export format, account deletion timeline,
    and legal-hold process for each launch region.
13. Security monitoring, alert thresholds, incident severity, notification
    ownership, and external review scope.
14. Backup/restore, disaster-recovery, RTO/RPO, and data-purge verification.
15. Exact rate limits, abuse signals, feature-disable controls, and exception
    approval authority.

Until these choices are resolved, this document defines safe minimum controls
and constraints, not a final legal notice or production configuration.

---

## 23. Approval checklist

Before approval, the owners must confirm:

- [ ] Product owner approved the data purposes and launch scope.
- [ ] Security owner approved the threat model and control baseline.
- [ ] Privacy/legal owner approved notices, consent, rights, retention, and
  regional requirements.
- [ ] Engineering mapped controls to `docs/ARCHITECTURE.md`,
  `docs/DOMAIN_MODEL.md`, and `docs/API_CONTRACT.md`.
- [ ] Every sensitive data category has an owner, classification, access policy,
  retention class, deletion path, and provider record.
- [ ] Authentication, authorization, session, recovery, and operator tests pass.
- [ ] RLS/repository, API, idempotency, webhook, upload, and audit tests pass.
- [ ] Mobile permission, local-storage, deep-link, notification, and release
  security tests pass on supported devices or are explicitly blocked.
- [ ] Moderation, report privacy, block, appeal, and account-deletion paths pass.
- [ ] Financial controls are implemented and server-tested before real value is
  enabled, or the feature is disabled and clearly labeled.
- [ ] Logging, analytics, crash, support, and notification redaction review
  passes.
- [ ] Backup/restore, deletion propagation, retention expiry, and incident
  exercises have evidence.
- [ ] Secrets are managed outside source/APK and rotation/recovery is tested.
- [ ] Monitoring, alerting, emergency controls, contacts, and runbooks exist.
- [ ] All remaining risks have owners and an explicit release decision.
- [ ] No target-specific source, private endpoint, credential, package name,
  proprietary asset, or opaque initialization data has been reused.
