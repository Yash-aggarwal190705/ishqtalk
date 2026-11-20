# Trust and Safety — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Trust and safety owner to be assigned; product, legal, privacy, and operations reviewers required  
**Last updated:** 2026-10-25  
**Source of truth for:** Reporting, blocking, moderation, appeals, age/host
eligibility, emergency escalation, safety evidence, and enforcement operations  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0004-moderation-model.md`

This document defines the independent product's safety and moderation model. It
does not copy target moderation rules, ranking rules, source code, private
services, exact copy, or enforcement behavior. Static artifact evidence can
suggest generic report/block surfaces, but it does not establish a production
safety policy.

This is an operational and product policy draft, not legal advice. Legal and
regional owners must approve age requirements, prohibited-content policy,
emergency escalation, law-enforcement requests, host relationships, reporting
obligations, and user notices before public launch.

---

## 1. Safety objectives and decision labels

### 1.1 Objectives

The product must:

1. Reduce foreseeable harm from harassment, scams, impersonation, exploitation,
   unsafe contact, abuse, and financial manipulation.
2. Give users clear, reachable, privacy-preserving report and block controls.
3. Protect reporters, witnesses, victims, and bystanders from retaliation.
4. Give moderators only the minimum data needed for an assigned case.
5. Make enforcement consistent, explainable at a safe level, and appealable where
   appropriate.
6. Keep safety decisions separate from arbitrary provider or client behavior.
7. Preserve evidence and audit history without retaining more personal data than
   the approved safety purpose requires.
8. Provide emergency and legally required escalation paths with accountable
   owners and response targets.

### 1.2 Decision labels

- **Required:** must be implemented and tested before the stated release.
- **Proposed:** independent policy awaiting product, safety, legal, or regional
  approval.
- **Gated:** disabled until its policy, staffing, provider, and test controls are
  ready.
- **Deferred:** outside the current release.
- **Unknown:** not established and must not be silently invented.

### 1.3 Minimum release gates

Before public launch, the product must have:

- report controls for accounts, profiles, messages, media, and calls;
- block/unblock behavior documented across discovery, messaging, calls, and
  notifications;
- private safety-case storage and reporter privacy controls;
- moderator roles, case assignment, evidence access, and audit events;
- enforcement states and user-facing safe explanations;
- age, host-eligibility, and geographic policy decisions;
- appeal or support escalation for applicable actions;
- emergency and legally required escalation ownership;
- account deletion and safety-retention behavior;
- abuse/rate limits and duplicate-report handling;
- moderation queue metrics, on-call coverage, and runbook procedures; and
- server-side tests for authorization, privacy, enforcement, and auditability.

---

## 2. Safety scope and protected parties

### 2.1 Covered surfaces

Safety controls apply to:

- account creation, profile editing, verification, and discovery;
- profile names, bios, tags, availability, and public media;
- follows, favorites, matches, and recommendations;
- direct messages, attachments, gifts, call invitations, and call outcomes;
- one-to-one calls, call requests, active calls, and post-call reports;
- notifications, deep links, support cases, and payment/payout interactions;
- host onboarding, eligibility, availability, and earnings displays; and
- moderator, support, finance, provider, and infrastructure tools.

Public live/audio rooms are deferred unless separately approved. If added, they
must have room-level moderation, participant controls, host tools, and a separate
capacity/safety review.

### 2.2 Protected parties

Safety design must consider:

- users/viewers;
- hosts/creators;
- reporters and witnesses;
- people who are blocked, restricted, or under review;
- moderators and support staff;
- minors or age-uncertain users;
- people affected by scams, impersonation, or financial abuse; and
- people whose data appears in evidence but who are not app users.

The product must not assume that the reporter, reported account, host, or
moderator is always the harmed or truthful party. The process must preserve
evidence, avoid retaliation, and allow correction without exposing protected
information.

### 2.3 Safety principles

- **Safety by default:** use the safer behavior when policy is unresolved.
- **Least exposure:** reveal only the minimum information needed for a decision.
- **No retaliation:** never disclose reporter identity by default.
- **Consistent enforcement:** equivalent cases should follow equivalent policy
  and escalation paths.
- **Human accountability:** automated signals assist review but do not silently
  become irreversible enforcement without approved policy.
- **Reversibility where safe:** temporary restrictions can be reviewed and
  reversed; evidence and audit history are not erased.
- **User agency:** users can block, report, leave, mute, and seek support.
- **Server authority:** clients cannot dismiss reports, lift restrictions, or
  change safety state.
- **Evidence honesty:** a report, classifier signal, or provider callback is not
  automatically proof of a violation.

---

## 3. Roles, capabilities, and separation of duties

### 3.1 User-facing roles

| Role | Safety responsibilities and rights |
| --- | --- |
| User/viewer | Report, block/unblock, manage privacy, receive safe case status, appeal applicable actions |
| Host | Maintain approved profile, receive calls, report/block, respond to support and eligibility review |
| Reporter/witness | Submit a private case, provide optional evidence, receive safe acknowledgement and status |
| Reported account | Receive safe enforcement notice where appropriate, respond or appeal without seeing reporter identity |

### 3.2 Operator capabilities

Use separate capabilities rather than a broad `admin` role:

| Capability | Scope | Must not do |
| --- | --- | --- |
| `safety.intake` | Triage new reports and duplicate cases | Apply high-impact enforcement without assigned authority |
| `safety.review` | Assigned case evidence and related context | Browse unrelated private messages or reports |
| `safety.enforce` | Approved temporary/permanent actions | Alter financial records or silently delete evidence |
| `safety.appeal` | Appeal review independent of original action where practical | Retaliate against an appellant or expose reporter identity |
| `safety.escalate` | Emergency/legal escalation workflow | Make unlogged external contact or disclose unnecessary data |
| `support.safety_case` | User communication and case status | View internal evidence beyond case scope |
| `finance.safety_hold` | Financial hold requested by documented safety/fraud case | Decide final moderation outcome without safety authority |
| `operations.safety_control` | Disable/limit risky feature or provider | Use a kill switch without reason, owner, and review |

### 3.3 Operator access controls

Every sensitive operator action requires:

- authenticated operator identity;
- current capability and case/resource scope;
- reason code and optional bounded note;
- target case/resource;
- server timestamp;
- prior and new state;
- request/correlation ID;
- audit event; and
- review/approval where policy requires it.

Operators should see redacted projections by default. Full evidence access is a
separate action and must be logged. Break-glass access is time-limited,
reason-coded, reviewed, and automatically revoked.

---

## 4. Report intake and user controls

### 4.1 Report entry points

Users must be able to report, where the surface exists:

- an account or profile;
- a profile media item;
- a message or attachment;
- a call participant or call event;
- a scam, impersonation, exploitation, or unsafe request;
- a payment/gift/payout concern through support; and
- an account, safety, or privacy issue through support.

The report control must be reachable without exposing the reporter to the
reported user. A report action must remain usable when the target is deleted,
blocked, offline, or no longer visible.

### 4.2 Report request requirements

The server validates:

- authenticated reporter;
- target type and target ID;
- reporter's authorized view of the target;
- reason code;
- bounded optional explanation;
- optional evidence references owned or submitted by the reporter;
- rate limit and duplicate-report rules; and
- whether the target is already under a matching case or enforcement state.

Report creation is idempotent. A retry with the same key returns the existing
case receipt. Reusing a key with different target or reason data fails safely.

### 4.3 User-facing acknowledgement

The reporter receives:

- a private case ID or safe acknowledgement;
- received/pending/reviewed/resolved status where policy allows;
- an expected next step or support route;
- a warning not to submit unnecessary sensitive data; and
- information that emergency situations require local emergency services or the
  approved emergency channel rather than waiting for ordinary review.

The acknowledgement must not expose:

- reporter identity to the reported account;
- internal risk scores or classifier output;
- moderator names or private notes;
- evidence that could enable retaliation; or
- a guaranteed enforcement outcome.

### 4.4 Report severity

Use a controlled severity model. Exact definitions and response targets require
regional and legal approval.

| Severity | Example category | Target response |
| --- | --- | --- |
| Critical | Immediate threat, exploitation, credible emergency, severe active harm | Immediate triage and emergency/legal escalation assessment |
| High | Active harassment, scam, impersonation, serious safety concern, unsafe host behavior | Priority review and temporary safeguards where justified |
| Normal | Policy violation, spam, unwanted contact, non-urgent abuse | Queue review under documented SLA |
| Low | Product complaint, duplicate, unclear or non-actionable report | Triage, merge, request clarification, or close with reason |

Severity may be raised or lowered only by an authorized workflow with a reason
and audit record.

---

## 5. Case lifecycle and evidence

### 5.1 Safety-case lifecycle

```text
received -> deduplicating -> triaged -> assigned -> reviewing
reviewing -> actioned -> notified -> resolved
reviewing -> no_action -> resolved
actioned -> appealed -> appeal_review -> affirmed | modified | reversed
received -> escalated -> external_or_emergency_review -> resolved
```

The exact transitions must be enforced by the server. A client cannot mark a
case resolved or delete a case.

### 5.2 Case fields

Every case should include:

```text
case_id
target_type
target_id
reporter_account_id or protected reporter reference
reason_code
severity
status
assigned_queue
assigned_operator_scope
policy_version
created_at_utc
updated_at_utc
first_reviewed_at_utc
resolved_at_utc
resolution_code
appeal_state
retention_class
legal_or_safety_hold
```

Reporter identity must be separated from the reported-user-facing projection.
The case record must not use mutable display names as identity references.

### 5.3 Evidence handling

Evidence may include bounded message context, media references, call metadata,
account/profile snapshots, provider references, and operator notes only when
necessary for the case.

Controls:

- capture the minimum context needed;
- preserve original evidence separately from redacted user projections;
- record source, timestamp, actor, and integrity/reference information;
- restrict access by assigned case and capability;
- do not copy evidence into tickets, chat, screenshots, or personal devices;
- encrypt evidence at rest and in transit;
- prevent ordinary operators from exporting raw evidence;
- apply retention and legal/safety holds;
- record every access, download, redaction, and deletion; and
- use compensating/audit records rather than silently rewriting evidence.

Automated classifier output is an evidence signal with a model/version and
confidence context, not a final decision by itself.

### 5.4 Case merging and duplicate reports

Duplicate reports may be merged only when the relationship is documented. The
system must preserve:

- each reporter reference privately;
- original timestamps and reasons;
- the canonical case ID;
- merge actor and reason; and
- any distinct evidence or appeal rights.

Do not suppress a report merely because another report exists. Duplicate abuse
controls must not silence a legitimate safety signal.

---

## 6. Blocking and interaction restrictions

### 6.1 Block behavior

Until a stricter product policy is approved, the safer default is that blocking
prevents new discovery, follows, favorites, matches, messages, call requests,
and notifications between the blocker and blocked account.

The server must apply block state consistently to:

- discovery and search results;
- profile availability and recommendations;
- follow/favorite/match actions;
- new conversations and messages;
- call requests, acceptance, RTC-token issuance, and active-call policy;
- notification generation and delivery;
- gifts, support prompts, and other direct interactions; and
- operator projections where reporter/target privacy requires filtering.

Blocking must not:

- reveal private information about the blocker;
- delete safety, financial, or legal records silently;
- prevent a user from reporting an account through a safe path;
- grant the blocker access to the blocked account's private data; or
- be used by a client to bypass server authorization.

### 6.2 Unblocking

Unblocking is an explicit authenticated action. It does not automatically:

- restore prior follows or matches;
- reopen a closed conversation;
- restore a canceled call;
- remove a safety case; or
- reverse moderation or account restrictions.

The product owner must approve whether either party can unblock, whether the
blocked party is notified, and whether prior content becomes visible again.

### 6.3 Active calls and blocks

When a block affects an active call, the backend must evaluate the approved
policy and may:

- end the call immediately;
- revoke future RTC tokens;
- stop new billable time;
- place settlement into reconciliation;
- preserve minimum call evidence for safety and financial review; and
- notify participants with a safe generic explanation.

The client must not continue media capture after the server ends or revokes the
call authorization.

---

## 7. Moderation actions and enforcement

### 7.1 Enforcement states

The product should distinguish:

```text
normal
warning
limited
content_held
feature_restricted
temporarily_suspended
permanently_suspended
deleted_or_anonymized
under_review
```

These states may apply to an account, profile, message, media item, call, or
feature. The server must define which interactions each state blocks.

### 7.2 Action requirements

Every moderation action records:

- actor and capability;
- target type and opaque target ID;
- action and prior/new state;
- reason code;
- policy and rule version;
- start time, expiry time, and review time where applicable;
- case and evidence references;
- user-notification decision;
- appeal eligibility;
- request/correlation ID; and
- outcome/error.

Moderation actions are append-only. A correction creates a linked action rather
than erasing the original decision.

### 7.3 Temporary restrictions

Temporary restrictions must have:

- clear scope;
- start and expiry timestamps in UTC;
- automatic expiry or scheduled review;
- user-safe explanation;
- support/appeal path where approved;
- audit record; and
- behavior that remains consistent across API, UI, notifications, calls,
  discovery, and messaging.

Do not show an account as permanently removed when it is temporarily restricted,
and do not show a user as safe to transact while a required hold is active.

### 7.4 Permanent enforcement and deletion

Permanent suspension or anonymization requires the approved authority level,
reason, policy version, evidence reference, and appeal decision where applicable.
Financial, legal, safety, and audit retention exceptions remain separate from
the user-facing identity state.

### 7.5 Automated signals

Automated signals may assist triage for spam, velocity, impersonation, fraud,
content safety, or coordinated abuse. They must:

- have an owner and version;
- be monitored for false positives and drift;
- avoid prohibited or unapproved data collection;
- be access-controlled;
- produce safe explanations for operators;
- not expose hidden risk scores to users or targets; and
- not make irreversible high-impact decisions without approved human or policy
  review, unless legal and safety owners explicitly approve the automation.

---

## 8. Appeals, support, and user communication

### 8.1 Appeal eligibility

The product owner and legal/safety reviewers must define which actions can be
appealed. At minimum, the product should provide a route for high-impact account
or host restrictions unless a documented emergency or legal exception applies.

An appeal should include:

- authenticated appellant;
- action/case reference;
- bounded explanation or new evidence;
- submission timestamp;
- review status;
- reviewer independence where practical;
- decision and reason code; and
- next support/escalation path.

The original actor should not be the sole appeal reviewer for a high-impact
action where separation is practical.

### 8.2 User notifications

Enforcement notifications must be:

- accurate about the user-visible state;
- safe about evidence and reporter identity;
- understandable without internal terminology;
- clear about duration or review date where possible;
- explicit about appeal/support options; and
- sent through a protected channel with minimal lock-screen content.

Do not disclose reporter identity, private evidence, internal fraud signals,
moderator personal information, or other users' data.

### 8.3 Support handoff

Support may:

- explain documented status and next steps;
- receive an appeal or correction request;
- route a case to safety, finance, privacy, or legal owners;
- help with account recovery through approved verification; and
- communicate pending deletion or payout states.

Support must not:

- remove a moderation action without capability;
- reveal private evidence or reporter identity;
- request passwords, tokens, or payment secrets;
- alter the financial ledger directly; or
- promise an enforcement or payout outcome it cannot control.

---

## 9. Age, host, and geographic eligibility

### 9.1 Age policy

The launch age policy is unresolved and requires legal/product approval. Before
launch, document:

- minimum user age and regional variations;
- whether age assurance or verification is required;
- what data is collected and retained for age decisions;
- how age-uncertain accounts are restricted;
- host/creator age and verification requirements;
- parental or guardian workflows if applicable;
- prohibited interactions involving minors;
- escalation and reporting obligations; and
- deletion/retention of age-verification evidence.

Do not infer age eligibility from a profile field alone when the approved policy
requires stronger assurance. Do not collect identity documents in ordinary chat
or support channels.

### 9.2 Host eligibility

Before a host can accept eligible calls or earn:

- identity and age eligibility must be approved;
- geography and sanctions/restriction policy must be applied where required;
- payout and tax requirements must be documented;
- safety training or policy acknowledgement must be recorded where required;
- account status, verification, and risk holds must be current; and
- host-facing earnings copy must not imply guaranteed income.

Eligibility state must be server-authoritative and auditable. A client cannot
grant host role, verification, payout availability, or call acceptance rights.

### 9.3 Geographic policy

Region-sensitive rules may affect:

- user onboarding;
- discovery and profile visibility;
- calls and media features;
- payments and taxes;
- host eligibility and payouts;
- age/identity verification;
- retention and privacy rights; and
- emergency or legal escalation.

The API must use an approved region/policy version and fail closed when a
required region decision is unavailable. Do not infer legal eligibility from a
client locale alone.

---

## 10. Abuse, fraud, and coordinated behavior

### 10.1 Abuse categories

The safety program must cover at least:

- spam and bulk outreach;
- harassment and unwanted contact;
- impersonation and identity deception;
- scams, payment fraud, and social engineering;
- exploitation, coercion, and unsafe off-platform requests;
- ban evasion and account farming;
- collusion, self-dealing, artificial call minutes, and referral abuse;
- coordinated reporting or retaliation;
- malicious uploads, malware, and harmful links; and
- moderator, support, or provider abuse.

### 10.2 Signals and safeguards

Signals may include velocity, duplicate content, account-link changes, payment
patterns, call-minute anomalies, report patterns, and provider events. Signals
must be:

- purpose-limited;
- privacy-reviewed;
- access-controlled;
- versioned and monitored;
- separate from public profile or ranking data; and
- subject to human review or documented policy before high-impact action where
  required.

Do not use advertising IDs or stable hardware fingerprints as an undisclosed
general-purpose identity or enforcement system.

### 10.3 Financial safety handoff

Safety or fraud risk may place a hold on purchases, earnings, or payouts only
through the approved finance/safety workflow. The hold must record:

- case/reference ID;
- reason category;
- actor/capability;
- amount or resource scope;
- start/review time;
- appeal/support path; and
- release or compensating action.

Fraud signals do not silently rewrite ledger history or decide final moderation
outcomes without the documented authority.

---

## 11. Emergency and legally required escalation

### 11.1 Emergency path

The product must publish and operate an emergency path appropriate to its launch
regions. Ordinary reports are not emergency services. The workflow must define:

- what qualifies as urgent or critical;
- intake channel and availability;
- on-call owner and backup;
- immediate safety controls;
- evidence preservation;
- provider/account restriction authority;
- external emergency or legal escalation;
- user communication; and
- post-incident review.

Do not promise response times or intervention that the team cannot staff.

### 11.2 Legal requests

Legal or law-enforcement requests must be handled by authorized legal/privacy
owners. The product must:

- verify requester and scope;
- preserve relevant records only under an approved hold;
- disclose the minimum required data through an approved channel;
- document decision, authority, timestamp, and data released;
- protect unrelated users and reporter identity where lawful; and
- avoid ad hoc operator disclosure through chat, email, or database access.

Engineering must not independently determine legal obligations.

### 11.3 Child-safety or exploitation escalation

The launch policy must define the handling, escalation, evidence, access,
retention, and notification rules for suspected exploitation or child-safety
issues. Those workflows require specialist legal/safety review before public
launch and must not be improvised from ordinary report handling.

---

## 12. Safety operations and metrics

### 12.1 Queue operations

The operations team must define:

- queue ownership and assignment rules;
- severity-based service targets;
- staffing and backup coverage;
- moderator training and quality review;
- case merge and escalation rules;
- evidence access review;
- conflict-of-interest handling;
- appeal independence;
- backlog and aging thresholds; and
- outage/manual fallback procedures.

### 12.2 Safety metrics

Track aggregate, privacy-safe metrics such as:

- report volume by category and surface;
- duplicate/invalid report rate;
- time to triage and first review;
- time to enforcement and resolution;
- critical-case escalation time;
- appeal volume, reversal, and modification rates;
- repeat abuse and ban-evasion indicators;
- block effectiveness and blocked-contact attempts;
- moderation queue age and staffing coverage;
- reporter-retaliation signals;
- false-positive/false-negative review samples; and
- evidence-access and operator-action audit anomalies.

Do not use report bodies, private message contents, reporter identity, or raw
device identifiers as ordinary analytics properties.

### 12.3 Safety alerts

Alert the safety/operations owner for:

- critical report or emergency intake;
- report queue or appeal backlog;
- sudden abuse/spam spike;
- repeated report submission failure;
- block or restriction enforcement failure;
- moderator access anomaly;
- evidence storage or retention failure;
- notification of enforcement failure;
- account deletion leaving safety data unresolved; and
- provider or moderation-service outage.

---

## 13. Testing and release evidence

Server-side tests must cover:

- report creation from every supported surface;
- reporter privacy and target projection;
- duplicate report and idempotency behavior;
- block propagation across discovery, messages, calls, and notifications;
- blocked, deleted, suspended, restricted, and deletion-pending accounts;
- moderator/operator capability boundaries;
- evidence access, redaction, export prevention, and audit events;
- temporary enforcement expiry and permanent enforcement;
- appeal submission, assignment, decision, and reversal;
- age/host/geographic eligibility gates;
- emergency control and feature-disable paths;
- fraud/safety hold handoff without ledger corruption; and
- account deletion with safety-retention exceptions.

Device and user-flow tests must cover:

- report and block controls on profile, message, and call surfaces;
- safe acknowledgement and no reporter disclosure;
- permission/network/offline failure during report submission;
- enforcement notifications and deep-link authorization;
- long names, messages, translations, and large fonts;
- accessibility labels and touch targets; and
- support/appeal entry points.

No safety feature is complete until the server-side authorization and privacy
tests pass. A client-only report button is not a safety implementation.

---

## 14. Open policy decisions

Before this document is approved, decide and record:

1. Launch countries, age minimums, and regional age-assurance requirements.
2. Host/creator legal relationship, verification, training, and payout eligibility.
3. Prohibited-content and prohibited-behavior policy.
4. Report categories, severity definitions, SLAs, and emergency coverage.
5. Exact block/unblock behavior for active calls and prior conversations.
6. Temporary restriction, suspension, deletion, and notification policy.
7. Appeal eligibility, reviewer independence, and response targets.
8. Moderator staffing, access scope, quality review, and conflict-of-interest rules.
9. Evidence retention, legal holds, export, and deletion behavior.
10. Automated moderation/fraud signal use and human-review requirements.
11. Law-enforcement, emergency, and child-safety escalation channels.
12. Support handoff, refunds, payout holds, and user communication policy.
13. Public-room safety requirements if live/audio rooms are later approved.

Until these decisions are approved, use the safer defaults in this document and
keep public launch, real money, host payouts, and high-risk media features gated.

---

## 15. Approval checklist

- [ ] Product and legal owners approved the launch regions and age policy.
- [ ] Report, block, moderation, appeal, and emergency paths are documented.
- [ ] Reporter identity and evidence access are protected in API, database, UI,
      operator tools, logs, and notifications.
- [ ] Every enforcement action has actor, reason, target, timestamp, policy
      version, and audit evidence.
- [ ] Role/capability tests cover users, hosts, moderators, support, finance,
      infrastructure, and unassigned operators.
- [ ] Blocked, deleted, suspended, and restricted states are consistent across
      discovery, messaging, calls, notifications, and support.
- [ ] Age, host, geographic, and payout eligibility are server-authoritative.
- [ ] Evidence retention, deletion, legal hold, and export behavior are tested.
- [ ] Safety queues, staffing, SLAs, alerts, and runbooks are ready.
- [ ] Account deletion does not remove required safety or financial records.
- [ ] Automated signals are privacy-reviewed, versioned, and not silently used
      for unapproved high-impact enforcement.
- [ ] No target-specific code, endpoint, asset, credential, or moderation rule
      has been reused.
