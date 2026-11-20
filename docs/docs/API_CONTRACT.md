# API Contract — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Engineering owner to be assigned  
**Last updated:** 2026-10-25  
**Source of truth for:** Public application API behavior, compatibility, and
server/client integration rules  
**Related documents:** `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/COST_MODEL.md`,
`docs/ADR/0001-technology-stack.md`,
`replica/schema.sql`

This document defines the proposed API for the independent product. It is not a
reconstruction of a target application's private API, endpoint names, payloads,
credentials, or backend behavior. The analyzed artifact supplied only bounded
static capability evidence; it did not provide a recoverable backend contract.

The contract is intentionally written before production endpoints are deployed.
Routes, fields, limits, provider adapters, and policies marked **Proposed** or
**Gated** require approval and executable tests before they become production
behavior.

---

## 1. Contract scope and decision labels

### 1.1 Decision labels

- **Required:** must be true for the stated release milestone.
- **Proposed:** an independent design choice awaiting product or engineering
  approval.
- **Gated:** documented for future use but disabled until its dependent policy,
  provider, legal, and test decisions are approved.
- **Deferred:** intentionally outside the current release contract.
- **Unknown:** not established; the implementation must not silently invent it.

### 1.2 API maturity by release stage

| Capability | Initial server-backed MVP | Production paid release | Deferred unless approved |
| --- | --- | --- | --- |
| Account/session context | Required | Required | — |
| Profile and profile media | Required | Required | — |
| Discovery and relationships | Required | Required | — |
| Matching | Proposed | Optional | — |
| Conversations and moderated messages | Required | Required | — |
| Reports, blocks, and notifications | Required | Required | — |
| One-to-one call lifecycle | Required with sandbox/demo provider | Required with approved RTC provider | — |
| RTC token issuance | Required for real calls | Required | — |
| Wallet and virtual credits | Gated/local seeded values | Required only after financial approval | — |
| Store purchases | Gated/sandbox only | Required only after receipt validation | — |
| Call settlement and host earnings | Gated/simulated | Required only after ledger and policy approval | — |
| Payouts | Deferred | Required only after legal, tax, and fraud approval | — |
| Public live rooms | Deferred | Separate product decision | Yes |
| Public audio rooms | Deferred | Separate product decision | Yes |
| Translation | Deferred | Separate privacy/cost/provider review | Yes |
| Recording, beauty effects, overlays, background calls | Deferred | Separate device and policy review | Yes |

### 1.3 Initial route families

The initial proposed route families are:

```text
/v1/me
/v1/sessions
/v1/profiles
/v1/media
/v1/discovery
/v1/relationships
/v1/matches
/v1/conversations
/v1/messages
/v1/calls
/v1/reports
/v1/notifications
/v1/devices
/v1/wallet                 # gated
/v1/products               # gated
/v1/purchases              # gated
/v1/entitlements           # gated
/v1/earnings               # gated
/v1/payouts                # gated
/v1/support
/v1/webhooks               # provider ingress, never a mobile-client API
```

The old local MVP notes contain `/v1/live` and audio-room concepts. Those routes
are not part of the initial one-to-one product contract unless public rooms are
approved separately. Existing local tables and seeded screens must not be
treated as proof that those APIs are production requirements.

---

## 2. Transport and representation conventions

### 2.1 Base URLs and environments

Each environment has a separate API origin, database, storage namespace,
authentication configuration, provider project, and secret set.

```text
Local:       http://127.0.0.1:<port>       # development only
Development: https://api-dev.example.invalid
Staging:     https://api-staging.example.invalid
Production:  https://api.example.invalid
```

The example domains are placeholders only. A local HTTP origin may be used for
development when isolated, but production and staging APIs must use HTTPS. The
mobile client must never receive service-role keys, RTC secrets, billing secrets,
signing keys, or private provider credentials.

### 2.2 HTTP and JSON rules

- Public API paths are versioned under `/v1`.
- Requests and responses use UTF-8 JSON unless an endpoint explicitly documents
  multipart or a provider upload URL.
- Request bodies use `Content-Type: application/json` when a body is present.
- Responses use `Content-Type: application/json` for application responses.
- Unknown request fields are rejected for security-sensitive commands and may be
  ignored only where the endpoint explicitly documents forward compatibility.
- JSON field names use `snake_case` in this draft. This is **Proposed** and must
  be confirmed before generating client models.
- `null` means a known empty value. An omitted field means the caller did not
  supply it or the field is not included in that response projection.
- Server timestamps are UTC RFC 3339 strings with an explicit timezone offset,
  normally `Z`.
- Monetary values are integer minor units plus an explicit currency code. No
  floating-point monetary values are accepted.
- Identifiers are opaque strings. Clients must not parse or order them.
- Boolean and enum values are case-sensitive and use the documented spelling.
- Provider-specific names, error messages, and payloads do not cross the public
  domain API boundary unless a separately approved field maps them safely.

### 2.3 Required and recommended headers

| Header | Requirement | Meaning |
| --- | --- | --- |
| `Authorization` | Required for protected routes | Bearer access token from the approved auth system |
| `Accept` | Recommended | Response media type requested by the client |
| `Content-Type` | Required with a JSON body | Request media type |
| `Idempotency-Key` | Required for effectful commands | Client-generated retry/deduplication key |
| `X-Request-Id` | Optional request input | Client correlation value; server returns a safe correlation ID |
| `If-Match` | Required where documented | Optimistic-concurrency version or entity tag |
| `X-Client-Version` | Recommended | App version for compatibility and diagnostics |
| `X-Platform` | Recommended | Coarse platform value such as `android`; not an identity signal |

The server must generate a request ID when the client does not supply one. The
request ID is safe to show to support staff and users. It must not contain an
access token, email address, advertising ID, device fingerprint, or message body.

The API must not require an advertising ID or stable hardware identifier for
authentication, authorization, account identity, fraud decisions, or API access.

### 2.4 Request size and validation defaults

The following are **Proposed defaults** until product-specific limits are
approved:

| Input | Proposed default |
| --- | ---: |
| JSON request body | 1 MiB |
| Display name | 1–60 Unicode characters |
| Biography | 0–500 Unicode characters |
| Message body | 1–2,000 Unicode characters |
| Report reason/details | 1–2,000 Unicode characters |
| Page size default | 20 records |
| Page size maximum | 100 records |
| Idempotency-key length | 16–128 ASCII characters |
| Cursor length | 1–4 KiB |
| Upload size | Endpoint and media-policy specific |

The server validates Unicode length, encoding, enum values, ownership, state,
authorization, and rate limits. A client-side validation result is only a user
experience aid and is never the final validation boundary.

---

## 3. Authentication, authorization, and account state

### 3.1 Authentication boundary

Protected API requests require an authenticated session. Authentication may be
provided by an approved external identity provider, but the application API
owns the account mapping, session policy, role checks, deletion behavior, and
authorization decisions.

