import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/explore/explore_screen.dart';
import 'package:ishqtalk/screens/explore/user_repository.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);
  const cases = <String, (Size, String)>{
    'explore': (Size(390, 844), 'explore.png'),
    'explore_360': (Size(360, 800), 'explore_360.png'),
    'explore_480': (Size(480, 960), 'explore_480.png'),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} at 390 x 844 style', (tester) async {
      final AppContextState app = AppContextState();
      final NavigationState navigation = NavigationState(app: app);
      usePortViewport(tester, size: entry.value.$1);
      await tester.pumpWidget(
        PortFixture(
          fontFamilyFallback: loginGoldenFallback,
          app: app,
          navigation: navigation,
          child: const ExploreScreen(
            repository: SeedUserRepository(delay: Duration.zero),
            instant: true,
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
