# READ ME FIRST: foundation for the v2 screens (Flutter port)

You are porting more screens from the Figma Make React prototype to Flutter/Dart. **You cannot look at images, so everything here is written from the React source.** Do not ask me for screenshots. If a number is missing from my spec, read it from the source file named at the top of that spec, and tell me which number you took from where.

## 0. The source changed: the new zip is the truth

I gave you a **new zip** (`Review_File_and_Begin_Work_2`). It is a newer revision of the prototype than the one my earlier specs were written from. Rules:

1. **Source of truth = the new zip's `src/`.** Where an earlier spec disagrees with it, the new source wins.
2. What is **superseded**:

| Earlier spec part | Replaced by |
|---|---|
| `live_and_messages_flutter_spec.md`, Messages part | `v2_01_messages_and_notifications.md` (source `src/inbox.tsx`; Messages left `views.tsx`) |
| `commerce_screens_flutter_spec.md` Part B (Get Tokens, 7 packs, purple header, UPI/Card/Wallet pay sheet) | `v2_07_me_and_get_tokens_updates.md` (source `src/tokens.tsx`: 6 amounts, 2-column cards, confirm sheet) |
| `commerce_screens_flutter_spec.md` Part D (Package: Props/Gift) | `v2_03_my_items_expired_history_bonus.md` (source `src/myItems.tsx`: "My items", Passes/Gifts) |
| `profile_and_discover_flutter_spec.md` Part A (My Profile) | still valid, **plus** the changes in `v2_07` (Wallet and rewards section, Edit icon, App settings) |
| `profile_and_discover_flutter_spec.md` A5 (Edit profile *sheet*) | `v2_05_edit_profile.md` (now a full **screen**, `src/editProfile.tsx`) |

3. **Unchanged and still valid:** Explore, Live Home, User Profile, Calling Sheet, Visitors, History list, Bonus (Part C of the commerce spec; only its data changed, see `v2_03`), Sky Lantern, glass cards, `fix_back_navigation_prompt.md`.
4. If anything you already built looks wrong because of this, **list it in your plan; do not silently rebuild old screens.**

## 1. How to work (every v2 spec)

1. Read the source files named at the top of the spec **completely** before planning. Do not skim.
2. Reply with a SHORT plan (what you will build, in which files, what is reused) and any real questions. **Wait for my OK.**
3. 1 CSS px = 1 Flutter logical pixel. Design width about 390, max 480 (centered column above 480). Nothing may overflow at 360 wide or at text scale 1.3.
4. **Do not invent features. Do not add anything the source does not have.** Dev-only controls (the DevPanel, "Flow overview", the inspector, `forceEmpty`, `pinLoading`, `initial*` props) are NOT screens or buttons. Their *states* are real states (loading, empty, sheet open) and must be reachable normally. The props become optional constructor parameters used only by tests.
5. Seed data lives behind repository interfaces so a real API can replace it later. Keep the seeds exactly as in the source.
6. **Verify numerically, because you cannot see.** For each screen write widget tests that assert the sizes, positions and texts listed in its "Numeric checks" section (use `tester.getRect(find.byKey(...))`, `find.text(...)`). Give widgets `Key`s for that. Also add a debug-only helper that prints the rects of keyed widgets so you can compare with my numbers. Run `flutter analyze` and the tests.
7. At the end report: what you built, what you seeded, what you stubbed, any deviation and why, and anything that looked like a bug in the prototype.
8. Reference Dart: `v2_shared_widgets.dart` (tokens, text helper, CSS-angle gradient, NeoButton, sheets, snackbar, shimmer, switch, TokenCoin, PassTicket, OrbitBadge, dashed painter). It was written without a compiler. Use it as a starting point, fix what `flutter analyze` reports, and keep the numbers.

## 2. Tailwind to Flutter conversion (the source is Tailwind v4)

