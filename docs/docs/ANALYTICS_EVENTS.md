# Analytics Events — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Product analytics owner to be assigned; security, privacy, product,
engineering, support, safety, and finance reviewers required  
**Last updated:** 2026-10-25  
**Source of truth for:** Privacy-safe product analytics, event names, schemas,
consent, retention, dashboards, ownership, and prohibited telemetry  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`, `docs/CLEAN_ROOM_RULES.md`

This document defines independent analytics events for product improvement,
reliability, safety, and financial operations. It does not authorize copying a
target application's event names, attribution identifiers, provider payloads,
ranking signals, or private telemetry behavior.

Analytics is not the source of truth for account identity, authorization,
messages, call state, billing, ledger entries, moderation, or deletion. Those
systems must emit safe references into analytics only after the authoritative
operation succeeds or reaches the documented state.

---

## 1. Principles and scope

### 1.1 Principles

- Collect the minimum data needed for an approved question.
- Use an allowlist of event names and properties.
- Do not collect advertising IDs or stable device fingerprints by default.
- Do not collect message bodies, private media URLs, payment receipts,
  authorization headers, identity documents, or moderation evidence in ordinary
  analytics.
- Use opaque account/resource references only when necessary and approved.
- Separate product analytics, security logs, crash diagnostics, financial
  reconciliation, and moderation evidence.
- Track server-confirmed state for business metrics; do not trust UI taps for
  money, calls, delivery, or safety outcomes.
- Make event schemas versioned, documented, testable, and privacy-reviewed.
- Honor consent, regional settings, deletion, retention, and provider controls.
- Make analytics failure non-blocking for core product actions.

### 1.2 Release stages

| Stage | Analytics behavior |
| --- | --- |
| Local MVP | Minimal debug-safe events or disabled; no external user data |
| Development | Synthetic/test account events; provider sandbox project |
| Staging | Approved allowlist with test identifiers and redaction checks |
| Production | Approved events, consent/notice controls, retention, dashboards, and access review |

### 1.3 Data not collected by default

The independent product must not collect by default:

- advertising IDs;
- stable hardware IDs or device fingerprints;
- precise location;
- contact lists;
- clipboard contents;
- message bodies or message attachments;
- private media URLs or call media;
- payment receipts, purchase tokens, payout destinations, or identity documents;
- reporter identity, moderation evidence, or private operator notes;
- authorization headers, cookies, access/refresh tokens, or provider secrets; and
- raw provider webhook payloads.

Any exception requires a documented purpose, owner, consent/notice decision,
retention, access scope, deletion behavior, and security/privacy approval.

---

## 2. Event envelope and schema rules

### 2.1 Common event envelope

Every accepted analytics event uses a common envelope:

```text
event_id                 unique event identifier
event_name               allowlisted stable name
schema_version           integer schema version
occurred_at_utc          event time according to source
received_at_utc          server/collector receive time when available
source                   android_client / api / worker / provider_adapter / operator_tool
environment              local / development / staging / production
platform                 coarse platform value
app_version              application version
session_reference        short-lived or opaque session reference where needed
account_reference        opaque reference only when approved
anonymous_reference      privacy-reviewed anonymous reference when approved
request_id               API correlation ID where applicable
resource_type            allowlisted type
resource_reference       opaque ID only where approved
properties               event-specific allowlisted fields
consent_context          required when collection depends on optional consent
```

Events must not include arbitrary key/value maps from client input. Property
names, types, lengths, and values are allowlisted and schema-validated.

### 2.2 Identity references

The analytics identity policy is **Proposed**:

- Use a random installation/session reference only when necessary for aggregate
  product measurement.
- Do not use advertising ID, hardware ID, phone number, email, provider subject,
  IP address, or stable fingerprint as the analytics identity.
- Account references are pseudonymous and access-controlled.
- Do not merge anonymous and authenticated histories unless the user-facing
  notice/consent and privacy review approve the linkage.
- Rotate or expire session/device references according to the approved retention
  policy.

### 2.3 Event time and ordering

- Server-confirmed events use server UTC time as the authoritative timestamp.
- Client events include client time only as diagnostic context and may be stale
  or manipulated.
- Providers and clients cannot override financial, moderation, call, or account
  state through analytics.
- Late, duplicate, or out-of-order events are deduplicated or marked as such.
- Event IDs and schema versions are stable across retries.

### 2.4 Event outcome fields

Use controlled values:

```text
result: success | failure | pending | canceled | blocked | restricted | unknown
failure_category: validation | authorization | rate_limit | offline | timeout
                   | provider | moderation | conflict | internal | none
