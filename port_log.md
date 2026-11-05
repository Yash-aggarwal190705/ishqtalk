# YourApp → Flutter port log

## 2026-11-04 — Explore tab (grid, search, call sheet)

### Scope and decisions

- Ported the `Explore` screen (`app_screens/src/views.tsx` + `ui.tsx` tokens)
  using the existing shared widgets: `TokenPill(soft)`, `CallButton`,
  `AvailLabel`, `Flag`, `Portrait`, `EmptyState`, `OfflineBanner`, `BottomNav`,
  `Sheet`, `Shimmer`, `AppIcon`. No new UI packages beyond
  `cached_network_image` (photo cards); Poppins stays bundled
  (`google_fonts` not needed).
- Screen `'explore'` now binds to the real `ExploreScreen` in the registry.
  The global `CallSheet` placeholder in `AppShell` is replaced by the ported
  two-step `CallSheet` (info → staged), mirroring the React `CallSheet`.
- Data lives in `lib/state/models.dart` (`AppUser` gained `photoUrl`,
  `verified`); `SeedUserRepository` (`lib/screens/explore/user_repository.dart`)
  provides the repository seam with the prototype's ~900ms load delay.
  Loading/skeleton, search query, and blocked filtering mirror the React
  `Explore` implementation; all Section 7 defaults (code-side) were followed.
- Evidence: `test/goldens/explore.png` (390×844), `explore_360.png`,
  `explore_480.png`; behavior coverage in `test/explore_test.dart`;
  image-content sanity checks in `test/explore_golden_sanity_test.dart`.

### Host-font caveat

Pre-existing login/onboarding/foundation goldens were rendered on Linux
(Flutter 3.47.9, Noto Sans CJK). On this Windows host the fallback symbol face
differs, so those old baselines pixel-diff here; all behavior tests pass and
the new Explore baselines are self-consistent on this host.

## 2026-11-02 — Initial setup, Foundation (0), Welcome Offer (1B)

### Scope and decisions

- Inspected `app_screens/src`, the three supplied montage PNGs, and `ishqtalk`.
  The Flutter project was the default counter scaffold; no earlier foundation,
  Section1A implementation, port log or bundled Poppins assets existed.
- State management is **Provider**, retained for subsequent sections.
- Follow the approved SPEC and the user's eight follow-up decisions. Explicit
  Flutter geometry/behavior takes precedence over incidental browser behavior.
- Use Poppins800 from the same Google Fonts family, height×.08 for the offer
  headline gap, .98 press-scale only on Continue, visible pending route bindings,
  and entrance-only instant mode. Freeze loops/prompt timing only via injected tests.
- Flutter source lives under `lib/`. Theme, icons and motion remain reusable.
  `NavigationState` is consolidated in `lib/navigation/nav.dart`; no duplicate
  `lib/state/navigation_state.dart` was created.

### STEP 2 — Complete files delivered

| File | Public symbols / role |
|---|---|
| `lib/main.dart` | Entry point; load preferences before first frame |
| `lib/app.dart` | `MyApp`, Provider composition, bundled typography, debug flags |
| `lib/foundation/app_theme.dart` | `AppColors`, `AppGradients`, `CssLinearGradient`, `AppTheme` |
| `lib/foundation/app_icons.dart` | `AppIcon`, `NavIcon`, `CompassIcon`, `PlayCircleIcon`, `ChatBubbleIcon`, `UserIcon`; original raw paths |
| `lib/foundation/app_motion.dart` | `FadeIn`, `SlideIn`, `SlideUp`, `Shimmer`, `PulseDot`, `Spin`, `Rise`, `Shake`, `LoopMotion`, `MotionScope`, `AppTap`, `PressScale` |
| `lib/shared/coin.dart` | `Coin` |
| `lib/shared/portrait.dart` | `Portrait` |
| `lib/shared/frog_avatar.dart` | `FrogAvatar` |
| `lib/shared/flag.dart` | `Flag` |
| `lib/shared/badge.dart` | `Badge` |
| `lib/shared/token_pill.dart` | `TokenPill`, `TokenPillVariant` |
| `lib/shared/call_button.dart` | `CallButton` |
| `lib/shared/age_chip.dart` | `AgeChip` |
| `lib/shared/lv_chip.dart` | `LvChip` |
| `lib/shared/header.dart` | `Header` |
| `lib/shared/bottom_nav.dart` | `BottomNav` |
| `lib/shared/sheet.dart` | `Sheet` |
| `lib/shared/dialog.dart` | `AppDialog`, `Dialog` alias |
| `lib/shared/offline_banner.dart` | `OfflineBanner` |
| `lib/shared/empty_state.dart` | `EmptyState` |
| `lib/shared/topic_chip.dart` | `TopicChip` |
| `lib/shared/spinner.dart` | `Spinner` |
| `lib/shared/avail_label.dart` | `AvailLabel`, `Availability` |
| `lib/shared/logo.dart` | `Logo` |
| `lib/state/models.dart` | `AppUser`, `Message`, `MessageState`, `Conversation`, original user/conversation seeds |
| `lib/state/app_context.dart` | `AppContextState`, `NetworkState`; local profile, conversations and social state |
| `lib/state/onboarding_state.dart` | `OnboardingState`; original logical preference keys and values |
| `lib/navigation/nav.dart` | `NavigationState`; push/back/tab/goto/openUser/openChat/messageUser/call/pay/signIn |
| `lib/navigation/screens.dart` | `ScreenDef`, `ScreenBuilder`, `screens`, `screenById`, `screenGroups`; all31 source entries |
| `lib/navigation/app_shell.dart` | `AppShell`; max480, incoming-only fade, splash timer, debug picker |
| `lib/screens/onboarding/welcome_offer.dart` | `WelcomeOffer(forceNotif, forcePay, instant)`, `WelcomeOfferTestOverrides` |
| `lib/screens/onboarding/notif_dialog.dart` | `NotifDialog` |
| `lib/screens/onboarding/payment_sheet.dart` | `PaymentSheet` (the Section1B simulated-payment sheet) |

