# Cost Model — Independent Social Discovery and Video-Chat App

**Status:** Draft / proposed  
**Owner:** Product/finance/engineering owners to be assigned  
**Last updated:** 2026-10-26  
**Source of truth for:** Cost drivers, unit assumptions, budget guardrails,
measurement, scenario planning, and monetization sensitivity for the
independent product  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/PAYMENTS_AND_EARNINGS.md`,
`docs/VIDEO_CALL_RULES.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/DISASTER_RECOVERY.md`,
`docs/RELEASE_CHECKLIST.md`, `replica/backend.md`, `replica/deploy.md`

This document is a planning model, not a vendor quote, price promise, financial
forecast, tax conclusion, or approval to spend money. Provider prices, store
fees, taxes, currency conversion, legal obligations, support staffing, and
production traffic must be verified before a paid release. All values marked
**Proposed** or **Assumption** require review.

---

## 1. Purpose and decision labels

### 1.1 Objectives

The cost model must help the team:

- estimate the cost of a user action before enabling it;
- separate fixed platform cost from variable usage cost;
- understand gross contribution before taxes, store fees, refunds, fraud,
  payouts, support, and shared overhead;
- set safe traffic, spending, call-minute, storage, and payout limits;
- detect unexpected provider or infrastructure cost quickly;
- compare fake/sandbox, development, staging, and production environments; and
- record assumptions so historical decisions are not silently rewritten.

### 1.2 Decision labels

- **Observed:** measured from an approved environment or provider invoice.
- **Proposed:** a model choice awaiting approval.
- **Assumption:** a temporary planning input, not a promise.
- **Gated:** cannot be used for production pricing or spending until the listed
  policy, provider, finance, tax, or legal review is complete.
- **Unknown:** requires a measurement or provider quote; do not fill it with an
  invented number.
- **Excluded:** intentionally outside the current model boundary.

### 1.3 Accounting boundary

The model separates:

1. user-facing price and collected revenue;
2. store/payment fees, taxes, refunds, chargebacks, and currency effects;
3. host earnings and payout costs;
4. variable infrastructure and provider costs;
5. shared fixed operating costs; and
6. one-time build, legal, audit, migration, and launch costs.

The application's financial ledger remains the source of truth for balances,
entitlements, earnings, and settlements. This document must never be used to
edit ledger entries or calculate a user's balance on the client.

---

## 2. Current product cost posture

### 2.1 Local-first MVP

The current Orbitra Android MVP uses local/seeded data and is not a production
cost baseline. It may measure UI and local device behavior, but it must not be
used to claim production API, database, RTC, billing, payout, storage, push, or
analytics costs.

### 2.2 Server-backed development

Development should use isolated resources, synthetic accounts, fake adapters,
and provider sandboxes where possible. Development cost must be tagged by
environment and feature so it does not look like organic production usage.

### 2.3 Staging and production

Staging should be production-shaped but isolated. Production should have:

- separate projects/namespaces and billing accounts where practical;
- budgets, alerts, quotas, and kill switches;
- resource tags for environment, owner, provider, and feature;
- sampled or synthetic load before costly paths are enabled; and
- a documented approval for every paid provider and recurring commitment.

---

## 3. Unit vocabulary and model inputs

Use stable units so dashboards and invoices can be reconciled:

| Input | Unit | Meaning |
| --- | --- | --- |
| `active_users` | users/month | Users with at least one qualifying activity |
| `new_users` | users/month | New accounts created in the period |
| `sessions` | sessions/month | Authenticated app sessions |
| `api_requests` | requests/month | API requests after retries are counted separately |
| `messages_sent` | messages/month | Accepted application messages |
| `message_notifications` | notifications/month | Push/email/SMS notification attempts |
| `call_requests` | requests/month | Call requests created |
| `connected_call_minutes` | minutes/month | Server/provider-confirmed connected time |
| `billable_call_minutes` | minutes/month | Approved billable unit, if monetization is enabled |
| `media_upload_gb` | GB/month | New uploaded object volume |
| `media_delivery_gb` | GB/month | Download/egress volume |
| `storage_gb` | GB-month | Stored object volume during the period |
| `rtc_participant_minutes` | minutes/month | Provider billing unit, if different from call minutes |
| `moderation_cases` | cases/month | Reports requiring review |
| `support_cases` | cases/month | Support contacts requiring handling |
| `purchase_attempts` | attempts/month | Store/payment attempts including failures |
| `successful_purchases` | purchases/month | Verified, fulfilled purchases |
| `payouts` | payouts/month | Payout instructions created or completed |
| `provider_events` | events/month | Webhook/provider events received |
| `analytics_events` | events/month | Accepted privacy-reviewed events |

Every measured input should include a time window, environment, feature flag
state, provider, unit definition, and source dashboard or invoice.

---

## 4. Cost categories and ownership

| Category | Typical driver | Cost owner | Required evidence |
| --- | --- | --- | --- |
| Compute/API | Requests, CPU, memory, concurrency, runtime | Engineering/operations | Metered usage and deployment record |
| Primary database | Storage, I/O, connections, replicas, backups | Data/operations | Provider usage and backup reports |
| Cache/queue/jobs | Commands, memory, queue volume, job runtime | Backend/operations | Usage, backlog, retry metrics |
| Object storage | Stored GB-month, writes, reads, lifecycle | Media/operations | Storage and lifecycle report |
| CDN/egress | Delivered bytes, region, cache hit rate | Media/operations | Egress and cache dashboards |
| RTC/media | Participant minutes, bandwidth, recording if approved | RTC owner | Provider usage and call metrics |
| Authentication | MAU, verification, recovery, SMS/email attempts | Identity owner | Provider usage and auth metrics |
| Push/email/SMS | Notification attempts, delivered messages | Messaging/operations | Provider usage and delivery metrics |
| Store/payment | Store fee, payment fee, tax, refund, chargeback | Finance owner | Provider settlement and ledger reconciliation |
| Host earnings/payouts | Earning minutes, payout count, payout fee, review | Finance/safety owner | Earnings ledger and payout report |
| Moderation | Automated review, human review, evidence storage | Safety owner | Case volume and staffing/provider report |
| Support | Contacts, handling time, escalation, tooling | Support owner | Case metrics and staffing model |
| Analytics | Events, retention, query/warehouse usage | Analytics owner | Event volume and provider billing |
| Observability | Logs, traces, metrics, crash reports, retention | Operations owner | Usage, retention, and alert report |
| Security/compliance | Scans, audits, KYC/identity, legal work | Security/legal owner | Contract, invoice, and review record |
| Shared overhead | People, tools, legal, insurance, administration | Product/finance | Approved budget allocation |

No category may be omitted merely because a provider's first tier is free.
Free-tier limits, overage rates, retention, data transfer, support plans, and
future price changes must be recorded as risks.

---

## 5. Formula model

### 5.1 Monthly operating cost

```text
variable_cost_month =
    api_cost
  + database_cost
  + cache_queue_job_cost
  + storage_cost
  + media_delivery_cost
  + rtc_cost
  + auth_cost
  + messaging_cost
  + analytics_cost
  + observability_cost
  + moderation_provider_cost
  + payout_provider_cost
  + other_provider_cost

