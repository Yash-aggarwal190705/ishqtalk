import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/live/live_screen.dart';
import 'package:ishqtalk/shared/token_pill.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  LiveState initial = LiveState.gift,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: LiveScreen(initial: initial, portraits: const <String>[]),
  );
}

void main() {
  testWidgets('gift is the default state: one sale badge box, no Free text', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    expect(find.text('60% OFF'), findsOneWidget);
    expect(find.text('7'), findsNothing);
    expect(find.text('Free'), findsNothing);
    nav.dispose();
    app.dispose();
  });

  testWidgets('free state shows two boxes and the Free label', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav, initial: LiveState.free));
    await tester.pump();
    expect(find.text('60% OFF'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('Start enters searching; Cancel returns to the previous state', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Start').first);
    await tester.pump();
    expect(find.text('Finding someone for you'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('60% OFF'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Finding someone for you'), findsNothing);
    expect(find.text('60% OFF'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('token pill plus opens tokens; history opens the history list', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'live');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.byType(TokenPill));
    expect(nav.screen, 'tokens');
    nav.back();
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('History'));
    expect(nav.screen, 'history-list');
    nav.dispose();
    app.dispose();
  });
}
