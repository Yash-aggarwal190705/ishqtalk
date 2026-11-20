# ADR 0002: Append-Only Payment and Earnings Ledger

**Status:** Proposed / monetization gated  
**Last updated:** 2026-10-26  
**Owner:** Finance, product, engineering, security, and legal owners to be assigned  
**Decision type:** Financial data integrity  
**Related documents:** `docs/PAYMENTS_AND_EARNINGS.md`, `docs/DOMAIN_MODEL.md`,
`docs/API_CONTRACT.md`, `docs/VIDEO_CALL_RULES.md`,
`docs/SECURITY_AND_PRIVACY.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/COST_MODEL.md`

## 1. Context

The product may eventually sell virtual credits or subscriptions, charge for
eligible one-to-one call time, calculate host earnings, issue refunds, process
chargebacks, and request payouts. Client balances, provider callbacks, and
local call timers are not authoritative financial records.

The workspace planning assumption is ₹15 charged to a user and ₹6 attributed to
a host per billable minute, but these numbers are not approved pricing,
earnings, tax, or payout policy.

## 2. Decision

Use an application-owned, append-only, double-entry ledger as the financial
source of truth.

1. Store money as integer minor units plus explicit ISO currency code.
2. Never use binary floating point for balances, rates, settlement, refunds, or
   payouts.
3. Every posted entry records source reference, actor/source, policy version,
   currency, amount, created timestamp, idempotency key, and audit reference.
4. Wallet and earnings balances are projections derived from ledger entries;
   public APIs cannot directly set or increment balances.
5. Correct errors with compensating entries. Never edit or delete a posted
   financial entry solely to change its result.
6. Store the approved pricing/rate/policy version with every call settlement,
   purchase fulfillment, refund, chargeback, earning, and payout transition.
7. Verify store/payment receipts on the server before granting value.
8. Treat provider webhooks as duplicated, delayed, reordered, and untrusted until
   signature and event identity are verified.
9. Require idempotency for purchase fulfillment, call settlement, refunds,
   payout creation, and other value-moving commands.
10. Keep financial records separate from user deletion while retaining the
    minimum required for legal, tax, fraud, support, and reconciliation needs.

## 3. Ledger invariants

- Every transaction has balanced debit and credit entries.
- A transaction has one immutable source reference and one policy version.
- An idempotency key cannot produce two different successful financial effects.
- A duplicate provider event cannot grant value twice.
- A refund or chargeback cannot silently create an unbounded negative balance;
  the approved negative/hold policy applies.
- Call settlement uses server-confirmed billable evidence, not client duration.
- A payout is not `paid` until provider confirmation and reconciliation complete.
- Historical rates and currencies are never rewritten by a later policy change.
- Reconciliation mismatches are visible and route to manual review.

## 4. Application boundary

```text
Store/payment provider -> verified purchase command -> ledger + entitlement
Call service -> server-confirmed settlement command -> ledger + host earning
Refund/chargeback provider -> compensating command -> ledger + entitlement state
Finance operator -> approved compensating/payout command -> audited ledger
Payout provider -> payout result -> payout state + reconciliation record
```

The economy module is the only module allowed to post financial ledger entries.
UI, RTC provider SDKs, payment SDKs, support tools, and direct database access
must not write balances or posted ledger rows.

## 5. Alternatives considered

### 5.1 Store the current balance as a mutable user column

Rejected. Mutable balances lose causality, make retries and corrections unsafe,
and complicate refunds, chargebacks, disputes, and reconciliation.

### 5.2 Trust provider webhooks as the ledger

Rejected. Providers are not the application's source of truth for entitlement
policy, call billing, host earnings, or deletion. Webhooks can be duplicated,
delayed, reordered, missing, or malicious.

### 5.3 Calculate charges on the Android client

Rejected. The client can be modified, backgrounded, disconnected, or replayed.
Server evidence and policy version must determine the result.

### 5.4 Delete or edit bad financial rows

Rejected. Corrections must preserve the audit trail and use compensating entries.

## 6. Consequences

### Positive

- Auditable history for purchases, calls, refunds, earnings, payouts, and
  chargebacks.
- Safe replay and reconciliation after retries or provider outages.
- Historical policy/rate correctness.
- Clear separation between user-facing projections and financial truth.

### Negative

- More schema, transaction, reconciliation, and test work before monetization.
- Finance/support tooling must understand holds, reversals, disputes, and
  compensating entries.
- Negative balances, fraud, tax, currency, and chargeback policy require
  explicit product/legal/finance decisions.

## 7. Required tests

- balanced transaction invariant;
- duplicate purchase fulfillment;
- duplicate, delayed, and reordered webhook events;
- invalid receipt and provider outage;
- insufficient balance and concurrent settlement;
- reconnect and call termination ordering;
- refund, chargeback, reversal, and negative adjustment;
- held, available, reversed, disputed, and paid earnings;
- duplicate payout request and provider payout failure;
- reconciliation mismatch and manual recovery; and
- two-account/operator authorization for all financial reads and writes.

Client-only tests are insufficient for any money-moving behavior.

## 8. Rollout and kill switches

1. Local seeded economy with explicit demo labels.
2. Development ledger with fake provider events.
3. Store sandbox receipt validation and reconciliation.
4. Internal refund, chargeback, settlement, and payout tests.
5. Closed testing with spending and payout limits.
6. Legal, tax, store, fraud, support, security, and finance approval.
7. Gradual production enablement with a kill switch for purchases, settlement,
   and payouts independently.

Disabling a money-moving feature must not delete or corrupt existing ledger
records, entitlements, earnings, or reconciliation evidence.

## 9. Open decisions

- Currency, regions, taxes, store/payment provider, and settlement currency.
- Billing unit and exact billable start/stop evidence.
- Refund/chargeback/negative-balance rules.
- Host legal relationship, eligibility, KYC/tax, fees, holds, and payout timing.
- Financial retention, export, legal hold, and support access.

## 10. Approval checklist

- [ ] Finance and legal owners assigned.
- [ ] Product rate/catalog policy approved separately.
- [ ] Ledger schema and migration reviewed.
- [ ] Receipt/webhook verification and idempotency tests exist.
- [ ] Reconciliation and compensating-entry workflows exist.
- [ ] Payout/fraud/tax/identity controls are approved before payout enablement.
- [ ] `docs/PAYMENTS_AND_EARNINGS.md` and `docs/RELEASE_CHECKLIST.md` match.
