import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/features/auth/data/local_auth_repository.dart';
import 'package:ishqtalk/features/auth/presentation/auth_state.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/onboarding/account_chooser.dart';
import 'package:ishqtalk/screens/onboarding/contact_sheet.dart';
import 'package:ishqtalk/screens/onboarding/country_code_picker.dart';
import 'package:ishqtalk/screens/onboarding/legal_dialog.dart';
import 'package:ishqtalk/screens/onboarding/login.dart';
import 'package:ishqtalk/screens/onboarding/login_busy_bar.dart';
import 'package:ishqtalk/screens/onboarding/login_primary_button.dart';
import 'package:ishqtalk/screens/onboarding/otp_step.dart';
import 'package:ishqtalk/screens/onboarding/provider_button.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Finder field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);
Finder digit(int i) => field('otp-digit-$i');
String code(WidgetTester tester) => List.generate(
  6,
  (i) => tester
      .widget<TextField>(digit(i))
      .controller!
      .text
      .replaceAll('\u200b', ''),
).join();

Future<NavigationState> mount(
  WidgetTester tester, {
  String? modal,
  bool expanded = false,
  bool instant = true,
}) async {
  usePortViewport(tester);
  final app = AppContextState();
  final nav = NavigationState(app: app, screen: 'login');
  final auth = AuthState(repository: LocalAuthRepository());
  addTearDown(nav.dispose);
  addTearDown(app.dispose);
  addTearDown(auth.dispose);
  await tester.pumpWidget(
    PortFixture(
      navigation: nav,
      auth: auth,
      child: Login(modal: modal, expanded: expanded, instant: instant),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 10));
  return nav;
}

