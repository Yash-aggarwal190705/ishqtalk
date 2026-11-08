# Update My Profile (Me tab) and rebuild Get tokens in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`TokenCoin`, `NeoButton`, `showAppSheet`, `AppSnack`, `LevelPill`).

**Source to read completely:** `src/views.tsx` (`Me`, `MenuRow`), `src/tokens.tsx` (`Tokens`), `src/tokenHistory.tsx` (`TokenCoin`), `src/ui.tsx` (`LvChip`, `Header`, `Icon`, `FrogAvatar`), `src/screenViews.tsx` (wiring).

This is a **delta** for the Me tab (earlier spec: `profile_and_discover_flutter_spec.md` and `fix_profile_glass_cards_prompt.md`; keep everything not listed below) plus a **full rewrite** of Get tokens (replaces the old Get Tokens in `commerce_screens_flutter_spec.md`, which had different amounts and layout).

---
# PART A. Me tab changes

1. **Edit icon** (`edit`, 48×48 button at top 46 / right 60 of the 216-high header block) now **pushes Edit profile** (`v2_05`). The old "Edit profile sheet" with `NameField` is removed.
2. **Gear icon** (48×48, top 46 / right 8) and the "App settings" row push **App settings** (`v2_06`). The row label is **"App settings"** (was "Settings").
3. **VIP card** and **Invite card** (the glass cards) now show the snackbar **"Coming soon"** (2.2 s, bottom = nav height + 12). The **Tokens** card (150 tall, spans two rows) pushes **Get tokens**.
4. **New section "Wallet and rewards"** between the glass cards and the white list: `section`, margin h 16, margin-top 20.
   - Title **"Wallet and rewards"** padding h 8, bottom 8, 14 / w600 `ink/75`.
   - A card: radius 28, 1 px `divider` border, white, clipped, rows separated by 1 px `divider` lines.
   - Four **tall MenuRows** (height 56, padding h 16, gap 12, row, left aligned, icon then label 14 / w500, then at the far right: optional trailing widget, gap 8, then a `chev` icon 20 colour `lvGray`):
     | Icon | Label | Trailing | Tap |
     |---|---|---|---|
     | `TokenCoin` 24 | **Get tokens** | the coin balance (e.g. **105**), 14 / w600 | push Get tokens |
     | `history` 24 | **Token history** | – | push Token history |
     | `bag` 24 | **My items** | – | push My items |
     | `diamond` 24 | **Level** | **Lv chip, gray**: height 20, radius 10, padding h 8, gap 4, 10 / w600 white, bg **#6F6785**; a 10 circle white@80% then **"Lv0"** | push Level |
   - Level chip numbers: the chip shows the user's current level; the prototype hardcodes **Lv0 gray**. Keep `lv` and `gray` as parameters (the non-gray fill is a 90° gradient #7C4AE8 → #8B5CF6).
