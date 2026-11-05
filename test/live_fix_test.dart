import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/live/big_lantern.dart';
import 'package:ishqtalk/screens/live/live_screen.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

void main() {
  for (final (String name, Size size) in <(String, Size)>[
    ('360', const Size(360, 800)),
    ('390', const Size(390, 844)),
    ('480', const Size(480, 1068)),
  ]) {
    group('live $name', () {
      late AppContextState app;
      late NavigationState nav;

      setUp(() {
        app = AppContextState();
        nav = NavigationState(app: app);
      });

      tearDown(() {
        nav.dispose();
        app.dispose();
      });

      Future<void> pumpLive(WidgetTester tester) async {
        usePortViewport(tester, size: size);
        await tester.pumpWidget(
          PortFixture(
            app: app,
            navigation: nav,
            child: LiveScreen(
              initial: LiveState.gift,
              portraits: const <String>[],
            ),
          ),
        );
        await tester.pump();
      }

      testWidgets('big lantern box is 55% of the sky, centered', (
        tester,
      ) async {
        await pumpLive(tester);
        final double skyW = size.width;
        final double skyH = size.height;
        final Rect lantern = tester.getRect(find.byType(BigLantern));
        expect(lantern.width, closeTo(skyW * 0.55, 1));
        expect(lantern.height, closeTo(lantern.width * 738 / 640, 1));
        expect(lantern.center.dx, closeTo(skyW / 2, 1));
        expect(lantern.center.dy, closeTo(skyH / 2, 1));
      });

      testWidgets('halo is centered on the lantern and fades to transparent', (
        tester,
      ) async {
        await pumpLive(tester);
        final Rect lantern = tester.getRect(find.byType(BigLantern));

        final finder = find.descendant(
          of: find.byType(BigLantern),
          matching: find.byWidgetPredicate((w) {
            if (w is! DecoratedBox) return false;
            final decoration = w.decoration;
            if (decoration is! BoxDecoration) return false;
            final gradient = decoration.gradient;
            if (gradient is! RadialGradient) return false;
            return gradient.colors.length == 3;
          }),
        );
        expect(finder, findsOneWidget);
        final Rect halo = tester.getRect(finder);
        expect(halo.center.dx, closeTo(lantern.center.dx, 1));
        expect(halo.center.dy, closeTo(lantern.center.dy, 1));

        final haloBox = tester.widget<DecoratedBox>(finder);
        final gradient = (haloBox.decoration as BoxDecoration).gradient as RadialGradient;
        expect(gradient.colors.last.a, 0);
      });

      testWidgets('big flame sits on the bulb at (49.3%, 90.2%)', (
        tester,
      ) async {
        await pumpLive(tester);
        final Rect lantern = tester.getRect(find.byType(BigLantern));

        final finder = find.descendant(
          of: find.byType(BigLantern),
          matching: find.byWidgetPredicate((w) {
            if (w is! DecoratedBox) return false;
            final decoration = w.decoration;
            if (decoration is! BoxDecoration) return false;
            final gradient = decoration.gradient;
            if (gradient is! RadialGradient) return false;
            return gradient.colors.length == 4;
          }),
        );
        expect(finder, findsOneWidget);
        final Rect flame = tester.getRect(finder);
        final double fx = (flame.center.dx - lantern.left) / lantern.width;
        final double fy = (flame.center.dy - lantern.top) / lantern.height;
        expect(fx, closeTo(0.493, 0.01));
        expect(fy, closeTo(0.902, 0.01));
      });

      testWidgets('Start label lies fully inside the lantern box', (
        tester,
      ) async {
        await pumpLive(tester);
        final Rect lantern = tester.getRect(find.byType(BigLantern));
        final Rect start = tester.getRect(find.text('Start'));
        expect(start.left, greaterThanOrEqualTo(lantern.left));
        expect(start.right, lessThanOrEqualTo(lantern.right));
        expect(start.top, greaterThanOrEqualTo(lantern.top));
        expect(start.bottom, lessThanOrEqualTo(lantern.bottom));
      });
    });
  }
}
