# Build App settings (with Log out sheet and Delete account sheet) in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`AppSwitch`, `NeoButton` incl. the `danger` variant and its disabled look, `showAppSheet`, `AppSnack`).

**Source to read completely:** `src/settings.tsx` (`SettingsPreview`, `Group`, `Row`, `Switch`), `src/screenViews.tsx` (`SettingsView`: what log out and delete do), `src/onboardingState.ts`, `src/ui.tsx` (`Header`, `Icon`, `Sheet`), `src/index.css`.

A **pushed** screen (slide-in 24 px + fade 280 ms), opened from My Profile → "App settings". Background `screen`, text `ink`. Back returns to Me.

## 1. Anatomy
```
Column
├─ Header("App settings")
└─ Scroll area (no scrollbar), bottom padding 24 + safe-area
   ├─ Group "General"   ├─ Group "Safety"   ├─ Group "Comfort"   ├─ Group "Device"   ├─ Group "Account"
   ├─ "Log out" button (margin-top 20)
   └─ "YourApp v0.1 demo" (margin-top 20)
Log out sheet · Delete account sheet · Snackbar
```

## 2. Groups and rows
**Group:** margin-top 20. Title (padding h 24, bottom 8) 14 / w600 `ink/75`. Then a card: margin h 16, radius 28, 1 px `divider` border, white, clipped, shadow `0 4 14 primary@8%`, rows separated by 1 px `divider` lines (no line after the last).

