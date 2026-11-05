import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class FrogAvatar extends StatelessWidget {
  const FrogAvatar({super.key, this.size = 80, this.ring = 3});

  final double size;
  final double ring;

  @override
  Widget build(BuildContext context) {
    final String frog =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80"><ellipse cx="40" cy="48" rx="26" ry="22" fill="${appColorHex(AppColors.frogYellow)}"/><circle cx="26" cy="28" r="10" fill="${appColorHex(AppColors.frogYellow)}"/><circle cx="54" cy="28" r="10" fill="${appColorHex(AppColors.frogYellow)}"/><circle cx="26" cy="28" r="6" fill="${appColorHex(AppColors.white)}"/><circle cx="54" cy="28" r="6" fill="${appColorHex(AppColors.white)}"/><circle cx="27" cy="29" r="3" fill="${appColorHex(AppColors.frogEye)}"/><circle cx="53" cy="29" r="3" fill="${appColorHex(AppColors.frogEye)}"/><path d="M27 52c8 7 18 7 26 0" stroke="${appColorHex(AppColors.frogMouth)}" stroke-width="3" fill="none" stroke-linecap="round"/><circle cx="20" cy="46" r="4" fill="${appColorHex(AppColors.frogBlush)}" fill-opacity=".7"/><circle cx="60" cy="46" r="4" fill="${appColorHex(AppColors.frogBlush)}" fill-opacity=".7"/></svg>';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const CssLinearGradient(
          degrees: 160,
          colors: <Color>[AppColors.profileA, AppColors.profileB],
        ),
        border: Border.all(color: AppColors.white85, width: ring),
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.string(
        frog,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
  }
}
