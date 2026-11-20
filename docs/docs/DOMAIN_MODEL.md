# Domain Model — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Engineering and product owners to be assigned  
**Last updated:** 2026-10-25  
**Source of truth for:** Domain entities, relationships, lifecycle states,
ownership, authorization, retention, invariants, and persistence boundaries  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/DISASTER_RECOVERY.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0005-data-retention.md`,
`reports/chato-deeper-static-analysis.md`,
`reports/chato-plugin-registration.csv`, `replica/schema.sql`,
`replica/backend.md`

This document defines an independent domain model for the social discovery,
messaging, paid one-to-one video-call, moderation, and host-earnings product.
It converts product requirements into implementation-oriented entities without
copying the analyzed application's source, private backend, package names,
proprietary assets, or exact data model.

This is a logical model, not a production migration. Exact SQL types, indexes,
row-level-security policies, provider-specific columns, and deployment choices
must be implemented in versioned migrations after the product and architecture
decisions are approved.

---

## 1. Modeling rules and terminology

### 1.1 Evidence and decision labels

- **Observed/static:** present in the authorized artifact evidence, but not
  runtime verified.
- **Inferred:** a reasonable functional hypothesis based on evidence or generic
  product behavior.
- **Proposed:** an independent design choice for this product.
- **Required:** must be true for the relevant release milestone.
- **Unknown:** not established; do not silently turn it into a fact.

The supplied target artifact was not successfully executed in the current
environment. The entities in this document are therefore independent product
designs informed by generic evidence, not claims about the target's private
schema.

### 1.2 Static-analysis consequence — October 25, 2026

The deeper report found a thin Flutter host, 53 registered plugin capabilities,
and a target-specific advertising-ID lookup path, but no recoverable Dart domain
model or backend contract. Therefore:

- plugin registration does not add entities to this model automatically;
- the target's device channel and advertising-ID behavior are not domain
  requirements and must not be copied;
- telemetry and attribution remain outside the core identity, authorization,
  economy, safety, and call aggregates; and
- optional capabilities such as translation, recording, camera effects,
  Bluetooth routing, overlays, downloads, and background calls require separate
  product approval and retention rules before entities or columns are added.

### 1.3 Account terminology

- **Account:** authenticated identity and security boundary.
- **User/viewer:** account that discovers profiles and may request calls.
- **Host:** account approved to offer eligible one-to-one calls and earn under
  the approved policy.
- **Operator:** staff or service identity with a narrowly scoped capability such
  as moderation, support, finance, payout, or infrastructure.
- **Participant:** an account that belongs to a conversation or call.

An account may have more than one approved role only when the role assignment is
explicit, reviewed, and represented in the authorization system. A UI label is
not a role grant.

### 1.4 Canonical data rules

- All server timestamps use UTC and a timezone-aware database type.
- Client-visible IDs are opaque, stable, and non-sequential where enumeration is
  a risk. UUIDv4, UUIDv7, or an equivalent approved identifier may be used.
- Monetary values use integer minor units, such as paise, never binary floating
  point.
- Currency is stored explicitly with every monetary amount.
- Enumerated status values are validated at the database and application
  boundaries.
- User-provided text is length-limited, normalized, encoded safely, and stored
  separately from rendered markup.
- Provider IDs are stored only when needed for reconciliation, support, or
  lifecycle operations.
- Secrets, access tokens, receipts, identity documents, and raw provider
  payloads are not normal domain fields exposed to clients.
- Advertising identifiers and device fingerprints are not account identity
  fields. If a separately approved attribution use exists, keep it in a
  purpose-limited telemetry system with its own consent, retention, access, and
  deletion rules rather than in the core domain model.
- JSON is used only for versioned, bounded, non-relational metadata. Important
  authorization, financial, or lifecycle fields remain typed columns.

### 1.5 Ownership language

Each entity definition uses one of these ownership patterns:

- **Account-owned:** the authenticated account controls the record within policy.
- **Participant-owned:** every authorized participant may read or act only on
  the portion allowed by the conversation/call policy.
- **Target-scoped:** access depends on the target resource and the actor's
  relationship to it.
- **Operator-scoped:** a staff role may access the record only through an
  assigned case or capability.
- **System-owned:** only backend jobs or service roles may create or transition
  the record.
- **Public projection:** a privacy-filtered read model, not the private source
  row.

### 1.6 Soft deletion and retention language

The model distinguishes:

- **active:** usable under current policy;
- **hidden:** excluded from public projections but retained;
- **suspended:** restricted by moderation or operations;
- **deleted/anonymized:** user-facing identity removed or replaced;
- **retained:** kept because of safety, legal, tax, fraud, or reconciliation
  requirements; and
- **purged:** permanently removed after the approved retention period.

Financial and safety records must not be silently deleted to make a UI or
balance look correct. Use anonymization or compensating entries where required.

---

## 2. Aggregate boundaries

Aggregates define transaction and authorization boundaries. A transaction should
change one aggregate and its explicitly owned children unless a documented
cross-aggregate command requires an atomic write or an outbox event.

| Aggregate | Root | Owned children | Primary invariants |
| --- | --- | --- | --- |
| Identity | `Account` | sessions, identities, consent records, role assignments, deletion request | One active account identity per approved provider link; suspended/deleted accounts cannot authenticate normally |
| Profile | `Profile` | profile media links, tags, availability projection | Only owner/approved host workflow can edit; public projection excludes private fields |
| Relationship | `Relationship` | none | Actor-target uniqueness; block overrides positive relationship actions |
| Match | `MatchAttempt` | match decisions, optional entitlement consumption | One final decision; retries do not create duplicate effects |
| Conversation | `Conversation` | participants, messages, message media links, read markers | Only current participants can read/write under policy |
| Call | `CallSession` | participants, call events, RTC grant audit, meter samples, settlement | Valid state transitions; one final outcome; one settlement |
| Economy | `LedgerTransaction` | ledger entries, fulfillment links, compensating references | Balanced append-only transaction; idempotent source effect |
| Wallet | `WalletAccount` | balance projection, entitlement links | Projection can be rebuilt from ledger; client cannot write balance |
| Host earnings | `HostEarning` | holds, adjustments, payout links | Earnings state follows settlement and policy; no premature availability |
| Safety | `SafetyCase` | evidence links, moderation actions, appeals | Reporter privacy; auditable action history; least-privilege evidence |
| Notification | `Notification` | delivery attempts, device targets | Minimal payload; deduplicated and preference-aware delivery |
| Support | `SupportCase` | messages, attachments, operator assignments | Case access and sensitive actions are audited |
| Operations | `AuditEvent` / `WebhookEvent` / `JobRun` | none or bounded metadata | Append-only evidence of sensitive actions and integration processing |

### Aggregate transaction rule

Do not update a wallet balance, call status, host earning, and notification as
unrelated client-side operations. The backend should:

1. validate the command;
2. lock or compare the relevant aggregate version;
3. apply the domain transition in a transaction;
4. write an outbox/event record when another module must react; and
5. let an idempotent worker deliver notifications or provider side effects.

---

## 3. Entity catalog

### 3.1 Core entities

| Entity | Required | Purpose |
| --- | --- | --- |
| `Account` | Yes | Authenticated identity and account lifecycle |
| `AccountIdentity` | Yes | Email or approved external-provider identity link |
| `Session` | Yes | Revocable login/device session |
| `DeviceRegistration` | Yes for push | Push target and device metadata |
| `RoleAssignment` | Yes | User/host/operator role grant |
| `ConsentRecord` | Yes | Versioned policy, privacy, media, or recording consent |
| `Profile` | Yes for discoverable account | Public presentation and host-facing profile |
| `MediaObject` | If media is enabled | Stored profile/message/report media metadata |
| `ProfileMedia` | If media is enabled | Ordered association between profile and media |
| `ProfileTag` | Optional | Normalized public tag association |
| `Availability` | If calling is enabled | Host call eligibility and schedule state |
| `Relationship` | Yes | Follow, favorite, request, or block relationship |
| `MatchAttempt` | If matching is enabled | Match request, candidate, and decision |
| `Conversation` | If messaging is enabled | Conversation root |
| `ConversationParticipant` | If messaging is enabled | Authorized membership and state |
| `Message` | If messaging is enabled | Text, attachment, gift, call, or system message |
| `MessageAttachment` | If attachments are enabled | Validated media association |
| `CallSession` | If calls are enabled | One-to-one call lifecycle |
| `CallParticipant` | If calls are enabled | Participant role and call-specific state |
| `CallEvent` | If calls are enabled | Append-only call/provider evidence |
| `RtcGrantAudit` | If calls are enabled | Safe record of token issuance, not token plaintext |
| `CallMeterSample` | If billing/measurement is enabled | Server/provider connection evidence |
| `CallSettlement` | If billing is enabled | Final billable duration and settlement decision |

### 3.2 Economy entities

| Entity | Required | Purpose |
| --- | --- | --- |
| `PricingPolicy` | Before billing | Versioned rates and billing rules |
| `WalletAccount` | If credits are enabled | Account-level virtual balance projection |
| `LedgerAccount` | Before financial ledger | Double-entry account for an owner or platform bucket |
| `LedgerTransaction` | Before financial ledger | Atomic business financial event |
| `LedgerEntry` | Before financial ledger | Debit/credit line in a ledger transaction |
| `Purchase` | If store billing is enabled | Store purchase verification and fulfillment state |
| `Entitlement` | If credits/subscriptions are enabled | Granted access, credits, ticket, or subscription |
| `GiftDefinition` | If gifts are enabled | Product-owned gift catalog item |
| `GiftTransfer` | If gifts are enabled | User-to-user gift spend and recipient record |
| `HostEarning` | Before host payouts | Host-side amount and availability state |
| `EarningHold` | Before host payouts | Fraud, refund, dispute, or policy hold |
| `PayoutProfile` | Before host payouts | Verified destination and eligibility status |
| `Payout` | Before host payouts | Payout request and provider outcome |
| `RefundCase` | If refunds are supported | Approved refund and compensating-entry workflow |

### 3.3 Safety, support, and operations entities

| Entity | Required | Purpose |
| --- | --- | --- |
| `SafetyCase` | Before public launch | Private report and moderation case |
| `SafetyEvidence` | If evidence is attached | Restricted snapshot or media reference |
| `ModerationAction` | Before public launch | Enforcement/review action and audit detail |
| `Appeal` | If appeals are supported | User appeal of a documented action |
| `SupportCase` | Before public launch | User support and finance/support workflow |
| `Notification` | If notifications are enabled | User-visible application event |
| `NotificationDelivery` | If notifications are enabled | Provider delivery attempt and result |
| `AuditEvent` | Required for sensitive operations | Append-only actor/action evidence |
| `IdempotencyRecord` | Required for effectful APIs | Replay-safe result record |
| `WebhookEvent` | Required for provider webhooks | Verified provider-event envelope and processing state |
| `OutboxEvent` | Recommended | Transactional event awaiting delivery |
| `JobRun` | Recommended | Retryable background job execution record |
| `AccountDeletionRequest` | Before public launch | Authenticated deletion workflow and exceptions |

### 3.4 Deferred or optional entities

The following may be added only with separate requirements:

- public live/audio room and room membership;
- task, reward, referral, invite, and reward claim;
- translation request and translated message projection;
- subscription plan and feature entitlement catalog;
- content-safety scan result;
- experiment assignment and ranking feature exposure;
- tax form and withholding record;
- regional policy and age-verification record; and
- export request/data portability package.

Static evidence suggested some of these surfaces, but their exact rules were
not verified. They must not be added as undocumented production behavior.

Telemetry and attribution events are intentionally not core domain entities in
this model. If approved later, they belong to a separately governed event
pipeline with an allowlist, consent checks, retention limits, and no authority
over account, call, moderation, or financial state.

---

## 4. Identifier, timestamp, and common column conventions

### 4.1 Common columns

Most mutable entities should use:

```text
id                  opaque public identifier
created_at          server-generated UTC timestamp
updated_at          server-generated UTC timestamp when mutable
version             optimistic-concurrency integer or equivalent
status              constrained lifecycle enum where applicable
```

Entities with deletion or retention requirements may also use:

```text
deleted_at          nullable UTC timestamp; not a substitute for retention policy
deleted_by          nullable actor/service identifier
retention_class     controlled retention category
redaction_state     none / partially_redacted / anonymized / purged
```

Append-only entities such as ledger entries, call events, audit events, webhook
events, and moderation actions must not have ordinary update semantics. A
correction is a new record or a linked compensating record.

### 4.2 Actor references

Use explicit actor columns where action provenance matters:

```text
actor_account_id       nullable for system/provider actions
actor_role             role/capability used for the action
source                  client / api / worker / provider / operator
request_id             correlation reference
idempotency_key        effect deduplication reference where applicable
```

Do not infer the actor from a mutable display name or email address.

### 4.3 Provider references

Provider references should be stored in a bounded, redacted form:

```text
provider_name           controlled adapter identifier
provider_object_type    purchase / room / event / payout / message, etc.
provider_object_id      opaque provider reference
provider_event_id       verified event identifier when applicable
provider_created_at     provider timestamp if supplied and trusted enough to retain
```

Never store provider secrets, raw authorization headers, or unbounded provider
payloads in ordinary entity rows.

### 4.4 Currency and amount value object

Every monetary value is represented logically as:

```text
amount_minor: integer >= 0
currency:     ISO-like approved currency code
```

Signed ledger direction is represented by a debit/credit direction or a signed
entry convention chosen in the financial ADR. Do not mix conventions in one
ledger.

The current planning assumption is 1,500 paise user charge and 600 paise host
earning per billable minute, but those values belong to a `PricingPolicy` row,
not a hard-coded entity default.

---

## 5. Identity, account, consent, and device entities

### 5.1 `Account`

**Purpose:** Authenticated security boundary for a person or approved service
identity.

**Ownership:** System-owned root; the account holder may update permitted
self-service fields. Operators may access only through their capability and case
scope.

**Proposed fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Stable public/account reference |
| `account_type` | enum | Yes | `person`, `service`, or approved future type |
| `status` | enum | Yes | See lifecycle below |
| `primary_locale` | locale code | Yes | Presentation preference, not necessarily location |
| `country_code` | nullable region code | No | Only when collected, consented, and needed |
| `timezone` | nullable IANA timezone | No | UI scheduling only; server timestamps remain UTC |
| `date_of_birth` | protected date or age proof reference | Policy-dependent | Do not expose in public profile |
| `age_band` | enum | Derived/optional | Prefer a minimized age category where exact DOB is unnecessary |
| `email_verified_at` | UTC timestamp | No | Auth assurance state |
| `last_seen_at` | UTC timestamp | No | Privacy-controlled; do not expose exact time by default |
| `created_at` | UTC timestamp | Yes | Server-generated |
| `updated_at` | UTC timestamp | Yes | Server-generated |
| `suspended_at` | UTC timestamp | No | Set by documented enforcement |
| `suspension_reason_code` | controlled code | No | Do not expose internal detail to clients |
| `deleted_at` | UTC timestamp | No | Account deletion/anonymization marker |
| `deletion_request_id` | opaque ID | No | Link to deletion workflow |
| `version` | integer | Yes | Optimistic concurrency |

**Account status state machine:**

```text
pending_verification -> active
pending_verification -> verification_failed | deleted
active -> restricted | suspended | deletion_requested
restricted -> active | suspended | deletion_requested
suspended -> active | deleted
deletion_requested -> deleting -> deleted
```

Additional legal or safety states may be introduced, but every state must define
what happens to authentication, discovery, messaging, calls, purchases,
earnings, and support access.

**Invariants:**

- `id` is never reused.
- A deleted account cannot create new sessions.
- A suspended account cannot initiate or accept calls unless an approved
  support/recovery action explicitly allows it.
- Account status changes are audited.
- Public profile data is not the source of truth for authentication identity.
- Exact date of birth and identity data are not returned in public profile APIs.

**Indexes/constraints:**

- unique normalized authentication identity is enforced in `AccountIdentity`,
  not by a public display name;
- index by `status`, `created_at`, and deletion workflow status;
- check that suspension/deletion timestamps are compatible with status; and
- prevent `active` state with a non-null completed deletion marker.

**Retention:** Account security and financial references may be retained after
public deletion. Personal profile data should be deleted or anonymized under
the approved privacy policy.

### 5.2 `AccountIdentity`

**Purpose:** Links an account to an authentication method without making the
provider identity the public domain model.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Internal identity-link ID |
| `account_id` | account ID | Yes | Owning account |
| `provider` | enum | Yes | `email`, `google`, `apple`, or another approved provider |
| `provider_subject_hash` | protected opaque value | Yes | Prefer a non-reversible lookup hash where possible |
| `normalized_email` | protected normalized value | Provider-dependent | Never expose in public APIs |
| `verified_at` | UTC timestamp | No | Provider/account verification |
| `last_used_at` | UTC timestamp | No | Security telemetry with retention limits |
| `linked_at` | UTC timestamp | Yes | Link creation |
| `unlinked_at` | UTC timestamp | No | Do not allow removal of the last recovery method without a replacement |
| `status` | enum | Yes | `active`, `revoked`, `unlinked`, `pending` |

**Invariants:**

- One active provider subject can link to only one account unless an approved
  merge workflow exists.
- Provider access/refresh tokens are not stored here in plaintext.
- Linking and unlinking require authenticated step-up checks where appropriate.
- Account merge is a separate audited operation; never silently merge records.

### 5.3 `Session`

**Purpose:** Revocable authenticated session for an account and device.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Session reference |
| `account_id` | account ID | Yes | Owner |
| `device_registration_id` | nullable ID | No | Push/device link |
| `token_family_id` | opaque ID | Yes | Refresh rotation family; never expose raw token |
| `created_at` | UTC timestamp | Yes | Session start |
| `last_used_at` | UTC timestamp | Yes | Security activity |
| `expires_at` | UTC timestamp | Yes | Absolute or rolling expiry policy |
| `revoked_at` | UTC timestamp | No | Revocation timestamp |
| `revocation_reason` | controlled code | No | Logout, security, deletion, etc. |
| `client_version` | bounded string | No | Support/compatibility metadata |
| `os_family` | controlled value | No | Do not use as an identity signal without approval |

Raw access and refresh tokens are never stored in this entity or normal logs.

**Invariants:** A revoked, expired, suspended-account, or deleted-account
session cannot authenticate protected requests.

### 5.4 `DeviceRegistration`

**Purpose:** Associates an account with a push-notification target.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Device registration reference |
| `account_id` | account ID | Yes | Owner |
| `platform` | enum | Yes | `android`, future approved platforms |
| `push_token_reference` | protected token reference | Yes | Encrypt or protect according to provider rules |
| `app_environment` | enum | Yes | `local`, `development`, `staging`, `production` |
| `permission_state` | enum | Yes | `unknown`, `granted`, `denied`, `revoked` |
| `app_version` | bounded string | No | Compatibility/support metadata only |
| `device_family` | bounded controlled value | No | Coarse capability/support metadata; not a fingerprint |
| `last_seen_at` | UTC timestamp | Yes | Device activity |
| `invalidated_at` | UTC timestamp | No | Provider rejection or logout cleanup |
| `created_at` | UTC timestamp | Yes | Registration time |

**Invariants:** A production token must never be used by a development
environment. Invalidated tokens are not selected for new notifications. Raw
advertising IDs, hardware identifiers, stable fingerprints, and provider access
tokens are not stored in this entity. Any approved attribution reference is
owned by a separate telemetry boundary and is not used for authorization,
account lookup, pricing, moderation, or call settlement.

### 5.5 `RoleAssignment`

**Purpose:** Grants a role or capability to an account for a bounded scope.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Assignment reference |
| `account_id` | account ID | Yes | Subject |
| `role` | enum | Yes | `user`, `host`, `moderator`, `support`, `finance`, `payout`, `infrastructure` |
| `scope` | bounded JSON/value | Yes | Region, queue, or resource scope; not arbitrary client input |
| `status` | enum | Yes | `pending`, `active`, `suspended`, `revoked`, `expired` |
| `granted_by` | actor ID | Yes | Human/service actor |
| `reason_code` | controlled code | Yes | Why the grant exists |
| `starts_at` | UTC timestamp | Yes | Effective time |
| `ends_at` | UTC timestamp | No | Expiry/review time |
| `created_at` | UTC timestamp | Yes | Audit timestamp |

**Invariants:** Role assignments are not self-grantable. Sensitive roles require
separation of duties and audit review.

### 5.6 `ConsentRecord`

**Purpose:** Records a versioned consent or acknowledgement for a defined scope.

**Consent scopes may include:**

- terms of service;
- privacy policy;
- community guidelines;
- age/eligibility acknowledgement;
- camera and microphone education;
- recording consent if recording is ever approved;
- marketing/analytics consent where required; and
- host agreement or payout terms.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Consent reference |
| `account_id` | account ID | Yes | Consenting account |
| `scope` | enum | Yes | Controlled consent purpose |
| `document_version` | string | Yes | Exact policy/content version |
| `decision` | enum | Yes | `accepted`, `declined`, `withdrawn`, `expired` |
| `captured_at` | UTC timestamp | Yes | Server time |
| `withdrawn_at` | UTC timestamp | No | If applicable |
| `capture_context` | bounded metadata | No | Platform/app version/locale; no raw device secrets |
| `source` | enum | Yes | `app`, `web`, `operator`, `system` |

**Invariants:** A feature requiring consent must check the current applicable
version and scope, not merely the existence of any old consent row.

### 5.7 `AccountDeletionRequest`

**Purpose:** Tracks an authenticated account deletion workflow.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Workflow reference |
| `account_id` | account ID | Yes | Subject |
| `status` | enum | Yes | `requested`, `confirmed`, `processing`, `blocked`, `completed`, `failed`, `canceled` |
| `requested_at` | UTC timestamp | Yes | Initial request |
| `confirmed_at` | UTC timestamp | No | Re-auth/confirmation |
| `completed_at` | UTC timestamp | No | Finished timestamp |
| `retention_exception_codes` | controlled list | No | Safety/financial/legal retained categories |
| `last_error_code` | safe code | No | Retry/support state, not stack trace |
| `attempt_count` | integer | Yes | Bounded retry count |
| `requested_by` | actor ID | Yes | Usually the account owner |

**Deletion states:**

```text
requested -> confirmed -> processing -> completed
                         |-> blocked
                         |-> failed -> processing
