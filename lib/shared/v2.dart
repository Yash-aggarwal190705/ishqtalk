import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../foundation/app_theme.dart';

// ---------------------------------------------------------------------------
// v2 shared building blocks (from v2_shared_widgets.dart, adapted to the
// app's existing tokens/theme — no google_fonts/intl).
// ---------------------------------------------------------------------------

/// CSS linear-gradient(angle deg, ...) with the exact CSS gradient-line
/// length for any box size. 0deg = to top, 90deg = to right, 135deg = down-right.
class CssAngle extends GradientTransform {
  const CssAngle(this.deg);
  final double deg;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double a = deg * math.pi / 180;
    final double len =
        (bounds.width * math.sin(a)).abs() +
        (bounds.height * math.cos(a)).abs();
    final Offset c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.rotationZ(a + math.pi) *
        Matrix4.diagonal3Values(1, len / bounds.height, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);
  }
}

LinearGradient cssLinear(
  double deg,
  List<Color> colors, [
  List<double>? stops,
]) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: colors,
  stops: stops,
  transform: CssAngle(deg),
);

// ---------------------------------------------------------------------------
// Neo button (primaryBtn/neo): 52 tall, radius 20, 2px ink border, hard 3,3
// ink shadow. Pressed: moves 3,3, no shadow. Disabled: gradient (vip) KEEPS
// its gradient; the red (danger) variant goes flat `card`.
// ---------------------------------------------------------------------------
class NeoButton extends StatefulWidget {
  const NeoButton(
    this.label, {
    super.key,
    this.onPressed,
    this.danger = false,
    this.fill = true,
    this.hPad = 32,
  });

  final String label;
  final VoidCallback? onPressed; // null = disabled
  final bool danger;
  final bool fill; // false = hug the label
  final double hPad;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final bool pressed = _down && enabled;
    final BoxDecoration deco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: enabled ? AppColors.ink : AppColors.divider,
        width: 2,
      ),
      color: widget.danger
          ? (enabled ? AppColors.danger : AppColors.card)
          : null,
      gradient: widget.danger
          ? null
          : cssLinear(135, const [AppColors.vipA, AppColors.vipB]),
      boxShadow: (enabled && !pressed)
          ? const <BoxShadow>[
              BoxShadow(color: AppColors.ink, offset: Offset(3, 3)),
            ]
          : null,
    );
    final Color fg = !enabled
        ? AppColors.ink60
        : (widget.danger ? AppColors.white : AppColors.ink);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: Transform.translate(
          offset: pressed ? const Offset(3, 3) : Offset.zero,
          child: Container(
            height: 52,
            width: widget.fill ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.fill ? 0 : widget.hPad,
            ),
            decoration: deco,
            child: Center(
              widthFactor: widget.fill ? null : 1,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Switch (settings.tsx): button 48 tall; "On"/"Off" label 28 wide, right
// aligned, 14/600 (On = ink, Off = ink/75), gap 8, track 48x28 (border 2,
// radius full). On: border+fill primary, thumb soft shadow; Off: border
// lvGray, fill card, thumb ring lvGray 1.5. Thumb 20, 4px inside the outer
// edge (Off x 4..24, On x 24..44), animates 150 ms.
// ---------------------------------------------------------------------------
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.on,
    required this.onChanged,
    required this.label,
  });

  final bool on;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: on,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!on),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 28,
                child: Text(
                  on ? 'On' : 'Off',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: on ? AppColors.ink : AppColors.sub,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  color: on ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: on ? AppColors.primary : AppColors.lvGray,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      left: on ? 24 : 4,
                      top: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: on
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : const <BoxShadow>[
                                  BoxShadow(
                                    color: AppColors.lvGray,
                                    spreadRadius: 1.5,
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ActionSheet (inbox): scrim ink@50, radius 28, padding 0/8/0/8+safe, handle
// 40x4 with 8 below. Sheet (ui.tsx): scrim ink@30, radius 20, padding
// 16/8/16/32+safe, handle with 16 below.
// ---------------------------------------------------------------------------
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool action = false,
  bool fullHeight = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    useSafeArea: false,
    barrierColor: action || fullHeight ? AppColors.scrim50 : AppColors.scrim30,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (ctx) {
      final MediaQueryData mq = MediaQuery.of(ctx);
      final double bottom = mq.viewPadding.bottom;
      final double kb = mq.viewInsets.bottom;
      final double radius = action || fullHeight ? 28 : 20;
      final Widget handle = Center(
        child: Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.only(bottom: action ? 8 : 16),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
      final Widget inner = Column(
        mainAxisSize: fullHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          handle,
          fullHeight
              ? Expanded(child: builder(ctx))
              : Flexible(child: SingleChildScrollView(child: builder(ctx))),
        ],
      );
      final EdgeInsets pad = action
          ? EdgeInsets.fromLTRB(0, 8, 0, 8 + bottom)
          : fullHeight
          ? EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom)
          : EdgeInsets.fromLTRB(16, 8, 16, 32 + bottom);
      final double maxH = fullHeight
          ? mq.size.height - 40
          : mq.size.height * 0.9;
      return Padding(
        padding: EdgeInsets.only(bottom: kb),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxH),
          width: double.infinity,
          padding: pad,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          ),
          child: inner,
        ),
      );
    },
  );
}

