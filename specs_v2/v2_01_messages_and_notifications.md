# Build Messages (all states and sheets) and Notifications in Flutter

Read `v2_00_read_me_first.md` first (rules, Tailwind conversion, shared widgets). Reference Dart: `v2_shared_widgets.dart`.

**Source to read completely:** `src/inbox.tsx` (`Messages`, `Notifications`, `ActionSheet`, `Backdrop`, `Skeleton`, `SysRow`, `Disc`, `Count`), `src/ui.tsx` (`Header`, `Icon`, `Logo`, `Portrait`, `OfflineBanner`, `EmptyState`, `BottomNav`), `src/store.tsx` (`SEED`, `block`, `markAllRead`, `clearConvos`), `src/screenViews.tsx` (how Messages is wired), `src/index.css` (`--nav-h`, `fade-in`, `slide-up`, `shimmer`).

This **replaces** the Messages part of `live_and_messages_flutter_spec.md`. Messages is the third tab ("Messages"); Notifications is a pushed screen.

States to build (all real, reachable normally): **list**, **loading** (skeleton), **empty**, **offline banner**, **More sheet**, **Clear confirm dialog**, **Row menu sheet**, snackbar. Notifications: **list**, **empty**.

---

## 1. Messages screen

Background white, text `ink`. Column: header, optional offline banner, scrolling list, bottom nav (light variant, Messages active). Sheets/dialog/snackbar are overlays above everything including the nav.

### 1.1 Header (not the shared `Header`)
- Height 64 + safe-area top, children bottom-aligned, padding left 16, right 8, bottom 4, space-between.
- Left: "Messages" 28 / w700, line height 32, `ink`.
- Right: three round buttons 48×48, icon colour `ink`, in this order: **call history** (`history` icon 24) → pushes the History screen; **help** (headset icon, 24) → snackbar "Coming soon"; **more** (`dots` icon 24) → opens the More sheet. Accessibility labels: "Call history", "Help", "More".
- Headset icon (viewBox 24, stroke 1.75, round): `M4 14v-2a8 8 0 0116 0v2`, rect x3 y14 w4 h6 rx2, rect x17 y14 w4 h6 rx2, `M19 20c0 1.5-2 2-5 2`.

### 1.2 Offline banner
Shown only when the app is offline: `OfflineBanner` with text **"You're offline. Showing saved conversations."** Margin h 16, bottom 8, radius 8, bg `coinBg`, padding h 12 / v 8, row gap 8, text 12 `ink`; wifi-off icon 16 stroke `#D9890B` width 2 (`M2 9a15 15 0 0120 0M5 13a10 10 0 0114 0M9 17a5 5 0 016 0M3 3l18 18`); the text is flex 1; no retry button here.

### 1.3 List
Scrollable, no scrollbar, bottom padding = nav height (56 + safe-area bottom). Content order:

1. **System rows** (always shown, also while loading):
2. a divider: margin h 16, margin v 4, height 1, `divider`
3. **Conversation rows**, or the skeleton, or the empty state.

**System row** (`SysRow`): the whole row is a button, height 72, padding h 16, gap 12, items centred, left aligned. Layout: lead disc 56 · text column (flex 1, min-width 0) · optional date.
- Title 16 / w500, one line ellipsis. Preview 14 / w400 colour `ink/75`, one line ellipsis.
- Date (only if present): 12 `ink/75`, aligned to the **top** of the row with padding-top 14.
- Disc: 56×56 circle, content centred.

