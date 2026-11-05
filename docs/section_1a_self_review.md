# STEP 3 — Section 1A specification-to-code review

Implemented after approval of the Section 1A SPEC and all five follow-up decisions.
Reference: `../../app_screens/src/login.tsx`, Splash in `views.tsx`, and `index.css`.
Paths in the tables are relative to `lib/screens/onboarding/` unless noted.
The prior Foundation/Section 1B review remains in `port_self_review.md`.

## Splash

| Approved SPEC line | Implementation / review |
|---|---|
| Full clipped viewport; vertical splashTop→splashBottom | `splash.dart`, existing `AppGradients.bgSplash` |
| 3 columns × 4 rows; x4, top−12, height54%H, gaps4 | Fractional dimensions calculated from local LayoutBuilder bounds; no rounding |
| Tile width `(W−16)/3`, height `(.54H−12)/4` | Expanded grid cells consume the exact remaining space; 390×844 gives 374/3 ×110.94 |
| Twelve Portraits, seed i+2, radius8, white25 overlays | Existing `Portrait`; row-major indexing2…13, clipped per tile |
| Bottom fade55%H, transparent→splashBottom at70%, held to100% | `AppGradients.splashFade`; full-width bottom layer above portraits |
| Entire logo+caption group centered | Column mainAxisSize.min in Center; no center shift from top grid |
| Logo size clamp80/26vw/96, radius24, brand gradient, shadow0/8/24 primary30 | Shared `Logo`; size96 at390px; all default decoration reused |
| Inner glass66%width ×62%height, radius22, white25 | Shared `Logo`, approved SPEC/source proportions preserved |
| Tail16×16, x8/bottom−6, rotate45°, radius4 | New optional `tailRadius: 4`; existing default2 retained |
| Flame30 white, original path | New optional `flameSize: 30`; existing default31% retained |
| Caption margin12; clamp24/7.5vw/30; line-height1.5, 700 italic, tracking−.5 primary | At390px: font29.25, line43.875; no normalized font sizes |
| No animation, including shell entrance | `AppShell` sets entrance instant for splash only; first-frame opacity1 asserted in shell tests |
| 2000ms shell routing | Existing timer retained; login unless onboarded/profile, then live; all branches tested |

## Login common composition and providers

| Approved SPEC line | Implementation / review |
|---|---|
| Splash background, clipped root, scrollable content, hidden scrollbar | `login.dart`; CustomScrollView with SliverFillRemaining; horizontal24/topSafe |
| Logo top padding max48/12%H | Local viewport height used explicitly; 101.28px at844, in addition to top safe inset |
| LoginLogo88, radius24, brand gradient, shadow0/10/30 primary35 | `login_logo.dart`; separate source illustration, not a duplicate of the shared flame Logo |
| LoginLogo SVG56% tile size, viewBox48; white bubble/cta heart | Two original paths verbatim; 49.28px atsize88, 17.92px atsize32 |
| Emoji anchor logo top-right, six native glyphs | `floating_emojis.dart`; zero-size overflow-visible anchor; IgnorePointer/ExcludeSemantics |
| Exact floater sizes/destinations | 20/−10,16/+12,22/−4,14/+8,18/−12,15/+6; exact 😍/❤️/💗 sequence |
| YourApp margin12;28/42/700 italic ink | `login.dart`; existing Poppins BoldItalic asset |
| Headline margin40; row gap12; left text/right72×64 coins | `login.dart`, exact two-line copy,22/27.5/700 |
| Coin layer sequence48,38,28,18; rx26/ry9, lower y+8 opacity.8 | `login_coins.dart`; original SVG ellipses and stacking order; canvas clipped at64 |
| Coin outline1.5 coinBg; top inner ringrx16/ry5 | Original dimensions; SVG object-bounding-box diagonal gradient vipA→vipB |
| Sparkle original path, primary10; center(56,11) | Preserved path; transform alignment derived from viewBox72×64 |
| Provider group mt20/gap12 | `login.dart`; collapsed zero-height extra-grid flex-item gaps retained |
| Provider52 high, radius14,15/22.5/600 ink | `provider_button.dart`; label centered independently of icon |
| Icon slot24×24, left16 inside border positioning box | Original Google24/viewBox48, X22/viewBox24, Telegram/Mail/Phone24/viewBox24 |
| Google white/border1.5 cta/shadow0/6/18 cta25 | Exactly those decoration values; all colors from AppColors |
| Other providers white60/border1 divider | Same bounds/label style; no Material ripple |
| Press scale.98 + primary10 fill over150ms | Shared PressScale with additive pressed-state callback; same transition curve for fill and scale; cancel restoration tested |
| Disabled.7 over150ms | AnimatedOpacity, all providers disabled whilebusy; disabled controls cannot activate |
| Focus-visible2px primary, offset2 | `login_button_focus.dart`; outer stroke with a real2px gap, no shadow approximation |
| More48, text12/16 ink2, gap4, chevron14 rotated90° | `login.dart`;44px occupied slot preserves source−4 bottom margin |
| Collapsed phone: −12 margin, wrapper.35, disabled.7, top-to-bottom mask | Equivalent flow gaps; effective.245 before alpha mask; pointer/semantics excluded |
| Expanded X/Telegram content116 high | 52+12+52; zero→116 clipped transition250ms easeOut; initial expanded route starts fully open |
| X/Telegram/Phone Rise delays0/60/120ms | Existing Rise; opacity0/Y8→opacity1/Y0 over300ms; fill-backwards preserved |
| Footer mt-auto, top24, bottom16+safe,11/16.5 ink2 | SliverFillRemaining+Spacer; follows content when scrolling required |
| Footer exact over18/Terms/Privacy copy and punctuation | Source TextSpans, underlined primary links; both actual pointer hit regions exercised |
| Busy bar full-width3px at top, above modals | `login_busy_bar.dart`; segment W/3; clipping; Loading semantics; z-order in root Stack |
| Toast ink pill, padding16×8,12/16 white, bottom96 | `login_toast.dart`; FadeIn250; liveRegion;1800ms expiry tested |

