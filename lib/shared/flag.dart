import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class Flag extends StatelessWidget {
  const Flag({super.key, required this.country});

  final String country;

  @override
  Widget build(BuildContext context) {
    final bool pakistan = country == 'Pakistan';
    final String svg = pakistan
        ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 14 10"><rect width="14" height="10" fill="${appColorHex(AppColors.flagPakistan)}"/><rect width="3.500" height="10" fill="${appColorHex(AppColors.white)}"/><circle cx="9" cy="5" r="2.200" fill="${appColorHex(AppColors.white)}"/><circle cx="9.800" cy="4.400" r="1.900" fill="${appColorHex(AppColors.flagPakistan)}"/></svg>'
        : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 14 10"><rect width="14" height="3.400" fill="${appColorHex(AppColors.flagIndiaOrange)}"/><rect y="3.300" width="14" height="3.400" fill="${appColorHex(AppColors.white)}"/><rect y="6.600" width="14" height="3.400" fill="${appColorHex(AppColors.flagIndiaGreen)}"/><circle cx="7" cy="5" r="1.200" fill="none" stroke="${appColorHex(AppColors.ink)}" stroke-width=".5"/></svg>';
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: SizedBox(
        width: 14,
        height: 10,
        child: SvgPicture.string(
          svg,
          fit: BoxFit.fill,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
