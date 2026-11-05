import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'login_logo.dart';
import 'login_button_focus.dart';
import 'onboarding_modal.dart';

class AccountChooser extends StatelessWidget {
  const AccountChooser({
    super.key,
    required this.pick,
    required this.addOther,
    required this.close,
    this.instant = false,
  });
  final VoidCallback pick;
  final VoidCallback addOther;
  final VoidCallback close;
  final bool instant;

  static const _accounts = [
    ('Alex Morgan', 'alex.morgan@example.com'),
    ('Sam Rivera', 'sam.rivera@example.com'),
    ('Taylor Kim', 'taylor.kim@example.com'),
  ];

  @override
  Widget build(BuildContext context) => OnboardingModal(
    close: close,
    instant: instant,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: LoginLogo(size: 32)),
        const SizedBox(height: 12),
        const Text(
          'Choose an account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          'to continue to YourApp',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.ink2),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 1, child: ColoredBox(color: AppColors.divider)),
        for (int i = 0; i < _accounts.length; i++) ...[
          LoginButtonFocus(
            onActivate: pick,
            radius: 0,
            offset: 0,
            child: AppTap(
              onTap: pick,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 1
                            ? AppColors.roseGold.withValues(alpha: .5)
                            : AppColors.primary10,
                      ),
                      child: Text(
                        _accounts[i].$1[0],
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: i == 1 ? AppColors.ink : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _accounts[i].$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _accounts[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.divider),
          ),
        ],
        LoginButtonFocus(
          onActivate: addOther,
          radius: 0,
          offset: 0,
          child: AppTap(
            onTap: addOther,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Text(
                      '＋',
                      style: TextStyle(
                        fontSize: 18,
                        height: 28 / 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add another account',
                    style: TextStyle(fontSize: 14, height: 20 / 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Demo account chooser',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, height: 1.5, color: AppColors.ink2),
        ),
      ],
    ),
  );
}
