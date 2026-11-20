# Product Requirements — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Product owner to be assigned  
**Last updated:** 2026-10-25  
**Product name:** To be chosen; do not use the target product name or identity  
**Document type:** Clean-room product requirements specification  
**Source of truth for:** Product scope, user outcomes, acceptance criteria, and
release requirements  
**Related documents:** `AGENTS.md`, `docs/ARCHITECTURE.md`,
`docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `reports/chato-recon.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/PAYMENTS_AND_EARNINGS.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/DISASTER_RECOVERY.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`,
`reports/chato-deeper-static-analysis.md`,
`reports/chato-static-evidence.json`, `reports/chato-plugin-registration.csv`,
`reports/chato-screen-inventory.csv`, `reports/chato-interaction-map.csv`,
`reports/chato-permissions.csv`, `reports/chato-install-run-test-plan.md`

---

## 1. Purpose and clean-room boundary

This document defines an **independent social discovery, messaging, and paid
one-to-one video-call product** based on generic functional patterns identified
through authorized static analysis of a locally supplied Android artifact.

The product may provide similar user outcomes, such as discovering people,
following profiles, exchanging messages, requesting a private video call,
buying virtual credits, and reporting unsafe behavior. It must use independent
product decisions and implementation details.

This document does **not** authorize or require copying:

- the target's product name, logo, colors, typography, layout, or visual
  identity;
- exact screens, wording, icons, illustrations, animations, screenshots,
  videos, audio, or other media;
- target source code, decompiled logic, private API contracts, endpoint names,
  credentials, tokens, user data, ranking rules, or moderation rules; or
- target prices, product IDs, provider configuration, or legal policies unless
  separately approved as an independent business decision.

The implementation must use fresh branding, fresh copy, fresh assets, new
identifiers, independent data, and approved providers.

### Evidence labels used in this document

- **Observed/static:** directly present in the authorized artifact or generated
  evidence files; not runtime verified.
- **Inferred:** a reasonable product hypothesis derived from static evidence or
  generic user-flow expectations.
- **Proposed:** an independent product decision suggested for this application,
  pending approval or validation.
- **Required:** a release condition for the independent application.
- **Unknown:** not established and must not be silently invented.

The supplied artifact was not successfully executed in the current environment.
Therefore, target-specific statements in this document are evidence-backed
hypotheses, not claims about verified runtime behavior.

### 1.1 Evidence update — October 25, 2026

The deeper static pass adds the following bounded facts to the clean-room
record:

- the supplied Android namespace is a thin Flutter host; its recovered
  `Application` class is empty and its activity contains no recoverable product
  route tree or business state machine;
- 53 Flutter Android plugins are registered, covering capabilities such as
  messaging, RTC/media, authentication, billing, push, storage, permissions,
  and telemetry; registration is capability evidence, not proof that every
  feature is reachable;
- the host contains a target-specific device channel and a static advertising-ID
  lookup path; this is a privacy-relevant observation, not a requirement for the
  independent product;
- the target base APK still lacks the native Flutter payload and matching
  splits, so exact UI, backend behavior, prices, ranking, moderation, and call
  settlement remain unknown; and
- runtime testing remains blocked in this environment: the x86_64 AVD requires
  unavailable KVM acceleration, while an arm64 AVD cannot run on this x86_64
  host.

These findings refine the independent product scope but do not select the
target's providers, telemetry model, package name, deep-link host, channel names,
copy, assets, or backend. The first implementation must use independent
providers or fakes, an allowlisted privacy-safe analytics design, and fresh
identifiers.

---

## 2. Product summary

### 2.1 Product vision

Create a safe, understandable social application where people can discover
interesting profiles, build lightweight relationships, communicate through
messages, and request private one-to-one video conversations with eligible
hosts. The product should make identity, consent, pricing, permissions,
moderation, and transaction status clear at every important step.

### 2.2 Primary user outcome

A signed-in user can discover an available person, review their profile, send a
message or follow them, request a private video call when eligible, see the
price and consent state before any billable activity begins, complete or end a
call safely, and receive a transparent history of the interaction.

### 2.3 Host outcome

An approved host can create and maintain a public profile, control availability,
accept eligible calls, see the state of active and completed calls, view
pending and available earnings, and access reporting and support tools without
being promised payment that has not been settled by the server.

### 2.4 Business model assumption

The current planning assumption supplied by the product owner is:

```text
User charge assumption:    ₹15 per billable minute = 1,500 paise
Host earning assumption:    ₹6 per billable minute =   600 paise
Pre-cost contribution:      ₹9 per billable minute =   900 paise
```

These values are **draft business inputs**, not a production promise. Before
real-money launch, the product owner and relevant legal, tax, payments, fraud,
and operations reviewers must approve:

- the billable unit and rounding rule;
- when billing starts and stops;
- taxes, store/payment fees, refunds, chargebacks, and currency treatment;
- host eligibility, verification, payout, withholding, and dispute rules; and
- the legal relationship between the platform and hosts.

The first implementation must use a clearly labelled mock or sandbox economy.

---

## 3. Goals, non-goals, and success criteria

### 3.1 Goals

#### G-001 — Safe discovery

Users can browse independent profile cards, apply approved filters, open a
profile, and understand whether the profile is available, verified, blocked,
deleted, or unavailable.

#### G-002 — Meaningful lightweight relationships

Users can follow or unfollow profiles, see relationship state, and avoid
duplicate or unauthorized relationship actions.

#### G-003 — Reliable messaging

Users can send text and approved attachments, see delivery state, retry safe
failures, and report or block from a conversation without exposing private
reporter information.

#### G-004 — Consent-based private calls

Users and hosts can request, accept, reject, cancel, reconnect, and end a
one-to-one video call with explicit permission handling and clear state.

#### G-005 — Transparent economy

Users can see balances, prices, purchases, entitlements, and transaction
history. Hosts can see earnings state. The server remains authoritative for all
money and entitlement decisions.

#### G-006 — Operational safety

The product has usable reporting, blocking, moderation, account deletion,
support, audit, incident, and recovery paths before production launch.

#### G-007 — Independent product identity

The application is visually and technically independent from the analyzed
artifact while preserving only generic functional outcomes that are approved.

### 3.2 Non-goals for the first production milestone

The following are not part of the first milestone unless separately approved:

- public group video rooms or multi-host broadcasts;
- anonymous calls without abuse controls and account accountability;
- real-money host payouts before identity, tax, fraud, and reconciliation
  controls exist;
- unreviewed recording, downloading, or redistribution of private calls;
- unsupported claims about beauty filters, recording, background calls,
  Bluetooth routing, or translation before device testing;
- copying the analyzed application's exact brand, screens, copy, assets, or
  private integrations;
- a global recommendation algorithm before safety, quality, and consent metrics
  are available; and
- a production claim for the existing local-first Orbitra MVP.

### 3.3 Proposed measurable success criteria

These are draft targets for product review, not measured results:

| Area | Proposed initial target | Measurement condition |
| --- | --- | --- |
| First-run completion | At least 70% of eligible users who begin onboarding reach the authenticated shell | Staging cohort, excluding provider outage and duplicate test accounts |
| Discovery response | P95 feed response under 500 ms excluding media download | Staging/production telemetry with privacy-safe request metrics |
| Message delivery | 95% of accepted online messages visible to the recipient within 5 seconds | Exclude recipient offline periods and provider outage windows |
| Call setup | 90% of eligible calls reach a connected state within 15 seconds | Supported device/network matrix; server and RTC timestamps |
| Crash safety | Crash-free sessions target of at least 99.5% before broad rollout | Crash provider data, separate from debug builds |
| Report handling | All valid reports receive an acknowledgement and case ID | API and moderation audit records |
| Financial reconciliation | Daily ledger, purchase, refund, and host-earning totals reconcile | Automated reconciliation job plus manual exception queue |

Success criteria must be revised when real usage, cost, safety, and support data
are available.

---

## 4. Users, roles, and permissions

### 4.1 User/viewer

Can:

- create and manage an account;
- browse eligible discovery surfaces;
- view public profiles and approved availability information;
- follow or unfollow profiles;
- send and receive permitted messages;
- request, accept, reject, cancel, and end eligible calls;
- purchase or restore approved virtual goods in supported environments;
- view their own balances, entitlements, transactions, and call history;
- report or block another account;
- manage consent, permissions, notifications, language, and account deletion.

Cannot:

- change server-calculated prices, balances, call duration, host rates, or
  entitlements;
- access another person's private messages, reports, payment payloads, or
  moderation evidence; or
- access host or moderator tools without the corresponding role.

### 4.2 Host/creator

Can, after approval:

- create and edit a public profile;
- upload approved profile media;
- configure availability and call eligibility;
- accept or reject eligible call requests;
- participate in calls and use supported media controls;
- view call history and earnings states;
- report users and request support;
- see clear explanations of pending, available, held, reversed, paid, or
  disputed earnings.

Cannot:

- self-approve identity or payout eligibility;
- alter the host earning rate from the client;
- mark an unsettled call as paid;
- access private user payment credentials or unrelated moderation cases; or
- use automated or collusive behavior to manufacture billable minutes.

### 4.3 Moderator

Can:

- review assigned safety cases;
- view only the evidence necessary for the case;
- apply documented temporary or permanent enforcement actions;
- record reason, actor, timestamp, target, and policy version;
- notify the affected account where policy requires; and
- escalate urgent safety cases.

Cannot silently edit the financial ledger or access unrelated private data.

### 4.4 Support/finance operator

Can:

- investigate approved account, refund, purchase, or payout cases;
- view safe transaction and reconciliation information;
- issue approved compensating actions through audited workflows; and
- communicate support outcomes.

Cannot rewrite posted ledger entries, approve their own sensitive actions, or
change moderation decisions without the appropriate role.

### 4.5 System administrator

Can manage infrastructure and access through least privilege, with audited
changes and emergency procedures. Infrastructure access does not automatically
grant access to private messages, moderation evidence, or financial data.

---

## 5. Scope by delivery milestone

### Milestone 0 — Product foundation and local prototype

Purpose: prove the user flow without pretending that providers or payments are
live.

Required capabilities:

- original onboarding and authentication mock or local test identity;
- seeded profiles and availability states;
- discovery, filters, profile detail, follow, and match demo;
- local conversation and message state;
- simulated incoming/outgoing/active call states;
- explicit permission education and denial states;
- mock credits and clearly labelled demo prices;
- report/block UI with local acknowledgement;
- privacy-safe telemetry defaults: no advertising-ID collection or device
  fingerprinting in the local prototype, and only allowlisted redacted events;
- accessibility labels and deterministic test data.

Not production claims:

- no live RTC;
- no real account authentication;
- no real purchases or payouts;
- no global discovery;
- no production moderation backend.

### Milestone 1 — Development backend and internal testing

Required capabilities:

- authenticated development accounts;
- server-owned profiles, relationships, conversations, and call sessions;
- authorization and row-level ownership tests;
- moderated text messaging and attachment limits;
- server-issued RTC token seam using a sandbox provider;
- server-side call state and event logging;
- fake purchase, refund, and host-settlement events;
- moderation case queue and audit trail;
- push notification development channel;
- metrics and error reporting with redaction.

### Milestone 2 — Closed beta

Required capabilities:

- staging environment isolated from production;
- approved authentication providers;
- tested RTC calls on supported devices;
- account deletion and data-retention workflow;
- reports, blocks, moderator review, and appeals/support path;
- store sandbox purchase validation;
- reconciliation and duplicate-webhook tests;
- host verification and non-production earnings flow;
- crash, latency, RTC, billing, and moderation dashboards.

### Milestone 3 — Controlled production rollout

Required before enabling real money or broad discovery:

- approved legal, tax, store, privacy, safety, and support documentation;
- production secrets in an approved secret manager;
- server-authoritative ledger and settlement;
- validated purchase, refund, chargeback, and payout workflows;
- host eligibility, payout holds, fraud controls, and support escalation;
- tested backups, restore, migration recovery, and rollback/forward-fix plan;
- release monitoring and spending/payout limits;
- gradual rollout with a documented stop condition.

---

## 6. Core user journeys

The following journeys are derived from the functional evidence and rewritten as
independent product requirements. Each journey must include the required happy,
empty, invalid, unauthorized, offline, provider-failure, and recovery states.

### J-001 — Startup, consent, and onboarding

**Actor:** New or returning user  
**Entry:** App launch, notification, or deep link  
**Outcome:** User reaches the correct authenticated or signed-out destination.

#### Main flow

1. App shows an original startup state while local configuration is loaded.
2. App determines whether the user has accepted current policies and whether a
   valid session exists.
3. New users see a concise value explanation and consent checkpoints.
4. User chooses to continue, sign in, or leave.
5. The app routes to authentication or the main shell.
6. Returning users with a valid session reach the intended destination without
   being asked to re-enter credentials unnecessarily.

#### Required failure states

- slow or failed initialization;
- offline launch;
- expired session;
- policy version changed;
- malformed or unauthorized deep link;
- corrupted local cache;
- user cancels onboarding; and
- back navigation without losing safe local state.

#### Acceptance criteria

- The app never blocks indefinitely on startup.
- A retry action is available after recoverable initialization failure.
- Consent is versioned and recorded server-side when required.
- The app does not request camera, microphone, or unrelated permissions during
  onboarding without a clear explanation and approved need.
- A signed-out user cannot reach protected data through a deep link.

### J-002 — Authentication and account recovery

**Actor:** User  
**Entry:** Authentication chooser  
**Outcome:** A verified, authorized session is created or the user receives a
safe recovery path.

#### Supported entry points for the first release

- Email-based account creation and sign-in.
- One or more approved social providers after privacy and provider review.
- Provider cancellation and unavailable-provider handling.

The exact provider list is a product decision. Static evidence suggested email,
Facebook, Google, and Apple entry points, but this does not require the
independent product to use all of them.

#### Acceptance criteria

- Invalid input is rejected before submission where possible.
- Server responses use stable, user-safe error codes.
- Rate limits and account lockout/recovery protections are enforced server-side.
- Provider cancellation returns the user to a recoverable state.
- Duplicate account linking is handled without creating conflicting identities.
- A successful session is stored securely and can be revoked.
- Logout clears protected local state and invalidates server sessions according
  to the security design.

### J-003 — Discovery and filtering

**Actor:** User  
**Entry:** Main discovery shell  
**Outcome:** User can browse eligible profiles and refine results.

#### Main flow

1. User opens the discovery surface.
2. App loads profile cards from the approved backend or clearly labelled seed
   data in prototype mode.
3. User can refresh, paginate, or open a profile.
4. User can apply approved filters such as country, language, gender/identity,
   availability, interests, or verification state.
5. App shows active filters and allows reset.

#### Requirements

- Feed results must be cursor-paginated rather than unbounded offset lists.
- Results must exclude blocked, deleted, suspended, and privacy-restricted
  accounts.
- Empty results explain why the list is empty and offer retry or filter reset.
- Loading states must not look like real profiles.
- Ranking criteria must be documented independently and must not be inferred as
  the target's ranking algorithm.
- The app must not expose precise location unless separately approved and
  necessary.

#### Acceptance criteria

- A user can open a profile from a result and return without losing filter
  state unless reset is intentional.
- Refresh and pagination do not duplicate cards.
- A blocked user cannot reappear through stale cached data after refresh.
- A server or network error leaves the previous safe state visible with a retry
  action where possible.

### J-004 — Profile detail, follow, and availability

**Actor:** User or host  
**Entry:** Discovery card, match result, message, or deep link  
**Outcome:** User understands the profile and can take an authorized action.

#### Profile content

The independent profile may include:

- display name and avatar;
- approved photos or media;
- biography and tags;
- language/country or broad region where consented;
- verification state;
- availability state;
- call eligibility and price information where applicable;
- follow state;
- message and call actions;
- report and block actions.

Do not copy the target's profile fields, exact labels, or visual arrangement.

#### Acceptance criteria

- Profile fields are validated and sanitized.
- Private or deleted profiles show a safe unavailable state.
- Follow/unfollow is idempotent and reflects server state.
- Duplicate taps do not create duplicate relationships.
- A user cannot call a blocked, deleted, suspended, or unavailable account.
- The profile never promises host availability or earnings that the server has
  not confirmed.

### J-005 — Matching

**Actor:** User  
**Entry:** Main shell or discovery action  
**Outcome:** User receives an eligible candidate or a clear no-result state.

#### Main flow

1. User opens the matching surface.
2. App explains any ticket, entitlement, balance, cooldown, or eligibility
   requirement before starting.
3. User selects approved preferences.
4. Server creates a match attempt with an idempotency key.
5. App shows searching, candidate found, candidate unavailable, and completed
   states.
6. User can accept, skip, follow, message, or request a call when permitted.
7. The result is recorded in match history without exposing private ranking
   details.

#### Rules

- Matching must not reveal exact location or sensitive attributes without
  consent and a documented purpose.
- Candidate selection must exclude blocked, deleted, suspended, ineligible, or
  already-conflicting accounts.
- A canceled or timed-out match must not consume more entitlement than the
  approved policy allows.
- A repeated tap or network retry must not create multiple match attempts.
- A candidate can become unavailable between display and action; the server
  must re-check eligibility.

#### Acceptance criteria

- Empty matching results explain the state and offer retry or preference reset.
- The user can cancel a search when the backend supports cancellation.
- Accept/skip decisions are idempotent and produce one final outcome.
- Match history does not expose another user's private safety or payment data.

### J-006 — Conversation list and thread

**Actor:** Signed-in user or host  
**Entry:** Main shell, profile, match result, push notification, or call result
  
**Outcome:** User can read and send permitted messages with safe delivery state.

#### Conversation list requirements

- Show only conversations the authenticated account is authorized to see.
- Show unread state, last-message preview subject to privacy policy, and safe
  participant identity.
- Support cursor pagination and refresh without duplicate rows.
- Handle deleted, blocked, archived, or unavailable participants gracefully.
- Do not use message bodies in normal analytics or logs.

#### Thread requirements

The independent product may support:

- text messages;
- emoji or Unicode text;
- approved image attachments;
- gifts or other virtual items after economy approval;
- call invitations and call-result messages;
- system notices such as blocked, deleted, or unavailable state; and
- optional translation after a separate privacy, cost, and provider review.

#### Message lifecycle

```text
draft -> submitting -> accepted -> delivered -> read
                         |              |
                         v              v
                       failed         expired
                         |
                         v
                        retry
