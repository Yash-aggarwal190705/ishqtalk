import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../foundation/app_motion.dart';
import '../../shared/portrait.dart';
import 'big_lantern.dart';
import 'lantern_orbit.dart';

/// Port of `SkyLantern.tsx`: gradient + 130 seeded stars + mountains (static),
/// twinkling stars (one Ticker), and the big + 4 small lanterns driven by
/// `LanternOrbitLayer` (single ticker, tilted ellipses, depth z-order).
/// The big lantern, halo and flame are the reference implementations from
/// `big_lantern.dart`.
class SkyLantern extends StatefulWidget {
  const SkyLantern({
    super.key,
    this.onRelease,
    this.portraits = defaultPortraits,
  });

  final VoidCallback? onRelease;
  final List<String> portraits;

  static const List<String> defaultPortraits = <String>[
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&crop=faces&w=160&h=160&q=70',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&crop=faces&w=160&h=160&q=70',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&crop=faces&w=160&h=160&q=70',
    'https://images.unsplash.com/photo-1745434159123-4908d0b9df94?auto=format&fit=crop&crop=faces&w=160&h=160&q=70',
  ];

  @override
  State<SkyLantern> createState() => _SkyLanternState();
}

const double _smallAspect = 292 / 260;

const List<Color> _skyBg = <Color>[
  Color(0xFF0D0A24),
  Color(0xFF3A1646),
  Color(0xFFC2441B),
];
const Color _starColor = Color(0xFFFFE9C4);
const Color _mountainPath1 = Color(0xFF1A0A22);
const Color _mountainPath2 = Color(0xFF12061A);

// ---------------------------------------------------------------------------
// mulberry32 (seed 11), copied exactly from SkyLantern.tsx so star positions
// match. JS bitwise ops are signed 32-bit; Dart ints are 64-bit.
// ---------------------------------------------------------------------------
int _i32(int v) => v.toSigned(32);
int _u32(int v) => v & 0xFFFFFFFF;
int _shrU(int v, int n) => _u32(v) >> n;
int _imul(int a, int b) => _i32(a * b);

double Function() _rng(int seed) {
  int a = seed;
  return () {
    a = _i32(_i32(a) + 0x6d2b79f5);
    int t = _i32(_imul(_i32(a ^ _shrU(a, 15)), 1 | a));
    t = _i32(t + _imul(_i32(t ^ _shrU(t, 7)), 61 | t));
    final int r = _i32(t ^ _shrU(t, 14));
    return _u32(r) / 4294967296;
  };
}

class _Star {
  const _Star({
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
    this.twinkle = false,
    this.delay = 0,
    this.duration = 0,
  });
  final double left; // percent
  final double top; // percent
  final double size; // px
  final double opacity;
  final bool twinkle;
  final double delay; // seconds
  final double duration; // seconds
}

List<_Star> _generateStars() {
  final double Function() r = _rng(11);
  return List<_Star>.generate(130, (i) {
    final bool tw = i % 7 == 0;
    return _Star(
      left: r() * 100,
      top: r() * 80,
      size: 1 + r() * 1.6,
      opacity: 0.25 + r() * 0.65,
      twinkle: tw,
      delay: -r() * 4,
      duration: tw ? 3 + (i % 5).toDouble() : 0,
    );
  });
}

double _easeInOut(double t) => Curves.easeInOut.transform(t);

double _alternatePhase(double elapsed, double period, double delay) {
  final double p = ((elapsed - delay) % period + period) % period;
  return p < period / 2 ? p * 2 / period : 2 - p * 2 / period;
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.stars});
  final List<_Star> stars;

  static Path _path1() => Path()
    ..moveTo(0, 120)
    ..lineTo(0, 78)
    ..lineTo(40, 62)
    ..lineTo(78, 74)
    ..lineTo(120, 50)
    ..lineTo(160, 70)
    ..lineTo(180, 40)
    ..lineTo(188, 20)
    ..lineTo(195, 8)
    ..lineTo(202, 20)
    ..lineTo(210, 40)
    ..lineTo(232, 66)
    ..lineTo(270, 52)
    ..lineTo(312, 72)
    ..lineTo(350, 56)
    ..lineTo(390, 70)
    ..lineTo(390, 120)
    ..close();

  static Path _path2() => Path()
    ..moveTo(180, 120)
    ..lineTo(180, 54)
    ..lineTo(210, 54)
    ..lineTo(210, 120)
    ..close()
    ..moveTo(96, 120)
    ..lineTo(96, 84)
    ..lineTo(102, 66)
    ..lineTo(108, 84)
    ..lineTo(108, 120)
    ..close()
    ..moveTo(300, 120)
    ..lineTo(300, 80)
    ..lineTo(307, 60)
    ..lineTo(314, 80)
    ..lineTo(314, 120)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect full = Offset.zero & size;
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _skyBg,
          stops: <double>[0, .52, 1],
        ).createShader(full),
    );
    for (final _Star star in stars) {
      canvas.drawCircle(
        Offset(star.left / 100 * size.width, star.top / 100 * size.height),
        star.size / 2,
        Paint()..color = _starColor.withValues(alpha: star.opacity),
      );
    }
    final double mTop = size.height * 0.86;
    final double sx = size.width / 390;
    final double sy = size.height * 0.14 / 120;
    canvas.save();
    canvas.translate(0, mTop);
    canvas.scale(sx, sy);
    canvas.drawPath(_path1(), Paint()..color = _mountainPath1);
    canvas.drawPath(_path2(), Paint()..color = _mountainPath2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => false;
}