## 2026-11-03 — Section 1A Splash and Login

### Scope and decisions

- Implemented the approved Section1A Splash/Login port without redesigning the
  source copy, geometry, SVG paths, colors, gradients, timings, or screen IDs.
- Splash is static and bypasses the shell's incoming250ms fade. Other screen
  transitions retain the existing keyed incoming fade.
- `Logo` and `Sheet` gained only backward-compatible optional configuration:
  Splash requests flame30/tail radius4; Section1B continues using its original
  defaults. Sheet forms request ink35/sigma2, radius24, max92%, horizontal20,
  bottom24+safe, and keyboard-inset avoidance.
- Provider remains the only state-management mechanism. Flow timers and form
  state are local to their owning widgets and are disposed/canceled.
- Native platform emoji/flags are used in production per the approved decision;
  no external emoji asset was added. Headless golden fallback fonts are test-only.

### Complete files delivered

| File | Public symbols / role |
|---|---|
| `lib/screens/onboarding/splash.dart` | `Splash`; static twelve-tile Splash composition |
| `lib/screens/onboarding/login.dart` | `Login` / `LoginView`; collapsed/expanded Login shell, modal routing, busy/toast flows |
| `lib/screens/onboarding/login_logo.dart` | `LoginLogo`; exact speech-bubble/heart SVG |
| `lib/screens/onboarding/login_provider_icons.dart` | `LoginProvider`, `LoginProviderIcon`; Google/X/Telegram/Mail/Phone SVGs |
| `lib/screens/onboarding/login_coins.dart` | `LoginCoins`; coin stack and sparkle loop |
| `lib/screens/onboarding/floating_emojis.dart` | `FloatingEmojis`; six staggered native glyph loops |
| `lib/screens/onboarding/provider_button.dart` | `ProviderButton`; provider button geometry, disabled/pressed/focus states |
| `lib/screens/onboarding/login_button_focus.dart` | `LoginButtonFocus`; source-style focus-visible outline |
| `lib/screens/onboarding/login_primary_button.dart` | `LoginPrimaryButton`; gradient form action |
| `lib/screens/onboarding/onboarding_modal.dart` | `OnboardingModal`; center/sheet modal shells and barrier semantics |
| `lib/screens/onboarding/account_chooser.dart` | `AccountChooser`; demo account list/add-account flow |
| `lib/screens/onboarding/contact_sheet.dart` | `ContactSheet`, `ContactKind`; Email/Phone input and OTP transition |
| `lib/screens/onboarding/country_code_picker.dart` | `CountryCodePicker`; accepted app-styled country selector |
| `lib/screens/onboarding/login_form_layout.dart` | `LoginFormLayout`; keyboard-aware scrollable body and pinned actions |
| `lib/screens/onboarding/login_text_field.dart` | `LoginTextField`; source-style text/digit fields |
| `lib/screens/onboarding/otp_step.dart` | `OtpStep`; six-digit entry, paste, verify, Shake, resend |
| `lib/screens/onboarding/legal_dialog.dart` | `LegalDialog`; exact Terms/Privacy copy |
| `lib/screens/onboarding/login_busy_bar.dart` | `LoginBusyBar`; one-second looping top progress segment |
| `lib/screens/onboarding/login_toast.dart` | `LoginToast`; Demo only toast |
| `lib/navigation/screens.dart` | Real builders for `splash`, `login`, `login-expanded`, `login-google`, `login-email`, `login-otp` |
| `lib/shared/logo.dart` | Additive `flameSize` and `tailRadius` options; defaults unchanged |
| `lib/shared/sheet.dart` | Additive barrier/blur/radius/padding/max-height/keyboard options; defaults unchanged |
| `lib/foundation/app_theme.dart` | Google-brand colors and Splash fade token |
| `lib/foundation/app_motion.dart` | Press callback and positive-delay loop freeze behavior |

### Section1A regression evidence

390×844 goldens:

- `test/goldens/splash.png`
- `test/goldens/login.png`
- `test/goldens/login_expanded.png`
- `test/goldens/login_google.png`
- `test/goldens/login_email.png`
- `test/goldens/login_otp.png`

