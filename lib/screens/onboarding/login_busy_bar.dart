import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';

class LoginBusyBar extends StatelessWidget {
  const LoginBusyBar({super.key});

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    height: 3,
    child: Semantics(
      label: 'Loading',
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, bounds) => LoopMotion(
            duration: const Duration(seconds: 1),
            builder: (context, phase, idle, _) {
              final double width = idle ? bounds.maxWidth : bounds.maxWidth / 3;
              final double x = idle
                  ? 0
                  : width * (-1 + 4.5 * Curves.easeInOut.transform(phase));
              return Stack(
                children: [
                  Positioned(
                    left: x,
                    top: 0,
                    width: width,
                    height: 3,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: AppGradients.bgBrand),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
