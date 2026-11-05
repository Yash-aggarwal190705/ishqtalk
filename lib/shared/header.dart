import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.title,
    required this.onBack,
    this.right,
    this.dark = false,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? right;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textColor = dark ? AppColors.white : AppColors.ink;
    return DefaultTextStyle.merge(
      style: TextStyle(color: textColor),
      child: SizedBox(
        height: 56 + MediaQuery.paddingOf(context).top,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: AppTap(
                  label: 'Back',
                  onTap: onBack,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: AppIcon(name: 'back', color: textColor),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: -4,
                right: -4,
                child: IgnorePointer(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              if (right != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: right,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
