# STEP 3 — Foundation + Section 1B self-review

Source: `../app_screens/src/{index.css,ui.tsx,welcomeOffer.tsx,App.tsx,nav.ts,screens.ts,appContext.ts,store.tsx,onboardingState.ts}`
and `../app_screens/src/components/icons/NavIcons.tsx` (paths relative to the Flutter project).

## Specification-to-code comparison

| Specification item | Implemented location / review result |
|---|---|
| All 25 theme colors, page background and ink overlays | `foundation/app_theme.dart`; original token names converted to camelCase, including equal-valued aliases |
| Five named gradients and stops | `AppGradients`; welcome 0/.5/1, vertical splash/welcome, horizontal CTA; `CssLinearGradient` computes physical-angle shader endpoints for 135° on rectangles |
| SVG illustration colors | Centralized additional colors and palette arrays in `AppColors` |
| Poppins 400/500/600/700 and italic 600/700 | Bundled TTFs with explicit pubspec weight/style declarations; no runtime fetch |
| Extra-bold 800 | Real `Poppins-ExtraBold.ttf` obtained from the existing Google Fonts family; no fallback |
| Text metrics | Explicit size, weight and height. Arbitrary Tailwind font sizes inherit unitless 1.5 from Preflight unless a leading utility overrides it. Zero letter spacing and even leading distribution at the app root |
| Material styling | Material 3 disabled; no splash/highlight/hover paint; hand-built buttons use `AppTap` |
| 28 raw icons | `app_icons.dart`; all 28 original path strings compared verbatim by `tool/check_svg_parity.py` |
| Current-color SVG fills | Explicit `SvgTheme(currentColor: ...)`; fixed black-fill fallback found in foundation golden review |
| Stroke overrides | Default 1.75, `dots` path owns 3, dark TokenPill's plus explicitly requests 3, flame has no stroke |
| Navigation icons | `CompassIcon`, `PlayCircleIcon`, `ChatBubbleIcon`, `UserIcon`; original paths and even-odd solid cutouts |
| Coin | Original 24-viewBox, gradient, circle radii, ring and star; default 16 |
| Portrait | Original palette selection and 100×130 SVG; 160° size-aware gradient; cover and bottom-center alignment preserve `xMidYMax slice` |
| FrogAvatar | Original 80-viewBox shapes, colors and 160° gradient; circular clipping; default 80 with 3px white85 ring |
| Flag | Original 14×10 artwork, 1px clip; only Pakistan gets Pakistan artwork, others get India as in React |
| Badge | Fixed 14px height, min width14, 2px horizontal padding, pill radius; 10/12 semibold; multi-digit numbers retain pill shape |
| TokenPill | Soft28/r16, dark32/r6; exact border/padding/gaps; dark plus inherits ink; clipped sigma6 backdrop |
| CallButton | 40px circle; original camera22; both color variants; Tailwind shadow-md's two black10 shadows restored |
| AgeChip / LvChip | 20px heights/r10; exact 8px padding and 4px gaps; SVG search/flag and gray/gradient level variants |
| Header | 56+safeTop; back40; centered16/24 title bottom12; right40 with padding12; inherited light/dark icon color |
| BottomNav | 56+safeBottom, divider1, white90/sigma6 or white35/sigma10; children56, pills40×28/r14; active1 versus inactive.95; badge−6/−2 and dot2/6 |
| BottomNav transition | Single 200ms tween for scale/color/background, Tailwind default easing; no animation from the wrong state on first mount and no double-applied scaling tween |
| Sheet | Ink30 full barrier; FadeIn250; SlideUp280; max90% of local bounds; top radius20; handle40×4; 16/8/(32+safeBottom) scrollable padding; panel taps consumed |
| Dialog | Ink30 fade, centered width−48, radius16/padding20; title16/24, body14/20 mt6, actions mt20/gap12; panel taps consumed |
| OfflineBanner | Original icon16, margins16/8, padding12/8, radius8, 12/16 text and optional `Try again` target32 |
| EmptyState | Padding32/48, icon circle64/margin12, title14 medium, body12 mt4, outlined action44 mt16 with intrinsic width |
| TopicChip | Height44, horizontal16, radiusfull, selected check14, gap6, correct selected/unselected colors |
| Spinner | Outer18, viewBox28, center14/r11/stroke3.5, round cap/dash52 18; 800ms linear loop |
| AvailLabel | Dot8/gap4; exact three labels/colors; text inherits caller style |
| Logo | Size96 default/r24, brand gradient, shadow0/8/24 primary30; inner66%×62%/r22, tail16 rotated45°, flame31% |
| FadeIn / SlideIn / SlideUp | 250/280/280ms easeOut, correct opacity and px/fractional translations; no double transform |
| Shimmer | Shader tile720, −360→360 over1400ms linear; repeated tile and original three colors |
| PulseDot | 1200ms round-trip; .25/1/.25 and .8/1.1/.8; easeInOut applied per 50% segment |
| Spin | Configurable linear period; default800ms |
| Rise | 300ms easeOut; opacity0/Y8 held throughout positive delay; negative delay starts in-progress |
| Shake | 400ms, positions0/−8/8/−6/6/0 at20% stops; segment easing, not whole-sequence easing |
| Motion lifetime | Controllers instantiated in `initState`, disposed; timers canceled; reduced motion stops loop tickers |
| Instant mode | Entrances complete immediately; continuous loops remain active. `MotionScope(freezeLoops: true)` is injected only in test fixtures |
| Screen registry | Exact 31 IDs, labels, groups, props and nav tabs. Typed builder signature; 3 WelcomeOffer bindings; other bindings visibly marked pending |
| Nav stack | `push` stores previous ID; `goto` does not alter stack; `back` falls back live; `tab` clears; negative chat ID goes explore |
| User / chat / call / pay / signIn | Typed AppUser; messageUser ensures but does not overwrite conversation; call/pay set independent overlays; signIn changes signed only |
| App context | Source seed users/conversations and unread totals, profile JSON, follows/blocks/visits, local delivery state, offline/slow toggles |
| Screen transition | Keyed `FadeIn` removes outgoing subtree immediately and fades incoming250ms easeOut exactly once; no page-route slide or reverse fade |
| Splash timer | 2000ms → live if onboarded OR profile, else login; canceled on shell disposal |
| Shell | Centered max480, screen fill, clip overflow; original shadow-2xl at viewport width≥640; debug picker gated by kDebugMode and DEV_SCREEN_PICKER |
| Offer gradient / blobs | Original five sizes/positions/delays; coin50, sigma3; local shell bounds rather than whole desktop width |
| Drift | Nine-second TweenSequence, two 50% easeInOut segments, initial phase `(−delay mod9)/9`; reduced motion resets visual translation to zero |
| Content | Horizontal24, top safe, bottom24+safe, hidden scrollbar; top row56; Skip target48 with horizontal8 and white70 text |
| Headline placement | Approved explicit height×.08 gap after top row; 44/44 weight800 DOUBLE, 1px vipB stroke and 0/3 ink30 shadow; COINS NOW28/35, gap4 |
| Tooltip | Top46/right8; badge/r8/padding12×6; notch10 rotated45°, top−4/right20; 11/16.5 text; 1000/4000ms timers; 300ms opacity; hidden hit testing disabled |
| Ribbon | mt16; padding32×8/r6; exact tail40×32 top8/offset−24 polygons and .9 RGB brightness; shadow0/6/14 cta35 |
| Card | mt24, full342 at viewport390, radius24, borderwhite30/1, white20/sigma6; padding20 plus border; title16/24 centered |
| Offer row | mt16, space-around, coin30/gap6/number28 bold; labels12/16 with4 gap; plus24/32; original gift34 path |
| CTA | Inner width300, h52/r26/mt20; horizontal cta→badge; 15/22.5 semibold, old price12/16 white70 strike, gap8; shadow0/8/20 badge35 |
| CTA press | Explicit approved150ms .98 scale while pressed, resets on release/cancel; only this source-absent interaction was added |
| Notifications | Normal600ms or immediate forceNotif; z40 ink35 with250ms fade; bottom12+safe/r24/p20/SlideUp280; circle40/bell20, text15 medium mt12, button48/r12 gap8 mt16 |
| Notification choice | Exact allow/deny values persisted; immediate removal, no exit; scrim cannot dismiss |
| Payment | z50 ink35/sigma2 barrier; fade250, slide280; r24, horizontal20/top8/bottom24+safe; handle40×4/mb16; title18/28 |
| Payment controls | Radios56 with divider1, rings20/border2/dot10, default UPI; button52/r14/mt20, physical135° brand gradient |
| Payment state | Processing…/opacity.6, disabled button and blocking scrim; completion at1200ms sets onboarding then tab(live); caption12/16 mt8 |
| Persistence | Exact logical `yourapp.hasOnboarded` string `1` and `yourapp.notifications` allow/deny values; SharedPreferences loaded before first application frame |

