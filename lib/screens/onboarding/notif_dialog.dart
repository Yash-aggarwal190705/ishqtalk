import 'package:flutter/material.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';

class NotifDialog extends StatelessWidget {
  const NotifDialog({
    super.key,
    required this.onChoose,
    required this.safeBottom,
    this.instant = false,
  });
  final bool instant;
  final double safeBottom;
  final ValueChanged<String> onChoose;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: FadeIn(
      instant: instant,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          color: AppColors.ink35,
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + safeBottom),
          alignment: Alignment.bottomCenter,
          child: SlideUp(
            instant: instant,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              namesRoute: true,
              label: 'Notifications',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary10,
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon(
                        name: 'bell',
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Allow IshqTalk to send you notifications?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final (
                          String label,
                          String choice,
                          Color background,
                          Color color,
                        )
                        in [
                          (
                            'Allow',
                            'allow',
                            AppColors.primary,
                            AppColors.white,
                          ),
                          (
                            "Don't allow",
                            'deny',
                            AppColors.primary10,
                            AppColors.ink,
                          ),
                        ]) ...<Widget>[
                      if (choice == 'deny') const SizedBox(height: 8),
                      AppTap(
                        onTap: () => onChoose(choice),
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