requested -> canceled
```

The workflow revokes sessions and stops new discovery/messages/calls before
destructive cleanup. It must be safe to retry after a process crash.

---

## 6. Profile, media, availability, and discovery entities

### 6.1 `Profile`

**Purpose:** Public or limited-visibility presentation for an account.

**Ownership:** Account-owned for edits; public projection is read through
privacy and eligibility filters. Host-specific fields require the host role.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | profile ID | Yes | May equal account ID internally, but keep domain boundary explicit |
| `account_id` | account ID | Yes | Owner; unique active profile per account |
| `visibility` | enum | Yes | `private`, `discoverable`, `unlisted`, `hidden`, `suspended` |
| `display_name` | bounded text | Yes | Independent user-facing name |
| `bio` | bounded text | Yes | Sanitized plain text |
| `locale` | locale code | Yes | Communication preference |
| `country_code` | nullable region code | No | Broad region only when approved and consented |
| `gender_identity` | protected/controlled value | Policy-dependent | Do not collect or expose without approved purpose |
| `pronouns` | controlled/nullable value | No | Optional and privacy-controlled |
| `verification_state` | enum | Yes | `not_started`, `submitted`, `under_review`, `approved`, `rejected`, `expired` |
| `level` | integer/nullable | No | If product approves a progression system; server-derived |
| `headline` | bounded text | No | Optional independent profile field |
| `profile_version` | integer | Yes | Changes when public projection materially changes |
| `created_at` | UTC timestamp | Yes | Creation |
| `updated_at` | UTC timestamp | Yes | Last edit |
| `published_at` | UTC timestamp | No | First public exposure |
| `deleted_at` | UTC timestamp | No | Profile removal marker |

**Invariants:**

- Only the account owner or approved host workflow can edit self-owned fields.
- A profile for a suspended/deleted account cannot be discoverable.
- Public responses are projections; never serialize private account fields by
  default.
- Verification state is not a guarantee of safety or conduct.
- Profile changes that affect eligibility may require re-review.

**Indexes/constraints:** unique active profile per account; indexes on visibility,
verification state, availability freshness, locale/region only where approved;
full-text/search indexes must not bypass block/suspension filters.

### 6.2 `MediaObject`

**Purpose:** Server-tracked media file or media processing result.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Media reference |
| `owner_account_id` | account ID | Yes | Original uploader |
| `storage_provider` | adapter ID | Yes | Storage seam |
| `storage_object_key` | protected opaque path | Yes | Never accept raw client path |
| `media_type` | enum | Yes | `image`, `video`, `audio`, `document`, future approved type |
| `mime_type` | controlled value | Yes | Validated server-side |
| `size_bytes` | integer | Yes | Maximum enforced |
| `width` / `height` | integer | No | For visual media |
| `duration_ms` | integer | No | For audio/video |
| `upload_state` | enum | Yes | `requested`, `uploading`, `uploaded`, `scanning`, `ready`, `failed`, `expired`, `deleted` |
| `moderation_state` | enum | Yes | `not_required`, `pending`, `approved`, `held`, `rejected`, `removed` |
| `content_hash` | protected hash | No | Deduplication/abuse analysis, subject to privacy review |
| `created_at` | UTC timestamp | Yes | Upload instruction creation or object record |
| `ready_at` | UTC timestamp | No | Approved for use |
| `expires_at` | UTC timestamp | No | Temporary upload or signed access expiry |
| `deleted_at` | UTC timestamp | No | Logical deletion |

**Invariants:** An attachment or profile association may reference only a media
object that is `ready` and permitted for that context. Private object keys and
signed URLs are never public domain fields.

### 6.3 `ProfileMedia`

**Purpose:** Ordered association between a profile and validated media.

**Fields:** `id`, `profile_id`, `media_object_id`, `role` (`avatar`, `gallery`,
`intro`, or approved future type), `sort_order`, `is_primary`, `status`,
`created_at`, `removed_at`.

**Invariants:** One active primary avatar per profile; media owner must match
profile owner; only approved media states can be published; removing media does
not erase safety evidence or the underlying object before retention permits it.

### 6.4 `ProfileTag`

**Purpose:** Normalized, searchable tag association.

**Fields:** `id`, `profile_id`, `tag_key`, `display_label`, `locale`, `source`
(`user`, `system`, `moderator`), `status`, `created_at`, `removed_at`.

**Invariants:** Normalize tag keys for uniqueness; user input cannot create
reserved moderation or system tags; removed tags leave audit evidence where
needed.

### 6.5 `Availability`

**Purpose:** Host call eligibility and broad availability projection.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Availability record |
| `host_account_id` | account ID | Yes | Must have active host assignment |
| `mode` | enum | Yes | `offline`, `available`, `busy`, `paused`, `restricted` |
| `call_types` | controlled list | Yes | Only approved call modes |
| `schedule_rule_ref` | nullable ID | No | Future scheduled availability |
| `last_heartbeat_at` | UTC timestamp | No | Provider/app heartbeat, not a guarantee |
| `expires_at` | UTC timestamp | No | Presence freshness boundary |
| `updated_at` | UTC timestamp | Yes | Server-generated |
| `source` | enum | Yes | `host_app`, `server`, `operator`, `provider` |

**Invariants:** Expired heartbeat cannot appear as live availability. Busy,
suspended, blocked, or ineligible hosts cannot receive new call requests.

### 6.6 `DiscoveryPolicy`

**Purpose:** Versioned independent rules for discovery filters and ranking.

This is not a copy of any target ranking behavior.

**Fields:** `id`, `version`, `status` (`draft`, `active`, `retired`), bounded
configuration reference, eligible regions/roles, experiment reference if any,
`created_by`, `approved_at`, `created_at`, `retired_at`.

**Invariants:** A feed request records the policy version used when a ranking
decision must be reproducible. Policy configuration cannot expose sensitive
attributes or bypass block/deletion/eligibility filtering.

### 6.7 `DiscoverySnapshot` (optional read model)

**Purpose:** Cacheable, privacy-filtered feed projection for a user or anonymous
session. It is not the source of truth for profile authorization.

**Fields:** `id`, `viewer_account_id` nullable, `policy_version`, filter hash,
profile IDs/order, generated timestamp, expires timestamp, source cursor.

**Rules:** Never cache a profile for a viewer after a block/suspension change
without invalidation or a server-side re-check. Do not store sensitive ranking
features in a client-readable snapshot.

---

## 7. Relationship and matching entities

### 7.1 `Relationship`

**Purpose:** Represents an actor-to-target relationship such as follow, favorite,
request, or block.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Relationship record |
| `actor_account_id` | account ID | Yes | Initiating account |
| `target_account_id` | account ID | Yes | Target account |
| `kind` | enum | Yes | `follow`, `favorite`, `block`, `mute`, `request` |
| `state` | enum | Yes | `active`, `pending`, `accepted`, `rejected`, `removed`, `expired` |
| `source` | enum | Yes | `profile`, `match`, `message`, `call`, `settings`, `operator` |
| `created_at` | UTC timestamp | Yes | Initial action |
| `updated_at` | UTC timestamp | Yes | State change |
| `removed_at` | UTC timestamp | No | End of positive relationship |
| `version` | integer | Yes | Concurrency |

**Invariants:**

- Actor and target must differ.
- Active uniqueness is `(actor_account_id, target_account_id, kind)`.
- Block has precedence over follow, favorite, request, match, message, and call
  eligibility according to the approved policy.
- Relationship commands are idempotent.
- A user cannot create a relationship against a deleted or permanently
  suspended target, though retained history may remain.
- Operators cannot create user relationships as a hidden support shortcut.

**Read rules:** A user can read their own positive relationship state and the
minimum public relationship signal approved for another profile. Block rows are
especially restricted and should not be exposed as a discoverable list to the
blocked account.

### 7.2 `MatchAttempt`

**Purpose:** Records a user-initiated matching request and its result.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Match attempt ID |
| `requester_account_id` | account ID | Yes | Initiating user |
| `policy_version` | string | Yes | Matching policy snapshot |
| `filter_snapshot` | bounded sanitized JSON | Yes | No unnecessary sensitive data |
| `status` | enum | Yes | `requested`, `searching`, `candidate_found`, `accepted`, `skipped`, `canceled`, `expired`, `no_result`, `failed` |
| `candidate_account_id` | nullable account ID | No | Assigned candidate |
| `candidate_expires_at` | UTC timestamp | No | Candidate decision window |
| `entitlement_id` | nullable ID | No | Ticket/credit consumption if approved |
| `decision` | enum | No | `accept`, `skip`, `message`, `call`, `none` |
| `idempotency_key` | bounded opaque value | Yes | Caller request deduplication |
| `created_at` | UTC timestamp | Yes | Start |
| `updated_at` | UTC timestamp | Yes | Last state change |
| `completed_at` | UTC timestamp | No | Terminal state |
| `failure_code` | safe code | No | Retry/support category |

**Invariants:**

- One idempotency key for an account and operation maps to one attempt/result.
- Candidate eligibility is rechecked when the user accepts or acts.
- Blocked, deleted, suspended, and unavailable candidates are not returned.
- Entitlement consumption and reversal follow an approved policy and are
  recorded, not inferred from UI.
- Only the requester can view their full filter snapshot and history.

### 7.3 `MatchDecision` (optional child)

**Purpose:** Append-only decision evidence when match history or fraud analysis
requires more than the final `MatchAttempt` row.

**Fields:** `id`, `match_attempt_id`, `actor_account_id`, `decision`, `reason_code`,
`created_at`, `source`, `idempotency_key`.

**Invariant:** At most one final decision per attempt per decision policy. A
correction is a new record, not an update to history.

---

## 8. Messaging and attachment entities

### 8.1 `Conversation`

**Purpose:** Root record for an authorized one-to-one or future approved
conversation.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Conversation ID |
| `kind` | enum | Yes | `direct`, `support`, `system`, future approved type |
| `status` | enum | Yes | `active`, `restricted`, `archived`, `closed`, `deleted` |
| `created_by_account_id` | account ID/system | Yes | Originator |
| `last_message_at` | UTC timestamp | No | Projection for ordering |
| `last_activity_version` | integer | Yes | Concurrency/read model version |
| `created_at` | UTC timestamp | Yes | Creation |
| `updated_at` | UTC timestamp | Yes | Last change |
| `closed_at` | UTC timestamp | No | Closure |
| `retention_class` | enum | Yes | Message retention category |

**Invariants:**

- A direct conversation has exactly two current participants unless an
  explicitly approved group mode exists.
- Conversation access is derived from active participant membership and account
  status, not from a client-known conversation ID.
- A blocked relationship can restrict or close new interactions according to
  policy.
- `last_message_at` is a projection and cannot authorize access.

### 8.2 `ConversationParticipant`

**Purpose:** Membership, per-user state, and authorization boundary for a
conversation.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Membership ID |
| `conversation_id` | conversation ID | Yes | Parent |
| `account_id` | account ID | Yes | Participant |
| `participant_role` | enum | Yes | `user`, `host`, `support`, `system` |
| `status` | enum | Yes | `active`, `left`, `blocked`, `removed`, `read_only` |
| `joined_at` | UTC timestamp | Yes | Membership start |
| `left_at` | UTC timestamp | No | End |
| `last_read_message_id` | nullable message ID | No | Per-user read projection |
| `last_read_at` | UTC timestamp | No | Read timestamp |
| `muted_until` | UTC timestamp | No | Notification preference/projection |
| `notification_preference` | enum | Yes | `all`, `mentions`, `none`, `system_only` |

**Invariants:** Unique active membership per account/conversation. A removed or
blocked participant cannot read new messages unless a legal/safety workflow
explicitly grants limited access.

### 8.3 `Message`

**Purpose:** A conversation event containing text, an attachment reference, a
gift, a call invitation/result, or a system notice.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Message ID |
| `conversation_id` | conversation ID | Yes | Parent |
| `sender_account_id` | account/system ID | Yes | Actor |
| `client_message_id` | bounded opaque value | Yes | Client deduplication reference |
| `message_type` | enum | Yes | `text`, `emoji`, `image`, `gift`, `call_invite`, `call_result`, `system` |
| `body_text` | sanitized text | Conditional | Required for text/emoji/system where applicable |
| `status` | enum | Yes | `submitting`, `accepted`, `held`, `removed`, `failed`, `expired` |
| `moderation_state` | enum | Yes | `not_reviewed`, `approved`, `held`, `removed` |
| `reply_to_message_id` | nullable message ID | No | Thread/reply only if approved |
| `created_at` | UTC timestamp | Yes | Server acceptance time |
| `edited_at` | UTC timestamp | No | If editing is approved |
| `removed_at` | UTC timestamp | No | Logical removal |
| `removed_reason_code` | safe code | No | Policy/support reference |
| `server_sequence` | monotonic per conversation | Yes | Cursor ordering, not public ID |

**Invariants:**

- `client_message_id` is unique for a sender and conversation within the
  retention window.
- A message is not marked delivered/read solely because the sender displayed it.
- Body text is never trusted for authorization or financial decisions.
- Removed content is replaced with a safe placeholder in ordinary user views;
  safety retention is separate.
- Editing/deletion rules must not silently erase required moderation or financial
  evidence.

**Message lifecycle:**

```text
draft -> submitting -> accepted -> delivered -> read
                         |              |
                         v              v
                       failed         expired
                         |
                         v
                        retry
