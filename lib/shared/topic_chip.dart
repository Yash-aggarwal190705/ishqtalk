import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class TopicChip extends StatelessWidget {
  const TopicChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String check =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="none" stroke="${appColorHex(AppColors.white)}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.500l3.200 3L13 4.500"/></svg>';
    return AppTap(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected) ...<Widget>[
              SizedBox(
                width: 14,
                height: 14,
                child: SvgPicture.string(check, excludeFromSemantics: true),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
