# Operations Runbook — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Operations/SRE owner to be assigned; engineering, security, privacy,
safety, finance, support, and provider owners required  
**Last updated:** 2026-10-25  
**Source of truth for:** Environments, deployments, monitoring, alerts,
incidents, jobs, provider operations, moderation/finance handoffs, support,
maintenance, and production response  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/DISASTER_RECOVERY.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/TEST_PLAN.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`

This is an independent product operations draft. It does not authorize access to
target services, accounts, private endpoints, credentials, or user data. All
production actions require approved accounts, least-privilege access, audited
change records, and the required owner approval.

No deployment, provider resource creation, production data change, purchase,
payout, or external communication is performed merely because a runbook step
exists.

---

## 1. Operations objectives and safety rules

### 1.1 Objectives

Operations must:

1. Keep local, development, staging, and production isolated.
2. Make deployments reproducible, observable, reversible, and attributable.
3. Detect and safely mitigate API, auth, messaging, RTC, billing, safety,
   deletion, provider, and cost failures.
4. Protect secrets, private data, financial records, safety evidence, and audit
   history during routine and emergency work.
5. Provide clear ownership, escalation, support guidance, and customer impact
   communication.
6. Use idempotent jobs, webhook handling, reconciliation, and recovery steps.
7. Prefer safe degradation and feature disablement over silently corrupting
   state or exposing users to unsafe behavior.

### 1.2 Non-negotiable rules

- Do not run destructive commands without explicit authorization and a verified
  recovery path.
- Do not use production data in development, screenshots, fixtures, or local
  debugging.
- Do not bypass authorization, RLS, ledger, moderation, deletion, or webhook
  verification to resolve an incident quickly.
- Do not edit posted financial, safety, audit, or webhook records silently.
- Do not put credentials, tokens, receipts, private messages, media URLs, or
  identity documents in tickets, logs, chat, or incident notes.
- Do not force-push, reset, clean, or delete unrelated workspace changes.
- Do not claim a device, provider, billing, safety, or backup check passed unless
  it ran and produced evidence.
- Record assumptions, blocked checks, temporary controls, and follow-up owners.

### 1.3 Operational status labels

- **Planned:** documented but not implemented.
- **Ready:** implemented and tested in the stated environment.
- **Degraded:** serving with a known limitation or reduced capability.
- **Blocked:** cannot run because a tool, provider, credential, device, or owner
  is unavailable.
- **Disabled:** intentionally stopped by an approved control.
- **Recovered:** mitigation complete and verification passed.
- **Retrospective required:** follow-up review is still open.

---

## 2. Ownership, access, and escalation

### 2.1 Required owners

Replace placeholders with named people or teams before production:

| Function | Primary | Backup | Approval scope |
| --- | --- | --- | --- |
| Incident commander | `TBD` | `TBD` | Incident coordination and priority |
| Engineering/API | `TBD` | `TBD` | API, jobs, database, application recovery |
| Infrastructure/SRE | `TBD` | `TBD` | Deployments, networking, secrets, capacity |
| Security | `TBD` | `TBD` | Security incidents, access, secret rotation |
| Privacy/legal | `TBD` | `TBD` | Data incidents, rights, notices, legal holds |
| Trust and safety | `TBD` | `TBD` | Reports, moderation, emergency escalation |
| Finance | `TBD` | `TBD` | Ledger, refunds, reconciliation, payouts |
| Support | `TBD` | `TBD` | User communication and case handling |
| RTC provider | `TBD` | `TBD` | Media provider incidents and capacity |
| Billing/payout provider | `TBD` | `TBD` | Store, receipt, payout, webhook incidents |

### 2.2 Capability separation

Use separate capabilities for:

- deployment and infrastructure;
- secret management;
- database read and migration;
- moderation case review/enforcement;
- support case access;
- finance/reconciliation/refund;
- payout operations;
- incident break-glass; and
- backup/restore.

No operator receives broad `admin` access by default. Access is time-limited,
environment-scoped, reviewed, and removed when no longer required.

### 2.3 Access requests

Every production access grant records:

- actor and team;
- environment and resource scope;
- capability;
- business/incident reason;
- start and expiry time;
- approver;
- MFA/strong-auth status where required; and
- review/revocation evidence.

Break-glass access is for a defined incident or recovery need only. It is
automatically expired where possible and reviewed after use.

### 2.4 Communication channels

Define and maintain:

```text
on-call channel:              TBD
incident bridge:              TBD
security escalation:          TBD
privacy/legal escalation:     TBD
safety emergency channel:     TBD
finance reconciliation:       TBD
provider support portals:     TBD
status communication owner:   TBD
```

Do not paste secrets, private user content, full receipts, or raw provider
payloads into these channels.

---

## 3. Environments and configuration

### 3.1 Environment separation

Each environment must have separate:

- API deployment and configuration;
- database and migration history;
- storage bucket/namespace;
- authentication project and signing keys;
- RTC project/namespace;
- store sandbox/production settings;
- push/email/analytics/crash projects;
- service accounts and role grants;
- secret set;
- queue/cache/rate-limit store; and
- monitoring dashboards and alert destinations.

### 3.2 Environment rules

| Environment | Data | Providers | Purpose |
| --- | --- | --- | --- |
| Local | Seeded/synthetic only | Stubs/fakes | Developer flow and unit tests |
| Development | Test accounts and synthetic data | Sandbox/test providers | Integration and feature work |
| Staging | Isolated test data; approved test PII only | Sandbox or isolated projects | Release rehearsal and device tests |
| Production | Real user data | Production providers | Approved public service |

Never point local/test builds at production billing, payout, moderation, or
private user data without a written exception, expiry, and owner.

### 3.3 Configuration changes

Configuration is versioned or auditable. A change record identifies:

- key/config name without secret value;
- old/new safe state;
- environment;
- reason and expected effect;
- owner/approver;
- start/end time if temporary;
- rollback value/procedure; and
- validation evidence.

Emergency feature controls must be safer than code changes and must not silently
change prices, ledger rules, retention, moderation policy, or legal notices.

### 3.4 Required configuration groups

Maintain safe placeholders and ownership for:

```text
PUBLIC_API_BASE_URL
PUBLIC_PROJECT_ID
AUTH_PROVIDER_CONFIGURATION
DATABASE_URL / DATABASE_ROLE
STORAGE_NAMESPACE
RTC_PROJECT_REFERENCE
RTC_API_KEY / RTC_API_SECRET       # server-only
BILLING_CONFIGURATION              # server/store-specific
PAYOUT_CONFIGURATION               # server-only
PUSH_CONFIGURATION
EMAIL_CONFIGURATION
ANALYTICS_CONFIGURATION
ERROR_REPORTING_CONFIGURATION
RATE_LIMIT_CONFIGURATION
FEATURE_CONTROL_CONFIGURATION
```

Secret values belong in the secret manager, not this repository.

---

## 4. Daily and weekly operational checks

### 4.1 Daily checks

The on-call or operations owner reviews:

- API availability, latency, error, and rate-limit dashboards;
- authentication/recovery failures and suspicious sessions;
- message acceptance/delivery/notification failures;
- RTC connection, reconnect, provider error, and token issuance metrics;
- moderation queue age, critical cases, and staffing coverage;
- purchase, refund, webhook, ledger, and payout reconciliation exceptions;
- account deletion jobs and retained-record exceptions;
- backup completion and last successful restore evidence;
- queue/dead-letter backlog and failed jobs;
- storage, database, bandwidth, RTC, and provider cost alerts; and
- pending incidents, changes, security alerts, and provider notices.

Do not access private content merely to complete a dashboard check. Use assigned
case scope and aggregate metrics.

### 4.2 Weekly checks

- Review open incidents, risks, and temporary exceptions.
- Review operator access, break-glass use, and privileged audit events.
- Review secret/key rotation schedule and expiring credentials.
- Review queue retry/dead-letter patterns.
- Review moderation backlog, appeals, emergency cases, and report privacy.
- Review finance reconciliation, holds, refunds, and payout exceptions.
- Review deletion/retention job success and provider cleanup.
- Review cost by provider and feature with budget owners.
- Review dependency/security advisories and release plans.
- Test a non-production restore or recovery procedure according to schedule.

---

## 5. Deployment and release operations

### 5.1 Deployment prerequisites

Before deploying an API, worker, database migration, Android client, or provider
configuration change:

- change is reviewed and linked to a requirement/ADR;
- tests and static checks pass;
- migration/backfill/rollback behavior is documented;
- environment and secret configuration are verified;
- monitoring and alert changes are ready;
- support and safety impact is understood;
- financial or privacy changes have required approval;
- release artifact is reproducible and identified by commit/version; and
- rollback or forward-fix path is available.

### 5.2 Standard deployment sequence

```text
review change
  -> validate artifact and configuration
  -> backup/verify recovery point where needed
  -> deploy to development
  -> run smoke/integration checks
  -> deploy to staging
  -> run migration/release rehearsal and device checks
  -> approve production window
  -> deploy canary/limited scope
  -> monitor gates
  -> expand gradually
  -> record result and close/rollback
