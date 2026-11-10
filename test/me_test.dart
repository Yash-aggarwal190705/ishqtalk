import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/me/me_screen.dart';
import 'package:ishqtalk/shared/frog_avatar.dart';
import 'package:ishqtalk/shared/lv_chip.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Widget _fixture(AppContextState app, NavigationState navigation) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: const MeScreen(instant: true),
  );
}

void main() {
  testWidgets('renders header, stats, cards and menu rows', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    expect(find.byType(FrogAvatar), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
    expect(find.text('Messages sent'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Profiles viewed'), findsOneWidget);
    expect(find.text('Tokens'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Invite to earn money'), findsOneWidget);
    expect(find.text('Wallet and rewards'), findsOneWidget);
    expect(find.text('Get tokens'), findsOneWidget);
    expect(find.text('Token history'), findsOneWidget);
    expect(find.text('My items'), findsOneWidget);
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('105'), findsOneWidget); // coin balance trail
    expect(find.byType(LvChip), findsOneWidget);
    expect(find.text('Daily Bonus'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('App settings'), findsOneWidget);
    expect(find.text('Package'), findsNothing);
    expect(find.text('My Level'), findsNothing);
    nav.dispose();
    app.dispose();
  });

  testWidgets('edit icon pushes edit profile', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'me');
    usePortViewport(tester);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Edit profile'));
    expect(nav.screen, 'edit-profile');
    nav.dispose();
    app.dispose();
  });

  testWidgets('tokens card and Get tokens row push Get tokens', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'me');
    usePortViewport(tester);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.text('Tokens'));
    expect(nav.screen, 'tokens');
    nav.dispose();
    app.dispose();
  });

  testWidgets('wallet rows push their screens', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'me');
    usePortViewport(tester);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.text('Get tokens'));
    expect(nav.screen, 'tokens');
    await tester.pumpAndSettle();
    nav.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Token history'));
    expect(nav.screen, 'token-history');
    await tester.pumpAndSettle();
    nav.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('My items'));
    expect(nav.screen, 'package-props');
    await tester.pumpAndSettle();
    nav.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Level'));
    expect(nav.screen, 'level');
    nav.dispose();
    app.dispose();
  });

  testWidgets('App settings row pushes settings; VIP card says coming soon', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'me');
    usePortViewport(tester);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.text('App settings'));
    expect(nav.screen, 'settings');
    await tester.pumpAndSettle();
    nav.back();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('card-vip')));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    nav.dispose();
    app.dispose();
  });
}
