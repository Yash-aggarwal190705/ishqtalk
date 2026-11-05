# ishqtalk

## React → Flutter port

Foundation, Splash, Login (including account/contact/OTP/legal modals), and the
Welcome Offer / notification / simulated-payment slice are implemented.
See [`port_log.md`](port_log.md) for file locations, pending screens,
font sources, review notes and verification commands.

```sh
flutter pub get
flutter run --dart-define=DEV_SCREEN_PICKER=true
```

Default boot shows static Splash for two seconds, then Login (or Live for an
already-onboarded profile). Use `--dart-define=INITIAL_SCREEN=login-otp` to enter a
particular state directly. The demo verification code is **123456**.

Visual regression tests use 390×844, plus three 320×568 keyboard-inset captures.
Run `flutter analyze` and `flutter test`. Headless native-glyph test setup is in
[`test/goldens/README.md`](test/goldens/README.md); application fonts remain Poppins
with native platform emoji. Section 1A review: [`docs/section_1a_self_review.md`](docs/section_1a_self_review.md).

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
