import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/messages/messages_screen.dart';
import 'package:ishqtalk/shared/badge.dart' as badge;
import 'package:ishqtalk/shared/empty_state.dart';
import 'package:ishqtalk/shared/offline_banner.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/port_fixture.dart';

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  bool instant = true,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: MessagesScreen(instant: instant),
  );
}

void main() {
  testWidgets('loading shows three skeleton rows and hides conversations', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav, instant: false));
    await tester.pump();
    expect(find.byType(Shimmer), findsWidgets);
    expect(find.text('Camila 💕😍'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(Shimmer), findsNothing);
    expect(find.text('Camila 💕😍'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('seed conversations render sorted newest first', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    const List<String> expected = <String>[
      '😍 Hot Queen 😍',
      'Kiara ❤️',
      'Camila 💕😍',
      'Pinku',
    ];
    final List<double> positions = <double>[];
    for (final String name in expected) {
      positions.add(tester.getTopLeft(find.text(name)).dy);
    }
    for (int i = 1; i < positions.length; i++) {
      expect(positions[i], greaterThan(positions[i - 1]));
    }
    // 3 conversation badges + Visitors + Notifications.
    expect(find.byType(badge.Badge), findsNWidgets(5));
    nav.dispose();
    app.dispose();
  });

  testWidgets('unread rows use bold name, ink preview and badge', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    final Text camilaName = tester
        .widgetList<Text>(find.text('Camila 💕😍'))
        .first;
    expect(camilaName.style?.fontWeight, FontWeight.w700);
    final Text camilaPreview = tester.widget<Text>(
      find.text('Hola amor, cómo estás ?'),
    );
    expect(camilaPreview.style?.fontWeight, FontWeight.w500);
    final Text pinkuPreview = tester.widget<Text>(find.text('chat'));
    expect(pinkuPreview.style?.fontWeight, FontWeight.w400);
    nav.dispose();
    app.dispose();
  });

  testWidgets('online users get a dot; away/unavailable do not', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    final Iterable<Element> dots = find
        .byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  const Color(0xFF3CC76A),
        )
        .evaluate();
    expect(dots.length, 2);
    nav.dispose();
    app.dispose();
  });

  testWidgets('a message from me renders with the You: prefix', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    // Pinku (id 12) has no unread; send a message from 'me'.
    app.send(12, 'hola');
    await tester.pump();
    expect(find.text('You: hola'), findsOneWidget);
    await tester.pumpAndSettle();
    nav.dispose();
    app.dispose();
  });

  testWidgets('tapping a conversation opens it and marks it read', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'messages');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.text('Camila 💕😍'));
    expect(nav.screen, 'chat');
    expect(nav.chatId, 10);
    expect(app.convos[10]!.unread, 0);
    nav.dispose();
    app.dispose();
  });

  testWidgets('empty state offers Explore people and switches tabs', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'messages');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    for (final int id in <int>[10, 12, 13, 15]) {
      app.block(id);
    }
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No conversations yet'), findsOneWidget);
    await tester.tap(find.text('Explore people'));
    expect(nav.screen, 'explore');
    nav.dispose();
    app.dispose();
  });

  testWidgets('offline banner appears above saved conversations', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    app.setOffline(true);
    await tester.pump();
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(
      find.text("You're offline. Showing saved conversations."),
      findsOneWidget,
    );
    expect(find.text('Camila 💕😍'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('bell in the header opens Notifications', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'messages');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('header-bell')));
    expect(nav.screen, 'notifications');
    nav.dispose();
    app.dispose();
  });

  testWidgets('Conversation and Message models match the seeded store', (
    tester,
  ) async {
    final app = AppContextState();
    final Conversation convo = app.convos[10]!;
    expect(convo.user.name, 'Camila 💕😍');
    expect(convo.user.avail, 'online');
    expect(convo.unread, 1);
    expect(convo.date, '10-24');
    final Message last = convo.messages.last;
    expect(last.from, 'them');
    expect(last.text, 'Hola amor, cómo estás ?');
    expect(last.state, MessageState.sent);
    expect(last.time, '10:24');
    app.dispose();
  });
}
