import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    this.seed = 0,
    this.child,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final int seed;
  final Widget? child;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  static const Color _skin = AppColors.portraitSkin;

  @override
  Widget build(BuildContext context) {
    assert(seed >= 0);
    final int paletteIndex = (seed % 8) * 2;
    final Color first = AppColors.portraitBackgrounds[paletteIndex];
    final Color second = AppColors.portraitBackgrounds[paletteIndex + 1];
    final Color hair =
        AppColors.portraitHair[seed % AppColors.portraitHair.length];
    final String svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 130" preserveAspectRatio="xMidYMax slice"><ellipse cx="50" cy="140" rx="48" ry="42" fill="${appColorHex(AppColors.white)}" fill-opacity=".55"/><ellipse cx="50" cy="52" rx="24" ry="27" fill="${appColorHex(hair)}"/><ellipse cx="50" cy="56" rx="17" ry="21" fill="${appColorHex(_skin)}"/><path d="M33 50c4-14 30-14 34 0-8-6-26-6-34 0z" fill="${appColorHex(hair)}"/><rect x="44" y="72" width="12" height="14" rx="5" fill="${appColorHex(_skin)}"/></svg>';
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: CssLinearGradient(
              degrees: 160,
              colors: <Color>[first, second],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SvgPicture.string(
                svg,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                excludeFromSemantics: true,
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}
