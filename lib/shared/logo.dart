import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 96, this.flameSize, this.tailRadius = 2});

  final double size;
  final double? flameSize;
  final double tailRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppGradients.bgBrand,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: SizedBox(
        width: size * 0.66,
        height: size * 0.62,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white25,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: 8,
              bottom: -6,
              child: Transform.rotate(
                angle: 0.7853981633974483,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.white25,
                    borderRadius: BorderRadius.all(Radius.circular(tailRadius)),
                  ),
                ),
              ),
            ),
            AppIcon(
              name: 'flame',
              size: flameSize ?? size * 0.31,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
