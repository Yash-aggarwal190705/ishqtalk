import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

const Curve cssEase = Cubic(0.25, 0.1, 0.25, 1);
const Curve tailwindTransition = Cubic(0.4, 0, 0.2, 1);

bool animationsDisabled(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// An explicitly injected snapshot policy. Production leaves this absent.
/// Unlike `instant`, it freezes continuous animations at their initial phase,
/// retaining negative delays rather than treating them as reduced motion.
class MotionScope extends InheritedWidget {
  const MotionScope({
    super.key,
    required super.child,
    this.freezeLoops = false,
  });

  final bool freezeLoops;

  static bool loopsFrozen(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionScope>()?.freezeLoops ??
      false;

  @override
  bool updateShouldNotify(MotionScope oldWidget) =>
      freezeLoops != oldWidget.freezeLoops;
}

enum _EntranceKind { fade, slideIn, slideUp, rise, shake }

class _Entrance extends StatefulWidget {
  const _Entrance({
    required this.child,
    required this.kind,
    required this.duration,
    this.delay = Duration.zero,
    this.instant = false,
    this.play = true,
    this.trigger = 0,
  });

  final Widget child;
  final _EntranceKind kind;
  final Duration duration;
  final Duration delay;
  final bool instant;
  final bool play;
  final Object trigger;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool? _disabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configure();
  }

  @override
  void didUpdateWidget(covariant _Entrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger || oldWidget.play != widget.play) {
      _disabled = null;
    }
    _configure();
  }

  void _configure() {
    final bool disabled =
        widget.instant || !widget.play || animationsDisabled(context);
    if (disabled == _disabled) return;
    _disabled = disabled;
    _timer?.cancel();
    _controller.stop();
    if (disabled) {
      _controller.value = 1;
    } else if (widget.delay > Duration.zero) {
      _controller.value = 0;
      _timer = Timer(widget.delay, () => _controller.forward());
    } else {
      _controller.forward(
        from: (-widget.delay.inMicroseconds / widget.duration.inMicroseconds)
            .clamp(0.0, 1.0),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final double progress = Curves.easeOut.transform(_controller.value);
      return switch (widget.kind) {
        _EntranceKind.fade => Opacity(opacity: progress, child: child),
        _EntranceKind.slideIn => Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(24 * (1 - progress), 0),
            child: child,
          ),
        ),
        _EntranceKind.slideUp => FractionalTranslation(
          translation: Offset(0, 1 - progress),
          child: child,
        ),
        _EntranceKind.rise => Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - progress)),
            child: child,
          ),
        ),
        _EntranceKind.shake => Transform.translate(
          offset: Offset(shakeSequence.transform(_controller.value), 0),
          child: child,
        ),
      };
    },
  );
}

// CSS timing functions apply between each pair of keyframes, not over the
// entire TweenSequence. Keeping the curve on each tween preserves its stops.
final Animatable<double> shakeSequence = TweenSequence<double>([
  for (final (double from, double to) in <(double, double)>[
    (0, -8),
    (-8, 8),
    (8, -6),
    (-6, 6),
    (6, 0),
  ])
    TweenSequenceItem(
      tween: Tween(
        begin: from,
        end: to,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 20,
    ),
]);

final Animatable<double> pulseSequence = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOut)),
    weight: 50,
  ),
  TweenSequenceItem(
    tween: Tween(
      begin: 1.0,
      end: 0.0,
    ).chain(CurveTween(curve: Curves.easeInOut)),
    weight: 50,
  ),
]);

class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.instant = false});
  final Widget child;
  final bool instant;
  @override
  Widget build(BuildContext context) => _Entrance(
    kind: _EntranceKind.fade,
    duration: const Duration(milliseconds: 250),
    instant: instant,
    child: child,
  );
}

class SlideIn extends StatelessWidget {
  const SlideIn({super.key, required this.child, this.instant = false});
  final Widget child;
  final bool instant;
  @override
  Widget build(BuildContext context) => _Entrance(
    kind: _EntranceKind.slideIn,
    duration: const Duration(milliseconds: 280),
    instant: instant,
    child: child,
  );
}

class SlideUp extends StatelessWidget {
  const SlideUp({super.key, required this.child, this.instant = false});
  final Widget child;
  final bool instant;
  @override
  Widget build(BuildContext context) => _Entrance(
    kind: _EntranceKind.slideUp,
    duration: const Duration(milliseconds: 280),
    instant: instant,
    child: child,
  );
}

class Rise extends StatelessWidget {
  const Rise({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.instant = false,
  });
  final Widget child;
  final Duration delay;
  final bool instant;
  @override
  Widget build(BuildContext context) => _Entrance(
    kind: _EntranceKind.rise,
    duration: const Duration(milliseconds: 300),
    delay: delay,
    instant: instant,
    child: child,
  );
}