accepted -> held -> approved | removed
```

`delivered` and `read` may be maintained as participant projections rather than
mutating the immutable message row.

### 8.4 `MessageDelivery`

**Purpose:** Recipient-specific delivery/read projection.

**Fields:** `id`, `message_id`, `recipient_account_id`, `delivery_state`
(`pending`, `delivered`, `read`, `failed`, `suppressed`), `delivered_at`,
`read_at`, `failure_code`, `updated_at`.

**Invariants:** A blocked, deleted, or notification-suppressed recipient does
not imply message deletion. Delivery state is not proof that a person read the
content unless the client/provider contract supports that claim.

### 8.5 `MessageAttachment`

**Purpose:** Validated association between a message and a ready media object.

**Fields:** `id`, `message_id`, `media_object_id`, `attachment_type`,
`sort_order`, `status` (`pending`, `ready`, `blocked`, `removed`, `expired`),
`created_at`, `removed_at`.

**Invariants:** Only participants can create an attachment request. The media
owner, conversation membership, moderation state, and retention class must be
compatible. The client receives a controlled access reference, never a permanent
public storage path.

### 8.6 `MessageGift` (optional)

**Purpose:** Domain metadata for a gift message after the economy module has
approved virtual gifts.

**Fields:** `id`, `message_id`, `gift_definition_id`, `gift_transfer_id`,
`sender_account_id`, `recipient_account_id`, `display_state`.

**Invariant:** The gift transfer and message reference must be linked to one
idempotent spend. Displaying a gift cannot grant value a second time.

### 8.7 `CallMessageLink` (optional)

**Purpose:** Links a call invitation or outcome to a conversation without making
the message the source of call authorization.

**Fields:** `message_id`, `call_session_id`, `event_type`, `created_at`.

**Invariant:** The call aggregate remains authoritative for call status,
participants, billing, and settlement.

---

## 9. Notification and deep-link entities

### 9.1 `Notification`

**Purpose:** Application-owned event intended for one account or an approved
operator channel.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Notification ID |
| `recipient_account_id` | account ID | Yes | Target |
| `category` | enum | Yes | `message`, `call`, `reward`, `security`, `support`, `moderation`, `system` |
| `event_type` | controlled value | Yes | Versioned application event |
| `payload_reference` | bounded safe data | Yes | Minimal client-safe data or resource ID |
| `deep_link_intent_id` | nullable ID | No | Authenticated destination intent |
| `status` | enum | Yes | `created`, `queued`, `delivered`, `opened`, `expired`, `suppressed` |
| `deduplication_key` | bounded value | Yes | Prevent repeated event creation |
| `created_at` | UTC timestamp | Yes | Creation |
| `expires_at` | UTC timestamp | No | Important for calls/invites |
| `opened_at` | UTC timestamp | No | User interaction |

**Invariants:** Notification payloads do not contain secrets, raw message
bodies, unrestricted media URLs, or unauthorized profile data. Notification
creation is independent of provider delivery success.

### 9.2 `NotificationDelivery`

**Purpose:** Tracks attempts to deliver a notification to a registered device or
in-app channel.

**Fields:** `id`, `notification_id`, `device_registration_id`, `channel`,
`provider_name`, `provider_message_id`, `status` (`queued`, `sent`, `delivered`,
`failed`, `invalidated`, `expired`), `attempt_count`, `last_attempt_at`,
`failure_code`, `created_at`, `updated_at`.

**Invariants:** One provider failure must not delete the underlying application
notification. Retries are bounded and idempotent.

### 9.3 `DeepLinkIntent`

**Purpose:** Safe, short-lived reference to a destination such as a profile,
conversation, call, support case, or notification.

**Fields:** `id`, `intent_type`, `resource_id`, `recipient_account_id` nullable,
`required_auth_state`, `created_at`, `expires_at`, `consumed_at`, `status`.

**Invariants:** The intent is re-authorized on open. A guessed resource ID or
expired intent cannot reveal private existence or content.

---

## 10. Video-call and RTC entities

### 10.1 `CallSession`

**Purpose:** Application-owned root for one private call request and its
connected/end lifecycle.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Call ID |
| `requester_account_id` | account ID | Yes | Initiating account |
| `recipient_account_id` | account ID | Yes | Requested other participant |
| `host_account_id` | account ID | Yes when paid host call | Approved host earning recipient |
| `call_type` | enum | Yes | `one_to_one_video`, future approved type |
| `status` | enum | Yes | See state machine |
| `failure_code` | safe code | No | User/provider category |
| `cancel_reason_code` | safe code | No | Cancellation source |
| `pricing_policy_id` | nullable ID | No | Required when billable |
| `rate_snapshot_id` | nullable ID | No | Immutable rate snapshot |
| `rtc_room_reference` | protected opaque value | No | Provider room reference, not a secret |
| `created_at` | UTC timestamp | Yes | Request creation |
| `accepted_at` | UTC timestamp | No | Recipient acceptance |
| `connecting_at` | UTC timestamp | No | Media connection attempt |
| `connected_at` | UTC timestamp | No | Server-confirmed connected state |
| `reconnecting_at` | UTC timestamp | No | Latest reconnect transition |
| `ended_at` | UTC timestamp | No | Server-confirmed end |
| `expires_at` | UTC timestamp | Yes | Request/session expiry boundary |
| `updated_at` | UTC timestamp | Yes | Last transition |
| `version` | integer | Yes | Concurrency |
| `idempotency_key` | bounded opaque value | Yes | Request deduplication |

**State machine:**

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

**Invariants:**

- Requester and recipient differ.
- A call has exactly the approved number and roles of participants.
- Only eligible accounts can create or accept the call.
- Block, suspension, deletion, or revoked eligibility prevents new transitions
  that the policy disallows.
- Each transition is validated against the current version.
- There is at most one active billable call per account unless concurrency is
  explicitly approved.
- `connected_at` is not set from an unverified client timer.
- A call can have at most one final settlement outcome.

### 10.2 `CallParticipant`

**Purpose:** Call-specific participant role and media state.

**Fields:** `id`, `call_session_id`, `account_id`, `role` (`caller`, `recipient`,
`host`, `viewer`), `invite_state`, `permission_state`, `media_state`,
`audio_state`, `video_state`, `joined_at`, `left_at`, `last_heartbeat_at`,
`device_route`, `created_at`, `updated_at`.

**Invariant:** Call participant rows do not grant access to the call by
themselves; the call session and current account authorization are required.

### 10.3 `CallEvent`

**Purpose:** Append-only evidence of application or verified provider events.

**Fields:** `id`, `call_session_id`, `event_type`, `previous_status`,
`new_status`, `actor_account_id` nullable, `source`, `provider_name` nullable,
`provider_event_id` nullable, `event_at`, `received_at`, `idempotency_key`,
`safe_metadata`, `created_at`.

**Event sources:** `client_request`, `server`, `worker`, `rtc_provider`,
`operator`, `system_timeout`.

**Invariants:** Events are immutable. A provider event ID is processed once per
provider. Invalid or out-of-order events are retained for reconciliation and do
not blindly overwrite newer state.

### 10.4 `RtcGrantAudit`

**Purpose:** Safe audit of server-issued RTC access without storing token
plaintext.

**Fields:** `id`, `call_session_id`, `participant_account_id`, `provider_name`,
`room_reference`, `grant_scope`, `issued_at`, `expires_at`, `revoked_at`,
`issue_reason`, `request_id`, `token_fingerprint` optional protected hash.

**Invariants:** Token secrets are not persisted in this row. A grant is scoped
to one call and participant role. Expired/revoked grants cannot be reused.

### 10.5 `CallMeterSample`

**Purpose:** Bounded server/provider evidence used to determine connected and
billable intervals.

**Fields:** `id`, `call_session_id`, `participant_account_id`, `sample_type`
(`connected`, `heartbeat`, `disconnected`, `provider_quality`, `reconnect`),
`observed_at`, `received_at`, `source`, `provider_event_id` nullable,
`quality_bucket` nullable, `sequence` nullable.

**Rules:** Samples are evidence, not user-visible financial entries. Retention
and precision must be limited to what billing, support, safety, and quality
analysis require.

### 10.6 `CallSettlement`

**Purpose:** Immutable decision record for the final user charge, host earning,
or no-charge outcome.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Settlement ID |
| `call_session_id` | call ID | Yes | One-to-one unique |
| `status` | enum | Yes | `pending_review`, `calculated`, `posted`, `reversed`, `disputed`, `void` |
| `connected_duration_ms` | integer | Yes | Server/provider-derived |
| `billable_units` | integer | Yes | Approved unit calculation |
| `user_amount_minor` | integer | Yes | Exact charge, possibly zero |
| `host_amount_minor` | integer | Yes | Exact earning, possibly zero |
| `currency` | code | Yes | Currency at settlement |
| `pricing_policy_id` | ID | Yes if billable | Applied policy |
| `rate_snapshot_id` | ID | Yes if billable | Immutable rate/rule snapshot |
| `calculation_version` | string | Yes | Algorithm/policy version |
| `calculated_at` | UTC timestamp | Yes | Calculation time |
| `posted_at` | UTC timestamp | No | Ledger posting |
| `reversal_reference_id` | nullable ID | No | Compensating settlement |
| `idempotency_key` | bounded opaque value | Yes | Prevent duplicate settlement |
| `reason_code` | controlled code | Yes | Normal, no-answer, failed, refund, etc. |

**Invariants:** One call has one primary settlement. Any change after posting
creates a linked reversal/compensating transaction. Amounts are not calculated
from client-reported duration.

---

## 11. Pricing, wallet, purchase, ledger, and payout entities

### 11.1 `PricingPolicy`

**Purpose:** Versioned business rules for prices, billable units, host rates,
fees, limits, and settlement timing.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Policy ID |
| `version` | human-readable version | Yes | Immutable once active |
| `status` | enum | Yes | `draft`, `approved`, `active`, `retired` |
| `currency` | code | Yes | E.g. approved currency code |
| `user_rate_minor` | integer | Yes if calls bill | Draft planning value currently 1,500 paise/minute |
| `host_rate_minor` | integer | Yes if host earns | Draft planning value currently 600 paise/minute |
| `billing_unit` | enum | Yes | `second`, `thirty_seconds`, `minute`, future approved unit |
| `rounding_rule` | enum | Yes | Explicitly approved rounding behavior |
| `billing_start_rule` | enum | Yes | Server-confirmed event |
| `billing_stop_rule` | enum | Yes | End/disconnect/grace rule |
| `reconnect_grace_ms` | integer | Yes | May be zero; must be approved |
| `maximum_call_duration_ms` | integer | Yes | Spending/safety limit |
| `minimum_balance_minor` | integer | Yes | Low-balance/stop threshold |
| `refund_rule_version` | string | Yes | Linked refund policy |
| `host_earning_release_rule` | string | Yes | Pending-to-available policy |
| `approved_by` | actor ID | No until approved | Product/finance/legal review |
| `approved_at` | UTC timestamp | No | Approval time |
| `effective_at` | UTC timestamp | No | Activation time |
| `retired_at` | UTC timestamp | No | Retirement |
| `created_at` | UTC timestamp | Yes | Creation |

**Invariants:** Active policies are immutable. A call settlement stores the
policy/rate snapshot used; changing the active policy cannot rewrite history.

The current ₹15/₹6 figures are planning assumptions only and must not be
treated as approved production values until the policy is reviewed.

### 11.2 `RateSnapshot`

**Purpose:** Immutable call-specific copy of all rate inputs required to explain
and reproduce a settlement.

**Fields:** `id`, `pricing_policy_id`, policy version, currency, user rate,
host rate, billing unit, rounding rule, reconnect rule, fee/tax references,
captured_at, captured_by/system source.

**Invariants:** A snapshot cannot be edited or deleted while referenced by a
settlement, ledger transaction, refund, host earning, or dispute.

### 11.3 `LedgerAccount`

**Purpose:** Double-entry account for a user wallet, host payable balance,
platform revenue, provider clearing, refund reserve, tax/fee bucket, or suspense
account.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Ledger account ID |
| `owner_account_id` | nullable account ID | No | User/host-owned account; platform buckets are null or service-owned |
| `account_type` | enum | Yes | `user_wallet`, `host_payable`, `platform_revenue`, `provider_clearing`, `refund_reserve`, `tax_payable`, `fee`, `suspense` |
| `currency` | code | Yes | One currency per ledger account |
| `status` | enum | Yes | `active`, `frozen`, `closed` |
| `created_at` | UTC timestamp | Yes | Creation |
| `closed_at` | UTC timestamp | No | Closure |

**Invariants:** A ledger account cannot be posted to after closure. A frozen
account requires the documented hold/review behavior. User-facing balance is a
projection, not a mutable source row.

### 11.4 `LedgerTransaction`

**Purpose:** Atomic business transaction grouping balanced ledger entries.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Transaction ID |
| `transaction_type` | enum | Yes | `purchase`, `call_charge`, `host_earning`, `refund`, `chargeback`, `payout`, `adjustment`, `reward`, `gift` |
| `source_type` | controlled value | Yes | Call, purchase, payout, case, etc. |
| `source_id` | opaque ID | Yes | Source aggregate |
| `status` | enum | Yes | `pending`, `posted`, `reversed`, `void`, `disputed` |
| `currency` | code | Yes | All entries must match |
| `total_minor` | integer | Yes | Total movement, not a replacement for entries |
| `policy_version` | string | No | Applied business policy |
| `idempotency_key` | bounded opaque value | Yes | Unique source effect |
| `created_at` | UTC timestamp | Yes | Creation |
| `posted_at` | UTC timestamp | No | Ledger post |
| `reversal_of_id` | nullable transaction ID | No | Compensating transaction link |
| `created_by` | actor/service ID | Yes | Actor/source |

**Invariants:**

- A posted transaction has balanced entries according to the selected ledger
  convention.
- A source effect maps to at most one posted transaction for one idempotency
  key.
- Posted transactions are immutable.
- A reversal references the original and cannot exceed the eligible amount.
- `total_minor` is derived/checked against entries; clients cannot set it as
  financial truth.

### 11.5 `LedgerEntry`

**Purpose:** One debit/credit line within a `LedgerTransaction`.

**Fields:** `id`, `ledger_transaction_id`, `ledger_account_id`, `direction`
(`debit`, `credit`), `amount_minor`, `currency`, `sequence`, `created_at`.

**Invariants:** Amount is a non-negative integer; currency matches parent and
account; the transaction's debits and credits balance; entries are append-only.

### 11.6 `WalletAccount`

**Purpose:** User-facing projection of spendable virtual balance or approved
credit entitlement.

**Fields:** `id`, `owner_account_id`, `ledger_account_id`, `currency`,
`available_minor_projection`, `held_minor_projection`, `last_ledger_sequence`,
`projection_version`, `status`, `updated_at`.

**Rules:** The projection may be rebuilt from posted ledger entries. A client
cannot write it. If projection and ledger disagree, freeze risky value movement
and enqueue reconciliation rather than trusting either display blindly.

### 11.7 `Purchase`

**Purpose:** Tracks a store or approved payment-provider purchase from initiation
through verification and fulfillment.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Internal purchase ID |
| `buyer_account_id` | account ID | Yes | Buyer |
| `provider_name` | adapter ID | Yes | Store/payment provider |
| `provider_product_id` | protected/bounded value | Yes | Approved product catalog reference |
| `provider_purchase_id` | opaque provider ID | Yes | Deduplication/reconciliation |
| `provider_event_id` | opaque ID | No | Event reference |
| `status` | enum | Yes | `initiated`, `pending`, `verified`, `fulfilled`, `canceled`, `refunded`, `revoked`, `rejected`, `disputed` |
| `currency` | code | Yes | Purchase currency |
| `gross_amount_minor` | integer | No | Verified amount if available |
| `entitlement_id` | nullable ID | No | Granted entitlement |
| `receipt_reference` | protected reference | No | Store receipt storage reference; not raw in logs |
| `verified_at` | UTC timestamp | No | Verification |
| `fulfilled_at` | UTC timestamp | No | Entitlement/ledger fulfillment |
| `created_at` | UTC timestamp | Yes | Initiation |
| `updated_at` | UTC timestamp | Yes | State change |
| `idempotency_key` | bounded value | Yes | Client/backend operation key |

**Invariants:** A provider purchase is verified before granting value. Replayed
provider events return the existing result. Refund/revocation creates a
compensating entitlement/ledger action according to policy.

### 11.8 `Entitlement`

**Purpose:** Records a server-granted right to credits, tickets, subscription
features, or other approved product capability.

**Fields:** `id`, `owner_account_id`, `entitlement_type`, `source_type`,
`source_id`, `quantity_granted`, `quantity_consumed`, `currency` nullable,
`status` (`pending`, `active`, `exhausted`, `expired`, `revoked`, `refunded`),
`starts_at`, `expires_at`, `policy_version`, `created_at`, `updated_at`.

**Invariants:** Quantity consumed cannot exceed quantity granted. Grants and
consumption use idempotency keys. An entitlement cannot be activated by a
client-only purchase callback.

### 11.9 `GiftDefinition`

**Purpose:** Product-owned catalog item for optional virtual gifts.

**Fields:** `id`, `slug`, `display_name_key`, `asset_reference`,
`price_minor`, `currency`, `status`, `policy_version`, `sort_order`, `created_at`,
`retired_at`.

Gift definitions are independent product assets and copy. They are not copied
from the analyzed artifact.

### 11.10 `GiftTransfer`

**Purpose:** Records a user-to-user virtual gift spend and recipient display.

**Fields:** `id`, `sender_account_id`, `recipient_account_id`,
`gift_definition_id`, `conversation_id` nullable, `message_id` nullable,
`quantity`, `unit_price_minor`, `currency`, `status` (`requested`, `posted`,
`failed`, `reversed`, `refunded`), `ledger_transaction_id`, `idempotency_key`,
`created_at`, `posted_at`.

**Invariants:** Sender has sufficient server-confirmed entitlement; sender and
recipient are eligible; one idempotency key creates one transfer; a reversal is
linked to the original transaction.

### 11.11 `HostEarning`

**Purpose:** Host-side claim resulting from a settled eligible call or approved
business event.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Earning ID |
| `host_account_id` | account ID | Yes | Approved host |
| `source_type` | enum | Yes | `call_settlement`, approved future source |
| `source_id` | opaque ID | Yes | Source settlement |
| `amount_minor` | integer | Yes | Gross host amount |
| `currency` | code | Yes | Currency |
| `status` | enum | Yes | `pending`, `available`, `held`, `paid`, `reversed`, `disputed` |
| `policy_version` | string | Yes | Applied earning policy |
| `ledger_transaction_id` | ID | Yes after posting | Financial link |
| `available_at` | UTC timestamp | No | Release time |
| `hold_reason_code` | safe code | No | Fraud/refund/support hold |
| `reversed_by_id` | nullable earning ID | No | Compensating relationship |
| `created_at` | UTC timestamp | Yes | Creation |
| `updated_at` | UTC timestamp | Yes | State change |

**Invariants:** Pending/held earnings cannot be withdrawn. Reversal and dispute
states preserve original history. Host status, verification, geography, tax,
and fraud eligibility are checked before `available`.

### 11.12 `EarningHold`

**Purpose:** Documents why an earning is held and what event may release it.

**Fields:** `id`, `host_earning_id`, `hold_type` (`refund_window`, `fraud_review`,
`identity_review`, `payout_issue`, `support_dispute`, `legal_hold`), `status`,
`reason_code`, `created_at`, `released_at`, `released_by`, `notes_reference`.

Sensitive case notes must live in the controlled case system, not a general
host-facing row.

### 11.13 `PayoutProfile`

**Purpose:** Verified host payout destination and eligibility state.

**Fields:** `id`, `host_account_id`, `provider_name`, `provider_destination_ref`,
`verification_state`, `eligibility_state`, `currency`, `country_code`,
`minimum_payout_minor`, `created_at`, `updated_at`, `revoked_at`.

Do not store raw bank/card credentials or identity documents in this domain row.
Use the approved payout/identity provider and retain only safe references.

### 11.14 `Payout`

**Purpose:** Idempotent request to move available host earnings to an approved
payout destination.

**Fields:** `id`, `host_account_id`, `payout_profile_id`, `amount_minor`,
`currency`, `status` (`requested`, `approved`, `submitted`, `paid`, `failed`,
`held`, `reversed`, `disputed`, `canceled`), `provider_name`,
`provider_payout_id`, `idempotency_key`, `approved_by`, `submitted_at`,
`paid_at`, `failure_code`, `created_at`, `updated_at`.

**Invariants:** Only available earnings can be reserved. Duplicate requests do
not reserve or pay twice. Payout state is reconciled with the provider and
cannot be marked paid solely by the client.

### 11.15 `RefundCase`

**Purpose:** Tracks an approved refund or chargeback response without editing
the original purchase or ledger transaction.

**Fields:** `id`, `requester_account_id` nullable, `source_type`, `source_id`,
`reason_code`, `status` (`requested`, `reviewing`, `approved`, `rejected`,
`submitted`, `completed`, `failed`), `amount_minor`, `currency`,
`provider_ref`, `compensating_transaction_id`, `created_at`, `updated_at`,
`decided_by`.

**Invariants:** Refund amount cannot exceed eligible original value. Refunds may
reverse user entitlements and host earnings according to documented policy.

---

## 12. Safety, moderation, support, and operations entities

### 12.1 `SafetyCase`

**Purpose:** Private report or safety escalation concerning an account, profile,
message, media object, call, or other approved target.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Case reference shown safely to reporter |
| `reporter_account_id` | account ID | Yes unless system escalation | Must remain private from target by default |
| `target_type` | enum | Yes | `account`, `profile`, `message`, `media`, `call`, `conversation`, `payout`, `other_approved` |
| `target_id` | opaque ID | Yes | Resource reference, re-authorized on access |
| `reason_code` | controlled enum | Yes | Versioned independently written reason |
| `description` | sanitized bounded text | No | Reporter explanation; restricted access |
| `status` | enum | Yes | `submitted`, `triaged`, `reviewing`, `actioned`, `resolved`, `dismissed`, `appealed`, `closed` |
| `priority` | enum | Yes | `routine`, `urgent`, `emergency` |
| `policy_version` | string | Yes | Policy applied at intake |
| `assigned_queue` | controlled value | Yes | Moderation/support queue |
| `assigned_operator_id` | nullable account ID | No | Least-privilege assignment |
| `created_at` | UTC timestamp | Yes | Submission |
| `updated_at` | UTC timestamp | Yes | State change |
| `resolved_at` | UTC timestamp | No | Resolution |
| `reporter_visible_status` | enum | Yes | Safe subset, not confidential action detail |

**Invariants:**

- Reporter identity is not exposed to the target through ordinary APIs,
  notifications, or case references.
- Target existence and private case state are not disclosed to unauthorized
  users.
- Duplicate reports can be linked/deduplicated without discarding risk signals.
- Every action is linked to the case and audit trail.
- Emergency reports have a documented escalation path and owner.

**State machine:**

```text
submitted -> triaged -> reviewing -> actioned -> resolved -> closed
                         |-> dismissed -> closed
                         |-> emergency_escalation -> actioned/resolved