/// Centered dialog: scrim ink@50, side margin 24, radius 28, padding 24.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color scrim = AppColors.scrim50,
  double radius = 28,
  double padding = 24,
  Key? dialogKey,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: scrim,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (c, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: child,
    ),
    pageBuilder: (ctx, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            key: dialogKey,
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: builder(ctx),
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Snackbar: dark pill, one at a time, 2.2s, fade in 250ms. Hide on dispose.
// ---------------------------------------------------------------------------
class AppSnack {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    required double bottom,
    int ms = 2200,
  }) {
    hide();
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        bottom: bottom,
        child: _SnackBody(message),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _timer = Timer(Duration(milliseconds: ms), hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _SnackBody extends StatelessWidget {
  const _SnackBody(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
    builder: (_, v, child) => Opacity(opacity: v, child: child),
    child: Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.white,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Shimmer skeleton: one ShimmerScope per skeleton list, bars move in sync.
// ---------------------------------------------------------------------------
class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});

  final Widget child;

  static Animation<double> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerInherited>()!.t;

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ShimmerInherited(t: _c, child: widget.child);
}

class _ShimmerInherited extends InheritedWidget {
  const _ShimmerInherited({required this.t, required super.child});

  final Animation<double> t;

  @override
  bool updateShouldNotify(_ShimmerInherited old) => false;
}

class _ShimmerShift extends GradientTransform {
  const _ShimmerShift(this.pos);

  final double pos;

  @override
  Matrix4? transform(Rect b, {TextDirection? textDirection}) =>
      Matrix4.translationValues(b.left + pos, 0, 0) *
      Matrix4.diagonal3Values(720 / b.width, 1, 1) *
      Matrix4.translationValues(-b.left, 0, 0);
}

/// Dashed rounded rectangle (Edit profile add-photo tile: 1.5px dashed
/// #CFC8E6, radius 20).
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({
    this.color = const Color(0xFFCFC8E6),
    this.width = 1.5,
    this.radius = 20,
    this.dash = 4.5,
    this.gap = 3,
  });

  final Color color;
  final double width, radius, dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(width / 2),
          Radius.circular(radius - width / 2),
        ),
      );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final PathMetric m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + dash, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter oldDelegate) => false;
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.w,
    this.h,
    this.radius = 4,
    this.circle = false,
  });

  final double? w;
  final double? h;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final Animation<double> t = ShimmerScope.of(context);
    return AnimatedBuilder(
      animation: t,
      builder: (_, _) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const <Color>[
              AppColors.divider,
              AppColors.card,
              AppColors.divider,
            ],
            stops: const <double>[0, .5, 1],
            transform: _ShimmerShift(-360 + 720 * t.value),
          ),
        ),
      ),
    );
  }
}
