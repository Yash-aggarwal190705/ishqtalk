# ADR 0001: Independent Technology and Deployment Shape

**Status:** Proposed with approved Flutter client follow-up  
**Last updated:** 2026-10-26  
**Owner:** Engineering and product owners to be assigned  
**Decision type:** Architecture and implementation strategy  
**Related documents:** `docs/PRODUCT_REQUIREMENTS.md`, `docs/ARCHITECTURE.md`,
`docs/DOMAIN_MODEL.md`, `docs/API_CONTRACT.md`, `docs/TEST_PLAN.md`,
`docs/OPERATIONS_RUNBOOK.md`, `docs/COST_MODEL.md`,
`docs/CLEAN_ROOM_RULES.md`, `docs/ADR/0006-flutter-client.md`

## 1. Context

The workspace contains a native Java Android MVP with platform Views, seeded
local data, and a small dependency surface. The product requirements now cover
server-authoritative discovery, messaging, one-to-one RTC calls, moderation,
analytics, payments, host earnings, operations, and recovery.

The supplied target artifact is a thin Flutter host with incomplete native
payload/splits. Its bundled plugin inventory is capability evidence only and is
not a technology recommendation. The independent product must not copy its
provider arrangement, package identity, private channels, or implementation.

The first production shape must remain small enough to operate with a small team,
while preserving clear boundaries for future scaling and provider replacement.

## 2. Decision

Adopt the following independent technology direction:

1. **Mobile:** preserve the current native Android Java/platform-Views MVP as a
   reference and fallback, while building the new mobile client in Flutter and
   Dart under the separately approved `docs/ADR/0006-flutter-client.md`.
2. **Backend shape:** start with a modular monolith plus background workers,
   rather than independent microservices.
3. **Primary data:** use a relational database as the system of record for
   accounts, profiles, relationships, messaging, calls, safety, economy, and
   audit data, with versioned migrations and row-level ownership controls.
4. **API:** use the proposed versioned REST/JSON contract under `/v1`, with
   OpenAPI 3.1 as the executable contract once approved.
5. **Provider seams:** wrap authentication, RTC, billing, push, storage, email,
   analytics, and content-safety providers behind application-owned interfaces
   with fake adapters for tests.
6. **Asynchronous work:** use an outbox/queue/job boundary for notifications,
   media validation, webhook handling, deletion, reconciliation, and recovery.
7. **Deployment:** keep local, development, staging, and production resources,
   databases, provider projects, credentials, and analytics namespaces separate.
8. **Observability:** include redacted logs, metrics, traces, audit events,
   provider usage, cost dashboards, health checks, and incident runbooks as
   first-class release components.

This ADR does not approve a specific backend language, hosting vendor, database
vendor, RTC provider, payment provider, authentication provider, or analytics
vendor. Those decisions require independent provider/security/privacy/cost
review and, where material, a follow-up ADR.

## 3. Why this decision

- It preserves the current MVP's build path and limits unnecessary rewrite risk.
- A modular monolith keeps transactions and authorization boundaries simple while
  the product and team are small.
- A relational system supports ownership, constraints, transactions, ledger
  invariants, audit history, and recovery requirements.
- REST/JSON and OpenAPI provide a clear client/server compatibility boundary.
- Provider adapters prevent SDK-specific behavior from becoming the domain model.
- Separate workers make retries, delayed webhooks, media scanning, notifications,
  deletion, and reconciliation explicit and observable.
- Environment separation prevents local/test builds from reaching production
  billing, payout, moderation, or private user data.

## 4. Alternatives considered

### 4.1 Copy the target's bundled Flutter/provider arrangement

Rejected. Static plugin registration does not establish target runtime behavior,
provider approval, legal permission, private API contracts, or suitability for
the independent product. It also violates the clean-room boundary if copied.

### 4.2 Migrate the app client to Flutter

The product owner approved this direction in ADR 0006. The migration is staged:
the existing Java MVP remains intact while the Flutter client is built and
verified. The Flutter client must not be described as production-ready until
its own build, device, accessibility, privacy, and release evidence exists.

### 4.3 Start with many microservices

Rejected for the initial production shape. It would add network boundaries,
deployment complexity, operational overhead, and failure modes before measured
scale or team ownership justify them.

### 4.4 Use a client-managed backend or provider SDK as the source of truth

Rejected. The client is untrusted, and provider state cannot replace application
authorization, moderation, ledger, entitlement, payout, or deletion rules.

## 5. Consequences

### Positive

- One initial backend deployment and authorization boundary.
- Easier local and staging testing with fake adapters.
- Transactional relationships, calls, ledger entries, and deletion workflows.
- Clear path to scale workers, API instances, storage, RTC, and moderation
  operations independently when measurements justify it.
- Provider replacement does not require rewriting the public domain model.

### Negative

- The modular monolith requires discipline to prevent module coupling.
- A relational database and migrations require careful ownership and recovery
  work.
- Maintaining the Java MVP during migration creates temporary duplicate client
  code and separate build evidence.
- The team must implement adapter fakes, contract tests, audit events, and
  operational tooling before claiming production integration.

## 6. Implementation constraints

- UI code must not decide final authorization, billing, payout, or moderation.
- Provider secrets and server-role keys must remain server-side.
- Every effectful operation must be idempotent.
- Every migration must have a rollback/forward-fix and restore plan.
- Every provider adapter must map provider failures to application states.
- The OpenAPI schema, API Markdown contract, domain model, migrations, and tests
  must remain compatible.
- The independent product must use new identifiers, data, copy, assets, and
  provider configuration.

## 7. Rollout

1. Keep the current MVP on seeded/fake adapters.
2. Implement the modular backend with account/profile/discovery boundaries.
3. Add messaging, reports, blocks, and deletion with server tests.
4. Add provider adapters behind fakes and sandbox projects.
5. Add RTC, billing, ledger, payouts, and analytics only after their ADRs and
   release gates are approved.
6. Measure load, cost, reliability, and team ownership before extracting any
   module into an independent service.

## 8. Open questions

- Backend language/framework and deployment platform.
- Database, queue, cache, object storage, and observability vendors.
- Authentication, RTC, billing, push, email, analytics, and content-safety
  providers.
- Supported Android API/device matrix and whether a future Kotlin migration is
  justified.
- Required scale and team boundaries for any future service extraction.

## 9. Approval checklist

- [ ] Engineering owner assigned.
- [ ] Product accepts the staged technology direction.
- [ ] Security/privacy review confirms the trust boundaries.
- [ ] Operations confirms environment, backup, monitoring, and recovery shape.
- [ ] Cost model covers the proposed deployment and provider categories.
- [ ] API and migration owners are assigned.
- [ ] Any specific provider or framework choice is recorded in a follow-up ADR.