## Modal shells and account chooser

| Approved SPEC line | Implementation / review |
|---|---|
| Ink35 barrier, CSS blur4→sigma2, FadeIn250 | `onboarding_modal.dart`; clipped backdrop; shared Sheet configuration for sheet mode |
| Center widthW−48, max90%H, radius20, padding20, white/ink | Scrollable panel; shadow0/20/60 ink25; no center slide |
| Sheet full width, max92%, top radius24,20/8/20/(24+safe) | Existing `Sheet` with optional settings; default90%/radius20/16/8/16/32 retained |
| Sheet handle40×4/divider/round, marginBottom16 | Shared handle reused; no duplicate panel implementation |
| Sheet SlideUp280 + wrapper FadeIn250 | Existing primitives; no exit animation; instant settles entrances |
| Scrim closes, panel consumes tap | Actual panel/scrim interaction tests; modal background focus disabled |
| Account LoginLogo32; mt12 title20/28/600; subtitle13/19.5 ink2 | `account_chooser.dart`, exact title/subtitle source copy |
| List mt16, top1px divider, button56 + separate1px divider | Three original account rows; natural panel height398.5 at390×844 |
| Avatar36 circle, initials14/20/600 | Alex/Taylor primary10+primary; Sam roseGold50+ink |
| Name14/20/500, email12/16 ink2; gap12; ellipsis | Exact three source names/emails, separate lines, Expanded truncation |
| Add row56, circle36/divider1, fullwidth＋18/28 primary | Source U+FF0B retained; no substituted Material icon; keyboard activation/focus outline supported |
| Footnote10/15 ink2, mt8, centered | Exact `Demo account chooser` string |
| Account pick→close+busy1000→welcome-offer | Tested just before/at deadline; no real account request added |
| Add account keeps chooser + toast1800 | Exact local demo behavior, timer test included |

## Contact sheets, country picker, OTP, and legal dialogs

| Approved SPEC line | Implementation / review |
|---|---|
| Email/Phone use the shared bottom Sheet, title18/28/600, subtitle13/19.5, field mt20 | `contact_sheet.dart`; `OnboardingModal` delegates sheet geometry to the configurable shared `Sheet` |
| Email field52/r14/card fill/padding16; divider→primary focus→badge error | `login_text_field.dart`; border is derived from the real FocusNode and validation state; no Material underline or ripple |
| Phone selector96×52 + field, gap8; initial +91 | Selector remains a hand-built source-style control; input uses the remaining width; selected code is kept in target text |
| Email regex and phone7–12 digit validation | Exact requested email regex after trim; phone input formatter strips non-digits and caps at12, validator requires7–12 |
| Error message reserved20px and exact strings | `ConstrainedBox(minHeight:20)` keeps the Send action from jumping; errors are live regions |
| Send code52/r14/brand gradient/disabled.4 | `LoginPrimaryButton`; disabled action is non-interactive and visually.4 |
| Keyboard adaptation | `Sheet(avoidKeyboard:true)` subtracts `viewInsets.bottom`, moves the panel above the inset, and `LoginFormLayout` keeps a scrollable body with pinned action controls |
| Focused field stays visible | `Scrollable.ensureVisible` runs after inset changes; field `scrollPadding` includes the focus ring; exercised at320×568 with simulated300px keyboard inset |
| Country selector can use a platform-standard styled surface | `country_code_picker.dart` is a scrollable app-styled bottom sheet with flags, country names, codes, selected indicator, and scrim close |
| Country choices +91/+1/+44/+92/+971 | Exact five requested choices; selected code is reflected in the phone form and retained after returning from OTP |
| OTP title/target/Change line | `otp_step.dart`; exact copy,13/19.5 target, primary underlined Change; Change returns to the form without dropping input |
| Six boxes, gap8, height56, width `(W−40−40)/6`, radius12 | Row uses six Expanded children and five8px gaps inside the sheet's 20px horizontal padding; 390px gives310/6 each |
| Digit focus/error border and primary30 focus ring | `LoginTextField(digit:true)`; custom field container paints the requested border and outer focus ring |
| Digit entry auto-advance, last ASCII digit, backspace to previous | Per-box controllers/focus nodes and a sentinel zero-width character permit empty-box Backspace on software/hardware paths; behavior tests cover both |
| Paste/autofill six digits | Formatter detects full-code replacement or multi-character insertion, fills boxes1–6, and focuses `min(length,5)` |
| Enter verifies; Verify disabled until six digits | Focus key handler and submitted callback call the same verifier; empty boxes disable action |
| Demo code and wrong-code error | `123456`; exact `Incorrect code. Please try again.` plus `Shake` trigger increment |
| Shake0/−8/8/−6/6/0 over400ms | Existing shared `Shake` primitive; motion tests assert the80ms stops and OTP test asserts the visible error/reset behavior |
| Resend30s→enabled; tap restarts30 and retains entered state | Periodic timer is disposed with OTP; resend leaves digits/error unchanged; behavior test covers the boundary and reset |
| Correct verify closes sheet, busy1000ms, routes welcome-offer | Parent callback closes modal and starts the same busy/timer path as account selection; deadline test covers just-before/at1000ms |
| Legal Terms/Privacy center modal, exact copy, Close52 | `legal_dialog.dart`; source strings remain literal and exact; footer links and scrim/Close interactions are tested |

