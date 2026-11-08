# Build Token history (list, filter, empty, loading) and Level in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`TokenCoin`, `OrbitBadge`, `LevelPill`, `NeoButton`, `showAppSheet`, `ShimmerBox`, `fmtIN`).

**Source to read completely:** `src/tokenHistory.tsx` (`TokenHistory`, `TokenCoin`, `TxRow`, `Skeleton`), `src/level.tsx` (`Level`, `OrbitBadge`, `LevelPill`, `GiftSparkle`), `src/ui.tsx` (`Header`, `Icon`, `Sheet`), `src/screenViews.tsx` and `src/screens.ts` (wiring and the dev states), `src/index.css`.

Both are **pushed screens** (no bottom nav). Token history is opened from Me → "Token history" and from the Get tokens header. Level is opened from Me → "Level" (and from the My items empty state, see `v2_03`).

---

# PART A. Token history

Background `screen` #FBF9FF, text `ink`. Transition: **fade 250 ms only** (no slide). States: **list**, **loading**, **empty (no data)**, **no match (filter)**, **filter sheet open**.

## A1. Anatomy
```
Column
├─ Header("Token history"), right slot = filter button
├─ Balance card (margin h 16, top 4)
└─ Scroll area (no scrollbar, bottom padding 32): skeleton | groups | empty/no-match state
Filter sheet (route above everything)
```

**Header right slot:** a 48×48 button with margin-right −8 (so its right edge is 4 from the screen edge), centred `sliders` icon 24 (path `M4 8h9M17 8h3M4 16h3M11 16h9`, stroke 1.75). When the filter is **active** (type ≠ All or range ≠ "Last 30 days") show a dot: 10×10 circle, bg `badge`, border 2 px `screen` colour, positioned top 10 / right 10 inside the button. Tap opens the filter sheet with the **draft = current filter**. Accessibility label "Filter".

