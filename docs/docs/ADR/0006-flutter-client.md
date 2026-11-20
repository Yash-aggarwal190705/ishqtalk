# ADR 0006: Flutter Client Direction

**Status:** Approved for implementation
**Last updated:** 2026-10-26
**Owner:** Solo developer / product owner
**Decision type:** Mobile client framework
**Related documents:** `docs/ADR/0001-technology-stack.md`,
`docs/ARCHITECTURE.md`, `docs/PRODUCT_REQUIREMENTS.md`, `docs/TEST_PLAN.md`,
`docs/CLEAN_ROOM_RULES.md`, `flutter_app/README.md`

## 1. Context

The workspace currently contains an independent native Java Android MVP in
`replica-android/`. The product owner has decided that the application should be
developed as a Flutter application so one client codebase can support the
planned mobile product while the developer remains a solo operator.

The supplied target artifact also contains a Flutter host, but that is only
clean-room evidence about a possible implementation technology. It does not
authorize copying the target's Dart code, routes, assets, provider choices,
package identity, or private integrations.

## 2. Decision

1. Build the new mobile client in Flutter and Dart, targeting Android first.
2. Keep `replica-android/` intact as a historical local-first reference and
   fallback until the Flutter client reaches the required local-flow parity.
3. Create the independent Flutter client under `flutter_app/` with original
   branding, copy, widgets, identifiers, and local data.
4. Preserve the application-owned repository, domain, API, authorization,
   provider-adapter, and test boundaries from the production architecture.
5. Start with a local/fake repository so the first Flutter slice remains usable
   without credentials. Replace it with a server-backed repository only after
   the API, authentication, ownership, and RLS controls are implemented.
6. Do not enable live RTC, real-money purchases, host payouts, recording, or
   production moderation merely because the Flutter UI contains a placeholder.

## 3. Why this decision

- A single Flutter client reduces duplicated UI and state-management work for a
  solo developer.
- Flutter provides a practical path from the existing local MVP to a tested
  Android client while keeping the backend authoritative.
- A separate Flutter project lets the current Java MVP remain a safe fallback
  during migration instead of creating a risky in-place rewrite.
- The decision is independent from the target artifact and does not rely on its
  bundled plugins or undocumented runtime behavior.

## 4. Consequences

### Positive

- One mobile UI codebase for the planned product.
- Easier deterministic widget and state tests for the local vertical slice.
- Clear migration boundary between the existing Java prototype and the new
  production-oriented client.
- Provider and backend integration can be added behind Dart interfaces rather
  than embedded in screens.

### Negative

- The project now has a temporary second client until the migration is complete.
- Flutter SDK, Android tooling, dependency updates, accessibility review, and
  device testing become release prerequisites.
- The current Java MVP's build evidence cannot be treated as Flutter build or
  device evidence.

## 5. Initial implementation scope

The first Flutter milestone is a local, clearly labelled development slice:

```text
Welcome -> profile setup -> discover -> live-room detail -> host profile
        -> follow/unfollow -> inbox conversation -> local profile
```

The slice must include useful loading, empty, validation, and recoverable error
states where those states are represented locally. It must not claim that
authentication, messaging delivery, RTC, billing, or moderation are live until
their server-side implementations and tests exist.

## 6. Approval and follow-up

- [x] Product owner selected Flutter for the mobile client.
- [x] Existing Java MVP is preserved during migration.
- [ ] Flutter local slice reaches documented widget-test and Android-build
      evidence.
- [ ] Server-backed repository and authentication are approved and tested.
- [ ] Device, accessibility, privacy, safety, RTC, billing, and release gates
      are completed before production claims.
