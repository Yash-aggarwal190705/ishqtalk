# Video Call Rules — Independent Social Discovery and One-to-One RTC

**Status:** Draft / proposed  
**Owner:** Product and engineering owners to be assigned; security, privacy,
finance, safety, legal, and device-test reviewers required  
**Last updated:** 2026-10-25  
**Source of truth for:** Call eligibility, lifecycle, RTC permissions, reconnect,
metering, billing coordination, safety, media handling, and call-history rules  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0003-rtc-provider.md`

This document defines independent rules for private one-to-one video calls. It
does not reproduce target RTC providers, private room identifiers, credentials,
channel names, pricing, UI, or call state behavior. The supplied artifact was
not runtime-verified, so target-specific call behavior remains unknown.

Real calls, recording, billing, host earnings, and production RTC providers are
gated until the policy and test requirements in this document are approved.

---

## 1. Scope, principles, and release gates

### 1.1 Scope

These rules cover:

- one-to-one call requests and invitations;
- caller/recipient eligibility and role checks;
- acceptance, rejection, cancellation, expiration, and ending;
- application call state versus RTC provider state;
- camera, microphone, route, and notification permissions;
- scoped RTC token issuance and revocation;
- network interruption, reconnect, timeout, and provider failure;
- billable state and settlement coordination when economy is enabled;
- block, suspension, deletion, report, and safety behavior;
- call metadata, history, retention, and privacy; and
- device, backend, provider, and operational test requirements.

### 1.2 Core principles

- The backend owns application authorization and call state.
- The RTC provider owns media transport, not application billing or permissions.
- The client renders state and submits commands; it does not choose price,
  duration, eligibility, or final settlement.
- Application state, provider state, billable state, and UI state are separate.
- Every effectful command is idempotent and safe to retry.
- Server-confirmed timestamps and verified events are authoritative for billing.
- Media capture stops when the call ends or authorization is revoked.
- Recording and background capture are disabled by default.
- A provider outage produces a recoverable safe state rather than a false success.

### 1.3 Release stages

| Stage | Call behavior | Billing/earnings |
| --- | --- | --- |
| Local MVP | Seeded/demo call state; fake provider or no media | Disabled; any values labeled demo |
| Development | Approved test accounts and sandbox provider | Fake events or sandbox only |
| Closed testing | Real device RTC with test projects and test users | Store sandbox and simulated settlement |
| Production | Approved provider, device matrix, safety/support coverage | Only after `PAYMENTS_AND_EARNINGS.md` approval |

---

## 2. Roles, terminology, and source of truth

### 2.1 Roles

| Role | Call permissions |
| --- | --- |
| Initiator | Request, cancel while allowed, join as authorized participant, end own call |
| Recipient/host | Accept or reject while allowed, join as authorized participant, end own call |
| Moderator | Report/review safety issues; no ordinary call control or media access |
| Support | Explain safe status and assist with approved case workflows |
| Finance | Reconcile settlement/refund/earnings; no client call control |
| Backend service | Authorize, transition state, issue/revoke tokens, reconcile |
| RTC provider | Transport media and emit verified provider events |

### 2.2 Call state sources

| State | Authority |
| --- | --- |
| Application call lifecycle | Backend call service and database |
| Participant authorization | Backend policy and current account state |
| Media transport | Approved RTC provider adapter |
| Camera/mic permission | Device OS and client presentation |
| Billable time | Server settlement policy plus verified call evidence |
| User-visible history | Backend call projection and settlement state |
| Provider callback | Untrusted until signature/event verification |

### 2.3 Call identifiers

Use separate opaque identifiers for:

- application `call_id`;
- participant references;
- provider room/session reference;
- RTC token/grant audit record;
- call event;
- settlement; and
- idempotency/request keys.

Do not expose provider secrets, internal room naming rules, or sequential database
IDs. Never use a client-generated room name as proof of authorization.

---

## 3. Eligibility before a call request

### 3.1 Server-side preconditions

Before creating a call request, the backend checks:

- authenticated initiator and valid session;
- initiator and recipient account status;
- target existence and authorized relationship;
- block and safety restrictions in both directions;
- recipient availability and host eligibility where applicable;
- geographic and age policy;
- concurrent-call limits for both participants;
- rate limits and abuse controls;
- entitlement, balance, spending limit, or ticket requirement if enabled;
- active deletion, suspension, or moderation holds;
- provider availability and environment;
- duplicate active-call rules; and
- idempotency key and request fingerprint.

The client may hide an unavailable button, but the server repeats every check.

### 3.2 Call request command

Proposed API:

```text
POST /v1/calls
```

Request fields may include:

```text
recipient_id
conversation_id (optional)
client_context.app_version (optional diagnostic)
```

The client must not submit:

- price or host rate;
- billable duration;
- wallet balance;
- provider secret or room credential;
- claimed current time;
- moderation decision; or
- arbitrary provider room ID.

The response contains the server-created `call_id`, current state, expiry, safe
participant projections, and server time. If a duplicate idempotency key is
replayed, return the original request result or current pending state.

### 3.3 Request expiry

Every requested call has a server-defined expiration time. Expiry is processed
by a durable job and may also be applied when a participant queries the call.

```text
requested -> expired
```

The expiration window is a product decision. It must be short enough to avoid
stale invitations and long enough for normal notification/network delay.

### 3.4 Request abuse controls

The service must limit:

- requests per initiator and recipient;
- repeated requests after rejection/expiry;
- concurrent pending invitations;
- calls to blocked, restricted, or unavailable targets;
- token issuance attempts;
- repeated accept/reject/cancel transitions; and
- suspicious cross-account or self-dealing patterns.

Rate limits must return safe errors and must not reveal hidden fraud thresholds.

---

## 4. Application call lifecycle

### 4.1 Required states

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

The production implementation may add explicit `ending`, `reconciliation`, or
`disputed` projections, but it must not overload a single status to mean both
provider connectivity and financial settlement.

### 4.2 State transition rules

Every transition records:

- `call_id`;
- prior and new application state;
- actor or verified provider source;
- server UTC timestamp;
- idempotency key or provider event ID;
- policy/rate version where relevant;
- provider reference where necessary; and
- safe reason/failure code.

Transitions are server-authorized and append an immutable `CallEvent`. The client
cannot force a transition by changing local UI state.

### 4.3 Transition matrix

| Current | Command/event | Allowed result |
| --- | --- | --- |
| `requested` | Recipient accepts | `accepted` |
| `requested` | Recipient rejects | `rejected` |
| `requested` | Initiator cancels | `canceled` |
| `requested` | Expiry job | `expired` |
| `accepted` | Authorized participant requests token | `connecting` or token-pending projection |
| `accepted` | Cancel before connection, if policy allows | `canceled` or `ended` |
| `connecting` | Verified media connection | `connected` |
| `connecting` | Timeout/provider failure | `failed` or `ended` |
| `connected` | Verified temporary loss | `reconnecting` |
| `reconnecting` | Verified recovery within grace | `connected` |
| `reconnecting` | Grace expiry/provider failure | `failed` or `ended` |
| `connected` | Participant/system ends | `ended` |
| Any nonterminal | Suspension/block/revocation | Safe restricted/ended path |

Invalid transitions return `CALL_STATE_INVALID` and the current safe state.

### 4.4 Terminal states

Terminal outcome values should distinguish:

```text
rejected
expired
canceled
failed
ended
blocked
suspended
provider_unavailable
reconciliation_required
```

The terminal call state is not automatically the final financial state. A call
may be `ended` while settlement is `pending` or `reconciliation_required`.

---

## 5. Acceptance, rejection, and participant behavior

### 5.1 Accept

`POST /v1/calls/{call_id}/accept` requires:

- authenticated recipient/eligible host;
- current call state `requested`;
- no block, suspension, deletion, or safety restriction;
- current availability and concurrency eligibility;
- any required entitlement or balance check;
- idempotency key; and
- server transaction/audit record.

Accepting does not mean media is connected or billing has started. It creates an
application authorization to proceed to connection.

### 5.2 Reject

`POST /v1/calls/{call_id}/reject`:

- is available only to the recipient while `requested`;
- records a safe reason category if the product allows one;
- does not disclose private rejection notes to the initiator;
- does not charge or pay for unconnected time; and
- is idempotent for repeated identical commands.

### 5.3 Cancel

`POST /v1/calls/{call_id}/cancel` is available to the initiator while policy
allows cancellation. Cancellation after connection may be represented as end,
not cancellation, so call history remains accurate.

### 5.4 Notification behavior

Call notifications must:

- contain minimal lock-screen content;
- expire with the call request;
- use authenticated deep-link intents;
- not include provider tokens or private media URLs;
- deduplicate repeated deliveries; and
- stop after rejection, expiry, cancellation, block, deletion, or suspension.

Notification failure must not leave the server believing a call was accepted or
connected.

---

## 6. RTC provider and token rules

### 6.1 Provider adapter boundary

The selected RTC provider is an independent product decision. It must be wrapped
behind an application-owned adapter that maps provider behavior to:

- room/session creation;
- participant join/leave;
- publish/subscribe permissions;
- connection and quality events;
- temporary disconnect and reconnect;
- provider error categories;
- token issuance and expiration; and
- verified callbacks.

Provider SDK types and raw payloads must not become the public API or domain
model. Provider credentials remain server-side.

### 6.2 Token issuance

`POST /v1/calls/{call_id}/rtc-token` requires:

- authenticated call participant;
- current account and call status;
- valid participant role;
- no block, suspension, deletion, or revocation;
- provider availability;
- token request idempotency handling; and
- a short expiration window.

The token/grant must be scoped to:

- one environment;
- one application call;
- one provider room/session;
- one participant identity;
- one publish/subscribe role; and
- one expiration period.

It must not grant access to another call, room, participant, or provider project.

Record an `RtcGrantAudit` entry containing safe metadata such as participant,
call, role, issue time, expiry, provider adapter, result, and request ID. Never
store token plaintext in normal domain data, logs, analytics, or support notes.

### 6.3 Token refresh and revocation

Token refresh is a new server authorization check, not a client-side extension.
The server may deny refresh when:

- the call ended or failed;
- the account is blocked, suspended, deleted, or restricted;
- the participant left or lost eligibility;
- the provider is disabled;
- a safety action requires termination; or
- billing/spending controls stop the call.

Provider revocation may be eventual. During the gap, the application call state
must be authoritative and the client must stop capture when instructed.

### 6.4 Provider callbacks

Callbacks are accepted only after signature, timestamp, audience, event ID, and
schema verification. Events are deduplicated and mapped to append-only
`CallEvent` records. A callback cannot directly post a ledger entry or bypass
call eligibility.

---

## 7. Device permissions and media resources

### 7.1 Permission education

Before requesting camera or microphone permission where practical, the client
explains:

- which feature needs the permission;
- what happens if the user denies it;
- whether a video-off or audio-only fallback exists; and
- how to retry or open system settings after permanent denial.

The explanation must be independent copy, accessible, localized, and consistent
with actual behavior.

### 7.2 Permission states

Model device permission separately from call state:

```text
unknown -> requested -> granted
requested -> denied
denied -> settings_required
granted -> revoked
granted -> unavailable_hardware
```

The client must not mark the call `connected` merely because a permission was
granted. The backend/provider must still establish the authorized call state.

### 7.3 Capture and route controls

The client must show accurate state for:

- camera on/off;
- microphone muted/unmuted;
- speaker/earpiece/Bluetooth route where approved;
- connection/reconnect state;
- permission state; and
- recording state if recording is ever approved.

Rapid toggles must be serialized or reconciled so UI state does not claim a
different state from the device/provider. Capture must stop when:

- the call ends or fails;
- the server revokes authorization;
- the account is suspended/deleted;
- the user leaves the call;
- the app enters a disallowed background state; or
- required hardware/permission becomes unavailable.

### 7.4 Missing hardware and denial fallback

If camera/microphone hardware or permission is unavailable:

- show a user-readable state;
- preserve safe call behavior where policy allows audio-only or video-off;
- do not silently retry permission prompts;
- offer a settings path for permanent denial; and
- never claim media is active when it is not.

---

## 8. Connection, reconnect, and failure rules

### 8.1 Connection states

The application must distinguish:

```text
not_started
connecting
connected
reconnecting
degraded
failed
ended
```

Provider quality metrics are advisory. The server uses verified provider events,
server timestamps, and approved heartbeats/evidence to reconcile state.

### 8.2 Reconnect grace period

The reconnect grace policy is unresolved and must be approved before billing.
It must define:

- when the grace timer begins;
- whether the call remains authorized during grace;
- whether time is billable during grace;
- maximum grace duration;
- behavior if only one participant reconnects;
- notification and user copy;
- provider token refresh behavior; and
- terminal state after grace expires.

Until approved, use the safe development rule: no real money is moved and a
reconnect does not extend a demo call indefinitely.

### 8.3 Network and provider failures

| Failure | User state | Server action |
| --- | --- | --- |
| Device offline before connect | Retryable connection state | Keep request/accept state; do not start billing |
| Token expired before join | Recoverable token error | Recheck eligibility and issue a new scoped token if allowed |
| Provider unavailable before connect | Provider unavailable | Do not issue invalid token; expire/fail safely |
| Temporary media loss | Reconnecting | Track event and grace policy; do not duplicate session |
| Grace expiry | Failed/ended | Stop authorization and begin reconciliation |
| One participant leaves | End/reconcile according to policy | Record verified leave and stop/continue meter per approved rule |
| App process killed | Pending/recoverable or ended | Query authoritative call; do not trust local timer |
| Account blocked/suspended | Restricted/ended | Revoke future access and stop capture |

The client must provide retry, end, support, or settings actions rather than an
infinite spinner.

### 8.4 Duplicate and stale events

Provider and client events may arrive out of order. The service must:

- deduplicate by idempotency/event key;
- validate transition against current server state;
- retain conflicting evidence for reconciliation;
- avoid moving backward from a terminal state without an approved correction;
- not charge from one stale callback; and
- expose a safe pending/reconciliation state to users and support.

---

## 9. Billing and settlement coordination

Billing rules are defined in `docs/PAYMENTS_AND_EARNINGS.md`. This document
defines the call evidence and state boundaries only.

### 9.1 Billable state

Keep billable state separate from application and provider state:

```text
not_started
eligible_pending_connection
billable
paused_or_grace
stopped_pending_settlement
settled
reconciliation_required
not_billable
```

The client timer is display-only. It cannot set billable duration, price,
currency, host rate, or settlement result.

### 9.2 Meter evidence

If billing is enabled, the server may combine:

- application state transitions;
- verified RTC provider join/leave events;
- server-observed heartbeats or connection evidence where approved;
- participant identity and role;
- policy/rate version;
- reconnect grace rules; and
- end/timeout/block/suspension events.

Each meter sample must record source, server time, call ID, participant scope,
provider reference if needed, and integrity/idempotency reference. Do not record
more media or device detail than the billing/safety purpose requires.

### 9.3 Start and stop decisions

The following decisions are unresolved and must not be hidden in client code:

- Does billing start at acceptance, token issuance, media connection, or a
  server-confirmed connected state?
- Is audio-only or one-sided media billable?
- Is reconnect grace free, partially billable, or fully billable?
- Does billing stop at hang-up, verified disconnect, timeout, app close, block,
  suspension, or grace expiry?
- What happens when the server/provider evidence conflicts?
- What maximum duration and spending limits apply?

### 9.4 Settlement invariant

A call can produce at most one final settlement transaction. Corrections use a
compensating ledger entry. A failed or pending provider callback must not create
a second charge or earning.

---

## 10. Safety, privacy, and user controls during calls

### 10.1 In-call controls

Where supported, users must have reachable controls to:

- mute or unmute;
- turn camera on/off;
- end the call;
- block/report the participant;
- access help/support; and
- understand connection, permission, and billing state.

The block/report path must not expose reporter identity or force the user to
remain in a harmful call.

### 10.2 Block, suspension, and deletion

When a participant is blocked, suspended, deleted, or becomes ineligible:

- new call requests and token issuance are denied;
- active-call behavior follows the approved safety rule;
- media capture stops when authorization is revoked;
- settlement enters a safe pending/reconciliation path if necessary;
- call history uses an authorized redacted projection; and
- required safety/financial evidence is retained under policy.

### 10.3 Recording and media retention

Recording is disabled by default. Before enabling it, approve:

- participant consent and regional rules;
- visible recording indicator;
- storage and encryption;
- access and download policy;
- retention and deletion;
- moderation and legal hold;
- user notifications; and
- device/background behavior.

No call may be recorded silently. No UI may imply recording exists when it is
not implemented and tested.

### 10.4 Call metadata privacy

Call metadata is private/sensitive. Restrict access to participants and
approved safety, support, finance, or operations cases. Do not expose:

- provider room names or credentials;
- another participant's private device details;
- hidden quality/fraud/risk signals;
- precise location unless separately approved; or
- private settlement inputs outside the authorized projection.

---

## 11. APIs and events

### 11.1 Application endpoints

The proposed API routes are:

```text
POST /v1/calls
GET  /v1/calls
GET  /v1/calls/{call_id}
POST /v1/calls/{call_id}/accept
POST /v1/calls/{call_id}/reject
POST /v1/calls/{call_id}/cancel
POST /v1/calls/{call_id}/end
POST /v1/calls/{call_id}/rtc-token
GET  /v1/calls/{call_id}/settlement       # gated
POST /v1/calls/{call_id}/report
```

Effectful routes require an idempotency key. Protected reads require participant
authorization. The full request/response/error contract belongs in
`docs/API_CONTRACT.md`.

### 11.2 Call events

Internal events may include:

```text
call.requested
call.accepted
call.rejected
call.canceled
call.expired
call.connecting
call.connected
call.reconnecting
call.failed
call.ended
call.token_issued
call.authorization_revoked
call.settlement_pending
call.settlement_completed
call.reconciliation_required
```

Each event includes event ID, schema version, call ID, source, server timestamp,
prior/new state where applicable, idempotency/provider reference, and safe
metadata. Events do not contain token plaintext or private media payloads.

---

## 12. Testing and release evidence

### 12.1 Server/integration tests

Cover:

- call eligibility for active, blocked, suspended, deleted, restricted, and
  deletion-pending accounts;
- duplicate request/accept/reject/cancel/end/token commands;
- request expiry and scheduled-job retry;
- participant and role authorization with two accounts;
- token scope, audience, expiration, revocation, and wrong-call rejection;
- signature verification, webhook replay, duplicate, delayed, and reordered
  provider events;
- all state transitions and invalid transitions;
- block/suspension/deletion effects on active calls;
- reconnect grace and provider outage behavior;
- billable-state evidence and one-settlement invariant;
- insufficient balance/spending limit behavior when economy is enabled;
- report/block privacy and audit records; and
- call-history projection and retention/deletion behavior.

### 12.2 Device tests

On supported Android devices, test:

- camera/microphone education and permission denial;
- permanent denial/settings path;
- missing camera/microphone hardware;
- camera/mic toggles and audio-route changes;
- lock, background, foreground, process death, and app restart;
- network loss, Wi-Fi/mobile transition, and reconnect;
- token expiry and provider outage;
- end-call resource release;
- block/report during and after a call;
- long names, large text, translations, contrast, and screen reader labels;
- notification/deep-link privacy; and
- billing display versus server settlement when sandboxed.

If the device/provider is unavailable, mark these checks blocked/pending rather
than claiming RTC readiness from a compile result.

### 12.3 Production call release gate

- [ ] Approved independent RTC provider and data-processing review.
- [ ] Server-issued short-lived scoped tokens.
- [ ] Application/provider/billable state separation implemented.
- [ ] Reconnect, timeout, provider outage, and token revocation tested.
- [ ] Camera/microphone permission and fallback UX tested.
- [ ] Capture stops after end, revoke, block, suspension, and process changes.
- [ ] Recording disabled or separately approved and tested.
- [ ] Call reports/blocks and safety escalation work.
- [ ] Call billing and settlement rules approved and server-tested before money.
- [ ] Call metadata retention and deletion documented.
- [ ] Monitoring, support, incident, and provider runbooks available.

---

## 13. Open decisions

1. RTC provider, deployment region, provider data retention, and failover.
2. Eligibility rules for users, hosts, age, geography, and concurrency.
3. Call request expiration and notification behavior.
4. Whether calls are audio-only, video-first, or both.
5. Exact reconnect grace window and billable treatment.
6. Billable start/stop events, maximum duration, and spending limits.
7. One-sided media and poor-quality call billing policy.
8. Token lifetime, refresh, provider callback, and revocation details.
9. Recording, screenshots, background calls, effects, and audio-route policy.
10. Call metadata, evidence, settlement, and deletion retention periods.
11. In-call block/report behavior and emergency escalation.
12. Support, refund, chargeback, and settlement dispute handling.

---

## 14. Approval checklist

- [ ] Product owner approved call outcomes, roles, limits, and user copy.
- [ ] Security/privacy approved token, media, permission, logging, and retention controls.
- [ ] Safety approved in-call report/block, suspension, and emergency behavior.
- [ ] Finance approved billing evidence and settlement handoff.
- [ ] RTC provider adapter and webhook verification are implemented.
- [ ] State-transition and idempotency tests pass.
- [ ] Two-account authorization tests pass.
- [ ] Device permission, reconnect, process, and resource-release tests pass.
- [ ] No provider secret or target-specific identifier exists in the APK or repository.
- [ ] Production billing, recording, and host earnings remain disabled until their gates pass.
