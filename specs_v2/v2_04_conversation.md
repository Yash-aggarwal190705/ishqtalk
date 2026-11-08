# Build the Conversation (chat) screen and the safety flow in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`t`, `K`, `showAppSheet`, `showAppDialog`, `AppSnack`).

**Source to read completely:** `src/conversation.tsx` (`Conversation`, `Bubble`, `ToolBtn`, icons), `src/safety.tsx` (`SafetyFlow`), `src/store.tsx` (`Msg`, `Convo`, `send`, `deliver`, `retry`, `markRead`, `block`, `SEED`), `src/ui.tsx` (`AvailLabel`, `Portrait`, `OfflineBanner`, `Icon`, `Sheet`, `Dialog`), `src/screenViews.tsx` (how Conversation and `onBlocked` are wired).

A **pushed** screen (no bottom nav), slide-in 24 px + fade 280 ms. Opened from: a Messages row, the "Message" button on User Profile. White background, text `ink`. Back returns to the opener.

## 1. Anatomy
```
Column (white)
├─ Top bar (safe-area top + 64)
├─ Message list (flex 1, scrolls)
└─ Bottom area (white): [offline banner] + ( unavailable note | token notice + composer + tool row )
Snackbar (overlay)   Safety flow (sheet/dialog routes)
```

## 2. Top bar
Safe-area top padding, then a row of height 64, padding h 4, with: back button 48×48 (`back` icon 24, stroke 1.75) on the left, the **menu** button 48×48 (`dots` icon 24, label "Conversation menu") on the right, and the **title block** centered between them (absolute: left 56, right 56, vertically centred, not tappable):
- **Name** 18 / w600, line height 24, one line ellipsis, centred.
- Below it the **availability label** (`AvailLabel`): row, gap 4, centred, 12 `ink/75`: an 8×8 circle then text. online → `onlineGreen` + **"Online now"**; away → `coin` + **"Away"**; unavailable → `lvGray` + **"Unavailable"**.

## 3. Message list
Scroll area, no scrollbar, padding h 16 / v 12, children **spaced 20** vertically, then an invisible end marker (it adds a final 20 gap). The list **auto-scrolls to the bottom** when a message is added and when any message's state changes.

**Empty conversation** (no messages): centred in the area, text centred: **"No messages yet"** 16 / w500; below (margin-top 4) **"Say hello to {name}."** 14 `ink/75`; below (margin-top 12) a text button **"Explore more people"** (height 48, padding h 16, 14 / w600 `primary`) → switch to the **Explore** tab.

**Otherwise:** first a centred timestamp = the `t` of the first message (14 `ink/75`, e.g. "10:20"), then one bubble per message in order.

**Message from them:** row, gap 12, top aligned: `Portrait(seed: user.id % 10)` 40×40 circle · a container with **max width 72% of the row**:
- text message: bubble radius 16, padding h 16 / v 12, text 16 with line height 24, bg `card`, text `ink`, words may break;
- photo message (`photo` is not null): **no bubble**, `Portrait(seed: photo)` **104×188**, radius 16.

**Message from me:** column, right aligned: a container with **max width 78%**:
- bubble as above but bg `primary`, text white. State `pending` → whole bubble opacity .6. State `failed` → a 1 px `badge` ring around the bubble.
- Under it (margin-top 4) a row, gap 6, 12 `ink/75`: the time `t`, then by state: `pending` → **"· Sending…"**; `sent` → **"· Saved locally"**; `failed` → **"· Not sent"** (colour `ink`) followed by a **"Retry"** text button (height 32, padding h 4, w600 `primary`) that retries delivery.

## 4. Bottom area
White. Contents top to bottom:
1. **Offline banner** if the app is offline: text **"You're offline. Messages won't send until you're back."** (same banner as Messages).
2. If the other user is **unavailable**: only a centred note, padding h 16, top 12, bottom 16 + safe-area, 14 `ink/75`: **"{name} is unavailable right now. You can still read past messages."** (no composer, no tool row).
3. Otherwise:
   - **Token notice:** min height 40, bg `tintInvite` #FFE3EA, padding h 16, row gap 12, text 14 `ink`: a thermometer-style icon 18 (stroke 2, round, colour `badge`, path `M10 14.5V5a2 2 0 014 0v9.5a4 4 0 11-4 0zM12 9v7`) + **"Use 5 tokens (₹5) to send a message."**
   - **Composer** (padding h 16, top 12): row, gap 12, items bottom-aligned:
     - text field: min height 48, **max height 112**, grows with its content, radius 20, bg `card`, padding h 16 / v 12, text 16, placeholder **"Type something sweet…"** in `ink/60`, no border, no underline; on focus a 2 px `primary` ring; max length **500** (extra characters are ignored); the keyboard's action key = **send** (Enter sends; no newline).
     - **Send button:** 96×48, fully rounded, bg `cta` #FF6B6B, `send` icon 24 in `ink` (path `M21 3L3 10l7 3 3 7zM10 13l11-10`); **disabled (opacity .4) when the trimmed text is empty**; pressed: scale .95.
     - When the text length is **above 400**, show under the row (margin-top 4), right aligned, 12 `ink/75`: **"{len}/500"**.
   - **Tool row:** padding h 8, top 8, bottom 8 + safe-area, space-between, four 48×48 round buttons with 28 icons:
     1. **Emoji** (smile icon, colour `ink/60`) → append "😊" to the text (respecting the 500 limit)
     2. **Send photo** (picture icon, `ink/60`) → snackbar "Coming soon"
     3. **Video call** (filled camera-with-heart icon, colour `primary`) → open the **Calling Sheet** for this user (the same sheet used elsewhere); if calling is not available, snackbar "Coming soon"
     4. **Send gift** (gift icon, colour `cta`) → snackbar "Coming soon"
   - The icon SVGs (Smile, Picture, VideoCam, Gift) are inline at the top of `conversation.tsx`: copy the paths. VideoCam is filled (`currentColor`) with a white heart.

