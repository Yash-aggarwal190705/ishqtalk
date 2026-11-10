import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/app.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/app_shell.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/explore/explore_screen.dart';
import 'package:ishqtalk/screens/explore/widgets/user_card.dart';
import 'package:ishqtalk/screens/profile/user_profile_screen.dart';
import 'package:ishqtalk/screens/visitors/visitors_screen.dart';
import 'package:ishqtalk/shared/token_pill.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  late List<MethodCall> systemPops;

  setUp(() {
    systemPops = <MethodCall>[];
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemNavigator.pop') systemPops.add(call);
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    String initialScreen = 'live',
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    usePortViewport(tester);
    await tester.pumpWidget(
      // Freeze the Live sky's infinite loops so pumpAndSettle can settle.
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
    // Let seeded data (Explore 900 ms, Messages 600 ms) finish loading.
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

  void expectNoExit() => expect(systemPops, isEmpty);

  group('back navigation', () {
    testWidgets('Explore -> Profile -> back -> Explore (state kept)', (
      tester,
    ) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsOneWidget);
      await back(tester);
      expect(find.byType(UserProfileScreen), findsNothing);
      expect(find.byType(ExploreScreen), findsOneWidget);
      expect(navOf(tester).screen, 'explore');
      expectNoExit();
    });

    testWidgets(
      'Explore -> Profile -> Message -> Conversation and back all the way',
      (tester) async {
        await pumpApp(tester, initialScreen: 'explore');
        await tester.tap(find.byType(UserCard).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Message'));
        await tester.pumpAndSettle();
        expect(navOf(tester).screen, 'chat');
        await back(tester);
        expect(find.byType(UserProfileScreen), findsOneWidget);
        await back(tester);
        expect(find.byType(ExploreScreen), findsOneWidget);
        expectNoExit();
      },
    );

    testWidgets('call sheet on a pushed screen closes before the screen', (
      tester,
    ) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('35')); // call bar
      await tester.pumpAndSettle();
      expect(find.textContaining('Video call with'), findsOneWidget);
      await back(tester);
      expect(find.textContaining('Video call with'), findsNothing);
      expect(find.byType(UserProfileScreen), findsOneWidget);
      expectNoExit();
    });

    testWidgets('Messages -> Visitors -> Profile and back', (tester) async {
      await pumpApp(tester, initialScreen: 'messages');
      await tester.tap(find.text('Profile visitors'));
      await tester.pumpAndSettle();
      expect(find.byType(VisitorsScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900)); // visitors repo load
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anaya'));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsOneWidget);
      await back(tester);
      expect(find.byType(VisitorsScreen), findsOneWidget);
      await back(tester);
      expect(find.byType(VisitorsScreen), findsNothing);
      expect(navOf(tester).screen, 'messages');
      expectNoExit();
    });

    testWidgets('Live -> Tokens -> back -> Live -> back exits once', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byType(TokenPill));
      await tester.pumpAndSettle();
      expect(navOf(tester).screen, 'tokens');
      await back(tester);
      expect(navOf(tester).screen, 'live');
      expectNoExit();
      await back(tester);
      expect(systemPops.length, 1);
    });

    testWidgets('Me -> App Settings -> back -> Me', (tester) async {
      await pumpApp(tester, initialScreen: 'me');
      await tester.scrollUntilVisible(
        find.text('App settings'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('App settings'));
      await tester.pumpAndSettle();
      expect(navOf(tester).screen, 'settings');
      await back(tester);
      expect(navOf(tester).screen, 'me');
      expectNoExit();
    });

    testWidgets('Explore search closes on back before leaving the tab', (
      tester,
    ) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await back(tester);
      expect(find.byType(TextField), findsNothing);
      expect(navOf(tester).screen, 'explore');
      expectNoExit();
      await back(tester); // Explore -> Live
      expect(navOf(tester).screen, 'live');
      await back(tester); // Live exits
      expect(systemPops.length, 1);
    });

    testWidgets('Me edit sheet closes on back first', (tester) async {
      await pumpApp(tester, initialScreen: 'me');
      await tester.tap(find.bySemanticsLabel('Edit profile'));
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsOneWidget);
      await back(tester);
      expect(find.text('Edit profile'), findsNothing);
      expect(navOf(tester).screen, 'me');
      expectNoExit();
    });

    testWidgets('tab switch clears pushed screens', (tester) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsOneWidget);
      // Switching tabs pops any pushed routes above the shell (rule 6).
      navOf(tester).tab('live');
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsNothing);
      expect(navOf(tester).screen, 'live');
      await back(tester);
      expect(systemPops.length, 1);
    });

    testWidgets('onboarding replaces history: Live back exits, never Login', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'yourapp.hasOnboarded': '1'});
      final preferences = await SharedPreferences.getInstance();
      usePortViewport(tester);
      await tester.pumpWidget(
        MotionScope(
          freezeLoops: true,
          child: MyApp(preferences: preferences, debugScreenPicker: false),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      expect(navOf(tester).screen, 'live');
      await tester.pump(const Duration(milliseconds: 1100)); // flush tab load timers
      await tester.pumpAndSettle();
      await back(tester);
      expect(systemPops.length, 1);
      expect(navOf(tester).screen, 'live');
    });

    testWidgets('in-app back arrow behaves like system back', (tester) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsNothing);
      expect(navOf(tester).screen, 'explore');
      expectNoExit();
    });

    testWidgets('blocking a user pops the profile once', (tester) async {
      await pumpApp(tester, initialScreen: 'explore');
      await tester.tap(find.byType(UserCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsNothing);
      expect(navOf(tester).screen, 'explore');
      expectNoExit();
    });
  });
}