## Deviations and limitations retained intentionally

1. Approved: headline gap uses **8% of available height**. React `margin-top:8%`
   uses the containing block's width. At390×844 with zero insets the approved
   gap is67.52px rather than the browser's width-relative gap.
2. Approved: real Poppins800 is bundled. The original Google Fonts request did
   not fetch800, although the heading requests it; the original browser may
   select/synthesize a different weight. No silent700 substitution is made.
3. Approved: Continue's .98 press-scale is added despite its absence in that
   React class. Other source buttons retain their original lack of scaling.
4. Approved: instant skips entrances, including SlideUp/Rise, but never stops
   loops. The narrower CSS selector only disables `.fade-in`/`.slide-in`;
   this follows the user's clarified entrance-animation rule.
5. Correction to initial SPEC: Tailwind's transition default is
   `cubic-bezier(.4,0,.2,1)`, not CSS `ease`. Tooltip and BottomNav use that
   source default. Explicit CSS easeOut/easeInOut use the required Flutter curves.
6. Splash redirection is scoped to the splash screen. A debug jump during its
   first2seconds is not unexpectedly overwritten by the source shell's
   unconditional mount timer. This preserves the requested usable dev picker.
7. Unported routes and global CallSheet/PaySheet show explicit pending content.
   Section1A, Live, and the remaining screen ports are not implemented by this slice.