The API must not expose provider access tokens to the mobile client beyond the
minimum client credential flow approved for that provider. Server-role tokens
remain server-side.

Unauthenticated requests must fail with a stable error and must not reveal
whether a sensitive account, email address, phone number, or private resource
exists.

### 3.2 Account and session states

The API must distinguish at least:

```text
pending_verification
active
restricted
suspended
deletion_pending
deleted
```

Account state affects every protected resource. For example:

- `active`: normal access within role and relationship rules.
- `restricted`: selected actions are disabled while safe reads may remain.
- `suspended`: authentication or business actions fail according to policy.
- `deletion_pending`: no new money movement or new safety-sensitive action;
  deletion status remains queryable.
- `deleted`: no normal authentication; retained records are anonymized or kept
  only where documented for safety, legal, tax, fraud, or reconciliation needs.

### 3.3 Session endpoints

Authentication-provider login and verification endpoints are not duplicated in
this draft. The application-owned session endpoints are:

| Method | Path | Auth | Idempotency | Purpose |
| --- | --- | --- | --- | --- |
| `GET` | `/v1/me` | Required | No | Return the caller's account, role summary, profile summary, and effective restrictions |
| `GET` | `/v1/me/roles` | Required | No | Return approved role assignments and capability summary |
| `GET` | `/v1/me/consents` | Required | No | Return the caller's current consent records |
| `POST` | `/v1/me/consents` | Required | Yes | Record a versioned consent decision |
| `POST` | `/v1/sessions/revoke` | Required | Yes | Revoke the current session or a specified caller-owned session |
| `POST` | `/v1/sessions/revoke-all` | Required | Yes | Revoke all sessions after an authenticated confirmation |
| `POST` | `/v1/me/deletion-request` | Required | Yes | Start account deletion workflow |
| `GET` | `/v1/me/deletion-request` | Required | No | Read deletion status and documented retention exceptions |
| `POST` | `/v1/me/deletion-request/cancel` | Required | Yes | Cancel deletion only during the allowed cancellation window |

`POST /v1/me/consents` must record the policy version, consent type, server
timestamp, actor, source, and withdrawal state where applicable. It must not
store raw device identifiers as proof of consent.

### 3.4 Capability roles

The API separates roles and capabilities:

| Role/capability | Typical access |
| --- | --- |
| User/viewer | Own account, eligible discovery, own relationships, authorized conversations, calls, reports, and purchases |
| Host | Approved profile, availability, eligible call acceptance, earnings view, and host support actions |
| Moderator | Assigned safety cases, minimum evidence, documented enforcement actions, and appeals |
| Support operator | Assigned support cases and approved account workflows; no silent ledger edits |
| Finance operator | Reconciliation, refund, payout, and ledger workflows with separate audit capability |
| Infrastructure administrator | Deployment and infrastructure access; no routine private-message or financial access |
| Backend worker | Specific system-owned transitions and outbox/job processing |
| Provider webhook | Verified event ingestion only; never a general-purpose user role |

The presence of a UI label or client-supplied role is never authorization.

### 3.5 Authorization rules

Every protected endpoint documents:

1. The authenticated actor.
2. The target resource.
3. The ownership or participant relationship.
4. The required role/capability.
5. Block, suspension, deletion, and eligibility checks.
6. The transaction and audit boundary.

The API must fail closed when the account, role, target, token, or policy state
cannot be established.

---

## 4. Response envelopes and errors

### 4.1 Single-resource success

Successful single-resource responses use this proposed shape:

```json
{
  "data": {
    "id": "opaque-resource-id",
    "resource_type": "profile"
  },
  "meta": {
    "request_id": "opaque-request-id"
  }
}
```

The `data` object contains only fields allowed for the caller's authorization
scope. A response must not contain private fields merely because the caller can
guess their names.

### 4.2 Collection success

```json
{
  "data": [],
  "page": {
    "next_cursor": "opaque-cursor-or-null",
    "has_more": true
  },
  "meta": {
    "request_id": "opaque-request-id",
    "ordering": "created_at_desc",
    "filter_version": "opaque-filter-version"
  }
}
```

`next_cursor` is opaque. Clients must send it back unchanged and must not
construct, decode, sort, or persist it as a resource identifier.

### 4.3 Accepted and pending work

Commands that enqueue work or await a provider must return an explicit state:

```json
{
  "data": {
    "operation_id": "opaque-operation-id",
    "status": "pending",
    "resource_id": "opaque-resource-id"
  },
  "meta": {
    "request_id": "opaque-request-id"
  }
}
```

The client must not show a purchase, payout, deletion, message delivery, call
connection, or moderation outcome as complete until the authoritative state says
it is complete.

### 4.4 Error shape

```json
{
  "error": {
    "code": "CALL_NOT_ELIGIBLE",
    "message": "This call cannot be started right now.",
    "retryable": false,
    "field_errors": [],
    "details": {}
  },
  "meta": {
    "request_id": "opaque-request-id"
  }
}
```

Rules:

- `code` is stable and machine-readable.
- `message` is safe for the UI but may later be replaced by a localized message
  key.
- `retryable` describes whether repeating the same operation may succeed; it
  does not replace idempotency rules.
- `field_errors` identifies safe user-input fields and must not contain secrets.
- `details` is optional, bounded, and endpoint-specific.
- No error includes stack traces, SQL, provider payloads, tokens, receipts,
  private moderation evidence, or data outside the caller's scope.

### 4.5 Error code registry

| Code | Suggested HTTP status | Retryable | Meaning |
| --- | ---: | :---: | --- |
| `UNAUTHENTICATED` | 401 | No | No valid authenticated session |
| `SESSION_EXPIRED` | 401 | After re-auth | Session is no longer valid |
| `FORBIDDEN` | 403 | No | Actor lacks access to the resource or action |
| `ROLE_REQUIRED` | 403 | No | Approved role/capability is missing |
| `INVALID_INPUT` | 400 | No | Request shape or value is invalid |
| `VALIDATION_FAILED` | 422 | No | Field-level validation failed |
| `NOT_FOUND` | 404 | No | Resource is not available to this caller |
| `UNAVAILABLE` | 404/409 | Sometimes | Resource exists but is not currently usable |
| `BLOCKED` | 403/409 | No | Block policy prevents the action |
| `SUSPENDED` | 403/423 | No | Account or target is suspended |
| `DELETED` | 410 | No | Resource has been deleted or anonymized |
| `RATE_LIMITED` | 429 | After delay | Request velocity exceeded policy |
| `CONFLICT` | 409 | After refresh | Current state conflicts with the command |
| `DUPLICATE_REQUEST` | 409 | No | Same business effect already exists without replayable result |
| `IDEMPOTENCY_KEY_REUSED` | 409 | No | Key was reused with a different request payload |
| `INSUFFICIENT_ENTITLEMENT` | 402/409 | No | Required credits, access, or eligibility are unavailable |
| `CALL_NOT_ELIGIBLE` | 409 | No | Call policy or participant checks failed |
| `CALL_STATE_INVALID` | 409 | After refresh | Requested call transition is not valid |
| `PERMISSION_REQUIRED` | 409 | After permission | Device permission is required for local continuation |
| `PROVIDER_UNAVAILABLE` | 503 | Yes | Approved provider is unavailable |
| `PROVIDER_TIMEOUT` | 504 | Yes | Approved provider did not respond in time |
| `OFFLINE_RETRYABLE` | 503 | Yes | Request could not reach the API |
| `TIMEOUT_RETRYABLE` | 504 | Yes | API operation timed out; query or retry safely |
| `PURCHASE_PENDING` | 202/409 | Later | Store verification or fulfillment is incomplete |
| `PURCHASE_REJECTED` | 409 | No | Purchase could not be verified or fulfilled |
| `MODERATION_REVIEW` | 202/409 | Later | Action is held for safety review |
| `ACCOUNT_DELETION_PENDING` | 409 | Later | Account operation is still processing |
| `INTERNAL_RETRYABLE` | 503 | Yes | Temporary server failure |
| `INTERNAL_ERROR` | 500 | Unknown | Unexpected failure; contact support with request ID |

