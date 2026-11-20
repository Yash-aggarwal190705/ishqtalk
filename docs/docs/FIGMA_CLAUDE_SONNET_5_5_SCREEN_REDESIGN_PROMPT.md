# Figma redesign prompt for Claude Sonnet 5.5

Copy the prompt below into Claude Sonnet 5.5 when asking it to redesign the
current Orbitra Flutter screens in Figma.

---

## Prompt

You are redesigning the existing **Orbitra** Android-first Flutter client in
Figma. The current implementation is a local-first social discovery,
messaging, and staged video-chat prototype. Your job is to improve the screen
design, information hierarchy, states, and prototype flow without changing the
product's established visual identity.

This is a **design handoff task**, not a request to rewrite the Flutter code.
Create a complete, structured Figma design system and clickable prototype that
the developer can implement in the existing Flutter project.

## 1. Non-negotiable design constraints

### Preserve the existing visual identity

Keep the current Orbitra design language:

- dark navy background;
- rounded surfaces and cards;
- warm orange primary actions;
- mint secondary accents;
- soft, friendly, low-pressure social tone;
- generous spacing;
- high-contrast light text;
- simple geometric artwork instead of photographic or copied assets;
- Material 3-inspired controls;
- calm, welcoming, independent visual identity.

Do **not** redesign the app into a different brand style. Do not introduce a
light theme, neon cyberpunk style, glassmorphism, gradients everywhere,
high-density dashboard layouts, or a generic banking/social template.

### Keep this exact color palette

Create Figma color variables or styles using these exact values:

| Token | Hex | Usage |
| --- | --- | --- |
| `background` | `#10141F` | Main page and scaffold background |
| `surface` | `#1A2233` | Cards, fields, navigation surface, message bubbles |
| `raisedSurface` | `#222C41` | Selected chips, notices, raised controls, secondary surfaces |
| `border` | `#364056` | Borders, dividers, inactive outlines |
| `primaryText` | `#F8FAFC` | Main headings, body text, important labels |
| `mutedText` | `#AEB9CC` | Secondary copy, helper text, timestamps |
| `accent` | `#F18F4E` | Primary CTA, selected action, outgoing messages |
| `mint` | `#6FD6BE` | Secondary accent, topic labels, positive discovery cues |
| `danger` | `#FF7777` | Report, safety, destructive warnings, preview status |
| `success` | `#5DD39E` | Online, available, successful state |
| `warning` | `#F3C969` | Attention and pending state |
| `onAccent` | `#22170F` | Text/icons on the orange accent |

Do not create replacement colors that visually change the product. Small
opacity variants are allowed for overlays, disabled states, dividers, and
artwork decoration, but the base palette must remain unchanged.

### Keep the current visual tokens

Use the existing implementation as the visual reference:

- main card radius: approximately `20px`;
- input and button radius: approximately `14px`;
- small badge/chip radius: pill shape or approximately `20px`;
- standard button height: approximately `48–52px`;
- minimum interactive target: `44px × 44px`;
- horizontal page padding: approximately `20–24px`;
- card padding: approximately `12–24px` depending on hierarchy;
- typography: clean modern sans-serif similar to Flutter Material/Roboto;
- no decorative display font;
- no excessive uppercase text except compact status badges such as `LIVE` or
  `PREVIEW`.

Use Auto Layout, components, variants, and variables throughout the Figma
file. Do not draw one-off static rectangles when a reusable component is
appropriate.

## 2. Current source files to use as context

The current Flutter implementation is under:

```text
flutter_app/lib/src/screens/
flutter_app/lib/src/widgets.dart
flutter_app/lib/src/theme.dart
flutter_app/lib/src/models.dart
flutter_app/lib/src/controller.dart
flutter_app/lib/src/repository.dart
```

The existing screens are:

1. Welcome
2. Profile setup
3. Discover
4. Live-room detail
5. Host profile detail
6. Inbox
7. Conversation
8. Local profile/settings

Preserve the existing Orbitra logo concept, card treatment, geometric room
artwork, avatar initials, topic pills, message bubbles, and bottom navigation
visual language. Improve the structure and states around them.

## 3. Clean-room and originality requirements

This is an independent product. Do not copy any target application's exact
screens, branding, logo, text, colors, icons, layout, assets, screenshots,
illustrations, or proprietary media. Use only the current Orbitra code and the
requirements in this prompt.

Use original Orbitra copy and original geometric artwork. Do not use stock
photos or target-derived images in the design file.

## 4. Figma file organization

Create the following Figma pages:

### Page 00 — Cover and design brief

