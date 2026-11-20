# Disaster Recovery — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Infrastructure/SRE owner to be assigned; engineering, security,
privacy, finance, safety, support, and provider owners required  
**Last updated:** 2026-10-25  
**Source of truth for:** Recovery objectives, backups, restore, failover,
service/data-loss response, disaster exercises, and recovery evidence  
**Related documents:** `AGENTS.md`, `docs/ARCHITECTURE.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/API_CONTRACT.md`, `docs/DOMAIN_MODEL.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0005-data-retention.md`

This document defines an independent recovery plan. It does not authorize
access to target services, private accounts, credentials, or target runtime
data. Recovery procedures must use the product's own environments, providers,
backups, keys, and data.

Recovery is not complete when servers respond. It is complete when data
integrity, authorization, financial invariants, safety controls, deletion state,
provider reconciliation, monitoring, and user support are verified.

---

## 1. Recovery objectives and decision labels

### 1.1 Objectives

The recovery program must:

1. Restore critical user access and safe application behavior after a service,
   provider, region, data, credential, or operational failure.
2. Protect confidentiality and integrity during backup, restore, failover, and
   manual recovery.
3. Prevent duplicate messages, calls, purchases, ledger entries, refunds,
   payouts, moderation actions, or deletion effects after replay.
4. Preserve enough evidence to reconcile delayed or missing provider events.
5. Provide explicit degraded/disabled behavior rather than silently losing
   authorization or financial state.
6. Test restore procedures before a real disaster.

### 1.2 Decision labels

- **Required:** must be implemented and evidenced before production.
- **Proposed:** initial target awaiting capacity, business, and provider review.
- **Gated:** not ready until the listed dependency or test exists.
- **Blocked:** cannot be verified because a tool, provider, credential, device,
  or owner is unavailable.
- **Unknown:** not established; record rather than invent.

### 1.3 Recovery scope

In scope:

- API and worker services;
- authentication/session configuration;
- relational database and migrations;
- object storage and media metadata;
- queues, cache, rate-limit, outbox, idempotency, and webhook records;
- RTC, push, email, billing, payout, moderation, and analytics integrations;
- secrets, signing keys, certificates, and deployment configuration;
- monitoring, alerts, support/safety/finance operations; and
- user-facing deletion, privacy, financial, and safety state.

---

## 2. Recovery objectives and service tiers

Exact targets require capacity and business approval. The following are proposed
starting points, not production commitments.

### 2.1 Service tiers

| Tier | Systems | Proposed RTO | Proposed RPO | Recovery priority |
| --- | --- | ---: | ---: | --- |
| Tier 0 | Auth boundary, authorization, database integrity, ledger, deletion/safety controls | 1 hour | 5 minutes or provider-defined durable point | First; fail closed if unavailable |
| Tier 1 | API, messaging, call control, webhook ingress, queues | 4 hours | 15 minutes | Restore safe core product |
| Tier 2 | Storage/media, notifications, discovery projections, support | 12 hours | 1 hour | Restore dependent features |
| Tier 3 | Analytics, noncritical reports, experiments, historical projections | 24–72 hours | 24 hours | Restore after integrity/core access |

RTO is the target time to restore an acceptable service state. RPO is the
maximum acceptable data loss window. Neither target permits losing or duplicating
financial, safety, authorization, or deletion state without review.

### 2.2 Degraded-mode policy

During recovery, the product may:

- disable discovery, messaging, calls, uploads, purchases, payouts, or selected
  notifications;
- serve read-only public projections;
- keep accepted messages pending delivery;
- keep purchases/calls/settlements in pending or reconciliation state;
- defer noncritical analytics and jobs; and
- show support/status guidance.

The service must not enable writes that cannot be authorized, deduplicated,
audited, reconciled, or rolled back safely.

### 2.3 Recovery completion criteria

Recovery is complete only after:

- critical health and readiness checks pass;
- authentication and authorization tests pass;
- database/RLS/ownership checks pass;
- idempotency/outbox/webhook queues are reconciled;
- financial invariants and provider records reconcile;
- safety cases and block/restriction state are consistent;
- account deletion jobs and retention exceptions are safe;
- media/storage access and deletion are verified;
- monitoring/alerts and on-call ownership are active; and
- support/user communication is current.

---

## 3. Dependency and recovery map

### 3.1 Critical dependency classes