The final code registry must be maintained without changing the meaning of an
existing code. Provider-specific errors map into this registry.

---

## 5. Idempotency, retries, and concurrency

### 5.1 Operations requiring idempotency

The following operations create or change a business effect and require an
`Idempotency-Key`:

- profile creation or other commands that create a new owned resource;
- relationship changes where a command is not naturally represented as a safe
  replacement;
- match attempts and match decisions;
- conversation creation;
- message creation and message attachment completion;
- report creation;
- call creation, acceptance, rejection, cancellation, ending, and token
  issuance where a provider effect may be created;
- purchase verification, restore, refund, and fulfillment;
- payout creation and cancellation;
- support-case creation and user deletion requests;
- consent changes that create an auditable record; and
- any future command that changes money, access, moderation, or ownership.

Safe reads such as `GET /v1/me` do not require an idempotency key.

### 5.2 Idempotency protocol

- The client generates a unique key for one logical operation and reuses it for
  retries of that operation.
- The key is scoped to the authenticated account, route, and API version.
- The server stores a bounded request fingerprint, result status, safe response
  body or resource reference, and expiration time in `IdempotencyRecord`.
- Repeating the same key with the same request fingerprint returns the original
  result or its current pending state.
- Reusing a key with a different request fingerprint returns
  `IDEMPOTENCY_KEY_REUSED`.
- The server must not permanently cache access tokens, payment receipts, raw
  provider payloads, or private message bodies in an idempotency record.
- A request timing out does not prove that its effect failed. The client must
  retry with the same key or query the resource by the returned operation ID.
- Idempotency records may expire only after the documented replay window and
  after any provider reconciliation window has passed.

### 5.3 Retry classification

| Situation | Client behavior |
| --- | --- |
| `4xx` validation, authorization, block, or policy error | Do not retry without changing state or user input |
| `409` state conflict | Refresh authoritative state, then decide whether to retry |
| `429` rate limit | Wait for `Retry-After`; do not spin or create new keys |
| `502`, `503`, `504` on an idempotent command | Retry with the same key and bounded backoff |
| Network timeout after command submission | Retry with the same key or query the operation |
| Provider timeout after a financial/call command | Keep command pending and reconcile; never create a new business effect blindly |
| App restart with pending command | Restore the operation and retry with the original key |

Recommended client backoff is bounded exponential backoff with jitter. The exact
delays belong to the client implementation and must respect server-provided
`Retry-After` values.

### 5.4 Optimistic concurrency

Mutable resources may expose a `version` field. An update can require
`If-Match: <version-or-etag>` or an equivalent request field. If the version is
stale, return `CONFLICT` with the current safe resource projection.

Append-only records such as ledger entries, call events, audit events, webhook
events, moderation actions, and payout events do not support ordinary update or
delete semantics. Corrections create linked compensating records.

---

## 6. Pagination, filtering, and consistency

### 6.1 Cursor pagination

Unbounded collections use cursor pagination. Offset pagination is not part of the
production contract.

Common query parameters:

```text
cursor=<opaque cursor>
limit=<1..100>
```

Endpoint-specific filters must be validated and included in the cursor binding.
The server must reject a cursor used with incompatible filters or ordering.

Each collection response provides:

- `next_cursor`, or `null` when no next page exists;
- `has_more`;
- stable ordering metadata;
- filter/schema version when results depend on a policy or ranking version; and
- a request ID.

### 6.2 Consistency rules

- The server owns ordering, filtering, eligibility, and authorization.
- Clients must not sort financial history, moderation cases, or private
  messages to override server ordering.
- Discovery may be eventually consistent, but a resource must still be checked
  for current eligibility when an effectful command is made.
- A deleted or hidden record may disappear between pages. The client must handle
  missing records without treating it as an authorization failure automatically.
- Refresh must not produce duplicate visible items when the client merges pages.
- Presence and availability responses include a server timestamp or freshness
  state; stale presence is not guaranteed live.

### 6.3 Collection-specific pagination

| Collection | Default ordering | Required filters |
| --- | --- | --- |
| Discovery | Policy-defined ranking with stable tie-breaker | Category, locale, availability, approved filters |
| Conversations | Most recently active first | Participant-owned state, archived/unread where approved |
| Messages | `created_at` ascending within a conversation | Conversation ID and direction/cursor |
| Notifications | Newest first | Read state and notification category |
| Reports | Reporter-owned safe status view | Status and created-time range where approved |
| Wallet transactions | Server ledger time descending | Currency/account scope, date range where approved |
| Earnings and payouts | Server settlement time descending | State and date range where approved |
| Support cases | Most recently updated first | Owner and case status |

---

## 7. Common resource shapes

The following shapes are proposed wire projections. They are not database rows
and must be filtered by authorization before serialization.

### 7.1 Account summary

```json
{
  "id": "opaque-account-id",
  "status": "active",
  "locale": "en-US",
  "roles": ["user"],
  "created_at": "2026-10-25T12:00:00Z",
  "updated_at": "2026-10-25T12:00:00Z"
}
```

Never include provider access tokens, recovery secrets, identity-document
contents, advertising IDs, stable device fingerprints, or private risk signals.

### 7.2 Profile summary and detail

```json
{
  "id": "opaque-profile-id",
  "display_name": "Example Host",
  "avatar": {
    "media_id": "opaque-media-id",
    "url": "https://signed.example.invalid/short-lived-resource",
    "expires_at": "2026-10-25T12:10:00Z"
  },
  "bio": "Independent profile description.",
  "locale": "en-US",
  "tags": ["music"],
  "availability": {
    "state": "available",
    "observed_at": "2026-10-25T12:00:00Z"
  },
  "relationship": {
    "following": false,
    "favorite": false,
    "blocked": false
  },
  "verification": {
    "state": "not_displayed"
  }
}
```