| Tailwind | Flutter |
|---|---|
| spacing `n` (e.g. `p-4`, `gap-3`, `h-14`, `mt-5`) | n × 4 dp (`h-14` = 56, `px-5` = 20, `gap-1.5` = 6) |
| `rounded-lg / xl / 2xl / 3xl / full` | 8 / 12 / 16 / 24 / stadium (half of the shorter side) |
| `rounded-[28px]` | 28 (arbitrary values are literal px) |
| `text-xs / sm / base / lg / xl / 2xl` | 12/16, 14/20, 16/24, 18/28, 20/28, 24/32 (size / line height). Any other size without `leading-*` has line height 1.5 × size |
| `font-medium / semibold / bold / extrabold` | w500 / w600 / w700 / w800 |
| `text-ink/75` | ink at 75% alpha (`K.sub`); `/60` = `K.ink60`; `bg-ink/30` = `K.scrim30` |
| `text-ink-2`, `text-ink-3` | tokens `ink2` #8A839F, `ink3` #A8A2BA (different from `ink/75`) |
| `blur-[Npx]`, `backdrop-blur-[Npx]` | `ImageFilter.blur(sigma: N)` |
| `shadow-[0_Ypx_Bpx_color]` | `BoxShadow(offset: (0,Y), blurRadius: B)` |
| `divide-y`, `border-b` with `divider` | 1 px `#ECE7F5` line |
| `active:scale-[.98]` | `AnimatedScale` 0.98 while pressed |
| `pt-safe`, `pb-safe`, `pb-[calc(24px+env(safe-area-inset-bottom))]` | add `MediaQuery.viewPaddingOf(context).top/bottom` |
| `h-nav` | 56 + safe-area bottom (bottom nav height) |
| `truncate` | `maxLines: 1, overflow: TextOverflow.ellipsis` |

Text: use `TextStyle(height: lineHeight / fontSize, leadingDistribution: TextLeadingDistribution.even)` (CSS centres half-leading above and below). Font: Poppins; the source uses weights 400, 500, 600, 700, 800 and italic 600/700. Bundle the font files (do not rely on a runtime download for the first frame). The ₹ sign and the real minus U+2212 are used in the text, keep them.

Gradients: use `cssLinear(angleDeg, colors)` from `v2_shared_widgets.dart`. A plain `Alignment.topLeft → bottomRight` is wrong on non-square boxes.

## 3. Design tokens (`src/index.css`)

primary #8B5CF6 · cta #FF6B6B · primary10 #F5F0FF · ink #3B3354 · ink2 #8A839F · ink3 #A8A2BA · card #F7F4FC · screen #FBF9FF · divider #ECE7F5 · coin #FFC857 · coinBg #FFF4D6 · vipA #FFC857 · vipB #FF9F7A · badge #FF4D8D · onlineGreen #3CC76A · onlineCyan #2ED3C6 · lvGray #C9C3D8 · roseGold #F4B8A6 · profileA #C4B5FD · profileB #FFB4A8 · tintTokens #FFF0DD · tintVip #EFE6FF · tintInvite #FFE3EA · success #087F5B · danger #D92D2D.
Gradients: `bg-vip` = 135° vipA→vipB. `bg-brand` = 135° primary→cta. `bg-cta-pill` = 90° cta→badge. Check each one against `index.css` before use.

If `index.css` and these values differ, **index.css wins** and tell me.

## 4. Shared building blocks (v2 versions; replace older ones that differ)