```

The exact lifecycle may include additional server states, but the client must
not show a sent message as delivered until the server/provider state supports
that claim.

#### Acceptance criteria

- Empty messages cannot be submitted.
- Message length, attachment type, size, and rate limits are enforced at the
  server boundary.
- A retry is safe and does not duplicate a message.
- Offline submission either queues under a documented policy or fails clearly;
  it must not imply delivery.
- A blocked participant cannot send new messages unless a documented unblock
  policy allows it.
- Message/report privacy is preserved when a user reports a message.
- Users can delete or hide their own message only under the approved retention
  and moderation policy; deletion must not erase required safety or financial
  records silently.

### J-007 — Incoming call request

**Actor:** Host or eligible recipient  
**Entry:** Signaling event, push notification, or in-app invitation  
**Outcome:** Recipient can understand and accept, reject, or ignore the request.

#### Acceptance criteria

- The recipient sees caller identity, availability, consent context, and any
  applicable price before accepting.
- Accept and reject actions are idempotent.
- A caller who cancels or times out cannot leave a stale ringing state.
- Notification taps route only to a valid, authorized call destination.
- Permission education occurs before camera or microphone access.
- If the recipient is offline, deleted, blocked, suspended, or already in a
  conflicting call, the caller receives a safe outcome.
- Repeated push notifications do not create duplicate call sessions.

### J-008 — Outgoing call request and lobby

**Actor:** User or authorized caller  
**Entry:** Profile, conversation, or match result  
**Outcome:** Caller sees eligibility, consent, and connection status before the
call becomes billable.

#### Main flow

1. User taps the call action.
2. Server checks account, block, availability, entitlement, balance, rate,
   concurrency, and host eligibility.
3. App presents a confirmation state with the independent product's price and
   billing explanation.
4. Caller confirms or cancels.
5. Server creates one call session and sends an invitation.
6. App shows waiting, accepted, rejected, expired, canceled, connecting, and
   failed states.

#### Acceptance criteria

- A call request is not billable merely because the button was tapped.
- The price and billing policy are visible before confirmation.
- Insufficient balance or missing entitlement produces a recoverable purchase
  or support path, not a hidden failure.
- Duplicate requests with the same idempotency key resolve to one call session.
- The client cannot substitute a different recipient, rate, or duration after
  server authorization.

### J-009 — Active one-to-one video call

**Actor:** Connected caller and host  
**Entry:** Accepted call reaches a connected media state  
**Outcome:** Both participants can communicate, understand state, and end or
recover the call safely.

#### Call state machine

```text
requested -> accepted -> connecting -> connected
requested -> rejected | expired | canceled
connecting -> failed | ended
connected -> reconnecting -> connected
connected -> ended
reconnecting -> failed | ended
```

The server call state, RTC provider state, billing state, and UI state are
separate. A provider callback or local lifecycle event must not by itself decide
the final financial settlement.

#### Core controls

The first supported device release should define and test:

- microphone mute/unmute;
- camera enable/disable;
- speaker or approved audio-route selection;
- camera switching where supported;
- connection/reconnecting indicator;
- call timer or billable-duration indicator that matches the approved policy;
- report/block/safety action;
- hang-up/end call;
- permission and hardware status.

Optional controls such as beauty effects, blur, recording, picture-in-picture,
Bluetooth routing, or background calls require separate acceptance criteria and
real-device testing. Static evidence of SDK classes or assets is not sufficient
to ship those claims.

#### Billing boundary

Before production implementation, approve:

- the exact billable start event;
- the exact billable stop event;
- the rounding and reconnect-grace rule;
- the behavior when only one participant has connected media;
- the behavior during network loss, app backgrounding, lock, or process death;
- the maximum session duration and spending limit; and
- the settlement event and reconciliation path.

For the prototype, the call timer and balance must be explicitly simulated.

#### Acceptance criteria

- Camera and microphone are never accessed silently.
- Permission denial gives a user-readable fallback and settings path.
- Rapid control taps do not corrupt state or create duplicate provider calls.
- Network loss shows reconnecting and then either recovery or a clear ended
  state.
- Ending a call stops capture and releases media resources.
- Both participants receive a consistent final call outcome after reconnect or
  delayed provider events.
- A report can be submitted from the call without exposing the reporter.

### J-010 — Call history and post-call state

**Actor:** User or host  
**Entry:** Profile, conversation, account, or call end  
**Outcome:** Participant sees a safe, understandable record of the call.

History may include:

- other participant's public display name or safe deleted-user label;
- call direction;
- requested, accepted, connected, ended, rejected, or failed status;
- server-confirmed connected and ended timestamps;
- billable duration if applicable;
- user charge, host earnings state, and transaction reference where authorized;
- report/support entry point; and
- retry or reconnect outcome.

Financial history must be generated from the authoritative ledger and not from
client timers. Deleted or blocked accounts must not expose data that the user is
no longer authorized to see.

### J-011 — Profile editing and media

**Actor:** User or host  
**Entry:** Account/profile surface  
**Outcome:** Account owner can edit approved profile data and media safely.

#### Requirements

- Validate display name, biography, tags, language, and other fields.
- Use scoped media access and content URIs where supported.
- Enforce file type, size, dimension, and malware/content-safety limits.
- Show upload progress, cancellation, retry, and failure states.
- Confirm destructive media deletion where appropriate.
- Prevent another user from modifying the profile.
- Preserve moderation evidence when a reported asset is removed.
- Do not collect identity documents in the prototype unless a secure approved
  verification flow exists.

### J-012 — Verification and eligibility

Verification is a product and legal decision, not a visual badge exercise.

Potential states:

```text
not_started -> submitted -> under_review -> approved
                                      |-> rejected -> resubmission_allowed
