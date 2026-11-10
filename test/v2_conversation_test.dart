import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/app.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/app_shell.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/chat/conversation_screen.dart';
import 'package:ishqtalk/screens/messages/messages_screen.dart';
import 'package:ishqtalk/shared/portrait.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  Future<void> pumpApp(WidgetTester tester, {String initialScreen = 'live'}) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    usePortViewport(tester);
    await tester.pumpWidget(
      MotionScope(
        freezeLoops: true,
        child: MyApp(
          preferences: preferences,
          debugScreenPicker: false,
          initialScreen: initialScreen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
  }

  NavigationState navOf(WidgetTester tester) => tester
      .element(find.byType(AppShell, skipOffstage: false))
      .read<NavigationState>();

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> openTara(WidgetTester tester) async {
    await pumpApp(tester, initialScreen: 'messages');
    await tester.tap(find.text('Tara'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);
  }

  testWidgets('Tara thread: timestamp, avatars, photo 104x188', (tester) async {
    await openTara(tester);
    expect(find.text('10:20'), findsOneWidget);
    expect(find.text('welcome to my profile, call me for talking'), findsOneWidget);
    expect(find.text('That story circle was so fun 😄'), findsOneWidget);
    // Photo message renders as a 104x188 Portrait.
    final Rect photo = tester.getRect(
      find.byWidgetPredicate(
        (w) => w is Portrait && w.seed == 3 && w.width == 104,
      ),
    );
    expect(photo.width, 104);
    expect(photo.height, 188);
    // Avatar 40x40 at x=16 (first Portrait in the list, seed 0, no size args).
    final Rect avatar = tester.getRect(
      find.byWidgetPredicate(
        (w) => w is Portrait && w.seed == 0 && w.width == null,
      ).first,
    );
    expect(avatar.left, 16);
    expect(avatar.width, 40);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sending hi: Sending… then Saved locally; row date Today',
      (tester) async {
    await openTara(tester);
    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send'));
    await tester.pump();
    expect(find.text('· Sending…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('· Saved locally'), findsOneWidget);
    // Messages row now lists Tara first with Today.
    await back(tester);
    expect(find.text('Tara'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('offline: Not sent + Retry; retry while offline stays failed',
      (tester) async {
    await pumpApp(tester, initialScreen: 'messages');
    final AppContextState app = navOf(tester).app;
    app.setOffline(true);
    await tester.pump();
    await tester.tap(find.text('Tara'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send').first, warnIfMissed: true);
    await tester.pump();
    expect(find.text('· Not sent'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('· Not sent'), findsOneWidget);
    // Come back online + retry -> pending then sent.
    app.setOffline(false);
    await tester.pump();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('· Sending…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('· Saved locally'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('send button disabled for whitespace; counter over 400',
      (tester) async {
    await openTara(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    // Disabled: opacity .4 on the send button wrapper.
    final Opacity sendOpacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.bySemanticsLabel('Send'),
        matching: find.byType(Opacity),
      ).first,
    );
    expect(sendOpacity.opacity, .4);
    await tester.enterText(find.byType(TextField), 'a' * 401);
    await tester.pump();
    expect(find.text('401/500'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unavailable user (Dev) hides the composer and shows the note',
      (tester) async {
    await pumpApp(tester, initialScreen: 'messages');
    await tester.tap(find.text('Dev'));
    await tester.pumpAndSettle();
    expect(find.text('Dev is unavailable right now. You can still read past messages.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.bySemanticsLabel('Send'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('safety menu: Report/Block/Conversation details disabled; Block pops back',
      (tester) async {
    await openTara(tester);
    await tester.tap(find.bySemanticsLabel('Conversation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
    expect(find.text('Conversation details'), findsOneWidget);
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(find.text('Block Tara?'), findsOneWidget);
    // System back closes only the dialog.
    await back(tester);
    expect(find.text('Block Tara?'), findsNothing);
    expect(find.byType(ConversationScreen), findsOneWidget);
    // Reopen and confirm block -> screen pops back to Messages.
    await tester.tap(find.bySemanticsLabel('Conversation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsNothing);
    expect(find.text('Tara'), findsNothing);
    expect(find.byType(MessagesScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
