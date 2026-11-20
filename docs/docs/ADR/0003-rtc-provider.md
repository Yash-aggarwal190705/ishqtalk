# ADR 0003: Provider-Neutral RTC Adapter and Server-Issued Tokens

**Status:** Proposed / live-call gated  
**Last updated:** 2026-10-26  
**Owner:** Engineering, RTC, security, privacy, safety, and operations owners to be assigned  
**Decision type:** Media/provider integration  
**Related documents:** `docs/ARCHITECTURE.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/API_CONTRACT.md`, `docs/SECURITY_AND_PRIVACY.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/COST_MODEL.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`,
`docs/CLEAN_ROOM_RULES.md`

## 1. Context

The product may support private one-to-one video calls. The supplied target
artifact statically registers media/RTC capabilities, but that does not prove a
reachable feature, provider choice, room model, token format, pricing, or
settlement behavior. The independent product must not select or copy a target
provider arrangement from plugin registration.

RTC tokens, room references, permissions, reconnects, provider callbacks, and
billable state cross security, privacy, safety, operations, and financial
boundaries. The mobile client cannot safely mint a provider token or decide
whether a call is eligible or billable.

## 2. Decision

Adopt an application-owned RTC adapter boundary with a provider-neutral domain
model and server-issued short-lived scoped tokens.

1. The application owns call eligibility, lifecycle, participants, safety,
   billing evidence, settlement, and history.
2. An RTC adapter owns provider room/session creation, participant grants,
   provider callbacks, media connection state, and provider-specific errors.
3. The server issues a short-lived token scoped to one approved call, room, and
   participant role. Provider API keys and secrets remain server-side.
4. Room references and provider identifiers are opaque and are not public domain
   identifiers unless needed for safe reconciliation.
5. Fake adapters are required for unit and integration tests; a sandbox provider
   is required before a live-call release.
6. Provider callbacks are untrusted until signature, event identity, timestamp,
   and audience are verified.
7. Application call state and provider media state remain separate. A provider
   callback or client timer alone cannot settle a charge or host earning.
8. Permission denial, unavailable hardware, token expiry, provider outage,
   reconnect, app death, and block/safety actions must map to recoverable
   application states.

No specific commercial RTC provider is approved by this ADR. A provider choice
requires a follow-up decision covering security, privacy, cost, regions,
quality, SDK licensing, Android support, data handling, callbacks, recovery,
and support.

## 3. Application state

The initial state machine is:

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

The application must also track permission state, provider connection state,
billable state, safety restrictions, and settlement state explicitly. UI button
labels are not state authority.

## 4. Alternatives considered

### 4.1 Copy the target's bundled provider or native channel

Rejected. Static registration is not provider approval or runtime proof, and
copying target-specific channels, room identifiers, credentials, or setup data
violates the clean-room boundary.

### 4.2 Mint RTC tokens in the Android client

Rejected. Provider secrets would be recoverable and token scope could be forged.

### 4.3 Let provider callbacks determine billing

Rejected. Provider callbacks are delayed/reordered/untrusted and do not encode
the application's policy, user entitlement, host earnings, or settlement rules.

### 4.4 Build live RTC before the call state and safety rules

Deferred. A visible call screen without eligibility, permissions, reconnect,
report/block, billing, and provider-failure rules is not a production feature.

## 5. Required adapter interface shape

The exact programming language is open, but the adapter must support concepts
equivalent to:

```text
create_room(call_id, participant_scope)
issue_participant_grant(call_id, participant_id, role, expires_at)
revoke_participant_grant(call_id, participant_id, reason)
end_room(call_id, reason)
verify_callback(raw_body, signature, headers)
map_provider_event(event) -> application_event
health_check()
```

Every operation must define timeout, retry, idempotency, logging redaction, and
provider-error mapping. The adapter must not post ledger entries or alter
moderation decisions directly.

## 6. Consequences

### Positive

- Provider replacement remains possible.
- Local and development tests can run without real media credentials.
- Server authority protects tokens, eligibility, privacy, and settlement.
- Provider failures map to user-safe states and operational runbooks.
- Call data and financial evidence remain application-owned.

### Negative

- Adapter, sandbox, fake provider, callback verification, and device testing add
  implementation work.
- Provider quality and pricing cannot be claimed until a provider is selected
  and measured.
- Device/network testing is required for permissions, reconnects, audio routes,
  and app lifecycle behavior.

## 7. Required tests and release gates

- server authorization for both call participants;
- token scope, audience, expiry, replay, and revocation;
- denied/revoked camera and microphone permissions;
- missing hardware and audio route behavior;
- request/accept/reject/cancel/expire/end transitions;
- network loss, reconnect grace, token expiry, provider timeout, and outage;
- duplicate/delayed/out-of-order provider callbacks;
- block/report during and before a call;
- app background/process death/restart;
- server-confirmed billable start/stop evidence;
- no duplicate settlement after retries; and
- redacted logs and safe support evidence.

Live calls remain disabled until provider, privacy, security, safety, finance,
operations, cost, and device-test approval is recorded.

## 8. Open decisions

- RTC provider and supported regions/data handling.
- Provider SDK/license and Android API/device matrix.
- Room topology, participant roles, token claims, and callback contract.
- Reconnect grace, billable start/stop, recording policy, and call limits.
- TURN/network requirements, quality thresholds, and cost alerts.
- Support/debug evidence that can be accessed without recording or exposing
  private media.

## 9. Approval checklist

- [ ] Provider comparison and privacy/security review complete.
- [ ] Adapter interface and fake implementation are tested.
- [ ] Server token service is implemented; no client secret exists.
- [ ] Call state, permission, safety, reconnect, and settlement rules agree.
- [ ] Device/network matrix and provider outage tests pass.
- [ ] Cost and operational alerts are ready.
- [ ] `docs/VIDEO_CALL_RULES.md` and `docs/RELEASE_CHECKLIST.md` match.
