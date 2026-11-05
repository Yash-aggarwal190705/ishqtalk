// lantern_orbit.dart
//
// Elliptical lantern orbits for the Live Home sky, ported 1:1 from SkyLantern.tsx
// (the maths was checked against the screen recording of the prototype).
//
// Drop-in: put `LanternOrbitLayer` in the sky Stack between the static sky layers
// (gradient, stars, mountains) and nothing else. It draws the big lantern and the
// 4 small lanterns together so the small ones can pass BEHIND and IN FRONT of the big one.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ---------------------------------------------------------------------------
// Pure maths (unit-testable, no Flutter widgets)
// ---------------------------------------------------------------------------

enum OrbitDirection { cw, ccw }

class OrbitSpec {
  const OrbitSpec({
    required this.rxPct,
    required this.ryPct,
    required this.tiltDeg,
    required this.seconds,
    required this.direction,
    required this.startDeg,
  });

  final double rxPct; // horizontal radius as share of sky WIDTH
  final double ryPct; // vertical radius as share of sky HEIGHT
  final double tiltDeg; // tilt of the ellipse, degrees (screen coords, y down)
  final double seconds; // seconds per full turn
  final OrbitDirection direction;
  final List<double>
  startDeg; // start angle of lantern 0 and lantern 1 on this orbit
}

const OrbitSpec orbitA = OrbitSpec(
  rxPct: 0.40,
  ryPct: 0.22,
  tiltDeg: -18,
  seconds: 16,
  direction: OrbitDirection.cw,
  startDeg: [0, 180],
);
const OrbitSpec orbitB = OrbitSpec(
  rxPct: 0.46,
  ryPct: 0.28,
  tiltDeg: 22,
  seconds: 22,
  direction: OrbitDirection.ccw,
  startDeg: [90, 270],
);

/// Order matters: index 0..3 = Orbit_A_Lantern_1, A_2, B_3, B_4.
const List<(OrbitSpec, int)> lanternSlots = [
  (orbitA, 0),
  (orbitA, 1),
  (orbitB, 0),
  (orbitB, 1),
];

const double backScale = 0.55, frontScale = 1.0;
const double backOpacity = 0.35, frontOpacity = 0.9;

double _lerp(double a, double b, double t) => a + (b - a) * t;

class LanternPlacement {
  const LanternPlacement({
    required this.dx,
    required this.dy,
    required this.depth,
    required this.scale,
    required this.opacity,
  });

  final double dx, dy; // offset of the lantern CENTRE from the sky centre
  final double
  depth; // -1 = far back (top of ellipse) ... +1 = nearest (bottom)
  final double scale, opacity;

  bool get inFront => depth >= 0; // in front of the big lantern
}

/// [size] is the full sky box (full-bleed, including the areas under the status bar and nav).
LanternPlacement placeLantern({
  required OrbitSpec orbit,
  required int index,
  required double elapsedSeconds,
  required Size size,
}) {
  final dir = orbit.direction == OrbitDirection.cw ? 1.0 : -1.0;
  final deg =
      orbit.startDeg[index] + dir * (elapsedSeconds / orbit.seconds) * 360.0;
  final a = deg * math.pi / 180.0; // degrees -> RADIANS (common bug)
  final t = orbit.tiltDeg * math.pi / 180.0;
  final rx = orbit.rxPct * size.width;
  final ry = orbit.ryPct * size.height;

  final ex = rx * math.cos(a);
  final ey = ry * math.sin(a);
  final x = ex * math.cos(t) - ey * math.sin(t);
  final y = ex * math.sin(t) + ey * math.cos(t);

  final maxY = math.sqrt(
    math.pow(rx * math.sin(t), 2) + math.pow(ry * math.cos(t), 2),
  );
  final d = y / maxY; // -1 .. +1
  final f = (d + 1) / 2;
  return LanternPlacement(
    dx: x,
    dy: y,
    depth: d,
    scale: _lerp(backScale, frontScale, f),
    opacity: _lerp(backOpacity, frontOpacity, f),
  );
}

/// Sway of one small lantern: +-4 degrees about its TOP-CENTRE, 3.4 s per leg,
/// ease-in-out, alternating, phase delayed by 0.9 s per lantern.
double swayRadians(
  double elapsedSeconds,
  int index, {
  double swayDeg = 4,
  double legSeconds = 3.4,
}) {
  final t = elapsedSeconds + index * 0.9;
  final p = (1 - math.cos(math.pi * t / legSeconds)) / 2; // 0 -> 1 -> 0, eased
  return (-swayDeg + 2 * swayDeg * p) * math.pi / 180.0;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class LanternOrbitLayer extends StatefulWidget {
  const LanternOrbitLayer({
    super.key,
    required this.bigLantern,
    required this.smallLanterns,
    this.reduceMotion = false,
  });

  /// Already sized (width = 55% of sky width, height = width * 738 / 640). It is centred for you.
  final Widget bigLantern;

  /// Exactly 4 prebuilt small lanterns (image + masked face + flame), each laid out in a box of
  /// width = 120 * (skyWidth / 390) and height = width * 292 / 260. Build them ONCE (not per frame).
  /// Do NOT add sway inside them: this layer applies it.
  final List<Widget> smallLanterns;

  /// true when MediaQuery.disableAnimations: lanterns stay at their start angles.
  final bool reduceMotion;

  @override
  State<LanternOrbitLayer> createState() => _LanternOrbitLayerState();
}

class _LanternOrbitLayerState extends State<LanternOrbitLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _elapsed = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    assert(widget.smallLanterns.length == 4);
    // ONE ticker drives all four lanterns. Never use 4 repeating AnimationControllers:
    // they drift apart and cannot be z-sorted against each other.
    _ticker = createTicker((d) => _elapsed.value = d.inMicroseconds / 1e6);
    if (!widget.reduceMotion) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final smallW = 120.0 * (size.width / 390.0);
        final smallH = smallW * 292.0 / 260.0;

        return RepaintBoundary(
          child: ValueListenableBuilder<double>(
            valueListenable: _elapsed,
            builder: (context, t, _) {
              final back = <Widget>[];
              final front = <Widget>[];
              for (var i = 0; i < lanternSlots.length; i++) {
                final (orbit, idx) = lanternSlots[i];
                final p = placeLantern(
                  orbit: orbit,
                  index: idx,
                  elapsedSeconds: t,
                  size: size,
                );
                final w = Positioned(
                  key: ValueKey(
                    'small-lantern-$i',
                  ), // keeps each lantern's state when it changes layer
                  left: size.width / 2 + p.dx - smallW / 2,
                  top: size.height / 2 + p.dy - smallH / 2,
                  width: smallW,
                  height: smallH,
                  child: Opacity(
                    opacity: p.opacity,
                    child: Transform.scale(
                      scale: p.scale, // scales about the lantern's own centre
                      child: Transform.rotate(
                        angle: swayRadians(t, i),
                        alignment: Alignment.topCenter, // pivot = top-centre
                        child: widget.smallLanterns[i],
                      ),
                    ),
                  ),
                );
                (p.inFront ? front : back).add(w);
              }

              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  ...back, // behind the big lantern (top half of each ellipse)
                  KeyedSubtree(
                    key: const ValueKey('big-lantern'),
                    child: Center(child: widget.bigLantern),
                  ),
                  ...front, // in front of the big lantern (bottom half)
                ],
              );
            },
          ),
        );
      },
    );
  }
}