resolved -> appealed -> reviewing
```

### 12.2 `SafetyEvidence`

**Purpose:** Restricted evidence attached to a safety case.

**Fields:** `id`, `safety_case_id`, `evidence_type` (`message_snapshot`,
`media_reference`, `call_metadata`, `user_text`, `system_signal`),
`source_id` nullable, `media_object_id` nullable, `captured_at`,
`retention_class`, `access_level`, `redaction_state`, `created_at`,
`purged_at`.

**Rules:** Evidence access is case-scoped and audited. Do not copy full private
messages or media into multiple systems when a safe reference is sufficient.
Evidence must be retained only as long as the approved safety/legal policy
requires.

### 12.3 `ModerationAction`

**Purpose:** Immutable or append-only record of an enforcement, review, warning,
restriction, or restoration action.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Action ID |
| `safety_case_id` | case ID | Yes | Reason/context |
| `target_account_id` | account ID | No | Account affected, if applicable |
| `target_type` / `target_id` | resource reference | Yes | Affected resource |
| `action_type` | enum | Yes | `warning`, `content_hold`, `content_remove`, `mute`, `block`, `restrict`, `suspend`, `ban`, `restore`, `no_action` |
| `duration_ms` | integer/nullable | No | Temporary restriction |
| `reason_code` | controlled | Yes | Policy reason |
| `policy_version` | string | Yes | Applied rule |
| `actor_account_id` | account/service ID | Yes | Moderator/system |
| `effective_at` | UTC timestamp | Yes | Start |
| `expires_at` | UTC timestamp | No | End |
| `reversed_at` | UTC timestamp | No | If restored/reversed |
| `created_at` | UTC timestamp | Yes | Audit time |

**Invariants:** A moderator cannot silently overwrite a prior action. Reversal
is a new action linked to the original. Scope must be explicit so an account
restriction affects only approved features.

### 12.4 `Appeal`

**Purpose:** User request for review of an eligible moderation or support action.

**Fields:** `id`, `safety_case_id` nullable, `target_action_id`,
`appellant_account_id`, `reason`, `status` (`submitted`, `reviewing`,
`upheld`, `modified`, `reversed`, `closed`), `assigned_operator_id`,
`created_at`, `updated_at`, `decided_at`, `decision_reason_code`.

**Invariants:** The original decision remains in history. Appeal access is
restricted and does not reveal reporter identity or unrelated evidence.

### 12.5 `SupportCase`

**Purpose:** User-facing support workflow for account, purchase, refund, call,
host-earning, or safety questions.

**Fields:** `id`, `requester_account_id`, `category`, `source_type`, `source_id`,
`status` (`open`, `waiting_for_user`, `waiting_internal`, `resolved`, `closed`),
`priority`, `assigned_team`, `assigned_operator_id`, `created_at`, `updated_at`,
`resolved_at`, `retention_class`.

Support cases should reference safe domain records rather than copying payment
payloads, private messages, or identity documents into free-text notes.

### 12.6 `SupportMessage`

**Purpose:** A message in a support case.

**Fields:** `id`, `support_case_id`, `sender_type` (`user`, `operator`,
`system`), `sender_account_id` nullable, `body_text`, `visibility`, `created_at`,
`redacted_at`.

**Invariants:** Only case participants and authorized operators can read it.
Operator messages are audited. Sensitive payment/identity data should be
represented by controlled references rather than pasted into text.

### 12.7 `AuditEvent`

**Purpose:** Append-only evidence for sensitive user, operator, service, and
provider actions.

**Fields:**

| Field | Type/shape | Required | Notes |
| --- | --- | --- | --- |
| `id` | opaque ID | Yes | Audit ID |
| `actor_account_id` | nullable account/service ID | Yes | Null only for verified external/system event |
| `actor_role` | controlled value | Yes | Capability used |
| `action` | controlled value | Yes | `profile_updated`, `role_granted`, `refund_approved`, etc. |
| `target_type` / `target_id` | resource reference | Yes | Affected resource |
| `reason_code` | controlled code | Yes for privileged action | Required explanation |
| `request_id` | correlation ID | No | Link to API/operation |
| `case_id` | safety/support case ID | No | Case context |
| `before_summary` | redacted bounded summary | No | Never raw secrets/private payloads |
| `after_summary` | redacted bounded summary | No | Safe result summary |
| `source` | enum | Yes | `api`, `worker`, `provider`, `operator`, `migration` |
| `created_at` | UTC timestamp | Yes | Immutable event time |

**Invariants:** Audit events are append-only and queryable by authorized
operators. They must not become a second unbounded copy of private content.

### 12.8 `IdempotencyRecord`

**Purpose:** Stores the result of an effectful command so retries return the same
business outcome.

**Fields:** `id`, `actor_account_id` nullable, `operation_type`,
`idempotency_key`, `request_hash`, `resource_type`, `resource_id`,
`result_code`, `response_reference` or safe response summary, `status`
(`in_progress`, `completed`, `failed_retryable`, `expired`), `created_at`,
`expires_at`.

**Invariants:** The same actor/operation/key cannot be reused with a different
request hash. The record never stores secrets or full sensitive responses.

### 12.9 `WebhookEvent`

**Purpose:** Verified envelope for a provider callback and its processing result.

**Fields:** `id`, `provider_name`, `provider_event_id`, `event_type`,
`signature_status`, `schema_status`, `processing_status` (`received`,
`verified`, `ignored_duplicate`, `queued`, `processed`, `failed_retryable`,
`dead_lettered`), `safe_payload_hash`, `received_at`, `processed_at`,
`failure_code`, `attempt_count`.

**Invariants:** Provider event IDs are unique per provider. Signature failure is
not treated as a valid business event. Raw payload retention is minimized and
protected.

### 12.10 `OutboxEvent`

**Purpose:** Transactionally records an internal event that must be delivered to
another module, queue, notification system, or analytics sink.

**Fields:** `id`, `event_type`, `aggregate_type`, `aggregate_id`, `event_version`,
`safe_payload`, `status` (`pending`, `published`, `failed`, `dead_lettered`),
`attempt_count`, `available_at`, `published_at`, `created_at`.

**Invariants:** Outbox creation occurs in the same transaction as the state
change it describes. Publication is idempotent. Payload contains only fields
approved for the destination.

### 12.11 `JobRun`

**Purpose:** Tracks a retryable background job execution.

**Fields:** `id`, `job_type`, `deduplication_key`, `status` (`queued`, `running`,
`succeeded`, `retryable_failure`, `dead_lettered`, `canceled`), `attempt_count`,
`available_at`, `started_at`, `finished_at`, `last_error_code`, `safe_context`,
`created_at`.

**Invariants:** A job cannot claim a business effect without idempotency. Error
context is safe and bounded; stack traces belong in protected diagnostics, not
user-visible domain data.

---

## 13. Relationship map and cardinality rules

The following cardinalities are proposed for the first production model:

```text
Account 1 ---- 0..1 Profile
Account 1 ---- 0..* AccountIdentity
Account 1 ---- 0..* Session
Account 1 ---- 0..* DeviceRegistration
Account 1 ---- 0..* RoleAssignment
Account 1 ---- 0..* ConsentRecord

