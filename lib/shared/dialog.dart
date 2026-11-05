import 'package:flutter/material.dart' hide Dialog;

import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    required this.children,
    required this.close,
    this.instant = false,
  });

  final String title;
  final String body;
  final List<Widget> children;
  final VoidCallback close;
  final bool instant;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeIn(
        instant: instant,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: close,
          child: Container(
            color: AppColors.ink30,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.ink2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(spacing: 12, children: children),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef Dialog = AppDialog;
