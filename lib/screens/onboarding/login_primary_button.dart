import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'login_button_focus.dart';

class LoginPrimaryButton extends StatelessWidget {
  const LoginPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) => LoginButtonFocus(
    onActivate: onTap,
    child: AppTap(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppGradients.bgBrand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.white,
                    backgroundColor: AppColors.white30,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    ),
  );
}
