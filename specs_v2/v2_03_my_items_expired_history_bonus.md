# Build My items, Expired items, History (call list) and the Bonus data update in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`PassTicket`, `NeoButton`, `OutlineButton52`, `showAppSheet`, `ShimmerBox`).

**Source to read completely:** `src/myItems.tsx` (`MyItems`, `ExpiredItems`, `ItemTabs`, `PassTicket`, `Empty`, `Skeleton`, `TicketArt`, `GiftArt`, `BagArt`), `src/screens2.tsx` (`History`, `Bonus`), `src/screenViews.tsx` (wiring), `src/ui.tsx` (`Header`, `Icon`, `Sheet`, `Portrait`).

- **My items** and **Expired items** are new and **replace the old "Package" screen** (`commerce_screens_flutter_spec.md` Part D). Delete or retire the old Package screen: every entry point to it now opens My items.
- **History** (call list) is unchanged; only its empty state is shown in the screenshots, the list state is in the commerce spec Part D2 and repeated below.
- **Bonus** is unchanged from `commerce_screens_flutter_spec.md` Part C except the data below.

All four are pushed screens, slide-in (24 px + fade, 280 ms).

---

# PART A. My items (`MyItems`)

Background `screen`. Column: `Header("My items")`, tab bar, tab panel. Sheet on top.

## A1. Header
Shared `Header`. Right slot: a 48×48 button with margin-right −8, centred `history` icon 24 (path `M4 12a8 8 0 108-8 8 8 0 00-6 2.7M4 4v4h4M12 8v4l3 2`, stroke 1.75), with a **permanent** badge dot (10×10, bg `badge`, 2 px border in `screen` colour, top 10 / right 10 of the button). Label "Expired items". Tap → push **Expired items**.

## A2. Tabs (`ItemTabs`, shared with Expired items)
Height 48, 2 equal columns, 1 px `divider` line under the whole bar. Each tab is a column: the label (flex 1, vertically centred) then an underline at the very bottom. Labels **"Passes"** and **"Gifts"**, 16. Selected: **w600 `ink`** with a 3 px tall, 56 wide, fully rounded underline filled with the **vip gradient**. Unselected: w500 `ink/75`, no underline. Initial tab: Passes. (Left/right arrow keys switch tabs: optional.)

## A3. Passes tab
- **Loading:** skeleton while loading (prototype 700 ms, min 300 ms). 4 rows, each height 72, padding h 16, gap 12: shimmer 40×28 radius 8; column (flex 1, spaced 8): bar h 14 / width 1/2 / radius 4 and bar h 12 / width 2/3 / radius 4; shimmer 56×24 fully rounded on the right. The header and tab bar are already visible. The same skeleton shows in the **Gifts** tab while loading.
- **List** (fade-in, scrolls): rows are buttons, height 72, padding h 16, gap 12, centred, left aligned. Layout: `PassTicket` (40×28) · column (flex 1): line 1 **"{name} × {qty}"** 16 / w500 one line ellipsis (the sign is the multiplication sign × U+00D7 with spaces around it); line 2 `when` 14 `ink/75` one line ellipsis · an **"Active"** chip: fully rounded, bg `onlineCyan`, padding h 12 / v 4, text 12 / w600 `ink`.
- Seed (`ACTIVE`):
  1. match · "Match pass" · 2 · "Expires 12 Nov, 6:30 pm" · desc "Skip the wait and start a video match right away."
  2. chat · "Chat pass" · 1 · "Expires 15 Nov, 9:00 am" · desc "Start a chat with anyone, even before they reply."
- **Empty (no active passes):** `Empty` component (A5) with art `TicketArt`, title **"No passes yet"**, body **"Earn passes with your daily bonus."**, and a **NeoButton "See daily bonus"** (52 tall, hugging, padding h 32). Per the source this button runs `seeBonus = () => push('level')`, i.e. it opens the **Level** screen (not Bonus). That looks like a prototype slip (the label says "daily bonus" and Level has a "Daily bonus" section), but **follow the source and list it in your final report** so I can decide. Keep the callback injectable (`onSeeBonus`).
- **Tap a row** → item sheet (A4).

## A4. Item sheet (`showAppSheet`, standard Sheet)
- Centred column: `PassTicket(w: 80)` (80×56), then **"{name} × {qty}"** (margin-top 12) 18 / w600, then the description (margin-top 4) 14 `ink/75`, then the `when` text (margin-top 4) 14 `ink/75`.
- **"Use now"** NeoButton full width, margin-top 20 → close the sheet, then switch to the **Live** tab.
- **"Close"** text button (margin-top 4, height 48, 16 / w600 `primary`).

