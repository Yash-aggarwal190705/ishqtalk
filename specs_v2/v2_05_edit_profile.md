# Build the Edit profile screen (photos, verification, rows, Name / Gender / Interests sheets) in Flutter

Read `v2_00_read_me_first.md` first. Reference Dart: `v2_shared_widgets.dart` (`NeoButton` incl. its disabled look, `showAppSheet`, `AppSnack`, `DashedRRectPainter`).

**Source to read completely:** `src/editProfile.tsx` (everything), `src/ui.tsx` (`FrogAvatar`, `Header`, `Icon`, `Sheet`), `src/screenViews.tsx` (`EditProfileView`), `src/store.tsx` (`saveProfile`, `profile`), `src/index.css`.

This is now a full **pushed screen** (fade 250 ms only, no slide), opened from the **edit icon** at the top of My Profile (Me tab). It **replaces the old "Edit profile sheet"** (profile spec A5). Background `screen`, text `ink`. States: default, 2+ photos, verified, Name sheet, Gender sheet, Interests sheet, snackbar. (The old name sheet used `NameField` from onboarding; this screen has its own validation, section 8.)

## 1. Anatomy
```
Column
├─ Header("Edit profile")                    (shared header, no right slot)
└─ Scroll area (no scrollbar), padding h 16, bottom 32
   ├─ Avatar block (top padding 16)
   ├─ "Photos" section
   ├─ "Get verified" card (margin-top 24)
   └─ Rows column (margin-top 24, gap 8): Name · Birthday(+caption) · User ID · Gender · Interests
Sheets (routes) · Snackbar (bottom 24 + safe-area)
```

## 2. Avatar block
Column centred. A 96×96 `FrogAvatar` (circle, **border-box**: the 3 px ring is inside the 96, so the artwork is 90×90). Ring colour white @85%, background gradient 160° `#C4B5FD → #FFB4A8`. Artwork (viewBox 80, scaled to fill): body ellipse (40,48) rx 26 ry 22 `#F7B43A`; two eye bumps circles (26,28) and (54,28) r 10 `#F7B43A`; eye whites r 6 `#fff`; pupils (27,29) and (53,29) r 3 `#222`; mouth path `M27 52c8 7 18 7 26 0` stroke `#A5521C` width 3 round no fill; cheeks (20,46) and (60,46) r 4 `#F58A4A` @70%. The same avatar is used on My Profile (reuse it).
**Edit button:** a 48×48 touch area positioned **right −14, bottom −14** of the avatar (it overhangs; do not clip). Inside it a 32×32 circle: white, 2 px `ink` border, `edit` icon 16 in `ink` (path `M5 4h8M4 6v13a1 1 0 001 1h13a1 1 0 001-1v-7M18 3l3 3-9 9-4 1 1-4z`). Tap → snackbar **"Coming soon"**. Label "Change avatar".
Below the avatar (margin-top 12): **"Tap to change"** 14 `ink/75`. (Only the small button is tappable in the prototype; the text is static.)

