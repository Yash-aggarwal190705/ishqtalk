import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/app.dart';
import 'package:ishqtalk/foundation/app_icons.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/foundation/app_theme.dart';
import 'package:ishqtalk/navigation/app_shell.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/messages/messages_screen.dart';
import 'package:ishqtalk/shared/offline_banner.dart';
import 'package:ishqtalk/shared/v2.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/port_fixture.dart';

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  bool instant = true,
  bool forceEmpty = false,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: MessagesScreen(instant: instant, forceEmpty: forceEmpty),
  );
}

Future<void> _pump(
  WidgetTester tester,
  AppContextState app,
  NavigationState navigation, {
  bool instant = true,
  bool forceEmpty = false,
}) async {
  usePortViewport(tester);
  await tester.pumpWidget(
    _fixture(app, navigation, instant: instant, forceEmpty: forceEmpty),
  );
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  testWidgets('loading shows 6 skeleton rows then conversations', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav, instant: false);
    await tester.pump();
    expect(find.byType(ShimmerBox), findsWidgets);
    expect(find.text('Tara'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(ShimmerBox), findsNothing);
    expect(find.text('Tara'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('rows are ordered by ts desc with unread badges and LIVE tags', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();

    const List<String> order = <String>[
      'Tara',
      'Kabir',
      'Isha',
      'Anaya',
      'Dev',
      'Aarav',
    ];
    final List<double> ys = <double>[];
    for (final String name in order) {
      ys.add(tester.getTopLeft(find.text(name)).dy);
    }
    for (int i = 1; i < ys.length; i++) {
      expect(ys[i], greaterThan(ys[i - 1]));
    }
    expect(find.text('LIVE'), findsNWidgets(3));
    expect(app.unread, 3);
    nav.dispose();
    app.dispose();
  });

  testWidgets('unread rows use w600 name and ink w500 preview', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();

    final Text tara = tester.widget<Text>(find.text('Tara'));
    expect(tara.style?.fontWeight, FontWeight.w600);
    final Text taraPrev = tester.widget<Text>(
      find.text('That story circle was so fun 😄'),
    );
    expect(taraPrev.style?.fontWeight, FontWeight.w500);
    expect(taraPrev.style?.color, AppColors.ink);

    final Text anaya = tester.widget<Text>(find.text('Anaya'));
    expect(anaya.style?.fontWeight, FontWeight.w500);
    final Text anayaPrev = tester.widget<Text>(
      find.text('Thanks for saying hi'),
    );
    expect(anayaPrev.style?.fontWeight, FontWeight.w400);
    nav.dispose();
    app.dispose();
  });

  testWidgets('live rows show the LIVE tag; non-live do not', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    // Tara, Isha, Aarav are online; Kabir/Anaya/Dev are not.
    expect(find.text('LIVE'), findsNWidgets(3));
    nav.dispose();
    app.dispose();
  });

  testWidgets('a message from me renders with the You: prefix', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    app.send(12, 'hola'); // Kabir
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
    await _pump(tester, app, nav);
    await tester.pump();
    await tester.tap(find.text('Tara'));
    expect(nav.screen, 'chat');
    expect(nav.chatId, 10);
    expect(app.convos[10]!.unread, 0);
    nav.dispose();
    app.dispose();
  });

  testWidgets('more sheet: mark all read clears badges + snackbar', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pumpAndSettle();
    expect(find.text('Messages options'), findsOneWidget);
    await tester.tap(find.text('Mark all as read'));
    await tester.pumpAndSettle();
    expect(app.unread, 0);
    expect(find.text('All messages marked as read'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    expect(find.text('All messages marked as read'), findsNothing);
    nav.dispose();
    app.dispose();
  });

  testWidgets('clear confirm dialog clears list and shows empty state', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear message list'));
    await tester.pumpAndSettle();
    expect(find.text('Clear your message list?'), findsOneWidget);
    final Rect dialog = tester.getRect(
      find.byKey(const ValueKey('clear-dialog')),
    );
    expect(dialog.width, closeTo(390 - 48, 2));
    await tester.tap(find.text('Clear list'));
    await tester.pumpAndSettle();
    expect(app.convos, isEmpty);
    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.text('Message list cleared'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    nav.dispose();
    app.dispose();
  });

  testWidgets('empty state Find a room switches to Live', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'messages');
    await _pump(tester, app, nav, forceEmpty: true);
    await tester.pump();
    expect(find.text('No messages yet'), findsOneWidget);
    await tester.tap(find.text('Find a room'));
    await tester.pumpAndSettle();
    expect(nav.screen, 'live');
    nav.dispose();
    app.dispose();
  });

  testWidgets('offline banner appears above saved conversations', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    app.setOffline(true);
    await tester.pump();
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(
      find.text("You're offline. Showing saved conversations."),
      findsOneWidget,
    );
    expect(find.text('Tara'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('long-press opens the row menu; Mute then shows Unmute', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await _pump(tester, app, nav);
    await tester.pump();
    await tester.longPress(find.text('Kabir'));
    await tester.pumpAndSettle();
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(find.text('Muted Kabir'), findsOneWidget);
    expect(find.byType(AppIcon), findsWidgets); // BellOff after the name
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.longPress(find.text('Kabir'));
    await tester.pumpAndSettle();
    expect(find.text('Unmute'), findsOneWidget);
    await tester.tap(find.text('Unmute'));
    await tester.pumpAndSettle();
    nav.dispose();
    app.dispose();
  });

  testWidgets('system back: dialog closes first, then back goes to Live', (
    tester,
  ) async {
    // Requires the shell (tab-level PopScope routes back to Live), so pump
    // the real app at the Messages tab.
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    usePortViewport(tester);
    await tester.pumpWidget(
      MotionScope(
        freezeLoops: true,
        child: MyApp(
          preferences: preferences,
          debugScreenPicker: false,
          initialScreen: 'messages',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    final NavigationState nav = tester
        .element(find.byType(AppShell, skipOffstage: false))
        .read<NavigationState>();
    expect(nav.screen, 'messages');

    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear message list'));
    await tester.pumpAndSettle();
    await _back(tester);
    expect(find.text('Clear your message list?'), findsNothing);
    expect(nav.screen, 'messages');
    await _back(tester);
    expect(nav.screen, 'live');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Conversation and Message models match the v2 seed', (
    tester,
  ) async {
    final app = AppContextState();
    final Conversation tara = app.convos[10]!;
    expect(tara.user.name, 'Tara');
    expect(tara.user.avail, 'online');
    expect(tara.unread, 1);
    expect(tara.date, '10:24');
    expect(tara.timestamp, 6);
    expect(tara.messages.length, 3);
    expect(tara.messages[1].photo, 3);
    final Message last = tara.messages.last;
    expect(last.from, 'them');
    expect(last.text, 'That story circle was so fun 😄');
    expect(last.state, MessageState.sent);
    expect(last.time, '10:24');
    expect(app.unread, 3);
    app.dispose();
  });

  testWidgets(
    'numeric checks: rows 72, avatar 56 at x16, text at x84, LIVE tag',
    (tester) async {
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await _pump(tester, app, nav);
      await tester.pump();

      final Rect taraRow = tester.getRect(find.byKey(const ValueKey('row-10')));
      expect(taraRow.height, 72);
      final Rect taraAvatar = tester.getRect(
        find.byKey(const ValueKey('avatar-10')),
      );
      expect(taraAvatar.width, 56);
      expect(taraAvatar.height, 56);
      expect(taraAvatar.left, 16); // left edge of the avatar
      final Rect taraText = tester.getRect(
        find.byKey(const ValueKey('text-10')),
      );
      expect(taraText.left, closeTo(84, 1)); // 16 + 56 + 12

      // LIVE tag right edge is 4 beyond the avatar's right edge.
      final Rect live = tester.getRect(find.byKey(const ValueKey('live-10')));
      expect(live.right, closeTo(taraAvatar.right + 4, 1));

      // Header: three icon buttons are 48×48.
      for (final String label in <String>['Call history', 'Help', 'More']) {
        final Finder btn = find.bySemanticsLabel(label);
        expect(btn, findsOneWidget);
        final Size size = tester.getSize(btn.first);
        expect(size.width, 48);
        expect(size.height, 48);
      }
      nav.dispose();
      app.dispose();
    },
  );
}
