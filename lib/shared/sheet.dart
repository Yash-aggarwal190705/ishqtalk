import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class Sheet extends StatelessWidget {
  const Sheet({
    super.key,
    required this.child,
    required this.close,
    this.instant = false,
    this.barrierColor = AppColors.ink30,
    this.barrierBlurSigma = 0,
    this.cornerRadius = 20,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 32),
    this.maxHeightFraction = .9,
    this.avoidKeyboard = false,
    this.childScrolls = false,
  }) : assert(maxHeightFraction > 0 && maxHeightFraction <= 1);
  final Widget child;
  final VoidCallback close;
  final bool instant;
  final Color barrierColor;
  final double barrierBlurSigma;
  final double cornerRadius;
  final EdgeInsets padding;
  final double maxHeightFraction;
  final bool avoidKeyboard;

  /// Lets forms keep their actions pinned while scrolling their input area.
  final bool childScrolls;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: LayoutBuilder(
      builder: (context, bounds) {
        final double keyboard = avoidKeyboard
            ? MediaQuery.viewInsetsOf(context).bottom.clamp(0, bounds.maxHeight)
            : 0;
        final double available = math.max(0, bounds.maxHeight - keyboard);
        final EdgeInsets contentPadding = padding.copyWith(
          bottom: padding.bottom + MediaQuery.paddingOf(context).bottom,
        );
        final Widget handle = Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.all(Radius.circular(99)),
            ),
          ),
        );
        final Widget body = DefaultTextStyle.merge(
          style: const TextStyle(color: AppColors.ink),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              handle,
              if (childScrolls) Flexible(child: child) else child,
            ],
          ),
        );
        Widget barrier = Container(color: barrierColor);
        if (barrierBlurSigma > 0) {
          barrier = ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: barrierBlurSigma,
                sigmaY: barrierBlurSigma,
              ),
              child: barrier,
            ),
          );
        }
        return FadeIn(
          instant: instant,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: close,
            child: Stack(
              fit: StackFit.expand,
              children: [
                barrier,
                Padding(
                  padding: EdgeInsets.only(bottom: keyboard),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: SlideUp(
                        instant: instant,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(cornerRadius),
                          ),
                          child: Container(
                            width: double.infinity,
                            color: AppColors.white,
                            constraints: BoxConstraints(
                              maxHeight: available * maxHeightFraction,
                            ),
                            child: childScrolls
                                ? Padding(padding: contentPadding, child: body)
                                : SingleChildScrollView(
                                    padding: contentPadding,
                                    child: body,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