Include:

- Orbitra title;
- short product description;
- prototype scope: local-first social discovery and messaging;
- explicit note that authentication, backend messaging, RTC, billing, payouts,
  and production moderation are not connected in the current Flutter slice;
- design principles;
- palette summary;
- last-updated date;
- a small “implementation status” legend:
  - implemented in local prototype;
  - staged or preview only;
  - planned for backend milestone.

### Page 01 — Foundations

Create:

- color variables;
- typography styles;
- spacing scale;
- corner-radius scale;
- elevation/border rules;
- icon sizing rules;
- accessibility notes;
- responsive mobile frame guidance.

Recommended spacing values: `4, 8, 12, 16, 20, 24, 28, 32, 40, 48`.

Recommended mobile frames:

- primary: `390 × 844`;
- compact: `360 × 800`;
- large: `412 × 915`.

Every important screen must be checked on all three widths, especially long
names, long room titles, validation errors, keyboard-visible states, and empty
states.

### Page 02 — Components

Create reusable components with variants for:

- Orbitra logo;
- profile avatar with initials;
- online/away/unavailable indicator;
- primary filled button;
- secondary outlined button;
- icon button;
- destructive button;
- text field;
- validation/error text;
- topic pill/choice chip;
- demo/staged notice;
- live/preview badge;
- viewer-count badge;
- room artwork;
- live-room card;
- profile summary row;
- message bubble: incoming/outgoing/pending/failed;
- inbox conversation tile: read/unread;
- empty-state card;
- loading skeleton;
- offline/retry banner;
- bottom navigation item;
- report reason row;
- confirmation dialog;
- bottom sheet;
- permission education card.

Use component properties for:

- selected/unselected;
- enabled/disabled;
- loading;
- error;
- online/away/unavailable;
- unread/read;
- local preview/server-backed placeholder;
- short/long text;
- light/dark content on artwork.

## 5. Global design behavior

Apply these rules to every screen:

1. Keep the dark background visible around major content groups.
2. Do not put every element inside a card. Use cards for clear content groups.
3. Keep primary actions orange and secondary actions outlined or mint-accented.
4. Use mint for discovery and positive relationship cues, not for destructive
   actions.
5. Use danger red only for report, block, unavailable, failure, or destructive
   confirmation states.
6. Use warning yellow for pending or attention states.
7. Keep text concise, warm, and non-technical.
8. Never make the local prototype look like a production connection is live.
9. Clearly distinguish `PREVIEW`, `STAGED`, `LOCAL`, and `LIVE` states.
10. Keep all important states usable without color alone; include text, icons,
    or shape changes.
11. Maintain 44px or larger touch targets.
12. Ensure text remains readable at large font sizes.
13. Use accessible labels for icon-only actions.
14. Use ellipsis or controlled wrapping for long names and titles.

## 6. Detailed screen redesign instructions

### Screen A — Welcome

Current purpose: introduce Orbitra and start local profile setup.

Create these frames:

1. `Welcome / Default`
2. `Welcome / Compact viewport`
3. `Welcome / Accessibility large text`

Keep:

- Orbitra logo centered near the top;
- `Orbitra` wordmark;
- tagline `Find a room. Meet a spark.`;
- dark navy background;
- warm surface card;
- orange `Start exploring` CTA;
- local-development notice.

Improve:

- Make the vertical layout responsive instead of relying on a fixed visual
  height.
- Keep the main CTA full width with a minimum height of 52px.
- Make the short explanatory card easier to scan: small mint eyebrow, one
  strong sentence, optional supporting line.
- Keep the development notice visually separate from the product promise.
- Use an information icon and label the notice as `Local preview` rather than
  making it look like a warning or error.
- Ensure the button and notice remain visible without awkward clipping on the
  compact 360 × 800 frame.

Suggested copy hierarchy:

```text
Orbitra
Find a room. Meet a spark.

A small start
Build your corner of the community with a name and a few good conversations.

Start exploring

Local preview · no account required
Seeded data is used while the server features are being built.
```

Do not add login, password, phone, or social-provider fields to this local
prototype screen. Authentication belongs to a later backend milestone.

### Screen B — Profile setup

Current purpose: collect a display name and initial topic interest.

Create these frames:

1. `Profile setup / Empty`
2. `Profile setup / Name focused`
3. `Profile setup / Name invalid`
4. `Profile setup / Interest selected`
5. `Profile setup / Keyboard visible`
6. `Profile setup / Saving`
7. `Profile setup / Saved transition`

Required changes:

- The display-name field must be blank for a genuinely new local profile.
- Do not prefill a new user with `Avery` unless the frame is explicitly marked
  as seeded demo data.
- Keep the live avatar preview, but show a neutral placeholder when the name is
  empty.
- Keep the maximum display-name length of 60 characters.
- Show validation for empty input and names shorter than two characters.
- Show the character counter without making it visually dominant.
- Keep the topic selector, but make it clear that the selected topic is saved
  as part of the profile.
- Use a single-selection chip group with clear selected state: orange fill,
  dark text, visible check icon or strong selection treatment.
- Add a short helper line: `You can change this later.`
- Make the save button full width and disabled while invalid or saving.
- Show a small progress/loading state on the button while saving.
- Keep the local-state notice, but use the label `Local preview`.

Required topic options:

```text
Music · Talk · Games · Creative
```

The prototype must include a matching seeded Music discovery state later. Do
not present a filter or interest that has no corresponding content without an
explicit empty-state explanation.

### Screen C — Discover

Current purpose: browse seeded rooms, search, and filter by topic.

Create these frames:

1. `Discover / Default`
2. `Discover / Search focused`
3. `Discover / Topic selected`
4. `Discover / Search results`
5. `Discover / No results`
6. `Discover / Offline`
7. `Discover / Loading skeleton`
8. `Discover / Room unavailable`

Keep:

- `Discover` heading;
- short subtitle;
- search field;
- horizontal topic pills;
- rounded room cards;
- geometric gradient artwork;
- host avatar and name;
- viewer-count treatment;
- bottom navigation.

Improve the information hierarchy:

- Search field first, then topic filters, then the room feed.
- Keep topic pills horizontally scrollable without shrinking their labels.
- Use `For you`, `Music`, `Talk`, `Games`, and `Creative` consistently.
- Make the selected topic obvious using the orange accent and dark text.
- Add a clear-filter action to the no-results state.
- When a search returns nothing, say what was searched and offer `Clear search`.
- When a topic has no available rooms, say `No rooms in this topic yet` rather
  than using a generic failure message.

Room card changes:

- Keep the artwork and geometric style.
- Keep the small status badge, but use `PREVIEW` for the local slice unless the
  session is actually connected to RTC.
- Keep viewer count as seeded/demo data and pair it with a `Seeded` or `Local`
  label in the prototype documentation, not as a prominent warning on every
  card.
- Make the room title the primary text.
- Make the host row a clearly separate tappable profile action so the outer room
  card action and host action are not ambiguous.
- Render `Online now`, `Away`, or `Unavailable` from state instead of always
  showing `online now`.
- Add a subtle unavailable card variant with muted artwork and a reason.

Do not add a global recommendation algorithm or claim real-time availability.

### Screen D — Room detail

Current purpose: show a seeded room preview, host details, follow action, local
chat, and report preview.

Create these frames:

1. `Room / Preview default`
2. `Room / Following host`
3. `Room / Empty chat`
4. `Room / Chat with messages`
5. `Room / Composer focused`
6. `Room / Report sheet`
7. `Room / Report acknowledgement`
8. `Room / Staged video-chat notice`
9. `Room / Unavailable`
10. `Room / Offline retry`

Required changes:

- Keep the large geometric room artwork and dark theme.
- Change the prominent `LIVE` label to `PREVIEW` for the local-first build,
  unless the frame is explicitly a future server-backed RTC state.
- Show a small explanation such as `Local room preview · viewer count is
  seeded` in the design documentation or secondary notice.
- Keep room title, description, topic, and host information in that order.
- Keep `Follow` as the primary relationship action.
- Add a secondary `Message host` action if the prototype supports creating a
  local conversation from a room.
- Keep report accessible from the app bar and the room action area, but avoid
  presenting two visually identical controls too close together.
- Add a clear `More` menu variant containing report and block actions when the
  safety flow is expanded.
- Keep the report sheet short, calm, and non-accusatory.
- Add a confirmation/acknowledgement state after a report selection:
  `Thanks. Your report was recorded in this local preview.`
- Make the message list scrollable and keep the newest message visible after a
  message is sent.
- Add message states for incoming, outgoing, pending, failed, and retry.
- Keep the composer anchored above the system inset and keyboard.
- Disable or visually soften the send button for an empty message.
- Add a staged-call information sheet instead of implying that a live call is
  already available.

Suggested staged-call copy:

```text
Private calls are staged
Authentication, permissions, server authorization, RTC tokens, and billing
must be connected before private calls can be enabled.
```

### Screen E — Host profile detail

Current purpose: show a public profile, follow action, and staged video-chat
entry point.