class Shake extends StatelessWidget {
  const Shake({
    super.key,
    required this.child,
    this.play = true,
    this.trigger = 0,
    this.instant = false,
  });
  final Widget child;
  final bool play;
  final Object trigger;
  final bool instant;
  @override
  Widget build(BuildContext context) => _Entrance(
    kind: _EntranceKind.shake,
    duration: const Duration(milliseconds: 400),
    play: play,
    trigger: trigger,
    instant: instant,
    child: child,
  );
}

typedef LoopBuilder = Widget Function(
  BuildContext context,
  double phase,
  bool idle,
  Widget? child,
);

/// One linear CSS animation clock; individual keyframes apply their own curves.
class LoopMotion extends StatefulWidget {
  const LoopMotion({
    super.key,
    required this.duration,
    required this.builder,
    this.delay = Duration.zero,
    this.child,
  });

  final Duration duration;
  final Duration delay;
  final LoopBuilder builder;
  final Widget? child;

  @override
  State<LoopMotion> createState() => _LoopMotionState();
}

class _LoopMotionState extends State<LoopMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _waiting = false;
  bool? _stopped;
  bool _reduced = false;

  double get _initialPhase => widget.delay.isNegative
      ? (-widget.delay.inMicroseconds % widget.duration.inMicroseconds) /
            widget.duration.inMicroseconds
      : 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _initialPhase,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = animationsDisabled(context);
    final bool stopped = _reduced || MotionScope.loopsFrozen(context);
    if (stopped == _stopped) return;
    final bool first = _stopped == null;
    _stopped = stopped;
    _timer?.cancel();
    _waiting = false;
    if (stopped) {
      _controller.stop();
      // A frozen first frame still precedes positive animation delays.
      _waiting = first && !_reduced && widget.delay > Duration.zero;
    } else if (first && widget.delay > Duration.zero) {
      _waiting = true;
      _timer = Timer(widget.delay, () {
        setState(() => _waiting = false);
        _controller.repeat();
      });
    } else {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LoopMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (_stopped == false && !_waiting) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) =>
        widget.builder(context, _controller.value, _reduced || _waiting, child),
  );
}

class PulseDot extends StatelessWidget {
  const PulseDot({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.instant = false,
  });
  final Widget child;
  final Duration delay;
  // Entrance-only flag: deliberately does not stop this loop.
  final bool instant;
  @override
  Widget build(BuildContext context) => LoopMotion(
    duration: const Duration(milliseconds: 1200),
    delay: delay,
    child: child,
    builder: (context, phase, idle, child) {
      final double value = pulseSequence.transform(phase);
      return Opacity(
        opacity: idle ? 1 : .25 + .75 * value,
        child: Transform.scale(scale: idle ? 1 : .8 + .3 * value, child: child),
      );
    },
  );
}

class Spin extends StatelessWidget {
  const Spin({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.instant = false,
  });
  final Widget child;
  final Duration duration;
  final bool instant;
  @override
  Widget build(BuildContext context) => LoopMotion(
    duration: duration,
    child: child,
    builder: (context, phase, idle, child) =>
        Transform.rotate(angle: idle ? 0 : phase * math.pi * 2, child: child),
  );
}

class Shimmer extends StatelessWidget {
  const Shimmer({super.key, required this.child, this.instant = false});
  final Widget child;
  final bool instant;
  @override
  Widget build(BuildContext context) => LoopMotion(
    duration: const Duration(milliseconds: 1400),
    child: child,
    builder: (context, phase, idle, child) => CustomPaint(
      painter: _ShimmerPainter(idle ? 0 : -360 + phase * 720),
      child: child,
    ),
  );
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter(this.position);
  final double position;
  @override
  void paint(Canvas canvas, Size size) {
    const LinearGradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[AppColors.skeleton, AppColors.card, AppColors.skeleton],
      stops: <double>[0, .5, 1],
      tileMode: TileMode.repeated,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(position, 0, 720, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.position != position;
}

/// A source button with no implicit visual press effect or Material splash.
class AppTap extends StatelessWidget {
  const AppTap({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.label,
  });
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final String? label;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled && onTap != null,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: child,
    ),
  );
}

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.scale = .98,
    this.duration = const Duration(milliseconds: 150),
    this.behavior = HitTestBehavior.opaque,
    this.onPressedChanged,
  });
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scale;
  final Duration duration;
  final HitTestBehavior behavior;
  final ValueChanged<bool>? onPressedChanged;
  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;
  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onPressedChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled && widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: enabled ? widget.onTap : null,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: enabled && _pressed ? widget.scale : 1,
          duration: animationsDisabled(context)
              ? Duration.zero
              : widget.duration,
          curve: tailwindTransition,
          child: widget.child,
        ),
      ),
    );
  }
}
