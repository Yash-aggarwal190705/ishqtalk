import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/explore/explore_screen.dart';
import 'package:ishqtalk/screens/explore/user_repository.dart';
import 'package:ishqtalk/screens/explore/widgets/user_card.dart';
import 'package:ishqtalk/shared/call_button.dart';
import 'package:ishqtalk/shared/empty_state.dart';
import 'package:ishqtalk/shared/offline_banner.dart';
import 'package:ishqtalk/shared/token_pill.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/port_fixture.dart';

class _CountingRepository implements UserRepository {
  int fetches = 0;

  @override
  Future<List<AppUser>> fetch() async {
    fetches++;
    return users;
  }
}

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  UserRepository? repository,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: ExploreScreen(
      repository: repository ?? const SeedUserRepository(delay: Duration.zero),
    ),
  );
}

void main() {
  testWidgets('renders every seed user; unavailable hides its call button', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    expect(find.byType(UserCard), findsNWidgets(10));
    expect(find.byType(CallButton), findsNWidgets(9));
    expect(find.byType(TokenPill), findsOneWidget);
    nav.dispose();
    app.dispose();
  });

  testWidgets('blocked users are never shown', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    expect(find.text('Ragini'), findsOneWidget);
    app.block(0);
    await tester.pump();
    expect(find.text('Ragini'), findsNothing);
    expect(find.byType(UserCard), findsNWidgets(9));
    nav.dispose();
    app.dispose();
  });

  testWidgets('search filters live by trimmed case-insensitive name', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  QUEEN  ');
    await tester.pump();
    expect(find.text('Queen 👑'), findsOneWidget);
    expect(find.byType(UserCard), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(UserCard), findsNothing);
    await tester.tap(find.text('Clear search'));
    await tester.pump();
    expect(find.byType(UserCard), findsNWidgets(10));
    nav.dispose();
    app.dispose();
  });

  testWidgets('Cancel clears the query and returns to the normal header', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'maya');
    await tester.pump();
    expect(find.byType(UserCard), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Explore'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(UserCard), findsNWidgets(10));
    nav.dispose();
    app.dispose();
  });

  testWidgets('card tap opens that user profile', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'explore');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(UserCard).first);
    expect(nav.screen, 'profile');
    expect(nav.user.id, users.first.id);
    nav.dispose();
    app.dispose();
  });

  testWidgets(
    'call button opens the call overlay without opening the profile',
    (tester) async {
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'explore');
      await tester.pumpWidget(_fixture(app, nav));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CallButton).first);
      expect(nav.screen, 'explore');
      expect(nav.callUser, isNotNull);
      expect(nav.callUser!.id, users.first.id);
      nav.dispose();
      app.dispose();
    },
  );

  testWidgets('token pill pushes the tokens screen', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'explore');
    await tester.pumpWidget(_fixture(app, nav));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenPill));
    expect(nav.screen, 'tokens');
    nav.dispose();
    app.dispose();
  });

  testWidgets('offline banner appears and Try again reloads', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    final repository = _CountingRepository();
    await tester.pumpWidget(_fixture(app, nav, repository: repository));
    await tester.pumpAndSettle();
    app.setOffline(true);
    await tester.pump();
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.text("You're offline. Showing saved people."), findsOneWidget);
    expect(repository.fetches, 1);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(repository.fetches, 2);
    nav.dispose();
    app.dispose();
  });

  testWidgets('skeleton shimmer shows while the repository loads', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    await tester.pumpWidget(
      PortFixture(
        app: app,
        navigation: nav,
        child: const ExploreScreen(
          repository: SeedUserRepository(delay: Duration(milliseconds: 500)),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Shimmer), findsWidgets);
    expect(find.byType(UserCard), findsNothing);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byType(Shimmer), findsNothing);
    expect(find.byType(UserCard), findsNWidgets(10));
    nav.dispose();
    app.dispose();
  });
}
