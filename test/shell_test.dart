import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/app_shell.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/explore/explore_screen.dart';
import 'package:ishqtalk/screens/live/live_screen.dart';
import 'package:ishqtalk/screens/messages/messages_screen.dart';
import 'package:ishqtalk/screens/onboarding/splash.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/onboarding_state.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);
  for (final (onboarded, hasProfile, expected) in [
    (false, false, 'login'),
    (true, false, 'live'),
    (false, true, 'live'),
  ]) {
    testWidgets(
      'splash routes to $expected at 800ms (onboarded=$onboarded, profile=$hasProfile)',
      (tester) async {
        usePortViewport(tester);
        final app = AppContextState();
        if (hasProfile) app.saveProfile('Demo User');
        final state = OnboardingState();
        if (onboarded) state.setOnboarded();
        final nav = NavigationState(app: app);
        await tester.pumpWidget(
          PortFixture(
            app: app,
            onboarding: state,
            navigation: nav,
            child: const AppShell(),
          ),
        );
        expect(find.byType(Splash), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 799));
        expect(nav.screen, 'splash');
        await tester.pump(const Duration(milliseconds: 1));
        expect(nav.screen, expected);
        if (expected == 'live') {
          expect(find.byType(LiveScreen), findsOneWidget);
        } else {
          expect(find.byType(Splash), findsNothing);
        }
        await tester.pump(const Duration(milliseconds: 1100)); // flush tab load timers
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        nav.dispose();
        state.dispose();
        app.dispose();
      },
    );
  }

  testWidgets(
    'tab switching keeps all tabs alive and hides the inactive ones',
    (tester) async {
      usePortViewport(tester, size: const Size(800, 844));
      final app = AppContextState();
      final state = OnboardingState();
      final nav = NavigationState(app: app, screen: 'explore');
      await tester.pumpWidget(
        PortFixture(
          app: app,
          onboarding: state,
          navigation: nav,
          child: const AppShell(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1100)); // flush tab load timers
      await tester.pumpAndSettle();
      expect(find.byType(ExploreScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(LiveScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(MessagesScreen, skipOffstage: false), findsOneWidget);

      final IndexedStack stack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(stack.index, 0); // explore

      nav.tab('messages');
      await tester.pump();
      expect(nav.screen, 'messages');
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);
      // Another tab still exists (state kept), just not the visible one.
      expect(find.byType(ExploreScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(MessagesScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      nav.dispose();
      state.dispose();
      app.dispose();
    },
  );

  testWidgets('PopScope allows exit only on the Live tab', (tester) async {
    usePortViewport(tester);
    final app = AppContextState();
    final state = OnboardingState();
    final nav = NavigationState(app: app, screen: 'explore');
    await tester.pumpWidget(
      PortFixture(
        app: app,
        onboarding: state,
        navigation: nav,
        child: const AppShell(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1100)); // flush tab load timers
    await tester.pumpAndSettle();
    final Finder scopeFinder = find.byWidgetPredicate(
      (w) => w.runtimeType.toString().contains('PopScope'),
    );
    bool canPop() =>
        (tester.widgetList(scopeFinder).single as dynamic).canPop as bool;
    expect(canPop(), isFalse);

    nav.tab('live');
    await tester.pump();
    expect(canPop(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    nav.dispose();
    state.dispose();
    app.dispose();
  });
}