5. **Below it** (margin-top 20, white block with top radius 20, padding-top 4) the existing normal rows (height 48): **Daily Bonus** (clipboard icon, with the 6 px `badge` dot after the label) → Bonus; **Credits** (dollar icon, trail: a 20 circle gradient #8B5CF6→#A78BFA with white "S" 10 / w700, then "0"; 14 / w500) → "Coming soon"; **App settings** (gear) → App settings. The "Package" row no longer exists.
6. Name shown in the header is the saved profile name (fallback "Your Name"). Counters: Messages sent / Following / Profiles viewed (unchanged).

Numeric checks (390 wide): the Wallet card is x 16, w 358; 4 rows × 56 + 3 dividers; coin balance trail "105" sits left of the chevron with 8 gap; the Level chip is 20 tall; tapping each row opens the right screen; back returns to Me with scroll position kept.

---
# PART B. Get tokens (pushed screen, slide-in 24 px + fade 280 ms)

Background `screen`, text `ink`. Opened from: Me (Tokens card, "Get tokens" row), Token history empty state / header where applicable. Back returns.

## B1. Anatomy
```
Column
├─ Header("Get tokens", right: history button)
├─ Scroll area (flex 1, padding h 16, bottom 16, no scrollbar)
│  ├─ Balance row (height 56)
│  └─ 2-column grid of 6 cards (margin-top 8, gaps 16)
├─ Footer (white, top border 1 px divider, padding h 16, top 12, bottom 12 + safe-area)
Confirm sheet · Snackbar
```
- **Header right slot:** a 48×48 button (margin-right −8) with the `history` icon 24, label "Token history" → push **Token history**.
- **Balance row:** height 56, space-between: left row gap 8: `TokenCoin(32)` + the balance formatted Indian grouping, 24 / w700, line height 28; right **"1 token = ₹1"** 14 `ink/75`.

## B2. Cards (radio group)
Amounts, in order: **100, 500, 1000, 5000, 8000, 10000**. Formatting `fmtIN` (e.g. "1,000", "10,000"). Grid: 2 columns, gap 16 both ways, margin-top 8. Width of each = (390 − 32 − 16)/2 = **171**. Each card is a radio button (semantics label "{n} tokens, ₹{n}"):
- Height **190**, radius 28, white, padding 16, column centred.
- **Not selected:** 1 px `divider` border, shadow `0 4 14 primary@8%`.
- **Selected:** 2 px `ink` border, hard shadow `3,3 0 ink`, plus a **check badge** at top 12 / right 12: 28 circle, bg `onlineCyan`, 2 px `ink` border, check icon 14 (viewBox 24, path `M5 12.5l4.5 4.5L19 7.5`, stroke 3, round) in `ink`.
- Children: `TokenCoin(56)` in a 56-high box with margin-top 4; then **"{n} tokens"** (margin-top 12) 18 / w600, line height 24; then a price pill pushed to the bottom: height 40, full width, fully rounded, centred **"₹{n}"** 16 / w600 `ink`; bg `primary10` when not selected, **vip gradient** when selected.
- Initial: nothing selected. Tapping selects (tap again keeps it selected).
Border width changes 1→2 px: keep the card size fixed (draw the border inside; use the same outer box).

## B3. Footer
- Caption (margin-bottom 8, centred, 14 `ink/75`): nothing selected → **"Pick a card to continue"**; selected → **"No extra fees. Tokens don’t expire."** (use the typographic apostrophe ’ U+2019).
- Button: `NeoButton` vip gradient, 52 tall, full width. Nothing selected: **"Choose an amount"**, **disabled** (disabled look: gradient stays, border `divider`, text `ink/60`, no shadow, see foundation). Selected: **"Get {n} tokens · ₹{n}"** (e.g. "Get 500 tokens · ₹500"), enabled → open the confirm sheet.

## B4. Confirm sheet (standard sheet)
- **"Confirm purchase"** 20 / w700.
- A list (margin-top 16) of 3 rows, each height 48, space-between, 1 px `divider` between rows: **Tokens** → "{n}", **Price** → "₹{n}", **Total** → "₹{n}". First two: label 16 `ink/75`, value 16 / w500. **Total**: label 16 / w600 `ink`, value 16 / w700.
- **"No extra fees. Tokens don’t expire."** margin-top 12, 14 `ink/75`. (The source has a literal `’` escape here that would print as text in a JSX paragraph; the intended text is the apostrophe ’. **Use ’ and mention it in your report**.)
- NeoButton **"Pay ₹{n}"** full width, margin-top 20 → close the sheet, then snackbar **"Payments arrive after the demo"**. **Payment is a stub: do not integrate a payment SDK; keep an `onPay(int amount)` callback with a TODO.** The balance does NOT change.
- Text button **"Cancel"** margin-top 4, height 48, 16 / w600 `primary`.

## B5. Snackbar
`AppSnack.show(bottom: 120 + safe-area)`, duration 2.4 s, text **"Payments arrive after the demo"**. Hide on dispose.

## B6. Numeric checks (width 390)
- Six cards, each 171×190, at x = 16 and x = 203; row gap 16; the price pill is 40 tall and full width of the card padding (139).
- No selection: button "Choose an amount" is disabled (gradient visible), caption "Pick a card to continue". Select "1,000": border 2 px `ink`, check badge visible, pill gradient, button "Get 1,000 tokens · ₹1,000", caption changes.
- Confirm sheet shows Tokens 1,000 / Price ₹1,000 / Total ₹1,000; "Pay ₹1,000" closes it and shows the snackbar; balance unchanged.
- Header history icon opens Token history; back closes the sheet first, then the screen.
- Test hooks: `initialSelected`, `initialSheet` (constructor params).

## B7. Do not
- No payment methods list, no offers/discount badges, no "most popular" tags: they are not in this revision.
