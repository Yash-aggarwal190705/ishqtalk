import 'package:flutter/material.dart';

import 'login_text_field.dart';

/// Natural document layout when there is room; scrollable inputs and pinned
/// actions when the keyboard reduces the sheet's available height.
class LoginFormLayout extends StatefulWidget {
  const LoginFormLayout({super.key, required this.body, required this.actions});
  final Widget body;
  final Widget actions;

  @override
  State<LoginFormLayout> createState() => _LoginFormLayoutState();
}

class _LoginFormLayoutState extends State<LoginFormLayout> {
  double? _lastInset;

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    if (_lastInset != inset) {
      _lastInset = inset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || inset == 0) return;
        BuildContext? field;
        FocusManager.instance.primaryFocus?.context?.visitAncestorElements((
          element,
        ) {
          if (element.widget is LoginTextField) {
            field = element;
            return false;
          }
          return true;
        });
        if (field != null) {
          Scrollable.ensureVisible(
            field!,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          );
        }
      });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ClipRect(
            clipper: const _FormViewportClipper(),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: widget.body,
            ),
          ),
        ),
        widget.actions,
      ],
    );
  }
}

class _FormViewportClipper extends CustomClipper<Rect> {
  const _FormViewportClipper();
  // Retain the source's 2px outer focus ring without painting scrolled content
  // over the pinned actions or grab handle.
  @override
  Rect getClip(Size size) => Rect.fromLTWH(-2, 0, size.width + 4, size.height);
  @override
  bool shouldReclip(_FormViewportClipper oldClipper) => false;
}
