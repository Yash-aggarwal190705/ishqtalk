import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ishqtalk/features/commerce/tokens_screen.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/shared/v2.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  Future<NavigationState> pumpTokens(
    WidgetTester tester, {
    int? initialSelected,
    String? initialSheet,
  }) async {
    usePortViewport(tester);
    final AppContextState app = AppContextState();
    final NavigationState nav = NavigationState(app: app, screen: 'tokens');
    await tester.pumpWidget(
      PortFixture(
        app: app,
        navigation: nav,
        child: TokensScreen(
          initialSelected: initialSelected,
          initialSheet: initialSheet,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return nav;
  }

  testWidgets('grid geometry and texts', (tester) async {
    await pumpTokens(tester);
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
    final Rect c1 = tester.getRect(
      find.byKey(const ValueKey('token-card-100')),
    );
    expect(c1.left, 16);
    expect(c1.width, 171);
    expect(c1.height, 190);
    final Rect c2 = tester.getRect(
      find.byKey(const ValueKey('token-card-500')),
    );
    expect(c2.left, 203);
    final Rect pill = tester.getRect(
      find.byKey(const ValueKey('price-pill-100')),
    );
    expect(pill.height, 40);
    expect(pill.width, 139);
    // Nothing selected: disabled button + caption.
    expect(tester.widget<NeoButton>(find.byType(NeoButton)).onPressed, isNull);
    expect(find.text('Choose an amount'), findsOneWidget);
    expect(find.text('Pick a card to continue'), findsOneWidget);
  });

  testWidgets('selecting a card enables buy and shows badge', (tester) async {
    await pumpTokens(tester);
    await tester.tap(find.text('1,000 tokens'));
    await tester.pump();
    expect(find.byKey(const ValueKey('check-badge')), findsOneWidget);
    expect(find.text('Get 1,000 tokens · ₹1,000'), findsOneWidget);
    expect(find.text('No extra fees. Tokens don’t expire.'), findsOneWidget);
    expect(
      tester.widget<NeoButton>(find.byType(NeoButton)).onPressed,
      isNotNull,
    );
    // Tapping the same card keeps it selected.
    await tester.tap(find.text('1,000 tokens'));
    await tester.pump();
    expect(find.byKey(const ValueKey('check-badge')), findsOneWidget);
  });

  testWidgets('confirm sheet pays and balance stays', (tester) async {
    await pumpTokens(tester);
    await tester.tap(find.text('1,000 tokens'));
    await tester.pump();
    await tester.tap(find.text('Get 1,000 tokens · ₹1,000'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm purchase'), findsOneWidget);
    expect(find.text('Tokens'), findsOneWidget);
    expect(find.text('1,000'), findsOneWidget); // Tokens row value
    // ₹1,000: selected card pill + Price + Total.
    expect(find.text('₹1,000'), findsNWidgets(3));
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    await tester.tap(find.text('Pay ₹1,000'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm purchase'), findsNothing);
    expect(find.text('Payments arrive after the demo'), findsOneWidget);
    expect(find.text('105'), findsOneWidget); // balance unchanged
    await tester.pump(const Duration(milliseconds: 2500));
  });

  testWidgets('initial confirm sheet; back closes only the sheet', (
    tester,
  ) async {
    final NavigationState nav = await pumpTokens(
      tester,
      initialSelected: 1000,
      initialSheet: 'confirm',
    );
    expect(find.text('Confirm purchase'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Confirm purchase'), findsNothing);
    expect(nav.screen, 'tokens');
  });

  testWidgets('header history icon pushes token history', (tester) async {
    final NavigationState nav = await pumpTokens(tester);
    await tester.tap(find.bySemanticsLabel('Token history'));
    expect(nav.screen, 'token-history');
  });
}