Create these frames:

1. `Profile detail / Online`
2. `Profile detail / Away`
3. `Profile detail / Unavailable`
4. `Profile detail / Following`
5. `Profile detail / Message action`
6. `Profile detail / Staged video chat`
7. `Profile detail / Report and block menu`
8. `Profile detail / Deleted or unavailable profile`

Required changes:

- Keep the centered avatar, name, status, bio, and rounded action area.
- Use the correct status color: success for online, muted text for away, and
  danger or warning only for unavailable/suspended states.
- Add a `Message` action. The product flow must not promise that users can start
  a conversation from a profile unless this action exists.
- Keep `Follow` as the primary action when the user is not following the host.
- Keep `Video chat` outlined and visibly staged/disabled until backend, RTC,
  permissions, consent, and billing are implemented.
- Add a top-right overflow menu for `Report profile` and `Block profile`.
- Use a confirmation dialog for blocking and a report-reason sheet for reports.
- Replace arbitrary statistics such as `38 rooms` and `92% good vibes` with
  either real seeded values that are clearly labeled or simpler approved
  information such as topic, availability, and follower count.
- Do not show a “good vibes” score unless the product owner approves its
  meaning, calculation, privacy implications, and moderation use.
- Add an unavailable/deleted state that does not show active actions.

### Screen F — Inbox

Current purpose: display seeded conversations and provide an empty state.

Create these frames:

1. `Inbox / With conversations`
2. `Inbox / Unread conversation`
3. `Inbox / Read conversation`
4. `Inbox / Empty`
5. `Inbox / Offline`
6. `Inbox / Loading skeleton`
7. `Inbox / Conversation unavailable`

Required changes:

- Keep the simple heading and subtitle.
- Keep conversation tiles with avatar, name, preview, timestamp, and unread
  count.
- Make unread state visually clear without relying only on color: use weight,
  badge, and contrast.
- Opening a conversation must have a corresponding read-state design. The
  unread badge should not remain forever after the conversation is opened.
- Add an optional overflow action on a conversation tile or in the conversation
  screen for report and block.
- If the inbox is empty, do not say `Start a conversation from a profile or
  room` unless those screens have a real Message action. Use a CTA such as
  `Explore rooms` if necessary.
- Add offline and retry states without implying message delivery.
- Use muted content for deleted or unavailable participants.

### Screen G — Conversation

Current purpose: show a local message thread and allow local message entry.

Create these frames:

1. `Conversation / Initial thread`
2. `Conversation / New outgoing message`
3. `Conversation / Pending message`
4. `Conversation / Failed message`
5. `Conversation / Retry message`
6. `Conversation / Empty thread`
7. `Conversation / Offline`
8. `Conversation / Report/block menu`
9. `Conversation / Long participant name`

Required changes:

- Keep incoming messages on the left and outgoing messages on the right.
- Keep orange for outgoing and surface color for incoming bubbles.
- Keep sender name visible for incoming room messages where needed, but avoid
  repeating private-conversation names on every bubble.
- Automatically keep the newest message visible after sending.
- Add pending and failed message variants with retry affordance.
- Keep delivery/read indicators clearly marked as staged until server delivery
  exists.
- Add a safe conversation menu containing `Report`, `Block`, and a future
  `Conversation details` entry.
- Make the AppBar safe for long names: avatar, flexible name area, ellipsis,
  and menu button.
- Keep the composer above the keyboard and system inset.
- Add a reasonable message character limit in the visual design.
- Do not add attachment, voice, or call controls as working actions unless they
  are marked as future/staged.

### Screen H — Local profile

Current purpose: show the local user's profile, edit name, settings placeholder,
and activity metrics.

Create these frames:

1. `My profile / Default`
2. `My profile / Edit name`
3. `My profile / Edit interest`
4. `My profile / Saving`
5. `My profile / Settings preview`
6. `My profile / Delete account preview`
7. `My profile / Empty activity`
8. `My profile / Local development notice`

Required changes:

- Keep the current compact profile header and two outlined actions.
- Add editing for the saved interest/topic as well as display name.
- Keep the settings button, but show a proper staged settings preview rather
  than only a snackbar.
- Include future settings categories visually:
  - Account and session;
  - Notifications;
  - Permissions;
  - Privacy and safety;
  - Help and support;
  - Delete account.
- Keep account deletion visibly destructive and separated from ordinary settings.
- Replace hard-coded activity statistics with values derived from local state or
  label them clearly as seeded demo values.
