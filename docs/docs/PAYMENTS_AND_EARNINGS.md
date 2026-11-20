# Payments and Host Earnings — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed / monetization gated  
**Owner:** Product, finance, and engineering owners to be assigned; legal, tax,
security, privacy, support, fraud, and store-policy review required  
**Last updated:** 2026-10-25  
**Source of truth for:** Prices, virtual credits, store purchases, ledger,
refunds, chargebacks, call settlement, host earnings, payouts, reconciliation,
financial privacy, and monetization release gates  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/OPERATIONS_RUNBOOK.md`,
`docs/DISASTER_RECOVERY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`, `docs/CLEAN_ROOM_RULES.md`,
`docs/ADR/0002-payment-ledger.md`

This document defines an independent monetization and earnings model. It does
not copy target prices, product IDs, provider configuration, purchase flows,
host relationships, or private financial behavior. Static evidence cannot prove
the target's business rules.

This document is not financial, tax, legal, accounting, or store-policy advice.
Real-money purchases, host earnings, and payouts remain disabled until the
required approvals and server-side tests are complete.

---

## 1. Monetization scope and release gates

### 1.1 Decision labels

- **Required:** must be true before the stated release.
- **Proposed:** independent design awaiting approval.
- **Gated:** documented but disabled until policy, legal, provider, and test
  conditions are complete.
- **Sandbox:** test provider/test-account behavior only; no production value.
- **Deferred:** outside the current product release.
- **Unknown:** not established and must not be silently invented.

### 1.2 Monetization rollout

Use this order unless an approved decision changes it:

1. Local seeded economy with clearly labeled demo values.
2. Development ledger with fake purchases, refunds, chargebacks, and payout events.
3. Store sandbox purchases with server-side receipt verification.
4. Internal reconciliation, fraud, refund, support, and deletion tests.
5. Closed testing with test accounts and non-production payout flows.
6. Legal, tax, store-policy, fraud, support, privacy, and incident review.
7. Gradual production rollout with spending, payout, and fraud limits.

The client UI, a provider SDK, or a successful local demo is not approval to
enable real money.

### 1.3 Initial feature gates

| Feature | Local MVP | Development/staging | Production |
| --- | --- | --- | --- |
| Seeded credits | Allowed if marked demo | Allowed with fake ledger | Never represents real value |
| Store product catalog | Static/test only | Sandbox catalog | Approved store catalog and policy version |
| Purchases | Disabled or sandbox | Fake/sandbox receipt flow | Server verification and reconciliation |
| Call billing | Simulated/no charge | Fake provider events | Approved meter and settlement policy |
| Gifts | Deferred/simulated | Fake ledger only | Store/legal/fraud/support approval |
| Host earnings | Simulated projection | Fake settlement events | Approved host policy and ledger |
| Payouts | Disabled | Fake provider outcomes | Identity, tax, fraud, legal, and provider approval |

---

## 2. Business model and unresolved policy

### 2.1 Planning assumption only

The workspace currently records this planning assumption:

```text
User charge:             ₹15 per billable minute = 1,500 paise
Host earning assumption: ₹6 per billable minute =   600 paise
Pre-cost contribution:   ₹9 per billable minute =   900 paise
```

These are not approved prices, promises, payout terms, or legal commitments.
The final rate, currency, taxes, store fees, provider costs, refunds, host
relationship, and payout rules must be versioned and approved before production.

### 2.2 Decisions required before billing

Decide explicitly:

1. Supported countries, currencies, and tax treatment.
2. Whether the product sells credits, subscriptions, tickets, gifts, or another
   entitlement.
3. Store/platform rules for each product type.
4. Billing unit: per second, 30 seconds, full minute, or another unit.
5. Rounding direction and minimum charge.
6. Billable start and stop events.
7. Reconnect grace and one-sided-media treatment.
8. Maximum call duration and user spending limits.
9. Host earning rate and policy version.
10. Host legal relationship, eligibility, identity, tax, and payout requirements.
11. Refund, chargeback, dispute, and negative-balance behavior.
12. App-store fees, payment fees, taxes, currency conversion, and platform fees.
13. Minimum payout threshold, schedule, holds, fees, and reversals.
14. Fraud, collusion, artificial-minute, self-dealing, and refund-abuse policy.
15. Customer-support authority and finance approval separation.

No implementation may silently answer these questions in client code.

### 2.3 Money principles

- Calculate money on the server using integer minor units.
- Store currency with every monetary amount.
- Never use binary floating point for balances or settlements.
- Keep the ledger append-only and correct errors with compensating entries.
- Record policy/rate version for every settlement.
- Treat provider callbacks as duplicated, delayed, reordered, and malicious until
  verified.
- Use idempotency for purchases, fulfillment, refunds, calls, settlements, and
  payouts.
- Never trust client balance, receipt status, call duration, price, host rate,
  or payout amount.
- Show pending, held, disputed, and reversed states honestly.
- Reconcile internal records to provider records on a documented schedule.

---

## 3. Money, product, and policy vocabulary

### 3.1 Monetary terms

| Term | Meaning |
| --- | --- |
| Minor unit | Smallest stored currency unit, such as paise |
| Amount | Signed integer plus currency and policy context |
| Price | User-facing amount for an approved product or usage event |
| Rate | Amount per approved billing unit |
| Fee | Provider, store, payout, or platform deduction |
| Tax | Tax collected, withheld, or reported under approved policy |
| Credit/entitlement | Product-defined access or virtual value, not automatically cash |
| Ledger transaction | Atomic business financial event |
| Ledger entry | Debit/credit line within a transaction |
| Projection | Rebuilt user-facing balance or earnings view |
| Compensating entry | New correcting entry linked to an earlier posted event |

### 3.2 Purchase states

```text
initiated -> submitted -> verifying -> fulfilled
                         |             |
                         v             v
                      rejected       refunded
                         |
                         v
                      pending_retry