Profile 1 ---- 0..* ProfileMedia ---- 1 MediaObject
Profile 1 ---- 0..* ProfileTag
Host Account 1 ---- 0..1 Availability

Account 1 ---- 0..* Relationship (as actor)
Account 1 ---- 0..* Relationship (as target)
Account 1 ---- 0..* MatchAttempt

Conversation 1 ---- 2..* ConversationParticipant
Conversation 1 ---- 0..* Message
Message 1 ---- 0..* MessageAttachment ---- 1 MediaObject

CallSession 1 ---- 2 CallParticipant
CallSession 1 ---- 0..* CallEvent
CallSession 1 ---- 0..* RtcGrantAudit
CallSession 1 ---- 0..* CallMeterSample
CallSession 1 ---- 0..1 CallSettlement

Account 1 ---- 0..* WalletAccount
LedgerTransaction 1 ---- 2..* LedgerEntry
Purchase 1 ---- 0..1 Entitlement
HostEarning 1 ---- 0..* EarningHold
HostEarning 0..* ---- 0..1 Payout

SafetyCase 1 ---- 0..* SafetyEvidence
SafetyCase 1 ---- 0..* ModerationAction
SafetyCase 1 ---- 0..* Appeal
SupportCase 1 ---- 0..* SupportMessage
```

### Cardinality constraints

- A direct conversation has exactly two active participants.
- A one-to-one call has exactly two participants and exactly one approved host
  role when the call is paid to a host.
- One call session has at most one primary settlement.
- One provider purchase reference maps to at most one internal purchase for an
  environment/provider combination.
- One active profile exists per account in the first release.
- One active primary avatar exists per profile.
- One active relationship of a given kind exists for an actor-target pair.
- A posted ledger transaction has at least two entries and balances.
- A host earning has one source settlement or approved source event.
- A payout cannot reserve the same earning amount twice.

---

## 14. State dictionaries and transition rules

The application should use controlled enumerations or lookup tables rather than
free-form strings. The following values are the starting contract.

### 14.1 Account states

| State | Meaning | Allowed actions |
| --- | --- | --- |
| `pending_verification` | Identity/account setup incomplete | Verification, safe recovery, support |
| `active` | Normal account | Approved product actions |
| `restricted` | Some features limited | Read safe data, support, permitted actions |
| `suspended` | Temporarily or indefinitely blocked | Recovery/support only unless policy says otherwise |
| `deletion_requested` | Deletion confirmed, cleanup pending | No new business effects |
| `deleting` | Cleanup in progress | No normal access |
| `deleted` | User-facing account removed/anonymized | Retained references only |

### 14.2 Profile states

| State | Discovery | Direct access | Owner edit |
| --- | --- | --- | --- |
| `private` | No | Owner/authorized support | Yes |
| `discoverable` | Yes if eligible | Yes | Yes |
| `unlisted` | No | Authorized deep link only | Yes |
| `hidden` | No | Safe unavailable state to others | Owner/support policy |
| `suspended` | No | Safe unavailable state | Restricted/support |
| `deleted` | No | No private data | No |

### 14.3 Media states

```text
requested -> uploading -> uploaded -> scanning -> ready
                                  |-> failed -> retry/expired
