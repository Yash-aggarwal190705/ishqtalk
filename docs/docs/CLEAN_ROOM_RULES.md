# Clean-Room Rules — Independent Product Development

**Status:** Draft / proposed  
**Owner:** Product/legal/engineering owners to be assigned  
**Last updated:** 2026-10-26  
**Source of truth for:** Evidence boundaries, provenance, independent
implementation rules, review gates, and handling of target artifacts  
**Related documents:** `AGENTS.md`, `docs/PRODUCT_REQUIREMENTS.md`,
`docs/ARCHITECTURE.md`, `docs/SECURITY_AND_PRIVACY.md`,
`docs/TRUST_AND_SAFETY.md`, `docs/ANALYTICS_EVENTS.md`,
`docs/TEST_PLAN.md`, `docs/RELEASE_CHECKLIST.md`,
`reports/chato-recon.md`, `reports/chato-deeper-static-analysis.md`,
`reports/chato-static-evidence.json`, `reports/chato-plugin-registration.csv`,
`reports/chato-screen-inventory.csv`, `reports/chato-interaction-map.csv`,
`reports/chato-permissions.csv`, `reports/chato-install-run-test-plan.md`

These rules define how the independent product may use authorized functional
evidence without copying the target application's protected expression,
implementation, private services, or user data. They are a development and
release control, not a legal opinion. Product, legal, security, and engineering
owners must review them before external distribution.

---

## 1. Objective and boundary

The independent product may pursue generic user outcomes such as discovering
profiles, exchanging messages, requesting a private video call, reporting an
account, or purchasing an approved virtual product. It must make fresh decisions
about:

- product name, identity, positioning, and copy;
- visual design, layout, interaction details, icons, illustrations, animation,
  audio, video, and other media;
- source code, architecture, data model, API contracts, identifiers, and
  credentials;
- providers, authentication, billing, RTC, storage, push, analytics, and
  moderation operations;
- pricing, entitlements, host relationship, payout, retention, and legal policy;
  and
- ranking, recommendations, safety, enforcement, support, and operational rules.

The clean-room boundary applies to all employees, contractors, agents,
subagents, vendors, repositories, prompts, reports, screenshots, fixtures,
logs, design files, and release artifacts.

---

## 2. Evidence labels

Every statement derived from supplied artifacts must use an evidence label:

- **Observed/static:** directly present in an authorized local file, static
  report, or approved public source; not necessarily runtime verified.
- **Inferred:** a reasonable conclusion from evidence, but not directly shown.
- **Unknown:** not established and must not be silently invented.
- **Proposed:** an independent decision for this product, pending approval.
- **Implemented:** behavior independently implemented and verified in this
  product.
- **Blocked:** intended behavior could not be verified because a required tool,
  artifact, device, account, or environment was unavailable.

Do not convert **Observed/static** or **Inferred** target evidence into a claim
that the target definitely has a feature. Do not convert a product proposal or
stub into a claim that the independent application is live or production-ready.

---

## 3. Allowed evidence

Subject to authorization and privacy review, the team may use:

- generic functional categories and user outcomes;
- broad capability inventories, such as messaging, notifications, media,
  authentication, billing, or RTC, when clearly labeled as static evidence;
- non-proprietary platform behavior and public standards documentation;
- independently written acceptance criteria and state machines;
- independent performance, accessibility, privacy, safety, and reliability
  requirements; and
- clean-room observations recorded without copying protected expression.

Evidence may guide questions and independent requirements. It does not supply a
source codebase, design system, backend contract, credential set, product
catalog, user database, ranking algorithm, moderation policy, or legal policy.

### 3.1 Evidence handling record

For every evidence-derived requirement, record:

```text
evidence_id:
source_path_or_reference:
access_authority:
date_observed_utc:
observer:
label: observed/static | inferred | unknown
generic_functional_summary:
what_is_not_known:
independent_product_decision:
reviewer:
```

Do not include copied target code, private payloads, user data, secrets, or
proprietary media in this record.

---

## 4. Prohibited material and actions

The following are prohibited unless a separate written authorization and legal
review explicitly changes the boundary:

- copying, translating, paraphrasing closely, or reconstructing target source
  code, decompiled logic, private API paths, backend contracts, schemas,
  credentials, tokens, signing material, or user data;
- reproducing the target logo, name, package identity, deep-link host, exact
  screen composition, exact wording, proprietary icons, illustrations, video,
  audio, screenshots, or other protected media;
- using target private services, accounts, certificates, cookies, tokens,
  provider credentials, or user data;
- bypassing authentication, access controls, certificate pinning, DRM, paid
  features, rate limits, or other protections;
- patching, re-signing, merging, or altering a supplied target APK to make it
  run or to remove its protections;