```

Provider-specific states map to these application states. Do not expose raw
provider status as the public domain model.

### 3.3 Earnings states

```text
pending -> available -> payout_requested -> paid
    |          |              |             |
    v          v              v             v
 held       reversed        failed       reversed
    |
    v
 disputed
```

Host earnings must not appear withdrawable until the server marks them
`available` under the approved policy.

### 3.4 Policy version

Every active price, billing rule, fee schedule, host rate, refund rule, spending
limit, and payout rule has a version and effective timestamp. Historical calls,
purchases, refunds, earnings, and payouts retain the applied version.

Changing a policy must not rewrite already-posted financial history.

---

## 4. Product catalog and entitlements

### 4.1 Product catalog

The server owns the catalog. A product record should contain:

```text
product_id
product_type
store
store_product_id
display_name_key
description_key
currency
price_minor
entitlement_type
entitlement_amount
policy_version
availability_state
region_scope
valid_from
valid_until
```

The client displays a server-approved catalog projection. It cannot alter
`price_minor`, currency, entitlement amount, host rate, tax, or availability.

Products must be disabled server-side without a client release when there is a
store, legal, fraud, provider, or operational issue.

### 4.2 Entitlements

An entitlement grants an approved product right such as credits, a ticket, a
subscription feature, or another explicitly defined access unit.

Entitlement records should include:

- opaque entitlement ID;
- account owner;
- type and quantity;
- source purchase or grant;
- policy version;
- granted, consumed, expired, revoked, or restored state;
- grant/expiry timestamps;
- idempotency/source references; and
- compensating/reversal links where applicable.

An entitlement is not automatically redeemable for cash. Gifting or transferring
value requires its own approved `GiftTransfer` and ledger rules.

### 4.3 Wallet projection

The wallet is a rebuildable projection, not the ledger source of truth. It may
show:

```text
available_credits
pending_credits
held_credits
expired_credits
last_updated_at
currency_or_unit_definition
```

The API must return the server timestamp and a safe history reference. The client
cannot set, increment, or repair the projection.

---

## 5. Ledger design and invariants

### 5.1 Double-entry model

The ledger must use balanced transactions:

```text
LedgerTransaction
  -> one or more LedgerEntry rows
  -> total debits == total credits
  -> one source business effect
  -> one policy/rate version
  -> one idempotency/deduplication reference