**Snackbar:** `AppSnack.show(bottom: 160)` (it floats above the composer), message **"Coming soon"**, 2.2 s; hide on dispose.

## 5. Sending and delivery (store logic; keep it behind a repository)
- **Send** (Enter / Send button): trim the text; ignore if empty. Append a message `{from: me, text, state: pending, t: now}` where `t` is the current time formatted like `10:24` (24 h or locale short time; the prototype uses `toLocaleTimeString` with 2-digit hour and minute: use the device locale's short time). Set the conversation's `ts` to now and its `date` to **"Today"** (so the Messages row moves to the top and shows "Today"). Clear the field. Increment a sent counter.
- **Delivery:** if the app is **offline** → the message goes to `failed` at once. Else it stays `pending` and after **700 ms** (2500 ms when the network is slow) becomes `sent`. There is no real backend: this is a simulated delivery and **no tokens are charged** in the prototype (the notice is informational). Keep a TODO where the 5-token charge and the real API go.
- **Retry:** runs the same delivery again for that message.
- **markRead:** opening the conversation sets its unread to 0 (and again whenever the message count changes while it is open). The Messages badge updates.
- The unavailable user: composer is hidden (section 4.2).

## 6. Seed conversations (for the first-run experience)
Tara (id 10, avail online) has **three** messages, all from them, all `sent`: (1) **"welcome to my profile, call me for talking"** t 10:20; (2) a **photo** message (`photo: 3`, empty text) t 10:21; (3) **"That story circle was so fun 😄"** t 10:24. So the list shows the timestamp "10:20", the text bubble, the 104×188 portrait, then the third bubble. Other conversations have a single message from them (see the Messages spec table). Conversation with a user the person has not chatted with yet is created empty by `ensureConvo` when "Message" is tapped on a profile.

## 7. Safety flow (the ⋯ menu here and on User Profile)
`SafetyFlow(user, withDetails)`; on this screen `withDetails = true` and `onBlocked` = go back (pop this conversation). Everything is a route: sheet, report step, ack step, block dialog; back closes one layer.

1. **Menu** (standard `Sheet`): rows (min height 48, padding v 8, gap 12, icon 22, label 14 / w500 over an optional 12 `ink2` sub-line):
   - **Report** (shield icon) sub **"Tell us what's wrong. It stays private."** → step 2
   - **Block** (circle-with-slash icon, colour `badge`, label colour `badge`) → step 4
   - **Conversation details** (doc icon) sub **"Staged · coming later"** — **disabled** (opacity .5) — only when `withDetails` (this screen)
   - then a **"Close"** text button (margin-top 8, height 44, 14, colour `ink2`).
2. **Report reasons:** title **"Report {name}"** 16 / w600; sub (margin 4 / 8) **"Choose what fits best. They won't be told who reported them."** 12 `ink2`; five rows (min height 48, bottom border 1 px `divider`, 14, `chev` icon 18 colour `lvGray` on the right): **Spam or scam · Inappropriate content · Harassment or bullying · Looks underage · Something else**. Tapping any row → step 3 (in the real app this is where the report API is called).
3. **Acknowledged:** centred: 48 circle (`onlineGreen` @15%) with a green check 24 (viewBox 16, path `M3 8.5l3.2 3L13 4.5`, stroke 2, round); **"Thanks. Your report was recorded in this local preview."** (margin-top 12) 14 / w500; **"Done"** (margin-top 20, height 48, full width, radius 8, bg `primary`, 14 / w600 white) → close.
4. **Block dialog** (`Dialog`: scrim `ink@30`, margin h 24, radius 16, padding 20, white): title **"Block {name}?"** 16 / w600; body **"They will be hidden from Explore and your messages. This can't be undone in the local preview."** 14 `ink2`; buttons row (margin-top 20, gap 12, equal width, height 44, radius 8, 14 / w600): **Cancel** (1 px `divider` border, text `ink`) and **Block** (bg `badge`, white). Block → block the user in the store (removes the conversation, hides the user from Explore and Visitors), close the flow, then call `onBlocked` (here: pop the Conversation; from User Profile: pop the profile).
This **replaces the safety texts in the earlier profile spec** (section B4): use the strings above.

## 8. Numeric checks (width 390)
- Top bar content height 64; the title block is centred between x = 56 and x = 334; back and menu buttons are 48×48.
- Tara thread: timestamp "10:20" is centred; her avatars are 40×40 at x = 16; the photo is exactly 104×188; text bubbles never exceed 72% of the row (them) / 78% (me).
- Sending "hi": a primary bubble appears at the right with "· Sending…" then after 700 ms "· Saved locally"; the Messages tab then lists this conversation first with date "Today".
- Offline: the same message shows "· Not sent" with a "Retry" button; Retry while still offline keeps it failed; once online it goes pending → sent.
- Send button is disabled (opacity .4) for empty / whitespace text. Text over 400 characters shows "401/500" etc.; typing past 500 is ignored.
- Dev (unavailable user, e.g. Dev, id 16): no composer, no tool row, the note is visible.
- ⋯ menu: Report, Block, "Conversation details" (disabled), Close. Block → confirm → the screen pops back to Messages and Dev/Tara is no longer listed.
- System back with the menu open closes only the menu.

## 9. Do not
- Do not add typing indicators, read receipts, attachments, voice notes or a gift picker (the tool buttons are stubs).
- Do not charge tokens or call a real messaging API.