- importing extracted target assets, resources, strings, layouts, snapshots,
  network captures, runtime databases, or logs into the independent source tree;
- using target-specific device channels, advertising IDs as identity, opaque
  initialization data, private endpoint names, or target-specific cleartext
  network policy; and
- presenting target static evidence as runtime truth or as approval for an
  independent product decision.

If a task would require any prohibited action, stop and escalate to the named
owner. Do not improvise a workaround.

---

## 5. Repository and artifact boundaries

### 5.1 Evidence directories

Target artifacts and clean-room reports remain under the evidence/reporting
areas. They must not be copied into product code, application assets, tests,
fixtures, design exports, build outputs, or release packages.

### 5.2 Independent product directories

Product code, tests, migrations, schemas, generated contracts, deployment
configuration, and assets must be independently authored. A reference to an
evidence report is allowed in documentation when it explains provenance; a
copied asset or implementation is not.

### 5.3 Generated and disposable material

Do not commit extracted APK contents, emulator state, screenshots, device dumps,
private runtime data, build caches, logs containing personal data, or generated
provider payloads unless the repository explicitly requires a redacted artifact.

---

## 6. Independent implementation rules

### 6.1 Product and UX

Use fresh:

- name, logo, color palette, typography, layout, navigation, iconography,
  illustration, animation, media, and voice/tone;
- information architecture, interaction wording, empty/loading/error states,
  onboarding, permission explanations, and support copy; and
- accessibility labels, localization keys, test fixtures, and example data.

Generic outcomes do not require identical screens or flows. A product may offer
a private call without reproducing the target's call screen, wording, price,
controls, animation, or provider behavior.

### 6.2 Technical design

Choose independent:

- package/application identifiers and signing identity;
- API paths, request/response shapes, error codes, event names, and schemas;
- database tables, migrations, identifiers, indexes, retention, and RLS;
- authentication/session, RTC, storage, billing, push, analytics, and
  moderation providers;
- ranking, discovery, eligibility, billing, payout, and enforcement rules; and
- logging, monitoring, incident response, and recovery procedures.

A generic pattern such as idempotency, cursor pagination, server-issued tokens,
or append-only ledger entries is a normal engineering technique and is not a
target-specific implementation. The actual names, code, schemas, parameters,
and policies must still be independently designed.

### 6.3 Data and identity

The independent product must use new synthetic or independently collected data.
It must not use target users, target advertising IDs, target device identifiers,
target media, target contact lists, target message content, or target provider
records. Stable account identity must not depend on an advertising identifier or
raw hardware identifier.

---

## 7. Analysis and reverse-engineering workflow

The allowed workflow is:

1. Confirm the artifact, access authority, purpose, and scope before inspection.
2. Preserve the original artifact and record its digest without modifying it.
3. Use static analysis only within the approved tool and evidence boundary.
4. Record generic capability observations with evidence labels and uncertainty.
5. Separate target observations from independent product requirements.
6. Write fresh acceptance criteria, architecture, state machines, schemas, and
   tests without copying target implementation or expression.
7. Run provenance, identifier, asset, secret, and privacy checks before review.
8. Obtain product/legal/security review for any boundary question.

Runtime testing of a target artifact requires explicit authorization, a complete
artifact, a safe isolated environment, and a clear purpose. If a target APK is
missing required splits, native payloads, device support, credentials, or runtime
access, record the result as **Blocked**. Do not bypass the blocker.

---

## 8. Code, copy, asset, and design provenance

Every production asset and externally sourced dependency should have a safe
provenance record:

```text
item:
type: code | copy | icon | illustration | font | audio | video | dependency
source:
license_or_permission:
author_or_vendor:
first_added_commit:
reviewer:
target_artifact_influence: none | generic_function_only | needs_review
notes:
```

The phrase `generic_function_only` means the item was designed independently
after considering a generic outcome; it does not permit copied visual or textual
expression.

Do not use a screenshot, color sample, extracted icon, target string, target
font configuration, or target media as a design shortcut. If a designer or agent
cannot explain independent provenance, quarantine the item and request review.

---

## 9. Provider, package, and infrastructure boundaries

The independent product must not reuse:

- target package names, application IDs, signing identities, deep-link hosts,
  intent actions, private channel names, or private endpoint identifiers;
- target provider projects, keys, secrets, room names, product IDs, webhook
  secrets, or private service URLs;
- target-specific cleartext network configuration, certificate material,
  advertising-ID lookup as identity, or opaque initialization payloads; or
- extracted target SDK configuration when an independent provider decision has
  not been made.

Provider selection must follow the independent architecture, privacy, security,
cost, safety, store, legal, and operations reviews. A bundled provider observed
in static analysis is evidence of capability, not a recommendation or approval.

