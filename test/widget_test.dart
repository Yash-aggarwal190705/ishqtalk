import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/app.dart';
import 'package:ishqtalk/screens/onboarding/welcome_offer.dart';
import 'package:ishqtalk/screens/onboarding/splash.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);
  testWidgets(
    'debug picker navigates from Splash to the offer without delayed redirect',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      usePortViewport(tester);
      await tester.pumpWidget(
        MyApp(preferences: preferences, debugScreenPicker: true),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(Splash), findsOneWidget);
      await tester.tap(find.text('Screens'));
      await tester.pump();
      await tester.tap(find.text('welcome-offer — Welcome Offer'));
      await tester.pump();
      expect(find.byType(WelcomeOffer), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(WelcomeOffer), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
