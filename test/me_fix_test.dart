import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/me/me_screen.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/port_fixture.dart';

void main() {
  for (final (String name, Size size) in <(String, Size)>[
    ('360', const Size(360, 800)),
    ('390', const Size(390, 844)),
    ('480', const Size(480, 1068)),
  ]) {
    group('me $name', () {
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

      Future<void> pumpMe(WidgetTester tester) async {
        usePortViewport(tester, size: size);
        await tester.pumpWidget(
          PortFixture(
            app: app,
            navigation: nav,
            child: const MeScreen(instant: true),
          ),
        );
        await tester.pump();
      }

      testWidgets('tokens card spans both rows next to VIP + Invite', (
        tester,
      ) async {
        await pumpMe(tester);
        final Rect tokens = tester.getRect(
          find.byKey(const ValueKey('card-tokens')),
        );
        final Rect vip = tester.getRect(find.byKey(const ValueKey('card-vip')));
        final Rect invite = tester.getRect(
          find.byKey(const ValueKey('card-invite')),
        );

        expect(tokens.height, closeTo(150, 1));
        expect(tokens.top, closeTo(vip.top, 1));
        expect(tokens.bottom, closeTo(invite.bottom, 1));
        expect(invite.top - vip.bottom, closeTo(8, 1));
      });

      testWidgets('card text starts inside the frosted panel', (tester) async {
        await pumpMe(tester);
        final Rect tokens = tester.getRect(
          find.byKey(const ValueKey('card-tokens')),
        );
        final Rect vip = tester.getRect(find.byKey(const ValueKey('card-vip')));
        final Rect invite = tester.getRect(
          find.byKey(const ValueKey('card-invite')),
        );

        expect(
          tester.getRect(find.text('Tokens')).top,
          greaterThanOrEqualTo(tokens.top + 22),
        );
        expect(
          tester.getRect(find.text('VIP')).top,
          greaterThanOrEqualTo(vip.top + 14),
        );
        expect(
          tester.getRect(find.text('Free Bonus')).top,
          greaterThanOrEqualTo(vip.top + 14),
        );
        expect(
          tester.getRect(find.text('Invite to earn money')).top,
          greaterThanOrEqualTo(invite.top + 14),
        );
        expect(
          tester.getRect(find.text('Get Bonus')).top,
          greaterThanOrEqualTo(invite.top + 14),
        );
      });

      testWidgets(
        'tokens content is vertically centered (title ~65, coin ~99)',
        (tester) async {
          await pumpMe(tester);
          final Rect tokens = tester.getRect(
            find.byKey(const ValueKey('card-tokens')),
          );

          final Rect title = tester.getRect(find.text('Tokens'));
          final Rect coin = tester.getRect(
            find.descendant(
              of: find.byKey(const ValueKey('card-tokens')),
              matching: find.byWidgetPredicate(
                (w) => w is Text && w.data != null && w.data!.length <= 4,
              ),
            ),
          );
          final double titleCenter = title.center.dy - tokens.top;
          final double coinCenter = coin.center.dy - tokens.top;
          expect(titleCenter, closeTo(65, 2));
          expect(coinCenter, closeTo(99, 2));
        },
      );

      testWidgets('tokens panel colors are peach/orange, not muddy', (
        tester,
      ) async {
        await pumpMe(tester);
        final RenderRepaintBoundary boundary = tester.renderObject(
          find.byKey(goldenSurface),
        );
        final ui.Image? image = await tester.runAsync(
          () => boundary.toImage(pixelRatio: 1),
        );
        expect(image, isNotNull);
        addTearDown(image!.dispose);
        final ByteData? byteData =
            await tester.runAsync<ByteData?>(() => image.toByteData());
        expect(byteData, isNotNull);
        final ByteData data = byteData!;

        final Rect tokens = tester.getRect(
          find.byKey(const ValueKey('card-tokens')),
        );
        final int x = tokens.left.round() + (0.35 * tokens.width).round();
        // Panel spans peek (22) to the card bottom; sample the fill gradient.
        for (final double f in <double>[0.0, 0.25, 0.45, 0.70, 0.85]) {
          final int y = (tokens.top + 22 + f * (tokens.height - 22)).round();
          final int offset = (y * image.width + x) * 4;
          final int r = data.getUint8(offset);
          final int g = data.getUint8(offset + 1);
          final int b = data.getUint8(offset + 2);
          expect(r, greaterThan(235), reason: 'sample $f r=$r');
          expect(g, greaterThan(180), reason: 'sample $f g=$g');
          expect(b, lessThan(r), reason: 'sample $f b=$b');
        }
      });
    });
  }
}