```

Example account classes may include:

```text
user_wallet
platform_revenue
host_pending_earnings
host_available_earnings
store_clearing
refund_reserve
provider_fee
tax_payable
chargeback_reserve
```

The final chart of accounts requires finance approval. The client never chooses
ledger accounts.

### 5.2 Ledger transaction fields

Every posted transaction should include:

```text
ledger_transaction_id
source_type
source_id
idempotency_key
policy_version
currency
created_at_utc
posted_at_utc
status
description_code
actor/source
compensates_transaction_id (optional)
provider_reference (bounded, optional)
```

Each entry includes account, signed integer minor amount, debit/credit side,
currency, and a safe description code. Raw receipts, payment credentials, and
provider payloads are not ledger descriptions.

### 5.3 Invariants

- Every posted transaction balances.
- A source business effect posts at most once per idempotency key.
- A purchase cannot grant the same entitlement twice.
- A refund cannot reverse more than the eligible original value.
- A chargeback creates a traceable compensating transaction.
- A call settles once, with rate/policy version retained.
- Host earnings link to a settled call or approved source effect.
- A payout cannot exceed available eligible earnings.
- Posted entries are immutable.
- Corrections use compensating entries.
- Currency mismatches fail closed.
- Negative balances are allowed only under an approved policy and remain
  visible/reconcilable.

### 5.4 Ledger access

Only the economy/finance service can post financial entries. Other modules issue
typed commands such as:

```text
VerifyPurchase
GrantEntitlement
ConsumeEntitlement
SettleCall
PostRefund
PostChargeback
PlaceEarningHold
ReleaseEarningHold
CreatePayout
ReversePayout
```

Each command is authenticated, authorized, validated, idempotent, audited, and
reconciled.

---

## 6. Store purchase and fulfillment flow

### 6.1 Purchase lifecycle

```text
client selects approved product
        -> store purchase
        -> client receives store reference
        -> server purchase submission
        -> receipt/token verification
        -> pending | rejected | fulfilled
        -> entitlement/ledger projection
```

The client callback is never sufficient to grant value.

### 6.2 Purchase request

Proposed API:

```text
POST /v1/purchases
GET  /v1/purchases/{purchase_id}
POST /v1/purchases/{purchase_id}/restore
GET  /v1/entitlements
```

Purchase submission requires:

- authenticated account;
- approved store and product ID;
- store-issued purchase reference/token;
- idempotency key;
- app/environment compatibility;
- safe client purchase reference where useful; and
- no client-selected amount or entitlement.

The server verifies the purchase with the store/provider, checks ownership and
duplicate fulfillment, validates product/policy version, and then posts the
entitlement/ledger transaction atomically or through a recoverable outbox.

### 6.3 Purchase outcomes

| Outcome | User state | Server behavior |
| --- | --- | --- |
| Valid and new | Fulfilled | Post one entitlement/ledger effect |
| Valid and already fulfilled | Fulfilled | Return existing entitlement; never grant twice |
| Verification pending | Pending | Queue retry/webhook reconciliation; no premature value |
| Invalid or revoked | Rejected | Record safe result; do not grant value |
| Store/provider unavailable | Pending/retryable | Preserve idempotency and retry safely |
| Wrong account/ownership conflict | Rejected/review | Do not disclose unrelated account details |
| Refund/chargeback later | Reversed/held | Post compensating entry and update entitlement policy |

### 6.4 Restore purchases

Restore is a reconciliation request, not a client command to create value. The
server verifies store ownership, maps the purchase to the current account under
the approved account-linking policy, and returns existing or pending
entitlements. Conflicting ownership requires support/finance review.

### 6.5 Store webhook handling

Store events are verified, deduplicated by provider event ID, mapped to an
application command, and processed idempotently. Handle:

- duplicate purchase events;
- delayed fulfillment;
- subscription renewal/cancellation if subscriptions are approved;
- refund and revocation;
- chargeback;
- store account change; and
- unknown event type.

Raw store receipts and provider payloads are sensitive. Retain only the minimum
protected evidence needed for reconciliation, support, tax, or fraud.

---

## 7. Call billing and settlement

### 7.1 Required call policy

Before enabling paid calls, approve `docs/VIDEO_CALL_RULES.md` decisions for:

- billable start event;
- billable stop event;
- billing unit and rounding;
- reconnect grace;
- one-sided media;
- maximum duration;
- insufficient balance;
- spending limits;
- refunds/disputes; and
- provider evidence requirements.

### 7.2 Settlement inputs

The settlement service may use only approved server/provider evidence:

- application call state transitions;
- verified RTC join/leave/reconnect events;
- server-observed connection evidence where approved;
- participant identity and role;
- policy/rate version;
- currency and product configuration;
- approved duration/rounding rule;
- block/suspension/revocation events; and
- prior settlement/idempotency records.

It must not use:

- client-reported duration;
- local timer values;
- client wallet balance;
- client-selected rate or currency;
- unverified provider callback;
- screenshot or UI state; or
- an untrusted device clock.

### 7.3 Settlement flow

```text
call ends or reaches settlement boundary
        -> collect verified call evidence
        -> apply policy/rate version
        -> validate limits and prior effects
        -> calculate integer minor-unit amounts
        -> post balanced ledger transaction
        -> create pending host earning
        -> publish safe history/notification
        -> reconcile provider evidence
