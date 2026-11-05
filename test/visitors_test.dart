import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/visitors/visitors_screen.dart';
import 'package:ishqtalk/shared/call_button.dart';
import 'package:ishqtalk/shared/spinner.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  bool instant = true,
  bool pinLoading = false,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: VisitorsScreen(instant: instant, pinLoading: pinLoading),
  );
}

void main() {
  testWidgets('shows a spinner while loading, then the rows', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'visitors-list');
    await tester.pumpWidget(_fixture(app, nav, instant: false));
    await tester.pump();
    expect(find.byType(Spinner), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(Spinner), findsNothing);
    expect(find.text('Pinku'), findsOneWidget);
    expect(find.text('Anaya'), findsOneWidget);
    expect(find.text('Zoya'), findsOneWidget);
    expect(find.byType(CallButton), findsNWidgets(3));
    nav.dispose();
    app.dispose();
  });

  testWidgets('row tap opens that user profile', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'visitors-list');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Anaya'));
    expect(nav.screen, 'profile');
    expect(nav.user.name, 'Anaya');
    nav.dispose();
    app.dispose();
  });

  testWidgets(
    'call button opens the call overlay without opening the profile',
    (tester) async {
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'visitors-list');
      await tester.pumpWidget(_fixture(app, nav));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.byType(CallButton).first);
      expect(nav.screen, 'visitors-list');
      expect(nav.callUser, isNotNull);
      nav.dispose();
      app.dispose();
    },
  );
}