**Row:** full width, padding h 20, row gap 12, centred. Height **56** without a caption, **min 72** (padding v 8) with a caption. Left column (flex 1, left aligned): **label** 16 / w500 (`ink`, or `danger` #D92D2D for the danger row) over an optional **caption** 14 `ink/75`. Then an optional **value** (shrink 0, 16, `ink/75`). Then the trailing widget: a **switch** if the row has one; else a `chev` icon 18 `ink2` if the row is tappable and not `plain`; plain rows (Device group) have no chevron even though they are tappable.

| Group | Row | Caption | Value | Trailing | Tap |
|---|---|---|---|---|---|
| General | App language | – | English | chev | snackbar "Coming soon" |
| General | Privacy policy | – | – | chev | "Coming soon" |
| General | Terms of service | – | – | chev | "Coming soon" |
| Safety | Blocked accounts | – | – | chev | "Coming soon" |
| Safety | My reports | Reports you sent and their status | – | chev | "Coming soon" |
| Safety | Safe mode | Hide sensitive content in discovery | – | **switch, default On** | the switch only |
| Comfort | Do not disturb | Pause call requests and notifications | – | **switch, default Off** | the switch only |
| Comfort | Camera beauty | – | – | chev | "Coming soon" |
| Device | Clear cache (plain) | – | **86 MB** → after tap **0 MB** | none | if the value is not "0 MB": set it to "0 MB" and snackbar **"Cache cleared"**; if already "0 MB" do nothing |
| Device | Check for updates (plain) | – | **Up to date** | none | ignore if the value is "Checking…"; else set the value to **"Checking…"** and after **1200 ms** back to **"Up to date"** |
| Account | Delete account (danger) | – | – | chev | open the Delete account sheet |
Rows with a switch are **not** tappable as a whole; only the switch toggles. Persist Safe mode and Do not disturb in local settings storage (behind a `SettingsRepository`); the cache size is a fake number (TODO: real cache size later).

**Switch** = `AppSwitch` from the reference file (not a Material `Switch`): a button 48 tall; a label **"On"** / **"Off"** (box 28 wide, right aligned, 14 / w600; On = `ink`, Off = `ink/75`), gap 8, then the track 48×28 (fully rounded, 2 px border). On: border and fill `primary`; Off: border `lvGray`, fill `card`. Thumb: 20×20 white circle, **4 px inside the outer edge**: Off at x = 4..24, On at x = 24..44 (track outer coordinates), vertically centred; On has a soft default shadow, Off has a 1.5 px `lvGray` ring instead. Animate the thumb 150 ms. The switch box is offset 8 px to the right (CSS `-mr-2`), so the track's right edge is 20 px from the card's right edge, aligned with where the chevrons end.

**Log out button** (below the groups): margin h 16, margin-top 20, height 56, radius 28, 1 px `divider` border, white, centred text **"Log out"** 16 / w700 `ink`. Tap → open the Log out sheet.
**Footer text:** **"YourApp v0.1 demo"** centred, margin-top 20, 14 `ink/75`. (Use the real app version string later: keep the exact text for now.)

## 3. Log out sheet (standard `Sheet`)
- **"Log out of YourApp?"** 20 / w700.
- **"You can log back in any time."** margin-top 4, 16 `ink/75`.
- **"Log out"** NeoButton (vip gradient), full width, margin-top 20.
- **"Stay logged in"** text button, margin-top 4, height 48, 16 / w600 `primary` → close.
- **Log out action:** close the sheet, **reset the onboarding state** (the "has onboarded" flag and the notification choice), and **replace** the whole navigation history with the **Login** screen (back from Login exits the app). Keep the user's local data decisions to the repository layer (the prototype only resets onboarding). TODO: sign out from the real auth provider.

## 4. Delete account sheet (full height)
A custom tall sheet (a route): scrim `ink@50` (tap closes), the panel is anchored to the bottom, **top edge 40 below the top of the screen**, radius 28 on the top corners, white, padding left/right 20, top 8, bottom 16 + safe-area; handle 40×4 `divider` centred, 16 below. Content scrolls (no scrollbar) above two fixed buttons.
Scrolling content:
1. **"Delete your account?"** 24 / w700, line height 32.
2. **"Here is what happens when you delete:"** margin-top 8, 16 `ink/75`.
3. List (margin-top 16, gap 12), each item row: circle 40 bg `tintInvite` with an icon 20 in `ink`, gap 12, text 16:
   - `user` icon — **Your profile is removed**
   - `chat` icon — **Your messages are removed**
   - `dollar` icon — **Your tokens are removed**
   - `shield` icon — **This can't be undone**
4. Checkbox row (margin-top 24, min height 48, gap 12, 16 / w500): a **24×24 checkbox** (accent `primary` when checked; unchecked: a 2 px grey `#767676` outline, radius 4) + **"I understand"**. Tapping the row toggles it. The check state resets when the sheet closes.
Fixed bottom buttons (always visible):
- **"Delete account"**: red NeoButton (52 tall, radius 20, 2 px `ink` border, bg `danger`, text white 16 / w600, hard shadow). **Disabled until the checkbox is checked**; disabled look: flat `card` fill (#F7F4FC), border `divider`, text `ink/60`, no shadow (for the *red* button the fill does change, unlike the orange one).
- **"Keep my account"** text button (margin-top 4, height 48, 16 / w600 `primary`), **autofocus** → close.
**Delete action:** clear **all** local data (settings, profile, onboarding flags, conversations, caches), reset every in-memory store, and restart the app from the **Splash** screen with a clean history (the prototype does `localStorage.clear()` and a page reload, which lands on Splash → Login). TODO: call the real "delete account" API here; until then it is a local reset only. Do not close the app process.

## 5. Snackbar
`AppSnack.show(bottom: 24 + safeBottom)`. Texts: "Coming soon", "Cache cleared". Hide on dispose; cancel the "Checking…" timer on dispose.

## 6. Numeric checks (width 390)
- Group titles start at x = 24; card x = 16, width 358; rows 56 tall (no caption) / min 72 (caption); chevron right edge at x = 354 (card right 374 − 20).
- Row order: General (3), Safety (3), Comfort (2), Device (2), Account (1). Safe mode shows "On" with the switch on; Do not disturb shows "Off".
- Toggling a switch changes its label and thumb position (x 4..24 ↔ 24..44) without opening anything.
- "Clear cache" shows "86 MB"; tap → "0 MB" + snackbar "Cache cleared"; second tap does nothing. "Check for updates": tap → "Checking…", after 1.2 s "Up to date"; taps while checking are ignored.
- Log out button is 56 tall, white with a 1 px border; footer text "YourApp v0.1 demo".
- Delete sheet: top edge at y = 40; "Delete account" disabled (flat `card` fill) until "I understand" is checked; "Keep my account" closes; back closes the sheet first, then the screen.
- Log out → sheet → "Log out" → Login screen; system back there exits the app.

## 7. Do not
- Do not use Material `SwitchListTile`, `Checkbox` default styling with a different size, or a `showDialog` for the delete sheet.
- Do not implement language, privacy, terms, blocked accounts, reports or beauty screens: they are "Coming soon" stubs.