```

One source call produces at most one final settlement. If evidence conflicts,
create `reconciliation_required` and stop automatic value movement until the
approved review path resolves it.

### 7.4 Calculation record

Every settlement must preserve:

```text
call_id
settlement_id
policy_version
rate_version
currency
billable_unit
billable_quantity
rounding_rule
user_charge_minor
host_earning_minor
fees_minor
tax_minor
refund_or_hold_reference
evidence_references
calculated_at_utc
posted_at_utc
idempotency_key
```

The user-facing history may show a simplified explanation, but support/finance
must be able to reconcile the calculation without exposing private provider
payloads.

### 7.5 Insufficient balance and spending limits

The product must define behavior when:

- a call request has insufficient balance;
- balance becomes insufficient during a call;
- a daily/monthly limit is reached;
- a purchase is pending;
- a refund or chargeback makes an entitlement unavailable; or
- a provider outage prevents final settlement.

The server may stop new calls, end an active call safely, place settlement in
pending/review, or require a new purchase according to the approved policy. The
client must not continue billing after server authorization ends.

---

## 8. Host earnings and payout rules

### 8.1 Earning creation

Host earnings are created only from an approved settled source effect. An
earning record links to:

- host account and eligibility state;
- call/transaction source;
- applied rate/policy version;
- currency and integer amount;
- pending/available/held/paid/reversed/disputed state;
- refund/chargeback/fraud references;
- hold and release dates; and
- audit/idempotency references.

Host UI must distinguish pending or held amounts from available funds.

### 8.2 Earning availability

Before moving `pending` to `available`, the service checks:

- call settlement finalized;
- refund/chargeback window and policy;
- host identity/age/geographic eligibility;
- account and payout status;
- fraud/collusion/artificial-minute review;
- minimum/maximum limits;
- tax/document status; and
- any safety or legal hold.

An earning may remain pending or held without implying wrongdoing. User-facing
copy must provide a support path and avoid exposing internal risk signals.

### 8.3 Payout eligibility

Payout requests require:

- authenticated eligible host;
- verified payout profile and destination reference;
- available balance above approved threshold;
- no active hold or unresolved dispute;
- rate/velocity and payout limits;
- idempotency key;
- tax/identity requirements; and
- a server-created payout record before provider submission.

Proposed API:

```text
GET  /v1/earnings
GET  /v1/payouts
POST /v1/payouts
GET  /v1/payouts/{payout_id}
```

The client cannot choose payout amount beyond available eligible funds, change
destination, or mark the payout paid.

### 8.4 Payout lifecycle

```text
requested -> eligibility_check -> submitted -> provider_pending -> paid
                                      |              |
                                      v              v
                                    failed         held
                                                       |
                                                       v
                                                  reversed/disputed
