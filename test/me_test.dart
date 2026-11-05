import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/me/me_screen.dart';
import 'package:ishqtalk/shared/frog_avatar.dart';
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
    expect(find.text('Daily Bonus'), findsOneWidget);
    expect(find.text('Package'), findsOneWidget);
    expect(find.text('My Level'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('App Settings'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('edit sheet validates and saves the trimmed name', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Please enter a name.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    expect(find.text('Use at least 2 characters.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Anna  ');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    expect(app.profileName, 'Anna');
    expect(find.text('Anna'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('tokens card pushes Get Tokens', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'me');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.text('Tokens'));
    expect(nav.screen, 'tokens');
    nav.dispose();
    app.dispose();
  });
}
