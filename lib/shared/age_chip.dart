import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';
import 'flag.dart';

class AgeChip extends StatelessWidget {
  const AgeChip({super.key, required this.age, this.country});

  final int age;
  final String? country;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AppIcon(name: 'user', size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$age',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
          if (country != null) ...<Widget>[
            const SizedBox(width: 4),
            Flag(country: country!),
            const SizedBox(width: 4),
            Text(
              country!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.5,
                color: AppColors.ink2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