Future<void> tapSpan(WidgetTester tester, String text) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText().contains(text),
  );
  final paragraph = tester.renderObject<RenderParagraph>(finder.last);
  final int start = paragraph.text.toPlainText().indexOf(text);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + text.length),
      )
      .first;
  await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  testWidgets('More reveals providers over 250ms and all three Rise delays', (
    tester,
  ) async {
    await mount(tester, instant: false);
    expect(find.text('Continue with X'), findsNothing);
    await tester.tap(find.text('More'));
    await tester.pump();
    expect(find.text('More'), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('extra-providers'))).height,
      0,
    );
    await tester.pump(const Duration(milliseconds: 125));
    expect(
      tester.getSize(find.byKey(const ValueKey('extra-providers'))).height,
      closeTo(116 * Curves.easeOut.transform(.5), .001),
    );
    await tester.pump(const Duration(milliseconds: 125));
    expect(
      tester.getSize(find.byKey(const ValueKey('extra-providers'))).height,
      116,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Continue with Telegram').hitTestable(), findsOneWidget);
    expect(find.text('Continue with Phone').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final (provider, modal) in [
    ('Google', 'google'),
    ('Email', 'email'),
    ('Phone', 'phone'),
  ]) {
    testWidgets('$provider waits exactly 400ms and disables every provider', (
      tester,
    ) async {
      await mount(tester, expanded: provider == 'Phone');
      await tester.tap(find.text('Continue with $provider'));
      await tester.pump();
      expect(find.byType(LoginBusyBar), findsOneWidget);
      expect(
        tester
            .widgetList<ProviderButton>(find.byType(ProviderButton))
            .every((b) => b.disabled),
        isTrue,
      );
      await tester.pump(const Duration(milliseconds: 399));
      expect(find.byType(AccountChooser), findsNothing);
      expect(find.byType(ContactSheet), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(LoginBusyBar), findsNothing);
      expect(
        find.byType(modal == 'google' ? AccountChooser : ContactSheet),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final provider in ['X', 'Telegram']) {
    testWidgets('$provider routes at 1200ms', (tester) async {
      final nav = await mount(tester, expanded: true);
      await tester.tap(find.text('Continue with $provider'));
      await tester.pump(const Duration(milliseconds: 1199));
      expect(nav.screen, 'login');
      await tester.pump(const Duration(milliseconds: 1));
      expect(nav.screen, 'welcome-offer');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'account chooser keeps its panel open, toast expires, pick routes after 1000ms',
    (tester) async {
      final nav = await mount(tester, modal: 'google');
      await tester.tap(find.text('Choose an account'));
      await tester.pump();
      expect(find.byType(AccountChooser), findsOneWidget);
      await tester.tap(find.text('Add another account'));
      await tester.pump(const Duration(milliseconds: 1799));
      expect(find.text('Demo only'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Demo only'), findsNothing);
      await tester.tap(find.text('Sam Rivera'));
      await tester.pump();
      expect(find.byType(AccountChooser), findsNothing);
      await tester.pump(const Duration(milliseconds: 999));
      expect(nav.screen, 'login');
      await tester.pump(const Duration(milliseconds: 1));
      expect(nav.screen, 'welcome-offer');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'email validates, trims target, changes back, and retains input',
    (tester) async {
      await mount(tester, modal: 'email');
      expect(
        tester.widget<TextField>(field('email-input')).focusNode!.hasFocus,
        isTrue,
      );
      expect(
        tester
            .widget<LoginPrimaryButton>(find.byType(LoginPrimaryButton))
            .onTap,
        isNull,
      );
      await tester.enterText(field('email-input'), 'alex@invalid');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await tester.enterText(field('email-input'), '  alex@example.com  ');
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsNothing);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      expect(find.byType(OtpStep), findsOneWidget);
      expect(
        find.textContaining('Sent to alex@example.com', findRichText: true),
        findsWidgets,
      );
      await tapSpan(tester, 'Change');
      await tester.pump();
      expect(
        tester.widget<TextField>(field('email-input')).controller!.text,
        '  alex@example.com  ',
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.byType(ContactSheet), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'phone selector shows countries and flags, normalizes digits and retains selection',
    (tester) async {
      await mount(tester, modal: 'phone');
      await tester.tap(find.text('+91'));
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      expect(find.byType(CountryCodePicker), findsOneWidget);
      for (final (flag, name, _) in CountryCodePicker.countries) {
        expect(find.text(flag), findsOneWidget);
        expect(find.text(name), findsOneWidget);
      }
      await tester.tap(find.text('United Kingdom'));
      await tester.pump();
      expect(find.byType(CountryCodePicker), findsNothing);
      expect(find.text('+44'), findsOneWidget);
      await tester.enterText(field('phone-input'), '12-abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Enter a valid phone number.'), findsOneWidget);
      await tester.enterText(field('phone-input'), '123 456 789 012345');
      await tester.pump();
      expect(
        tester.widget<TextField>(field('phone-input')).controller!.text,
        '123456789012',
      );
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      expect(
        find.textContaining('Sent to +44 123456789012', findRichText: true),
        findsWidgets,
      );
      await tapSpan(tester, 'Change');
      expect(find.text('+44'), findsOneWidget);
      expect(
        tester.widget<TextField>(field('phone-input')).controller!.text,
        '123456789012',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'OTP typing, hardware and software Backspace, and paste keep all digits in order',
    (tester) async {
      await mount(tester, modal: 'email-otp');
      await tester.enterText(digit(0), '1');
      await tester.pump();
      expect(tester.widget<TextField>(digit(1)).focusNode!.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(tester.widget<TextField>(digit(0)).focusNode!.hasFocus, isTrue);
      expect(code(tester), '1');
      await tester.tap(digit(1));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );
      await tester.pump();
      expect(tester.widget<TextField>(digit(0)).focusNode!.hasFocus, isTrue);
      await tester.enterText(digit(0), '123456');
      await tester.pump();
      expect(code(tester), '123456');
      expect(tester.widget<TextField>(digit(5)).focusNode!.hasFocus, isTrue);
      // Pasting at the end of an existing digit must ignore that existing digit.
      await tester.tap(digit(3));
      tester.widget<TextField>(digit(3)).controller!.selection =
          const TextSelection.collapsed(offset: 1);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '4654321',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      await tester.pump();
      expect(code(tester), '654321');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'wrong OTP shakes, a new digit clears error, Enter verifies after 1000ms',
    (tester) async {
      final nav = await mount(tester, modal: 'email-otp');
      await tester.enterText(digit(0), '999999');
      await tester.pump();
      await tester.tap(find.text('Verify'));
      await tester.pump();
      expect(find.text('Incorrect code. Please try again.'), findsOneWidget);
      final initialX = tester
          .getTopLeft(find.byKey(const ValueKey('otp-row')))
          .dx;
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('otp-row'))).dx,
        closeTo(initialX - 8, .001),
      );
      await tester.pump(const Duration(milliseconds: 320));
      await tester.enterText(digit(0), '1');
      await tester.pump();
      expect(find.text('Incorrect code. Please try again.'), findsNothing);
      for (int i = 1; i < 6; i++) {
        await tester.enterText(digit(i), '${i + 1}');
        await tester.pump();
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.byType(ContactSheet), findsNothing);
      expect(find.byType(LoginBusyBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 999));
      expect(nav.screen, 'login');
      await tester.pump(const Duration(milliseconds: 1));
      expect(nav.screen, 'welcome-offer');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('resend counts down 30 seconds and preserves entered digits', (
    tester,
  ) async {
    await mount(tester, modal: 'email-otp');
    await tester.enterText(digit(0), '321');
    await tester.pump();
    await tester.pump(const Duration(seconds: 29));
    expect(find.text('Resend code in 1s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Resend code'), findsOneWidget);
    await tester.tap(find.text('Resend code'));
    await tester.pump();
    expect(find.text('Resend code in 30s'), findsOneWidget);
    expect(code(tester), '321');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('footer legal links open exact dialogs and scrim dismisses', (
    tester,
  ) async {
    await mount(tester);
    await tapSpan(tester, 'Terms of Use');
    expect(find.byType(LegalDialog), findsOneWidget);
    expect(
      find.textContaining('By using IshqTalk you agree to be respectful'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pump();
    await tapSpan(tester, 'Privacy Policy');
    expect(
      find.textContaining('This prototype stores nothing on a server.'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(LegalDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unmount cancels pending provider and toast timers', (
    tester,
  ) async {
    final nav = await mount(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(nav.screen, 'login');
    expect(tester.takeException(), isNull);
  });
}
