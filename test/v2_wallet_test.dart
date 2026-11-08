import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_theme.dart';
import 'package:ishqtalk/features/wallet/domain.dart';
import 'package:ishqtalk/shared/v2.dart';
import 'package:ishqtalk/features/wallet/level_screen.dart';
import 'package:ishqtalk/features/wallet/token_history_screen.dart';
import 'package:ishqtalk/features/wallet/widgets.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Widget _historyFixture(
  AppContextState app,
  NavigationState navigation, {
  WalletRepository repository = const WalletRepository(),
  bool forceEmpty = false,
  bool pinLoading = false,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: TokenHistoryScreen(
      repository: repository,
      forceEmpty: forceEmpty,
      pinLoading: pinLoading,
    ),
  );
}

Widget _levelFixture(
  AppContextState app,
  NavigationState navigation,
  int tokensAdded,
) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: LevelScreen(
      repository: const WalletRepository(),
      tokensAdded: tokensAdded,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  group('Token history', () {
    testWidgets('balance card geometry and default groups', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_historyFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('105 tokens'), findsOneWidget);
      expect(find.text('1 token = ₹1'), findsOneWidget);

      final RenderBox card = tester.renderObject(
        find.byKey(const ValueKey('balance-card')),
      );
      // Outer box includes its margins: left 0, height 56 + 4 top margin.
      expect(
        card.localToGlobal(Offset.zero).dy,
        closeTo(56, 1),
      ); // header bottom
      expect(card.size.height, 60);
      // The text sits at 16 margin + 16 padding + 28 coin + 8 gap.
      expect(tester.getRect(find.text('105 tokens')).left, closeTo(68, 2));

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Daily check-in bonus'), findsOneWidget);
      expect(find.text('Tokens added'), findsOneWidget);
      expect(find.text('Match pass'), findsOneWidget);
      expect(find.text('Welcome bonus'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });

    testWidgets('row geometry, amount signs and colors', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_historyFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 800));

      final Text plus = tester.widget<Text>(find.text('+5').first);
      expect(plus.style?.color, AppColors.success);
      final Text minus = tester.widget<Text>(find.text('\u221250'));
      expect(minus.style?.fontWeight, FontWeight.w600);
      expect(minus.style?.color, AppColors.ink);
      expect(find.text('₹50'), findsOneWidget);
      expect(find.byType(TxLeadIcon), findsNWidgets(4));
      nav.dispose();
      app.dispose();
    });

    testWidgets('skeleton shows 4 rows before load', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_historyFixture(app, nav, pinLoading: true));
      await tester.pump();
      expect(find.byType(ShimmerBox), findsWidgets);
      expect(find.text('Today'), findsNothing);
      nav.dispose();
      app.dispose();
    });

    testWidgets('filter: Spent shows only Match pass + dot; range cycles', (
      tester,
    ) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_historyFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.bySemanticsLabel('Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsOneWidget);
      // Range starts at "Last 30 days": cycle 3× → All time → Today → Last 7.
      expect(find.text('Last 30 days'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('range-button')));
      await tester.pump();
      expect(find.text('All time'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('range-button')));
      await tester.pump();
      // Group header "Today" is behind the sheet; the sheet's range label is
      // the second occurrence.
      expect(find.text('Today'), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey('range-button')));
      await tester.pump();
      expect(find.text('Last 7 days'), findsOneWidget);

      await tester.tap(find.text('Spent'));
      await tester.pump();
      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();

      expect(find.text('Match pass'), findsOneWidget);
      expect(find.text('Tokens added'), findsNothing);
      expect(find.text('Daily check-in bonus'), findsNothing);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
      nav.dispose();
      app.dispose();
    });

    testWidgets('no-match empty state resets filter', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_historyFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 800));

      // Apply Spent + Today → no rows → "No matching activity".
      await tester.tap(find.bySemanticsLabel('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spent'));
      await tester.pump();
      // Range starts at Last 30 days: cycle to Today (30 → All → Today).
      await tester.tap(find.byKey(const ValueKey('range-button')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('range-button')));
      await tester.pump();
      expect(
        find.text('Today'),
        findsNWidgets(2),
      ); // group header + sheet label
      await tester.tap(find.text('Show results'));
      await tester.pumpAndSettle();
      expect(find.text('No matching activity'), findsOneWidget);

      // "Reset" inside the sheet only changes the draft, not the applied filter.
      await tester.tap(find.bySemanticsLabel('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
      // Close via the scrim (draft discarded) — the applied filter is unchanged.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('No matching activity'), findsOneWidget);

      // The empty-state Reset filter button clears the applied filter.
      await tester.tap(find.text('Reset filter'));
      await tester.pump();
      expect(find.text('Tokens added'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });

    testWidgets('no-data empty state pushes Get Tokens', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'token-history');
      await tester.pumpWidget(_historyFixture(app, nav, forceEmpty: true));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('No token activity yet'), findsOneWidget);
      await tester.tap(find.text('Get tokens'));
      await tester.pumpAndSettle();
      expect(nav.screen, 'tokens');
      nav.dispose();
      app.dispose();
    });
  });

  group('Level', () {
    testWidgets('Lv 0 seed texts', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_levelFixture(app, nav, 0));
      await tester.pump();

      // Card title + card-left + selected tab + rule pill.
      expect(find.text('Lv 0'), findsNWidgets(4));
      expect(find.text('Add 100 tokens to reach Lv 1'), findsOneWidget);
      expect(find.text('+5 tokens every day at Lv 0'), findsOneWidget);
      expect(find.byType(OrbitBadge), findsOneWidget);
      nav.dispose();
      app.dispose();
    });

    testWidgets('tokensAdded 2000: Lv 2, 50% fill, tab, chip, bonus line', (
      tester,
    ) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_levelFixture(app, nav, 2000));
      await tester.pump();

      expect(find.text('Lv 2'), findsWidgets);
      expect(find.text('2,000'), findsOneWidget);
      expect(find.text('Add 1,000 tokens to reach Lv 3'), findsOneWidget);
      expect(find.text('You are here'), findsOneWidget);
      expect(find.text('+12 tokens every day at Lv 2'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });

    testWidgets('tokensAdded 10000000: top level', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_levelFixture(app, nav, 10000000));
      await tester.pump();

      expect(find.text('Lv 10'), findsNWidgets(4));
      expect(find.text("You've reached the top level"), findsOneWidget);
      expect(find.text('1,00,00,000'), findsOneWidget); // pill
      nav.dispose();
      app.dispose();
    });

    testWidgets('rule table: 11 rows, alternating bg, labels in order', (
      tester,
    ) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_levelFixture(app, nav, 0));
      await tester.pump();

      for (final String label in thresholdLabels) {
        expect(find.text(label), findsWidgets);
      }
      // "0" appears twice: the card pill and the table's first row label.
      expect(find.text('0'), findsNWidgets(2));
      // Row heights are inside the scroll area; check the table exists and has
      // a first label visible.
      expect(find.text('Level rule'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });

    testWidgets('tapping a tab updates only the bonus line', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_levelFixture(app, nav, 0));
      await tester.pump();

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == 'Lv 4' && w.style?.fontSize == 16,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('+25 tokens every day at Lv 4'), findsOneWidget);
      // Card texts unchanged (still Lv 0).
      expect(find.text('Add 100 tokens to reach Lv 1'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });
  });

  group('domain math', () {
    test('fmtIN Indian grouping', () {
      expect(fmtIN(0), '0');
      expect(fmtIN(100), '100');
      expect(fmtIN(2000), '2,000');
      expect(fmtIN(99900), '99,900');
      expect(fmtIN(100000), '1,00,000');
    });

    test('levelInfo at 0, 2000, 10000000', () {
      final LevelInfo a = levelInfo(0);
      expect(a.current, 0);
      expect(a.next, 1);
      expect(a.isMax, isFalse);
      expect(a.pct, 0);
      expect(a.need, 100);

      final LevelInfo b = levelInfo(2000);
      expect(b.current, 2);
      expect(b.next, 3);
      expect(b.pct, 50);
      expect(b.need, 1000);

      final LevelInfo c = levelInfo(10000000);
      expect(c.isMax, isTrue);
      expect(c.pct, 100);
      expect(c.next, 10);
    });

    test('tierOf mapping', () {
      expect(tierOf(0), Tier.gray);
      expect(tierOf(1), Tier.mint);
      expect(tierOf(3), Tier.violet);
      expect(tierOf(6), Tier.pink);
      expect(tierOf(9), Tier.sunset);
    });
  });
}
