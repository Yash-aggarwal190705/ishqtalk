import 'package:flutter/material.dart';

import '../foundation/app_theme.dart';

class Badge extends StatelessWidget {
  const Badge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      constraints: const BoxConstraints(minWidth: 14),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          '$number',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            height: 12 / 10,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
