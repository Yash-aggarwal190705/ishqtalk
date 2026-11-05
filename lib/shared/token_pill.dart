import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';
import 'coin.dart';

enum TokenPillVariant { soft, dark }

class TokenPill extends StatelessWidget {
  const TokenPill({
    super.key,
    required this.variant,
    this.onPlus,
    this.count = 5,
  });

  final TokenPillVariant variant;
  final VoidCallback? onPlus;
  final int count;

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Coin(),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: variant == TokenPillVariant.soft
                ? FontWeight.w600
                : FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
        if (variant == TokenPillVariant.dark) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.cta,
              shape: BoxShape.circle,
            ),
            child: const AppIcon(
              name: 'plus',
              size: 10,
              color: AppColors.ink,
              stroke: 3,
            ),
          ),
        ],
      ],
    );

    final Widget decorated = variant == TokenPillVariant.soft
        ? Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.coinBg,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: content,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 32,
                padding: const EdgeInsets.only(left: 8, right: 4),
                decoration: BoxDecoration(
                  color: AppColors.white60,
                  border: Border.all(color: AppColors.white, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: content,
              ),
            ),
          );

    return AppTap(onTap: onPlus, enabled: onPlus != null, child: decorated);
  }
}