## Animation, lifecycle, navigation, and shared API review

| Approved SPEC line | Implementation / review |
|---|---|
| Splash is exempt from shell fade | `AppShell` passes `instant:true` only for definition id `splash`; existing non-splash keyed incoming fade remains unchanged |
| Instant turns off entrances but leaves loops active | Login passes `instant` only to entrance primitives; `LoopMotion` is controlled only by reduced motion or test `MotionScope`; motion tests assert this distinction |
| Floaters 3s easeOut, stagger500ms, translate/scale/opacity | `FloatingEmojis`; six `LoopMotion` instances, native platform glyphs, no external emoji assets, and deterministic phase tests |
| Sparkle2s `.6→1.1`, `.2→1` and busy bar1s `−100%→350%` | `LoginCoins` and `LoginBusyBar`; per-keyframe pulse sequence and segment-width math are tested at390px |
| Timers/controllers cleaned up | Login cancels flow/toast timers; ContactSheet disposes controllers/focus; OTP cancels countdown and disposes six controllers/nodes/recognizer; all relevant widgets are unmounted in tests |
| Retain Login modal prop and all source screen IDs | `Login(modal:String?)` accepts `google`, `email`, `email-otp`, `phone`, `terms`, `privacy`; registry still contains all31 IDs and now binds the first six to Splash/Login |
| Preserve Section1B | Shared `Logo`/`Sheet` constructors are additive with old defaults; existing Section1B golden, overlay, and full-suite tests pass |

## Verification evidence

- `flutter analyze` — PASS, no issues.
- `flutter test --reporter expanded` — PASS, all54 tests.
- `flutter build web --debug --dart-define=DEV_SCREEN_PICKER=true --dart-define=INITIAL_SCREEN=splash` — PASS, `build/web` produced.
- `python3 tool/check_svg_parity.py` — PASS, 28 original shared icon paths and 11 original Login SVG paths preserved verbatim.
- PNG dimensions — PASS: six Section1A frames are390×844; three keyboard frames are320×568.
- `test/login_behavior_test.dart` covers provider delays, expansion, account chooser, toast, validation, country selection, OTP typing/paste/backspace/Enter/error/resend, legal dialogs, and timer cancellation.
- `test/login_motion_test.dart` covers floater staggering, sparkle and bar phases, reduced motion, instant mode, and press cancel.
- `test/login_keyboard_test.dart` covers Email, Phone, and OTP with a300px simulated keyboard inset and recovery after the inset is removed.

## Known limitations and accepted approximations

1. Native emoji and flag glyphs intentionally use the host platform in production,
   as approved. Platform glyph shape/color can differ from the Flutter Linux
   golden face. Test-only fallback loading is documented in `test/goldens/README.md`.
2. The browser-native React `<select>` has no supplied open-state reference. The
   accepted implementation is a styled, scrollable app bottom sheet with flags,
   names, and codes rather than an attempt at browser popup pixel identity.
3. Keyboard tests simulate `MediaQuery.viewInsets`; they prove the layout and
   focus contract but do not render an OS keyboard in the golden. A real-device
   keyboard can change the visible keyboard pixels and platform resize mode.
4. Exact cross-engine React comparison remains unverified because standalone
   390×844 React screenshots were not supplied. The Section1A PNGs are stable
   Flutter-engine regression baselines, not evidence of pixel identity across
   browser and device text/blur rasterization.
5. Browser computer-use smoke testing was unavailable in this environment due
   to the missing Xvfb service. Flutter widget behavior, engine goldens, analysis,
   and web compilation were verified locally.
