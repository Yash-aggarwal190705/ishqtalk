# Production Readiness Checklist — Independent Social Discovery and Video-Chat App

**Status:** Active tracking document / draft program gate  
**Owner:** Product, engineering, security, safety, finance, operations, and legal owners to be assigned  
**Last reviewed:** 2026-10-26  
**Source of truth for:** End-to-end production-readiness progress, blockers,
owners, evidence, approvals, and launch gates  
**Related documents:** `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md`,
`docs/PRODUCT_REQUIREMENTS.md`, `docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`,
`docs/API_CONTRACT.md`, `contracts/openapi/v1/openapi.yaml`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TRUST_AND_SAFETY.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`, `docs/ADR/`

This is the **master program checklist** for moving the independent product
from the current local-first Android MVP to a production-level service. It is
more complete than the per-release `docs/RELEASE_CHECKLIST.md`: this document
tracks the work required to become launchable; the release checklist is used for
one specific build and rollout.

Legal documents are intentionally **not being created in this pass**, as
requested. Their required approvals remain explicit blockers in this checklist.

Do not interpret a checked documentation item as proof that the corresponding
software, provider, operational process, legal approval, or production control
already exists. Every completed item needs evidence in the `Evidence` field or
an approved linked record.

---

## 1. How to use this checklist

### 1.1 Status markers

Use exactly one marker per task:

- `[ ]` **Not started** — work has not begun or has no usable evidence.
- `[~]` **In progress** — implementation/review is active but not complete.
- `[x]` **Complete for this milestone** — acceptance criteria and evidence exist.
- `[B]` **Blocked** — cannot proceed because a required owner, tool, account,
  provider, device, approval, or external decision is unavailable.
- `[G]` **Gated** — implementation may exist, but release is prohibited until a
  policy, legal, financial, safety, security, provider, or test gate is approved.
- `[D]` **Deferred** — explicitly outside the selected release scope.

`[B]`, `[G]`, and `[D]` are not passes. A production launch may proceed only
when the selected release scope permits the item to remain gated/deferred and
the release owner records the decision.

### 1.2 Per-item tracking fields

For every item that is `[~]`, `[x]`, `[B]`, `[G]`, or `[D]`, fill in:

```text
Owner:
Evidence:
Last updated:
Next action:
```

Evidence must be safe to share internally: do not paste credentials, tokens,
private user data, payment receipts, message bodies, private media, or raw
provider payloads into this file.

### 1.3 Milestones

Use these milestone labels consistently:

| Milestone | Meaning |
| --- | --- |
| `M0` | Independent local MVP and documentation baseline |
| `M1` | Server-backed development environment |
| `M2` | Staging and closed-beta rehearsal |
| `M3` | Production non-paid release |
| `M4` | Production paid calls/purchases |
| `M5` | Host earnings and payout release |
| `M6` | Post-launch operating maturity |

No later milestone may be marked complete while an earlier required gate is
missing.

---

## 2. Current baseline — update before every planning session

This snapshot records the known state as of **October 26, 2026**. Update the
status and evidence as work progresses.

| Area | Current status | Evidence / current limitation | Next milestone |
| --- | --- | --- | --- |
| Clean-room static analysis | `[x]` Evidence set documented | `reports/chato-*.md`, CSV, and JSON reports exist; target runtime is not verified | M0 |
| Independent Android MVP | `[x]` MVP exists; not production-ready | `replica-android/`, seeded/local data, debug build path | M0/M1 |
| Flutter client migration | `[x]` Android-first local slice created and checked; production integration absent | `flutter_app/`, `docs/ADR/0006-flutter-client.md`, `flutter_app/build/app/outputs/flutter-apk/app-debug.apk` | M0/M1 |
| Product/architecture/domain drafts | `[x]` Drafts exist; approval pending | `docs/PRODUCT_REQUIREMENTS.md`, `ARCHITECTURE.md`, `DOMAIN_MODEL.md` | M1 |
| API contract | `[x]` Human and executable drafts exist; implementation absent | `docs/API_CONTRACT.md`, `contracts/openapi/v1/openapi.yaml` | M1 |
| Security/privacy plan | `[x]` Draft exists; controls absent in production | `docs/SECURITY_AND_PRIVACY.md`, `SECURITY.md` | M1/M2 |
| Safety/call/payment/analytics/operations/DR plans | `[x]` Drafts exist; execution absent | Corresponding `docs/*.md` files | M1/M2 |
| Test/release/cost/clean-room program docs | `[x]` Drafts exist; evidence index not populated | `docs/TEST_PLAN.md`, `RELEASE_CHECKLIST.md`, `COST_MODEL.md`, `CLEAN_ROOM_RULES.md` | M1 |
| Architecture decision records | `[x]` Proposed ADRs exist; Flutter client direction approved; remaining approvals pending | `docs/ADR/0001` through `0006` | M1 |
| Production backend | `[ ]` Not implemented | No production API, auth service, jobs, or operator service | M1 |
| Database migrations/RLS | `[ ]` Not implemented as production service | `replica/schema.sql` is planning material only | M1 |
| Real authentication/recovery | `[ ]` Not implemented | Local seeded session only | M1 |
| Production messaging/notifications | `[ ]` Not implemented | No approved backend/provider integration | M1/M2 |
| Production RTC | `[G]` Gated and not implemented | Provider, token service, device tests, and policies unresolved | M2/M4 |
| Production billing/ledger | `[G]` Gated and not implemented | Financial policy/provider/ledger implementation unresolved | M4 |
| Host earnings/payouts | `[G]` Gated and not implemented | Legal, tax, identity, fraud, finance, and provider decisions unresolved | M5 |
| Moderation operations | `[ ]` Not implemented | No production queue/operator tooling | M1/M2 |
| Legal documents and approval | `[B]` Intentionally left for later | `legal/` required documents do not yet exist | Before M3 |
| Authorized device/runtime validation | `[B]` Blocked | No usable authorized runtime; current emulator constraints are documented | M2 |
| Production deployment | `[ ]` Not implemented | No approved production environment or provider accounts | M2/M3 |

### 2.1 Current release claim

- [x] The current product is described as an independent local-first MVP.
- [x] The current product is **not** described as production-ready.
- [x] Real-money purchases, host payouts, production RTC, and production
      moderation remain disabled/gated.
- [x] Static target evidence is labeled as evidence, inference, unknown, or
      blocked rather than runtime truth.
- [ ] A production launch claim is permitted. **Do not check until all required
      M3/M4/M5 gates are complete.**

---

## 3. Program governance and ownership

### 3.1 Named owners

- [ ] `GOV-001` Assign product owner and backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-002` Assign engineering/API owner and backend backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-003` Assign mobile owner and device-test backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-004` Assign security/privacy owner and incident backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-005` Assign trust-and-safety owner, moderation lead, and emergency
      escalation backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `GOV-006` Assign finance owner for ledger, refunds, reconciliation, and
      payout controls.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `GOV-007` Assign operations/SRE owner, on-call lead, and disaster-recovery
      backup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `GOV-008` Assign support owner and escalation contacts.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `GOV-009` Assign privacy/legal reviewer. Legal documents remain outside
      this implementation pass but are required before launch.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `GOV-010` Assign release owner and independent go/no-go approvers.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

### 3.2 Operating cadence

- [ ] `GOV-011` Establish a weekly production-readiness review using this file.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-012` Record decisions, blockers, exceptions, and next actions after
      each review.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-013` Create a risk register with severity, owner, mitigation, and
      review date.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-014` Define an exception process with expiry dates; no permanent
      silent exceptions.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `GOV-015` Define release stages and capabilities allowed at each stage.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`

### 3.3 Product decisions

- [ ] `GOV-016` Choose an independent product name and verify that it is not the
      target identity.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-017` Approve launch regions, languages, currencies, and supported
      countries.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `GOV-018` Approve the first-release feature list and explicit exclusions.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `GOV-019` Approve age policy, host eligibility, identity verification,
      geography restrictions, and escalation rules.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M5`
- [ ] `GOV-020` Approve the user/host relationship and payout legal model before
      any earnings UI implies withdrawable funds.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`

---

## 4. Clean-room, provenance, and independent product controls

- [x] `CR-001` Keep target APKs and evidence reports separate from product code.
  Owner: `Engineering` | Evidence: `reports/`, `Chato.apk`, `replica-android/` separation | Target: `M0`
- [x] `CR-002` Document the clean-room boundary and evidence labels.  
  Owner: `Engineering` | Evidence: `docs/CLEAN_ROOM_RULES.md` | Target: `M0`
- [x] `CR-003` Record known target runtime blockers instead of bypassing them.
  Owner: `Engineering` | Evidence: `reports/chato-install-run-test-plan.md`, `docs/TEST_PLAN.md` | Target: `M0`
- [ ] `CR-004` Add a provenance record for every new code, copy, icon, font,
      illustration, audio, video, and third-party dependency.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-005` Add automated scans for target package/deep-link/native-channel
      identifiers and prohibited copied assets.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-006` Add automated secret and private-data scans to local/CI checks.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-007` Review all UI screens for independent layout, copy, iconography,
      colors, typography, media, and interaction decisions.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-008` Review application identifiers, deep links, package identity,
      signing identity, providers, and network configuration for independence.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-009` Quarantine any asset or implementation with unclear provenance;
      do not merge it while review is pending.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `CR-010` Add clean-room review to the per-release checklist.  
  Owner: `TBD` | Evidence: `docs/RELEASE_CHECKLIST.md` update | Target: `M1`
- [ ] `CR-011` Train contributors and agents on `docs/CLEAN_ROOM_RULES.md` and
      record acknowledgement.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`

---

## 5. Product, UX, accessibility, and policy readiness

- [x] `UX-001` Document product scope, user outcomes, and acceptance criteria.
  Owner: `Product` | Evidence: `docs/PRODUCT_REQUIREMENTS.md` | Target: `M0`
- [x] `UX-002` Document loading, empty, offline, retry, unauthorized, blocked,
      deleted, timeout, permission-denied, and provider-failure states.  
  Owner: `Product/Engineering` | Evidence: `docs/PRODUCT_REQUIREMENTS.md`, `docs/TEST_PLAN.md` | Target: `M0`
- [ ] `UX-003` Approve final product name, brand system, voice, typography,
      icons, illustrations, and independent media.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-004` Write independent user-facing copy for onboarding, permissions,
      safety, billing, errors, recovery, deletion, support, and notifications.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-005` Define supported languages and translation review process.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-006` Test long names, long messages, emoji, translated text, right-to-
      left content where supported, and large font settings.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-007` Verify every interactive control has accessible text or a content
      description.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-008` Verify touch targets, focus order, announcements, contrast, and
      status indication that does not rely on color alone.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-009` Test onboarding, consent, permission education, account recovery,
      report/block, deletion, and support flows as a user would use them.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-010` Approve all user-visible capabilities that remain disabled,
      including recording, background calls, effects, translation, and public
      rooms.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `UX-011` Ensure UI never claims a mock provider, seeded economy, or local
      demo is live.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`

---

## 6. Legal, regional, store, and external-approval gates

The legal documents are intentionally deferred from this work. Do not mark the
production release ready until these items are completed by qualified owners.

- [ ] `LEGAL-001` Create and approve `legal/PRIVACY_POLICY.md`. **Blocked by
      request scope; intentionally not created in this pass.**  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `LEGAL-002` Create and approve `legal/TERMS_OF_SERVICE.md`. **Blocked by
      request scope; intentionally not created in this pass.**  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `LEGAL-003` Create and approve `legal/COMMUNITY_GUIDELINES.md`.
      **Blocked by request scope; intentionally not created in this pass.**  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `LEGAL-004` Obtain legal/privacy review for launch regions, age rules,
      host relationship, payments, payouts, data retention, deletion, appeals,
      emergency escalation, and support disclosures.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M5`
- [ ] `LEGAL-005` Complete app-store policy review for authentication, user
      content, reporting, payments, subscriptions, calls, privacy, and age
      suitability.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4`
- [ ] `LEGAL-006` Approve refund, chargeback, taxes, receipts, payout, KYC/
      identity, and financial-support disclosures.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5`
- [ ] `LEGAL-007` Verify privacy, terms, community-guidelines, refund, support,
      and account-deletion URLs in the app and store listing.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `LEGAL-008` Verify regional data-transfer, vendor, age, safety, and
      consumer-protection requirements for every launch region.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `LEGAL-009` Establish legal-hold and emergency preservation contacts and
      response procedure.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`

---

## 7. Architecture, ADRs, and system boundaries

- [x] `ARCH-001` Document the modular-monolith plus workers target shape.  
  Owner: `Engineering` | Evidence: `docs/ARCHITECTURE.md`, `docs/ADR/0001-technology-stack.md` | Target: `M0`
- [x] `ARCH-002` Define UI, domain, repository, API, provider, and operations
      boundaries.  
  Owner: `Engineering` | Evidence: `docs/ARCHITECTURE.md` | Target: `M0`
- [x] `ARCH-003` Define separate local, development, staging, and production
      environments.  
  Owner: `Engineering/Operations` | Evidence: `docs/ARCHITECTURE.md`, `docs/OPERATIONS_RUNBOOK.md` | Target: `M0`
- [x] `ARCH-004` Define provider adapter requirements and fake-provider testing.
  Owner: `Engineering` | Evidence: `docs/ARCHITECTURE.md` | Target: `M0`
- [x] `ARCH-005` Record proposed technology/deployment ADR.  
  Owner: `Engineering` | Evidence: `docs/ADR/0001-technology-stack.md` | Target: `M0`
- [x] `ARCH-006` Record proposed payment-ledger ADR.  
  Owner: `Finance/Engineering` | Evidence: `docs/ADR/0002-payment-ledger.md` | Target: `M0`
- [x] `ARCH-007` Record proposed RTC provider-boundary ADR.  
  Owner: `Engineering/RTC` | Evidence: `docs/ADR/0003-rtc-provider.md` | Target: `M0`
- [x] `ARCH-008` Record proposed moderation-model ADR.  
  Owner: `Safety/Engineering` | Evidence: `docs/ADR/0004-moderation-model.md` | Target: `M0`
- [x] `ARCH-009` Record proposed data-retention ADR.  
  Owner: `Privacy/Engineering` | Evidence: `docs/ADR/0005-data-retention.md` | Target: `M0`
- [ ] `ARCH-010` Approve ADR-0001 with named engineering and operations owners.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `ARCH-011` Approve ADR-0002 before any real money or host earnings.
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `ARCH-012` Approve ADR-0003 before live RTC or call billing.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M4`
- [ ] `ARCH-013` Approve ADR-0004 before real user reports or moderation queue.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `ARCH-014` Approve ADR-0005 before real user data or deletion promises.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `ARCH-015` Document service ownership, data ownership, provider ownership,
      and escalation ownership for every production component.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 8. Backend foundation and environments

- [ ] `BE-001` Choose and document backend language, framework, build tool,
      runtime version, and local developer setup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-002` Create the backend repository/service layout using the approved
      modular boundaries.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-003` Create local environment with fake auth, fake providers, seeded
      data, deterministic clock, and deterministic IDs.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-004` Create isolated development environment with synthetic accounts.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-005` Create isolated staging environment with approved test accounts.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `BE-006` Create production environment only after approvals, budgets,
      secrets, monitoring, backup, and rollback are ready.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `BE-007` Enforce environment-specific API origins, databases, storage,
      providers, analytics, crash reporting, and secrets.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `BE-008` Block production URLs and production provider projects in local,
      development, and test builds.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-009` Add health, readiness, version, dependency, and migration-state
      endpoints with safe responses.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `BE-010` Add structured redacted logging, request IDs, metrics, tracing,
      audit events, and log retention controls.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `BE-011` Add queue/outbox/job system with retry, backoff, dead-letter, and
      manual-recovery paths.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `BE-012` Add feature flags and audited kill switches for calls, purchases,
      payouts, uploads, notifications, and costly providers.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 9. Database, migrations, ownership, and recovery

- [ ] `DB-001` Choose the production relational database and migration runner.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-002` Convert the domain model into versioned production migrations.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-003` Define primary keys, opaque IDs, foreign keys, constraints,
      indexes, uniqueness, check constraints, and deletion behavior.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-004` Implement ownership and row-level security policies for every
      user-owned and operator-owned table.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DB-005` Add audit tables for sensitive account, safety, finance,
      operator, webhook, and deletion actions.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-006` Add idempotency-key storage and request-payload fingerprinting.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-007` Add webhook-event deduplication and safe redacted event envelope.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DB-008` Test every migration on a clean database and representative
      existing data.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DB-009` Measure migration locks, backfill duration, and rollback/forward-
      fix behavior at representative volume.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DB-010` Implement encrypted backups, retention, restore, integrity checks,
      and access logging.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DB-011` Verify that financial records are corrected only through
      compensating entries, never silent edits/deletes.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `DB-012` Verify account deletion distinguishes user-owned data from safety,
      legal, tax, fraud, audit, and financial retention.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `DB-013` Run cross-account authorization and RLS tests for every table and
      operator capability.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`

---

## 10. Authentication, sessions, roles, and recovery

- [ ] `AUTH-001` Choose and approve the authentication provider and account-
      mapping strategy.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-002` Implement account creation, verification, login, refresh,
      logout, session revocation, and revoke-all.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-003` Implement account states: pending verification, active,
      restricted, suspended, deletion pending, and deleted.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-004` Implement recovery with abuse controls, rate limits, safe
      enumeration behavior, and audit records.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `AUTH-005` Implement separate user, host, moderator, support, finance,
      infrastructure, worker, and webhook capabilities.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-006` Enforce token expiration, audience, issuer, scope, revocation,
      clock-skew, and session/device limits.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-007` Verify no advertising ID, raw hardware ID, or stable fingerprint
      is required for identity or authorization.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `AUTH-008` Test two-account authorization for every protected API route.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `AUTH-009` Test blocked, suspended, deleted, restricted, and deletion-
      pending behavior across all protected resources.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `AUTH-010` Test session behavior after app restart, device change, token
      expiry, revoke-all, password/recovery event, and account deletion.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `AUTH-011` Add abuse monitoring and alerting for login, verification,
      recovery, account creation, and suspicious session activity.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 11. API contract, compatibility, and idempotency

- [x] `API-001` Define versioned REST/JSON conventions, response envelopes,
      errors, pagination, retries, and authorization rules.  
  Owner: `Engineering` | Evidence: `docs/API_CONTRACT.md` | Target: `M0`
- [x] `API-002` Create the initial OpenAPI 3.1 draft with fake examples only.
  Owner: `Engineering` | Evidence: `contracts/openapi/v1/openapi.yaml` | Target: `M0`
- [x] `API-003` Validate the OpenAPI draft with Redocly.  
  Owner: `Engineering` | Evidence: `npx --yes @redocly/cli lint contracts/openapi/v1/openapi.yaml` | Target: `M0`
- [ ] `API-004` Confirm final field naming convention (`snake_case` or another
      approved convention) before generating clients.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `API-005` Implement every required route in the approved API contract.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `API-006` Add request validation for type, length, enum, Unicode,
      ownership, authorization, state, and rate limits.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `API-007` Add stable error codes and safe messages without stack traces,
      SQL, provider payloads, tokens, receipts, or private evidence.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `API-008` Implement cursor pagination with documented ordering,
      consistency, expiry, and no duplicate/skip behavior.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `API-009` Require and validate `Idempotency-Key` on every effectful
      command; reject key reuse with a different request payload.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `API-010` Implement safe retry classification and timeout behavior for
      client, server, provider, queue, and webhook operations.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `API-011` Add optimistic-concurrency behavior where profile, message,
      preferences, or operator records can conflict.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `API-012` Add API contract tests for valid, malformed, oversized,
      unauthorized, cross-account, blocked, suspended, deleted, rate-limited,
      retried, and duplicate requests.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `API-013` Add supported-client compatibility and deprecation policy tests.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `API-014` Keep `docs/API_CONTRACT.md` and OpenAPI synchronized in CI.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`

---

## 12. Data model, profiles, discovery, and relationships

- [ ] `DISC-001` Implement account/profile create, read, update, visibility, and
      versioning against the server.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DISC-002` Implement profile media upload intents, scanning, moderation
      state, completion, deletion, quotas, and cleanup.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DISC-003` Implement discovery with server-side eligibility, privacy,
      geography, age, block, deletion, suspension, and host rules.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DISC-004` Define and test independent ranking/filtering behavior; do not
      infer or copy target ranking.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DISC-005` Implement cursor pagination, freshness metadata, cache expiry,
      and stale-result invalidation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DISC-006` Implement follow and favorite desired-state operations with
      idempotency and duplicate suppression.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DISC-007` Implement block precedence across discovery, relationships,
      matching, messages, notifications, calls, and availability.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `DISC-008` Decide whether matching is in the first production release and
      document the independent candidate/decision rules.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `DISC-009` If matching is enabled, implement match attempts, final
      decisions, expiry, duplicate handling, and authorization tests.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DISC-010` Test deleted, blocked, suspended, restricted, private, and
      unavailable profiles across fresh and cached discovery results.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DISC-011` Test long names, Unicode, invalid fields, moderation holds,
      upload failures, and partial profile updates.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 13. Messaging, realtime synchronization, and notifications

- [ ] `MSG-001` Implement direct conversation creation without duplicate
      participant pairs.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `MSG-002` Implement participant authorization, block/suspension/deletion
      checks, privacy state, and conversation lifecycle.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `MSG-003` Implement message validation, length/Unicode limits, attachment
      ownership, rate limits, and moderation state.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `MSG-004` Make message creation idempotent and safe under double taps,
      retries, app restarts, and network timeouts.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `MSG-005` Implement accepted, pending, held, rejected, redacted, deleted,
      delivered, read, and failed message behavior as approved.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `MSG-006` Ensure held/rejected messages are not shown as delivered to the
      recipient.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `MSG-007` Implement read markers, cursor history, ordering, gap recovery,
      and duplicate-event handling.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `MSG-008` Add realtime/push delivery as an advisory mechanism with HTTP
      resynchronization as the source of truth.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MSG-009` Implement notification preferences, device registration,
      revocation, logout, deletion, and minimal lock-screen payloads.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MSG-010` Handle push-provider failure, token invalidation, retry, dead
      letter, and in-app refresh fallback.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MSG-011` Test offline send/read behavior, restored connectivity, process
      death, duplicate events, missing events, and pagination consistency.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MSG-012` Verify logs, analytics, crash reports, and support records never
      contain message bodies or private media URLs by default.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`

---

## 14. Video calls, RTC, permissions, and media safety

Live RTC is gated until provider, device, safety, privacy, security, operations,
cost, and financial decisions are approved.

- [ ] `RTC-001` Select an independent RTC provider through a provider review and
      approve ADR-0003.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-002` Implement an application-owned provider adapter and fake adapter.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `RTC-003` Implement server-side call eligibility: participant state,
      block, host eligibility, availability, concurrency, limits, and provider
      health.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-004` Implement requested, accepted, connecting, connected,
      reconnecting, rejected, expired, canceled, failed, and ended states.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-005` Issue short-lived server tokens scoped to one call, room, and
      participant role; never ship provider secrets in the APK.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-006` Verify token audience, scope, expiry, replay resistance, and
      revocation behavior.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-007` Implement camera/microphone permission education, denial, “don't
      ask again,” revocation, missing hardware, and settings fallback.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-008` Stop camera/microphone capture when a call ends, fails, is
      blocked, or the user leaves the media feature.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `RTC-009` Test network loss, latency, process death, app backgrounding,
      token expiry, provider timeout, provider outage, reconnect grace, and
      safe termination.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M4`
- [ ] `RTC-010` Define and test server-confirmed billable start/stop evidence;
      client timers must not settle money.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `RTC-011` Test block, report, suspension, deletion, and safety action during
      an active call, including provider access revocation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M4`
- [ ] `RTC-012` Approve recording, screenshots, effects, background calls,
      Bluetooth routing, and media-retention policy; keep unsupported features
      disabled.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M4`
- [ ] `RTC-013` Establish call-quality, connection, reconnect, failure, and cost
      dashboards with provider reconciliation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M4`
- [ ] `RTC-014` Complete supported Android device/network matrix and authorized
      manual device tests.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 15. Trust, safety, moderation, and support

- [ ] `SAFE-001` Approve ADR-0004 with named safety, privacy, legal, and
      operations owners.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SAFE-002` Implement private reports for accounts, profiles, messages,
      media, and calls.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SAFE-003` Ensure report receipts reveal only safe status/timestamps and
      never reporter identity or internal evidence.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SAFE-004` Implement block/unblock behavior consistently across discovery,
      relationships, matching, messaging, notifications, calls, and availability.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SAFE-005` Implement case lifecycle, severity, assignment, evidence scope,
      action, dismissal, duplicate handling, and audit history.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SAFE-006` Implement separate moderator, support, finance, and
      infrastructure capabilities with least privilege.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SAFE-007` Implement documented warning, restriction, suspension, removal,
      hold, and appeal actions with reason and actor attribution.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SAFE-008` Define appeal intake, review, deadlines, independence, user
      notice, and outcome handling.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `SAFE-009` Define age, host, geography, identity, fraud, collusion,
      self-dealing, spam, harassment, impersonation, scam, and exploitation
      controls.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M5`
- [ ] `SAFE-010` Define emergency escalation, preservation, legally required
      response, and support/legal handoff.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `SAFE-011` Staff moderation/support coverage and define queue SLAs before
      real user launch.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `SAFE-012` Run moderation, appeal, emergency, false-report, coordinated-
      abuse, and operator-access drills.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `SAFE-013` Verify moderation evidence retention, deletion, legal holds,
      redaction, and access logging.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `SAFE-014` Prepare user-safe support scripts for account, privacy, report,
      block, call, purchase, refund, deletion, and payout cases.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`

---

## 16. Payments, wallet, ledger, purchases, and refunds

Real-money functionality is disabled until finance, legal, tax, store,
security, fraud, support, provider, ledger, and reconciliation gates pass.

- [ ] `PAY-001` Approve pricing currency, regions, product catalog, billing unit,
      rounding, tax, refunds, chargebacks, and policy version.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-002` Approve ADR-0002 with finance, security, product, and legal
      owners.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-003` Implement append-only double-entry ledger with integer minor units,
      explicit currency, source reference, actor, policy version, and idempotency.
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-004` Implement wallet and earnings projections from ledger entries;
      prohibit client balance writes.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5`
- [ ] `PAY-005` Choose and configure store/payment provider sandbox and production
      projects separately.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-006` Implement server-side receipt/purchase-token verification and
      provider event signature validation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-007` Implement duplicate, delayed, missing, reordered, invalid, and
      replayed purchase webhooks safely.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-008` Implement fulfillment idempotency so one purchase grants one
      entitlement/ledger effect.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-009` Implement pending, fulfilled, rejected, refunded, chargeback,
      reversed, and disputed purchase states.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-010` Implement insufficient-balance, spending-limit, pause/kill-switch,
      and provider-outage behavior.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-011` Implement refunds, chargebacks, negative adjustments, and
      compensating entries without editing posted history.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-012` Build user-facing transaction history that explains pending,
      completed, refunded, reversed, and disputed states without private payloads.
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-013` Add ledger invariant, receipt, webhook, refund, chargeback,
      reconciliation, authorization, and retry tests on the server.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-014` Reconcile store/provider records, entitlements, ledger entries,
      refunds, and chargebacks on a scheduled and incident basis.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`
- [ ] `PAY-015` Configure budget, spend, purchase-volume, refund, chargeback,
      and anomaly alerts before enabling production purchases.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4`

---

## 17. Host earnings, identity, fraud, and payouts

Host payouts are a separate release and must not be enabled with the first
purchase release automatically.

- [ ] `EARN-001` Approve host legal relationship, eligibility, age, region,
      identity/KYC, tax, consent, and support requirements.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-002` Define pending, available, held, paid, reversed, disputed, and
      canceled earnings states.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-003` Store approved rate/policy version with every earning and call
      settlement.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-004` Implement server-side earnings calculations from verified
      billable evidence and ledger state.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-005` Implement fraud/self-dealing/collusion/artificial-minute
      detection and manual-review holds.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-006` Choose and configure an approved payout provider with separate
      sandbox/production accounts and failure mapping.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-007` Implement payout eligibility, minimum threshold, schedule,
      destination validation, duplicate prevention, and idempotency.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-008` Implement payout review, hold, processing, paid, failed, and
      reversed states with provider reconciliation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-009` Define chargeback/refund effects on pending and available host
      earnings and already-created payouts.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-010` Add finance/operator authorization and audit tests for earnings,
      holds, refunds, payout creation, and release.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-011` Complete closed testing with test hosts, fake funds, payout
      failures, fraud holds, and reconciliation mismatches.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`
- [ ] `EARN-012` Confirm UI does not imply earnings are guaranteed or immediately
      withdrawable before server availability state.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M5`

---

## 18. Security, privacy, data lifecycle, and clean operations

- [x] `SEC-001` Define server-authoritative trust boundaries and threat model.
  Owner: `Security/Engineering` | Evidence: `docs/SECURITY_AND_PRIVACY.md` | Target: `M0`
- [x] `SEC-002` Define secret-handling, vulnerability-reporting, and incident
      response expectations.  
  Owner: `Security` | Evidence: `SECURITY.md` | Target: `M0`
- [x] `SEC-003` Define data categories, access, retention, deletion, and legal-
      hold requirements.  
  Owner: `Privacy/Security` | Evidence: `docs/SECURITY_AND_PRIVACY.md`, `docs/ADR/0005-data-retention.md` | Target: `M0`
- [ ] `SEC-004` Complete a production threat model with abuse cases, trust
      boundaries, assets, attackers, mitigations, and residual risk.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SEC-005` Complete dependency, license, malware, secret, static-analysis,
      and mobile manifest/security scans.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SEC-006` Enforce HTTPS-only production transport, secure headers, safe
      CORS, request size limits, and protected webhook ingress.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SEC-007` Implement approved secret manager, rotation, access review,
      emergency revocation, and exposure response.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SEC-008` Implement least-privilege operator access, time limits, reason-
      required actions, break-glass audit, and removal workflow.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `SEC-009` Implement account deletion as an idempotent multi-system workflow
      across database, storage, queues, caches, analytics, providers, and backups.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `SEC-010` Test deletion, anonymization, legal/safety/financial retention,
      provider purge requests, backup expiry, and failed retries.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `SEC-011` Verify logs, traces, metrics, analytics, support, crash reports,
      and screenshots are redacted and access-controlled.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `SEC-012` Complete external or independent security review appropriate to
      the launch scope.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4`
- [ ] `SEC-013` Close critical/high security and privacy findings or record
      explicit time-bound exceptions before release.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4`
- [ ] `SEC-014` Verify no target identifiers, proprietary assets, target
      credentials, or private target data entered the release artifact.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`

---

## 19. Analytics, consent, privacy-safe telemetry, and cost measurement

- [x] `AN-001` Define event envelope, event naming, properties, consent,
      retention, and prohibited telemetry.  
  Owner: `Analytics/Privacy` | Evidence: `docs/ANALYTICS_EVENTS.md` | Target: `M0`
- [ ] `AN-002` Choose analytics/crash provider(s) and approve data-processing,
      retention, region, access, and cost decisions.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `AN-003` Implement allowlisted event schemas with versioning and automated
      validation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `AN-004` Enforce consent and regional collection gates; default to no
      unnecessary advertising IDs or stable device fingerprints.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `AN-005` Verify message bodies, private media tokens, payment receipts,
      auth headers, raw hardware IDs, and unnecessary personal data are excluded.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `AN-006` Implement deletion/anonymization/retention automation for events,
      crash records, logs, and dashboards.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `AN-007` Create product, reliability, safety, finance, RTC, storage,
      moderation, and cost dashboards with role-based access.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `AN-008` Define metric names and thresholds for activation, retention,
      message delivery, call success, safety queue, reconciliation, and spend.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `AN-009` Reconcile provider usage, internal events, invoices, call minutes,
      storage, notifications, purchases, refunds, payouts, and support volume.
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5`
- [ ] `AN-010` Test telemetry during consent denial, offline mode, deletion,
      restricted account, provider failure, and app upgrade.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`

---

## 20. Mobile client production hardening

- [x] `MOB-001` Maintain original Android identity, code, branding, copy, and
      seeded data independent from target evidence.  
  Owner: `Mobile` | Evidence: `replica-android/README.md`, `docs/CLEAN_ROOM_RULES.md` | Target: `M0`
- [x] `MOB-002` Maintain reproducible debug build paths for the retained Java MVP
      and the approved Flutter client.  
  Owner: `Solo developer` | Evidence: `replica-android/build_apk.sh`, `flutter_app/README.md` | Target: `M0`
- [x] `MOB-003` Decide the first server-backed mobile client direction and record
      the Flutter migration decision while preserving the Java MVP fallback.  
  Owner: `Solo developer` | Evidence: `docs/ADR/0006-flutter-client.md` | Target: `M1`
- [x] `MOB-003A` Create the independent Flutter Android-first local vertical slice
      with original widgets, local repository state, and a labeled development
      mode.  
  Owner: `Solo developer` | Evidence: `flutter_app/lib/`, `flutter_app/README.md` | Target: `M0`
- [x] `MOB-003B` Verify the Flutter client with analyzer, widget tests, and a
      debug Android APK build.  
  Owner: `Solo developer` | Evidence: `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`,
      `flutter analyze`, `flutter test`, `flutter build apk --debug` | Target: `M0`
- [ ] `MOB-004` Replace seeded sessions/data with secure server-backed repositories
      while retaining a clearly separated fake/local mode.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `MOB-005` Implement secure session storage, refresh, revoke, logout, and
      deletion behavior on the client.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `MOB-006` Implement loading, empty, offline, retry, unauthorized, blocked,
      deleted, timeout, permission-denied, and provider-error UI states.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `MOB-007` Review manifest permissions, exported activities/services,
      backup rules, deep links, network security, logging, and release build
      configuration.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `MOB-008` Configure release signing and protected key handling without
      committing keystores or signing credentials.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `MOB-009` Add crash reporting with symbol/mapping upload and privacy-safe
      metadata.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `MOB-010` Test fresh install, upgrade, relaunch, logout, token expiry,
      backgrounding, process death, device restart, and account deletion.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MOB-011` Test supported Android versions, screen sizes, large fonts,
      screen readers, touch targets, contrast, localization, and network states.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MOB-012` Complete authorized physical-device/manual checks; do not convert
      an APK build into camera, microphone, RTC, push, billing, or background
      claims.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `MOB-013` Complete store listing, icon, screenshots, support URL, package
      identity, privacy links, and release metadata review.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`

---

## 21. Testing and quality evidence

- [x] `TEST-001` Define the layered test strategy and release-stage gates.  
  Owner: `QA/Engineering` | Evidence: `docs/TEST_PLAN.md` | Target: `M0`
- [x] `TEST-002` Define test data rules, evidence labels, defect severity, and
      minimum evidence record.  
  Owner: `QA/Engineering` | Evidence: `docs/TEST_PLAN.md` | Target: `M0`
- [ ] `TEST-003` Implement CI static checks: formatting, lint, type/compile,
      schema validation, secret scans, dependency checks, and license checks.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `TEST-004` Implement unit tests for validation, state machines,
      authorization, idempotency, pricing, rounding, ledger, deletion, and
      moderation rules.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `TEST-005` Implement repository/integration tests for migrations, RLS,
      queues, webhooks, storage, and provider adapters.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `TEST-006` Implement API contract tests for every executable route,
      including two-account authorization and safe errors.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `TEST-007` Implement duplicate, delayed, missing, reordered, malformed,
      and replayed webhook/job tests.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `TEST-008` Implement security/privacy tests for access isolation, deletion,
      redaction, rate limits, sessions, roles, and provider tokens.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `TEST-009` Implement safety tests for reports, blocks, enforcement,
      appeals, evidence access, emergency escalation, and audit.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `TEST-010` Implement server-side financial tests for purchases, receipts,
      ledger, refunds, chargebacks, call settlement, earnings, payouts, and
      reconciliation.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5`
- [ ] `TEST-011` Implement device/E2E tests for onboarding, auth, discovery,
      messaging, report/block, calls, permissions, deletion, notifications, and
      supported accessibility behavior.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `TEST-012` Implement load/performance tests for API, database, discovery,
      messaging, queues, notifications, RTC token issuance, and webhooks.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `TEST-013` Implement chaos/failure tests for provider outages, database
      failures, queue backlog, network loss, clock skew, storage failure, and
      recovery.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `TEST-014` Track every test with build, commit, environment, device,
      fixture, provider mode, timestamp, result, and safe evidence location.
  Owner: `TBD` | Evidence: `TBD` | Target: `M1`
- [ ] `TEST-015` Close or explicitly accept all critical/high defects before the
      applicable release; never weaken tests to pass.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`

---

## 22. Deployment, operations, observability, and support

- [x] `OPS-001` Define environment separation, access boundaries, deployment,
      incident, job, provider, support, finance, and safety procedures.  
  Owner: `Operations` | Evidence: `docs/OPERATIONS_RUNBOOK.md` | Target: `M0`
- [x] `OPS-002` Define proposed service tiers, RTO/RPO, degraded mode, restore,
      and recovery evidence.  
  Owner: `Operations` | Evidence: `docs/DISASTER_RECOVERY.md` | Target: `M0`
- [ ] `OPS-003` Set up reproducible CI/CD builds with protected environments,
      approvals, artifact storage, and deployment audit trail.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M1/M2`
- [ ] `OPS-004` Implement separate deployment pipelines for local, development,
      staging, and production.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `OPS-005` Add database migration rehearsal, approval, lock monitoring,
      rollback/forward-fix, and release evidence.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `OPS-006` Create dashboards for startup/crash, API, auth, messaging,
      notifications, RTC, safety, payments, ledger, payout, storage, queues,
      database, and provider costs.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `OPS-007` Configure alerts with severity, owner, threshold, runbook,
      escalation, and safe test procedure.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `OPS-008` Establish on-call coverage, incident commander rotation, support
      handoff, safety escalation, finance escalation, and provider contacts.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `OPS-009` Run incident drills for API degradation, auth abuse, database
      failure, queue backlog, webhook failure, RTC outage, notification failure,
      moderation incident, ledger mismatch, secret exposure, deletion failure,
      and cost spike.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `OPS-010` Implement safe shutdown controls for new calls, purchases,
      payouts, uploads, notifications, discovery expansion, and costly providers.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `OPS-011` Verify all operational actions are least-privilege, reasoned,
      time-limited, auditable, and reversible where possible.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `OPS-012` Create user/support communication templates for outages,
      maintenance, delayed purchases, calls, deletion, safety, and payouts.
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`
- [ ] `OPS-013` Verify production logs exclude secrets, tokens, message bodies,
      private media URLs, receipts, and unnecessary personal data.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`

---

## 23. Backup, disaster recovery, and business continuity

- [x] `DR-001` Define recovery scope, proposed service tiers, degraded mode,
      recovery completion criteria, and evidence expectations.  
  Owner: `Operations` | Evidence: `docs/DISASTER_RECOVERY.md` | Target: `M0`
- [ ] `DR-002` Approve RTO/RPO targets with product, finance, safety, security,
      and operations owners.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DR-003` Implement automated encrypted database backups and backup-age
      monitoring.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DR-004` Implement object-storage versioning/lifecycle/restore behavior
      for approved media and metadata.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DR-005` Back up or recreate secrets, certificates, deployment configuration,
      migrations, queue/outbox state, and provider configuration safely.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DR-006` Perform clean-environment database restore and integrity checks.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `DR-007` Perform failover/degraded-mode exercise for API, database, storage,
      queue, notifications, RTC, billing, and provider outages.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `DR-008` Verify idempotency/outbox/webhook/job replay after restore or
      failover.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `DR-009` Verify financial, safety, authorization, deletion, and audit
      invariants after recovery.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`
- [ ] `DR-010` Document communication, support, status, and post-recovery review
      process.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `DR-011` Run recurring recovery exercises and retain evidence with owner,
      date, result, and corrective actions.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M6`

---

## 24. Cost, capacity, quotas, and provider management

- [x] `COST-001` Define cost categories, unit vocabulary, scenario model,
      reconciliation, and control principles.  
  Owner: `Finance/Engineering` | Evidence: `docs/COST_MODEL.md` | Target: `M0`
- [ ] `COST-002` Obtain current provider quotes/terms for compute, database,
      storage, egress, RTC, auth, push, email, analytics, moderation, billing,
      payout, and support tooling.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `COST-003` Define low, expected, high, outage, refund/chargeback, and fraud
      stress scenarios with observed/assumed inputs labeled.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `COST-004` Set environment budgets, quotas, alerts, spend limits, call
      limits, upload limits, storage retention, and provider kill switches.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `COST-005` Measure API requests, retries, active users, messages, calls,
      RTC minutes, storage, egress, notifications, purchases, refunds, payouts,
      moderation, support, analytics, and provider usage.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `COST-006` Reconcile internal usage with provider invoices and identify
      credits, free tiers, overages, commitments, and currency effects.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`
- [ ] `COST-007` Define cost-spike response, safe degradation, and feature
      disablement without weakening safety, privacy, ledger, or recovery.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `COST-008` Approve paid-call economics separately from the planning
      assumption of ₹15 user charge / ₹6 host earning per billable minute.
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5`
- [ ] `COST-009` Review unit economics and capacity after staging load tests and
      before every paid rollout expansion.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M4/M5/M6`

---

## 25. Release, store, rollout, and go/no-go

- [x] `REL-001` Define release identity, approvals, build evidence, rollout,
      rollback, go/no-go, and post-release checks.  
  Owner: `Release/Engineering` | Evidence: `docs/RELEASE_CHECKLIST.md` | Target: `M0`
- [ ] `REL-002` Select the release stage: local MVP, development, staging,
      production non-paid, paid calls/purchases, or payouts.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3/M4/M5`
- [ ] `REL-003` Record release ID, product/server versions, commit, artifact
      digests, migration range, feature flags, environment, owners, and rollout
      window.  
  Owner: `TBD` | Evidence: `TBD` | Target: Every release
- [ ] `REL-004` Verify clean-checkout reproducibility, locked dependencies,
      generated artifacts, release signing, symbols, and provenance.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `REL-005` Verify no debug endpoints, seeded production data, development
      credentials, test flags, target identifiers, or provider secrets ship.
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `REL-006` Complete all required product, architecture, security, privacy,
      safety, API, mobile, RTC, finance, analytics, operations, DR, cost, store,
      and legal approvals for the selected scope.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`
- [ ] `REL-007` Verify privacy, terms, community-guidelines, refund, support,
      and account-deletion links are valid.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M3`
- [ ] `REL-008` Run full staging regression with test accounts, fake/sandbox
      providers, device matrix, failure cases, accessibility, and recovery.
  Owner: `TBD` | Evidence: `TBD` | Target: `M2`
- [ ] `REL-009` Complete closed beta with support, safety, incident, and data-
      deletion drills.  
  Owner: `TBD` | Evidence: `TBD` | Target: `M2/M3`
- [ ] `REL-010` Define rollout percentages, stop conditions, observation window,
      rollback target, forward-fix plan, and in-flight operation handling.
  Owner: `TBD` | Evidence: `TBD` | Target: `M3/M4/M5`
- [ ] `REL-011` Confirm no critical/high unresolved issue violates safety,
      authorization, privacy, data integrity, financial correctness, or legal
      release requirements.  
  Owner: `TBD` | Evidence: `TBD` | Target: Every release
- [ ] `REL-012` Record explicit go/no-go decision with approvers, exceptions,
      evidence index, rollback authority, and next review time.  
  Owner: `TBD` | Evidence: `TBD` | Target: Every release

---

## 26. Launch-day and post-launch monitoring

### 26.1 Launch-day checks

- [ ] `LAUNCH-001` Confirm the exact artifact, commit, environment, flags,
      migrations, provider configuration, and owner roster.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day
- [ ] `LAUNCH-002` Confirm dashboards, alerts, on-call, support, safety, finance,
      and incident channels are staffed and tested.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day
- [ ] `LAUNCH-003` Confirm backups are current and restore evidence is within the
      approved age.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day
- [ ] `LAUNCH-004` Confirm kill switches, rate limits, spending limits, payout
      holds, fraud controls, and safe degraded modes are active.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day
- [ ] `LAUNCH-005` Run smoke tests for startup, auth, profile, discovery,
      messaging, reports/blocks, deletion status, notifications, calls, and
      approved financial flows.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day
- [ ] `LAUNCH-006` Confirm support and user communication copy for known limits,
      pending states, outages, refunds, safety, and deletion.  
  Owner: `TBD` | Evidence: `TBD` | Target: Launch day

### 26.2 First 24 hours

- [ ] `LAUNCH-007` Review crash-free sessions, startup failures, API errors,
      latency, auth failures, rate limits, queues, and database health.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours
- [ ] `LAUNCH-008` Review message delivery, notifications, RTC connection,
      reconnect, call endings, and provider error rates if enabled.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours
- [ ] `LAUNCH-009` Review reports, blocks, moderation queue age, appeals,
      emergency escalations, support cases, and abuse signals.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours
- [ ] `LAUNCH-010` Review purchases, refunds, chargebacks, ledger invariants,
      earnings, payouts, webhooks, and reconciliation if enabled.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours
- [ ] `LAUNCH-011` Review provider usage, storage, egress, analytics, staffing,
      and cost against the approved model.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours
- [ ] `LAUNCH-012` Decide continue, pause, rollback, or forward-fix and record
      the decision with evidence.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 24 hours

### 26.3 First 7 and 30 days

- [ ] `LAUNCH-013` Complete seven-day reliability, safety, support, finance,
      privacy, cost, and provider review.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 7 days
- [ ] `LAUNCH-014` Complete 30-day post-launch review against product,
      reliability, safety, financial, operational, and cost objectives.  
  Owner: `TBD` | Evidence: `TBD` | Target: First 30 days
- [ ] `LAUNCH-015` Update this checklist, source-of-truth documents, risks,
      assumptions, runbooks, and next milestone based on observed operation.
  Owner: `TBD` | Evidence: `TBD` | Target: `M6`

---

## 27. Evidence index

Keep a link or workspace-relative path for every completed gate. Use redacted
reports and do not put secrets or private user data in the index.

| Evidence ID | Description | Path/link | Date | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| `E-001` | Clean-room static evidence | `reports/` | 2026-10-25 | Engineering | `[x]` |
| `E-002` | Product requirements draft | `docs/PRODUCT_REQUIREMENTS.md` | 2026-10-25 | Product | `[x]` |
| `E-003` | Architecture draft and ADRs | `docs/ARCHITECTURE.md`, `docs/ADR/` | 2026-10-26 | Engineering | `[x]` |
| `E-004` | Human-readable API contract | `docs/API_CONTRACT.md` | 2026-10-26 | Engineering | `[x]` |
| `E-005` | OpenAPI lint result | `contracts/openapi/v1/openapi.yaml` and command output | 2026-10-26 | Engineering | `[x]` |
| `E-006` | Security/privacy draft | `docs/SECURITY_AND_PRIVACY.md`, `SECURITY.md` | 2026-10-26 | Security | `[x]` |
| `E-007` | Safety/call/payment/analytics/operations/DR drafts | Corresponding `docs/*.md` files | 2026-10-26 | Owners TBD | `[x]` |
| `E-008` | Test/release/cost/clean-room plans | Corresponding `docs/*.md` files | 2026-10-26 | QA/Release | `[x]` |
| `E-009` | Android MVP build evidence | `replica-android/`, `replica/build-log.md` | `TBD` | Mobile | `[~]` |
| `E-010` | Backend development environment | `TBD` | `TBD` | Backend | `[ ]` |
| `E-011` | Staging regression report | `TBD` | `TBD` | QA | `[ ]` |
| `E-012` | Security/privacy review | `TBD` | `TBD` | Security | `[ ]` |
| `E-013` | Safety operations drill | `TBD` | `TBD` | Safety | `[ ]` |
| `E-014` | Restore/failover exercise | `TBD` | `TBD` | Operations | `[ ]` |
| `E-015` | Legal/store approval bundle | `TBD` | `TBD` | Legal/Release | `[B]` |
| `E-016` | Production go/no-go record | `TBD` | `TBD` | Release | `[ ]` |

---

## 28. Current blockers and next actions

### 28.1 Blocking production readiness now

- [ ] Production backend and server-side authorization do not exist.
- [ ] Production database migrations, RLS, audit records, and recovery do not
      exist.
- [ ] Real authentication, recovery, and device/session management do not exist.
- [ ] Production messaging, notifications, storage, and moderation operations do
      not exist.
- [ ] RTC provider, server token service, device matrix, and reconnect evidence
      do not exist.
- [ ] Payments, ledger, receipt validation, refunds, chargebacks, reconciliation,
      earnings, and payouts do not exist.
- [ ] Legal documents and required external approvals remain intentionally
      deferred and are launch blockers.
- [ ] Authorized device/runtime validation remains unavailable.
- [ ] Production environment, provider accounts, secrets, monitoring, backups,
      and on-call ownership are not established.

### 28.2 Recommended next execution order

1. Assign owners and approve the M1 scope.
2. Choose backend/database/authentication technologies under ADR-0001.
3. Implement the backend foundation, migrations, RLS, sessions, profiles,
   discovery, relationships, conversations, messages, reports, blocks, and
   deletion status.
4. Add API contract tests and server-side authorization/idempotency tests.
5. Create development and staging environments with fake/sandbox providers.
6. Obtain an authorized device/runtime and complete mobile/accessibility/
   permission tests.
7. Approve and implement RTC only after safety, privacy, cost, and device gates.
8. Approve and implement purchases/ledger only after finance/store/legal gates.
9. Approve and implement host earnings/payouts only after identity, tax, fraud,
   support, and reconciliation gates.
10. Create the legal documents and obtain regional/store approvals before M3.
11. Run staging regression, recovery drills, closed beta, and the go/no-go review.

---

## 29. Completion rule

The product may be called **production level** only when:

- all required M3 items are `[x]` or have an explicitly approved, time-bound
  exception;
- all enabled M4/M5 capability items are `[x]` with server-side evidence;
- no critical/high security, privacy, safety, authorization, data-integrity, or
  financial defect remains unresolved;
- legal/store/privacy/community/support gates are approved for the launch region;
- staging regression, device testing, backup restore, recovery drills,
  reconciliation, and incident drills have actual evidence;
- production owners, on-call, budgets, quotas, kill switches, support, safety,
  finance, and rollback procedures are active; and
- the release owner records a signed go/no-go decision in
  `docs/RELEASE_CHECKLIST.md`.

Until then, describe the product as an independent MVP, development build,
staging build, or gated prototype according to the evidence—not as production
ready.

---

## 30. Review log

| Date | Reviewer(s) | Summary | Blockers added/closed | Next review |
| --- | --- | --- | --- | --- |
| 2026-10-26 | Coding assistant | Created the master production-readiness checklist from the current clean-room, product, architecture, API, security, safety, payments, operations, test, cost, and recovery documents. | Initial production blockers recorded; legal documents intentionally left out of scope. | `TBD` |