- **Header** (`ui.tsx Header`): height 56 + safe top, children bottom-aligned, padding h 4, bottom 4. Back button 40×40 with a 24 icon (stroke 1.75, round). **Title** centered, 16/600 `ink`, its centre is 24 above the header bottom (same line as the icon centre). Right slot: `ml-auto`, height 40, `pr-3` (12). Screens that put a 48×48 button there (Token history filter, My items clock, Get tokens history) use `-mr-2` (-8) so the button's right edge is 4 from the screen edge.
- **Screen background** `screen` #FBF9FF unless the spec says white (Messages, Conversation, Settings groups differ, see each spec).
- **Page transition:** pushed screens slide in from the right 24 px + fade, 280 ms ease-out (`slide-in`). Token history, Edit profile and Notifications only fade, 250 ms. Tab screens have no transition (kept alive in an `IndexedStack`).
- **Sheet / ActionSheet / Dialog / Snackbar / Shimmer / NeoButton / Switch**: all defined in `v2_shared_widgets.dart`, with the exact numbers in its comments. Rules:
  - All sheets and dialogs are **real routes** (`showModalBottomSheet`, `showGeneralDialog`) so system back closes only them. Tap on the scrim closes (except where a spec says otherwise).
  - **Disabled NeoButton:** a gradient (vip) button KEEPS its orange gradient when disabled (an un-layered CSS rule beats Tailwind's `disabled:bg-card`); only its border becomes `divider`, its text `ink/60`, and the hard shadow disappears. A *red* NeoButton becomes flat `card` when disabled. (I checked this against the screenshots.)
  - **Snackbar:** dark pill, one at a time, 2.2 s, fade in 250 ms. Call `AppSnack.hide()` in the screen's `dispose`.
  - **Shimmer:** one `ShimmerScope` per skeleton list.
- **Loading states are real:** every list screen shows its skeleton first and then the content. In the prototype the delay is faked (600 to 700 ms). In Flutter: show the skeleton until the repository returns, with a minimum of 300 ms so it does not flash. Because tabs are kept alive, a tab's skeleton shows only the first time the tab is built.
- **Icons:** copy the SVG path data from `src/ui.tsx` (`P` table and `Icon`) and from the inline `<svg>` blocks in each screen file. All are 24×24 viewBox, `fill: none`, stroke `currentColor`, width 1.75, round caps and joins, unless the source says otherwise. Do not substitute Material icons.
- **Empty state** (`ui.tsx EmptyState`, used by Notifications): `py-12 px-8`, centred column; a 64 circle `card` with an `ink3` icon 28; title 14/500 `ink2` (mt 12); body 12 `ink3` (mt 4).

## 5. Navigation (extends `fix_back_navigation_prompt.md`)

Pushed screens (no bottom nav, back returns to the opener, state kept): Notifications, Token history, Level, My items, Expired items, Edit profile, App settings, Conversation, Get Tokens, Bonus, History, Visitors, User Profile. Sheets and dialogs: everything named "sheet", "dialog", "confirm", "menu".

New flows that must work (back, back, back…):

| Flow | Back |
|---|---|
| Messages → Notifications | → **Messages** |
| Messages → ⋯ → Clear message list → confirm | dialog closes → sheet is already closed → **Messages** |
| Messages → long-press row → menu → Report → reason → Done | each step closes one layer → **Messages** |
| Me → Wallet and rewards → Token history → empty-state "Get tokens" | Get Tokens → **Token history** → **Me** |
| Me → Level | → **Me** |
| Me → My items → Expired items (clock icon) | Expired → **My items** → **Me** |
| My items → "See daily bonus" (empty Passes) | per the source this pushes **Level** (see `v2_03`); back → My items |
| Bonus → ticket icon | My items → **Bonus** |
| Me → edit icon → Edit profile → Name / Gender / Interests sheets | sheet closes → **Edit profile** → **Me** |
| Me → App settings → Log out sheet | sheet closes → **App settings** → **Me** |
| Conversation → ⋯ → Block → confirm | after blocking, the conversation closes (pop once) |

Switching tabs through the bottom nav clears pushed screens. Back on Explore/Messages/Me goes to Live; back on Live exits. Extend the existing back-navigation tests with these rows.

## 6. Build order

1. `v2_01_messages_and_notifications.md`
2. `v2_02_token_history_and_level.md`
3. `v2_03_my_items_expired_history_bonus.md`
4. `v2_04_conversation.md`
5. `v2_05_edit_profile.md`
6. `v2_06_app_settings.md`
7. `v2_07_me_and_get_tokens_updates.md`
8. `v2_08_onboarding.md` (Splash, Login, Welcome Offer; Welcome and Setup are legacy)

I will paste them one at a time. Do each one fully (all states, all sheets, all texts) before the next.
