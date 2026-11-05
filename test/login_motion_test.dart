import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/screens/onboarding/floating_emojis.dart';
import 'package:ishqtalk/screens/onboarding/login_busy_bar.dart';
import 'package:ishqtalk/screens/onboarding/login_coins.dart';
import 'package:ishqtalk/screens/onboarding/login.dart';
import 'package:ishqtalk/screens/onboarding/provider_button.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  testWidgets('floaters preserve stagger, easeOut and 3-second cycle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const PortFixture(
        freezeLoops: false,
        child: Center(child: FloatingEmojis()),
      ),
    );
    List<double> alpha() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(FloatingEmojis),
            matching: find.byType(Opacity),
          ),
        )
        .map((w) => w.opacity)
        .toList();
    expect(alpha(), [1, 0, 0, 0, 0, 0]);
    await tester.pump(const Duration(milliseconds: 499));
    expect(alpha()[1], 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(alpha()[1], 1);
    await tester.pump(const Duration(milliseconds: 1000));
    final firstLoop = find.byType(LoopMotion).first;
    final transforms = tester
        .widgetList<Transform>(
          find.descendant(of: firstLoop, matching: find.byType(Transform)),
        )
        .toList();
    final value = Curves.easeOut.transform(.5);
    expect(alpha().first, closeTo(1 - value, .001));
    expect(transforms[0].transform.entry(0, 3), closeTo(-10 * value, .001));
    expect(transforms[0].transform.entry(1, 3), closeTo(-120 * value, .001));
    expect(transforms[1].transform.entry(0, 0), closeTo(.8 + .3 * value, .001));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(alpha().first, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'sparkle reaches both stops and progress uses its own segment width',
    (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        const PortFixture(
          freezeLoops: false,
          child: Stack(
            children: [
              Center(child: LoginCoins()),
              LoginBusyBar(),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      final barSegment = find
          .descendant(
            of: find.byType(LoginBusyBar),
            matching: find.byType(Positioned),
          )
          .last;
      final segment = tester.widget<Positioned>(barSegment);
      expect(segment.width, 130);
      expect(
        segment.left,
        closeTo(130 * (-1 + 4.5 * Curves.easeInOut.transform(.5)), .001),
      );
      await tester.pump(const Duration(milliseconds: 500));
      final sparkle = find.descendant(
        of: find.byType(LoginCoins),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(sparkle).opacity, 1);
      final scale = find.descendant(
        of: find.byType(LoginCoins),
        matching: find.byType(Transform),
      );
      expect(
        tester.widget<Transform>(scale).transform.entry(0, 0),
        closeTo(1.1, .001),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<Opacity>(sparkle).opacity, closeTo(.2, .001));
      expect(
        tester.widget<Transform>(scale).transform.entry(0, 0),
        closeTo(.6, .001),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'reduced motion hides floaters and leaves a full-width static bar',
    (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        const PortFixture(
          freezeLoops: false,
          reducedMotion: true,
          child: Stack(
            children: [
              Center(child: FloatingEmojis()),
              LoginBusyBar(),
            ],
          ),
        ),
      );
      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      expect(opacities.every((w) => w.opacity == 0), isTrue);
      final barSegment = tester.widget<Positioned>(
        find
            .descendant(
              of: find.byType(LoginBusyBar),
              matching: find.byType(Positioned),
            )
            .last,
      );
      expect(barSegment.width, 390);
      expect(barSegment.left, 0);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets(
    'instant keeps floater loops; provider press scales and cancel restores',
    (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        const PortFixture(freezeLoops: false, child: Login(instant: true)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final firstOpacity = find
          .descendant(
            of: find.byType(FloatingEmojis),
            matching: find.byType(Opacity),
          )
          .first;
      expect(tester.widget<Opacity>(firstOpacity).opacity, lessThan(1));
      final google = find.byType(ProviderButton).first;
      final gesture = await tester.startGesture(tester.getCenter(google));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      final transform = find
          .descendant(of: google, matching: find.byType(Transform))
          .first;
      expect(
        tester.widget<Transform>(transform).transform.entry(0, 0),
        closeTo(.98, .001),
      );
      await gesture.cancel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.widget<Transform>(transform).transform.entry(0, 0), 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