| Dependency | Failure impact | Safe fallback |
| --- | --- | --- |
| Authentication | Users cannot sign in or refresh sessions | Fail closed; preserve existing safe sessions only if policy allows |
| Database | Most reads/writes unavailable | Read-only/cache only if authorization and freshness are safe |
| Object storage | Media unavailable or uploads fail | Disable upload/media; preserve metadata and retry |
| Queue/outbox | Notifications, deletion, webhook, reconciliation delay | Keep source state; retry/dead-letter safely |
| RTC provider | Calls cannot connect or recover | Disable new calls; keep application state/reconcile existing calls |
| Store/billing provider | Purchases/refunds uncertain | Keep pending; do not grant or remove value prematurely |
| Payout provider | Payouts uncertain | Disable new payouts; preserve available earnings and pending states |
| Push/email | User notification delayed | In-app refresh/support path; do not change business state |
| Moderation provider | Safety review delayed | Hold/restrict high-risk content/features; safety manual fallback |
| Analytics/crash | Metrics delayed | Core product continues; buffer/drop only approved analytics |
| Secret manager | New deploy/provider auth unavailable | Keep existing safe service if possible; do not embed secrets |
| DNS/edge/network | Traffic cannot reach API | Failover/maintenance page/status communication |

### 3.2 Dependency inventory

Before production, maintain an inventory with:

```text
service/provider
environment
owner/backup
region
data categories
credentials/secret references
contract/support path
status page/health signal
RTO/RPO dependency
failover/fallback
restore/reconciliation procedure
last exercise date
```

### 3.3 Recovery authority

The incident commander coordinates recovery. Service owners decide technical
steps within their capability. Security/privacy, finance, safety, and legal
owners approve decisions involving secrets, personal data, financial state,
moderation evidence, retention, or external notifications.

---

## 4. Backup policy

### 4.1 What must be backed up

Back up or otherwise durably preserve, according to approved policy:

- database data and migration history;
- ledger, purchase, entitlement, earning, payout, refund, and webhook records;
- account deletion, safety case, moderation, audit, and consent records;
- object-storage metadata and approved media;
- configuration and feature-control state;
- infrastructure/deployment definitions;
- safe observability and incident references; and
- key/secret recovery metadata without copying secret values into the backup
  record.

Do not back up unnecessary caches, temporary upload data, raw tokens, ephemeral
RTC tokens, full logs with private bodies, or unapproved production data.

### 4.2 Backup classes

| Class | Examples | Recovery purpose |
| --- | --- | --- |
| Continuous/point-in-time | Primary database, ledger | Short RPO and corruption recovery |
| Scheduled snapshot | Database, storage metadata | Routine restore and rollback point |
| Object replication | Approved media/storage | Media availability and regional recovery |
| Configuration backup | Infrastructure, migrations, safe config | Rebuild environment |
| Audit/financial archive | Ledger/audit/finance reconciliation | Integrity, tax, legal, support |
| Secret recovery | Secret-manager version/rotation metadata | Credential recovery without plaintext export |

### 4.3 Backup controls

- Encrypt backups at rest and in transit.
- Use separate backup credentials and access roles.
- Keep backup destinations separate from the primary environment.
- Apply retention, legal hold, and deletion schedules.
- Record creation time, source version, environment, encryption state, and
  verification result.
- Test restore rather than relying on successful backup completion.
- Monitor backup age, size, failure, and unexpected change.
- Prevent backup data from entering development or personal devices.
- Require approval for backup export or restore into a nonproduction environment.

### 4.4 Backup verification

Every backup check should verify:

- job completed;
- expected data/schema version exists;
- encryption/access policy is active;
- checksum or provider integrity check passes;
- retention/expiry is correct; and
- a restore sample or full restore test is scheduled/performed.

A green backup job without restore evidence is not production recovery evidence.

---

## 5. Restore and failover procedure

### 5.1 Restore decision

Before restoring, the incident commander and service owner determine:

- incident scope and suspected corruption/loss;
- safe recovery point and expected data loss;
- whether to restore in place, to a parallel environment, or to a new region;
- read-only/degraded mode;
- affected providers and credentials;
- financial/safety/deletion hold requirements;
- user/support communication; and
- rollback/forward-fix path.

Do not overwrite the only copy of evidence or production data before preserving
the recovery point and incident references.

### 5.2 Standard database restore

1. Declare incident and restrict changes to the affected system.
2. Preserve current state, logs, provider references, and recovery metadata.
3. Select an encrypted verified backup/point-in-time recovery point.
4. Restore to an isolated environment where practical.
5. Verify schema/migration version and extension/configuration compatibility.
6. Run integrity, ownership/RLS, ledger-balance, audit, deletion, and safety
   record checks.
7. Reconcile outbox, idempotency, webhook, job, and provider event records.
8. Test authentication and two-account authorization.
9. Compare safe counts/checksums with expected baselines.
10. Approve cutover or forward-fix.
11. Drain/replay queues with bounded idempotent batches.
12. Monitor and communicate recovery.

