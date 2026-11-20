# Release Checklist — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Release/engineering owner to be assigned  
**Last updated:** 2026-10-26  
**Source of truth for:** Release evidence, go/no-go decisions, staged rollout,
rollback, and production release readiness  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/API_CONTRACT.md`, `docs/DOMAIN_MODEL.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`, `docs/TEST_PLAN.md`, `docs/COST_MODEL.md`,
`docs/PRODUCTION_READINESS_CHECKLIST.md`,
`legal/PRIVACY_POLICY.md`, `legal/TERMS_OF_SERVICE.md`,
`legal/COMMUNITY_GUIDELINES.md`

The master program tracker is `docs/PRODUCTION_READINESS_CHECKLIST.md`. This
document is the per-release gate, not a statement that the current local-first
Android MVP is production-ready. Every checked item must link to actual evidence
or an approved exception. A mock provider, seeded balance, local call simulator,
or debug APK must not be presented as a live production capability.

---

## 1. Release identity and decision record

```text
release_id:
product_version:
server_version:
environment: local | development | staging | production
commit_sha:
android_artifact_sha256:
api_contract_version:
schema_migration_range:
feature_flag_snapshot:
release_owner:
incident_commander:
start_time_utc:
planned_rollout_window_utc:
```

- [ ] Release scope, excluded capabilities, and feature flags are recorded.
- [ ] The target environment is isolated from unrelated environments.
- [ ] The commit, build inputs, artifact digests, migration range, and
      configuration version are recorded.
- [ ] The release owner, rollback authority, support contact, safety contact,
      finance contact, and incident commander are named.
- [ ] All unresolved exceptions have an owner, expiry date, mitigation, and
      explicit approval.

### 1.1 Release stage

Select exactly one:

- [ ] Local Android MVP / seeded data only.
- [ ] Development server-backed integration.
- [ ] Staging / closed beta rehearsal.
- [ ] Production non-paid release.
- [ ] Production paid release with approved purchases.
- [ ] Production host-earnings/payout release with approved finance and legal
      controls.

The selected stage controls which gated capabilities may be enabled.

---

## 2. Required approvals

| Area | Reviewer/owner | Evidence | Status |
| --- | --- | --- | --- |
| Product scope and acceptance | Product owner | Approved scope and test report | [ ] |
| Architecture and migrations | Engineering owner | ADRs, migration rehearsal, recovery plan | [ ] |
| Security | Security owner | Security review and findings | [ ] |
| Privacy and data retention | Privacy/legal owner | Data map, policy, deletion test | [ ] |
| Trust and safety | Safety owner | Moderation, appeals, emergency drill | [ ] |
| API compatibility | API owner | Contract schema and compatibility report | [ ] |
| Mobile/device | Mobile/QA owner | Device matrix and artifact evidence | [ ] |
| RTC/media | RTC owner | Provider, permission, reconnect, and outage tests | [ ] |
| Finance/payments | Finance owner | Ledger, receipt, refund, reconciliation evidence | [ ] |
| Host earnings/payouts | Finance/legal owner | Eligibility, tax, fraud, payout evidence | [ ] |
| Analytics | Analytics/privacy owner | Event validation and consent review | [ ] |
| Operations | Operations owner | Monitoring, alerts, runbook, on-call | [ ] |
| Disaster recovery | Operations/security owner | Restore/failover exercise evidence | [ ] |
| Store/legal links | Release/legal owner | Valid policies and store metadata | [ ] |

No capability should be enabled merely because its UI exists. Approval must
cover implementation, policy, provider configuration, testing, and operations.

---

## 3. Source, build, and artifact reproducibility

- [ ] Clean checkout/build instructions are documented.
- [ ] The build uses the approved toolchain versions.
- [ ] Dependencies are locked or otherwise reproducible.
- [ ] Static analysis, formatting, lint, type, compile, and test checks passed.
- [ ] Secret, target-identifier, prohibited-asset, and license checks passed.
- [ ] Debug logging, test endpoints, seeded production data, and development
      credentials are excluded from the release.
- [ ] Android manifest, permissions, exported components, deep links, network
      security, backup settings, and package identity were reviewed.
- [ ] Release artifact digest and provenance are recorded.
- [ ] Generated API clients, schemas, translations, and assets match the source
      revision.
- [ ] Crash reporting and symbol/mapping files are uploaded through the
      approved protected process.

### 3.1 Current MVP limitation

The current documented Android command is:

```bash
# From replica-android/
./build_apk.sh
```

This produces a debug artifact and does not satisfy production release gates.
Live RTC, billing, payouts, production moderation, global discovery, and
server-side authorization must not be claimed from that artifact.

---

## 4. Configuration, secrets, and environment safety

- [ ] Environment is explicitly identified in the build and server deployment.
- [ ] Local, development, staging, and production resources are separate.
- [ ] Secrets are injected from the approved secret manager or CI environment.
- [ ] No API keys, service-role keys, RTC secrets, billing credentials, signing
      keys, cookies, tokens, or private certificates are in source, fixtures,
      reports, screenshots, or logs.
- [ ] Client bundles contain only public configuration.
- [ ] Production URLs and production provider projects are blocked from local
      and test builds unless explicitly approved.
- [ ] Feature flags default to the safest state for the target environment.
- [ ] Rate limits, spending limits, payout limits, fraud thresholds, and kill
      switches are configured and tested.
- [ ] Key rotation, emergency disablement, and secret-exposure procedures are
      ready.

---

## 5. Database, migrations, and data integrity

- [ ] All schema changes are versioned migrations owned by the service.
- [ ] Migrations ran successfully on a clean database.
- [ ] Migrations ran successfully against a representative existing database.
- [ ] Constraints, indexes, ownership, RLS, retention flags, and audit tables
      were verified.
- [ ] Backfill duration, lock behavior, rollback/forward-fix, and recovery steps
      are documented.
- [ ] Backups are current and restore evidence is available.
- [ ] Financial records are not deleted to correct a calculation; compensating
      entries preserve the audit trail.
- [ ] Account deletion behavior distinguishes user-owned data from retained
      safety, legal, tax, fraud, and financial records.
- [ ] Queue, webhook, reconciliation, and deletion jobs are idempotent and have
      dead-letter/manual-recovery handling.

---

## 6. API, authorization, and compatibility

- [ ] `docs/API_CONTRACT.md` matches the executable contract/schema.
- [ ] Every protected route has authentication, ownership, role, and two-account
      authorization tests.
- [ ] Input validation, error codes, pagination, concurrency, rate limits, and
      idempotency tests passed.
- [ ] Breaking changes are versioned and supported-client compatibility is
      documented.
- [ ] Webhook signatures, provider event IDs, replay handling, and out-of-order
      behavior are tested.
- [ ] Health/readiness endpoints do not expose secrets or unnecessary internals.
- [ ] Logs and traces redact authorization headers, message bodies, private
      media URLs, receipts, and provider payloads.
- [ ] Unauthorized, blocked, deleted, suspended, and restricted-account cases
      return the documented safe behavior.

---

## 7. Mobile, permissions, accessibility, and media

- [ ] Supported Android versions/devices are documented.
- [ ] Fresh install, upgrade, relaunch, logout, session expiry, and account
      deletion were tested.
- [ ] Camera, microphone, notification, storage/media, Bluetooth, and other
      permissions have pre-permission explanation, denial, revocation, and
      settings-path behavior where applicable.
- [ ] Capture stops when the call or feature ends.
- [ ] Call, mute, camera, route, permission, reconnect, and recording states
      reflect actual state rather than button labels.
- [ ] No unsupported recording, beauty effect, overlay, background-call, or
      Bluetooth claim appears in UI or release notes.
- [ ] Touch targets, content descriptions, screen reader order, focus, contrast,
      large text, long names/messages, emoji, and localization were tested.
- [ ] Offline, slow, restored, and changing network behavior is recoverable.
- [ ] Notifications and deep links fail closed for malformed or unauthorized
      targets.

---

## 8. Trust, safety, and support

- [ ] Report, block, unblock, moderation, enforcement, appeal, and account
      restriction flows work in the release environment.
- [ ] Reporter identity and private evidence are not disclosed to the reported
      user.
- [ ] Moderator, support, finance, and infrastructure permissions are separate.
- [ ] Every moderation action records actor, reason, target, timestamp, scope,
      and audit reference.
- [ ] Age, host eligibility, geographic restrictions, and identity verification
      gates are enforced where applicable.
- [ ] Emergency escalation and legally required preservation procedures have a
      named owner and tested handoff.
- [ ] Support scripts cover account recovery, deletion, blocked users, reports,
      calls, refunds, failed purchases, and payout holds without exposing private
      data.
- [ ] Community guidelines, privacy policy, terms, refund/support links, and
      contact paths are valid for the release region.

---

## 9. Video-call and RTC gates

These items are required only when live calls are enabled.

- [ ] An approved RTC provider, project/namespace, and adapter are configured.
- [ ] RTC tokens are server-issued, short-lived, scoped to the exact call, and
      never minted from a client secret.
- [ ] Request, accept, reject, expire, cancel, connecting, connected,
      reconnecting, failed, and ended states are tested.
- [ ] Permission denial, unavailable hardware, token expiry, wrong scope,
      provider outage, reconnect, app backgrounding, and process death are tested.
- [ ] Server-confirmed billable start/stop evidence is defined and tested.
- [ ] Reconnect grace and settlement behavior are tested with duplicate and
      delayed events.
- [ ] Media privacy, recording policy, capture shutdown, and support evidence
      handling are approved.

---

## 10. Payments, wallet, earnings, and payout gates

These items are **Gated** unless the financial release has been approved.

- [ ] Product IDs, price/currency, taxes, store policy, refund, chargeback,
      and entitlement rules are approved.
- [ ] Server-side receipt validation and duplicate webhook handling passed.
- [ ] Wallet and ledger use integer minor units and append-only entries.
- [ ] Purchase fulfillment, call settlement, refunds, chargebacks, and negative
      adjustments are idempotent and reconciled.
- [ ] Rate-policy version is stored with each settlement.
- [ ] Insufficient balance, held funds, reversed earnings, payout failure,
      account suspension, fraud hold, and dispute behavior passed.
- [ ] Host identity, age/geography, tax, minimum threshold, payout schedule,
      and legal relationship are approved.
- [ ] Users and hosts see understandable transaction/earnings state without
      private payment payloads.
- [ ] Finance owner signs the reconciliation and release evidence.

---

## 11. Analytics, monitoring, and privacy

- [ ] Event names and properties match `docs/ANALYTICS_EVENTS.md`.
- [ ] Consent, regional controls, retention, deletion, and access controls are
      tested.
- [ ] Prohibited telemetry is absent: message bodies, private media tokens,
      payment receipts, auth headers, raw hardware identifiers, and unnecessary
      advertising identifiers.
- [ ] Crash, API, auth, messaging, RTC, moderation, payment, reconciliation,
      storage, database, queue, and provider dashboards are available.
- [ ] Alerts have severity, owner, threshold, runbook, and safe test evidence.
- [ ] Logs and dashboards do not expose secrets or unnecessary personal data.
- [ ] Cost and provider-usage dashboards are live before enabling costly paths.

---

## 12. Disaster recovery and operational readiness

- [ ] `docs/DISASTER_RECOVERY.md` tier, RTO, RPO, and degraded-mode decisions
      are approved for the release.
- [ ] Backup age, restore, failover, integrity, and reconciliation evidence is
      current.
- [ ] Deployment, migration, rollback/forward-fix, queue restart, webhook
      replay, provider outage, secret exposure, deletion failure, and cost-spike
      procedures have been rehearsed or marked blocked.
- [ ] On-call coverage, escalation paths, status communication, and support
      guidance are ready.
- [ ] Kill switches and safe degradation paths have been tested.
- [ ] The release can be paused without corrupting financial, safety, or account
      state.

---

## 13. Rollout and rollback

### 13.1 Staged rollout

- [ ] Internal test accounts only.
- [ ] Small closed beta cohort with monitoring.
- [ ] Gradual percentage rollout with stop thresholds.
- [ ] Region/provider/feature flag rollout reviewed.
- [ ] Spending, call-minute, traffic, moderation, and payout limits are active.
- [ ] Rollout owner watches the defined dashboards for the agreed observation
      window.

### 13.2 Stop conditions

Pause or roll back when any of the following occurs:

- unauthorized access or privacy leak;
- unsafe moderation/safety behavior;
- ledger imbalance, duplicate charge, duplicate payout, or reconciliation gap;
- elevated crash, startup, auth, message, notification, RTC, or deletion
  failure beyond the approved threshold;
- unexpected provider, storage, database, or traffic cost spike;
- backup, restore, alerting, or audit evidence failure; or
- a release gate is discovered to be unchecked or invalid.

### 13.3 Rollback decision

- [ ] Rollback target is identified and available.
- [ ] Database rollback versus forward-fix decision is explicit.
- [ ] Client/server compatibility during rollback is understood.
- [ ] In-flight calls, messages, purchases, webhooks, payouts, and deletion jobs
      have a safe handling plan.
- [ ] Support and safety communications are prepared.
- [ ] A post-rollback reconciliation and evidence review is assigned.

---

## 14. Go/no-go record

```text
decision: go | no-go | go-with-approved-exceptions
decision_time_utc:
release_owner:
approvers:
open_critical_defects:
open_high_defects:
approved_exceptions:
rollback_owner:
next_review_time_utc:
evidence_index:
notes:
```

- [ ] Every required checkbox is complete or has a named approved exception.
- [ ] No critical defect or unreviewed security/privacy/financial/safety issue
      remains.
- [ ] The decision and evidence index are retained with the release record.

---

## 15. Post-release checks

Within the agreed observation window:

- [ ] Crash-free startup/session behavior is within threshold.
- [ ] API latency, errors, auth failures, rate limits, and queue health are
      within threshold.
- [ ] Message delivery, notifications, RTC quality/reconnect, and call endings
      are within threshold.
- [ ] Reports, blocks, moderation queue, appeals, and support volume are within
      expected bounds.
- [ ] Purchases, refunds, webhooks, ledger, earnings, payouts, and
      reconciliation are reviewed when enabled.
- [ ] Cost and provider usage match the approved model.
- [ ] No unexpected sensitive data appears in logs, analytics, support evidence,
      or crash reports.
- [ ] Rollout is continued, paused, or reversed with a recorded decision.
- [ ] Follow-up defects, documentation updates, and incident reviews have
      owners and dates.

---

## 16. Approval checklist

- [ ] Release/engineering owner assigned.
- [ ] Release stage and scope approved.
- [ ] `docs/TEST_PLAN.md` evidence index attached.
- [ ] Security, privacy, safety, finance, operations, and legal approvals are
      recorded where applicable.
- [ ] Build, artifact, configuration, migration, and schema evidence is
      reproducible.
- [ ] Rollout, stop conditions, rollback/forward-fix, support, and incident
      procedures are ready.
- [ ] Any blocked test is explicit, owned, and excluded from claims of readiness.