8. App-context live message time formatting currently uses local24-hour HH:mm;
   React's locale-selected12/24-hour formatting is pending its conversation port.
   Seeded message copy/times are unchanged. Browser online/offline events are
   represented by explicit local network state, not a newly added connectivity service.
9. Goldens are **Flutter regression baselines**, not proof of pixel identity to
    React. The supplied montages differ in saturation, proportions, gifts/price
    copy and prompt scrim appearance; they cannot support an exact390×844 diff.
    Original-size crops retain the evidence without stretching it. The source
    and explicit requirements take precedence. Tooltip/base-offer references
    are missing. Text rasterization, backdrop compositing and antialiasing need
    a same-scale standalone reference to quantify residual engine differences.

## Test policy

Golden fixture:390×844 logical px, DPR1, scale1, zero safe insets; bundled fonts
loaded before capture, production shadows enabled. Production code never uses
test prompt suppression or MotionScope freezing. Frozen loop frames retain
negative-delay phases. Interactive tests exercise real timers separately.

Regression files: `test/goldens/{welcome_offer,notif_prompt,payment_sheet,welcome_tooltip,foundation}.png`.
The foundation gallery also exercises every raw icon and both BottomNav modes.

Runtime checks cover notifications600ms, tooltip1000/4000ms, payment1200ms,
scrim/panel tap behavior, press scale, exact motion stops, negative phases,
reduced motion, stack behavior, splash routing and debug navigation.
Final commands and outcomes are recorded in `port_log.md`.

## Delivery self-evaluation

| Axis | Score | Evidence / remaining improvement |
|---|---|---|
| Accuracy | 4/5 | Analysis clean,27 tests pass, original icon paths verified. Same-scale React images are still needed to quantify raster-level differences. |
| Completeness | 4/5 | All requested foundation widgets and three1B bindings delivered; source-independent goldens exist. Montage-only input cannot prove the requested pixel-exact comparison. |
| Clarity | 4/5 | File inventory and element-by-element mapping are linked from the README; the detailed table is necessarily lengthy. |
| Actionability | 4/5 | Debug launch command, preview build, font assets and reproducible checks provided; interactive browser service unavailable here, and future-screen placeholders are explicit. |
| Conciseness | 4/5 | Final handoff is short; the port log and review intentionally retain detailed provenance rather than repeating full Dart files in chat. |

Overall: **4.0/5**. Highest-impact next verification is a same-scale390×844
React capture with known font loading/insets and matching timestamps. Next,
compare native-device text and blur rendering against that capture. The user
should agree that implementation/regression evidence is strong, while claiming
full React pixel identity from the available montages would overstate it.
