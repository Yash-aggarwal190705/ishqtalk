# Test Plan — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** QA/engineering owner to be assigned  
**Last updated:** 2026-10-26  
**Source of truth for:** Test strategy, release evidence, test data rules,
quality gates, and regression coverage for the independent product  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`, `docs/RELEASE_CHECKLIST.md`,
`docs/PRODUCTION_READINESS_CHECKLIST.md`,
`docs/CLEAN_ROOM_RULES.md`, `replica/test-plan.md`,
`replica-android/README.md`

This document defines how the independent product will be tested. It does not
claim that a provider, production environment, device, store sandbox, payment
flow, or live RTC integration is currently available. A check is **Passed** only
when the stated command or manual procedure actually runs and produces recorded
evidence.

---

## 1. Scope and decision labels

### 1.1 Product scope

The plan covers:

- startup, onboarding, consent, authentication, recovery, session management,
  logout, and account deletion;
- profiles, media, discovery, filters, relationships, follows, and matching when
  that capability is approved;
- conversations, messages, message state, notification delivery, and blocking;
- one-to-one call requests, acceptance, permissions, RTC connection, reconnect,
  billing evidence, and end-of-call settlement;
- credits, purchases, entitlements, refunds, chargebacks, host earnings, and
  payouts only when the corresponding financial gates are approved;
- reports, blocks, moderation actions, appeals, age/host eligibility, and
  emergency escalation;
- privacy, security, authorization, rate limits, audit records, analytics, and
  data deletion;
- deployment, migrations, backups, restore, provider failure, incident
  response, and operational recovery; and
- accessibility, localization, long content, offline behavior, and changing
  network conditions.

### 1.2 Decision labels

- **Required:** must be proven for the stated release stage.
- **Proposed:** a test or threshold suggested for approval.
- **Gated:** cannot run as a production test until the listed provider, legal,
  financial, safety, or operational decision is approved.
- **Blocked:** the test is designed but unavailable because a tool, account,
  device, provider, or environment is missing.
- **Deferred:** intentionally outside the current release.
- **Unknown:** not established; do not replace it with an unrecorded assumption.

### 1.3 Evidence labels

- **Automated evidence:** command output, test report, artifact digest, or CI
  record retained with the commit and environment.
- **Manual evidence:** tester, date, build, device/environment, steps, result,
  and a safe screenshot or log excerpt when useful.
- **Provider evidence:** sandbox response, webhook record, reconciliation result,
  or provider dashboard export with secrets and personal data removed.
- **Blocked evidence:** exact missing dependency and the reason the test could
  not be completed; blocked is not a pass.

---

## 2. Quality objectives and release stages

### 2.1 Quality objectives

The product must demonstrate that:

1. the server, not the client, decides authorization, balances, entitlements,
   call eligibility, moderation, and settlement;
2. retries, duplicate taps, repeated requests, app restarts, duplicate webhooks,
   delayed events, and out-of-order events do not create duplicate business
   effects;
3. failure states are understandable, recoverable, and safe for users;
4. sensitive data, payment data, messages, media, logs, analytics, and support
   evidence follow the approved security and privacy rules;
5. financial records remain balanced, append-only, auditable, and reconcilable;
6. safety reports, blocks, enforcement actions, appeals, and operator access are
   private, authorized, and auditable; and
7. the release can be built, deployed, monitored, restored, rolled back, or
   forward-fixed using documented procedures.

### 2.2 Release stages

| Stage | Required evidence | Allowed dependencies | Explicit exclusions |
| --- | --- | --- | --- |
| Local Android MVP | Unit tests, deterministic UI smoke checks, build artifact, seeded-data checks | Fake providers, local data | Production auth, live RTC, real money, payouts |
| Server-backed development | API contract, repository, authorization, migration, job, and provider-adapter tests | Synthetic accounts and sandbox/fake providers | Production PII, production billing, production payout |
| Staging / closed beta | Full regression, device matrix, security/privacy checks, recovery rehearsal, support/safety drills | Isolated staging resources and approved test accounts | Unapproved external users or production funds |
| Production paid release | All required automated and manual evidence, legal/store/finance/safety approvals, rollback plan | Approved production providers and secrets | Any unchecked gated capability |

### 2.3 Entry and exit criteria

Before testing begins for a release:

- the scope, build, environment, commit, feature flags, and test accounts are
  recorded;
- the relevant migrations and seed data are reproducible;
- test providers are fake, sandbox, or explicitly approved for the environment;
- secrets are injected through approved local/CI configuration and are not in
  fixtures, logs, screenshots, or reports; and
- known blockers and deferred capabilities are listed.

A release exits testing only when:

- all required checks pass or have an approved, time-bound exception;
- no open critical or high-severity defect violates safety, authorization,
  privacy, data integrity, or financial correctness;
- the release checklist contains links to actual evidence;
- blocked tests are accepted by the named owner and do not hide a release gate;
  and
- rollback, recovery, support, and incident contacts are ready.

---

## 3. Test layers and ownership

| Layer | Main purpose | Owner | Required for |
| --- | --- | --- | --- |
| Static checks | Formatting, type checks, schema validation, secret scans, dependency checks | Engineering | Every change |
| Unit tests | Rules, validation, state machines, pricing, rounding, authorization decisions | Module owner | Every domain change |
| Repository/integration tests | Database constraints, RLS, migrations, queues, webhooks, provider adapters | Backend/data owner | Server-backed releases |
| Contract tests | Request/response shape, error codes, compatibility, idempotency, pagination | API owner | Every API change |
| Security/privacy tests | Access isolation, deletion, redaction, rate limits, abuse controls | Security owner | Server-backed and paid releases |
| Device tests | Permissions, media, lifecycle, connectivity, accessibility, localization | Mobile/QA owner | Call and store releases |
| End-to-end tests | User journeys across client, API, jobs, notifications, providers, and support tools | QA/release owner | Staging and production paid release |
| Operational tests | Deploy, migrate, rollback, backup, restore, alerts, reconciliation, incident drills | Operations owner | Staging and production |

No test layer may be used to silently substitute for a missing higher-risk
server-side test. For example, a client test cannot prove purchase fulfillment,
ledger correctness, payout eligibility, moderation authorization, or account
deletion completion.

---

## 4. Test environments and data

### 4.1 Environment rules

| Environment | Data | Providers | Purpose |
| --- | --- | --- | --- |
| Local | Seeded and synthetic only | Fakes/stubs by default | Fast development and deterministic tests |
| Development | Synthetic accounts; approved test PII only | Sandbox or fake providers | Integration and feature work |
| Staging | Isolated test data; documented test accounts | Sandbox or isolated projects | Release rehearsal and device testing |
| Production | Real user data subject to policy | Approved production providers | Real operation only after release approval |

Never point local or test builds at production billing, payout, moderation,
private user data, or private provider projects without explicit documented
approval.

### 4.2 Test data requirements

Fixtures should cover:

- normal, unverified, age-ineligible, suspended, deleted, blocked, and
  restricted accounts;
- user, host, moderator, support, finance, and infrastructure roles;
- long names, emoji, translated text, empty strings, boundary lengths, invalid
  Unicode, and right-to-left text where localization supports it;
- unread, read, delivered, failed, pending, deleted, and moderated messages;
- every call lifecycle state, reconnect attempt, provider error, and permission
  result;
- insufficient balance, pending purchase, refund, chargeback, held earnings,
  available earnings, reversed settlement, and payout failure;
- reports with private reporter data, multiple evidence types, appeals, and
  enforcement history; and
- duplicate, delayed, missing, reordered, malformed, and replayed webhook/job
  inputs.

Fixtures must use opaque synthetic identifiers. They must not contain real
passwords, tokens, payment receipts, message bodies copied from users, private
media, target-app data, or production identifiers.

### 4.3 Clock and network control

Tests must be able to control or record:

- UTC time and timezone conversion;
- token expiration and clock skew;
- delayed jobs and webhook arrival order;
- network loss, latency, packet loss, reconnect, and offline-to-online return;
- provider timeout, rate limit, partial response, and outage; and
- app backgrounding, process death, device restart, and resumed sessions.

---

## 5. Static and unit-test coverage

### 5.1 Static checks

Every change should run the narrowest applicable checks for:

- compilation, type checking, linting, and formatting;
- migration syntax, schema validation, OpenAPI validation, and JSON/CSV parsing;
- dependency vulnerability and license policy checks;
- secret and credential-pattern scans;
- prohibited target identifier and proprietary-asset scans;
- generated-client or generated-schema drift; and
- documentation links, code fences, required metadata, and stale references.

### 5.2 Domain rules

Unit tests must cover:

- account and session state transitions;
- profile visibility, relationship transitions, block precedence, and deleted
  account behavior;
- message validation, ordering, idempotency, moderation state, and retry
  classification;
- call state transitions, acceptance expiry, reconnect grace, billable-state
  boundaries, and terminal-state idempotency;
- integer minor-unit arithmetic, rounding, rate-policy versioning, insufficient
  balance, refunds, chargebacks, compensating entries, and ledger balance;
- host eligibility, held/available/reversed earnings, payout thresholds, and
  fraud holds;
- report severity, enforcement scope, appeals, evidence visibility, and
  moderator capability boundaries;
- analytics consent, allowlisted properties, redaction, retention, and event
  version compatibility; and
- account deletion classification, legal/financial retention, and job retries.

### 5.3 Property and invariant tests

Where practical, use property-based or table-driven tests to prove that:

- applying the same idempotency key twice produces one business effect;
- ledger entries remain balanced after every successful posting;
- compensating entries preserve the original audit trail;
- blocked accounts cannot create newly authorized interactions;
- a terminal call cannot return to a billable state;
- pagination cursors do not duplicate or silently skip records under the stated
  consistency model; and
- redaction never emits secrets, authorization headers, private message bodies,
  or payment payloads.

---

## 6. Repository, migration, API, and job tests

### 6.1 Database and migration tests

For every migration:

1. apply it to a clean database;
2. apply it to a representative prior schema and data set;
3. verify constraints, indexes, ownership, RLS, and backfills;
4. measure lock and backfill behavior for the expected data volume;
5. test rollback or the documented forward-fix path; and
6. run representative reads and writes before and after the migration.

Financial and safety data must not be deleted merely to make a migration pass.

### 6.2 API contract tests

Each protected route requires:

- valid request and response examples;
- malformed, missing, oversized, and unauthorized input tests;
- two-account ownership and role-boundary tests;
- stable error-code and user-safe-message tests;
- idempotency, retry, timeout, and concurrency tests where applicable;
- pagination and cursor-expiry tests for collections; and
- compatibility tests for supported client versions.

The executable contract must eventually be generated or validated from
`contracts/openapi/v1/openapi.yaml`; until that file exists, the API document is
the draft source of truth and the missing executable contract is a release gap.

### 6.3 Jobs and webhooks

Every retryable job and provider webhook must be tested for:

- signature or authenticity verification;
- duplicate delivery;
- delayed and out-of-order delivery;
- malformed or unsupported version;
- timeout and retry backoff;
- dead-letter or manual recovery;
- safe replay after partial completion; and
- audit records that exclude unnecessary provider payload data.

---

## 7. Security, privacy, and trust-and-safety tests

### 7.1 Authorization and privacy

Required server-side cases include:

- unauthenticated access to every protected route;
- cross-account reads and writes for profiles, media, messages, calls, reports,
  wallet data, earnings, support cases, and audit records;
- role separation between moderator, support, finance, and infrastructure
  administration;
- expired, revoked, malformed, and wrong-audience tokens;
- rate limits for authentication, recovery, messaging, reports, uploads, calls,
  token issuance, purchases, and webhook endpoints;
- log, analytics, crash-report, support, and screenshot redaction;
- export, deletion, retention, legal hold, and financial-record exceptions; and
- blocked, suspended, deleted, and restricted account behavior.

### 7.2 Safety and abuse

Test that:

- reports do not reveal reporter identity to the reported user;
- blocks prevent the documented interaction categories in both directions;
- moderators see only the minimum evidence allowed by role and case scope;
- enforcement actions are reasoned, timestamped, actor-attributed, and audited;
- appeals cannot bypass an active restriction without an authorized decision;
- emergency escalation preserves evidence and follows the documented handoff;
  and
- spam, harassment, impersonation, scams, collusion, self-dealing, and account
  farming controls fail closed or route to review as documented.

---

## 8. Video-call and device testing

### 8.1 Call flow matrix

At minimum, test each transition in the approved call state machine:

| Scenario | Expected result |
| --- | --- |
| Request accepted | Server records acceptance and client enters connecting state |
| Request rejected, expired, or canceled | No RTC token is usable and no billable state begins |
| Camera permission granted/denied/revoked | UI reflects the real state and offers a safe fallback/settings path |
| Microphone permission granted/denied/revoked | Call remains safe and mute/permission status is accurate |
| RTC token expired or wrong scope | Provider access fails closed and the user sees a recoverable error |
| Network loss during connection | State becomes reconnecting or failed according to policy |
| Network loss while connected | Reconnect grace and billing behavior match the approved rules |
| App background/process death | Server state remains authoritative and no duplicate settlement occurs |
| Hang-up from either side | Terminal state is recorded once and resources are released |
| Provider outage | New calls are blocked or degraded without corrupting call or ledger state |

### 8.2 Device and accessibility matrix

The supported device matrix must include approved Android API levels, screen
sizes, portrait/landscape behavior where supported, camera/microphone hardware,
Bluetooth/audio routes where supported, slow network, denied permissions, large
font size, screen reader navigation, contrast, touch targets, and localization.

Do not claim that recording, beauty effects, overlays, Bluetooth routing,
background calls, or a specific provider works until the corresponding device
test has passed.

---

## 9. Payments, earnings, and reconciliation tests

These tests are **Gated** until financial policy, store/provider configuration,
tax/legal review, and a server-side ledger exist.

Required cases include:

- product/catalog version mismatch;
- valid, invalid, duplicate, delayed, refunded, and chargeback purchase events;
- receipt verification failure and provider outage;
- fulfillment retry with one entitlement and one ledger effect;
- insufficient balance before and during a call;
- rate-policy version captured for every settlement;
- disconnect, reconnect, timeout, app close, and provider callback ordering;
- negative adjustment and compensating entry without editing posted history;
- earnings held, released, reversed, disputed, and payout-failed;
- payout threshold, identity/eligibility hold, fraud hold, and tax state;
- reconciliation mismatch detection and safe manual recovery; and
- user-facing transaction history that excludes private payment payloads.

Client-only tests do not satisfy purchase, settlement, refund, chargeback, or
payout release gates.

---

## 10. Analytics and operational testing

### 10.1 Analytics

Verify that:

- only allowlisted event names and properties are emitted;
- consent and regional policy gates are honored;
- identifiers are opaque and scoped as documented;
- message bodies, media URLs with private tokens, receipts, auth headers, and
  raw device identifiers are not emitted;
- event versions are backward-compatible or migrated intentionally;
- deletion and retention jobs remove or anonymize eligible analytics records;
  and
- dashboards use documented definitions and access controls.

### 10.2 Operations

Test:

- readiness and liveness behavior during dependency failure;
- alert thresholds without exposing sensitive data;
- deployment, migration, rollback, and forward-fix procedures;
- queue restart, dead-letter recovery, webhook replay, and reconciliation;
- backup age checks, restore, failover, and integrity validation;
- incident severity, ownership, communication, and closure evidence; and
- cost-spike, provider-outage, secret-exposure, deletion-failure, and ledger-
  mismatch response procedures.

---

## 11. End-to-end journey matrix

| Journey | Happy path | Important failures/abuse cases | Required stage |
| --- | --- | --- | --- |
| Startup and consent | User sees independent branding, consent, and recoverable startup state | Offline, corrupt session, denied notification, unsupported version | Local MVP |
| Authentication | User creates/restores a session and can log out | Brute force, expired token, recovery abuse, duplicate request | Server-backed MVP |
| Profile and discovery | User creates a profile and browses eligible profiles | Blocked/deleted profile, invalid media, pagination, privacy setting | Server-backed MVP |
| Messaging | User sends, receives, retries, and reads a message | Duplicate tap, blocked user, moderation hold, notification failure | Server-backed MVP |
| Report and block | User reports and blocks another account | Reporter privacy, duplicate report, appeal, moderator boundary | Server-backed MVP |
| Call request | Eligible parties request, accept, connect, reconnect, and end a call | Permission denial, provider failure, app death, duplicate settlement | Staging; paid flow gated |
| Purchase | Approved sandbox purchase fulfills once | Invalid receipt, delayed webhook, refund, chargeback, outage | Paid release only |
| Host earnings | Eligible host sees pending/available/reversed state | Fraud hold, payout failure, dispute, reconciliation mismatch | Paid release only |
| Account deletion | User receives status and eligible data is removed | Job retry, legal hold, financial retention, partial failure | Server-backed MVP |
| Operations | Operator deploys, monitors, recovers, and records evidence | Rollback, backup restore, provider outage, incident escalation | Staging and production |

---

## 12. Defect management and evidence

### 12.1 Severity

- **Critical:** data loss, unauthorized access, secret exposure, unsafe
  interaction, ledger corruption, duplicate money movement, or inability to
  recover production data.
- **High:** broken core journey, incorrect permission, privacy leak, moderation
  bypass, failed account deletion, or release-blocking provider behavior.
- **Medium:** important degraded behavior with a safe workaround.
- **Low:** cosmetic, copy, or low-impact usability issue without safety or data
  integrity impact.

Critical and high issues require an owner, reproduction evidence, affected
versions/environments, mitigation, and release decision. Do not close a defect
by weakening a test or hiding the failure.

### 12.2 Minimum evidence record

Every release-relevant check should record:

```text
test_id:
build_commit:
environment:
device_or_runtime:
data_fixture:
provider_mode:
started_at_utc:
finished_at_utc:
command_or_steps:
result: passed | failed | blocked | skipped
failure_or_blocker:
evidence_location:
owner:
```

Evidence must exclude credentials, authorization headers, private message
bodies, private media, full payment payloads, and unnecessary personal data.

---

## 13. Current commands and known limitations

The existing Android MVP documents these checks:

```bash
# From replica-android/
./build_apk.sh