## A5. Gifts tab and the `Empty` component
`Empty`: fade-in, fills the panel, content centred both ways with padding h 32 and **bottom padding 96** (so it sits above the true centre); text centred. Column: a **112 circle** bg `divider` (#ECE7F5) with the art (56×56, colour `primary`, stroke 1.25); title (margin-top 20) **20 / w700**; body (margin-top 4) 16 `ink/75`; optional action (margin-top 24).
- Gifts tab (always empty in the seed): art `GiftArt`, title **"No gifts yet"**, body **"Gifts you get in rooms will show up here."**, action **OutlineButton "Explore rooms"** (52 tall, radius 20, 2 px `primary` border, white, text 16 / w600 `primary`, padding h 32) → switch to the **Explore** tab.
- Art paths (viewBox 24, stroke 1.25, round, no fill) are in `myItems.tsx` (`TicketArt`, `GiftArt`, `BagArt`): copy them exactly.

## A6. Entry points
Me → "My items"; Bonus header ticket icon; (old Package entries all go here).

---

# PART B. Expired items (`ExpiredItems`)

Same frame: `Header("Expired items")` (**no** right slot), the same `ItemTabs`, same panel and skeleton (prototype delay 600 ms, min 300 ms).
- **Passes tab, list:** rows are **not** tappable: height 72, padding h 16, gap 12, centred. `PassTicket` at **opacity .6** · column (flex 1): line 1 "{name} × {qty}" 16 / w500 ellipsis; line 2 (margin-top 2) an **"Expired"** chip: fully rounded, bg `divider`, padding h 8 / v 2, text 12 / w600 `ink` · on the right the `when` text, **max width 132**, right aligned, 14 `ink/75`, wraps to two lines (e.g. "Expired 25 Oct, 5:15 pm" wraps after "5:15").
- Seed (`EXPIRED`, in this order): Match pass ×2 "Expired 25 Oct, 5:15 pm"; Match pass ×2 "Expired 24 Oct, 8:40 pm"; Match pass ×1 "Expired 22 Oct, 11:05 am"; Chat pass ×1 "Expired 20 Oct, 7:30 pm"; Chat pass ×2 "Expired 18 Oct, 2:10 pm"; Chat pass ×1 "Expired 15 Oct, 9:45 am". (Match = `primary` ticket, Chat = `onlineCyan` ticket.)
- **Passes empty** (no expired passes): `Empty`, art `TicketArt`, title **"No expired passes"**, body **"Passes that run out will be listed here."**, no action.
- **Gifts tab:** `Empty`, art `BagArt`, title **"No expired gifts"**, body **"Gifts that run out will be listed here."**, no action.
- The tab bar keeps working in all states.

---

# PART C. History (call list)

White-ish `screen` background, `Header("History")`, slide-in. Reached from: Live (clock button), Messages (history icon).
- **List** rows: height 72, padding h 16, gap 12, centred: `Portrait(seed)` 48 circle · column (flex 1): name 14 / w600 one line ellipsis; below it the time text 12 `ink2` with **tabular figures** · a 40×40 circle button bg `primary` with a white `cam` icon 22 (label "Call back") → opens the Calling Sheet for that person (the sheet opens above History; closing it returns to History). Seed: seed 2 "she has 🥰😘" "00:37  00:00:20"; seed 5 "junumoni begum" "00:37  00:00:20"; seed 7 "sona" "00:35  00:01:20" (two spaces inside the time strings are real).
- **Empty** (no calls): centred (bottom padding 128): **"No calls yet"** 14 `ink2`; below (margin-top 16) an outlined pill **"Start chat"** (height 40, padding h 24, 1 px `primary` border, fully rounded, 14 / w600 `primary`) → switch to the **Live** tab.

---

# PART D. Bonus (data update only)

Build/keep the Bonus screen exactly as in `commerce_screens_flutter_spec.md` Part C. This revision of the source changes only:
- **Header balance** (right slot, row gap 12, 14 / w500): [`bag` icon 20 in `primary` + the ticket count] (this whole group is a button → push **My items**) · [`Coin` 20 + coin balance]. While loading both numbers show **0**. Ticket count = **3**, or **4 after signing in today**. Coin balance = the app's token balance (**105**).
- `openPackage` now means "push My items" (the VIP / Get VIP / "Give gifts" / "Get month VIP" actions also push My items). `openExplore` = switch to the Explore tab.
- Everything else in Part C (7 sign-in cells, Sign in button, VIP card, Tasks card, Daily Bonus card, countdowns 08:48:06 / 08:48:20 ticking from the local clock, toast "+1 Match Ticket") stays.

---

# Numeric checks (width 390)

- My items: header + a 48 tall tab bar; each tab is 195 wide; underline 56×3, centred under the selected tab; row height 72; Active chip height 24 (line height 16 + padding 4 + 4).
- Passes list has exactly 2 rows ("Match pass × 2", "Chat pass × 1"). Tapping the first opens a sheet with "Match pass × 2", the description and "Expires 12 Nov, 6:30 pm", buttons "Use now", "Close". "Use now" → Live tab visible and the sheet gone.
- Fake an empty repository: "No passes yet", "Earn passes with your daily bonus.", button "See daily bonus" (52 tall). The art circle is 112×112 and its centre is **48 above** the panel's vertical centre (bottom padding 96).
- Gifts tab: "No gifts yet", "Gifts you get in rooms will show up here.", outline button "Explore rooms".
- Expired: 6 rows; each time text max width 132; every ticket at opacity .6; Gifts tab "No expired gifts".
- History empty: "No calls yet" and "Start chat" (40 tall).

## Do not
- Do not keep the old Package screen, "Props/Gift" tabs or the "×{qty}" grid.
- Do not add counts, filters, or a "buy" button to these screens.
