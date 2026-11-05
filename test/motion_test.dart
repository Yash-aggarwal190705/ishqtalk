import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_motion.dart';

import 'support/port_fixture.dart';

void main() {
  testWidgets(
    'Rise holds the from state during delay then completes in 300ms',
    (tester) async {
      await tester.pumpWidget(
        const PortFixture(
          child: Rise(
            delay: Duration(milliseconds: 60),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      double opacity() =>
          tester.widget<Opacity>(find.byType(Opacity).last).opacity;
      expect(opacity(), 0);
      await tester.pump(const Duration(milliseconds: 59));
      expect(opacity(), 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(opacity(), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(), closeTo(Curves.easeOut.transform(.5), .001));
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(), 1);
    },
  );

  testWidgets(
    'negative delay starts in-cycle; reduced motion stops the ticker',
    (tester) async {
      double phase = -1;
      bool idle = false;
      Widget frame(bool reduced, bool freeze) => PortFixture(
        reducedMotion: reduced,
        freezeLoops: freeze,
        child: LoopMotion(
          duration: const Duration(seconds: 9),
          delay: const Duration(seconds: -2),
          builder: (context, value, paused, child) {
            phase = value;
            idle = paused;
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(frame(false, false));
      expect(phase, closeTo(2 / 9, .0001));
      await tester.pump(const Duration(seconds: 1));
      expect(phase, closeTo(3 / 9, .0001));
      await tester.pumpWidget(frame(true, false));
      expect(idle, isTrue);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'instant skips entrances but spin continues until explicitly frozen',
    (tester) async {
      Widget frame(bool frozen) => PortFixture(
        freezeLoops: frozen,
        child: const FadeIn(
          instant: true,
          child: Spin(
            instant: true,
            duration: Duration(milliseconds: 800),
            child: SizedBox(width: 18, height: 18),
          ),
        ),
      );
      await tester.pumpWidget(frame(false));
      expect(tester.widget<Opacity>(find.byType(Opacity).last).opacity, 1);
      await tester.pump(const Duration(milliseconds: 200));
      final matrix = tester
          .widget<Transform>(find.byType(Transform).last)
          .transform;
      expect(matrix.entry(0, 0), closeTo(0, .001));
      expect(matrix.entry(1, 0), closeTo(1, .001));
      await tester.pumpWidget(frame(true));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('Shake reaches its CSS keyframe positions every 80ms', (
    tester,
  ) async {
    await tester.pumpWidget(
      const PortFixture(child: Shake(child: SizedBox(width: 10, height: 10))),
    );
    for (final expected in [-8, 8, -6, 6, 0]) {
      await tester.pump(const Duration(milliseconds: 80));
      final matrix = tester
          .widget<Transform>(find.byType(Transform).last)
          .transform;
      expect(matrix.entry(0, 3), closeTo(expected, .001));
    }
  });

  testWidgets('PulseDot completes a round trip in 1200ms', (tester) async {
    await tester.pumpWidget(
      const PortFixture(
        freezeLoops: false,
        child: PulseDot(child: SizedBox(width: 4, height: 4)),
      ),
    );
    expect(tester.widget<Opacity>(find.byType(Opacity).last).opacity, .25);
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester.widget<Opacity>(find.byType(Opacity).last).opacity,
      closeTo(1, .001),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester.widget<Opacity>(find.byType(Opacity).last).opacity,
      closeTo(.25, .001),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
