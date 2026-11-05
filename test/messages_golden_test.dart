import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/messages/messages_screen.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);

  testWidgets('messages_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const MessagesScreen(instant: true),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/messages.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });

  testWidgets('messages_loading_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const MessagesScreen(instant: false),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/messages_loading.png'),
    );
    // Let the loading timer fire before teardown.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });

  testWidgets('messages_empty_390 golden', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    for (final int id in <int>[10, 12, 13, 15]) {
      app.block(id);
    }
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: const MessagesScreen(instant: true),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/messages_empty.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });
}
