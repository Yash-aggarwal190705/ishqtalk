import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class Coin extends StatelessWidget {
  const Coin({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    final String coinTop = appColorHex(AppColors.coinTop);
    final String coinBottom = appColorHex(AppColors.coinBottom);
    final String ring = appColorHex(AppColors.coinRing);
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><defs><linearGradient id="coinG" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="$coinTop"/><stop offset="1" stop-color="$coinBottom"/></linearGradient></defs><circle cx="12" cy="12" r="11" fill="url(#coinG)"/><circle cx="12" cy="12" r="7.500" fill="none" stroke="$ring" stroke-width="1.500"/><path d="M12 7.500l1.400 3 3.200.4-2.400 2.200.7 3.200L12 14.700 9.100 16.300l.7-3.200-2.400-2.200 3.200-.4z" fill="${appColorHex(AppColors.white)}"/></svg>',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
