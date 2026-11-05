import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/me/me_screen.dart';
import 'package:ishqtalk/screens/profile/user_profile_screen.dart';
import 'package:ishqtalk/screens/visitors/visitors_screen.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);

  testWidgets('me_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const MeScreen(instant: true),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/me.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });

  testWidgets('profile_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: UserProfileScreen(user: users.first, instant: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/profile.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });

  testWidgets('visitors_loading_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const VisitorsScreen(instant: false),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/visitors_loading.png'),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });

  testWidgets('visitors_list_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const VisitorsScreen(instant: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/visitors_list.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });
}