| Row | Disc | Title | Preview | Date | Tap |
|---|---|---|---|---|---|
| 1 | bg `coinBg`, `eye` icon 26, colour `ink` | Profile visitors | See who looked at your profile | none | push Visitors |
| 2 | bg `primary10`, `bell` icon 26, colour `primary` | Notifications | Welcome to YourApp! Say hi in a live room. | 24 Oct | push Notifications |
| 3 | bg `tintInvite` (#FFE3EA), the app **Logo** at size 34 | YourApp Help | Questions or something wrong? Ask here | none | snackbar "Coming soon" |

**Logo(size)** (`ui.tsx`): square `size`×`size`, corner radius 24 (so at 34 it is a circle), gradient 135° `#8B5CF6 → #FF6B6B`, shadow `0 8 24 rgba(139,92,246,.30)`; inside, centred: a box 62% × 66% of `size`, radius 22 (clamped to a pill), white @25%; a small square 16×16 rotated 45°, radius 4, white @25%, positioned left 8, bottom −6 inside that box; and the `flame` icon, white, size = `size × 0.31`, on top.

**Conversation row** (one per conversation, sorted by `ts` descending, archived ones hidden): button, height 72, padding h 16, gap 12, items centred, no text selection.

Layout: avatar block 56×56 · middle column (flex 1) · right column.

- **Avatar block:** 56×56 circle. `live` = user.avail == online. If live: padding 3 and a **2 px `primary` ring drawn outside** the 56 box (box-shadow spread 2, no layout change), the portrait inside is 50×50. If not live: portrait fills 56×56. Portrait = `Portrait(seed: user.id % 10)` clipped to a circle. **LIVE tag** (only if live): positioned right −4, bottom −4 (it overflows the avatar, so do not clip), pill with 2 px white border, bg `primary`, padding h 6, text "LIVE" 10 / w700 white, line height 16.
- **Middle column:** first row = name (16, **w600 if unread else w500**, one line, ellipsis) then, if muted, a `BellOff` icon (14, stroke 2, colour `ink/75`) with gap 6. Second line = preview, 14, one line ellipsis: if the conversation has no messages: "No messages yet"; else the last message text, prefixed with **"You: "** when its sender is me. Colour/weight: **unread → w500 `ink`**, else w400 `ink/75`.
  - BellOff path (viewBox 24, stroke 2, round): `M6 16V11a6 6 0 0110-4.5M18 11v5l2 2H4M10 21h4M3 3l18 18`.
- **Right column:** column, items right-aligned, gap 6, vertically centred in the row (so it occupies 16 + 6 + 20 = 42 dp, top at 15). Top: the date text (12, `ink/75`) only if `date` is not empty. Below: if unread, the **Count** badge, else an empty 20-tall spacer. **Count**: height 20, min width 20, fully round, bg `primary`, padding h 4, number 12 / w600 white, line height 1.
- **Tap** opens that conversation (push Conversation). **Long-press 500 ms** (or secondary click / the ContextMenu key) opens the Row menu for that conversation, and the tap that follows a fired long-press must NOT also open the chat. Accessibility label: `"{name}{, live now}{, {n} unread}. Long press for more options"`.

**Loading (skeleton):** while loading, instead of the conversation rows show 6 rows, each height 72, padding h 16, gap 12: a shimmer circle 56; a column (flex 1, children spaced 8) with a shimmer bar height 14, width 1/3, radius 4 and a bar height 12, width 2/3, radius 4. Not tappable.

**Empty state** (no conversations, or all archived): centred column, padding h 32 / v 40: circle 64 bg `card` with the `chat` icon 28 in `primary` (bottom margin 12); "No messages yet" 18 / w600; below it (margin-top 4) "Say hi in a live room to start one." 14 `ink/75`; below (margin-top 20) a **NeoButton** "Find a room" (52 tall, radius 20, 2 px `ink` border, `bg-vip` gradient, text 16 / w600 `ink`, padding h 32, hard shadow 3,3 `ink`; pressed: translate 3,3 and no shadow). "Find a room" switches to the **Live** tab (the tab switch clears pushed screens).

### 1.4 More sheet (ActionSheet)
Opens from the "more" icon. `showAppSheet(action: true)`: scrim `ink@50`, white, top radius 28, padding top 8 / bottom 8 + safe-area, handle 40×4 `divider` centred, 8 below, **no horizontal padding on the panel**.
- Title row: "Messages options" 14 `ink/75`, padding h 24, bottom 4.
- Rows (full width, height 56, padding h 24, text 16 / w500, left aligned):
  1. **Mark all as read** → set every conversation's unread to 0, close the sheet, snackbar **"All messages marked as read"**. The Messages tab badge disappears.
  2. **Clear message list** (text `danger` #D92D2D) → closes nothing yet, replaces the sheet with the confirm dialog (see 1.5).
- Divider: margin h 24, height 1, `divider`.
- **Cancel** row: centred, 16 / **w700** `primary` → close.

### 1.5 Clear confirm dialog
`showAppDialog`: scrim `ink@50`, card width = screen − 48, radius 28, padding 24, white.
- Title **"Clear your message list?"** 20 / w700, line height 28.
- Body (margin-top 8): **"This removes all conversations from your list. This can't be undone."** 16, `ink/75`.
- Buttons column (margin-top 24, gap 8):
  - **"Clear list"**: red NeoButton: 52 tall, radius 20, 2 px `ink` border, bg `danger`, text 16 / w600 white, hard shadow 3,3 `ink` (pressed: translate, no shadow). Tap → delete all conversations, close, snackbar **"Message list cleared"**. The list then shows the empty state and the tab badge disappears.
  - **"Cancel"**: height 48, radius 20, text 16 / w600 `primary`, no background; **autofocus**. Tap → close.
- Scrim tap closes.

### 1.6 Row menu (ActionSheet)
Opens on long-press. Same sheet style as 1.4. Title row = the **user's name** (14 `ink/75`). Rows (56 tall):
1. **Mute** / **Unmute** (label depends on current state) → toggle the muted flag (local to this screen), close, snackbar **"Muted {name}"** / **"Unmuted {name}"**. A muted conversation shows the BellOff icon after its name.
2. **Archive** → hide the conversation from this list (local), close, snackbar **"Conversation archived"**.
3. **Report** → close, snackbar **"Report sent. Thank you for helping keep YourApp safe"** (no further flow here).
4. **Block** (text `danger`) → block the user (removes the conversation from the store; the user must also disappear from Explore and Visitors), close, snackbar **"Blocked {name}"**.
- Divider and centred **Cancel** (w700 `primary`) as in 1.4.

### 1.7 Snackbar
Use `AppSnack.show(bottom: 56 + safeBottom + 12)`. Messages used on this screen: "Coming soon", "All messages marked as read", "Message list cleared", "Muted {name}", "Unmuted {name}", "Conversation archived", "Report sent. Thank you for helping keep YourApp safe", "Blocked {name}". Hide on dispose.

### 1.8 Behaviour
- **Loading:** on the first build, skeleton until the repository returns (prototype 600 ms, min 300 ms in Flutter). Later visits to the tab do not re-show the skeleton (tab is kept alive).
- **Tab badge:** the Messages icon in the bottom nav shows the **sum of unread** over conversations (hidden at 0). It must update live after Mark all read / Clear / opening a chat (opening a chat marks it read).
- `muted` and `archived` are screen-local state (kept while the tab lives; lost on app restart). Do not persist them.
- Back (system) on this tab goes to Live (see the back-navigation spec). Sheets and the dialog are routes, so back closes only them.

### 1.9 Seed data (`SEED` in `store.tsx`, sorted by ts desc)
| id | Name | Avail | Last message (from them) | Unread | date | ts |
|---|---|---|---|---|---|---|
| 10 | Tara | online (LIVE) | That story circle was so fun 😄 | 1 | 10:24 | 6 |
| 12 | Kabir | away | Playlist link sent! | 1 | 09:12 | 5 |
| 13 | Isha | online (LIVE) | Mock interview tomorrow at 6? | 1 | Yesterday | 4 |
| 15 | Anaya | away | Thanks for saying hi | 0 | 24 Oct | 3 |
| 16 | Dev | unavailable | Game night is on Friday | 0 | 22 Oct | 2 |
| 17 | Aarav | online (LIVE) | Sent you the notes | 0 | 20 Oct | 1 |

Portrait seed = `id % 10` (Tara 0, Kabir 2, Isha 3, Anaya 5, Dev 6, Aarav 7). Total unread = 3. Tara's thread has two earlier messages (see the Conversation spec). Keep these behind a repository interface.

---

## 2. Notifications screen (pushed, fade-in only)

White background, `Header("Notifications")` (shared header). Body scrolls, bottom padding 24.

**Row:** min height 72, padding h 16 / v 8, gap 12, items centred: disc 56 (bg `primary10`, icon 26 `primary`) · column (flex 1): title 16 / w500, body 14 `ink/75` (wraps, **not** truncated) · date 12 `ink/75` aligned to top with padding-top 12. Rows are not tappable.

| Title | Body | Date | Icon |
|---|---|---|---|
| Welcome to YourApp! | Say hi in a live room to start your first chat. | 24 Oct | bell |
| Daily check-in is ready | Claim your match ticket in Bonus. | 24 Oct | calendar |
| Tara viewed your profile | Say hi back from Profile visitors. | 23 Oct | eye |
| Safety tip | Never share personal details in a chat. | 21 Oct | shield |

(The preview on the Messages row says "Welcome to YourApp! Say hi in a live room." which differs slightly from the first notification body. Keep both strings as written.)

**Empty state** (when there are no notifications): shared `EmptyState`: title "No notifications yet", body "New updates will show up here.", `bell` icon 28.

---

## 3. Numeric checks (write these as widget tests; width 390)

- Messages header height = 64 + top inset; the three icon buttons are 48×48.
- Every system row and conversation row: height 72; the avatar is 56×56; the left edge of the avatar is x = 16; the text column starts at x = 84.
- Live row (Tara): the portrait is 50×50 inside the 56 box; the LIVE tag's right edge is 4 beyond the avatar's right edge.
- Row order: Tara, Kabir, Isha, Anaya, Dev, Aarav. Unread badges on the first three show "1". Nav badge shows 3. After "Mark all as read" the badge is gone and the previews are no longer w500.
- Skeleton: exactly 6 rows of height 72 after the divider.
- More sheet: rows 56 tall; Cancel text is w700 `primary`; the title text "Messages options".
- Dialog width = 390 − 48; title text exactly "Clear your message list?"; "Clear list" is 52 tall with a 2 px `ink` border.
- Long-press on Kabir opens a sheet titled "Kabir" with rows Mute, Archive, Report, Block; tapping Mute then long-pressing again shows "Unmute".
- Notifications: 4 rows; empty state when the list is empty.
- System back: with the dialog open → closes the dialog only; then back → Live tab.

## 4. Do not
- Do not build the "Messages – More sheet / Clear confirm / Row menu / Empty" as separate screens: they are states of this one screen.
- Do not use `ListTile`, `Dismissible` or swipe actions (none in the prototype).
- Do not show a search field or filter chips (none in the prototype).