### 5.3 Storage/media restore

Restore metadata and objects in an order that prevents unauthorized access:

1. Restore private bucket/namespace and access policy.
2. Restore metadata/ownership/moderation/retention state.
3. Verify signed URL and authorization behavior.
4. Restore approved objects or replicate from verified source.
5. Scan or revalidate objects where required.
6. Rebuild thumbnails/search/cache only after primary authorization works.
7. Process missing/expired/held objects as safe unavailable projections.
8. Verify deletion and legal-hold exceptions.

### 5.4 Configuration and secret recovery

- Restore configuration from a verified version, not an unreviewed local copy.
- Restore secret-manager references and rotate credentials when compromise is
  possible.
- Verify environment, audience, region, provider, and database target.
- Never place secret values in a recovery ticket or Markdown document.
- Re-test token signing, webhook verification, database access, RTC tokens,
  billing/payout credentials, and push/email after rotation.

### 5.5 Failover and cutover

Before cutover:

- confirm the target region/environment is isolated and authorized;
- ensure database and storage consistency;
- verify auth keys/audience and API base URL;
- test migrations, RLS, idempotency, queues, and health;
- disable or route provider actions safely;
- update DNS/edge/feature control with an audited change; and
- notify support and incident stakeholders.

After cutover:

- monitor errors, latency, auth, messages, calls, purchases, jobs, safety, and
  deletion;
- reconcile events created around the cutover boundary;
- prevent split-brain writes;
- preserve old environment read-only until recovery is verified; and
- record exact cutover time and source/target versions.

---

## 6. Disaster scenarios and response

### 6.1 Database corruption or accidental deletion

- Freeze risky writes and declare SEV-1/SEV-2 according to impact.
- Preserve current database, logs, audit, and provider evidence.
- Determine last known good point and affected tables/aggregates.
- Restore isolated copy and run integrity/RLS/ledger/safety/deletion checks.
- Reconcile commands/events after the recovery point.
- Cut over or forward-fix with finance/safety/privacy approval where affected.

### 6.2 Region or hosting outage

- Confirm provider/region outage and expected recovery.
- Enable approved degraded/maintenance mode.
- Fail over only if target is current, tested, and authorized.
- Disable duplicate writes and provider actions during transition.
- Reconcile requests/events across outage and cutover windows.
- Keep user/support communication accurate and time-stamped.

### 6.3 Secret, signing-key, or certificate compromise

- Revoke/rotate affected secret/key/certificate.
- Determine whether tokens, webhooks, provider access, or APK/build artifacts
  were exposed.
- Reissue/revoke sessions or provider grants as needed.
- Validate environment/audience and inspect access logs.
- Follow security/privacy incident response and provider notification assessment.
- Do not restore compromised secrets from backup without rotation.

### 6.4 Ransomware or unauthorized data modification

- Isolate affected systems and preserve evidence.
- Stop propagation, credentials, jobs, and provider access as appropriate.
- Do not destroy evidence or restore over the only copy.
- Use clean infrastructure and verified backups.
- Rotate credentials and validate integrity before reconnecting.
- Review privacy, financial, safety, and legal impact.

### 6.5 Billing/store/payout outage

- Disable affected fulfillment, refund, settlement, or payout commands if
  correctness is uncertain.
- Preserve pending requests and provider event IDs.
- Do not grant/remove value based on client callbacks.
- Reconcile after provider recovery and process idempotently.
- Finance approves release, compensating entries, or user/host communication.

### 6.6 RTC outage

- Disable new calls or token issuance if provider authorization is unreliable.
- Keep application call state and safety controls available.
- Avoid charging/paying from missing or contradictory provider evidence.
- Preserve pending/reconciliation states.
- Reconcile join/leave/callback data after recovery.

### 6.7 Moderation/safety system outage

- Keep report intake available if it can be safely queued.
- Route critical cases to the approved manual/emergency channel.
- Restrict high-risk content/features if review cannot occur.
- Protect reporter identity and evidence.
- Restore queue processing with deduplication and audit.

### 6.8 Account deletion or retention outage

- Keep deletion status pending and stop new sensitive actions as required.
- Preserve deletion request and exception records.
- Retry failed steps idempotently.
- Verify provider/cache/search/analytics/storage cleanup.
- Escalate privacy/legal owner if approved timelines may be missed.

---

## 7. Data integrity and reconciliation after recovery

### 7.1 Integrity checks

Run checks for:

- database schema/migration version;
- foreign-key and ownership constraints;
- RLS/repository authorization;
- account/session status;
- conversation participants and message sequence;
- call state transitions and provider references;
- ledger balance and immutable entries;
- purchase/entitlement idempotency;
- earning/payout state and holds;
- safety case/action consistency;
- outbox/job/webhook deduplication;
- deletion and retention state; and
- notification/device revocation.

### 7.2 Replay rules

Replay only events/commands that have:

- trusted source and event ID;
- validated signature/schema where applicable;
- known target and policy version;
- idempotency/deduplication record;
- safe ordering/transition; and
- owner approval for financial, safety, deletion, or provider effects.

When uncertain, keep the effect pending and create a reconciliation case. Never
replay by creating new client idempotency keys blindly.

### 7.3 User-visible verification

After recovery, verify representative test accounts for:

- login/logout/session revocation;
- profile/discovery/relationship;
- conversation/message/read state;
- call request/accept/token/end state;
- report/block/enforcement;
- wallet/purchase/settlement projections if enabled;
- host earnings/payout state if enabled; and
- deletion status.

Use synthetic or approved test accounts and do not inspect unrelated user content.

---

## 8. Communication and support during recovery

### 8.1 Internal update

Every recovery update states:

- incident and recovery phase;
- affected services and users;
- known data/integrity impact;
- controls currently enabled/disabled;
- next action and owner;
- next update time; and
- support/safety/finance guidance.

### 8.2 User/support messaging

Messages must be accurate, minimal, accessible, and free of secrets or internal
security details. Explain pending/retryable states for:

- messages and notifications;
- calls and reconnects;
- purchases/refunds/payouts;
- reports and appeals; and
- account deletion.

Do not claim no data loss, no financial impact, or legal compliance before the
appropriate owner completes the assessment.

### 8.3 Privacy/legal assessment

Escalate suspected personal-data access/loss, reporter disclosure, identity or
payment exposure, deletion failure, or safety evidence exposure to security and
privacy/legal owners. Engineering must preserve evidence and follow instructions
without independently deciding notification obligations.

---

## 9. Recovery exercises and evidence

### 9.1 Exercise types

Run, at minimum:

- quarterly database restore sample;
- periodic full database/queue/outbox recovery rehearsal;
- object-storage restore and signed-URL test;
- secret/key rotation exercise;
- provider outage/tabletop for RTC, billing, payout, push, and moderation;
- account deletion/retention exception test;
- ledger/purchase/reconciliation replay test; and
- incident communication and on-call exercise.

The final frequency depends on risk, provider, and release approval.

### 9.2 Exercise record

Record:

```text
exercise_id
date/time_utc
scope/environment
scenario
participants/owners
backup/recovery_point
expected_rto/rpo
actual_restore/recovery_time
data/integrity checks
issues/blockers
corrective actions
owner/due date
next exercise
```

Do not use real user data in exercises unless explicitly approved, protected,
and necessary. Prefer synthetic or isolated copies.

### 9.3 Recovery evidence standard

Evidence must show the command/check, environment, result, timestamp, version,
owner, and safe references. Screenshots alone are insufficient for ledger,
authorization, deletion, or backup integrity claims.

---

## 10. Testing and approval gates

Before production:

- [ ] RTO/RPO and service tiers are approved.
- [ ] Critical dependencies and owners are inventoried.
- [ ] Database, storage, configuration, secret, and audit backup policies exist.
- [ ] Backup age/health and restore tests are monitored.
- [ ] Database restore passes schema, RLS, ownership, and ledger checks.
- [ ] Queue/outbox/webhook/idempotency replay is safe.
- [ ] Provider failover/degraded behavior is documented and exercised.
- [ ] Account deletion, safety retention, financial records, and privacy holds are recoverable.
- [ ] User/support/finance/safety communication paths are ready.
- [ ] Incident commander and recovery owners are assigned.
- [ ] Exercises produce evidence and tracked corrective actions.
- [ ] No target-specific data, credentials, providers, endpoints, or artifacts are used.

---

## 11. Open decisions

1. Final RTO/RPO by service and data class.
2. Hosting/database/storage region and failover topology.
3. Backup frequency, retention, encryption, and cross-region strategy.
4. Restore authority, approval, and production access model.
5. Provider failover and degraded-mode behavior for RTC, billing, payout,
   moderation, push, email, and analytics.
6. Maximum acceptable loss/delay for messages, calls, notifications, purchases,
   earnings, payouts, safety cases, and deletion state.
7. Recovery exercise frequency and independent review requirement.
8. Disaster communication, status page, support, privacy/legal, and regulator
   escalation channels.
9. Data residency, backup transfer, legal-hold, and deletion requirements.
10. Cost budget for redundant infrastructure and recovery storage.