The public projection must omit private email, phone, precise location, payout
details, moderation evidence, internal ranking fields, and support data.

### 7.3 Relationship

```json
{
  "actor_id": "opaque-account-id",
  "target_id": "opaque-account-id",
  "kind": "follow",
  "state": "active",
  "created_at": "2026-10-25T12:00:00Z",
  "updated_at": "2026-10-25T12:00:00Z"
}
```

Allowed relationship kinds and conflict rules are product-owned. Blocking must
override positive relationship actions and must consistently affect discovery,
messaging, calls, and notifications.

### 7.4 Conversation and participant

```json
{
  "id": "opaque-conversation-id",
  "kind": "direct",
  "state": "active",
  "participants": [
    {
      "account_id": "opaque-account-id",
      "role": "participant",
      "state": "active",
      "joined_at": "2026-10-25T12:00:00Z",
      "last_read_message_id": "opaque-message-id-or-null"
    }
  ],
  "last_message": null,
  "created_at": "2026-10-25T12:00:00Z",
  "updated_at": "2026-10-25T12:00:00Z"
}
```

Only authorized participants receive participant or message data. A blocked,
suspended, or deleted participant may be represented by a safe restricted
projection rather than a private explanation.

### 7.5 Message

```json
{
  "id": "opaque-message-id",
  "conversation_id": "opaque-conversation-id",
  "sender_id": "opaque-account-id",
  "kind": "text",
  "body": "Hello.",
  "moderation_state": "visible",
  "delivery_state": "accepted",
  "attachments": [],
  "created_at": "2026-10-25T12:00:00Z",
  "updated_at": "2026-10-25T12:00:00Z"
}
```

Possible application states include `draft`, `submitting`, `accepted`,
`failed`, `retryable`, `delivered`, `read`, `held`, `removed`, and
`redacted`. The API must not claim `delivered` or `read` without the relevant
server/provider evidence.

### 7.6 Call session

```json
{
  "id": "opaque-call-id",
  "initiator_id": "opaque-account-id",
  "recipient_id": "opaque-account-id",
  "state": "requested",
  "provider_state": "not_started",
  "billable_state": "not_started",
  "requested_at": "2026-10-25T12:00:00Z",
  "connected_at": null,
  "ended_at": null,
  "end_reason": null,
  "server_time": "2026-10-25T12:00:00Z"
}
```

Application call state, RTC provider state, billable state, and UI state are
separate. The client must not change the final call or financial outcome by
reporting a local timer or lifecycle callback.

### 7.7 Report receipt

```json
{
  "id": "opaque-case-id",
  "status": "received",
  "target_type": "message",
  "created_at": "2026-10-25T12:00:00Z",
  "next_step": "reviewed_under_safety_policy"
}
```

The reporter receives only the minimum safe status. Internal evidence, staff
notes, reporter identity, risk scores, and enforcement details are restricted.

---

## 8. Endpoint contracts

Each endpoint below is a proposed contract entry. Before implementation, each
route must have an executable schema, authorization test, failure test, and
mapping to the relevant product requirement IDs.

### 8.1 Account, profile, and consent endpoints

#### `GET /v1/me`

- **Actor:** authenticated account.
- **Purpose:** return the caller's account summary, safe profile summary, roles,
  restrictions, and current server time.
- **Request body:** none.
- **Response:** `AccountSummary` plus the caller's authorized profile projection.
- **Errors:** `UNAUTHENTICATED`, `SESSION_EXPIRED`, `DELETED`,
  `INTERNAL_RETRYABLE`.
- **Audit:** normal reads may use access telemetry; do not log private fields.

#### `PATCH /v1/me/profile`

- **Actor:** authenticated account; host-only fields require approved host
  capability.
- **Idempotency:** required when the update creates a new media association or
  other external effect; ordinary replacement may use `If-Match`.
- **Request:** only owner-editable fields such as `display_name`, `bio`,
  `locale`, tags, availability preferences, and approved visibility settings.
- **Validation:** field lengths, supported locale, tag policy, visibility rules,
  moderation state, and account status.
- **Authorization:** cannot update another account or grant a role, verification
  status, host eligibility, or payout state.
- **Response:** current profile projection and `version`.
- **Errors:** `VALIDATION_FAILED`, `FORBIDDEN`, `CONFLICT`, `SUSPENDED`,
  `RATE_LIMITED`, `MODERATION_REVIEW`.

#### `GET /v1/profiles/{profile_id}`

- **Actor:** public or authenticated access only if the product approves public
  profile discovery; otherwise authenticated account.
- **Purpose:** return the target's privacy-filtered profile projection.
- **Authorization:** apply block, suspension, deletion, region, age, and
  visibility rules before serialization.
- **Response:** `ProfileSummary` or `ProfileDetail` according to caller scope.
- **Errors:** `NOT_FOUND`, `BLOCKED`, `UNAVAILABLE`, `SUSPENDED`.

#### `GET /v1/me/roles`

- Returns approved role assignments and capability names without internal staff
  notes or provider identity details.
- A role assignment is server-owned and cannot be submitted through a normal
  user endpoint.

#### `GET /v1/me/consents`

- Returns current consent versions, effective timestamps, and withdrawal state.
- Does not return raw device identifiers or hidden risk metadata.

#### `POST /v1/me/consents`

- **Idempotency:** required.
- **Request:** `consent_type`, `policy_version`, `decision`, and optional
  `context` from an allowlisted enum.
- **Server behavior:** record an append-only `ConsentRecord`; do not overwrite
  historical consent evidence.
- **Errors:** `INVALID_INPUT`, `CONFLICT`, `SUSPENDED`.

#### Session and deletion operations

| Method | Path | Auth | Idempotency | Contract behavior |
| --- | --- | --- | --- | --- |
| `POST` | `/v1/sessions/revoke` | Required | Yes | Revoke only the current or caller-owned session; do not accept arbitrary account IDs |
| `POST` | `/v1/sessions/revoke-all` | Required | Yes | Revoke all sessions after the server validates the current session |
| `POST` | `/v1/me/deletion-request` | Required | Yes | Start authenticated, retryable deletion orchestration |
| `GET` | `/v1/me/deletion-request` | Required | No | Return deletion status, timestamps, cancellation window, and safe retention explanation |
| `POST` | `/v1/me/deletion-request/cancel` | Required | Yes | Cancel only when policy allows; never restore already-purged data |

Deletion requests must not silently delete records required for safety, legal,
tax, fraud, or financial reconciliation. The response must distinguish
`requested`, `processing`, `completed`, `canceled`, and `blocked_for_review`.

### 8.2 Profile media endpoints

#### `POST /v1/media/upload-intents`

- **Actor:** authenticated account.
- **Idempotency:** required.
- **Request:** media purpose (`profile_avatar`, `profile_media`, or approved
  message/report attachment), MIME type, byte size, and optional dimensions.
- **Server checks:** ownership, account status, purpose, type, size, dimensions,
  quota, rate limits, and malware/content-safety policy.
