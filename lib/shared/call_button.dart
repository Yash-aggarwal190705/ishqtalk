import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class CallButton extends StatelessWidget {
  const CallButton({super.key, this.onList = false, this.onTap});

  final bool onList;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      label: 'Video call',
      onTap: onTap,
      enabled: onTap != null,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onList ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: AppColors.black.withValues(alpha: .10),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -2,
            ),
          ],
        ),
        child: AppIcon(
          name: 'cam',
          size: 22,
          color: onList ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}
