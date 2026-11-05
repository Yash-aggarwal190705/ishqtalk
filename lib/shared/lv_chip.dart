import 'package:flutter/material.dart';

import '../foundation/app_theme.dart';

class LvChip extends StatelessWidget {
  const LvChip({super.key, required this.level, this.gray = false});

  final int level;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: gray ? AppColors.levelGray : null,
        gradient: gray ? null : AppGradients.level,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.white80,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Lv$level',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