scanning -> held | rejected
ready -> removed -> purged
```

Only `ready` and approved media can be attached to public profiles or messages.

### 14.4 Relationship states

| Kind | Typical states | Notes |
| --- | --- | --- |
| Follow/favorite | `active`, `removed` | Idempotent add/remove |
| Block | `active`, `removed` | Block precedence is policy-controlled |
| Request | `pending`, `accepted`, `rejected`, `expired`, `removed` | Only if a request relationship is approved |
| Mute | `active`, `removed`, `expired` | Notification/content preference, not necessarily block |

### 14.5 Match states

```text
requested -> searching -> candidate_found -> accepted | skipped
requested -> canceled | expired | failed | no_result
candidate_found -> candidate_unavailable -> no_result
```

Entitlement consumption must be linked to the exact transition that policy
defines as chargeable.

### 14.6 Conversation states

```text
active -> restricted -> archived -> closed -> deleted
active -> blocked
```

The state is not sufficient to determine participant access; account status,
blocks, retention, and case authorization also apply.

### 14.7 Message states

```text
submitting -> accepted -> delivered -> read
submitting -> failed -> retry
accepted -> held -> approved | removed
accepted -> expired
```

### 14.8 Call states

See `CallSession`; no client-only transition is final. Provider events are
verified and reconciled with application state.

### 14.9 Purchase states

```text
initiated -> pending -> verified -> fulfilled
pending -> rejected | canceled
fulfilled -> refunded | revoked | disputed
```

### 14.10 Entitlement states

```text
pending -> active -> exhausted
active -> expired | revoked | refunded
```

### 14.11 Ledger transaction states

```text
pending -> posted
pending -> failed | void
posted -> reversed | disputed
```

No ordinary update may change the financial meaning of a `posted` transaction.

### 14.12 Host earning states

```text
pending -> available -> paid
pending -> held -> available | reversed | disputed
available -> held | paid | reversed | disputed
paid -> reversed | disputed only through documented compensating workflow
```

### 14.13 Payout states

```text
requested -> approved -> submitted -> paid
requested -> canceled | held | failed
submitted -> failed | held | paid
paid -> reversed | disputed only through provider/reconciliation workflow
```

### 14.14 Safety case states

```text
submitted -> triaged -> reviewing -> actioned -> resolved -> closed
reviewing -> dismissed -> closed
resolved -> appealed -> reviewing
```

---

## 15. Ownership and authorization matrix by entity

This table is a domain-level default. The API and database policies may be
stricter. UI visibility never replaces backend authorization.

| Entity | User/viewer | Host | Moderator | Support/finance | System/service |
| --- | --- | --- | --- | --- | --- |
| `Account` own | Read/edit allowed fields | Same | Case-authorized only | Case-authorized only | Lifecycle service |
| `AccountIdentity` | No raw provider data | No raw provider data | No ordinary access | Case-authorized | Auth service |
| `Session` | Own revoke/list | Own revoke/list | Security case only | Security case only | Auth service |
| `RoleAssignment` | No | No | Approved role scope | Approved role scope | Role/admin service |
| `ConsentRecord` | Own read/withdraw where allowed | Own read/withdraw | Case-authorized | Case-authorized | Consent service |
| `Profile` | Public eligible projection; own edit | Own edit | Case scope | Support scope | Profile service |
| `MediaObject` | Own or authorized reference | Own or authorized reference | Case evidence | Case evidence | Storage/scanner service |
| `Availability` | Public safe projection | Own edit | Case/operations scope | No | Availability service |
| `Relationship` | Own actor state | Own actor state | No ordinary access | No | Relationship service |
| `MatchAttempt` | Own full history | Own participation only | Case scope | Support scope | Match service |
| `Conversation` | Active participants | Active participants | Case-authorized evidence | Support case scope | Messaging service |
| `Message` | Participants per policy | Participants per policy | Case evidence | Support case scope | Messaging service |
| `CallSession` | Own participant call | Own participant call | Safety case scope | Support/finance case scope | Call service |
| `CallEvent` | Safe history projection | Safe history projection | Case scope | Reconciliation scope | Call/provider service |
| `CallSettlement` | Own charge summary | Own earning summary | No ordinary access | Finance/support scope | Economy service |
| `WalletAccount` | Own projection | Own approved wallet | No | Finance case scope | Economy service |
| `Purchase` | Own safe history | Own if buyer | No | Finance scope | Billing adapter/service |
| `LedgerTransaction/Entry` | No raw ledger | No raw ledger | No | Approved finance scope | Economy service |
| `HostEarning` | No | Own summary | No | Finance/payout scope | Earnings service |
| `PayoutProfile` | No | Own status, not raw destination | No | Payout scope | Payout provider |
| `Payout` | No | Own status | No | Payout/finance scope | Payout service |
| `SafetyCase` | Own submission/status | Own submission/status | Assigned scope | Support scope | Safety service |
| `SafetyEvidence` | No | No | Assigned scope | Case scope | Safety service |
| `ModerationAction` | Safe notification only | Safe notification only | Assigned scope | No | Moderation service |
| `Appeal` | Own appeal/status | Own appeal/status | Assigned scope | Support scope | Safety service |
| `SupportCase/Message` | Own case | Own case | Safety-linked scope | Assigned support scope | Support service |
| `Notification` | Own notifications | Own notifications | Assigned operations only | Assigned operations only | Notification service |
| `AuditEvent` | No | No | Assigned audit scope | Assigned audit scope | Audit service |
| `WebhookEvent/JobRun` | No | No | No | Reconciliation scope | Integration service |

### Authorization implementation rules

1. Check account status before entity-specific policy.
2. Check role/capability before operator access.
3. Check resource ownership or participant membership.
4. Check block, suspension, deletion, region, age, and eligibility policy.
5. Check current lifecycle state and concurrency version.
6. Record an audit event for sensitive or privileged actions.

---

## 16. Privacy classification and retention matrix

Exact retention periods require approval in `docs/SECURITY_AND_PRIVACY.md` and
legal review. This matrix defines ownership and decision categories without
inventing a legal period.

| Data category | Examples | Classification | Owner/access | Deletion behavior |
| --- | --- | --- | --- | --- |
| Authentication | Provider subject, email, sessions | Private/sensitive | Account/auth service | Revoke sessions; delete/anonymize under policy |
| Public profile | Display name, bio, approved media, tags | Public projection | Account owner; eligible viewers | Hide/delete profile; retain safety reference if needed |
| Availability | Online/busy/paused state | Private-derived/public projection | Host and eligible viewers | Expire stale state; do not retain unnecessary history |
| Relationships | Follow/favorite/block | Private/relationship | Actor/target policy | Preserve block/safety evidence as required |
| Messages | Text, emoji, attachments | Private | Participants; case-authorized moderators | Retention/deletion policy; preserve limited safety evidence |
| Call metadata | Participants, timestamps, states | Private/sensitive | Participants; support/finance/safety case | Retain for billing/safety/reconciliation policy |
| Call media | Audio/video/recording if approved | Sensitive | Explicitly authorized participants/operators | Disabled by default; strict consent/retention |
| Payment/store | Purchase references, receipts, refunds | Sensitive/financial | Finance/support service | Retain for reconciliation/tax/legal policy; redact payloads |
| Ledger | Entries, settlement, payout records | Financial | Finance/audit only | Append-only retention; compensating entries |
| Host verification | Identity/eligibility references | Sensitive | Verification/payout operators | Minimum retention; provider reference preferred |
| Safety | Reports, evidence, moderation actions | Sensitive | Assigned safety/support roles | Retain under safety/legal policy; reporter privacy |
| Notifications | Event type, delivery state, deep-link intent | Private | Recipient/notification service | Expire after purpose; minimize payload |
| Analytics | Event category and timing | Pseudonymous | Analytics operators | Aggregated/retained according to consent/policy |
| Audit | Operator/service actions | Sensitive | Security/audit operators | Append-only retention for accountability |
| Support | Tickets and messages | Private/sensitive | Requester/assigned support | Retain under support/legal policy |

### Retention invariants

- A user deletion request does not erase a posted financial transaction.
- A safety case cannot be exposed to the reported account.
- Private media access expires independently of database row retention.
- Analytics cannot become a hidden copy of message or payment content.
- Purging one user's profile cannot orphan a ledger or audit record required for
  reconciliation; use anonymized references where appropriate.

---

## 17. Database constraints and index plan

This is a logical index plan. The database owner must tune it using real query
plans and data volume. Every index must have a measured query or constraint
reason.

### 17.1 Required uniqueness constraints

- `AccountIdentity(provider, provider_subject_hash)` for active identity links.
- `Profile(account_id)` for one active profile per account.
- `Relationship(actor_account_id, target_account_id, kind)` for active state.
- `ConversationParticipant(conversation_id, account_id)` for membership.
- `Message(conversation_id, sender_account_id, client_message_id)` for message
  idempotency.
- `CallSession(idempotency_key, requester_account_id)` for call creation.
- `CallSettlement(call_session_id)` for one primary settlement.
- `PricingPolicy(version)` and active policy constraints by product/currency.
- `LedgerTransaction(idempotency_key, transaction_type)` within an approved
  source/environment scope.
- `LedgerEntry(ledger_transaction_id, sequence)` for deterministic ordering.
- `Purchase(provider_name, provider_purchase_id)` for provider deduplication.
- `WebhookEvent(provider_name, provider_event_id)` for callback deduplication.
- `IdempotencyRecord(actor, operation_type, idempotency_key)` within retention.

### 17.2 Required check constraints

- Account IDs in actor/target relationships must differ.
- Call requester, recipient, and host IDs must satisfy the approved role rules.
- Monetary amounts are non-negative integers with an approved currency.
- Message body length and attachment count remain within configured limits.
- End timestamps cannot precede start timestamps.
- Expiry timestamps cannot precede creation timestamps.
- Entitlement consumption cannot exceed granted quantity.
- Payout amount cannot exceed reserved/available earning amount.
- Ledger entries belong to the same currency as their transaction/account.
- A deleted/suspended record cannot be exposed through an active public projection.

### 17.3 Query/index groups

| Query group | Suggested index fields |
| --- | --- |
| Account status/deletion | `(status, created_at)`, deletion workflow status |
| Profile discovery | `(visibility, status, updated_at)`, approved filter fields where lawful |
| Availability | `(host_account_id, mode, expires_at)`, `(mode, expires_at)` |
| Relationships | `(actor_account_id, kind, state)`, `(target_account_id, kind, state)` |
| Match history | `(requester_account_id, created_at desc)`, `(status, expires_at)` |
| Conversations | participant membership, `(conversation_id, last_message_at)` |
| Messages | `(conversation_id, server_sequence)`, `(conversation_id, created_at)` |
| Calls | `(requester_account_id, created_at desc)`, `(recipient_account_id, created_at desc)`, active-state index |
| Settlement | `(call_session_id)`, `(status, created_at)` |
| Purchases | buyer/status, provider reference, verification queue |
| Ledger | source reference, account/sequence, created_at, reconciliation status |
| Earnings/payouts | host/status/created_at, payout provider reference |
| Safety | queue/status/priority/created_at, assigned operator |
| Notifications | recipient/status/created_at, expiration |
| Jobs/webhooks | deduplication key, processing status, available_at |

### 17.4 Row-level security expectations

Where the chosen database supports row-level security, policies must cover at
least:

- account self-read/write fields;
- profile owner writes and public projection reads;
- relationship actor access;
- conversation participant reads/writes;
- message participant access;
- call participant access;
- wallet and purchase owner reads;
- host earning owner summary reads;
- safety reporter status reads and moderator case reads;
- support case requester/assigned-operator reads; and
- no direct client access to raw ledger, audit, webhook, job, or provider-secret
  tables.

Service-role access must not be used as a substitute for application
authorization in user-facing endpoints.

---

## 18. Domain commands and events

Commands are requests to change state. Events describe an accepted state change
and are safe, versioned integration boundaries. A command may be rejected;
events are emitted only for an accepted or intentionally recorded outcome.

### 18.1 Core commands

```text
CreateAccount
VerifyAccount
RevokeSession
AcceptConsent
RequestAccountDeletion
UpdateProfile
UploadProfileMedia
SetAvailability
ChangeRelationship
StartMatchAttempt
DecideMatch
CreateConversation
SendMessage
RetryMessage
RequestMessageAttachment
ReportTarget
BlockAccount
RequestCall
RespondToCall
IssueRtcGrant
RecordCallEvent
EndCall
SettleCall
StartPurchaseVerification
FulfillPurchase
ConsumeEntitlement
PostGiftTransfer
CreateRefundCase
ApplyCompensatingEntry
ReleaseHostEarning
RequestPayout
ReviewSafetyCase
ApplyModerationAction
SubmitAppeal
CreateSupportCase
CreateNotification
```

### 18.2 Core events

```text
AccountCreated
AccountStatusChanged
SessionRevoked
ConsentRecorded
ProfilePublished
ProfileHidden
MediaReady
MediaRemoved
AvailabilityChanged
RelationshipChanged
MatchAttemptChanged
ConversationCreated
MessageAccepted
MessageModerationChanged
MessageDeliveryChanged
CallStateChanged
RtcGrantIssued
CallSettlementPosted
PurchaseVerified
EntitlementGranted
EntitlementConsumed
LedgerTransactionPosted
LedgerTransactionReversed
HostEarningStateChanged
PayoutStateChanged
SafetyCaseSubmitted
ModerationActionApplied
AppealStateChanged
NotificationCreated
AccountDeletionProgressed
```

### 18.3 Event requirements

Each event includes:

```text
event_id
event_type
event_version
aggregate_type
aggregate_id
occurred_at_utc
source
correlation_id
causation_id (when available)
safe_payload
```

Events must not contain passwords, tokens, raw receipts, private message bodies,
identity documents, or unrestricted media URLs. Consumers must be idempotent and
must tolerate duplicate, delayed, and out-of-order delivery.

---

## 19. Read models and projections

The domain tables are not always the best shape for the mobile API. Build
privacy-filtered read models that can be rebuilt from authoritative records.

### 19.1 Public profile projection

Includes only approved fields:

- profile ID;
- display name and approved media references;
- bio/tags;
- broad region/language where consented;
- verification display state;
- availability freshness/state;
- relationship state for the requesting user;
- call eligibility and approved price explanation; and
- report/block action availability.

Excludes private email, DOB, provider identity, exact location, moderation
evidence, payout data, and hidden ranking features.

### 19.2 Conversation projection

Includes:

- conversation ID;
- authorized participant summary;
- last safe message preview or type;
- unread count;
- delivery/read state;
- restricted/blocked/deleted state; and
- latest activity timestamp.

It must be rebuilt or invalidated after block, deletion, moderation removal, or
participant status changes.

### 19.3 Call history projection

Includes:

- call ID and direction;
- safe participant summary;
- status and reason category;
- server-confirmed timestamps/duration;
- authorized charge/earning summary;
- support/report reference; and
- reconnect outcome.

It must not expose provider tokens, room secrets, unrelated participant data, or
raw RTC payloads.

### 19.4 Wallet/earnings projection

Includes:

- current server-confirmed balance or pending refresh state;
- available/held/pending buckets;
- currency;
- transaction category and date;
- user-safe explanation of pending/refund/reversal; and
- support/reconciliation status where useful.

The projection must show a safe unavailable state when ledger reconciliation is
in progress rather than guessing a balance.

### 19.5 Moderation queue projection

Includes only the evidence needed by the assigned role:

- case ID, priority, category, target type, and age;
- minimum context and safe references;
- assignment and SLA state;
- prior actions relevant to the case; and
- allowed action controls.

Reporter identity and unrelated private data remain restricted.

---

## 20. Invariants and consistency tests

These invariants should become automated unit, integration, database, and
reconciliation tests.

### 20.1 Identity and access

- Deleted or suspended accounts cannot create protected sessions.
- A user cannot read another user's private account, conversation, wallet,
  safety case, or payout data.
- Role changes are audited and take effect according to the role policy.
- A blocked relationship is applied consistently to discovery, matching,
  messaging, calls, and notifications.

### 20.2 Profiles and media

- Only the owner can edit their profile.
- Only ready/approved media can be published.
- An active profile cannot belong to a deleted account.
- A profile cannot have two active primary avatars.
- Signed media access expires and is re-authorized.

### 20.3 Messaging

- One client message idempotency key creates at most one message.
- Only conversation participants can create or read messages.
- Removed content does not reappear through stale read models.
- Notification failure does not roll back an accepted message.
- Message attachment media belongs to the authorized uploader/conversation.

### 20.4 Calls

- A call has exactly two approved participants in the first release.
- A user cannot create a call against a blocked/deleted/ineligible account.
- An idempotent call request creates at most one call session.
- Only valid state transitions are accepted.
- Provider tokens are scoped and never exposed as domain data.
- One call has at most one primary settlement.
- Client timers cannot determine final billable duration.

### 20.5 Economy

- Posted ledger transactions balance.
- Posted ledger transactions are immutable.
- A purchase cannot grant an entitlement twice.
- Entitlement consumption cannot exceed its grant.
- Refunds and chargebacks use compensating transactions.
- Host earnings cannot become available before policy conditions.
- Payouts cannot exceed available/reserved earnings.
- Replayed webhook events do not create duplicate value.

### 20.6 Safety and operations

- Reporter identity is not exposed to the target.
- Every moderation action has actor, target, reason, timestamp, and policy
  version.
- Operator access is limited by role and case scope.
- Account deletion is retryable and leaves documented retained records.
- Audit, webhook, and job records are append-only or state-transition audited.

---

## 21. Migration and implementation guidance

### 21.1 Migration rules

- Every schema change is a versioned migration owned by the service/database.
- Migrations are forward-compatible with the previous application during staged
  rollout where practical.
- Add nullable columns or new tables before requiring new writes.
- Backfill in bounded batches with progress and restart safety.
- Add constraints after existing data is validated or repaired.
- Do not drop financial, safety, or audit columns without an approved retention
  decision.
- Record lock duration, expected backfill size, rollback/forward-fix path, and
  monitoring in the migration notes.

### 21.2 Suggested migration sequence

1. Accounts, identities, sessions, roles, and consent.
2. Profiles, media metadata, tags, and availability.
3. Relationships, blocks, and discovery projections.
4. Conversations, participants, messages, and attachments.
5. Call sessions, participants, events, grants, and call history.
6. Pricing policy and rate snapshots in sandbox mode.
7. Wallet, ledger, purchases, entitlements, and reconciliation.
8. Host earnings, payout profiles, holds, and payout workflow.
9. Safety cases, evidence, moderation actions, appeals, and support.
10. Notifications, outbox, webhook, jobs, and audit events.

The existing `replica/schema.sql` is a small production-shaped Orbitra MVP
reference, not a complete migration for this domain model. It contains profiles,
live sessions, messages, follows, calls, audio rooms, and reports, but it must be
reviewed and expanded rather than treated as production-ready.

### 21.3 Local-first adapter mapping

Until the backend exists, the local repository may implement a subset of these
entities in memory or safe local storage:

| Domain entity | Local prototype behavior | Production replacement |
| --- | --- | --- |
| `Account/Profile` | Seeded local identity | Authenticated account/profile API |
| `Availability` | Seeded host availability | Server presence/availability service |
| `Relationship` | Local follow/favorite | Relationship API and database row |
| `Conversation/Message` | In-memory seeded thread | Authorized messaging service |
| `CallSession` | Simulated state machine | Call service plus RTC provider |
| `Wallet/Entitlement` | Clearly labelled mock values | Ledger-backed economy service |
| `SafetyCase` | Local acknowledgement | Moderation case system |
| `Notification` | Local simulated events | Notification/outbox worker |

The local adapter must use the same domain states where feasible so UI tests do
not accidentally encode production-incompatible behavior.

---

## 22. Open domain decisions

The following decisions remain open and must be resolved before the relevant
entities are considered final:

1. Long-term mobile stack and serialization strategy.
2. Authentication provider and exact account merge/recovery policy.
3. Host role approval, identity verification, age/geography restrictions, and
   legal relationship.
4. Profile fields, visibility, discovery ranking, and precise-location policy.
5. Conversation retention, editing/deletion, attachments, gifts, and translation.
6. Call participant roles, concurrency rules, recording, and media retention.
7. RTC provider and verified connected-state evidence.
8. Billing unit, ₹15/₹6 rate policy, reconnect grace, refunds, taxes, and fees.
9. Wallet currency, credit expiry, subscriptions, gifts, and rewards.
10. Host earning release, holds, payout minimums, reversals, and disputes.
11. Safety categories, moderation staffing, evidence retention, and appeals.
12. Analytics identity, consent, regional privacy, and data export.
13. Database, storage, cache, queue, and provider infrastructure.
14. RPO/RTO, restore testing, and operational ownership.

An implementation may use a clearly labelled draft enum or mock value while a
decision is pending, but must not present it as approved policy.

---

## 23. Domain-model acceptance checklist

Before using this model to create production migrations:

- [ ] Product requirements and architecture are approved or the task is clearly
  labelled prototype/sandbox.
- [ ] Every entity has an owner, access rule, lifecycle, and retention category.
- [ ] All state-changing commands have idempotency and retry behavior.
- [ ] Account, profile, relationship, conversation, message, call, and safety
  authorization tests are defined.
- [ ] Financial entities use integer minor units and append-only entries.
- [ ] Pricing and rate snapshots preserve historical settlement rules.
- [ ] Purchase, webhook, refund, chargeback, payout, and reconciliation flows
  have server-side tests.
- [ ] Call state, provider events, meter evidence, and settlement are separate.
- [ ] Blocked, deleted, suspended, and unavailable states are consistent across
  read models.
- [ ] Safety evidence and reporter identity are least-privilege protected.
- [ ] Account deletion and retention exceptions are documented.
- [ ] Migrations, indexes, constraints, RLS/policies, backup, and restore plans
  exist.
- [ ] Read models do not leak private fields, provider secrets, raw receipts,
  message bodies, or unrestricted media URLs.
- [ ] Open product decisions are recorded before enabling real money or host
  payouts.

This checklist is a design gate. It is not evidence that the current Orbitra
MVP or any provider integration satisfies the model.