- Prefer truthful activity counters such as rooms visited, people followed, and
  messages sent. Do not show a host count if the user has not hosted a room.
- Keep the local-development notice, but make it an informational state rather
  than a product failure.

## 7. Required global states

Create representative frames or component variants for all of these:

### Loading

- Use surface-colored skeleton blocks.
- Do not use a full-screen spinner for ordinary feed loading.
- Keep the layout shape stable while content loads.

### Empty

- Use a mint or neutral icon.
- Explain why the state is empty.
- Provide one useful next action where possible.

### Offline

- Use a compact warning banner with `Try again`.
- Do not claim that a message was delivered while offline.
- Preserve typed message text if a send attempt fails.

### Error

- Use calm, user-readable copy.
- Do not expose stack traces, API details, provider names, or technical tokens.
- Provide retry where retry is safe.

### Blocked/deleted/unavailable

- Remove or disable actions that cannot be used.
- Do not expose private information about a blocked/deleted account.
- Explain only what the current user needs to know.

### Report acknowledgement

- Confirm that the report was received or queued in the local preview.
- Never reveal the reporter's identity to the reported person.

### Permission education

Create a staged permission education card for camera and microphone use:

- explain why the permission is needed;
- show an allow/continue action;
- show a denial path and settings guidance;
- do not imply that permission was granted before the system result exists.

## 8. Prototype connections

Connect the Figma prototype so the main local journey can be clicked:

```text
Welcome
  → Profile setup
  → Profile setup / Interest selected
  → Discover
  → Search/filter
  → Room preview
  → Host profile
  → Follow
  → Message
  → Inbox
  → Conversation
  → Send message
  → Report/block preview
  → My profile
  → Edit name or interest
```

Also connect these alternate paths:

- Discover with no results → clear filters → Discover default;
- Room → report sheet → acknowledgement;
- Profile detail → staged video chat → explanation dialog;
- Conversation → failed message → retry;
- Inbox → empty state → Explore rooms;
- Profile → settings preview → local-only explanation;
- Profile → delete-account preview → cancel/confirmation.

Use realistic mobile transitions: short dissolve or slide for navigation, bottom
sheet for report reasons, dialog for staged call explanation, and no excessive
motion.

## 9. Copy and product truthfulness rules

Use copy that is warm but precise. Avoid promising functionality that the
current local-first app does not implement.

Use these labels consistently:

- `Local preview` for seeded local data;
- `Staged` for UI entry points that are not enabled;
- `Preview` instead of `Live` when there is no RTC connection;
- `Seeded` for demo viewer counts or statistics;
- `Unavailable` for an item that cannot currently be opened;
- `Try again` for recoverable errors.

Do not use:

- “real-time” when the data is local;
- “delivered” without server delivery evidence;
- “live” without a verified RTC session;
- “earnings” or “balance” until financial backend behavior exists;
- “verified” unless the verification state is actually modeled;
- arbitrary reputation scores such as “good vibes” without an approved rule.

## 10. Accessibility and implementation handoff

For every screen, verify:

- all primary actions have visible text;
- icon-only actions have a tooltip/accessible label;
- touch targets are at least 44px;
- text contrast is readable against the exact palette;
- status is not conveyed by color alone;
- long names and titles wrap or truncate safely;
- empty, error, and offline states are understandable without technical
  knowledge;
- large text does not clip buttons or hide essential actions;
- keyboard-visible layouts keep the composer and save actions accessible.

For the developer handoff, annotate:

- component names;
- Figma variables/styles used;
- spacing and radius values;
- frame sizes;
- interaction behavior;
- state transitions;
- whether each element is implemented now, local-only, staged, or planned;
- any copy that must remain exact in the Flutter implementation.

## 11. Final Figma deliverables

Before finishing, provide:

1. A polished Figma file organized by the pages above.
2. A clickable prototype covering the main local journey.
3. Component variants for all important states.
4. Responsive frames at 360 × 800, 390 × 844, and 412 × 915.
5. A design-token page with the exact Orbitra palette.
6. A screen-by-screen change log describing what changed and why.
7. An implementation-status legend separating local, staged, and future server
   behavior.
8. Developer annotations for Flutter implementation.

Do not change the Orbitra brand, palette, or overall dark rounded visual style.
Improve clarity, truthfulness, accessibility, state coverage, and the path from
profile discovery to messaging while keeping the design recognizably Orbitra.

---

## Expected outcome

The resulting Figma file should feel like a refined version of the current
Orbitra app—not a new app. A developer should be able to implement it in the
existing Flutter project without inventing new colors, components, navigation
patterns, or product promises.