fixed_cost_month =
    committed_infrastructure
  + support_staffing
  + moderation_staffing
  + engineering_operations
  + legal_compliance
  + software_tools
  + insurance_and_administration

operating_cost_month = variable_cost_month + fixed_cost_month
```

### 5.2 Revenue and contribution

Use the finance-approved definition of collected revenue. A planning view may
be expressed as:

```text
gross_user_charge = billable_call_minutes * approved_user_rate_minor_units

net_collected_revenue =
    gross_user_charge
  - sales_tax_or_vat
  - store_or_payment_fees
  - refunds
  - chargebacks
  - currency_and_settlement_adjustments

host_earnings = billable_call_minutes * approved_host_rate_minor_units

pre_shared_cost_contribution =
    net_collected_revenue
  - host_earnings
  - variable_call_and_payment_costs
```

This model must not use binary floating-point for ledger amounts. Forecasting
may use decimals in an approved finance workbook, but posted money uses integer
minor units and the documented rounding rule.

### 5.3 Existing planning assumption

The current workspace planning assumption is:

```text
User charge:             ₹15 per billable minute = 1,500 paise
Host earning assumption: ₹6 per billable minute =   600 paise
Pre-cost contribution:   ₹9 per billable minute =   900 paise
```

These figures are **Assumptions**, not approved prices, earnings promises, tax
rules, or payout commitments. They must not be exposed in a production UI until
product, finance, legal, tax, store, fraud, and support review is complete.

---

## 6. Scenario planning

### 6.1 Required scenarios

Forecast at least:

- low, expected, and high active-user volume;
- low, expected, and high call connection and billable-minute rates;
- low, expected, and high media upload/delivery volume;
- provider outage or failover mode;
- refund and chargeback stress;
- fraud/self-dealing stress;
- payout hold and delayed settlement;
- notification/recovery traffic spike;
- support and moderation case surge; and
- provider price or free-tier change.

### 6.2 Scenario table template

| Scenario | Active users | Billable minutes | Media delivery GB | Reports | Purchases | Key risk |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Low | Unknown | Unknown | Unknown | Unknown | Unknown | Baseline must be measured |
| Expected | Unknown | Unknown | Unknown | Unknown | Unknown | Requires product funnel evidence |
| High | Unknown | Unknown | Unknown | Unknown | Unknown | Capacity and cost spike |
| Provider outage | Unknown | 0 or degraded | Degraded | Increased | Delayed | Safe degradation and support |
| Fraud/refund stress | Unknown | Unknown | Unknown | Increased | Reversed | Ledger and payout exposure |

Do not fill unknowns with target-app observations. Target static evidence may
inform generic feature categories, but it cannot establish independent traffic,
conversion, price, or provider cost.

### 6.3 Sensitivity analysis

At minimum, vary:

- call minutes per active user;
- connection success and reconnect rates;
- user/host rate spread;
- store/payment fee percentage;
- refund and chargeback percentage;
- RTC price per participant-minute;
- media upload and delivery per active user;
- support/moderation cases per 1,000 active users;
- storage retention period; and
- notification provider mix.

Record which variables are observed, estimated, or merely proposed.

---

## 7. Measurement and reconciliation

### 7.1 Required dashboards

Before enabling costly production paths, dashboards should show:

- active users, sessions, API requests, retries, errors, and latency;
- connected and billable call minutes by environment, region, and provider;
- RTC participant minutes, bandwidth, reconnects, and failed calls;
- uploads, stored GB-month, downloads, egress, and cache hit rate;
- messages, notifications, auth/recovery attempts, and provider failures;
- purchase attempts, verified purchases, refunds, chargebacks, and store fees;
- ledger entries, settlement mismatches, host earnings, payouts, and holds;
- moderation and support cases, handling time, and escalation volume;
- analytics events and retention/query usage; and
- provider invoice usage mapped to internal feature and environment tags.

### 7.2 Daily and monthly reconciliation

Daily checks should compare:

- server/API metrics to provider usage;
- connected/billable call minutes to RTC usage and settlement evidence;
- purchase webhooks to verified receipts, entitlements, and ledger entries;
- refunds/chargebacks to compensating ledger entries;
- host earnings to approved billable minutes and policy versions;
- payout instructions to provider outcomes and ledger states; and
- storage/egress dashboards to invoice or provider usage.

Monthly close should record:

- period start/end and timezone/UTC definition;
- provider invoices and currency conversion evidence;
- known credits, free tiers, commitments, and one-time charges;
- unresolved mismatches and owner/date for correction;
- model-versus-actual variance and explanation; and
- updated assumptions with a version, reviewer, and effective date.

The cost model may explain a mismatch, but only the financial ledger and
approved compensating entries change financial state.

---

## 8. Cost controls and safe degradation

Required controls include:

- environment budgets, quotas, and alerts;
- per-user and per-feature rate limits;
- maximum call duration and daily spending limits where approved;
- upload size, media duration, retention, and egress limits;
- provider kill switches and fallback adapters;
- queue backpressure, retry caps, and dead-letter handling;
- log, trace, analytics, and crash-report sampling/retention controls;
- staged enablement for RTC, translation, media processing, and notifications;
- payout holds and manual review thresholds;
- cost-spike incident procedure and owner; and
- a user-safe degraded mode that does not corrupt calls, messages, safety state,
  balances, or audit records.

Do not reduce cost by disabling security, privacy, moderation, reconciliation,
backup, or audit controls without an explicit reviewed decision.

---

## 9. Budget and approval template

```text
model_version:
period_start_utc:
period_end_utc:
environment:
currency:
prepared_by:
reviewed_by:
approved_by:

observed_inputs_source:
provider_quote_sources:
invoice_sources:
assumption_changes:
known_exclusions:
largest_uncertainty:
budget_limit:
alert_threshold:
kill_switch_threshold:
```

Approval must include product, engineering/operations, finance, and security
review for any model that enables paid calls, purchases, payouts, costly media,
or a new provider commitment.

---

## 10. Open decisions before approval

1. Launch regions, currencies, tax treatment, and financial reporting owner.
2. Approved user rate, host rate, billing unit, rounding, refunds, chargebacks,
   and payout policy.
3. RTC, storage, database, authentication, messaging, analytics, moderation,
   observability, payment, and payout providers.
4. Provider contract terms, free tiers, quotas, overages, support plans, and
   price-change protections.
5. User-volume, call-minute, media, support, moderation, and fraud forecasts.
6. Fixed staffing and shared-cost allocation methodology.
7. Cost allocation tags and invoice/reconciliation ownership.
8. Budget limits, alert thresholds, kill switches, and safe degraded behavior.
9. Treatment of one-time launch, legal, audit, migration, and incident costs.
10. Whether and how cost ranges are disclosed internally or to users/hosts.

---

## 11. Approval checklist

- [ ] Finance/product/engineering owners assigned.
- [ ] All inputs are labeled observed, proposed, assumption, gated, unknown, or
      excluded.
- [ ] No vendor price or target-app behavior is presented as verified without
      evidence.
- [ ] Integer minor-unit and ledger boundaries are documented.
- [ ] Provider usage and invoice reconciliation is designed.
- [ ] Budgets, quotas, alerts, kill switches, and cost-spike response exist.
- [ ] Paid-call and payout economics are approved separately from this draft.
- [ ] `docs/ANALYTICS_EVENTS.md` includes the required cost/usage events without
      prohibited personal or financial payloads.
- [ ] `docs/OPERATIONS_RUNBOOK.md` includes cost-spike and provider-outage
      procedures.
- [ ] `docs/RELEASE_CHECKLIST.md` includes the required cost and budget gates.