320×568 keyboard-inset captures:

- `test/goldens/login_email_keyboard.png`
- `test/goldens/login_phone_keyboard.png`
- `test/goldens/login_email_otp_keyboard.png`

Behavior/motion coverage is in `test/login_behavior_test.dart`,
`test/login_motion_test.dart`, and `test/login_keyboard_test.dart`. The detailed
line-by-line review and accepted limitations are in
`docs/section_1a_self_review.md`; golden font provenance is in
`test/goldens/README.md`.

`pubspec.yaml` adds `provider`, `flutter_svg`, `shared_preferences` and seven
Poppins TTF declarations. Resolved dependencies are in `pubspec.lock`.
All font resources, exact URLs, license and checksums are in
`assets/fonts/` and `assets/fonts/SOURCES.md`.

### STEP 3 — Review and evidence

The element-by-element comparison, fixed implementation discrepancies, and
remaining approximations are in [`docs/port_self_review.md`](docs/port_self_review.md).

Golden captures (390×844, DPR1, zero test insets):

- `test/goldens/welcome_offer.png`
- `test/goldens/notif_prompt.png`
- `test/goldens/payment_sheet.png`
- `test/goldens/welcome_tooltip.png`
- `test/goldens/foundation.png` — every icon, shared illustration and both navigation modes

Real fonts and shadows are enabled in the test binding. Deterministic snapshots
freeze loops at their initial negative-delay phases, rather than changing
production behavior or relying on arbitrary wall-clock sleeps.

Original-size montage crops and provenance: `reference_images/README.md`.
Recreate them with `python3 tool/crop_references.py` (Pillow required).
Verify the original icon path strings with `python3 tool/check_svg_parity.py`.

### Pending bindings / limitations

Bound: `splash`, `login`, `login-expanded`, `login-google`, `login-email`,
`login-otp`, `welcome-offer`, `notif-prompt`, `payment-sheet`.

Pending: `live`, `explore`, `messages`, `me`, `live-searching`, `live-free`,
`live-gift`, `sky-lantern`, `profile`, `call`, `visitors-loading`, `visitors-list`,
`tokens`, `bonus`, `package-props`, `package-gift`, `history-list`, `history-empty`,
`welcome`, `setup`, `chat`, `settings`. Global `CallSheet` and commerce `PaySheet`
also show explicit pending content. Add each real builder as its section is ported.
Payment success/Skip reach the correct `live` ID, whose visual screen is pending.

Source-only cross-engine pixel parity remains unproven because standalone390×844
React references were not supplied. Montages differ in saturation/proportions/copy
and lack a tooltip-only frame. Do not use a resized montage as a golden baseline.
The Section1A review records accepted native emoji/platform-selector/keyboard
differences and the test-only golden fallback faces.
Context live-message time localization and platform connectivity sensing remain
for their future screen/integration sections.

### Try the implemented slice

From `ishqtalk/`:

```sh
flutter pub get
flutter run --dart-define=DEV_SCREEN_PICKER=true
```

The picker is debug-only. Default boot shows static `splash` for2000ms, then
`login` or `live` according to local onboarding/profile state. Use
`--dart-define=INITIAL_SCREEN=login-otp` or the picker to enter a Section1A state.
The OTP demo code is `123456`. No OS notification request or real payment is
performed; those flows preserve the source's local simulation semantics.

```sh
flutter analyze
flutter test
```

Only use `flutter test --update-goldens` after intentionally reviewing a visual
change. Normal verification must compare against the saved PNG baselines.

### Final verification

Verified with container-local Flutter3.47.9 / Dart3.13.7, compatible with the
existing `sdk: ^3.13.4` constraint:

| Command | Observed result |
|---|---|
| `flutter analyze` | PASS — no issues |
| `flutter test --reporter expanded` | PASS — all54 tests, including Section1A and prior baselines |
| `flutter test test/login_golden_test.dart test/login_keyboard_test.dart --update-goldens --reporter expanded` | PASS — six390×844 and three320×568 captures generated/reviewed |
| `flutter build web --debug --dart-define=DEV_SCREEN_PICKER=true --dart-define=INITIAL_SCREEN=splash` | PASS — `build/web` produced |
| `python3 tool/check_svg_parity.py` | PASS —28 shared and11 Login SVG path strings preserved verbatim |
| PNG dimension inspection | PASS — Section1A frames390×844; keyboard frames320×568 |

Visual review fixed SVG currentColor fallback, a camOutline path transcription,
duplicate shadow/stroke layering, CTA shadow clipping, intrinsic widget sizing,
percentage gradient geometry and per-segment keyframe easing. Goldens were
regenerated after the corrections and then compared in a normal test run.

The local web preview is served at `http://localhost:8765` from `build/web`.
Interactive computer-use smoke verification was unavailable because the
browser service lacks Xvfb; it is not claimed as passed. The real rendering
evidence is the Flutter-engine goldens and the interaction/widget tests.

Flutter tooling rewrote the local Android SDK pointer during verification; its
original Windows Flutter SDK path was restored afterward. Platform project
scaffolds and the React reference were retained. No commit or push was performed.
