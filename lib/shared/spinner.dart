import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class Spinner extends StatelessWidget {
  const Spinner({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final Color color = light ? AppColors.white : AppColors.primary;
    final String svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 28 28"><circle cx="14" cy="14" r="11" fill="none" stroke="${appColorHex(color)}" stroke-width="3.500" stroke-linecap="round" stroke-dasharray="52 18"/></svg>';
    return Spin(
      duration: const Duration(milliseconds: 800),
      child: SvgPicture.string(
        svg,
        width: 18,
        height: 18,
        excludeFromSemantics: true,
      ),
    );
  }
}