---

## 10. Privacy, security, and data handling

- Do not place target user data, target runtime data, credentials, tokens,
  cookies, payment payloads, or private media in prompts, fixtures, reports,
  logs, screenshots, or source files.
- Redact authorization headers, private URLs, receipts, message bodies, media,
  device identifiers, and unnecessary personal data from evidence.
- Keep private memory, credentials, local configuration, and logs outside the
  repository.
- Scan changed files for target identifiers, secrets, copied strings, and
  suspicious assets before review.
- Treat any suspected boundary violation as a security/privacy incident: stop
  distribution, preserve minimal evidence, notify the owner, quarantine the
  material, and document the remediation without copying the sensitive value.

---

## 11. Review gates

### 11.1 Before implementation

- [ ] The requested outcome is expressed independently.
- [ ] Source evidence is authorized and labeled.
- [ ] No target source code, private service, credential, or user data is needed.
- [ ] Product, legal, and security boundaries are understood.
- [ ] Open questions are recorded instead of invented.

### 11.2 Before merge

- [ ] Code, copy, UI, assets, identifiers, schemas, and tests have independent
      provenance.
- [ ] Static evidence is not presented as runtime truth.
- [ ] Changed files contain no target package/deep-link/provider identifiers or
      secrets.
- [ ] Redaction and privacy checks pass.
- [ ] Relevant product, architecture, security, safety, and legal reviewers have
      been assigned.

### 11.3 Before release

- [ ] `docs/TEST_PLAN.md` includes provenance and clean-room checks.
- [ ] `docs/RELEASE_CHECKLIST.md` includes clean-room and prohibited-material
      gates.
- [ ] Release artifact contains only independent code, assets, configuration,
      and approved dependencies.
- [ ] Store metadata, privacy policy, terms, community guidelines, and support
      copy are independently authored.
- [ ] Any unresolved boundary question has a written decision before release.

---

## 12. Violation response

If copied or unauthorized material is suspected:

1. Stop adding or distributing the affected material.
2. Do not delete evidence destructively or rewrite history to hide the issue.
3. Record the path, commit, source category, discovery time, and owner without
   copying secrets or private payloads.
4. Quarantine the material from builds, releases, prompts, fixtures, and design
   exports.
5. Notify product/legal/security/engineering owners.
6. Determine whether rotation, access revocation, user notification, provider
   notification, or incident response is required.
7. Replace the material with independently authored work or obtain explicit
   approval for another lawful source.
8. Run provenance, secret, asset, identifier, and release checks again.
9. Record the remediation and reviewer decision.

Do not classify a violation as harmless merely because the copied item is small,
hidden, generated, or not visible in the main screen.

---

## 13. Current evidence boundary

The supplied Chato artifact and its reports are evidence only. Current known
limitations include:

- the base artifact lacks the matching Flutter native payload/splits required
  for complete runtime behavior;
- the available emulator/device environment cannot provide authorized target
  runtime validation;
- the reports establish static capability and metadata observations, not exact
  target UI, backend behavior, pricing, ranking, moderation, or settlement; and
- the independent application must not use the target package name, deep-link
  host, native channel, advertising-ID behavior, provider credentials, opaque
  initialization data, cleartext network policy, or proprietary assets.

All target-derived statements in independent documents must retain that scope.

---

## 14. Open decisions before approval

1. Product/legal owner and review cadence.
2. Evidence retention location, access control, and deletion schedule.
3. Authorized tools, artifacts, runtime environments, and permitted analysis
   activities.
4. Provenance tooling for code, copy, design assets, fonts, media, and
   dependencies.
5. Automated scans for target identifiers, copied strings, assets, secrets, and
   private data.
6. Escalation path and incident classification for a suspected violation.
7. Required legal, store, privacy, security, and vendor review before release.
8. Whether any public-source or third-party material needs additional license
   review or attribution.

---

## 15. Approval checklist

- [ ] Product, legal, security, and engineering owners assigned.
- [ ] Evidence labels and provenance records are used consistently.
- [ ] Target artifacts remain isolated from independent product code and assets.
- [ ] No target code, private API, credential, user data, proprietary media,
      package identifier, or private provider configuration is reused.
- [ ] Independent product, UX, API, data, provider, safety, billing, and
      operational decisions are documented.
- [ ] Runtime blockers are recorded as blocked rather than bypassed.
- [ ] Secret, target-identifier, asset, copy, and privacy scans are part of the
      test/release process.
- [ ] Suspected violations have a response and remediation procedure.
- [ ] `docs/TEST_PLAN.md` and `docs/RELEASE_CHECKLIST.md` include these gates.