**Balance card:** margin h 16, margin-top 4, height 56, radius 28, 1 px `divider` border, white, padding h 16, shadow `0 4 14 primary@8%`, row space-between centred.
- Left: `TokenCoin(28)` + gap 8 + text **"{balance} tokens"** 16 / w600 (balance = the app's token balance, seed 105, plain number as written: "105 tokens").
- Right: **"1 token = ₹1"** 14 `ink/75`.

## A2. Groups and rows
Rows are filtered (see A4), then split into **Today** (`daysAgo == 0`) and **Earlier** (`daysAgo > 0`). A group with no rows is not shown. Group header: text **"Today"** / **"Earlier"**, padding h 16, top 16, bottom 4, 14 / w600 `ink/75`.

**Row (TxRow):** height 72, padding h 16, gap 12, centred. Layout: lead circle 40 · text column (flex 1) · amount column.
- Lead: 40×40 circle, icon 22 (stroke 1.75) colour `ink`. Tint by kind: checkin `tintTokens` #FFF0DD (calendar-check icon), purchase `tintVip` #EFE6FF (wallet icon), pass `tintInvite` #FFE3EA (ticket icon). Icon paths are inline in `tokenHistory.tsx` (`CalendarCheck`, `Wallet`, `Ticket`, viewBox 24).
- Title 16 / w500 one line ellipsis; below it the `when` text 14 `ink/75` one line ellipsis.
- Amount column (right aligned): row gap 4: **`+5`** or **`−50`** (use the real minus sign U+2212) 16 / w600, colour `success` #087F5B if earned else `ink`, followed by `TokenCoin(18)`; below it **"₹{abs}"** 12 `ink/75`.
- Accessibility label: `"{title}, earned|spent {n} tokens, {when}"`.

**Seed data** (`TX`):
| id | kind | Title | When | Amount | daysAgo |
|---|---|---|---|---|---|
| 1 | checkin | Daily check-in bonus | Today, 10:46 am | +5 | 0 |
| 2 | purchase | Tokens added | 28 Oct, 3:19 pm | +100 | 1 |
| 3 | pass | Match pass | 26 Oct, 9:02 pm | −50 | 3 |
| 4 | checkin | Welcome bonus | 24 Oct, 5:15 pm | +5 | 5 |

Default view therefore: **Today** (row 1) and **Earlier** (rows 2, 3, 4).

## A3. Skeleton (loading)
4 rows, each height 72, padding h 16, gap 12: shimmer circle 40; a column (flex 1, children spaced 8) with a bar h 14 / width 1/2 / radius 4 and a bar h 12 / width 1/3 / radius 4; a bar h 16 / w 48 / radius 4 on the right. The header and the balance card are already visible while loading. Prototype delay 700 ms (min 300 ms in Flutter); load on screen open.

## A4. Filter
- State: `filter = {type: All|Earned|Spent, range: index into RANGES}`, `DEFAULT = {All, 2}`.
- `RANGES = [Today (0 days), Last 7 days (7), Last 30 days (30), All time (no limit)]`.
- A transaction is shown when `(type == All) or (type == Earned) == (amount > 0)` **and** `daysAgo <= maxDays`. With the seed: Today → rows with daysAgo 0 (row 1); Last 7 days → all four (max daysAgo is 5); Last 30 days and All time → all four. Earned → rows 1, 2, 4. Spent → row 3.
- **No-match state** (rows empty because of the filter): see A5.

**Filter sheet** (`showAppSheet`, standard Sheet: scrim `ink@30`, radius 20, padding 16/8/16/32+safe, handle):
1. **"Filter"** 18 / w600.
2. Label **"Type"** (margin top 16, bottom 8) 14 / w500 `ink/75`.
3. Segmented control: row, gap 4, fully rounded, bg `card`, padding 4. Three equal buttons **All / Earned / Spent**, each height 48, fully rounded, 16 / w500. Selected: bg `primary`, text white. Unselected: transparent, text `ink`. Tapping changes the **draft** only. Radio-group semantics.
4. Label **"Date range"** (margin top 20, bottom 8), same style as "Type".
5. A button, height 56, full width, radius 20, 1 px `divider` border, white, padding h 16, 16 / w500: left the current range label ("Last 30 days"), right a `chev` icon 18 rotated 90° (pointing down) colour `ink2`. **Each tap cycles** the draft range to the next value (Today → Last 7 days → Last 30 days → All time → Today). Do not replace this with a picker.
6. **"Show results"** NeoButton (full width, margin-top 24): applies the draft to the filter and closes.
7. **"Reset"** text button (margin-top 4, height 48, full width, 16 / w600 `primary`): sets the **draft** to DEFAULT only (it does not apply or close).
Closing the sheet by the scrim or by back discards the draft.

## A5. Empty states (centered in the scroll area, padding h 32 / v 56)
Column: a circle 64, bg **white**, containing `TokenCoin(40)` (bottom margin 12); title 18 / w600; sub (margin-top 4) 14 `ink/75`; a NeoButton with **width auto, padding h 32**, margin-top 20.
- **No data** (the user has no transactions at all): title **"No token activity yet"**, sub **"Daily check-ins and top-ups will show up here."**, button **"Get tokens"** → push Get Tokens.
- **No match** (filter hides everything): title **"No matching activity"**, sub **"Try a different type or date range."**, button **"Reset filter"** → set the filter back to DEFAULT (no sheet).
The balance card stays visible in both. "No data" must be a real state (repository returns an empty list); with the seed it is not reachable, so test it with a fake repository.

## A6. Numeric checks (width 390)
- Balance card: x 16, width 358, height 56, top = header bottom + 4.
- Each row 72 tall; lead circle 40; amount text for row 3 is "−50" (U+2212) in `ink`; row 1 "+5" in `success`.
- Default: group headers "Today" then "Earlier"; 4 rows total. After choosing Spent + Show results: only "Match pass" under "Earlier", the header icon shows the dot.
- Sheet: the Type segmented control is 4 + 48 + 4 = 56 tall; "Show results" 52 tall; tapping the range button three times from "Last 30 days" goes All time → Today → Last 7 days.
- "Reset" changes the draft but not the list behind the sheet.

---

# PART B. Level

Background `screen`. **Pushed, slide-in** (24 px + fade, 280 ms). `Header("Level")`. The whole body below the header scrolls (no scrollbar), bottom padding 24 + safe-area bottom. Input: `tokensAdded` (the user's total tokens ever added; seed 0 → Lv 0) from a repository; derive everything else.

## B1. Maths
```
THRESH       = [0, 100, 1000, 3000, 10000, 30000, 100000, 300000, 1000000, 3000000, 10000000]
THRESH_LABEL = ['0','100','1,000','3,000','10,000','30,000','1 lakh','3 lakh','10 lakh','30 lakh','1 crore']
BONUS        = [5, 8, 12, 18, 25, 35, 50, 70, 100, 150, 200]
current = last index i with tokensAdded >= THRESH[i]
max     = current >= 10
next    = max ? 10 : current + 1
pct     = max ? 100 : round((tokensAdded - THRESH[current]) / (THRESH[next] - THRESH[current]) * 100)
need    = max ? 0 : THRESH[next] - tokensAdded
```
Numbers in the card use Indian grouping (`fmtIN`: 2,000, 99,900, 1,00,000). Examples: 0 → Lv 0, pct 0, need 100. 2000 → Lv 2, pct 50, need 1,000, "Add 1,000 tokens to reach Lv 3".

## B2. Level card
Margin h 16, margin-top 4, radius 28, padding 20, text centred, white text, clip (overflow hidden). Background: linear gradient **160°** from `primary` #8B5CF6 to the 50/50 mix of `primary` and `ink` ≈ **#6348A5** (use `cssLinear(160, ...)`). Three soft blobs inside, clipped by the card (each a circle blurred with Gaussian sigma 40, `ImageFilter.blur`, painted *under* the content):
- top −32, left −32, 128×128, `profileB` #FFB4A8 @ 40%
- top 40, right −40, 144×144, `onlineCyan` @ 25%
- bottom −40, left 40, 128×128, `profileA` #C4B5FD @ 30%

Content column, centred, on top:
1. `OrbitBadge(level: current)` 112×112.
2. **"Lv {current}"** 20 / w700, margin-top 8.
3. Row (margin-top 16, full width, space-between, centred, 16 / w600): **"Lv {current}"** · a white pill (height 32, padding h 12, gap 6, fully rounded, text 14 / w700 `ink`) with `TokenCoin(18)` + **{fmtIN(tokensAdded)}** · **"Lv {next}"**.
4. Progress bar (margin-top 12): height 8, full width, fully rounded, track white @25%, fill `onlineCyan` of width `pct %`, animate width 300 ms.
5. Text (margin-top 12) 14: **"Add {fmtIN(need)} tokens to reach Lv {next}"**, or **"You've reached the top level"** when max.

## B3. Level tabs
Row (margin-top 12, padding h 8) of 11 tabs `Lv 0` … `Lv 10`, **horizontally scrollable** without a scrollbar. Each tab: height 48, min width 56, padding h 12, column centred, text 16. Selected: **w700 `primary`**, else **w500 `ink/75`**. Under the text (margin-top 2) a 6×6 circle: `primary` when selected, transparent otherwise. Initial selection = `current`; the selected tab is scrolled to the **centre** on change. Tapping a tab selects it. (Keyboard left/right moves the selection: nice for a11y, optional on mobile.)

## B4. Daily bonus row
Margin h 16, margin-top 8, min height 72, row gap 12, centred: a 56 circle `tintTokens` with the `GiftSparkle` icon 30 colour `ink` (paths in `level.tsx`) · column: **"Daily bonus"** 18 / w600 line height 24 · **"+{BONUS[sel]} tokens every day at Lv {sel}"** 16 · **"Reach higher levels for a bigger bonus"** 14 `ink/75`. Updates when the selected tab changes (live region).

## B5. "Level rule" card
Margin h 16, margin-top 16, radius 28, 1 px `divider` border, white, clip, shadow `0 4 14 primary@8%`.
- Header (padding 20 / 20 / 12, centred): **"Level rule"** 18 / w600; below (margin-top 4) **"Your level follows the total tokens you've added."** 14 `ink/75`.
- Column header row, height 40, text 14 / w600 `ink/75`: **"Level"** left (padding-left 20), **"Tokens added"** right (padding-right 20).
- 11 body rows, **height 56 each**, background alternating starting with `primary10` on index 0 (`i % 2 == 0` → #F5F0FF, else white). Left (padding-left 20): `LevelPill(i)` and, only on the **current** level row, a "You are here" chip (gap 8): 1 px `ink` border, fully rounded, padding h 8 / v 2, text 12 / w600 `ink`. Right (padding-right 20): `THRESH_LABEL[i]` 16 / w500.
- `LevelPill`: height 24, padding h 12, fully rounded, 12 / w700. Tier colours: Lv 0 → bg `lvGray`, text `ink`; Lv 1–2 → `onlineCyan`, `ink`; Lv 3–5 → `primary`, **white** text; Lv 6–8 → `badge` #FF4D8D, `ink`; Lv 9–10 → 135° vip gradient, `ink`.

## B6. OrbitBadge (use the one in `v2_shared_widgets.dart`)
Hexagon `M56 6l42 24v52L56 106 14 82V30z` filled by tier (gray `lvGray`, mint `onlineCyan`, violet `primary`, pink `badge`, sunset = vip gradient), 3 px white stroke, round join. Inside: two white arcs (opacity .9, stroke 2.5, round caps) — circle r 26, one dash 110 long starting at −30°; circle r 17, one dash 60 long starting at 150° — and a white dot r 6 at the centre. **Every tier except gray has a glow** (`drop-shadow(0 0 14px coin@60%)`, which is a Gaussian sigma 7 under the hexagon). Do not draw the dashes with a dash-array package: draw two arcs (`sweep = dash / radius`).

## B7. Preview-only state
The prototype has a "scrolled to rules" frame (`scrollToTable`) used only by the dev inspector. Do not build a button for it. Optionally accept `scrollToTable` in the constructor for tests: it scrolls so the Level rule card's top is 8 below the top of the scroll area.

## B8. Numeric checks (width 390)
- Level card: x 16, width 358; the badge is 112×112 and horizontally centred; progress bar height 8.
- Lv 0 seed: texts "Lv 0" (twice), "Lv 1", pill "0", "Add 100 tokens to reach Lv 1", bonus line "+5 tokens every day at Lv 0".
- With `tokensAdded = 2000`: "Lv 2", pill "2,000", "Lv 3", bar fill 50% of the track, "Add 1,000 tokens to reach Lv 3", the selected tab is "Lv 2", the "You are here" chip is on row 2, bonus line "+12 tokens every day at Lv 2".
- With `tokensAdded = 10000000`: "You've reached the top level", fill 100%, "Lv 10" twice.
- Rule table: 11 rows × 56; row 0 background #F5F0FF, row 1 white; labels in order `0, 100, 1,000, 3,000, 10,000, 30,000, 1 lakh, 3 lakh, 10 lakh, 30 lakh, 1 crore`.
- Tapping tab "Lv 5" changes the bonus line to "+35 tokens every day at Lv 5" and does not change the card or the table.

## Do not
- Do not add a "claim" or "upgrade" button; there is none.
- Do not use Material `TabBar`, `DataTable` or `LinearProgressIndicator`.
