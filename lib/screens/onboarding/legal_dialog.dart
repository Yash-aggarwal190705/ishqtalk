import 'package:flutter/material.dart';

import '../../foundation/app_theme.dart';
import 'login_primary_button.dart';
import 'onboarding_modal.dart';

class LegalDialog extends StatelessWidget {
  const LegalDialog({
    super.key,
    required this.privacy,
    required this.close,
    this.instant = false,
  });
  final bool privacy;
  final VoidCallback close;
  final bool instant;

  @override
  Widget build(BuildContext context) => OnboardingModal(
    close: close,
    instant: instant,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          privacy ? 'Privacy Policy' : 'Terms of Use',
          style: const TextStyle(
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          privacy
              ? 'Placeholder policy. This prototype stores nothing on a server. Any data you enter stays on this device and is never sent anywhere.'
              : 'Placeholder terms. By using IshqTalk you agree to be respectful, to be at least 18 years old and to not share harmful content. This is a prototype and no real terms apply.',
          style: const TextStyle(
            fontSize: 14,
            height: 24 / 14,
            color: AppColors.ink2,
          ),
        ),
        const SizedBox(height: 16),
        LoginPrimaryButton(label: 'Close', onTap: close),
      ],
    ),
  );
}
