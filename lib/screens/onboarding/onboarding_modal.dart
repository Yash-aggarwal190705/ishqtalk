import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../shared/sheet.dart';

class OnboardingModal extends StatelessWidget {
  const OnboardingModal({
    super.key,
    required this.child,
    required this.close,
    this.sheet = false,
    this.form = false,
    this.instant = false,
  });
  final Widget child;
  final VoidCallback close;
  final bool sheet;
  final bool form;
  final bool instant;

  Widget get _content => BlockSemantics(
    child: Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FocusScope(autofocus: true, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (sheet) {
      return Sheet(
        close: close,
        instant: instant,
        barrierColor: AppColors.ink35,
        barrierBlurSigma: 2,
        cornerRadius: 24,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        maxHeightFraction: .92,
        avoidKeyboard: true,
        childScrolls: form,
        child: _content,
      );
    }
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, bounds) => FadeIn(
          instant: instant,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: close,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: const ColoredBox(color: AppColors.ink35),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: bounds.maxWidth - 48,
                      constraints: BoxConstraints(
                        maxHeight: bounds.maxHeight * .9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: .25),
                            offset: const Offset(0, 20),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _content,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
