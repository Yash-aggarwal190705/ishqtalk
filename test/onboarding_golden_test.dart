import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/screens/onboarding/welcome_offer.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);
  const cases = <String, WelcomeOffer>{
    'welcome_offer': WelcomeOffer(
      instant: true,
      testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
    ),
    'notif_prompt': WelcomeOffer(
      forceNotif: true,
      instant: true,
      testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
    ),
    'payment_sheet': WelcomeOffer(
      forcePay: true,
      instant: true,
      testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
    ),
    'welcome_tooltip': WelcomeOffer(
      instant: true,
      testOverrides: WelcomeOfferTestOverrides(
        disableTimers: true,
        suppressNotificationPrompt: true,
        tooltipVisible: true,
      ),
    ),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} at 390 x 844', (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(PortFixture(child: entry.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(goldenSurface),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    });
  }
}
