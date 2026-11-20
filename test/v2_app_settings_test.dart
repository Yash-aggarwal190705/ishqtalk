import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishqtalk/features/auth/data/local_auth_repository.dart';
import 'package:ishqtalk/features/auth/presentation/auth_state.dart';
import 'package:ishqtalk/foundation/app_icons.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/me/app_settings_screen.dart';
import 'package:ishqtalk/shared/v2.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/onboarding_state.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<(AppContextState, OnboardingState, NavigationState)> pumpSettings(
    WidgetTester tester, {
    String? sheet,
  }) async {
    usePortViewport(tester);
    final AppContextState app = AppContextState();
    final OnboardingState onboarding = OnboardingState();
    final NavigationState nav = NavigationState(app: app, screen: 'settings');
    final AuthState auth = AuthState(repository: LocalAuthRepository());
    await tester.pumpWidget(
      PortFixture(
        app: app,
        onboarding: onboarding,
        navigation: nav,
        auth: auth,
        child: AppSettingsScreen(initialSheet: sheet),
      ),
    );
    await tester.pumpAndSettle();
    return (app, onboarding, nav);
  }

  double thumbLeft(WidgetTester tester, Finder row) {
    final Finder anim = find.descendant(
      of: row,
      matching: find.byType(AnimatedPositioned),
    );
    return tester.widget<AnimatedPositioned>(anim).left!;
  }

  testWidgets('groups, rows and numbers', (tester) async {
    await pumpSettings(tester);
    for (final String title in <String>[
      'General',
      'Safety',
      'Comfort',
      'Device',
      'Account',
    ]) {
      expect(tester.getTopLeft(find.text(title)).dx, 24);
    }
    final Rect general = tester.getRect(
      find.byKey(const ValueKey('group-general')),
    );
    expect(general.left, 16);
    expect(general.width, 358);
    expect(
      tester.getSize(find.byKey(const ValueKey('row-App language'))).height,
      56,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('row-My reports'))).height,
      greaterThanOrEqualTo(72),
    );
    final Finder chev = find.descendant(
      of: find.byKey(const ValueKey('row-App language')),
      matching: find.byWidgetPredicate((w) => w is AppIcon && w.name == 'chev'),
    );
    expect(tester.getRect(chev).right, closeTo(354, .5));
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Reports you sent and their status'), findsOneWidget);
    expect(find.text('Hide sensitive content in discovery'), findsOneWidget);
    expect(find.text('86 MB'), findsOneWidget);
    expect(find.text('Up to date'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('logout-button'))).height,
      56,
    );
    expect(find.text('YourApp v0.1 demo'), findsOneWidget);
  });

  testWidgets('switches toggle label and thumb, persist', (tester) async {
    await pumpSettings(tester);
    final Finder safeRow = find.byKey(const ValueKey('row-Safe mode'));
    expect(
      find.descendant(of: safeRow, matching: find.text('On')),
      findsOneWidget,
    );
    expect(thumbLeft(tester, safeRow), 24);
    await tester.tap(
      find.descendant(of: safeRow, matching: find.byType(AppSwitch)),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: safeRow, matching: find.text('Off')),
      findsOneWidget,
    );
    expect(thumbLeft(tester, safeRow), 4);
    final Finder dndRow = find.byKey(const ValueKey('row-Do not disturb'));
    expect(thumbLeft(tester, dndRow), 4);
    await tester.tap(
      find.descendant(of: dndRow, matching: find.byType(AppSwitch)),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: dndRow, matching: find.text('On')),
      findsOneWidget,
    );
    expect(thumbLeft(tester, dndRow), 24);
    expect(find.text('Coming soon'), findsNothing);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('yourapp.safeMode'), isFalse);
    expect(prefs.getBool('yourapp.doNotDisturb'), isTrue);
  });

  testWidgets('clear cache and check updates', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.byKey(const ValueKey('row-Clear cache')));
    await tester.pump();
    expect(find.text('0 MB'), findsOneWidget);
    expect(find.text('Cache cleared'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.tap(find.byKey(const ValueKey('row-Clear cache')));
    await tester.pump();
    expect(find.text('0 MB'), findsOneWidget);
    expect(find.text('Cache cleared'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('row-Check for updates')));
    await tester.pump();
    expect(find.text('Checking…'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('row-Check for updates')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Checking…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Up to date'), findsOneWidget);
  });

  testWidgets('log out sheet resets onboarding and goes to login', (
    tester,
  ) async {
    final (_, OnboardingState onboarding, NavigationState nav) =
        await pumpSettings(tester);
    onboarding.setOnboarded();
    expect(onboarding.onboarded, isTrue);
    await tester.scrollUntilVisible(
      find.text('Log out'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of YourApp?'), findsOneWidget);
    expect(find.text('You can log back in any time.'), findsOneWidget);
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(nav.screen, 'login');
    expect(onboarding.onboarded, isFalse);
  });

  testWidgets('stay logged in closes only the sheet', (tester) async {
    final (_, _, NavigationState nav) = await pumpSettings(tester);
    await tester.scrollUntilVisible(
      find.text('Log out'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stay logged in'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of YourApp?'), findsNothing);
    expect(nav.screen, 'settings');
    expect(find.byType(AppSettingsScreen), findsOneWidget);
  });

  testWidgets('delete sheet: top edge 40, disabled until ack, keep closes', (
    tester,
  ) async {
    await pumpSettings(tester, sheet: 'delete');
    final Rect panel = tester.getRect(
      find.byKey(const ValueKey('delete-sheet-panel')),
    );
    expect(panel.top, 40);
    final Finder deleteButton = find.descendant(
      of: find.byKey(const ValueKey('delete-sheet-panel')),
      matching: find.text('Delete account'),
    );
    expect(
      tester.widget<NeoButton>(find.byType(NeoButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('I understand'));
    await tester.pump();
    expect(
      tester.widget<NeoButton>(find.byType(NeoButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsNothing);
    expect(deleteButton, findsNothing);
    expect(find.byType(AppSettingsScreen), findsOneWidget);
  });

  testWidgets('delete account clears data and restarts at splash', (
    tester,
  ) async {
    final (
      AppContextState app,
      OnboardingState onboarding,
      NavigationState nav,
    ) = await pumpSettings(
      tester,
      sheet: 'delete',
    );
    app.saveProfile('Meera Sharma');
    onboarding.setOnboarded();
    await tester.tap(find.text('I understand'));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('delete-sheet-panel')),
        matching: find.text('Delete account'),
      ),
    );
    await tester.pumpAndSettle();
    expect(nav.screen, 'splash');
    expect(onboarding.onboarded, isFalse);
    expect(app.profileName, isEmpty);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('yourapp.profile'), isNull);
    expect(prefs.getString('yourapp.hasOnboarded'), isNull);
  });

  testWidgets('system back closes only the sheet', (tester) async {
    await pumpSettings(tester, sheet: 'delete');
    expect(find.text('Delete your account?'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsNothing);
    expect(find.byType(AppSettingsScreen), findsOneWidget);
  });
}