class _TwinklePainter extends CustomPainter {
  const _TwinklePainter({required this.stars, required this.elapsed});
  final List<_Star> stars;
  final double elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    for (final _Star star in stars) {
      final double e = _easeInOut(
        _alternatePhase(elapsed, star.duration * 2, star.delay),
      );
      canvas.drawCircle(
        Offset(star.left / 100 * size.width, star.top / 100 * size.height),
        star.size / 2,
        Paint()..color = _starColor.withValues(alpha: .15 + .85 * e),
      );
    }
  }

  @override
  bool shouldRepaint(_TwinklePainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}

// ---------------------------------------------------------------------------
// Face photo: 70% square, elliptical border radius, radial edge mask,
// saturation 1.1 / contrast 1.05.
// ---------------------------------------------------------------------------
class _LanternFace extends StatelessWidget {
  const _LanternFace({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double w = size * 0.70;
    final Widget photo = CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const Portrait(),
      errorWidget: (_, _, _) => const Portrait(),
    );
    final Widget filtered = ColorFiltered(
      colorFilter: ColorFilter.matrix(const <double>[
        1.1,
        0,
        0,
        0,
        0,
        0,
        1.1,
        0,
        0,
        0,
        0,
        0,
        1.1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(const <double>[
          1.05,
          0,
          0,
          0,
          -6.4,
          0,
          1.05,
          0,
          0,
          -6.4,
          0,
          0,
          1.05,
          0,
          -6.4,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: photo,
      ),
    );
    return Positioned(
      left: (size - w) / 2,
      top: size * 0.45 - w / 2,
      width: w,
      height: w,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const RadialGradient(
          radius: 1,
          colors: <Color>[Colors.black, Colors.transparent],
          stops: <double>[.88, 1],
        ).createShader(rect),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(w * .46, w * .50),
            topRight: Radius.elliptical(w * .46, w * .50),
            bottomLeft: Radius.elliptical(w * .42, w * .40),
            bottomRight: Radius.elliptical(w * .42, w * .40),
          ),
          child: SizedBox.expand(child: filtered),
        ),
      ),
    );
  }
}

class _SmallLanternSprite extends StatelessWidget {
  const _SmallLanternSprite({
    required this.image,
    required this.width,
    required this.height,
    required this.faceUrl,
    required this.flameDelaySeconds,
    required this.reduceMotion,
  });

  final AssetImage image;
  final double width;
  final double height;
  final String? faceUrl;
  final double flameDelaySeconds;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image(image: image, fit: BoxFit.contain),
        if (faceUrl != null) _LanternFace(url: faceUrl!, size: width),
        // Reference flame position for a small lantern: (44%, 81.6%), delay -i * 0.13 s.
        FlameGlow(
          boxWidth: width,
          boxHeight: height,
          xPct: 44,
          yPct: 81.6,
          delaySeconds: flameDelaySeconds,
          reduceMotion: reduceMotion,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sky
// ---------------------------------------------------------------------------
class _SkyLanternState extends State<SkyLantern>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  late final List<_Star> _stars;
  late final List<_Star> _twinklers;
  late final List<_Star> _statics;
  double _elapsed = 0;
  double _lastTick = 0;
  bool _running = false;
  bool _reduced = false;
  bool _precached = false;
  late final AssetImage _bigImage = const AssetImage(
    'assets/images/lantern_big.png',
  );
  late final AssetImage _smallImage = const AssetImage(
    'assets/images/lantern_small.png',
  );

  @override
  void initState() {
    super.initState();
    _stars = _generateStars();
    _twinklers = _stars.where((s) => s.twinkle).toList();
    _statics = _stars.where((s) => !s.twinkle).toList();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      // Enough for about 3x density; warm both caches.
      precacheImage(_bigImage, context);
      precacheImage(_smallImage, context);
    }
    _reduced = animationsDisabled(context) || MotionScope.loopsFrozen(context);
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncTicker();
  }

  bool get _appActive {
    final AppLifecycleState? state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  void _syncTicker() {
    final bool shouldRun = !_reduced && _appActive && mounted;
    if (shouldRun == _running) return;
    _running = shouldRun;
    if (shouldRun) {
      _lastTick = 0;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == 0) {
      _lastTick = elapsed.inMicroseconds / 1e6;
      return;
    }
    final double now = elapsed.inMicroseconds / 1e6;
    _elapsed += now - _lastTick;
    _lastTick = now;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final double k = w / 390;
    final double smallW = 120 * k;
    final double smallH = smallW * _smallAspect;
    final double t = _elapsed;

    // Reference big lantern: exactly 55% of the sky width, centered by the
    // orbit layer. Wrapped in Semantics for the "Start" button label.
    // container:true keeps the label exact instead of merging with children.
    final Widget big = Semantics(
      button: true,
      label: 'Start',
      child: ExcludeSemantics(
        child: BigLantern(
          skyWidth: w,
          onStart: widget.onRelease ?? () {},
          reduceMotion: _reduced,
        ),
      ),
    );
    final List<Widget> small = <Widget>[
      for (int i = 0; i < 4; i++)
        _SmallLanternSprite(
          image: _smallImage,
          width: smallW,
          height: smallH,
          faceUrl: widget.portraits.isEmpty
              ? null
              : widget.portraits[i % widget.portraits.length],
          flameDelaySeconds: -i * 0.13,
          reduceMotion: _reduced,
        ),
    ];

    // TickerMode mutes every ticker below (orbit layer, halo, flames) while
    // the app is backgrounded; the twinkle ticker above is stopped as well.
    return TickerMode(
      enabled: _appActive,
      child: RepaintBoundary(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _SkyPainter(stars: _statics)),
              if (!_reduced)
                CustomPaint(
                  painter: _TwinklePainter(stars: _twinklers, elapsed: t),
                ),
              LanternOrbitLayer(
                bigLantern: big,
                smallLanterns: small,
                reduceMotion: _reduced,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
