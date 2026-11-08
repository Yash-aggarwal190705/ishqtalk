# Build Splash, Login, Welcome offer (and the legacy Welcome / Profile setup) in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`K`, `t`, `cssLinear`/`brandGradient`/`vipGradient`, `showAppSheet`, `AppSnack`, `TokenCoin`). Build this **last** (build order v2_08).

**Source to read completely:** `src/login.tsx`, `src/welcomeOffer.tsx`, `src/onboarding.tsx`, `src/onboardingState.ts`, `src/views.tsx` (`Splash`), `src/App.tsx` (start-up routing), `src/screenViews.tsx` (wiring), `src/ui.tsx` (`Portrait`, `Coin`, `Icon`, `Logo`), `src/index.css` (`bg-splash`, `bg-welcome`, `lg-*` keyframes).

## 0. Flow and navigation
- App start → **Splash** for **2000 ms** → if "has onboarded" flag is set **or** a saved profile exists → the tabs shell on **Live**; else **Login**. (Replace history: back never returns to Splash.)
- **Login** → pick a provider → (provider flow) → **Welcome offer** (replace Login).
- **Welcome offer** → "Skip" or a successful simulated payment → set the onboarded flag, then show the tabs shell on **Live** (replace history; back from Live exits the app).
- Log out (settings) → clear onboarding flag + notification choice → Login. Delete account → clear everything → Splash.
- **Legacy, not reachable in the main flow** (build last, do not wire into start-up): `Welcome` and `ProfileSetup` in `onboarding.tsx`. Build them as plain screens behind routes `/legacy/welcome` and `/legacy/profile-setup` only so they exist; mention that in your report.
- Persistence (behind an `OnboardingRepository`, keys `yourapp.hasOnboarded` = "1", `yourapp.notifications` = allow|deny): `hasOnboarded()`, `setOnboarded()`, `resetOnboarding()` (removes both keys), `setNotifChoice(v)`.

---
# PART A. Splash
Gradient background 180° `#FFF1F5` → `#EDE4FF`. Clip everything.
1. **Portrait grid:** positioned left 4, right 4, top **−12**, height **54%** of the screen; 3 columns × 4 rows, gaps 4; 12 cells `Portrait(seed: i + 2)` (i = 0..11), each radius 8, clipped, overlaid with white@25%.
2. **Fade overlay:** bottom 0, full width, height **55%**, gradient 180° transparent `#EDE4FF@0` → `#EDE4FF` at 70%.
3. **Centre block:** vertically centred (the block's centre = screen centre), column centred:
   - Logo square: side = **clamp(80, 26% of the width, 96)** (390 → 96); radius 24; gradient 135° `#8B5CF6 → #FF6B6B`; shadow `0 8 24 #8B5CF6@30%`. Inside it a rounded box 66% × 62% (w × h of the square), radius 22, white@25%, with a small 16×16 rotated 45° white@25% radius-4 square at left 8, bottom −6 (a speech-bubble tail); centred in the box a `flame` icon 30 in white.
   - **"YourApp"** (margin-top 12) **clamp(24, 7.5% of the width, 30)**, w700, letter-spacing −0.5, italic, colour `primary`.
Numeric check: logo 96×96 at 390 wide; title 29.25 → use 29.25.

---
# PART B. Login
Background gradient 180° `#FFF1F5 → #EDE4FF`. Column with padding h 24 + safe-area top, scrolls (no scrollbar), min height = screen. A **busy bar** overlay: while `busy`, a 3 px high strip at the very top (above everything), a `primary→cta` 135° bar 1/3 of the width sliding left → right (−100% → 350% of its own width) in 1 s ease-in-out, looping.

## B1. Header block
Column centred, padding-top **max(48, 12% of the screen height)**.
- **Logo** 88×88 (`LoginLogo`): radius 24, `brandGradient`, shadow `0 10 30 primary@35%`. Inside: a chat-bubble glyph at 56% of the size (viewBox 48): white path `M10 6h28a6 6 0 016 6v18a6 6 0 01-6 6H25l-9 7v-7h-6a6 6 0 01-6-6V12a6 6 0 016-6z` and a `cta` heart `M24 29.5s-8.5-5-8.5-10.5a4.7 4.7 0 018.5-2.7A4.7 4.7 0 0132.5 19C32.5 24.5 24 29.5 24 29.5z`.
- **Floaters**: six emoji pinned to the logo's **top-right corner** (an absolutely positioned box at top 0 / right 0 of the logo; each emoji starts at that box's top-left), in order: 😍 size 20 dx −10; ❤️ 16 dx 12; 💗 22 dx −4; 😍 14 dx 8; ❤️ 18 dx −12; 💗 15 dx 6. Each loops forever, 3 s ease-out, start delay `i × 0.5 s`: from (0,0) scale .8 opacity 1 → to (dx, **−120**) scale 1.1 opacity 0 (opacity is 0 before the delay ends). Disable the loop when the system "reduce motion" flag is set.
- **"YourApp"** margin-top 12, 28 / w700 italic `ink`.

