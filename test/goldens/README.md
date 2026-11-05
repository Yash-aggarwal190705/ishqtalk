# Port regression captures

- Foundation + Section 1B: five original 390×844 PNGs.
- Section 1A: `splash`, `login`, `login_expanded`, `login_google`, `login_email`,
  `login_otp`, each 390×844, DPR1, zero safe/keyboard insets.
- Keyboard layout: `login_email_keyboard`, `login_phone_keyboard`,
  `login_email_otp_keyboard`, each 320×568 with a **simulated 300px keyboard inset**.
  The app surface below y268 is covered by the keyboard on a device. These images
  test layout/insets; they are not captures of an Android/iOS keyboard.
- Explore tab: `explore` (390×844), `explore_360` (360×800), `explore_480`
  (480×960). Same DPR1/zero-inset conventions; loaded state (no skeleton). The
  explore goldens were generated on Windows with `msyh.ttc` as the symbol
  fallback face; the older Login/Onboarding baselines came from the Linux
  container with Noto Sans CJK, so they are not interchangeable byte-for-byte
  across hosts.

Use `flutter test` for normal comparison. Only regenerate intentionally reviewed
changes, with the targeted test files and `--update-goldens`.

All captures load the bundled Poppins fonts, preserve production shadows, settle
entrances with `instant`, and freeze loops with the test-only `MotionScope` at
their initial phase. A positive-delay floater remains invisible. OTP captures
retain focus, the initial caret, and countdown30. No production timer is disabled.

## Headless native-glyph support (Section 1A captures only)

`flutter_tester` does not resolve native fallback fonts like a device. The golden
fixture loads **test-only** fallback faces to avoid tofu for native emoji and the
source's fullwidth `＋` character. Neither face is added to application assets,
`pubspec.yaml`, or production text styles. No emoji asset was downloaded.

The verified environment uses Flutter3.47.9 on Linux, with:

| Face | Source | SHA-256 |
|---|---|---|
| Noto Color Emoji | Existing Flutter SDK `engine/src/flutter/txt/third_party/fonts/NotoColorEmoji.ttf` | `50cd34f78ec3553aaf20c6db140f880d54cc84f06e1377767961743d496a56da` |
| Noto Sans CJK Regular | Debian `fonts-noto-cjk` 1:20220127+repack1-1, installed OS font | `b76b0433203017ca80401b2ee0dd69350349871c4b19d504c34dbdd80541690a` |

On a matching Linux host, install `fonts-noto-cjk`. The loader discovers the SDK
and installed CJK font. On other test hosts, point `PORT_EMOJI_FONT` and
`PORT_SYMBOL_FONT` to equivalent existing files. Baselines use these exact faces;
a different native face can change pixels, as expected. Production emoji/flags
and fullwidth-symbol fallback use the host platform and can look different.

These are Flutter-engine regression baselines. Supplied montages are not
same-size React baselines, so passing tests does not prove cross-engine pixel
identity. See the section self-review for remaining comparison limits.
