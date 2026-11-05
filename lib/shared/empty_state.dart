import 'package:flutter/material.dart';

import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.child,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: AppColors.ink3),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink3,
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: 16),
            AppTap(
              onTap: onAction,
              enabled: onAction != null,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    action!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
