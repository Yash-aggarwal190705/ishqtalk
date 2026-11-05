import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'onboarding_modal.dart';

class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.close,
    this.instant = false,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback close;
  final bool instant;

  static const countries = [
    ('🇮🇳', 'India', '+91'),
    ('🇺🇸', 'United States', '+1'),
    ('🇬🇧', 'United Kingdom', '+44'),
    ('🇵🇰', 'Pakistan', '+92'),
    ('🇦🇪', 'United Arab Emirates', '+971'),
  ];

  @override
  Widget build(BuildContext context) => OnboardingModal(
    close: close,
    sheet: true,
    instant: instant,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Country code',
          style: TextStyle(
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (final (flag, name, code) in countries)
          AppTap(
            onTap: () => onSelect(code),
            child: Semantics(
              selected: code == selected,
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 24, height: 1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 14, height: 20 / 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 18,
                      child: code == selected
                          ? Container(
                              width: 18,
                              height: 18,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
