// big_lantern.dart
//
// Correct Flutter versions of: the big "Start" lantern, its soft halo, and the flickering flame.
// Everything for the big lantern lives inside ONE box of exactly 55% of the sky width.
// Pass it to LanternOrbitLayer(bigLantern: ...) from lantern_orbit.dart.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _lanternText = Color(0xFFB8400F);

class BigLantern extends StatefulWidget {
  const BigLantern({
    super.key,
    required this.skyWidth, // full sky width (NOT the safe-area width)
    required this.onStart,
    this.reduceMotion = false,
  });

  final double skyWidth;
  final VoidCallback onStart;
  final bool reduceMotion;

  @override
  State<BigLantern> createState() => _BigLanternState();
}

class _BigLanternState extends State<BigLantern> with TickerProviderStateMixin {
  late final AnimationController _halo = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _halo.repeat(reverse: true);
  }

  @override
  void dispose() {
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.skyWidth * 0.55; // 55% of the screen width, nothing else
    final h = w * 738 / 640; // lantern-big.png is 640 x 738

    return SizedBox(
      width: w,
      height: h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onStart,
        child: Stack(
          clipBehavior: Clip.none, // halo is bigger than the box on purpose
          children: [
            // 1) HALO: soft glow, 190% x 170% of the lantern box, centred on the lantern.
            Positioned(
              left: -0.45 * w,
              top: -0.35 * h,
              width: 1.90 * w,
              height: 1.70 * h,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _halo,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(_halo.value);
                    return Opacity(
                      opacity: 1.0 - 0.4 * t, // 1 -> .6
                      child: Transform.scale(
                        scale: 1.0 + 0.08 * t,
                        child: child,
                      ), // 1 -> 1.08
                    );
                  },
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        radius: 0.5, // fades to fully transparent exactly at the box edge
                        colors: [
                          Color.fromRGBO(255, 150, 50, 0.75),
                          Color.fromRGBO(255, 120, 30, 0.35),
                          Color.fromRGBO(255, 100, 20, 0.0),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2) LANTERN IMAGE, forced into the 55% box (never its intrinsic size).
            Positioned.fill(
              child: Image.asset(
                'assets/images/lantern_big.png',
                width: w,
                height: h,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),

            // 3) START LABEL, 30% from the lantern top, inside the lantern.
            Positioned(
              left: 0,
              right: 0,
              top: 0.30 * h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.string(
                    '<svg viewBox="0 0 56 56" xmlns="http://www.w3.org/2000/svg">'
                    '<rect x="4" y="12" width="32" height="32" rx="7" fill="#B8400F"/>'
                    '<path d="M40 24 L51 17 Q53 16 53 18.5 V37.5 Q53 40 51 39 L40 32 Z" fill="#B8400F"/>'
                    '</svg>',
                    width: 0.20 * w,
                    height: 0.20 * w,
                  ),
                  SizedBox(height: 0.03 * w),
                  Text(
                    'Start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _lanternText,
                      fontWeight: FontWeight.w700,
                      fontSize: 0.10 * w,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            // 4) FLAME at the bulb: (49.3%, 90.2%) of the lantern box. Width = 22% of the box.
            FlameGlow(
              boxWidth: w,
              boxHeight: h,
              xPct: 49.3,
              yPct: 90.2,
              delaySeconds: 0,
              reduceMotion: widget.reduceMotion,
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft flickering flame. Used by the big lantern (49.3, 90.2) and by each small lantern (44, 81.6).
/// It is positioned by PERCENT OF THE LANTERN BOX, so it always sits on the bulb.
class FlameGlow extends StatefulWidget {
  const FlameGlow({
    super.key,
    required this.boxWidth,
    required this.boxHeight,
    required this.xPct,
    required this.yPct,
    this.delaySeconds = 0,
    this.reduceMotion = false,
  });

  final double boxWidth, boxHeight;
  final double xPct, yPct; // centre of the flame, percent of the lantern box
  final double delaySeconds; // small lanterns use -i * 0.13
  final bool reduceMotion;

  @override
  State<FlameGlow> createState() => _FlameGlowState();
}

class _FlameGlowState extends State<FlameGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) {
      // negative CSS delay = start part-way through the cycle
      final phase =
          ((-widget.delaySeconds) / 0.9) % 1.0; // full out-and-back = 0.9 s
      _c.value = phase > 0.5 ? 1.0 - (phase - 0.5) * 2 : phase * 2;
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.boxWidth * 0.22;
    final cx = widget.boxWidth * widget.xPct / 100;
    final cy = widget.boxHeight * widget.yPct / 100;
    return Positioned(
      left: cx - d / 2,
      top: cy - d / 2,
      width: d,
      height: d,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_c.value);
            return Opacity(
              opacity: 0.7 + 0.3 * t, // .7 -> 1
              child: Transform.scale(
                scale: 0.9 + 0.25 * t,
                child: child,
              ), // .9 -> 1.15
            );
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                // CSS "radial-gradient(circle, ...)" is farthest-corner: radius = 0.7071 of the box
                radius: 0.7071,
                colors: [
                  Color(0xFFFFFBE6),
                  Color(0xFFFFE9A0),
                  Color.fromRGBO(255, 176, 60, 0.75),
                  Color.fromRGBO(255, 140, 0, 0.0),
                ],
                stops: [0.0, 0.28, 0.55, 0.75],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