```

Requirements:

- Explain what is being verified and why.
- Collect the minimum data needed.
- Restrict reviewer access and retain an audit trail.
- Prevent self-approval and badge spoofing.
- Define expiration, re-verification, rejection, appeal, and deletion rules.
- Do not show a verification badge as proof of safety, identity, or guaranteed
  behavior beyond the approved policy.

### J-013 — Credits, packages, and subscriptions

**Actor:** User  
**Entry:** Account, call confirmation, message gift, or purchase prompt  
**Outcome:** User understands balance and entitlement and can use approved
virtual goods.

#### Requirements

- Show current server-confirmed balance and last refresh status.
- Explain package contents, price, currency, expiry, and restrictions before
  purchase.
- Distinguish virtual credits, promotional rewards, subscriptions, and host
  earnings.
- Support purchase pending, success, cancellation, failure, restore, delayed
  fulfillment, duplicate event, refund, and chargeback states.
- Verify store receipts on the server.
- Deduplicate purchase events by provider event ID and idempotency key.
- Never grant or remove value solely from a client callback.
- Keep a user-readable transaction history without exposing store payloads.

### J-014 — Tasks, rewards, referrals, and invites

These surfaces were suggested by static asset clusters but their exact rules are
unknown. If included, the independent product must define:

- eligible actions and completion criteria;
- reward amount and currency;
- claim expiry and duplicate-claim behavior;
- referral attribution and self-referral prevention;
- abuse/rate limits;
- share and missing-handler behavior;
- reversal when a qualifying event is refunded or fraudulent; and
- support and dispute path.

Rewards must not create unbounded financial liability or bypass purchase,
moderation, or account-eligibility controls.

### J-015 — Settings, notifications, deep links, and media actions

#### Settings

Users may manage:

- language and locale;
- notification preferences;
- chat preferences;
- privacy and consent settings;
- blocked accounts;
- permission education and settings links;
- account sessions and logout;
- account deletion and data requests; and
- support/contact routes.

#### Notifications

Notifications may cover messages, calls, rewards, account/security events, and
support outcomes. Payloads must minimize private data and use authenticated,
short-lived destinations.

#### Deep links

- Validate scheme, host, path, parameters, authentication, and authorization.
- Fail closed for malformed or expired links.
- Do not reveal whether a private profile or call exists to an unauthorized
  user.
- Return users to a safe shell if the destination is deleted or unavailable.

#### Media actions

For pick/share/download/open actions:

- use scoped storage and content URIs;
- handle cancellation, missing external handler, permission denial, partial
  download, expired URL, and retry;
- use expiring signed URLs where private media is involved; and
- do not imply that a private call or message may be redistributed without
  consent and policy approval.

### J-016 — Reports, blocking, moderation, and appeals

**Actor:** User, host, moderator, or support operator  
**Entry:** Profile, message, media, call, account, or support surface  
**Outcome:** A safety concern is recorded privately and receives an appropriate
response.

#### Report flow

1. Reporter selects a target and a reason.
2. App explains what information will be shared with the safety team.
3. Reporter may attach approved evidence if allowed.
4. Server validates target ownership/context and creates one case.
5. Reporter receives acknowledgement and a safe case reference.
6. Moderator workflow triages, investigates, acts, escalates, or closes.
7. Reporter receives an appropriate status update without exposing confidential
   enforcement details.

#### Requirements

- Report reasons are versioned and independently written.
- Duplicate reports are deduplicated or linked without hiding risk signals.
- Reporter identity is not revealed to the reported account by default.
- Moderators see the minimum necessary evidence.
- Blocks immediately prevent the documented interaction types.
- Enforcement actions are auditable and reversible only through approved roles.
- Appeals and support escalation have a documented route.
- Safety evidence retention is separate from ordinary content deletion.

#### Acceptance criteria

- Missing reason, invalid target, unauthorized report, and attachment denial are
  handled clearly.
- A reported account cannot delete the case or reporter's identity.
- A user can block from profile, conversation, and call surfaces.
- A moderation action updates discovery, messaging, calling, and notification
  eligibility consistently.

---

## 7. Functional requirements catalogue

The identifiers below are stable references for implementation tickets, API
contracts, tests, analytics, and release reviews.

### 7.1 Authentication and account requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-AUTH-001 | Must | The system creates a unique opaque account identifier after successful account creation. | Duplicate submissions produce one account or a safe conflict. |
| FR-AUTH-002 | Must | Protected API requests require an authenticated session. | Unauthenticated requests receive a stable unauthorized error. |
| FR-AUTH-003 | Must | Every account-owned read and write is authorized server-side. | Second-user authorization tests cannot read or mutate another user's data. |
| FR-AUTH-004 | Must | Authentication failures use user-safe messages and do not disclose whether sensitive account data exists. | Error responses contain no stack traces, SQL, tokens, or provider payloads. |
| FR-AUTH-005 | Must | Login, recovery, linking, and verification flows are rate-limited and auditable. | Repeated attempts trigger a recoverable limit state. |
| FR-AUTH-006 | Must | Logout revokes or invalidates the appropriate session and clears protected local state. | Relaunch does not show the previous user's private data. |
| FR-AUTH-007 | Must | Account deletion is a documented, authenticated, retryable workflow. | User sees deletion status and retained-record explanation where required. |
| FR-AUTH-008 | Should | The system supports approved social sign-in providers. | Provider cancellation, missing provider, and account-link conflict are tested. |

### 7.2 Discovery and profile requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-DISC-001 | Must | Discovery returns only profiles eligible for the requesting user. | Blocked, deleted, suspended, and private profiles are excluded. |
| FR-DISC-002 | Must | Discovery supports cursor pagination and safe refresh. | No duplicate or skipped cursor results in integration tests. |
| FR-DISC-003 | Must | Empty, loading, offline, timeout, and retry states are explicit. | Each state has a user-readable message and recovery action where possible. |
| FR-DISC-004 | Must | Approved filters are validated and applied server-side. | Client cannot bypass hidden, region, age, or eligibility rules. |
| FR-DISC-005 | Must | Profile detail displays only fields allowed by privacy and authorization rules. | Unauthorized fields are absent from API and UI. |
| FR-DISC-006 | Must | Follow/unfollow is idempotent and server-authoritative. | Repeated taps produce one relationship state. |
| FR-DISC-007 | Should | Profile availability is shown with a timestamp or freshness explanation. | Stale availability is not presented as guaranteed live status. |
| FR-DISC-008 | Should | Discovery ranking can be changed through a documented independent policy. | Ranking version is recorded for experiments or support review. |
| FR-DISC-009 | Could | Users can save or favorite profiles. | Save/remove is private, idempotent, and visible only to the owner unless approved. |

### 7.3 Matching requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-MATCH-001 | Must | A match attempt has a unique idempotency key and server-owned status. | Retry returns the existing attempt rather than creating a duplicate. |
| FR-MATCH-002 | Must | Matching excludes blocked, deleted, suspended, and ineligible accounts. | Eligibility tests cover each exclusion. |
| FR-MATCH-003 | Must | User-facing filters have documented meanings and safe defaults. | Unsupported or malformed values are rejected. |
| FR-MATCH-004 | Must | No-result, timeout, cancellation, and candidate-unavailable states are recoverable. | User can retry or return without a stuck spinner. |
| FR-MATCH-005 | Should | Match history records the outcome without exposing private ranking data. | History is scoped to the requesting account. |
| FR-MATCH-006 | Could | A ticket or entitlement can gate a match attempt. | Consumption and reversal rules are tested before enabling. |

### 7.4 Messaging requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-MSG-001 | Must | Only authorized participants can read a conversation. | Cross-account repository/API tests fail closed. |
| FR-MSG-002 | Must | Message creation requires a client idempotency key. | Duplicate network retries produce one business message. |
| FR-MSG-003 | Must | Server validates text length, encoding, rate limits, and moderation policy. | Invalid and abusive input receives stable errors. |
| FR-MSG-004 | Must | Message state distinguishes local draft, submitting, accepted, failed, retry, delivered, and read where supported. | UI state matches server evidence. |
| FR-MSG-005 | Must | Offline or timeout behavior never falsely shows delivery. | Offline test preserves a pending/failed state. |
| FR-MSG-006 | Must | Block and suspension rules prevent prohibited new messages. | Existing thread transitions to a safe restricted state. |
| FR-MSG-007 | Should | Approved image attachments use scoped storage, size/type limits, and expiring access. | Upload failure and retry tests pass without leaking private URLs. |
| FR-MSG-008 | Should | Gifts or virtual items are shown as explicit spend actions. | Confirmation, insufficient balance, and duplicate-spend tests pass. |
| FR-MSG-009 | Could | Translation is available only after privacy, cost, language, and provider approval. | Translation failure does not alter the original message. |
| FR-MSG-010 | Must | Users can report a message without revealing reporter identity. | Moderation case includes context under least-privilege access. |
| FR-MSG-011 | Must | Message history uses cursor pagination and safe deletion/retention rules. | Large history does not load unbounded data. |
| FR-MSG-012 | Should | Message notifications contain minimal private content. | Lock-screen and analytics payload review passes. |

### 7.5 Video-call requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-CALL-001 | Must | A call request checks recipient, block, availability, entitlement, balance, and concurrency on the server. | Invalid calls are rejected before provider token creation. |
| FR-CALL-002 | Must | Call creation is idempotent. | Repeated taps and retries produce one session. |
| FR-CALL-003 | Must | Call states are persisted independently from UI labels. | State transition tests cover requested through ended. |
| FR-CALL-004 | Must | RTC credentials are short-lived, scoped, and issued only by an authorized server. | No provider secret exists in client code or APK. |
| FR-CALL-005 | Must | Camera and microphone permissions are explained and recoverable. | Denial, revocation, and settings-return tests pass. |
| FR-CALL-006 | Must | Call connection, reconnecting, failed, and ended states are visible. | Network interruption test produces a safe result. |
| FR-CALL-007 | Must | Call billing uses server-confirmed events and timestamps. | Client timer manipulation cannot change settlement. |
| FR-CALL-008 | Must | Call end stops capture, releases media resources, and records an outcome. | Lifecycle and process-recovery tests pass on supported devices. |
| FR-CALL-009 | Must | User and host can report/block during or immediately after a call. | Safety action is reachable and privacy-preserving. |
| FR-CALL-010 | Should | User can control microphone, camera, and approved audio route. | Rapid toggles and device-route changes remain consistent. |
| FR-CALL-011 | Should | Call history shows authorized status, timestamps, duration, and financial reference. | History matches server settlement, not local display time. |
| FR-CALL-012 | Could | Camera switch, blur, beauty, recording, picture-in-picture, or Bluetooth routing are supported. | Each control has separate device test evidence before release. |
| FR-CALL-013 | Must | A call cannot continue after account suspension, block, or provider revocation. | Server/provider state terminates or restricts the session safely. |
| FR-CALL-014 | Must | Call limits and spending protections are enforced. | Max duration, balance threshold, and concurrency tests pass. |
| FR-CALL-015 | Should | The app explains whether a reconnect grace period is billable. | Policy copy and settlement test agree. |

### 7.6 Economy, purchases, and host earnings requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-MONEY-001 | Must | All monetary values use integer minor units on the server. | Currency tests cover rounding and negative adjustments. |
| FR-MONEY-002 | Must | Wallet balances are derived from an append-only ledger. | Direct balance mutation is impossible through public APIs. |
| FR-MONEY-003 | Must | Store receipts are verified server-side before entitlement grant. | Invalid, duplicate, delayed, refunded, and reversed events are tested. |
| FR-MONEY-004 | Must | Purchase and webhook handlers are idempotent and signature-verified. | Provider event replay does not duplicate value. |
| FR-MONEY-005 | Must | User charge and host earning rates are policy-versioned. | Historical settlement retains the applied rate. |
| FR-MONEY-006 | Must | Refunds and chargebacks create compensating ledger entries. | Posted transactions are never silently edited. |
| FR-MONEY-007 | Must | Host earning states distinguish pending, available, held, paid, reversed, and disputed. | Host UI cannot label pending funds as withdrawable. |
| FR-MONEY-008 | Must | Payout creation requires eligibility, limits, and an idempotency key. | Duplicate payout requests produce one audited record. |
| FR-MONEY-009 | Must | Finance/support actions are role-restricted and audited. | Unauthorized operator actions are rejected. |
| FR-MONEY-010 | Should | Users and hosts can view understandable transaction history. | History omits private provider payloads. |
| FR-MONEY-011 | Must | Spending and payout limits can be configured without a client release. | Operations can stop or limit value movement safely. |
| FR-MONEY-012 | Required before production | Real money remains disabled until legal, tax, store, fraud, support, and reconciliation review is complete. | Release checklist contains approvals and sandbox evidence. |

### 7.7 Safety, privacy, and account requirements

| ID | Priority | Requirement | Acceptance evidence |
| --- | --- | --- | --- |
| FR-SAFE-001 | Must | Users can report profiles, messages, media, calls, and accounts. | Each surface creates a private case or clear rejection. |
| FR-SAFE-002 | Must | Users can block and unblock according to the documented policy. | Blocked interactions stop across discovery, messages, calls, and notifications. |
| FR-SAFE-003 | Must | Moderation actions include actor, target, reason, timestamp, and policy version. | Audit query returns complete records. |
| FR-SAFE-004 | Must | Reporter identity is hidden from the reported user by default. | API and UI review shows no reporter disclosure. |
| FR-SAFE-005 | Must | Account deletion has documented retention exceptions. | Deletion job and retained-record report are tested. |
| FR-SAFE-006 | Must | Sensitive data is minimized and redacted from logs and analytics. | Secret/PII scan and logging review pass. |
| FR-SAFE-007 | Must | Age, host eligibility, and geographic restrictions are explicitly approved. | Launch cannot proceed with unresolved eligibility policy. |
| FR-SAFE-008 | Must | Suspended, deleted, and blocked states are consistent across all surfaces. | Cross-feature state tests pass. |
| FR-SAFE-009 | Should | Users can appeal or contact support for documented actions. | Case handoff and response status are recorded. |
| FR-SAFE-010 | Must | Emergency and legally required escalation paths are documented. | Operations runbook identifies owner and response channel. |
| FR-SAFE-011 | Must | Advertising identifiers, device fingerprints, and diagnostic identifiers are not used as core account identity and are collected only for an approved purpose with applicable consent. | Prototype builds collect none; production telemetry review identifies purpose, consent, retention, access, and deletion behavior. |

---

## 8. High-level domain model

The following are proposed independent domain objects. Names and fields may
change in `docs/DOMAIN_MODEL.md`, but ownership and authorization must remain
explicit.

| Entity | Purpose | Sensitive fields / rules |
| --- | --- | --- |
| `Account` | Authentication identity, status, locale, consent, sessions | Email/provider IDs, recovery data, suspension state; never expose provider tokens |
| `Profile` | Public presentation and availability | Public media, biography, tags, verification state; owner-editable fields only |
| `Relationship` | Follow, favorite, request, or block state | Scoped to the actor and target; block must affect all relevant queries |
| `Conversation` | Authorized participant relationship | Participant membership is server-authoritative |
| `Message` | Text, attachment, gift, call, or system event | Private content; moderation and retention rules apply |
| `MediaObject` | Profile or message media metadata | Signed URLs, content type/size, moderation state, retention |
| `MatchAttempt` | One matching request and outcome | Preferences, candidate, entitlement, decision, timestamps |
| `CallSession` | Requested, accepted, connected, and ended call | Participants, provider room ID, state, server timestamps, policy version |
| `CallEvent` | Append-only call lifecycle evidence | Provider event ID, event time, source, deduplication key |
| `Wallet` | User virtual balance or entitlement summary | Derived from ledger; never trust client values |
| `Purchase` | Store purchase and fulfillment status | Receipt reference and provider IDs; minimize payload retention |
| `Entitlement` | Credits, subscription, ticket, or feature access | Source, expiry, status, policy version |
| `LedgerEntry` | Append-only financial movement | Integer minor units, currency, account, reason, compensating reference |
| `HostEarning` | Host-side settlement claim | Pending/available/held/paid/reversed/disputed; linked to call settlement |
| `Payout` | Approved movement to host | Eligibility, destination reference, status, idempotency key, audit |
| `SafetyCase` | Report, block escalation, or support case | Reporter privacy, evidence access, status, policy version |
| `ModerationAction` | Enforcement or review action | Actor, reason, target, timestamp, appeal state |
| `Notification` | User-visible event delivery | Minimal payload, delivery status, expiration, deep-link authorization |
| `ConsentRecord` | Policy, privacy, media, or recording consent | Version, timestamp, actor, scope, withdrawal behavior |
| `AuditEvent` | Sensitive operator and system action trail | Redacted but sufficient for accountability and reconciliation |

### Data ownership requirements

- Every row must have an explicit owner or role-based access rule.
- Public profile data and private account data must be separate where practical.
- Financial records must not be deleted merely to correct a calculation.
- Safety evidence must have a documented retention period and access policy.
- UTC timestamps are canonical; local formatting occurs at the UI boundary.
- IDs exposed to clients must be opaque and non-sequential where enumeration is
  a risk.

---

## 9. Authorization matrix

The backend must enforce this matrix or a stricter policy. UI visibility is not
authorization.

| Capability | User/viewer | Host | Moderator | Support/finance | System administrator |
| --- | --- | --- | --- | --- | --- |
| Read own account/profile | Yes | Yes | Only when case-authorized | Only when case-authorized | Break-glass audit only |
| Edit own profile | Yes | Yes | No | No | No ordinary access |
| Read public profile | If eligible | If eligible | Case context | Case context | No automatic access |
| Follow/unfollow | Own action | Own action | No | No | No |
| Send message | If allowed | If allowed | No ordinary messaging | No | No |
| Read conversation | Participants only | Participants only | Case-authorized evidence | Case-authorized support | No automatic access |
| Request/accept call | If eligible | If eligible | No | No | No |
| Create provider token | No | No | No | No | Server service only |
| View own wallet/transactions | Yes | Own earnings only | No | Case-authorized | No automatic access |
| Adjust ledger | No | No | No | Approved compensating workflow | Separate finance service role |
| Submit report | Yes | Yes | Yes | Yes | Yes |
| Review safety case | No | No | Assigned scope | Support scope only | Audited emergency scope |
| Apply moderation action | No | No | Assigned policy scope | No | No unless separately granted |
| Issue refund | No | No | No | Approved finance scope | No automatic finance scope |
| Create payout | No | No | No | Approved finance workflow | No automatic finance scope |
| Change infrastructure | No | No | No | No | Least-privilege infrastructure scope |

Every privileged action must create an audit event containing actor, role,
target, reason, timestamp, request/case reference, and outcome.

---

## 10. Business rules and policy decisions

### 10.1 Pricing and billing decisions required before production

The following decisions are intentionally unresolved because they materially
change user experience, legal exposure, and financial results:

1. Is the rate charged per second, per 30 seconds, per full minute, or another
   unit?
2. Does billing start at acceptance, media connection, or a server-confirmed
   connected state?
3. Does billing stop at hang-up, provider disconnect, timeout, app close, or a
   server grace-period expiry?
4. Is a reconnect grace period free, partially billable, or fully billable?
5. What happens if only one participant has media connected?
6. What is the maximum call duration and maximum daily/monthly spend?
7. What happens when balance is insufficient during an active call?
8. How are taxes, app-store fees, payment fees, refunds, chargebacks, and
   currency conversion handled?
9. What exact host rate applies to each call and policy version?
10. When do host earnings move from pending to available?

No production code may silently choose answers for these questions. A temporary
development rule must be labelled as a mock rule and isolated behind a feature
flag or sandbox configuration.

### 10.2 Proposed settlement invariants

Once approved, the production system should preserve these invariants:

- A call cannot settle twice.
- A purchase cannot grant the same entitlement twice.
- A refund cannot remove more value than the original eligible transaction.
- A host earning cannot become available before the policy-defined conditions.
- A ledger correction is a new compensating entry, not an edit to history.
- A provider webhook cannot change state until its signature and event ID are
  verified.
- Client-reported duration, balance, price, and host rate are never authoritative.

### 10.3 Relationship and block rules

The product owner must approve whether blocking:

- removes both profiles from discovery;
- prevents all new messages;
- ends an active call immediately;
- cancels pending call requests;
- removes notifications and match suggestions;
- hides prior conversation content; and
- can be reversed by either party or only by the blocker.

Until approved, use the safer default: block prevents new discovery, messages,
calls, and notifications, while preserving only the minimum records required
for safety, financial reconciliation, and legal retention.

### 10.4 Recording and media retention

Recording, screenshots, downloads, and media sharing must be treated as
separate product features. Before enabling any recording:

- obtain explicit, visible consent from every required participant;
- show recording state continuously;
- define storage, access, retention, deletion, and export behavior;
- prohibit silent recording;
- define legal and safety escalation; and
- test camera, microphone, storage, and background behavior on supported devices.

The first release should keep recording disabled unless these requirements are
approved and implemented.

---

## 11. Non-functional requirements

### 11.1 Security

- All protected endpoints require authentication and authorization.
- All inputs are validated at the server boundary.
- Sensitive provider tokens are short-lived and scoped.
- Secrets never appear in the mobile package, source repository, logs, or
  analytics payloads.
- Database access uses least privilege and row-level ownership policies.
- Authentication, messaging, reports, uploads, calls, token issuance, and
  purchase operations are rate-limited.
- Dependencies are reviewed, pinned or locked, and scanned according to the
  chosen stack.
- Security incidents have a documented containment, rotation, notification, and
  recovery procedure.

### 11.2 Privacy

- Collect only data required for the approved feature.
- Explain why camera, microphone, notifications, media, contacts, location,
  advertising identifiers, and verification data are requested.
- Use privacy-safe analytics identifiers and retention.
- Redact message bodies, signed media URLs, receipts, authorization headers,
  and full device identifiers from normal logs.
- Provide account deletion, retention explanations, and support escalation.
- Keep user-owned, safety-retained, and financial-retained data decisions
  separate.

### 11.3 Performance and capacity

The following are draft engineering targets to validate with real measurements:

- main app shell usable within 3 seconds after local configuration is available
  on a supported mid-range device;
- discovery API P95 below 500 ms excluding media transfer;
- message send acknowledgement P95 below 2 seconds when both accounts are
  online and the provider is healthy;
- call connection target within 15 seconds for supported network conditions;
- no unbounded memory growth while scrolling feeds or long conversations;
- media uploads have size, dimension, timeout, cancellation, and retry limits;
- background jobs have bounded concurrency and back-pressure;
- cost alerts exist for RTC minutes, storage, bandwidth, database, messaging,
  push, analytics, and moderation providers.

### 11.4 Reliability and recovery

- Provider failures map to application-level error states.
- Jobs and webhook handlers are retry-safe and idempotent.
- Stale call, notification, upload, and purchase states have expiration or
  manual recovery paths.
- Database migrations have tested recovery or forward-fix plans.
- Backups are monitored and restore-tested.
- Operations can disable new calls, purchases, payouts, or discovery without a
  client release.

### 11.5 Accessibility and localization

- Every interactive control has text or an independent content description.
- Important state changes are announced or otherwise discoverable.
- Touch targets are usable without precise tapping.
- UI works with large text, long names, long messages, emoji, and translated
  strings.
- Color is not the only status indicator.
- Error, billing, permission, and safety messages use plain language.
- Locale and timezone formatting occurs at the presentation boundary while
  server timestamps remain UTC.

### 11.6 Observability

Measure without collecting unnecessary personal data:

- startup success/failure;
- authentication success/failure categories;
- discovery latency and empty-result rate;
- message accepted/delivered/failed rates;
- call requested/accepted/connected/reconnecting/ended/failed rates;
- permission grant/denial/revocation;
- purchase pending/fulfilled/refunded/reversed states;
- report queue age and moderation outcomes;
- payout and ledger reconciliation exceptions; and
- provider cost and quota consumption.

Every alert must have an owner, severity, runbook, and safe mitigation.

---

## 12. Accessibility, permission, and device acceptance matrix

The following device behaviors are release requirements for features that use
them. A static SDK or manifest entry is not evidence that the feature works.

| Area | Required test cases |
| --- | --- |
| Camera | Permission grant, denial, permanent denial, no camera hardware, camera switch, app background, call end |
| Microphone | Grant, denial, mute, audio focus loss, route change, call end |
| Bluetooth/audio route | Supported Android versions, connect/disconnect, unavailable device, permission denial |
| Notifications | Permission grant/denial, call notification, message notification, expired deep link |
| Media picker | Cancel, no handler, scoped storage, large file, unsupported type, upload retry |
| Network | Offline start, slow network, disconnect during call, reconnect, timeout, restored network |
| Lifecycle | Relaunch, force-stop, background, lock screen, rotation where supported, process death |
| Accessibility | Screen reader labels, focus order, large text, contrast, touch target size |
| Localization | Long translations, RTL where supported, date/currency formatting, emoji |
| Safety | Report, block, deleted account, suspended account, appeal/support route |
| Economy | Pending purchase, duplicate event, refund, chargeback, insufficient balance, reconciliation |

The final device matrix must include at least one supported small-width phone,
by the selected RTC and billing providers.

---

## 13. Analytics event contract

The full event schema belongs in `docs/ANALYTICS_EVENTS.md`. The initial
contract should include safe, versioned events such as:

| Event | Allowed properties | Must not include |
| --- | --- | --- |
| `app_started` | app version, build channel, locale, OS version bucket | account email, token, full device ID |
| `onboarding_completed` | flow version, outcome | free-text personal data |
| `auth_completed` | provider category, outcome code | credential, provider token |
| `discovery_loaded` | cursor page size, latency bucket, result count bucket | profile names or raw location |
| `profile_opened` | profile category, source surface | private profile fields not needed for analysis |
| `relationship_changed` | relationship type, outcome | message bodies or private notes |
| `message_submitted` | message type, attachment category, outcome | message body, signed URL, receipt |
| `message_delivery_changed` | state, latency bucket | message content |
| `call_state_changed` | state, direction, duration bucket, failure category | raw audio/video, tokens, private provider payload |
| `permission_changed` | permission category, outcome, OS version bucket | unrelated device identifiers |
| `purchase_state_changed` | product category, state, currency, amount bucket | raw receipt or payment instrument |
| `report_submitted` | target category, reason category, outcome | reporter identity in analytics payload |
| `block_changed` | action, target category, outcome | private target data |
| `support_case_changed` | category, status, time bucket | message bodies or identity documents |

Analytics must be disabled, sampled, or redacted when consent or regional policy
requires it. Product analytics is not a substitute for an audit ledger or
moderation record.

---

## 14. Release acceptance and go/no-go criteria

The product may move from prototype to closed beta only when:

- the approved product name, identity, copy, and independent assets exist;
- all Must requirements for the milestone have implementation and tests;
- authentication and authorization tests pass for at least two test accounts;
- blocked, deleted, suspended, unauthorized, and offline states are tested;
- report, block, support, and account deletion paths are usable;
- calls have explicit permission, reconnect, end, and provider-failure states;
- the economy is clearly sandboxed and cannot move real value accidentally;
- logs and analytics are reviewed for secrets and unnecessary personal data;
- the staging environment is separated from production;
- migrations, backups, restore, and rollback/forward-fix procedures are tested;
- crash, API, RTC, moderation, and purchase monitoring exists; and
- known limitations are recorded in the release decision.

The product may enable real-money purchases only when:

- store sandbox purchase, restore, delayed fulfillment, refund, and duplicate
  event tests pass;
- server-side receipt validation and entitlement reconciliation pass;
- the ledger is append-only, policy-versioned, and idempotent;
- terms, privacy, refund, host, community, and support policies are approved;
- taxes, store fees, fraud, chargebacks, payout holds, and support ownership are
  documented;
- spending limits and emergency shutdown controls are active; and
- the release owner explicitly records the approval.

The product may enable real host payouts only when:

- host eligibility, identity, age, geography, and payout destination checks are
  approved;
- pending/available/held/paid/reversed/disputed states are implemented;
- payout and refund/chargeback reversals are reconciled;
- fraud and collusion monitoring exists;
- payout support and appeals are staffed; and
- a finance/operator review approves the production workflow.

---

## 15. Evidence traceability and unknowns

| Evidence source | What it contributes | What it does not prove |
| --- | --- | --- |
| `reports/chato-recon.md` | Clean-room boundary, static architecture clues, generic entity and flow hypotheses | Runtime behavior, exact product logic, exact UI, exact APIs |
| `reports/chato-deeper-static-analysis.md` | Thin Flutter host, target-specific native channel, advertising-ID privacy surface, plugin-registration interpretation, and runtime blockers | Target route tree, Dart logic, provider selection, consent behavior, or backend contracts |
| `reports/chato-static-evidence.json` | Flutter host, messaging/RTC/billing SDK capability, asset clusters, permission and entity clues | Reachability of every feature, current backend behavior, credentials, product policy |
| `reports/chato-plugin-registration.csv` | Machine-readable list of 53 bundled Flutter Android plugins and capability categories | That every plugin is used or should be selected for the independent product |
| `reports/chato-screen-inventory.csv` | Candidate functional surfaces such as onboarding, discovery, profile, matching, messages, calls, economy, settings, safety, and media | Exact route names, layout, wording, accessibility labels, or visual design |
| `reports/chato-interaction-map.csv` | Candidate transitions and edge cases such as retries, permission denial, reconnect, duplicate taps, billing failure, and malformed links | Verified state machine or exact target implementation |
| `reports/chato-permissions.csv` | Permission categories that a fresh product should evaluate carefully | Necessity, request timing, or approved permission policy |
| `reports/chato-install-run-test-plan.md` | Runtime test ideas and current environmental blockers | Successful target installation or runtime evidence |

### Known unknowns that must remain visible

- Exact production brand, name, visual identity, copy, and media.
- Exact screen tree, routes, navigation structure, and accessibility labels.
- Exact ranking, matching, eligibility, and availability rules.
- Exact message moderation, translation, gift, and attachment policies.
- Exact call billing unit, rate timing, reconnect grace, and settlement rules.
- Exact product IDs, subscription plans, store prices, taxes, and refunds.
- Exact host verification, payout, tax, and fraud policy.
- Exact backend schema, API contracts, provider configuration, and data retention.
- Whether bundled SDK capabilities are reachable in the target product.
- Whether the target advertising-ID lookup returns a value before or after its
  asynchronous native operation completes; this must not be copied into the
  independent product.
- Runtime behavior of the target artifact; the supplied base APK lacked the
  payload/splits and no authorized device runtime was available.

No implementation ticket may turn an unknown into an unlabelled fact.

---

## 16. Open product decisions

The product owner should approve these decisions before the corresponding
features move beyond a mock or sandbox:

1. Product name, audience, countries, languages, and launch age policy.
2. User/host legal relationship and host verification process.
3. Authentication providers and account-recovery method.
4. Discovery ranking, matching policy, availability, and profile visibility.
5. Messaging attachments, gifts, translation, retention, and moderation.
6. RTC provider, supported devices, recording policy, and call limits.
7. Pricing granularity and the ₹15/₹6 draft rate policy.
8. Wallet/credit model, subscription model, refunds, taxes, and store fees.
9. Host earnings availability, payout schedule, holds, and disputes.
10. Age gating, content policy, moderation staffing, and emergency escalation.
11. Data retention, deletion, export, analytics, and regional privacy rules.
12. Support hours, response targets, refund authority, and appeals process.
13. Cloud, database, storage, push, analytics, and provider accounts.
14. Initial launch metrics, spending limits, fraud thresholds, and rollback plan.

Until these decisions are approved, use local seeded data, mock providers, fake
events, and clearly labelled demo values.

---

## 17. Implementation handoff

When implementing a requirement from this document, an AI agent or developer
must:

1. Link the task to one or more requirement IDs or journey IDs.
2. Read the relevant architecture, domain, security, payments, safety, and
   test documents.
3. Inspect current callers, data flow, migrations, configuration, and tests.
4. Implement the happy path and the relevant failure/abuse states together.
5. Add server-side validation and authorization where business effects occur.
6. Add or update tests that prove the user-visible outcome.
7. Update documentation, analytics, and release notes if behavior changes.
8. Run the narrowest relevant checks, then broader checks when practical.
9. Report implemented behavior separately from inferred or blocked behavior.

An implementation is not complete because a screen, button, mock provider, or
API endpoint exists. The stored data must be readable under the correct
authorization, repeated actions must be safe, and the user must receive a
recoverable result for expected failure states.
