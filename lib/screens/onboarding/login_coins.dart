import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';

class LoginCoins extends StatelessWidget {
  const LoginCoins({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 64,
    child: ClipRect(
      child: Stack(
        children: [
          SvgPicture.string(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 64">'
            '<defs><linearGradient id="lgCoin" x1="0" y1="0" x2="1" y2="1">'
            '<stop offset="0" stop-color="${appColorHex(AppColors.vipA)}"/>'
            '<stop offset="1" stop-color="${appColorHex(AppColors.vipB)}"/>'
            '</linearGradient></defs>'
            '${[48, 38, 28, 18].map((y) => '<ellipse cx="36" cy="${y + 8}" rx="26" ry="9" fill="url(#lgCoin)" opacity=".8"/>'
                '<ellipse cx="36" cy="$y" rx="26" ry="9" fill="url(#lgCoin)" stroke="${appColorHex(AppColors.coinBg)}" stroke-width="1.5"/>'
                '${y == 18 ? '<ellipse cx="36" cy="18" rx="16" ry="5" fill="none" stroke="${appColorHex(AppColors.coinBg)}" stroke-width="1.5"/>' : ''}').join()}'
            '</svg>',
            width: 72,
            height: 64,
            excludeFromSemantics: true,
          ),
          Positioned.fill(
            child: LoopMotion(
              duration: const Duration(seconds: 2),
              builder: (context, phase, idle, child) {
                final double pulse = pulseSequence.transform(phase);
                return Opacity(
                  opacity: idle ? 1 : .2 + .8 * pulse,
                  child: Transform.scale(
                    scale: idle ? 1 : .6 + .5 * pulse,
                    alignment: const Alignment(56 / 36 - 1, 11 / 32 - 1),
                    child: child,
                  ),
                );
              },
              child: SvgPicture.string(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 64"><path d="M56 4l2 5 5 2-5 2-2 5-2-5-5-2 5-2z" fill="${appColorHex(AppColors.primary10)}"/></svg>',
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