# Optional only when Appium and an authorized device are available
python3 e2e/orbitra_smoke.py
```

The production service test, lint, migration, API-contract, provider-sandbox,
store-sandbox, and device commands are **Unknown** until the service layout and
toolchain are approved. Do not invent a passing result or claim live RTC,
billing, payout, notification, or background behavior from the Android build
alone.

Known local blockers include unavailable or unapproved device/runtime access,
missing production provider accounts, missing executable OpenAPI contract, and
the local-first MVP's lack of production backend integrations.

---

## 14. Open decisions before approval

1. Supported Android versions, devices, screen readers, and localization set.
2. Backend language/framework, service test commands, and CI runner policy.
3. Database engine, migration runner, representative data volume, and RLS test
   harness.
4. Authentication and account-recovery provider/test strategy.
5. RTC provider and supported network/device matrix.
6. Store sandbox, receipt-validation, refund, chargeback, and payout test
   accounts.
7. Moderation staffing, response SLAs, emergency escalation, and test evidence
   access.
8. Analytics provider, consent regions, retention automation, and dashboard
   ownership.
9. Performance, load, latency, crash-free, delivery, and reconciliation
   thresholds for each release stage.
10. Evidence storage, retention, access, and redaction automation.

---

## 15. Approval checklist

- [ ] QA/engineering owner assigned.
- [ ] Product scope and release stage approved.
- [ ] Test environments and synthetic fixtures are reproducible.
- [ ] Static, unit, repository, contract, security, device, and operational
      checks have owners.
- [ ] Authorization, deletion, safety, financial, and idempotency tests are
      server-side where required.
- [ ] Android permission, accessibility, localization, network, and lifecycle
      matrix is approved.
- [ ] Provider sandbox/store sandbox accounts are available where gated tests
      are approved.
- [ ] Test evidence is redacted, retained, and linked from the release record.
- [ ] Critical/high defect policy and exception process are approved.
- [ ] `docs/RELEASE_CHECKLIST.md` is complete for the target release.
- [ ] Unavailable tests are marked blocked with owners and dates.