- **Response:** opaque `media_id`, short-lived upload instruction, expiry, and
  required headers. The upload instruction must not expose server secrets.
- **Errors:** `VALIDATION_FAILED`, `FORBIDDEN`, `RATE_LIMITED`,
  `PROVIDER_UNAVAILABLE`.

#### `POST /v1/media/{media_id}/complete`

- **Actor:** media owner.
- **Idempotency:** required.
- **Purpose:** confirm upload completion and start validation/scanning.
- **Response:** `pending`, `accepted`, `held`, or `rejected` media state.
- **Errors:** `NOT_FOUND`, `FORBIDDEN`, `CONFLICT`, `MODERATION_REVIEW`.

#### `DELETE /v1/media/{media_id}`

- **Actor:** media owner or narrowly scoped operator.
- **Idempotency:** required.
- **Behavior:** hide or delete according to retention policy; do not promise
  immediate permanent deletion when a safety or legal hold applies.
- **Errors:** `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `SUSPENDED`.

### 8.3 Discovery endpoints

#### `GET /v1/discovery`

Common query parameters:

```text
cursor=<opaque cursor>
limit=<1..100>
category=<approved category>
locale=<approved locale>
availability=<available|unavailable|any>
sort=<approved policy value>
```

- **Actor:** public or authenticated according to product approval; effectful
  actions always require authentication.
- **Purpose:** return profiles eligible for the requesting actor.
- **Server rules:** apply block, deletion, suspension, privacy, geography, age,
  host eligibility, and ranking policy before returning results.
- **Response:** paginated profile summaries with freshness metadata.
- **Errors:** `INVALID_INPUT`, `RATE_LIMITED`, `OFFLINE_RETRYABLE`,
  `INTERNAL_RETRYABLE`.
- **Privacy:** do not expose ranking features, fraud signals, exact location, or
  private availability reasons.

#### `GET /v1/profiles/{profile_id}/availability`

- Returns a coarse availability state and `observed_at` timestamp only when the
  caller is permitted to see it.
- Availability is advisory. A call request performs a fresh server eligibility
  check.

### 8.4 Relationships and matching endpoints

| Method | Path | Auth | Idempotency | Result |
| --- | --- | --- | --- | --- |
| `GET` | `/v1/relationships` | Required | No | Paginated caller-owned relationship list |
| `PUT` | `/v1/relationships/{target_id}/follow` | Required | Yes | Follow relationship in desired active state |
| `DELETE` | `/v1/relationships/{target_id}/follow` | Required | Yes | Follow relationship in desired inactive state |
| `PUT` | `/v1/relationships/{target_id}/favorite` | Required | Yes | Favorite relationship in desired active state |
| `DELETE` | `/v1/relationships/{target_id}/favorite` | Required | Yes | Favorite relationship in desired inactive state |
| `PUT` | `/v1/relationships/{target_id}/block` | Required | Yes | Block target and apply cross-surface restrictions |
| `DELETE` | `/v1/relationships/{target_id}/block` | Required | Yes | Remove block only where policy permits |
| `POST` | `/v1/matches` | Required | Yes | Create one match attempt after eligibility checks |
| `GET` | `/v1/matches` | Required | No | Paginated caller-owned match history |
| `GET` | `/v1/matches/{match_id}` | Required | No | Return safe match state |
| `POST` | `/v1/matches/{match_id}/decision` | Required | Yes | Accept, skip, cancel, or otherwise decide according to policy |

Relationship commands are idempotent desired-state operations. Blocking must
override follow, favorite, matching, messaging, calling, and notification
eligibility consistently. Match ranking and candidate rules remain server-only.

Match decisions must have one final outcome. Repeating a decision with the same
idempotency key returns the original result; a conflicting final decision
returns `CONFLICT`.

### 8.5 Conversation and message endpoints

#### Conversation routes

| Method | Path | Auth | Idempotency | Result |
| --- | --- | --- | --- | --- |
| `GET` | `/v1/conversations` | Required | No | Paginated conversations for the caller |
| `POST` | `/v1/conversations` | Required | Yes | Create or return an authorized direct conversation |
| `GET` | `/v1/conversations/{conversation_id}` | Required | No | Return authorized conversation metadata |
| `GET` | `/v1/conversations/{conversation_id}/messages` | Required | No | Cursor-paginated messages |
| `POST` | `/v1/conversations/{conversation_id}/read` | Required | Yes | Advance caller's read marker safely |

`POST /v1/conversations` must not create duplicate direct conversations for the
same approved participant pair. Block, suspension, privacy, and messaging
eligibility checks occur before creation.

#### Message routes

| Method | Path | Auth | Idempotency | Result |
| --- | --- | --- | --- | --- |
| `POST` | `/v1/conversations/{conversation_id}/messages` | Participant | Yes | Create one moderated message or return pending review state |
| `PATCH` | `/v1/messages/{message_id}` | Sender or approved operator | Conditional | Edit only where policy allows; preserve audit history |
| `DELETE` | `/v1/messages/{message_id}` | Sender or approved operator | Yes | Hide/redact according to retention and safety rules |
| `POST` | `/v1/messages/{message_id}/report` | Authorized viewer | Yes | Create a private safety case |

Message creation request example:

```json
{
  "kind": "text",
  "body": "Hello.",
  "attachment_ids": []
}
```

Message rules:

- Empty messages are rejected.
- Length, Unicode encoding, attachment ownership, type, size, and rate limits
  are enforced server-side.
- Moderation may accept, hold, redact, or reject a message.
- A held message must not appear delivered to the recipient.
- A notification failure does not roll back an accepted message.
- A retry with the same idempotency key creates at most one message.
- A blocked or suspended participant cannot send new messages when policy says
  the conversation is restricted.
- Normal logs and analytics never contain message bodies.

### 8.6 One-to-one call endpoints

#### Call lifecycle routes

| Method | Path | Auth | Idempotency | Result |
| --- | --- | --- | --- | --- |
| `POST` | `/v1/calls` | Participant | Yes | Create one call request after eligibility checks |
| `GET` | `/v1/calls` | Participant | No | Paginated authorized call history |
| `GET` | `/v1/calls/{call_id}` | Participant | No | Current call projection |
| `POST` | `/v1/calls/{call_id}/accept` | Recipient/eligible host | Yes | Transition `requested` to `accepted` |
| `POST` | `/v1/calls/{call_id}/reject` | Recipient | Yes | Transition to `rejected` |
| `POST` | `/v1/calls/{call_id}/cancel` | Initiator | Yes | Transition to `canceled` while allowed |
| `POST` | `/v1/calls/{call_id}/end` | Participant/authorized system | Yes | End call and begin reconciliation |
| `POST` | `/v1/calls/{call_id}/rtc-token` | Participant | Yes | Issue one short-lived scoped RTC grant |
| `GET` | `/v1/calls/{call_id}/settlement` | Participant, gated | No | Return authorized settlement projection |
| `POST` | `/v1/calls/{call_id}/report` | Participant | Yes | Create a private safety case |

Call creation request example:

```json
{
  "recipient_id": "opaque-account-id",
  "conversation_id": "opaque-conversation-id-or-null",
  "client_context": {
    "app_version": "0.1.0"
  }
}
```

The server must independently check:

- recipient existence and account state;
- block and relationship policy;
- host eligibility and availability;
- concurrent-call limits;
- account and spending limits;
- entitlement or balance when billing is enabled;
- call policy version;
- idempotency key and duplicate active-call rules; and
- provider availability before issuing an RTC token.

Application state transitions are:

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

The RTC provider does not own the application settlement result. Provider
callbacks, server timestamps, call events, and reconciliation rules determine
the final application state. A client timer or local lifecycle callback is never
enough to settle a charge or host earning.

#### RTC token response

```json
{
  "data": {
    "call_id": "opaque-call-id",
    "provider": "approved-rtc-adapter",
    "room_reference": "opaque-room-reference",
    "token": "short-lived-provider-token",
    "expires_at": "2026-10-25T12:05:00Z",
    "participant_role": "subscriber"
  },
  "meta": {
    "request_id": "opaque-request-id"
  }
}
```

The response may contain a short-lived participant token because the client
needs it to connect, but never contains the provider API key or secret. Room
references and token scopes must be limited to the exact call and participant.

### 8.7 Reports and safety endpoints

#### `POST /v1/reports`

- **Actor:** authenticated user with an authorized view of the target.
- **Idempotency:** required.
- **Request:** target type, target ID, reason code, optional bounded explanation,
  and optional evidence references the caller is allowed to submit.
- **Allowed target types:** `account`, `profile`, `message`, `media`, `call`,
  or another approved product resource.
- **Server behavior:** verify target visibility, create a private `SafetyCase`,
  apply rate limits, and return a safe acknowledgement.
- **Response:** report receipt with case ID and safe status only.
- **Errors:** `INVALID_INPUT`, `NOT_FOUND`, `FORBIDDEN`, `RATE_LIMITED`,
  `DUPLICATE_REQUEST`.

#### `GET /v1/reports/{report_id}`

- The reporter may read only the safe case status and timestamps allowed by
  policy.
- Moderators use a separate operator surface with capability checks and audited
  evidence access.
- The reported user cannot read the reporter identity or private case evidence.

#### Block behavior

Blocking uses the relationship endpoints in section 8.4. A successful block
must apply consistently to:

- discovery results;
- follow/favorite/match actions;
- new messages and message notifications;
- call requests and active-call policy;
- profile availability projections; and
- other approved interaction surfaces.

If a block affects an active call, the server must transition the call through a
documented safe state and revoke or restrict provider access as appropriate.

### 8.8 Notification and device endpoints

| Method | Path | Auth | Idempotency | Purpose |
| --- | --- | --- | --- | --- |
| `GET` | `/v1/notifications` | Required | No | Paginated caller-owned notifications |
| `POST` | `/v1/notifications/{notification_id}/read` | Required | Yes | Mark one notification read |
| `POST` | `/v1/notifications/read-all` | Required | Yes | Mark eligible notifications read |
| `POST` | `/v1/devices` | Required | Yes | Register or refresh an approved push target |
| `DELETE` | `/v1/devices/{device_id}` | Required | Yes | Remove a caller-owned push target |
| `PATCH` | `/v1/notification-preferences` | Required | Conditional | Update approved notification preferences |

Device registration request example:

```json
{
  "platform": "android",
  "app_version": "0.1.0",
  "device_family": "coarse-device-family",
  "push_token": "provider-token",
  "locale": "en-US"
}
```

Rules:

- Push tokens are secrets or sensitive provider references and must be encrypted
  or access-controlled appropriately.
- Advertising IDs, raw hardware identifiers, and stable fingerprints are not
  required fields and must not become account identity.
- Notification payloads contain minimal private content, especially on lock
  screens and third-party push systems.
- Re-registering the same approved device target must be idempotent.
- A disabled, logged-out, deleted, or revoked device must stop receiving
  protected notifications.

### 8.9 Gated wallet and product endpoints

These endpoints remain disabled until `docs/PAYMENTS_AND_EARNINGS.md`, legal
review, store policy review, fraud controls, and server-side ledger tests are
approved.

| Method | Path | Auth | Idempotency | Purpose |
| --- | --- | --- | --- | --- |
| `GET` | `/v1/wallet` | Required | No | Return server-calculated wallet projection |
| `GET` | `/v1/wallet/transactions` | Required | No | Return cursor-paginated authorized transaction history |
| `GET` | `/v1/products` | Required/approved public | No | Return active product catalog and policy version |
| `POST` | `/v1/purchases` | Required | Yes | Submit a store purchase for server verification |
| `GET` | `/v1/purchases/{purchase_id}` | Required | No | Return verification and fulfillment state |
| `POST` | `/v1/purchases/{purchase_id}/restore` | Required | Yes | Reconcile caller-owned approved purchases |
| `GET` | `/v1/entitlements` | Required | No | Return current entitlement projection |
| `GET` | `/v1/earnings` | Host | No | Return host earnings by approved state |
| `GET` | `/v1/payouts` | Host | No | Return host payout history |
| `POST` | `/v1/payouts` | Host | Yes | Request an eligible payout |
| `GET` | `/v1/payouts/{payout_id}` | Host | No | Return payout state and safe failure reason |

#### Purchase request

```json
{
  "store": "approved-store",
  "product_id": "independent-product-id",
  "purchase_token": "store-issued-token",
  "client_purchase_reference": "opaque-client-reference"
}
```

The server verifies the receipt or purchase token with the store, deduplicates
provider events, and grants value only after verification. The client cannot
choose the amount, currency, entitlement, host rate, ledger account, or payout
destination.

#### Wallet and ledger rules

- Wallet balances are projections derived from an append-only ledger.
- Public APIs cannot directly set or increment a balance.
- Every financial effect has a source reference, policy version, currency,
  integer minor-unit amount, actor/source, and idempotency reference.
- Refunds, chargebacks, reversals, and corrections create compensating entries.
- Historical settlements retain the rate and policy version used.
- Provider payloads and receipts are not returned in normal user responses.

#### Host earnings and payouts

Host earnings expose only approved projections such as:

```text
pending | available | held | paid | reversed | disputed
```

A payout request checks host identity/eligibility, geography, minimum threshold,
tax status, risk holds, limits, and duplicate active requests. A payout cannot
be labeled paid until provider confirmation and reconciliation are complete.

### 8.10 Support endpoints

Support APIs are user-facing only for the caller's own cases. Staff tools must
be separate from the mobile API or require explicit operator capability tokens.

| Method | Path | Auth | Idempotency | Purpose |
| --- | --- | --- | --- | --- |
| `POST` | `/v1/support/cases` | Required | Yes | Create a support case |
| `GET` | `/v1/support/cases` | Required | No | List caller-owned support cases |
| `GET` | `/v1/support/cases/{case_id}` | Required | No | Read safe case details |
| `POST` | `/v1/support/cases/{case_id}/messages` | Required participant | Yes | Add a support message or approved attachment |
| `POST` | `/v1/support/cases/{case_id}/close` | Required participant | Yes | Request case closure |

Support responses must not expose internal moderation notes, payment payloads,
provider secrets, or unrelated user data. Sensitive support and finance actions
must create audited operator events.

---

## 9. Provider webhooks and asynchronous events

### 9.1 Webhook trust boundary

Provider webhooks are untrusted input until signature, timestamp, audience, and
event identity are verified. The server must verify the signature before parsing
business data or changing application state.

Possible provider ingress families are placeholders until providers are approved:

```text
POST /v1/webhooks/billing/{provider}
POST /v1/webhooks/rtc/{provider}
POST /v1/webhooks/storage/{provider}
POST /v1/webhooks/notifications/{provider}
```

These routes are not callable by the mobile client.

### 9.2 Webhook processing sequence

Every webhook handler must:

1. Receive the raw body through a protected ingress boundary.
2. Verify the provider signature and timestamp tolerance.
3. Validate the provider event ID and event type.
4. Deduplicate against `WebhookEvent`.
5. Store only the minimum redacted audit envelope needed for reconciliation.
6. Map the event into an application command or state transition.
7. Apply the command transactionally and idempotently.
8. Enqueue dependent notifications or jobs through an outbox.
9. Acknowledge only according to the provider retry contract.
10. Send failures to a dead-letter or manual-recovery path.

### 9.3 Event ordering and replay

The application must tolerate duplicated, delayed, missing, and out-of-order
events. Provider event timestamps do not automatically override authoritative
application state. If evidence conflicts, mark the resource for reconciliation
instead of silently choosing the client or provider value.

Webhook handlers must not:

- credit a wallet twice;
- create duplicate messages or calls;
- mark a payout paid without confirmation;
- settle a call from a single unverified callback; or
- expose raw provider payloads in normal logs.

### 9.4 Internal events

Internal outbox events may include:

```text
profile.updated
relationship.changed
message.accepted
message.moderation_changed
call.requested
call.accepted
call.connected
call.reconnecting
call.ended
purchase.verified
ledger.transaction_posted
report.created
account.deletion_requested
notification.created
```

Each event includes an event ID, event type, schema version, created timestamp,
source, aggregate type/ID, request ID, and bounded redacted metadata. Events do
not contain secrets, full message bodies, payment receipts, or private media
URLs unless a separately approved protected workflow requires them.

---

## 10. Rate limits and abuse controls

Rate limits are server-side controls, not UI hints. Exact production thresholds
are **Proposed** until abuse, cost, and capacity testing is complete.

| Category | Examples | Required controls |
| --- | --- | --- |
| Authentication | Login, recovery, verification, provider linking | Per-account/IP limits, progressive delay, audit, safe enumeration behavior |
| Discovery | Feed refresh, profile reads | Per-account and adaptive abuse limits; cache safe public projections |
| Relationships | Follow, favorite, block, match | Per-account velocity limits and duplicate suppression |
| Messaging | Conversation/message creation, attachments | Per-account/conversation limits, moderation, spam controls, attachment quotas |
| Reports | Report creation and evidence | Per-account limits, duplicate-case handling, abuse review |
| Calls | Requests, accept/reject, token issuance | Concurrent-call limits, recipient velocity, spending/eligibility checks |
| Uploads | Upload intents and completion | Size/type quotas, scanning, bandwidth limits, abandoned-upload cleanup |
| Purchases | Purchase verification and restore | Idempotency, provider limits, fraud monitoring, no client balance trust |
| Payouts | Payout creation and status | Eligibility, account limits, holds, manual-review threshold, duplicate prevention |
| Support | Case and message creation | Per-account limits, attachment policy, spam review |

When a limit is exceeded, return `RATE_LIMITED`, include a safe `Retry-After`
when appropriate, and do not reveal internal fraud thresholds. Rate-limit logs
must use a safe actor category or opaque ID and must not contain message bodies,
payment receipts, authorization headers, or raw device identifiers.

The server may temporarily disable new calls, purchases, payouts, uploads, or
messaging through an audited operational control. The API must return a stable
user-safe error while the control is active.

---

## 11. Realtime, synchronization, and offline behavior

### 11.1 Source of truth

The versioned HTTP API is authoritative for:

- identity and permissions;
- profile and relationship state;
- conversation membership and message acceptance;
- call application state;
- wallet, entitlements, ledger, earnings, and payout state;
- moderation and account state; and
- account deletion.

Realtime streams, push notifications, provider callbacks, and local UI state are
delivery mechanisms or observations. They are not authority by themselves.

### 11.2 Reconnect and resynchronization

After an app restart, offline period, token refresh, provider reconnect, push
notification tap, or realtime disconnect, the client must:

1. Re-authenticate or refresh its session safely.
2. Query the authoritative resource or collection.
3. Apply the latest server state using the documented cursor/version.
4. Re-submit only pending effectful commands with the original idempotency key.
5. Remove or reconcile stale optimistic UI state.

The API must support safe refresh for discovery, conversations, messages,
notifications, calls, purchases, and deletion status.

### 11.3 Realtime event envelope

If a realtime provider is used, application events should use an envelope such
as:

```json
{
  "event_id": "opaque-event-id",
  "event_type": "message.accepted",
  "schema_version": 1,
  "aggregate_type": "message",
  "aggregate_id": "opaque-message-id",
  "occurred_at": "2026-10-25T12:00:00Z",
  "data": {
    "message_id": "opaque-message-id",
    "conversation_id": "opaque-conversation-id",
    "state": "accepted"
  }
}
```

Events must be scoped to the authenticated subscription and must not expose
private data to an unauthorized participant. Clients must tolerate duplicate or
missing events by resynchronizing through HTTP.

---

## 12. Audit and observability requirements

### 12.1 Request audit fields

Sensitive commands and operator actions record, where applicable:

```text
request_id
actor_account_id
actor_role_or_capability
source                    # client / api / worker / provider / operator
target_type
target_id
action
result
failure_code
idempotency_key
provider_event_id
created_at_utc
```

Audit records are append-only. They must not contain access tokens, full
authorization headers, message bodies, private media URLs, payment payloads, or
unnecessary personal data.

### 12.2 Safe operational metrics

The API should expose metrics to internal observability systems for:

- request count, latency, saturation, and error rate by route family;
- authentication failures and session revocations;
- discovery latency, empty results, and cursor failures;
- accepted, rejected, held, delivered, and failed messages without bodies;
- call request, acceptance, connection, reconnect, end, and failure rates;
- RTC token issuance and provider failure rates;
- report queue age and moderation processing failures;
- purchase, refund, webhook, ledger, and payout reconciliation;
- account deletion completion and exception rates; and
- storage, bandwidth, database, and provider cost trends.

Analytics event definitions belong in `docs/ANALYTICS_EVENTS.md`. The API
contract only defines the correlation and redaction boundary.

### 12.3 Health and readiness endpoints

Internal operational endpoints may include:

```text
GET /health/live
GET /health/ready
```

They must not expose dependency secrets, database connection strings, user data,
provider payloads, or detailed internal topology. Public availability checks
must not be confused with authenticated application API health.

---

## 13. API versioning and compatibility

### 13.1 Version policy

- `/v1` is the first public contract version.
- Additive response fields are allowed when clients ignore unknown fields safely.
- Removing fields, changing field meaning, changing enum semantics, changing
  authorization behavior, or changing financial meaning is breaking.
- Breaking changes require a new version or an explicitly approved migration.
- Error-code meanings must not be silently changed.
- Event and webhook payloads carry their own schema version.

### 13.2 Deprecation

Deprecated routes or fields must document:

- deprecation date;
- replacement route or field;
- minimum supported client version;
- removal date or review date;
- compatibility behavior; and
- migration tests.

Clients must not be forced to upgrade before the documented compatibility
window unless an emergency security or legal action is approved and supported.

### 13.3 Client compatibility

The server may use `X-Client-Version` and platform metadata for compatibility,
but those values are advisory and not authorization. Unsupported clients receive
`UNAVAILABLE` or a dedicated compatibility error with a safe upgrade path.

---

## 14. Security and privacy rules

The API implementation must follow `docs/SECURITY_AND_PRIVACY.md` once that
document is created. Until then, these minimum rules apply:

- Authenticate every protected request.
- Authorize every read and write against the authenticated actor and resource.
- Validate all types, lengths, enums, ownership, state, and rate limits at the
  server boundary.
- Use short-lived scoped provider tokens.
- Keep service-role keys and provider secrets server-side.
- Use row-level security or an equivalent repository authorization boundary for
  user-owned data.
- Redact sensitive values from normal logs, traces, analytics, and support
  diagnostics.
- Treat client input, provider callbacks, upload metadata, and realtime events
  as untrusted.
- Do not use advertising IDs, stable device fingerprints, or raw hardware IDs
  as account identity or general authorization inputs.
- Do not expose reporter identity or private moderation evidence.
- Do not expose another user's private messages, call metadata, payout data,
  support records, or identity documents.
- Make account deletion and retained-record exceptions explicit and retryable.

---

## 15. Executable contract and implementation artifacts

This Markdown document is the human-readable contract. The initial machine-readable
draft is available at:

```text
contracts/openapi/v1/openapi.yaml
```

The executable schema must remain aligned with this document and should include:

- route and method definitions;
- authentication schemes;
- request and response schemas;
- enum values and field constraints;
- common error responses;
- pagination parameters;
- idempotency and correlation headers;
- security requirements by route;
- examples with fake data only; and
- version and deprecation metadata.

Generated clients, server validators, and API tests must be reviewed against
this document. Generated artifacts do not replace the approval and ownership
requirements for the human-readable contract.

### 15.1 Contract test requirements

Every production route needs at least:

- schema validation for valid and invalid input;
- unauthenticated request coverage;
- second-account authorization coverage;
- ownership/participant coverage;
- blocked, suspended, deleted, and restricted-state coverage where applicable;
- rate-limit coverage;
- idempotency replay and key-reuse coverage for effectful commands;
- timeout/provider-failure coverage where applicable;
- pagination and cursor consistency coverage for collections;
- safe error and redaction assertions; and
- audit/event assertions for sensitive state changes.

Payment, payout, moderation, account deletion, authorization, and webhook
routes require server-side integration tests. Client-only tests are
insufficient.

---

## 16. Contract-to-requirement mapping

| API area | Product requirements |
| --- | --- |
| Authentication, sessions, deletion | `FR-AUTH-001` through `FR-AUTH-008` |
| Discovery and profiles | `FR-DISC-001` through `FR-DISC-009` |
| Matching | `FR-MATCH-001` through `FR-MATCH-006` |
| Messaging | `FR-MSG-001` through `FR-MSG-012` |
| Calls and RTC | `FR-CALL-001` through `FR-CALL-015` |
| Wallet, purchases, earnings, payouts | `FR-MONEY-001` through `FR-MONEY-012` |
| Safety, reports, blocks, privacy | `FR-SAFE-*` |
| Notifications and telemetry | Relevant notification and privacy requirements |

Each endpoint implementation ticket should reference this document, the
applicable requirement ID, the domain aggregate, the migration or repository
boundary, and the tests that prove the contract.

---

## 17. Open decisions before approval

The following decisions remain unresolved and must be recorded as approved
product, architecture, legal, or operational decisions before this contract is
marked **Approved**:

1. Whether REST/JSON with OpenAPI 3.1 is the final API style.
2. Whether JSON fields use `snake_case` or `camelCase`.
3. Authentication provider, token format, refresh policy, and account-linking
   behavior.
4. Public versus authenticated discovery access.
5. Exact profile, message, attachment, report, and upload limits.
6. Initial matching scope and whether matching is in the first release.
7. Conversation creation and message-retention policy.
8. RTC provider, token format, callback contract, and reconnect policy.
9. Call billing unit, billable start/stop events, grace period, and spending
   limits.
10. Currency, product catalog, store integration, refunds, chargebacks, host
    earnings, and payout policy.
11. Moderation roles, evidence access, enforcement states, appeals, and SLA.
12. Data retention, account deletion, export, legal hold, and regional policy.
13. Rate-limit thresholds, abuse signals, and emergency feature controls.
14. API hosting, observability, support access, and incident response ownership.

Until these choices are resolved, examples and endpoints marked **Proposed** or
**Gated** must not be presented as live production behavior.

---

## 18. Approval checklist

Before changing this document to **Approved**:

- [ ] Product owner has approved the initial route scope and user outcomes.
- [ ] Engineering owner has approved transport, naming, versioning, and error conventions.
- [ ] Security/privacy review has approved authentication, authorization, logging, and data minimization.
- [ ] Domain model and database migrations map to every required resource.
- [ ] Every effectful route defines idempotency and retry behavior.
- [ ] Every collection defines cursor ordering, filters, and consistency behavior.
- [ ] Every protected route has two-account authorization tests.
- [ ] Reports, blocks, account deletion, and operator access are covered by server tests.
- [ ] Video-call state, RTC tokens, reconnects, and provider failures are covered by server/device tests.
- [ ] Payment, ledger, receipt, refund, webhook, earnings, and payout rules are separately approved before enabling money.
- [ ] The OpenAPI schema validates and agrees with this document.
- [ ] Error responses are stable, safe, localized appropriately, and redacted.
- [ ] Rate limits, audit events, dashboards, alerts, and runbooks exist.
- [ ] Legal, store-policy, tax, support, and operational approvals are recorded where required.
- [ ] No target-specific code, endpoint, credential, package name, asset, or private provider behavior has been reused.
