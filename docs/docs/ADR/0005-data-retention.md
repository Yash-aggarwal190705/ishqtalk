# ADR 0005: Classification-Based Data Retention and Deletion

**Status:** Proposed / privacy and legal gated  
**Last updated:** 2026-10-26  
**Owner:** Privacy, legal, security, product, finance, safety, and operations owners to be assigned  
**Decision type:** Data lifecycle and privacy  
**Related documents:** `docs/SECURITY_AND_PRIVACY.md`, `docs/DOMAIN_MODEL.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/ANALYTICS_EVENTS.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/CLEAN_ROOM_RULES.md`

## 1. Context

The product may hold profile data, identity/session records, media, messages,
call metadata, reports, moderation evidence, analytics, payment records,
earnings, payouts, support cases, audit logs, backups, and provider references.
These categories have different purposes, sensitivity, deletion rights,
financial/legal requirements, and safety needs.

The product must not choose one universal retention period or promise immediate
permanent deletion for every record. The supplied target artifact does not
establish an independent retention policy.

## 2. Decision

Adopt classification-based retention with an idempotent account-deletion
workflow and documented exceptions.

1. Every data category has an owner, purpose, classification, access scope,
   retention trigger, deletion/anonymization action, legal/safety hold behavior,
   backup treatment, and evidence source.
2. Collect the minimum data needed for an approved feature.
3. Store canonical timestamps in UTC and use opaque identifiers.
4. Delete, anonymize, or aggregate eligible user-owned data when the approved
   retention period or account-deletion workflow requires it.
5. Retain only the minimum financial, tax, fraud, safety, legal, audit, or
   reconciliation records required by an approved policy.
6. A legal/safety/financial hold prevents eligible deletion only for the scoped
   record and records an actor, reason, timestamp, and review/expiry condition.
7. Backups, queues, caches, search indexes, analytics, provider copies, and
   local device caches have explicit purge or expiry behavior.
8. Deletion jobs are idempotent, observable, retryable, and report unresolved
   exceptions without claiming completion.
9. Privacy requests do not silently modify immutable financial history; they use
   anonymization, restriction, or compensating records where required.

Exact durations remain unapproved until the legal/privacy owners select regions,
purposes, tax obligations, safety needs, and provider terms.

## 3. Initial classification matrix

| Category | Purpose | Default handling | Deletion/hold note |
| --- | --- | --- | --- |
| Account/session | Authentication and security | Restricted access; short-lived sessions | Revoke sessions; retain minimal audit/security evidence |
| Profile/relationship | Product operation and discovery | User-controlled, privacy-filtered | Delete/anonymize according to account policy |
| Media | Profile/message/report feature | Object access control, scan, lifecycle | Delete eligible objects; preserve only scoped safety/legal hold |
| Messages | Communication and safety | Participant/case-limited access | User deletion/redaction policy; safety/legal hold may apply |
| Call metadata | Connection, support, settlement, safety | Minimize content; retain metadata only as needed | Delete/anonymize after approved period; preserve financial/safety evidence |
| RTC/provider references | Reconciliation and troubleshooting | Opaque identifiers and short-lived tokens | Expire tokens; purge provider references when no longer needed |
| Reports/moderation | Safety, enforcement, appeals | Case-based minimum access | Hold or retain only according to safety/legal policy |
| Analytics | Product/reliability/safety measurement | Allowlisted, consent-aware, minimized | Delete/anonymize by event category and policy |
| Purchases/ledger | Entitlement and financial reconciliation | Append-only, finance-limited | Retain as required; compensate rather than delete posted history |
| Earnings/payouts | Host settlement and tax/support | Finance-limited, audited | Retain as required for tax/fraud/reconciliation |
| Support cases | Assistance and dispute handling | Case-limited access | Delete/anonymize after approved support period or hold |
| Audit logs | Security, safety, operations, finance | Append-only, restricted | Retain per security/finance/safety policy |
| Backups | Recovery | Encrypted, access-controlled, expiry | Expire according to backup policy; no indefinite copies |

This matrix is a design baseline, not a legal retention schedule.

## 4. Account-deletion workflow

```text
active
  -> deletion_requested
  -> deletion_pending
  -> data_classification
  -> user_data_deleted_or_anonymized
  -> provider_purge_requested
  -> verification
  -> completed | blocked_for_review | failed_retryable
```

The workflow must:

- authenticate the request and apply account-state restrictions;
- revoke sessions and stop new sensitive actions;
- prevent new purchases, payouts, or calls where policy requires;
- classify profile, media, messages, reports, analytics, support, financial,
  audit, backup, and provider records;
- process each category through an idempotent job;
- record safe status and retention exceptions without exposing private evidence;
- retry failures and route unresolved items to authorized review; and
- mark completion only after required categories and provider requests are
  verified or an approved exception is recorded.

## 5. Alternatives considered

### 5.1 Delete every row immediately

Rejected. It can destroy safety, legal, tax, fraud, financial, audit, or
reconciliation evidence and may leave provider/backup copies inconsistent.

### 5.2 Keep all data indefinitely

Rejected. It violates minimization, increases breach impact and cost, and does
not provide a defensible purpose-based retention model.

### 5.3 Let the mobile client perform deletion

Rejected. Deletion spans server data, providers, queues, backups, analytics,
financial exceptions, and audit records. The server must orchestrate it.

### 5.4 Copy a target retention behavior

Rejected. Target retention was not runtime-verified and is not an independent
legal/privacy decision.

## 6. Consequences

### Positive

- Clear purpose and owner for every data category.
- Deletion can be tested, retried, audited, and supported.
- Safety/financial/legal exceptions are explicit rather than hidden.
- Backups, providers, analytics, and caches are included in lifecycle planning.

### Negative

- Requires data inventory, purge jobs, provider APIs, backup expiry, and
  retention testing.
- Regional policies and legal holds add operational complexity.
- Completion may be asynchronous and users need clear status communication.

## 7. Required tests

- deletion request authentication and idempotency;
- session revocation and prevention of new sensitive actions;
- profile/media/message/analytics purge or anonymization;
- safety/legal/financial retention exceptions;
- provider, queue, cache, search, and backup behavior;
- retry after partial failure and safe completion status;
- support/operator access and audit records;
- export/rectification interaction where approved; and
- no sensitive data in deletion logs or user-safe status responses.

## 8. Open decisions

- Launch regions and applicable privacy/tax/safety obligations.
- Exact retention durations and legal-hold authority.
- Message/media deletion and participant expectations.
- Financial, fraud, payout, and chargeback retention requirements.
- Backup, provider, analytics, search, cache, and device purge guarantees.
- User export, correction, appeal, and support evidence policy.

## 9. Approval checklist

- [ ] Privacy/legal owners assign regional retention requirements.
- [ ] Data inventory maps every category to owner, purpose, access, and action.
- [ ] Account-deletion state machine and jobs are implemented and tested.
- [ ] Financial, safety, legal-hold, backup, and provider exceptions are explicit.
- [ ] Analytics, logs, caches, and crash/support systems have purge behavior.
- [ ] `docs/SECURITY_AND_PRIVACY.md`, `docs/DOMAIN_MODEL.md`, and
      `docs/RELEASE_CHECKLIST.md` match.
