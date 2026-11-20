import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/features/auth/data/local_auth_repository.dart';
import 'package:ishqtalk/features/auth/presentation/auth_state.dart';
import 'package:ishqtalk/screens/onboarding/login.dart';
import 'package:ishqtalk/screens/onboarding/login_form_layout.dart';
import 'package:ishqtalk/screens/onboarding/login_primary_button.dart';
import 'package:ishqtalk/screens/onboarding/login_text_field.dart';
import 'package:ishqtalk/screens/onboarding/otp_step.dart';
import 'package:ishqtalk/screens/onboarding/country_code_picker.dart';

import 'support/port_fixture.dart';
import 'support/login_golden_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);
  for (final modal in ['email', 'phone', 'email-otp']) {
    testWidgets(
      '$modal keeps inputs and actions above a 300px keyboard at 320x568',
      (tester) async {
        usePortViewport(tester, size: const Size(320, 568));
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          PortFixture(
            fontFamilyFallback: loginGoldenFallback,
            auth: AuthState(repository: LocalAuthRepository()),
            child: Login(modal: modal, instant: true),
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 10));
        final double originalActionY = tester
            .getTopLeft(find.byType(LoginPrimaryButton))
            .dy;
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle(const Duration(milliseconds: 10));
        expect(tester.takeException(), isNull);
        final action = find.byType(LoginPrimaryButton);
        expect(tester.getBottomRight(action).dy, lessThanOrEqualTo(268));
        expect(action.hitTestable(), findsOneWidget);
        final active = find.byWidgetPredicate(
          (widget) => widget is LoginTextField && widget.focusNode.hasFocus,
        );
        expect(active, findsOneWidget);
        final inputRect = tester.getRect(active);
        final viewport = find.descendant(
          of: find.byType(LoginFormLayout),
          matching: find.byType(SingleChildScrollView),
        );
        final viewportRect = tester.getRect(viewport);
        expect(inputRect.top, greaterThanOrEqualTo(viewportRect.top - .01));
        expect(inputRect.bottom, lessThanOrEqualTo(viewportRect.bottom + .01));
        expect(active.hitTestable(), findsOneWidget);
        await expectLater(
          find.byKey(goldenSurface),
          matchesGoldenFile(
            'goldens/login_${modal.replaceAll('-', '_')}_keyboard.png',
          ),
        );

        tester.view.viewInsets = const FakeViewPadding();
        await tester.pumpAndSettle(const Duration(milliseconds: 10));
        expect(tester.getTopLeft(action).dy, closeTo(originalActionY, .01));
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle(const Duration(milliseconds: 10));

        if (modal == 'phone') {
          await tester.tap(find.text('+91'));
          await tester.pumpAndSettle(const Duration(milliseconds: 10));
          final countriesScroll = find.descendant(
            of: find.byType(CountryCodePicker),
            matching: find.byType(SingleChildScrollView),
          );
          await tester.drag(countriesScroll, const Offset(0, -240));
          await tester.pumpAndSettle(const Duration(milliseconds: 10));
          await tester.tap(find.text('United Arab Emirates'));
          await tester.pumpAndSettle(const Duration(milliseconds: 10));
          expect(find.byType(CountryCodePicker), findsNothing);
          expect(find.text('+971'), findsOneWidget);
        }

        if (modal != 'email-otp') {
          await tester.enterText(
            find.byType(TextField),
            modal == 'email' ? 'alex@example.com' : '9876543210',
          );
          await tester.pump();
          await tester.tap(find.text('Send code'));
          await tester.pumpAndSettle(const Duration(milliseconds: 10));
          expect(find.byType(OtpStep), findsOneWidget);
          expect(find.text('Verify').hitTestable(), findsOneWidget);
          expect(
            tester.getBottomRight(find.byType(LoginPrimaryButton)).dy,
            lessThanOrEqualTo(268),
          );
          expect(tester.takeException(), isNull);
          final focusedOtp = find.byWidgetPredicate(
            (widget) => widget is LoginTextField && widget.focusNode.hasFocus,
          );
          final otpViewport = tester.getRect(
            find.descendant(
              of: find.byType(LoginFormLayout),
              matching: find.byType(SingleChildScrollView),
            ),
          );
          expect(
            tester.getRect(focusedOtp).top,
            greaterThanOrEqualTo(otpViewport.top - .01),
          );
          expect(
            tester.getRect(focusedOtp).bottom,
            lessThanOrEqualTo(otpViewport.bottom + .01),
          );
        }
        tester.view.viewInsets = const FakeViewPadding();
        await tester.pumpAndSettle(const Duration(milliseconds: 10));
        if (modal == 'email-otp') {
          expect(tester.getTopLeft(action).dy, closeTo(originalActionY, .01));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
