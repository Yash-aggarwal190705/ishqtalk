import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';

class LoginToast extends StatelessWidget {
  const LoginToast({super.key, this.instant = false});
  final bool instant;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 96,
    left: 0,
    right: 0,
    child: IgnorePointer(
      child: Center(
        child: FadeIn(
          instant: instant,
          child: Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Demo only',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