## B2. Headline
margin-top 40, row space-between, gap 12: left **"Register to Get\nFree Coins!"** (a forced line break), 22 / w700, line height 1.25 (27.5); right the **Coins illustration** `Coins` 72×64 (SVG viewBox 72×64): four stacked coins for y = 48, 38, 28, 18: a back ellipse (cx 36, cy y+8, rx 26, ry 9) fill gradient 135° (top-left → bottom-right of the shape's box) `vipA → vipB` at opacity .8, then a front ellipse (cx 36, cy y, rx 26, ry 9) same gradient with a 1.5 px stroke `coinBg`; only for the last (y = 18) an inner ellipse (rx 16, ry 5, no fill, 1.5 px `coinBg` stroke). Plus a sparkle `M56 4l2 5 5 2-5 2-2 5-2-5-5-2 5-2z` fill `primary10`, twinkling forever (opacity .2→1→.2, scale .6→1.1→.6, 2 s ease-in-out, about its centre). Draw with `CustomPainter` or flutter_svg (flutter_svg has no CSS vars: inline the hex values).

## B3. Provider buttons
Column, margin-top 20, gap 12. **ProviderBtn:** height 52, full width, radius 14, label 15 / w600 `ink` centred, an icon box 24×24 pinned at left 16 (vertically centred). Pressed: scale .98 and bg `primary10`. Disabled: opacity .7. Two styles: **primary** = 1.5 px `cta` border, white fill, shadow `0 6 18 cta@25%`; **secondary** = 1 px `divider` border, white@60% fill.
Order:
1. **Continue with Google** (primary, Google "G" icon 24: four paths in viewBox 48 — copy exactly from `GoogleG` in `login.tsx`: red #EA4335, blue #4285F4, yellow #FBBC05, green #34A853).
2. **Continue with Email** (secondary, `MailIcon`).
3. **Expandable area** with **Continue with X** (`XIcon` 22, filled) and **Continue with Telegram** (`TelegramIcon` 24, filled), collapsed by default (height 0, clipped); expanding animates the height 250 ms ease-out; when expanded each child fades/rises (opacity 0→1, translateY 8→0, 300 ms, backwards fill): X delay 0, Telegram delay 60 ms.
4. If not expanded: a **"More ⌄"** button (height 48, padding h 16, centred, margin-bottom −4, 12 `ink2`, label "More" + `chev` icon 14 rotated 90°) → expands.
5. **Phone row** (always in the layout): collapsed = a **teaser**: opacity .35, not tappable, margin-top −12, with a vertical alpha mask (opaque at top → transparent at bottom); expanded = fully visible and tappable with a rise animation (delay 120 ms). The button **Continue with Phone** (secondary, `PhoneIcon`) is disabled while not expanded.
Source icon paths for Mail/Phone/X/Telegram are at the top of `login.tsx`; copy them exactly.

## B4. Footer
`mt-auto` (pushes to the bottom), padding-top 24, bottom 16 + safe-area, centred text 11 / line height 1.5 `ink2`: **"By logging in, you confirm you're over 18 years old and agree to our "** + a link **"Terms of Use"** + **" and "** + a link **"Privacy Policy"** + **"."** (links `primary`, underlined; inline spans inside one paragraph, so they wrap with the text). Tap → the Terms / Privacy modal.

## B5. Behaviour
- `start(provider)`: ignore if `busy`; set `busy` (buttons disabled + top bar). For **X / Telegram**: after **1200 ms** `busy = false` and go to **Welcome offer**. For **Google / Email / Phone**: after **400 ms** `busy = false` and open that provider's modal.
- `success()` (a provider modal completed): close the modal, `busy = true`, after **1000 ms** `busy = false` → Welcome offer.
- All timers cancelled on dispose. The login is a **demo**: no real auth. Keep an `AuthRepository` with `signInWithGoogle/Email/Phone/X/Telegram` that resolves successfully; TODO real providers.
- **"Demo only"** toast (from "Add another account"): a pill centred horizontally, bottom 96, bg `ink`, text white 12, padding h 16 / v 8, fully rounded, 1.8 s.

## B6. Shared modal frame (`Modal`)
Full-screen scrim `ink@35` with a **4 px backdrop blur** (`ImageFilter.blur(sigmaX: 4, sigmaY: 4)` over the scrim); tap the scrim closes. Two forms:
- **Dialog** (centre): width = screen − 48, max height 90%, radius 20, white, padding 20, shadow `0 20 60 ink@25%`; fade-in 250 ms.
- **Sheet** (bottom): full width, max height 92%, top radius 24, white, padding left/right 20, top 8, bottom 24 + safe-area; handle 40×4 `divider` centred, margin-bottom 16; slide up 280 ms.
Modals are routes (system back closes one).
Primary button style used inside (`primaryBtn`): height 52, full width, radius 14, `brandGradient`, text 15 / w600 white, **disabled = opacity .4**.

## B7. Google account chooser (Dialog)
- Centre column: the **logo at 32** (same glyph, radius scales: use radius 24 × 32/88 ≈ 9), then **"Choose an account"** (margin-top 12) 20 / w600, then **"to continue to YourApp"** 13 `ink2`.
- List (margin-top 16, 1 px top border `divider`), rows with 1 px bottom border `divider`, each height 56, gap 12: a 36 circle with the initial (14 / w600) and a text column (name 14 / w500, email 12 `ink2`, both one line ellipsis). Accounts: **Alex Morgan** alex.morgan@example.com (bg `primary10`, text `primary`); **Sam Rivera** sam.rivera@example.com (bg `roseGold`@50%, text `ink`); **Taylor Kim** taylor.kim@example.com (bg `primary10`, text `primary`). Tapping any → `success()`.
- Last row: **"＋"** circle 36 (1 px `divider` border, 18 `primary`, glyph U+FF0B) + **"Add another account"** 14 → shows the "Demo only" toast (does not close).
- Footer note (margin-top 8) centred **"Demo account chooser"** 10 `ink2`.

## B8. Email / Phone sheet (Sheet) with OTP
State: step input|otp, email, country code (+91 default), number, touched. A form-like column:
- **Input step.** Title **"Continue with Email"** / **"Continue with Phone"** 18 / w600; **"We will send you a verification code."** margin-top 4, 13 `ink2`.
  - Email: a box margin-top 20, height 52, radius 14, 1 px border (`divider`; `primary` while focused; `badge` when an error is shown), bg `card`, padding h 16, **autofocus**, keyboard type email, hint **"Email address"**, text 16, no underline.
  - Phone: margin-top 20, row gap 8: a **country code dropdown** (width 96, height 52, radius 14, 1 px `divider` border, bg `card`, padding h 12, 16; options **+91, +1, +44, +92, +971**) and the number box (flex 1, same style as email, keyboard phone, hint **"Phone number"**, digits only, max length **12**, autofocus).
  - Error line (margin-top 6, min height 20, 12 `badge`): shown only when `touched` and invalid: email → **"Enter a valid email address."**, phone → **"Enter a valid phone number."**. `touched` is set on blur and on submit.
  - Valid: email `^[^\s@]+@[^\s@]+\.[^\s@]{2,}$` (on the trimmed text); phone `^\d{7,12}$`.
  - **"Send code"** primary button, margin-top 12, **disabled while invalid**. Keyboard "done"/Enter submits: sets touched; if valid → OTP step.
- **OTP step.** Title **"Enter the 6-digit code"** 18 / w600; below (margin-top 4, 13 `ink2`): **"Sent to {target} "** + underlined text button **"Change"** (w500 `primary`) → back to the input step. `target` = email (trimmed) or `"{cc} {number}"` (if the number is empty: "{cc} 98765 43210").
  - Six boxes (margin-top 20, row, space-between, gap 8): each flexible width, height **56**, radius 12, 1 px border (`divider`; `primary` + a 2 px `primary@30%` glow when focused; `badge` when an error is shown), bg `card`, text centred 20 / w600, numeric keyboard, one digit each (take the **last** typed digit, strip non-digits; typing moves focus to the next box; Backspace in an empty box moves to the previous box; the first box has the one-time-code autofill hint; **autofocus the first box on entry**). **Paste**: digits of the pasted text (max 6) fill the boxes and focus goes to box min(len, 5). Enter with 6 digits verifies. Editing clears the error.
  - Error (margin-top 8, min height 20, 12 `badge`): **"Incorrect code. Please try again."** — also **shake** the row (0 → −8 → 8 → −6 → 6 → 0 px over 400 ms, at 20/40/60/80%).
  - **"Demo code: 123456"** margin-top 4, 12 `ink2`.
  - **"Verify"** primary button margin-top 16, **disabled while fewer than 6 digits**; wrong code → error + shake; right code (`123456`) → `success()`.
  - **Resend** text button (margin-top 8, height 48, 14 / w500): while `secs > 0` the label **"Resend code in {secs}s"** (colour `ink2`, disabled) counting down from **30** each second; at 0 → **"Resend code"** (`primary`, enabled); tap restarts at 30.
- The Google chooser's "pick" in the source starts the e-mail OTP flow only in a dev state (`email-otp` with alex.morgan@example.com prefilled); the real flow uses `success()` directly. Expose `initialModal`/`initialExpanded` constructor params for tests only.
- The sheet rises above the keyboard (add the keyboard inset).

## B9. Terms / Privacy (Dialog)
Title (18 / w600): **"Terms of Use"** or **"Privacy Policy"**; body (margin-top 8, 14, line height 24, `ink2`):
- Terms: **"Placeholder terms. By using YourApp you agree to be respectful, to be at least 18 years old and to not share harmful content. This is a prototype and no real terms apply."**
- Privacy: **"Placeholder policy. This prototype stores nothing on a server. Any data you enter stays on this device and is never sent anywhere."**
Then the primary button **"Close"** (margin-top 16).

## B10. Numeric checks (width 390, height 844)
- Logo 88×88 centred, top at max(48, 12% × 844 = 101) + safe-area; headline row starts 40 below the "YourApp" title; the three first buttons are 52 tall with 12 gaps, 342 wide (x = 24).
- Collapsed: "More" visible and the phone teaser (opacity .35) below; tapping "More" reveals X, Telegram, and the full Phone button.
- Email flow: "Continue with Email" → after 400 ms the sheet → type "a@b.co" → Send code enabled → OTP step with target "a@b.co" → "123456" → Verify → after 1000 ms the Welcome offer. Wrong code → error text and shake. Resend label counts 30 → 0.
- Google flow: chooser lists 3 accounts + "Add another account" (shows "Demo only", stays open); tapping an account → Welcome offer after 1000 ms.
- X / Telegram: top progress bar for 1.2 s, then Welcome offer.

---
# PART C. Welcome offer
Background vertical gradient 180° `primary` (#8B5CF6) → `profileA` (#C4B5FD) at 50% → `profileB` (#FFB4A8). Clipped. Text white.
- **Drifting blobs** (5 circles, fill `coin`, opacity .5, blur sigma **6**): sizes/positions (left, top are % of the screen width/height): (180, −12%, 6%, delay 0), (130, 70%, 18%, −2 s), (200, 58%, 62%, −4 s), (120, −6%, 70%, −6 s), (150, 30%, 84%, −8 s). Each animates forever, 9 s ease-in-out: translate (0,0) → (14, −22) → (0,0); negative delays mean they start part-way through the cycle (start the controller at the corresponding offset).
- **Content column** (scrolls, no scrollbar): padding h 24, top safe-area, bottom 24 + safe-area, centred.
  1. **Top row** height 56, right aligned: **"Skip"** text button (height 48, padding h 8, 14, white@70%) → `finish()`. A **tooltip** absolutely at top 46 / right 8: a bg `badge` rounded-8 bubble (padding h 12 / v 6, 11 white, one line) **"Explore What's New!"** with a 10×10 rotated 45° `badge` square as an arrow at top −4 / right 20. It fades in at **1000 ms** (opacity 0→1 over 300 ms) and fades out at **4000 ms**; not tappable.
  2. margin-top **8%** of the height: **"DOUBLE"** 44 / w800 `coin` colour, line height 1, with a 1 px `vipB` text outline and a drop shadow `0 3 0 ink@30%` (draw the stroke with a second `Text` using `foreground` Paint style stroke width 1); below (margin-top 4) **"COINS NOW"** 28 / w800 white, line height 1.25.
  3. **Ribbon** (margin-top 16): a `cta` bubble (radius 6, padding h 32 / v 8, 16 / w600 white, shadow `0 6 14 cta@35%`) **"Welcome Bonus!"**, with two tails (each 40×32, `cta` darkened to 90% brightness) at top 8, left −24 and right −24: left tail polygon (0,0)(100%,0)(100%,100%)(0,100%)(25%,50%); right tail (0,0)(100%,0)(75%,50%)(100%,100%)(0,100%). Draw with `ClipPath`/`CustomClipper`, tails behind the bubble.
  4. **Glass card** (margin-top 24, full width): radius 24, 1 px white@30% border, white@20% fill, padding 20, **backdrop blur sigma 12** (Tailwind `backdrop-blur-md`). Children:
     - **"Purchase Now & Get:"** centred 16 / w600.
     - Row (margin-top 16, space-around, centred): column [row gap 6: `Coin(30)` + **"200"** 28 / w700 line height 1; below, gap 4, **"Coins"** 12] · **"+"** 24 / w700 · column [gift icon 34 (viewBox 24, stroke 1.75, round, white: `rect x3 y8 w18 h4 rx1`; `M5 12v8h14v-8M12 8v12M12 8c-2 0-4-1-4-2.5S10 3 12 8c2-5 4-4.5 4-3S14 8 12 8z`); below **"x5 gifts"** 12].
     - **CTA button** (margin-top 20): height 52, full width, radius 26, `bg-cta-pill` (gradient 90° `cta → badge`), shadow `0 8 20 badge@35%`, centred row gap 8: **"Continue for ₹119.99"** 15 / w600 + **"₹239.98"** 12 / w400 with a strikethrough at opacity .7. Tap → open the payment sheet.
- **Notification dialog:** **600 ms** after the screen opens (unless a test flag forces it), show (scrim `ink@35`, no blur, anchored at the bottom with 12 padding on all sides + safe-area; fade 250 ms): a card radius 24, white, padding 20, slide-up 280 ms: a 40 circle `primary10` with a `bell` icon 20 `primary` centred; **"Allow YourApp to send you notifications?"** (margin-top 12) centred 15 / w500; buttons column (margin-top 16, gap 8, each height 48, radius 12, 15 / w600): **Allow** (bg `primary`, white) and **"Don't allow"** (bg `primary10`, text `ink`). Either choice saves the notification choice (`allow`/`deny`) in the repository and closes the dialog; **TODO**: request the real OS notification permission on Allow. (The dialog is not dismissible by the scrim.)
- **Payment sheet** (Sheet frame B6 but its scrim has the 4 px blur; no handle difference): title **"Payment method"** 18 / w600; two radio rows (margin-top 8) **UPI** (default selected) and **Card**, each height 56, 1 px bottom border `divider`, 15 / w500, right a 20 radio (2 px border `primary` when selected else `lvGray`, with a 10 `primary` dot); **Pay button** (margin-top 20): `primaryBtn` style, label **"Pay ₹119.99"**; tapping → label **"Processing…"**, disabled (opacity .6), scrim taps ignored, after **1200 ms** → `finish()`. Under it (margin-top 8) centred **"Simulated payment. No money is charged."** 12 `ink2`. **Stub:** no payment SDK; keep `onPay` with a TODO.
- `finish()` = `setOnboarded()` then open the tabs shell on **Live** (replace history).
Numeric checks: the glass card is 342 wide; the CTA is 52 tall; the notification dialog appears at 0.6 s; the tooltip appears at 1.0 s and is gone after 4.0 s; Skip → Live with the flag saved; Pay → "Processing…" → Live after 1.2 s.

---
# PART D. Legacy screens (not wired)
**Welcome:** background `screen`, padding h 20 + safe areas, column. Middle (flex 1, centred, gap 12, padding v 24): `Logo(88)` (the shared brand logo in `ui.tsx`), **"YourApp"** clamp(24, 7.5%, 30) / w700 italic `primary` (letter-spacing −0.5), **"Find someone. Start a chat."** 14 `ink2`. Card (radius 16, `card`, padding 20): **"A SMALL START"** 12 / w600 uppercase tracking .5 `primary`; **"Pick a name, then meet people at your own pace."** (margin-top 6) 16 / w600 line height 24; **"You can change it later."** (margin-top 4) 14 `ink2`. Button **"Start exploring"** (margin-top 16, height 52, radius 14, `primary`, 16 / w600 white). Note box (margin-top 16, bottom 16, radius 12, 1 px `divider` border, padding 12, row gap 10, 12 `ink2`): `eye` icon 18 `ink3`; **"Local preview · no account required"** (w600 `ink`) over **"Seeded data is used while the server features are being built."**
**ProfileSetup:** slide-in; padding h 20; **"Set up your profile"** 20 / w600; **"Just a name to begin."** 14 `ink2`; avatar preview 80 circle `primary10` with the first letter 30 / w600 `primary` (or a `user` icon 36 `primary@60%`); display-name field (label "Display name" 14 / w500; box height 52, radius 14, 1 px border `divider`/`primary` focus/`badge` error, white, hint "Your name", max length 60; below a row 12: error text (`badge`; empty/whitespace → "Please enter a name.", 1 char → "Use at least 2 characters.", shown only after touched/blur) and the right counter "{len}/60" `ink3`); **"Local preview · your profile stays on this device."** 12 `ink3`. Bottom button height 52, radius 14, `primary` (disabled `primary@40%`), 16 / w600: "Save and continue" → "Saving…" (spinner) for 700 ms → saves the name → "Saved" → after 700 ms calls `done`.

## Do not
- Do not add real social login SDKs, phone auth, or notification permission calls (TODO hooks only).
- Do not wire Welcome / ProfileSetup into start-up.
- Do not show the Demo code anywhere else.