```

Provider outcomes are verified and reconciled. A payout failure must not silently
remove available earnings; it must produce a safe retry/support state.

### 8.5 Refunds and chargebacks affecting hosts

When a purchase or call is refunded/charged back:

- identify linked entitlements, settlements, and host earnings;
- apply the approved reversal/hold policy;
- post compensating ledger entries;
- do not edit the original posted entry;
- prevent payout of affected pending funds;
- handle already-paid earnings through an approved recovery/negative-balance or
  platform-loss policy; and
- communicate only the safe user/host explanation.

Legal, tax, and finance owners must approve whether and how already-paid host
earnings can be reversed.

---

## 9. Fraud, abuse, and financial safety

### 9.1 Required review signals

The fraud program may review:

- duplicate or replayed receipts;
- rapid account creation or identity-link changes;
- self-dealing or related-account activity;
- artificial or synchronized call minutes;
- repeated refund/chargeback behavior;
- unusual gift/credit transfers;
- payout destination changes;
- account sharing or takeover signals;
- collusive reports or moderation manipulation; and
- provider reconciliation mismatches.

Signals must be purpose-limited, privacy-reviewed, access-controlled, versioned,
and separate from public profile ranking. Advertising IDs and stable hardware
fingerprints are not approved general-purpose fraud identity.

### 9.2 Holds and review

A hold records:

```text
hold_id
subject_type
subject_id
case_reference
reason_category
amount_or_scope
created_at_utc
review_at_utc
actor_capability
status
release_or_resolution_reference
```

Holds do not silently alter the ledger. Finance/safety operators see only the
minimum information needed for the assigned case, and every access/action is
audited.

### 9.3 Emergency controls

Operations must be able to disable or limit:

- new purchases;
- entitlement fulfillment;
- call billing;
- gifts/transfers;
- host earnings release;
- payout requests; and
- a compromised store, billing, payout, or fraud provider.

Each control has an owner, reason, environment, timestamp, safe user error,
rollback condition, and review record.

---

## 10. Reconciliation and finance operations

### 10.1 Reconciliation schedule

At minimum, reconcile on a schedule approved by finance:

- purchases versus store/provider records;
- fulfilled entitlements versus ledger postings;
- refunds/chargebacks versus wallet and host reversals;
- calls and RTC evidence versus settlements;
- host earnings versus call settlements;
- payouts versus provider outcomes and bank/payment records; and
- ledger balance projections versus append-only entries.

High-risk or high-volume systems may reconcile more frequently.

### 10.2 Reconciliation states

```text
not_started -> running -> matched
                       -> exception -> assigned -> resolved
                       -> blocked_manual_review
