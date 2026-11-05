import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/profile/safety_flow.dart';
import 'package:ishqtalk/screens/profile/user_profile_screen.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/port_fixture.dart';

AppUser _user() => users.first; // Ragini, online, Music topic.

Widget _fixture(AppContextState app, NavigationState navigation) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: UserProfileScreen(user: _user(), instant: true),
  );
}

void main() {
  testWidgets('renders identity, stats and call bar', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Ragini'), findsOneWidget);
    expect(find.text('Online now'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Fans'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('2695'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('35'), findsOneWidget);
    expect(find.text('/min'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('entering reports a profile visit', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(
      PortFixture(
        app: app,
        navigation: nav,
        child: UserProfileScreen(user: _user()),
      ),
    );
    await tester.pump();
    expect(app.visited.contains(users.first.id), isTrue);
    await tester.pump(const Duration(milliseconds: 900)); // drain repo delay
    nav.dispose();
    app.dispose();
  });

  testWidgets('Follow toggles and updates its label', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    Future<void> tapButton(String label) async {
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == label && w.style?.fontSize == 14,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tapButton('Follow');
    expect(find.text('Following'), findsNWidgets(2)); // stats label + button
    expect(app.following.contains(users.first.id), isTrue);
    await tapButton('Following');
    expect(app.following.contains(users.first.id), isFalse);
    nav.dispose();
    app.dispose();
  });

  testWidgets('Message opens the conversation', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'profile');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Message'));
    expect(nav.screen, 'chat');
    expect(nav.chatId, users.first.id);
    nav.dispose();
    app.dispose();
  });

  testWidgets('call bar opens the calling sheet overlay', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'profile');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('35'));
    expect(nav.callUser?.id, users.first.id);
    nav.dispose();
    app.dispose();
  });

  testWidgets('unavailable user shows a disabled call bar', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'profile');
    final AppUser unavailable = users[9]; // mannat kaur
    await tester.pumpWidget(
      PortFixture(
        app: app,
        navigation: nav,
        child: UserProfileScreen(user: unavailable, instant: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Unavailable right now'), findsOneWidget);
    await tester.tap(find.text('Unavailable right now'));
    expect(nav.callUser, isNull);
    nav.dispose();
    app.dispose();
  });

  testWidgets('block via safety menu removes the user and pops back', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'profile');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Report'), findsOneWidget);
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(find.text('Block Ragini?'), findsOneWidget);
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(app.blocked.contains(users.first.id), isTrue);
    expect(app.convos.containsKey(users.first.id), isFalse);
    expect(nav.screen, 'live'); // popped back with an empty stack
    nav.dispose();
    app.dispose();
  });

  testWidgets('report flow reaches the acknowledgement screen', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'profile');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Report Ragini'), findsOneWidget);
    expect(find.text('Spam or scam'), findsOneWidget);
    await tester.tap(find.text('Spam or scam'));
    await tester.pumpAndSettle();
    expect(
      find.text('Thanks. Your report was recorded in this local preview.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(SafetyFlow), findsNothing);
    nav.dispose();
    app.dispose();
  });
}
