import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'login_button_focus.dart';
import 'login_provider_icons.dart';

class ProviderButton extends StatefulWidget {
  const ProviderButton({
    super.key,
    required this.provider,
    required this.onTap,
    this.disabled = false,
  });
  final LoginProvider provider;
  final VoidCallback onTap;
  final bool disabled;

  @override
  State<ProviderButton> createState() => _ProviderButtonState();
}

class _ProviderButtonState extends State<ProviderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool primary = widget.provider == LoginProvider.google;
    final String label = switch (widget.provider) {
      LoginProvider.google => 'Continue with Google',
      LoginProvider.email => 'Continue with Email',
      LoginProvider.x => 'Continue with X',
      LoginProvider.telegram => 'Continue with Telegram',
      LoginProvider.phone => 'Continue with Phone',
    };
    final Duration duration = animationsDisabled(context)
        ? Duration.zero
        : const Duration(milliseconds: 150);
    return AnimatedOpacity(
      opacity: widget.disabled ? .7 : 1,
      duration: duration,
      curve: tailwindTransition,
      child: PressScale(
        enabled: !widget.disabled,
        onTap: widget.onTap,
        onPressedChanged: (value) => setState(() => _pressed = value),
        child: LoginButtonFocus(
          onActivate: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: duration,
            curve: tailwindTransition,
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _pressed && !widget.disabled
                  ? AppColors.primary10
                  : primary
                  ? AppColors.white
                  : AppColors.white60,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primary ? AppColors.cta : AppColors.divider,
                width: primary ? 1.5 : 1,
              ),
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: AppColors.cta.withValues(alpha: .25),
                        offset: const Offset(0, 6),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: LoginProviderIcon(provider: widget.provider),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
