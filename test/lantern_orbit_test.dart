// test/lantern_orbit_test.dart
// Reference numbers computed from the prototype's `place()` function for a 390 x 844 sky.
// dx/dy are offsets of each lantern centre from the sky centre (195, 422).
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/screens/live/lantern_orbit.dart';

void main() {
  const size = Size(390, 844);

  // t, slot (0=A1, 1=A2, 2=B3, 3=B4), dx, dy, depth, scale, opacity
  const rows = <(double, int, double, double, double, double, double)>[
    (0, 0, 148.36, -48.21, -0.263, 0.716, 0.553),
    (0, 1, -148.36, 48.21, 0.263, 0.834, 0.697),
    (0, 2, -88.53, 219.11, 0.956, 0.990, 0.888),
    (0, 3, 88.53, -219.11, -0.956, 0.560, 0.362),
    (4, 0, 57.38, 176.59, 0.965, 0.992, 0.890),
    (4, 1, -57.38, -176.59, -0.965, 0.558, 0.360),
    (4, 2, 114.53, 152.15, 0.664, 0.924, 0.808),
    (4, 3, -114.53, -152.15, -0.664, 0.626, 0.442),
    (8, 0, -148.36, 48.21, 0.263, 0.834, 0.697),
    (8, 2, 183.68, -92.70, -0.404, 0.684, 0.514),
    (12, 2, 38.08, -229.17, -1.000, 0.550, 0.350),
    (12, 3, -38.08, 229.17, 1.000, 1.000, 0.900),
  ];

  test('lantern placements match the prototype', () {
    for (final (t, slot, dx, dy, depth, scale, opacity) in rows) {
      final (orbit, idx) = lanternSlots[slot];
      final p = placeLantern(
        orbit: orbit,
        index: idx,
        elapsedSeconds: t,
        size: size,
      );
      expect(p.dx, closeTo(dx, 0.05), reason: 't=$t slot=$slot dx');
      expect(p.dy, closeTo(dy, 0.05), reason: 't=$t slot=$slot dy');
      expect(p.depth, closeTo(depth, 0.002), reason: 't=$t slot=$slot depth');
      expect(p.scale, closeTo(scale, 0.002), reason: 't=$t slot=$slot scale');
      expect(
        p.opacity,
        closeTo(opacity, 0.002),
        reason: 't=$t slot=$slot opacity',
      );
    }
  });

  test(
    'A turns clockwise, B counter-clockwise, A=16 s and B=22 s per turn',
    () {
      final a0 = placeLantern(
        orbit: orbitA,
        index: 0,
        elapsedSeconds: 0,
        size: size,
      );
      final a1 = placeLantern(
        orbit: orbitA,
        index: 0,
        elapsedSeconds: 1,
        size: size,
      );
      // clockwise on screen from the right-hand side: y increases (moves down)
      expect(a1.dy, greaterThan(a0.dy));
      final b0 = placeLantern(
        orbit: orbitB,
        index: 0,
        elapsedSeconds: 0,
        size: size,
      );
      final b22 = placeLantern(
        orbit: orbitB,
        index: 0,
        elapsedSeconds: 22,
        size: size,
      );
      expect(b22.dx, closeTo(b0.dx, 0.01));
      expect(b22.dy, closeTo(b0.dy, 0.01));
    },
  );
}