```

Exceptions must include safe references, expected/observed counts or amounts,
policy version, owner, severity, next action, and resolution evidence. Never
repair a mismatch by editing posted ledger history.

### 10.3 Financial reports

Produce access-controlled reports for:

- gross purchases and verified fulfillments;
- refunds, chargebacks, and reversals;
- call volume, billable units, and settlements;
- platform/user/host amounts;
- pending/available/held/paid earnings;
- payout failures and outstanding liabilities;
- ledger invariant failures;
- provider reconciliation exceptions; and
- taxes/fees/withholding as approved.

Reports must use UTC and a clear cut-off. They must not include raw receipts or
unnecessary personal data.

### 10.4 Finance/support separation

Support may explain a transaction and open a case. Finance may approve a refund,
adjustment, hold, or payout action only through the approved capability. No
operator should silently edit a balance, ledger entry, earning, or payout.

---

## 11. Financial privacy and user communication

The product must protect:

- purchase tokens and receipts;
- billing identifiers;
- wallet and transaction history;
- host earning and payout details;
- identity/tax verification;
- fraud and risk-review signals; and
- support/finance case notes.

User-facing history should explain:

- product and quantity;
- amount and currency;
- pending/complete/refunded/reversed state;
- relevant date/time;
- safe transaction reference; and
- support route.

It should not expose provider payloads, internal ledger accounts, staff notes,
fraud scores, other users' data, or secrets.

No UI may imply:

- a guaranteed host income;
- immediate withdrawal of pending funds;
- a purchase is complete before verification;
- a refund is complete before provider confirmation; or
- a call was billed using a client timer.

---

## 12. API and data model references

### 12.1 Proposed API routes

```text
GET  /v1/products
GET  /v1/wallet
GET  /v1/wallet/transactions
POST /v1/purchases
GET  /v1/purchases/{purchase_id}
POST /v1/purchases/{purchase_id}/restore
GET  /v1/entitlements
GET  /v1/earnings
GET  /v1/payouts
POST /v1/payouts
GET  /v1/payouts/{payout_id}
POST /v1/webhooks/billing/{provider}
```

These routes remain gated until the rules and approvals in this document are
complete. Request, response, error, authorization, and idempotency behavior is
defined in `docs/API_CONTRACT.md`.

### 12.2 Domain entities

The implementation should use the domain model's:

```text
PricingPolicy
WalletAccount
LedgerAccount
LedgerTransaction
LedgerEntry
Purchase
Entitlement
HostEarning
EarningHold
PayoutProfile
Payout
RefundCase
WebhookEvent
AuditEvent
IdempotencyRecord
```

Exact SQL types, constraints, indexes, RLS, and migrations must be implemented
in the owning service, not inferred from this Markdown alone.

---

## 13. Testing and release evidence

### 13.1 Server-side tests

Required tests include:

- integer-unit and currency validation;
- policy/rate version selection;
- double-entry balance invariants;
- duplicate purchase and receipt replay;
- delayed, duplicated, reordered, invalid, and signed webhook events;
- purchase pending, fulfilled, rejected, refunded, and chargeback paths;
- call settlement start/stop/rounding and one-settlement invariant;
- insufficient balance, spending limits, and concurrency;
- host earning pending/available/held/reversed/disputed transitions;
- payout eligibility, limits, duplicate requests, failures, and reversals;
- fraud/safety hold without ledger corruption;
- account deletion and financial-retention exceptions;
- finance/support/operator capability boundaries; and
- privacy-safe error, log, audit, and transaction-history projections.

### 13.2 Provider/sandbox tests

Use fake or sandbox providers to test:

- purchase verification success/failure/timeout;
- duplicate and out-of-order provider events;
- refunds and chargebacks;
- payout pending/paid/failed/held/reversed;
- RTC settlement evidence and provider outage;
- provider credential rotation; and
- reconciliation after service restart or job retry.

### 13.3 Production monetization gate

- [ ] Product catalog and rates approved.
- [ ] Currency, tax, store, refund, chargeback, and payout policies approved.
- [ ] Host legal relationship, identity, age, region, and tax requirements approved.
- [ ] Ledger and compensating-entry migrations implemented and tested.
- [ ] Receipt/webhook signatures and deduplication tested.
- [ ] Call billing and settlement rules approved and server-tested.
- [ ] Spending, payout, fraud, and emergency limits configured.
- [ ] Reconciliation reports, alerts, and manual-recovery queue operational.
- [ ] Financial privacy, notices, support, and account deletion reviewed.
- [ ] Sandbox/closed testing passes with test accounts.
- [ ] Legal, finance, tax, store-policy, security, privacy, and operations sign-off recorded.

---

## 14. Open decisions

1. Launch currency/regions, tax treatment, and store platforms.
2. Product types: credits, subscriptions, tickets, gifts, or another entitlement.
3. Final user charge, host rate, billing unit, rounding, and policy versioning.
4. Call start/stop/meter/grace rules and maximum spend.
5. Wallet/entitlement expiration and negative-balance behavior.
6. Refund, chargeback, dispute, and already-paid earning recovery.
7. Host legal relationship, identity, age, geography, tax, and payout providers.
8. Minimum payout threshold, schedule, fees, holds, and destination changes.
9. Fraud signals, manual-review thresholds, and appeal policy.
10. Provider data retention, receipt storage, and reconciliation schedule.
11. User/host history, notifications, support, and privacy copy.

---

## 15. Approval checklist

- [ ] No real money is enabled while required policy/legal/finance gates remain open.
- [ ] All money uses integer minor units and explicit currency.
- [ ] Ledger is append-only, balanced, idempotent, and correction-safe.
- [ ] Client cannot choose or mutate price, balance, duration, rate, entitlement, or payout.
- [ ] Purchase, refund, chargeback, call settlement, earning, and payout flows are server-tested.
- [ ] Provider webhooks are signature-verified and deduplicated.
- [ ] Reconciliation and manual recovery are operational.
- [ ] Host earnings are not shown as available before server eligibility.
- [ ] Financial records, receipts, payout data, and fraud signals are privacy-protected.
- [ ] Refunds/chargebacks cannot silently corrupt user or host balances.
- [ ] Legal, tax, store-policy, finance, fraud, support, security, and privacy approvals are recorded.