## 3. Photos
- **"Photos"** margin-top 24, 20 / w700, line height 26.
- **"Add up to 6. Clear, recent photos build trust."** margin-top 4, 14 `ink/75`.
- A horizontal scroller (margin-top 12, gap 12, bleeds to the screen edges: margin h −16 and padding h 16, bottom padding 4, no scrollbar). Children, in order: one **PhotoTile** per photo, then the **Add photo** tile **only while photos < 6**.
- **PhotoTile:** 104×140, radius 20, clipped, background by index: `i % 3` → 0 `tintVip` #EFE6FF, 1 `tintInvite` #FFE3EA, 2 `tintTokens` #FFF0DD. Artwork (viewBox 104×140): circle (52,56) r 20 `primary` @40%; path `M14 140c0-30 17-44 38-44s38 14 38 44z` `primary` @40%; circle (86,24) r 8 `coin`. **Remove button** in the top-right corner: 48×48 touch area, inside a 28 circle (white, 2 px `ink` border) with a `plus` icon 14 (stroke 2.5) **rotated 45°** (an ×). Tap → remove one photo (photos − 1) and snackbar **"Saved"**. Label "Remove photo {n}".
- **Add photo tile:** 104×140, radius 20, **1.5 px dashed border `#CFC8E6`**, white fill, column centred, gap 4: `plus` icon 28 `primary` + **"Add photo"** 14 / w500 `primary`. Draw the dashed border with `DashedRRectPainter` (dash ≈ 4.5, gap ≈ 3: the browser's dash length for a 1.5 px border; keep it close). Tap → photos + 1 and snackbar **"Saved"** (no real picker yet; keep a TODO and an `onAddPhoto` callback).
- Seed: **0 photos** (only the Add tile). The photo count is local state now; later it comes from the API.

## 4. Get verified card
Margin-top 24, height 64, full width, radius 28, 1 px `divider` border, white, padding h 16, shadow `0 4 14 primary@8%`, row gap 12, centred. Children:
1. circle 40, bg `onlineCyan`, `shield` icon 22 `ink` (path `M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6zM8.5 12l2.5 2.5 4.5-5`).
2. column (flex 1): **"Get verified"** 16 / w500; below **"Verified profiles earn more trust"** 12 `ink/75`, **one line, ellipsis** (it truncates at narrow widths: that is correct).
3. status chip: fully rounded, padding h 10 / v 4, 12 / w600 `ink`, row gap 4. Not verified: bg `card`, text **"Not verified"**. Verified: bg `onlineCyan`, a check icon 12 (viewBox 24, path `M5 12.5l4.5 4.5L19 7.5`, stroke 2.5, round) + **"Verified"**.
4. `chev` icon 18 `ink2`.
Tap → if not verified: set verified = true and snackbar **"Saved"** (no real verification yet: TODO). Tapping when already verified does nothing.

## 5. Rows (margin-top 24, column, gap 8)
**Row:** height 64, full width, radius 28, 1 px `divider` border, white, padding h 20, shadow `0 4 14 primary@8%`, row space-between, gap 12. Left label 16 / w500 `ink`. Right group (min width 0, gap 8): the value 16 `ink/75` one line ellipsis, then a trailing widget (default `chev` icon 18 `ink2`). Tappable rows have a pressed/focus state; non-tappable ones are plain.
| Row | Value | Tap | Trailing |
|---|---|---|---|
| **Name** | the saved name (seed **"Meera Sharma"**; if the app already has a saved profile name of 2+ characters use that) | open Name sheet (draft = current name) | chev |
| **Birthday** | **12 Mar 2004** | snackbar "Coming soon" | chev |
| **User ID** | **48213907** | not tappable | a **copy button** instead of the chev: 48×48 touch area with margin-right −12, `copy` icon 22 `primary` (paths: rect x8.5 y8.5 w11 h12 rx2.5; `M15.5 5.5v-.5A2 2 0 0013.5 3h-7A2 2 0 004.5 5v10a2 2 0 002 2H7`). Tap → copy "48213907" to the clipboard and snackbar **"User ID copied"** |
| **Gender** | the selected gender (seed **Woman**) | open Gender sheet | chev |
| **Interests** | see below (seed Music, Tech, Travel → **"Music, Tech +1"**) | open Interests sheet (draft = current) | chev |
Under **Birthday** (inside the same wrapper, so it is not separated by the 8 gap): the caption **"Used to confirm you're 18 or older."** margin-top 6, padding h 8, 12 `ink/75`.
**Interests value:** 0 selected → "Add interests"; 1–2 → names joined with ", "; 3 or more → first two joined with ", " then " +{n−2}" (e.g. "Music, Tech +1").

## 6. Name sheet (`showAppSheet`, standard Sheet)
1. **"Name"** 18 / w600.
2. Label **"Display name"** (margin-top 12) 14 / w500.
3. Input box (margin-top 6): height 52, radius 20, **2 px border**, white, padding h 16, row. Border colour: `divider` while the trimmed text is empty or valid (becomes `primary` while focused), **`ink`** when the trimmed text is invalid. Text 16, **autofocus**, max length **30**. At the end of the box (only when the trimmed text is non-empty): valid → check icon 16 in `ink` (stroke 2.5); invalid → warning icon 16 in `badge` (circle r 9.5 + `M12 7.5v5.5M12 16.5v.01`, stroke 2.25, round).
4. Message line (margin-top 6, min height 20, row gap 6, 12 `ink`): empty text → nothing; valid → check 14 + **"Looks good"**; invalid → warning 14 + **"Use 2 to 24 characters, letters and numbers only"**.
5. Helper (margin-top 16, bottom 8, centred, 12 `ink/75`): **"Ready to save"** when changed and valid, else **"Change your name to save"**.
6. **"Save changes"** NeoButton, full width, **disabled unless (trimmed != saved name) and valid**. **Disabled look: the orange gradient stays, border becomes `divider`, text `ink/60`, no shadow** (see foundation). On tap: save the trimmed name (profile store; My Profile shows it), close, snackbar **"Saved"**.
- **Valid** = trimmed text matches `^[A-Za-z0-9 ]{2,24}$`. The sheet must rise above the keyboard (add the keyboard inset).
- Opening the sheet resets the draft to the current name. Closing without saving discards the draft.

## 7. Gender sheet
**"Gender"** 18 / w600 (margin-bottom 4), then four radio rows, each height 56, full width, bottom border 1 px `divider` (also on the last), 16 text, space-between: **Woman, Man, Non-binary, Prefer not to say**. Right: radio circle 24, 2 px border (`primary` if selected else `lvGray`), with a 12 `primary` dot inside when selected. **Tapping a row selects it, closes the sheet and shows "Saved".**

## 8. Interests sheet
**"Interests"** 18 / w600; **"Pick what you like talking about."** margin-top 4, 14 `ink/75`. Chips (margin-top 16, wrap, gap 8) for **Music, Tech, Travel, Movies, Fitness, Art**: height 48, fully rounded, 1 px border, padding h 16, gap 6, 14 / w500. Selected: bg and border `primary`, text white, with a check 14 before the label. Unselected: border `divider`, white, text `ink`. Tapping toggles the **draft**. Then **"Save changes"** NeoButton (margin-top 24; always enabled): commit the draft, close, snackbar **"Saved"**. Closing by scrim or back discards the draft. Zero selected is allowed (the row then shows "Add interests").

## 9. Snackbar
`AppSnack.show(bottom: 24 + safeBottom)`. Texts used: "Coming soon", "Saved", "User ID copied". Hide on dispose.

## 10. State and data
Local state: name, gender, interests, photos (count), verified. Name is also written to the shared profile store (`saveProfile`). Put the rest behind a `ProfileRepository` (in-memory now) so an API can replace it. Test hooks (constructor params, not UI): `initialPhotos`, `initialVerified`, `initialSheet` (`name | gender | interests`).

## 11. Numeric checks (width 390)
- Avatar 96×96 centred; the edit button's inner circle is 32×32 and its centre is 10 dp inside the avatar's right edge and 10 dp inside its bottom edge (touch area 48×48, right/bottom −14).
- Photo tiles/Add tile are 104×140; with 0 photos only "Add photo" is shown; after 6 adds it disappears (6 tiles); removing one brings it back.
- The verified card is 64 tall; its sub-text ellipsizes at 360 wide; tapping changes the chip to "Verified" (check + text, bg `onlineCyan`).
- Rows are 64 tall, 8 apart, except Birthday whose wrapper is 64 + 6 + 16 (caption line height) = 86 tall; "User ID" has the copy button and no chevron; "Interests" reads "Music, Tech +1".
- Name sheet: with the unchanged name → button disabled (gradient visible, border `divider`), helper "Change your name to save", message "Looks good". Type "A" → warning message "Use 2 to 24 characters, letters and numbers only", border `ink`. Type "Meera S" → button enabled, helper "Ready to save", Save → sheet closes, row shows "Meera S", snackbar "Saved".
- Gender: choose "Man" → sheet closes, row shows "Man". Interests: deselect "Music" → Save → row "Tech, Travel".
- System back with a sheet open closes only the sheet; with none open it returns to Me.

## 12. Do not
- Do not add a real image picker, upload, birthday picker, or verification flow. The "Coming soon" snackbars are intentional.
- Do not use Material `TextField` decorations (underline, floating label); style the field as specified.
