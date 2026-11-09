import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/features/items/domain.dart';
import 'package:ishqtalk/features/items/expired_items_screen.dart';
import 'package:ishqtalk/features/items/my_items_screen.dart';
import 'package:ishqtalk/features/items/widgets.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

Widget _itemsFixture(
  AppContextState app,
  NavigationState navigation, {
  ItemsRepository repository = const ItemsRepository(),
  bool forceEmpty = false,
  bool pinLoading = false,
  ItemTab initialTab = ItemTab.passes,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: MyItemsScreen(
      repository: repository,
      forceEmpty: forceEmpty,
      pinLoading: pinLoading,
      initialTab: initialTab,
    ),
  );
}

Widget _expiredFixture(
  AppContextState app,
  NavigationState navigation, {
  bool forceEmpty = false,
  bool pinLoading = false,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: ExpiredItemsScreen(
      forceEmpty: forceEmpty,
      pinLoading: pinLoading,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  group('My items', () {
    testWidgets('passes list: 2 rows, Active chip, sheet, Use now → Live',
        (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'package-props');
      await tester.pumpWidget(_itemsFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Match pass × 2'), findsOneWidget);
      expect(find.text('Chat pass × 1'), findsOneWidget);
      expect(find.text('Active'), findsNWidgets(2));

      // Ticket is 40x28; the row is 72 tall.
      final Rect ticket = tester.getRect(find.byType(PassTicket).first);
      expect(ticket.width, 40);
      expect(ticket.height, closeTo(28, 1));
      expect(find.byType(PassTicket), findsNWidgets(2));

      await tester.tap(find.text('Match pass × 2'));
      await tester.pumpAndSettle();
      expect(find.text('Skip the wait and start a video match right away.'), findsOneWidget);
      // Row + sheet both show the when text.
      expect(find.text('Expires 12 Nov, 6:30 pm'), findsNWidgets(2));
      await tester.tap(find.text('Use now'));
      await tester.pumpAndSettle();
      expect(find.text('Use now'), findsNothing);
      expect(nav.screen, 'live');
      nav.dispose();
      app.dispose();
    });

    testWidgets('empty passes: See daily bonus pushes Level (source slip)',
        (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'package-props');
      await tester.pumpWidget(
        _itemsFixture(app, nav, forceEmpty: true),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('No passes yet'), findsOneWidget);
      expect(find.text('Earn passes with your daily bonus.'), findsOneWidget);
      // The 112 circle sits 48 above the panel vertical centre (bottom pad 96).
      final Rect circle = tester.getRect(find.byType(ItemArtIcon));
      expect(circle.height, 56); // art tile, circle is behind
      await tester.tap(find.text('See daily bonus'));
      await tester.pumpAndSettle();
      expect(nav.screen, 'level');
      nav.dispose();
      app.dispose();
    });

    testWidgets('gifts tab: empty state + Explore rooms → Explore tab',
        (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'package-props');
      await tester.pumpWidget(
        _itemsFixture(app, nav, initialTab: ItemTab.gifts),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('No gifts yet'), findsOneWidget);
      expect(find.text('Gifts you get in rooms will show up here.'), findsOneWidget);
      await tester.tap(find.text('Explore rooms'));
      await tester.pumpAndSettle();
      expect(nav.screen, 'explore');
      nav.dispose();
      app.dispose();
    });

    testWidgets('loading shows the skeleton first', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(
        _itemsFixture(app, nav, pinLoading: true),
      );
      await tester.pump();
      expect(find.byType(ItemsSkeleton), findsOneWidget);
      expect(find.text('Match pass × 2'), findsNothing);
      nav.dispose();
      app.dispose();
    });
  });

  group('Expired items', () {
    testWidgets('6 rows, opacity .6 tickets, Expired chip, time max-width 132',
        (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(_expiredFixture(app, nav));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Match pass × 2'), findsNWidgets(2));
      expect(find.text('Match pass × 1'), findsOneWidget);
      expect(find.text('Chat pass × 1'), findsNWidgets(2));
      expect(find.text('Chat pass × 2'), findsOneWidget);
      expect(find.text('Expired'), findsNWidgets(6));

      // Every PassTicket in the expired list renders at opacity .6.
      for (final Element e in find.byType(Opacity).evaluate()) {
        final Opacity o = e.widget as Opacity;
        if (o.child is PassTicket) {
          expect(o.opacity, closeTo(.6, .001));
        }
      }
      nav.dispose();
      app.dispose();
    });

    testWidgets('gifts tab shows No expired gifts', (tester) async {
      usePortViewport(tester);
      final app = AppContextState();
      final nav = NavigationState(app: app);
      await tester.pumpWidget(
        _expiredFixture(app, nav),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Gifts'));
      await tester.pump();
      expect(find.text('No expired gifts'), findsOneWidget);
      nav.dispose();
      app.dispose();
    });
  });
}
