import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/screens/onboarding/login.dart';
import 'package:ishqtalk/screens/onboarding/splash.dart';

import 'support/port_fixture.dart';
import 'support/login_golden_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);
  const cases = <String, Widget>{
    'splash': Splash(),
    'login': Login(instant: true),
    'login_expanded': Login(expanded: true, instant: true),
    'login_google': Login(modal: 'google', instant: true),
    'login_email': Login(modal: 'email', instant: true),
    'login_otp': Login(modal: 'email-otp', instant: true),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} at 390 x 844', (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        PortFixture(
          fontFamilyFallback: loginGoldenFallback,
          child: entry.value,
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(goldenSurface),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