```

Never deploy database and client assumptions in an order that breaks supported
older clients. Use additive migrations and compatibility windows.

### 5.3 Database migration operations

For each migration record:

- migration ID and owner;
- clean-database result;
- representative-existing-data result;
- expected duration and lock behavior;
- backfill batch/concurrency;
- monitoring and abort threshold;
- rollback or forward-fix plan;
- backup/recovery point;
- RLS/authorization impact; and
- post-migration verification query/report.

Do not manually edit production tables to correct a financial, safety, or account
state. Use a versioned migration or an audited domain command.

### 5.4 Rollback and forward-fix

Prefer a safe forward-fix when a migration or data change is already visible.
Rollback only when:

- the data effect is understood;
- dependent clients/providers are compatible;
- recovery point and lock behavior are known; and
- incident/change owners approve.

After rollback or forward-fix, verify API, auth, messaging, calls, financial
invariants, safety cases, deletion jobs, and dashboards.

### 5.5 Release evidence

Record:

```text
version/commit
environment
artifact checksum/reference
build/test commands
migration IDs
approvers
start/end time
monitoring window
result
rollback/forward-fix decision
open follow-up
```

---

## 6. Monitoring, health, and alert response

### 6.1 Minimum dashboards

Maintain separate dashboards for:

- API availability, latency, saturation, errors, and rate limits;
- authentication, recovery, session revocation, and suspicious activity;
- discovery, profiles, relationships, and pagination;
- conversations, messages, delivery, notifications, and queues;
- RTC calls, token issuance, connection/reconnect, quality, and provider state;
- safety reports, moderation queue, appeals, and emergency escalation;
- purchases, refunds, chargebacks, ledger invariants, earnings, and payouts;
- account deletion, retention jobs, provider cleanup, and exceptions;
- database, storage, cache, queues, backups, and restore evidence; and
- provider spend, bandwidth, storage, RTC minutes, and other cost drivers.

Dashboards must use safe aggregate or restricted data. Do not query private
messages, moderation evidence, receipts, or payout destinations for routine
monitoring.

### 6.2 Health endpoints

Internal health endpoints may include:

```text
GET /health/live
GET /health/ready
```

`live` means the process is responding. `ready` means the service can safely
accept its intended traffic and dependencies are within the approved state. Do
not include secrets, user data, database connection strings, or raw provider
payloads in health responses.

### 6.3 Alert requirements

Every alert has:

- severity and threshold;
- owning team and backup;
- dashboard/runbook link;
- expected first response;
- safe mitigation;
- escalation condition;
- notification destination; and
- closure evidence.

Initial alert families:

| Alert | First response |
| --- | --- |
| API error/latency/availability | Check deploys/dependencies; canary rollback or degrade affected feature |
| Auth/recovery abuse | Apply rate controls, inspect safe aggregate signals, involve security |
| Database saturation/error | Protect writes, inspect locks/connections, follow DB recovery path |
| Queue/dead-letter growth | Pause unsafe producer, inspect idempotency/failure, replay safely |
| Messaging degradation | Check API/storage/moderation/notification dependencies; preserve accepted messages |
| RTC degradation | Check provider/regions/tokens; disable new calls if required |
| Purchase/webhook mismatch | Stop fulfillment if necessary; reconcile before granting value |
| Ledger invariant failure | Freeze affected value movement; finance incident and reconciliation |
| Moderation backlog/critical case | Escalate safety owner; apply temporary controls |
| Deletion job failure | Keep status pending; retry safely; review retained exceptions |
| Backup/restore failure | Protect next recovery point; follow DR runbook |
| Secret exposure | Revoke/rotate; security incident; inspect access logs |
| Cost spike | Identify feature/provider; apply quota/kill switch and owner review |

### 6.4 Alert fatigue

Tune alerts to actionable conditions. A silently ignored alert is an operational
failure. Review noisy alerts weekly and preserve a written reason for threshold
changes.

---

## 7. Incident management

### 7.1 Severity levels

| Severity | Definition | Required response |
| --- | --- | --- |
| SEV-1 | Active safety, security, financial integrity, widespread outage, or legal-risk event | Immediate incident commander, bridge, containment, owner escalation |
| SEV-2 | Material degradation, partial outage, provider failure, queue/ledger risk | On-call response, mitigation, stakeholder updates |
| SEV-3 | Limited user or operational impact with workaround | Normal on-call handling and tracked fix |
| SEV-4 | Low-risk defect, documentation gap, or non-urgent improvement | Queue for planned work |

Severity may be raised when impact or uncertainty increases.

### 7.2 Incident command

The incident commander:

- declares severity and assigns roles;
- starts the incident record and timeline;
- coordinates engineering, security, safety, finance, privacy/legal, and support;
- chooses containment/feature controls;
- prevents unrelated changes from obscuring evidence;
- maintains internal update cadence;
- approves recovery verification; and
- assigns post-incident follow-up.

Required incident roles may include:

```text
incident_commander
technical_lead
communications_lead
security/privacy_lead
safety_lead
finance_lead
scribe/timeline_owner
provider_liaison
```

### 7.3 Incident record

Record only safe, necessary data:

```text
incident_id
severity
detected_at_utc
declared_at_utc
owner
affected_services/environments
user-impact summary
known/suspected timeline
containment actions
feature controls
evidence references
provider references
secret rotation status
support guidance
privacy/legal assessment
recovery verification
follow-up actions/owners/dates
```

Do not place credentials, message bodies, identity documents, raw receipts,
private media URLs, or unnecessary user data in the incident record.

### 7.4 Communication cadence

Set a cadence appropriate to severity. Updates state:

- what is affected;
- what users may see;
- what is being done;
- what is not known;
- next update time; and
- support guidance.

Do not promise restored times, refunds, safety outcomes, or legal conclusions
without the responsible owner.

### 7.5 Recovery and closure

Close an incident only after:

- mitigation is verified;
- affected queues/jobs/providers are stable;
- financial/safety/security integrity checks pass;
- support has guidance;
- privacy/legal assessment is complete;
- monitoring is normalized; and
- follow-up owners/dates are recorded.

SEV-1 and SEV-2 incidents require a blameless review with timeline, root and
contributing causes, what worked/failed, corrective actions, and evidence.

---

## 8. Common operational procedures

### 8.1 API degradation

1. Confirm alert, scope, environment, route family, and user impact.
2. Check recent deploys, configuration, dependencies, database, queues, and
   provider health.
3. Protect effectful operations with feature controls if data integrity is at
   risk.
4. Do not retry non-idempotent requests blindly.
5. Roll back or forward-fix using the deployment procedure.
6. Monitor recovery and verify safe error/pending behavior.
7. Inform support and update the incident record.

### 8.2 Authentication or recovery abuse

1. Confirm rate-limit/alert source without exposing account existence.
2. Apply approved rate controls or temporarily disable affected flow.
3. Revoke suspicious sessions/tokens only through the security workflow.
4. Inspect aggregate access patterns and affected business effects.
5. Escalate account takeover, provider, or secret concerns.
6. Restore flow gradually after tests and monitoring pass.

### 8.3 Database incident

1. Identify read/write/lock/replication/connection failure.
2. Protect financial, safety, deletion, and authorization writes first.
3. Check recent migration/configuration/dependency changes.
4. Follow the database/DR procedure; do not run ad hoc destructive SQL.
5. Verify ownership/RLS and invariant queries after recovery.
6. Reconcile queues, outbox, webhooks, ledger, calls, and deletion jobs.
7. Record recovery point, data-loss assessment, and follow-up.

### 8.4 Queue or job backlog

1. Identify queue, job type, age, retry count, and dead-letter volume.
2. Check whether the job is safe to replay and idempotent.
3. Stop or rate-limit the producer if it can worsen the backlog.
4. Inspect representative redacted failures.
5. Fix dependency/configuration or deploy approved forward-fix.
6. Replay bounded batches and monitor business invariants.
7. Escalate financial, safety, deletion, or notification impact.

### 8.5 Webhook failure

1. Confirm provider, signature failures, event type, and delivery window.
2. Do not bypass signature verification or manually trust a payload.
3. Check `WebhookEvent` deduplication and processing state.
4. Replay through the idempotent recovery path if verification succeeds.
5. For billing/payout/call events, reconcile before granting value or marking
   paid/settled.
6. Notify provider liaison and record dead-letter/manual-review work.

### 8.6 RTC/provider degradation

1. Check token issuance, provider health, region, connection, reconnect, and
   callback metrics.
2. Determine whether existing calls or only new calls are affected.
3. Disable new calls or token issuance if unsafe.
4. Preserve call state and prevent false settlement.
5. Keep user-facing pending/retry/support state accurate.
6. Reconcile provider/application call events after recovery.
7. Do not expose provider secrets or raw payloads in support messages.

### 8.7 Messaging/notification degradation

1. Separate message acceptance from notification delivery.
2. Verify conversation authorization, database writes, moderation, storage,
   realtime, push, and email dependencies.
3. Preserve accepted messages even if notification delivery fails.
4. Retry notification jobs with deduplication and expiry.
5. Do not mark messages delivered/read without evidence.
6. Notify users safely if delivery is delayed and provide refresh/retry.

### 8.8 Safety/moderation incident

1. Assign safety owner and determine severity.
2. Protect reporter identity and evidence access.
3. Apply temporary feature/account/provider control if necessary.
4. Escalate critical/emergency/legal cases through approved channels.
5. Preserve minimum evidence and audit events.
6. Communicate safe status to users/support without exposing private details.
7. Review queue, enforcement, appeals, and deletion-retention impact.

### 8.9 Payment/ledger/reconciliation incident

1. Stop the affected purchase, fulfillment, settlement, earnings, or payout path
   if integrity is uncertain.
2. Identify source event, policy version, idempotency record, and ledger status.
3. Never edit posted entries or grant value manually without the approved command.
4. Compare store/provider records with internal records.
5. Place affected items in pending/hold/reconciliation state.
6. Finance owner approves compensating entries or release.
7. Support receives safe, accurate user/host guidance.
8. Resume gradually after invariant and reconciliation checks pass.

### 8.10 Secret exposure

1. Declare security incident and identify secret class/environment.
2. Revoke/rotate without copying the value into tickets or chat.
3. Check source, APK, build logs, history, artifacts, and provider access.
4. Inspect logs for unauthorized use.
5. Patch exposure and rerun secret scans.
6. Assess user, provider, privacy, legal, and operational impact.
7. Record only redacted evidence and follow-up.

### 8.11 Account deletion failure

1. Keep deletion status visible as pending/failed rather than claiming completion.
2. Identify failed step: account, profile, media, messages, provider, cache,
   analytics, queue, backup, or retained-record review.
3. Retry idempotently or route to manual exception owner.
4. Revoke sessions and stop new access where policy requires.
5. Verify retention exceptions and avoid deleting required safety/financial data.
6. Communicate safe status to the user/support.

### 8.12 Cost spike

1. Identify provider, feature, environment, traffic, and time range.
2. Confirm whether the increase is legitimate, abusive, or a leak/loop.
3. Apply quota, sampling, rate, or feature control.
4. Protect safety, auth, deletion, and financial correctness first.
5. Notify cost/provider owner and record user impact.
6. Restore gradually after usage and billing verification.

---

## 9. Scheduled jobs and reconciliation

### 9.1 Job requirements

Every scheduled or queued job has:

- owner and purpose;
- input/output contract;
- idempotency key or deterministic deduplication;
- bounded batch size and concurrency;
- retry/backoff policy;
- timeout and cancellation behavior;
- dead-letter/manual recovery path;
- safe logs and metrics;
- alert threshold; and
- data-retention/deletion behavior.

Initial jobs include:

- expire unanswered call requests;
- expire stale RTC sessions;
- retry notification delivery;
- process moderated message/media state;
- retry purchase verification and fulfillment;
- reconcile refunds/chargebacks;
- calculate/transition host earnings;
- process payout provider events;
- clean temporary uploads and signed references;
- process account deletion steps;
- notify/escalate safety cases;
- refresh safe discovery projections; and
- generate daily operational/finance reports.

### 9.2 Job restart procedure

1. Inspect job type, age, attempts, owner, and safe failure category.
2. Confirm whether the effect is idempotent and whether the dependency is healthy.
3. Pause producer or reduce concurrency if it can worsen impact.
4. Retry a bounded sample.
5. Verify business invariant and output.
6. Resume batches gradually.
7. Review dead-letter items and assign manual recovery.

### 9.3 Reconciliation procedure

For any mismatch, record source systems, time window, policy version, counts,
amounts or state differences, owner, severity, and next action. Reconcile:

- purchase/store events versus fulfillment/ledger;
- refunds/chargebacks versus wallet/host reversals;
- calls/RTC events versus application state/settlement;
- payouts versus provider outcome and ledger;
- moderation action versus account/interaction state; and
- deletion job state versus provider/cache/backup cleanup.

Never resolve a mismatch by deleting or editing history silently.

---

## 10. Support, safety, and finance operations

### 10.1 Support handoff

Support receives:

- safe user-facing status;
- request/case/reference IDs;
- approved next steps;
- pending/retry/blocked explanation;
- refund/payout/deletion status where authorized; and
- escalation owner and target response.

Support does not receive or request passwords, tokens, payment secrets, raw
receipts, full message exports, or identity documents through ordinary channels.

### 10.2 Safety handoff

Safety cases are routed by severity and capability. The on-call process must
protect reporter identity, minimize evidence exposure, preserve audit history,
and identify emergency/legal escalation. See `docs/TRUST_AND_SAFETY.md`.

### 10.3 Finance handoff

Finance owns reconciliation, approved refunds, ledger corrections,
earnings/payout holds, and payout release. Support may create or update a case
but cannot post a ledger entry. Each finance action references case, actor,
reason, idempotency, and audit records.

### 10.4 Privacy/security handoff

Escalate suspected unauthorized access, secret exposure, data loss, retention or
deletion failure, reporter disclosure, or privacy-rights failure to security and
privacy/legal owners. Do not decide breach notification or legal disclosure
inside an engineering-only channel.

---

## 11. Backup and disaster-recovery operations

The detailed recovery plan is in `docs/DISASTER_RECOVERY.md`. Operations must
maintain:

- backup completion/age dashboard;
- restore-test evidence;
- encrypted backup locations;
- database, storage, configuration, and secret recovery procedures;
- dependency/provider recovery contacts;
- RTO/RPO and data-loss decisions; and
- a current recovery owner and backup owner.

A backup that cannot be restored is not a verified recovery point.

---

## 12. Maintenance and routine changes

### 12.1 Maintenance window

Before maintenance:

- publish internal/service notice and support guidance;
- confirm owner, scope, start/end, and rollback;
- verify backups/recovery point;
- check provider and dependency status;
- pause or drain affected jobs safely;
- prepare dashboards and alerts; and
- record the change.

After maintenance:

- verify health, auth, API, jobs, messaging, calls, safety, finance, and deletion
  paths as applicable;
- compare error/latency/cost metrics;
- remove temporary controls;
- close or roll forward the change; and
- record evidence and follow-up.

### 12.2 Dependency maintenance

Review provider/SDK upgrades for:

- permissions and collection changes;
- token and webhook behavior;
- data retention/deletion;
- API compatibility;
- pricing/cost;
- security advisories;
- mobile device support; and
- rollback/compatibility.

Do not enable an SDK capability merely because it is bundled or registered.

---

## 13. Operational metrics and service objectives

Define approved service objectives before launch. Initial metric families:

| Area | Metrics |
| --- | --- |
| API | Availability, P50/P95/P99 latency, error rate, saturation, rate limits |
| Auth | Login/recovery success, failures, lockouts, revocations |
| Messaging | Accepted/failed, delivery/read projections, notification delay |
| RTC | Request/accept/connect/reconnect/end/failure, quality and provider errors |
| Safety | Report volume, queue age, first-review/resolution, appeal backlog |
| Finance | Verification, fulfillment, reconciliation, ledger invariant, payout outcomes |
| Deletion | Requested/processing/completed/failed, exception age |
| Jobs | Success/retry/dead-letter/age/concurrency |
| Data | Backup age, restore tests, storage/search/cache cleanup |
| Cost | RTC minutes, storage, bandwidth, database, provider and moderation cost |

Metrics must have owners, thresholds, dashboards, and runbooks. Avoid setting
availability targets before workload/provider baselines exist, but do not launch
without a way to detect material degradation.

---

## 14. Production-readiness checklist

- [ ] Named owners, backups, on-call coverage, and escalation channels exist.
- [ ] Environment separation and secret-manager access are verified.
- [ ] Deployment, migration, rollback/forward-fix, and release evidence procedures exist.
- [ ] Health dashboards and actionable alerts exist for API, auth, messaging, RTC,
      safety, finance, deletion, jobs, backups, and cost.
- [ ] Incident severity, command, communication, and postmortem process is ready.
- [ ] Common outage, webhook, provider, payment, safety, deletion, secret, and
      cost runbooks have been rehearsed.
- [ ] Jobs are idempotent, observable, bounded, and recoverable.
- [ ] Reconciliation and manual-recovery queues exist for calls, purchases,
      refunds, earnings, payouts, moderation, and deletion.
- [ ] Support has safe user-facing guidance and escalation routes.
- [ ] Backup/restore and disaster-recovery evidence is current.
- [ ] Operator access is least-privilege, time-limited, and audited.
- [ ] Logs, analytics, traces, tickets, and incident records are redacted.
- [ ] Real money, payouts, recording, and production RTC remain gated until approvals pass.
- [ ] No target-specific provider, credential, package, endpoint, asset, or data has been reused.

---

## 15. Open operational decisions

1. On-call hours, primary/backup owners, and incident communication channels.
2. Service objectives, alert thresholds, and status communication policy.
3. Hosting/deployment platform, environment topology, and access process.
4. Database/storage/cache/queue providers and backup/restore schedule.
5. RTC, billing, payout, push, email, analytics, moderation, and support providers.
6. Feature-disable/kill-switch authority and approval process.
7. Finance reconciliation cadence and manual-recovery authority.
8. Safety queue staffing, emergency availability, and legal escalation contacts.
9. Support hours, refund/payout/deletion escalation, and customer communication.
10. RTO/RPO, maintenance windows, and disaster-recovery exercise schedule.
11. Cost budgets, quota alerts, and provider spend controls.
