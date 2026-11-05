import 'package:flutter/material.dart';

import '../../foundation/app_theme.dart';

/// CSS focus-visible outline: two pixels, two pixels outside the button.
class LoginButtonFocus extends StatefulWidget {
  const LoginButtonFocus({
    super.key,
    required this.child,
    required this.onActivate,
    this.radius = 14,
    this.offset = 2,
  });
  final Widget child;
  final VoidCallback? onActivate;
  final double radius;
  final double offset;

  @override
  State<LoginButtonFocus> createState() => _LoginButtonFocusState();
}

class _LoginButtonFocusState extends State<LoginButtonFocus> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    enabled: widget.onActivate != null,
    onShowFocusHighlight: (value) => setState(() => _focused = value),
    actions: {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) {
          widget.onActivate?.call();
          return null;
        },
      ),
    },
    child: CustomPaint(
      foregroundPainter: _focused && widget.onActivate != null
          ? _FocusOutline(widget.radius, widget.offset)
          : null,
      child: widget.child,
    ),
  );
}

class _FocusOutline extends CustomPainter {
  const _FocusOutline(this.radius, this.offset);
  final double radius;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).inflate(offset + 1),
        Radius.circular(radius + offset + 1),
      ),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_FocusOutline oldDelegate) =>
      radius != oldDelegate.radius || offset != oldDelegate.offset;
}
