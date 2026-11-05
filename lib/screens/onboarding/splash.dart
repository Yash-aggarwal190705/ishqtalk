import 'package:flutter/material.dart';

import '../../foundation/app_theme.dart';
import '../../shared/logo.dart';
import '../../shared/portrait.dart';

class Splash extends StatelessWidget {
  const Splash({super.key, this.instant = false});
  final bool instant;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final double size = (bounds.maxWidth * .26).clamp(80, 96);
      final double fontSize = (bounds.maxWidth * .075).clamp(24, 30);
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.bgSplash),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -12,
              left: 4,
              right: 4,
              height: bounds.maxHeight * .54,
              child: Column(
                children: [
                  for (int row = 0; row < 4; row++) ...[
                    if (row > 0) const SizedBox(height: 4),
                    Expanded(
                      child: Row(
                        children: [
                          for (int col = 0; col < 3; col++) ...[
                            if (col > 0) const SizedBox(width: 4),
                            Expanded(
                              child: Portrait(
                                seed: row * 3 + col + 2,
                                borderRadius: BorderRadius.circular(8),
                                child: const ColoredBox(
                                  color: AppColors.white25,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bounds.maxHeight * .55,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.splashFade),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Logo(size: size, flameSize: 30, tailRadius: 4),
                  const SizedBox(height: 12),
                  Text(
                    'IshqTalk',
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
