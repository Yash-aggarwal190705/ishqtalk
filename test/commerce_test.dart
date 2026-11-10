import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/app.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/app_shell.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/shared/age_chip.dart';
import 'package:ishqtalk/shared/call_button.dart';
import 'package:ishqtalk/shared/token_pill.dart';
import 'package:ishqtalk/features/commerce/widgets.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  Future<void> pumpApp(
    WidgetTester tester, {
    String initialScreen = 'live',
  }) async {
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

  /// The Bonus screen runs periodic countdown timers, so pumpAndSettle never
  /// settles there; use bounded pumps.
  Future<void> pumpFixed(
    WidgetTester tester, [
    Duration d = const Duration(milliseconds: 100),
  ]) async {
    await tester.pump(d);
  }

  group('Visitors', () {
    testWidgets('age chip stretches across the middle column', (tester) async {
      await pumpApp(tester, initialScreen: 'messages');
      await tester.tap(find.text('Profile visitors'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      final Rect chip = tester.getRect(find.byType(AgeChip).first);
      final double listWidth = tester.getSize(find.byType(ListView)).width;
      // Middle column width = list - h-padding(32) - avatar(48) - gap(12)
      // - call button(40).
      final double middleWidth = listWidth - 32 - 48 - 12 - 40;
      expect(chip.width, closeTo(middleWidth, 1));
    });

    testWidgets(
      'call button opens the call sheet without opening the profile',
      (tester) async {
        await pumpApp(tester, initialScreen: 'messages');
        await tester.tap(find.text('Profile visitors'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CallButton).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Video call with'), findsOneWidget);
        await back(tester);
        expect(find.textContaining('Video call with'), findsNothing);
        expect(navOf(tester).screen, 'visitors-list');
      },
    );
  });

  group('Get Tokens', () {
    testWidgets('renders balance, cards and grid; back returns', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byType(TokenPill));
      await tester.pumpAndSettle();
      expect(find.text('Get tokens'), findsOneWidget);
      expect(find.text('105'), findsOneWidget);
      expect(find.text('1 token = ₹1'), findsOneWidget);
      for (final String label in <String>[
        '100 tokens',
        '500 tokens',
        '1,000 tokens',
        '5,000 tokens',
        '8,000 tokens',
        '10,000 tokens',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Choose an amount'), findsOneWidget);
      await back(tester);
      expect(navOf(tester).screen, 'live');
    });

    testWidgets('select card, confirm pay, snackbar; balance unchanged', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byType(TokenPill));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1,000 tokens'));
      await tester.pump();
      expect(find.text('Get 1,000 tokens · ₹1,000'), findsOneWidget);
      expect(find.text('No extra fees. Tokens don’t expire.'), findsOneWidget);
      await tester.tap(find.text('Get 1,000 tokens · ₹1,000'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm purchase'), findsOneWidget);
      expect(find.text('Tokens'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      await tester.tap(find.text('Pay ₹1,000'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm purchase'), findsNothing);
      expect(find.text('Payments arrive after the demo'), findsOneWidget);
      expect(find.text('105'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2500));
    });
  });

  group('Bonus', () {
    testWidgets('loading spinner then content; sign-in adds a match ticket', (
      tester,
    ) async {
      await pumpApp(tester, initialScreen: 'me');
      await tester.tap(find.text('Daily Bonus'));
      // The pushed route starts offstage during its transition.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LoadingSpinner, skipOffstage: false), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      await pumpFixed(tester);
      expect(find.text('Sign in rewards'), findsOneWidget);
      expect(find.text('VIP Bonus'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Profile Verification'), findsOneWidget);
      expect(find.text('( 0/1 )'), findsNWidgets(7));

      await tester.tap(find.text('Sign in'));
      await pumpFixed(tester);
      expect(find.text('Signed in today'), findsOneWidget);
      expect(find.text('+1 Match Ticket'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1900));
      await pumpFixed(tester);
      expect(find.text('+1 Match Ticket'), findsNothing);
      // tickets header: chat 1 + match 2 -> 3 = 4
      expect(find.text('4'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Go on "Have friends" switches to Explore', (tester) async {
      await pumpApp(tester, initialScreen: 'me');
      await tester.tap(find.text('Daily Bonus'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 800));
      await pumpFixed(tester);
      // First "Go" is Profile Verification (no action); the second one is
      // "Have (0/10) friends" -> Explore tab.
      await tester.tap(find.text('Go').at(1));
      await tester.pumpAndSettle();
      expect(navOf(tester).screen, 'explore');
    });
  });

  group('My items', () {
    testWidgets('passes list, item sheet, gifts tab; back returns', (
      tester,
    ) async {
      await pumpApp(tester);
      navOf(tester).push('package-props');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      expect(find.text('Passes'), findsOneWidget);
      expect(find.text('Gifts'), findsOneWidget);
      expect(find.text('Match pass × 2'), findsOneWidget);
      expect(find.text('Chat pass × 1'), findsOneWidget);
      expect(find.text('Active'), findsNWidgets(2));

      await tester.tap(find.text('Match pass × 2'));
      await tester.pumpAndSettle();
      expect(
        find.text('Skip the wait and start a video match right away.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Use now'));
      await tester.pumpAndSettle();
      expect(find.text('Use now'), findsNothing);
      expect(navOf(tester).screen, 'live');

      // Re-open to test the Gifts tab (after Use now we are on Live).
      navOf(tester).push('package-props');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gifts'));
      await tester.pumpAndSettle();
      expect(find.text('No gifts yet'), findsOneWidget);

      await back(tester);
      expect(navOf(tester).screen, 'live');
    });

    testWidgets('expired items opens from the header and back returns', (
      tester,
    ) async {
      await pumpApp(tester);
      navOf(tester).push('package-props');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Expired items'));
      await tester.pumpAndSettle();
      expect(navOf(tester).screen, 'expired-items');
      expect(find.text('Expired'), findsNWidgets(6));
      await back(tester);
      expect(navOf(tester).screen, 'package-props');
    });
  });
}