retryable: true | false
```

Never use free-form exception strings, stack traces, database errors, provider
payloads, or message text as event properties.

### 2.5 Schema change rules

Changing an event requires:

- schema version or additive compatibility decision;
- owner and purpose review;
- privacy/security review for new fields;
- dashboard and query impact assessment;
- client/server compatibility plan;
- migration/backfill decision; and
- updated examples and tests.

Do not silently change an event property from aggregate to user-level or change
its meaning while retaining the same name/version.

---

## 3. Privacy, consent, and retention

### 3.1 Collection categories

| Category | Allowed examples | Prohibited/default behavior |
| --- | --- | --- |
| Product usage | Screen/feature state, safe outcome, coarse category | No message content or private screen capture |
| Reliability | Route family, latency bucket, safe error code, app version | No tokens, request body, stack secrets, or private URLs |
| Call quality | Coarse connection state, duration bucket, provider error category | No media, hidden participant/device identity, or client-settlement authority |
| Safety operations | Aggregate report category/count, queue age, action state | No report text, reporter identity, or evidence in normal analytics |
| Finance operations | Aggregate purchase/settlement outcome, reconciliation count | No receipts, purchase tokens, payout destinations, or raw ledger payloads |
| Support | Case category/status/age | No message body or identity-document content |
| Consent/privacy | Consent version/decision, deletion status | No raw personal data in event properties |

### 3.2 Consent and notice

Each optional analytics purpose must document:

- purpose and owner;
- required versus optional status;
- notice/consent requirement by region;
- event names and properties;
- provider/subprocessor recipients;
- retention and deletion behavior;
- user settings/withdrawal behavior; and
- impact if collection is disabled.

Core reliability/security metrics may use a separate approved operational basis,
but must remain minimized and protected. Do not make optional analytics consent
a hidden requirement for authentication, messaging, calls, safety, deletion, or
other core rights.

### 3.3 Retention

Analytics retention must be shorter than or equal to the approved purpose. Define
separate retention classes for:

```text
product_aggregate
reliability_diagnostic
security_signal
financial_reconciliation_reference
safety_aggregate
consent_audit
```

Raw event retention, transformed aggregate retention, backups, provider copies,
and deletion/opt-out propagation must be documented. Analytics records must not
become an excuse to retain message, media, payment, or moderation data.

### 3.4 Deletion and correction

When an account is deleted or an approved privacy request is fulfilled:

- remove or anonymize account-linked analytics references according to policy;
- preserve only required security/financial/safety audit references;
- prevent re-identification through retained dimensions;
- update downstream analytics providers where supported; and
- record completion or exception without exposing the deleted data.

---

## 4. Common property allowlist

### 4.1 Safe common properties

Potentially allowed after review:

| Property | Type | Notes |
| --- | --- | --- |
| `app_version` | bounded string | Release version, not identity |
| `platform` | enum | `android`, later approved platforms |
| `device_family` | coarse enum/string | No raw model or hardware identifier unless approved |
| `os_major` | bounded integer | Coarse compatibility value |
| `locale` | approved locale | Avoid precise inferred location |
| `environment` | enum | Never mix production with test dashboards |
| `feature_flag` | allowlisted key | No hidden user segmentation without review |
| `screen_name` | allowlisted enum | Independent product screen name |
| `route_family` | allowlisted enum | API family, not raw URL/query |
| `result` | enum | Controlled outcome |
| `failure_category` | enum | No provider exception text |
| `latency_ms_bucket` | bucket | Avoid raw user timing payloads where unnecessary |
| `retryable` | boolean | Safe operational value |
| `policy_version` | bounded reference | Only where needed for aggregate policy analysis |
| `resource_type` | enum | No arbitrary resource names |
| `resource_reference` | opaque ID | Only when required and approved |

### 4.2 Prohibited common properties

Never send:

```text
email
phone_number
password
recovery_code
access_token
refresh_token
cookie
authorization_header
advertising_id
hardware_id
serial_number
imei
mac_address
stable_fingerprint
precise_location
contact_list
clipboard_text
message_body
media_url
media_contents
payment_receipt
purchase_token
payout_destination
identity_document
report_explanation
moderation_evidence
private_operator_note
raw_provider_payload
```

---

## 5. Event naming and taxonomy

### 5.1 Naming convention

Use lower-case dot-separated names:

```text
<domain>.<object>_<lifecycle-or-action>
```

Examples:

```text
app.started
auth.login_succeeded
discovery.results_loaded
message.accepted
call.connected
purchase.verification_pending
moderation.report_created
```

Names describe an observed state or server-confirmed action, not a button label.
Use one event for one meaningful outcome rather than emitting every UI redraw.

### 5.2 Event ownership

| Domain | Owner | Primary use |
| --- | --- | --- |
| `app.*` | Mobile/platform | Startup, version, crash-safe lifecycle |
| `auth.*` | Identity | Login, session, recovery, account state |
| `profile.*` | Product/profile | Profile completion and changes |
| `discovery.*` | Product/discovery | Feed quality and availability |
| `relationship.*` | Product/relationship | Follow, favorite, block outcomes |
| `match.*` | Product/matching | Match attempts and decisions |
| `conversation.*` | Messaging | Conversation lifecycle and privacy-safe delivery |
| `message.*` | Messaging/safety | Accepted/held/failed delivery states |
| `call.*` | RTC/call | Application call lifecycle and quality buckets |
| `purchase.*` | Finance | Store verification/fulfillment states |
| `wallet.*` | Finance | Safe projection/reconciliation outcomes |
| `earning.*` | Finance/host | Host-state transitions |
| `payout.*` | Finance/operations | Payout lifecycle and exceptions |
| `moderation.*` | Safety | Case/action aggregate states |
| `notification.*` | Messaging/platform | Delivery and suppression outcomes |
| `support.*` | Support | Case state and response time |
| `security.*` | Security | Safe aggregate security signals |
| `ops.*` | Operations | Jobs, providers, incidents, cost/availability |

---

## 6. Event catalog

The catalog below is a proposed starting allowlist. Events are emitted only when
their source has enough evidence to support the outcome. Exact properties,
retention, and dashboard use must be approved before production collection.

### 6.1 App and client lifecycle

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `app.started` | Client | app version, platform, environment, safe startup result | App reached startup boundary |
| `app.ready` | Client | startup latency bucket, app version | App became usable |
| `app.startup_failed` | Client | safe failure category, app version | Startup failed; no raw exception |
| `app.updated` | Client | previous/current major version only where needed | App version transition |
| `app.permission_prompt_shown` | Client | permission type enum | User saw an approved explanation/prompt |
| `app.permission_result` | Client | permission type, result enum | Permission granted/denied/revoked/unavailable |
| `app.settings_opened` | Client | setting category enum | User opened a settings path |

Do not record screen contents, permission rationale text containing personal
data, or raw device identifiers.

### 6.2 Authentication and account events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `auth.login_started` | Client/API | provider enum, platform | Login flow began |
| `auth.login_succeeded` | API | provider enum, account reference if approved | Server created/continued session |
| `auth.login_failed` | API | safe failure category, retryable | Login failed without account enumeration |
| `auth.logout` | API/client | session scope enum | Session was revoked/cleared |
| `auth.recovery_started` | API | channel enum, result | Recovery request accepted or rejected |
| `auth.recovery_completed` | API | result, session-revoked flag | Recovery completed |
| `auth.identity_linked` | API | provider enum, result | Approved identity link changed |
| `auth.session_revoked` | API/security | reason category, scope | Session became invalid |
| `auth.account_restricted` | Safety/API | restriction category, policy version | Account state changed |
| `account.deletion_requested` | API | deletion state, retention-exception flag | Authenticated deletion workflow started |
| `account.deletion_completed` | Worker/API | outcome, exception category | Deletion workflow completed or reported exception |

Never include email, phone, provider subject, recovery code, token, or identity
document properties.

### 6.3 Profile and discovery events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `profile.created` | API | profile reference, completion bucket | Profile was created |
| `profile.updated` | API | changed-field category, result | Approved profile update completed |
| `profile.media_added` | API | media purpose, moderation state | Approved media association changed |
| `profile.media_removed` | API | media purpose, result | Media was hidden/removed |
| `discovery.opened` | Client/API | entry surface, filter category | Discovery surface opened |
| `discovery.results_loaded` | API/client | result count bucket, empty flag, latency bucket | Page loaded |
| `discovery.results_failed` | API/client | failure category, retryable | Page failed safely |
| `discovery.profile_opened` | Client | profile reference if approved, entry surface | Authorized profile detail viewed |
| `discovery.filter_applied` | Client/API | allowlisted filter category/value bucket | Approved filter used |
| `discovery.refresh` | Client/API | result/empty/failed outcome | User refreshed or server refreshed |

Do not capture search text, precise location, hidden ranking features, or private
availability reasons. If profile references are not necessary for aggregate
analysis, omit them.

### 6.4 Relationship and matching events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `relationship.follow_changed` | API | kind, desired state, result | Follow relationship changed |
| `relationship.favorite_changed` | API | kind, desired state, result | Favorite relationship changed |
| `relationship.block_changed` | API | desired state, result | Block state changed |
| `match.attempt_created` | API | result, candidate-count bucket | Match attempt created |
| `match.decision_recorded` | API | decision category, result | Accept/skip/cancel decision persisted |
| `match.attempt_failed` | API | failure category, retryable | Match failed or had no eligible result |

Do not expose candidate identities, ranking features, private preferences, or
blocked-account details in analytics.

### 6.5 Conversation and messaging events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `conversation.created` | API | conversation kind, participant-count bucket | Authorized conversation created |
| `conversation.opened` | Client/API | conversation kind, unread-count bucket | Participant opened conversation |
| `conversation.read_marker_changed` | API | message-count bucket, result | Read projection changed |
| `message.submitted` | API/client | message type, attachment-count bucket | Message command submitted |
| `message.accepted` | API | message type, result | Server accepted message |
| `message.held` | API/safety | message type, moderation state | Message held for review |
| `message.removed` | API/safety | reason category, message type | Message hidden/removed |
| `message.failed` | API | failure category, retryable, message type | Message was not accepted |
| `message.delivery_changed` | API/worker | delivery state, failure category | Delivery projection changed |
| `message.reported` | API | reason category, result | Message report created |
| `message.attachment_scan_result` | Worker | attachment type, result category | Media validation completed |

Never include message body, attachment URL, file name, raw message ID unless
approved for a narrowly scoped aggregate, reporter identity, or recipient
identity in ordinary analytics.

### 6.6 Call and RTC events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `call.requested` | API | eligibility result, call policy version | Call request accepted/rejected |
| `call.accepted` | API | result | Recipient accepted |
| `call.rejected` | API | safe reason category | Recipient rejected |
| `call.canceled` | API | safe reason category | Initiator canceled |
| `call.expired` | Worker/API | expiry category | Request expired |
| `call.token_issued` | API | provider adapter, participant role, result | Scoped token issued; never token value |
| `call.connecting` | API/provider | result, provider error category | Connection attempt began |
| `call.connected` | API/provider | connection latency bucket, provider quality bucket | Server/provider confirmed connection |
| `call.reconnecting` | API/provider | duration bucket, result | Temporary connection loss |
| `call.failed` | API/provider | failure category, retryable | Connection failed |
| `call.ended` | API/provider | end reason category, duration bucket | Application call ended |
| `call.reported` | API | reason category, result | Safety report created |
| `call.settlement_pending` | Finance | result category, policy version | Settlement awaits evidence/reconciliation |
| `call.settlement_completed` | Finance | duration bucket, policy version, result | Settlement completed; no amount unless approved |
| `call.reconciliation_required` | Finance/ops | exception category | Evidence conflict requires review |

Call analytics must not become billing authority. Do not use client duration or
local timer events to calculate money.

### 6.7 Purchase, wallet, earnings, and payout events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `purchase.started` | Client/API | product type, catalog policy version | User started approved purchase |
| `purchase.submitted` | API | store enum, product type, result | Safe purchase reference submitted |
| `purchase.verification_pending` | API/worker | store enum, product type | Provider verification pending |
| `purchase.fulfilled` | API/worker | product type, entitlement type, result | Value granted after verification |
| `purchase.rejected` | API/worker | failure category, store enum | Purchase not granted |
| `purchase.refunded` | Provider/API | product type, refund category | Refund recorded |
| `purchase.chargeback` | Provider/API | product type, result | Chargeback recorded |
| `wallet.projection_updated` | Worker/API | change category, result | Safe wallet projection changed |
| `earning.state_changed` | Finance | prior/new state, policy version | Host earning state changed |
| `payout.requested` | API | result, eligibility category | Payout request created |
| `payout.state_changed` | Provider/API | prior/new state, failure category | Payout outcome changed |
| `finance.reconciliation_exception` | Finance/ops | source type, severity, result | Reconciliation issue recorded |

Do not include currency amounts, purchase tokens, receipts, payout destinations,
provider IDs, tax details, or fraud signals unless a separate protected finance
pipeline explicitly approves an aggregate field.

### 6.8 Safety, support, and notification events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `moderation.report_created` | API | target type, reason category, severity | Safety case received |
| `moderation.case_triaged` | Safety | severity, queue category | Case triaged |
| `moderation.action_applied` | Safety | action category, target type, duration bucket | Enforcement applied |
| `moderation.appeal_created` | Safety/support | action category, result | Appeal submitted |
| `moderation.appeal_resolved` | Safety | result category, action outcome | Appeal resolved |
| `notification.created` | Worker | category, channel, result | Notification created |
| `notification.delivered` | Provider/worker | channel, result, failure category | Delivery outcome |
| `notification.suppressed` | Worker | category, suppression reason | Delivery intentionally stopped |
| `support.case_created` | Support/API | category, priority | Support case created |
| `support.case_resolved` | Support | category, resolution category | Support case resolved |

Do not include report text, reporter identity, evidence, support message body,
moderator identity, or internal enforcement reasoning.

### 6.9 Security and operations events

| Event | Source | Allowed properties | Outcome meaning |
| --- | --- | --- | --- |
| `security.rate_limited` | API/security | route family, category, result | Limit applied |
| `security.authorization_denied` | API/security | route family, denial category | Access denied; no target private data |
| `security.session_revoked` | Auth/security | reason category, scope | Session revoked |
| `security.break_glass_used` | Security/ops | capability, scope category, result | Emergency access used |
| `ops.job_started` | Worker | job type, attempt number | Job began |
| `ops.job_completed` | Worker | job type, result, duration bucket | Job completed |
| `ops.webhook_processed` | Worker | provider family, event type category, result | Verified event processed |
| `ops.provider_degraded` | Monitoring | provider family, severity | Provider health degraded |
| `ops.incident_opened` | Ops | incident category, severity | Incident created |
| `ops.feature_control_changed` | Ops | feature family, desired state, reason category | Emergency/operational control changed |

Security and operations events must not expose credentials, private payloads,
full IP/device identifiers, or raw provider data.

---

## 7. Instrumentation rules by source

### 7.1 Client instrumentation

The client may emit product and UX events for:

- startup and permission outcomes;
- screen/feature entry;
- safe loading/empty/offline/retry outcomes;
- user intent where it is useful and privacy-approved; and
- client-only rendering diagnostics.

The client must not claim server success for:

- account creation or authorization;
- message acceptance/delivery;
- call connection or billing;
- purchase fulfillment;
- moderation action;
- payout state; or
- account deletion completion.

Client events are best-effort. Failure to send analytics must not block a
message, call, report, purchase, deletion, or safety action.

### 7.2 API instrumentation

The API emits authoritative outcome events after validation and state changes.
For transactional events, write the domain change and an outbox/event record in
one transaction or an equivalent recoverable workflow. Do not emit
`purchase.fulfilled`, `call.settlement_completed`, `message.accepted`, or
`account.deletion_completed` before the authoritative state is durable.

### 7.3 Worker instrumentation

Jobs emit start, retry, success, pending, dead-letter, and failure outcomes with:

- job type;
- attempt number;
- duration bucket;
- safe failure category;
- related opaque resource reference where needed; and
- no raw payload.

Job retries must not duplicate business effects or analytics events. Use a stable
job run/event ID.

### 7.4 Provider instrumentation

Provider adapters emit only mapped application outcomes:

- verification result;
- provider availability category;
- callback processed/rejected;
- connection/quality bucket;
- delivery state; or
- reconciliation result.

Do not forward raw provider payloads, provider tokens, full provider IDs, or
unapproved device/identity fields.

### 7.5 Operator instrumentation

Operator tools emit audit/analytics events for:

- sensitive case access;
- moderation action;
- finance/refund/payout action;
- break-glass use;
- export or deletion exception;
- feature-control change; and
- incident response action.

Operator events require actor capability, reason category, scope, target type,
request/case reference, result, and timestamp. Do not store private case notes
or evidence content in analytics.

---

## 8. Dashboards and metrics

### 8.1 Product health

Track:

- startup success and time to ready;
- onboarding/profile completion;
- discovery load, empty, error, and refresh rates;
- profile-to-follow/message/call conversion as approved aggregate funnels;
- conversation creation and message acceptance;
- call request/accept/connect/end outcomes; and
- notification delivery and suppression.

Do not use private message bodies, hidden ranking features, or raw identities to
build ordinary product dashboards.

### 8.2 Reliability and operations

Track:

- API latency and error rate by route family;
- auth/recovery failures and session revocations;
- cursor/pagination failures;
- message acceptance/delivery/notification failures;
- RTC connect/reconnect/failure buckets;
- job retry/dead-letter rates;
- webhook verification and processing failures;
- deletion completion and exception rate;
- storage/bandwidth/database/queue cost; and
- provider degradation.

### 8.3 Safety

Track aggregate metrics:

- report volume and category;
- time to triage/first review/resolution;
- queue age and coverage;
- block/restriction effectiveness;
- appeal volume and outcome;
- evidence-access anomalies; and
- critical escalation timing.

Safety dashboards must protect reporter identity, evidence, private content, and
internal risk signals.

### 8.4 Finance and monetization

Track aggregate, access-controlled metrics:

- purchase verification outcomes;
- pending/fulfilled/refunded/chargeback counts;
- call settlement and reconciliation exceptions;
- ledger invariant failures;
- pending/available/held/paid earning totals where finance approves;
- payout success/failure/hold/reversal; and
- provider/store fee and cost categories.

Financial dashboards must not become a place to expose raw receipts, payout
destinations, tax records, or fraud case details.

### 8.5 Event quality

Monitor:

- schema validation failures;
- unknown event names/properties;
- duplicate event rate;
- event delivery lag;
- consent/opt-out suppression failures;
- deletion propagation failures;
- provider ingestion failures; and
- sampling or aggregation discrepancies.

---

## 9. Access, providers, and governance

### 9.1 Analytics access

Analytics access is role-limited:

| Role | Allowed access |
| --- | --- |
| Product | Approved aggregate product metrics |
| Engineering | Reliability and safe technical diagnostics |
| Security | Security signals and restricted investigations |
| Safety | Aggregate safety metrics and assigned-case operational metrics |
| Finance | Protected aggregate financial/reconciliation metrics |
| Support | Case status/volume metrics, not raw private content |
| Vendor/provider | Only data contractually approved for the service |
| Infrastructure | Storage/service operation, not routine user content |

Raw or pseudonymous event access requires a documented purpose, expiry, audit,
and deletion/retention policy. Export is disabled by default and must be
encrypted and time-limited when approved.

### 9.2 Provider review

Before sending events to an analytics, crash, attribution, or observability
provider, record:

- event names/properties shared;
- purpose and owner;
- consent/notice status;
- region/data transfer;
- provider retention/deletion;
- subprocessors and support access;
- security controls;
- account deletion/opt-out propagation;
- cost and sampling behavior; and
- exit/export plan.

Provider SDKs must be configured to disable unused collection and optional
device/attribution identifiers where practical.

### 9.3 Debug and staging data

Development/staging dashboards use synthetic or test-account data. Do not copy
production message bodies, media, receipts, reports, identity data, or private
provider payloads into fixtures, screenshots, or local databases.

---

## 10. Testing and validation

### 10.1 Schema tests

Test:

- required/optional fields;
- enum and length constraints;
- unknown-property rejection;
- event name/version allowlist;
- timestamp and event-ID validation;
- duplicate/retry behavior;
- source authorization; and
- safe failure without blocking core product actions.

### 10.2 Privacy tests

Automated scans and fixtures must confirm that events cannot contain:

- access/refresh tokens or authorization headers;
- email, phone, password, recovery code;
- advertising ID, hardware ID, stable fingerprint, or precise location;
- message body, media URL/content, report explanation, or moderation evidence;
- payment receipt, purchase token, payout destination, or identity document; and
- raw provider payloads or secrets.

Test account deletion/opt-out propagation and provider suppression behavior.

### 10.3 Source-of-truth tests

For server-confirmed events, verify that:

- the event is not emitted before the durable state change;
- duplicate commands produce at most one business event where required;
- failed/pending commands emit the correct outcome;
- event references point to authorized resources; and
- analytics failure does not roll back the business transaction.

### 10.4 Dashboard checks

Before release, validate sample counts and definitions against:

- API/database source metrics;
- job/provider reconciliation;
- call settlement records;
- safety case records; and
- purchase/ledger records.

Analytics may be eventually consistent, but financial, safety, and authorization
systems must not depend on an analytics dashboard as their source of truth.

---

## 11. Open decisions

1. Analytics provider, crash provider, observability provider, and data regions.
2. Anonymous/session/account reference policy and rotation period.
3. Optional analytics consent and regional notice requirements.
4. Event retention, aggregate retention, backup retention, and deletion behavior.
5. Exact event allowlist, sampling, and dashboard owners.
6. Security telemetry retention and restricted-access process.
7. Financial and safety metric access roles.
8. Attribution use, if any, and explicit prohibition/approval of advertising IDs.
9. Provider data-processing, subprocessors, transfer, and export terms.
10. Cost budgets, event-volume limits, and emergency sampling/disable controls.

---

## 12. Approval checklist

- [ ] Every event has an owner, purpose, schema version, source, retention, and access policy.
- [ ] The event/property allowlist is implemented and unknown fields are rejected or safely ignored by policy.
- [ ] No advertising IDs, stable fingerprints, message bodies, media URLs, receipts, tokens, or moderation evidence are collected by default.
- [ ] Consent/notice and opt-out/deletion behavior are approved.
- [ ] Client events cannot claim server-confirmed financial, call, moderation, or account outcomes.
- [ ] Server/outbox events are idempotent and emitted after authoritative state.
- [ ] Analytics failure cannot block core product, safety, deletion, or financial actions.
- [ ] Provider review, retention, region, subprocessors, and access controls are complete.
- [ ] Privacy/redaction scans and schema tests pass.
- [ ] Dashboards use source-of-truth reconciliation and protect sensitive data.
- [ ] No target-specific telemetry names, identifiers, SDK behavior, or private payloads have been reused.
