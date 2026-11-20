# ADR 0004: Case-Based Trust and Safety Moderation

**Status:** Proposed / safety gated  
**Last updated:** 2026-10-26  
**Owner:** Trust/safety, product, legal, privacy, and operations owners to be assigned  
**Decision type:** Safety operations and authorization  
**Related documents:** `docs/TRUST_AND_SAFETY.md`, `docs/SECURITY_AND_PRIVACY.md`,
`docs/PRODUCT_REQUIREMENTS.md`, `docs/API_CONTRACT.md`,
`docs/DOMAIN_MODEL.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/TEST_PLAN.md`,
`docs/RELEASE_CHECKLIST.md`, `docs/CLEAN_ROOM_RULES.md`

## 1. Context

The product may include profiles, messages, media, calls, reports, blocks,
moderation actions, appeals, host eligibility, and emergency escalation. Static
analysis may suggest generic report/block capability, but it does not establish
the target's moderation rules, staffing, evidence access, or legal obligations.

Safety decisions require minimum-necessary evidence, role separation, privacy,
consistent enforcement, auditability, appeals, and operational response. A
single broad `admin` role is not sufficient.

## 2. Decision

Adopt a case-based moderation model with immediate user controls and a separate
human/operator review workflow.

1. Users can report eligible accounts, profiles, messages, media, and calls
   without revealing reporter identity to the reported user.
2. Blocks apply immediately to the documented discovery, relationship,
   messaging, notification, call, and availability surfaces.
3. A report creates a private `SafetyCase` with target, reason, severity,
   evidence references, reporter scope, status, timestamps, and audit history.
4. Moderators receive only assigned/minimum evidence and use separate
   capabilities from support, finance, and infrastructure operators.
5. Enforcement actions are explicit, scoped, reasoned, timestamped, reversible
   only through an authorized path, and visible to the appropriate audit trail.
6. Users receive safe status/decision explanations and an appeal path where the
   policy allows one. Private reporter identity and internal evidence remain
   protected.
7. Automated content/risk systems may triage or hold content, but a provider or
   model cannot silently become the final application policy.
8. Emergency and legally required escalations have a separate protected path,
   preservation rules, named owner, and support/legal handoff.

## 3. Roles and capability separation

| Capability | Can do | Cannot do by default |
| --- | --- | --- |
| User/viewer | Report, block, appeal, view own safe case status | View reporter identity or internal evidence |
| Host | Manage approved availability/profile and receive host support | Override safety enforcement |
| Moderator | Review assigned safety cases and apply documented actions | Read unrelated private messages, edit ledger, deploy systems |
| Support | Handle approved account/support workflows | Apply hidden moderation or edit financial history |
| Finance | Reconcile approved financial cases and payouts | Read unrelated message content or change moderation decisions |
| Infrastructure | Operate systems and recovery | Routine access to private content or silent user-state mutation |
| Safety worker | Process queued/automated transitions | Grant itself operator access |

Every sensitive action records actor, capability, reason, target, scope, time,
and audit reference.

## 4. Enforcement states

The application should model states such as:

```text
reported -> queued -> assigned -> investigating -> actioned | dismissed | duplicate
actioned -> restricted | suspended | removed | warning | no_action
actioned -> appealed -> upheld | modified | overturned
```

The exact state names and user notice policy remain proposed. A client cannot
clear a restriction or invent an enforcement result.

## 5. Alternatives considered

### 5.1 User-only report inbox

Rejected. It lacks evidence access control, prioritization, enforcement audit,
appeals, emergency handling, and operational ownership.

### 5.2 One broad administrator role

Rejected. It violates least privilege and increases access to messages,
financial data, private reports, and infrastructure beyond the case need.

### 5.3 Fully automated moderation

Rejected. Automation may assist triage, but false positives, appeals, context,
emergency escalation, and provider failure require human and policy controls.

### 5.4 Copy target moderation/ranking behavior

Rejected. Target behavior is not established by static analysis and cannot be
copied under the clean-room rules.

## 6. Consequences

### Positive

- Immediate user safety controls do not wait for human review.
- Case scope, role separation, privacy, audit, and appeals are explicit.
- Safety operations can work with fake/test evidence before production data.
- Automated providers remain replaceable and subordinate to application policy.

### Negative

- Requires staffing, training, case tooling, evidence retention, and escalation.
- Moderation rules and response times vary by region and legal requirement.
- The system must handle false reports, coordinated abuse, privacy requests,
  deleted accounts, and evidence holds.

## 7. Required tests

- reporter privacy and cross-account evidence isolation;
- block precedence across every interaction surface;
- duplicate report/idempotency and rate limits;
- moderator/support/finance/infrastructure role separation;
- assignment, action, appeal, expiry, and audit transitions;
- deleted, suspended, restricted, and blocked account behavior;
- private messages/media/call evidence minimization;
- emergency escalation and preservation;
- automated provider timeout, false result, and outage;
- notification of decisions without leaking internal evidence; and
- account deletion/retention interaction with safety cases.

## 8. Open decisions

- Launch regions, age/host eligibility, and legal escalation obligations.
- Moderation staffing, queue SLAs, severity taxonomy, and coverage hours.
- Automated provider scope, model review, false-positive handling, and cost.
- Evidence retention, export, deletion, legal hold, and moderator tooling.
- Appeal availability, deadlines, review independence, and user notice copy.

## 9. Approval checklist

- [ ] Safety/legal/privacy owners assigned.
- [ ] Role/capability matrix and audit events implemented.
- [ ] Report/block/enforcement/appeal workflows tested server-side.
- [ ] Emergency escalation and evidence preservation are operationally owned.
- [ ] Minimum-necessary evidence and retention decisions are approved.
- [ ] Moderation queue and support handoff are available before user launch.
- [ ] `docs/TRUST_AND_SAFETY.md` and `docs/RELEASE_CHECKLIST.md` match.
