import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_theme.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key, this.size = 88});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: AppGradients.bgBrand,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .35),
          offset: const Offset(0, 10),
          blurRadius: 30,
        ),
      ],
    ),
    child: SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<path d="M10 6h28a6 6 0 016 6v18a6 6 0 01-6 6H25l-9 7v-7h-6a6 6 0 01-6-6V12a6 6 0 016-6z" fill="${appColorHex(AppColors.white)}"/>'
      '<path d="M24 29.500s-8.500-5-8.500-10.500a4.700 4.700 0 018.500-2.700A4.700 4.700 0 0132.500 19C32.500 24.500 24 29.500 24 29.500z" fill="${appColorHex(AppColors.cta)}"/>'
      '</svg>',
      width: size * .56,
      height: size * .56,
      excludeFromSemantics: true,
    ),
  );
}
