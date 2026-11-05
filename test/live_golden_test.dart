import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/live/live_screen.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);
  const cases = <String, (Size, String, LiveState)>{
    'live_gift_390': (Size(390, 844), 'live_gift.png', LiveState.gift),
    'live_free_390': (Size(390, 844), 'live_free.png', LiveState.free),
    'live_searching_390': (
      Size(390, 844),
      'live_searching.png',
      LiveState.searching,
    ),
    'live_gift_480': (Size(480, 960), 'live_gift_480.png', LiveState.gift),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} golden', (tester) async {
      final AppContextState app = AppContextState();
      final NavigationState navigation = NavigationState(app: app);
      usePortViewport(tester, size: entry.value.$1);
      await tester.pumpWidget(
        PortFixture(
          fontFamilyFallback: loginGoldenFallback,
          app: app,
          navigation: navigation,
          child: LiveScreen(
            initial: entry.value.$3,
            portraits: const <String>[],
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(goldenSurface),
        matchesGoldenFile('goldens/${entry.value.$2}'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      navigation.dispose();
      app.dispose();
    });
  }
}
