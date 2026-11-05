import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.onRetry, this.text = "You're offline."});

  final VoidCallback? onRetry;
  final String text;

  @override
  Widget build(BuildContext context) {
    final String icon =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="${appColorHex(AppColors.offlineIcon)}" stroke-width="2" stroke-linecap="round"><path d="M2 9a15 15 0 0120 0M5 13a10 10 0 0114 0M9 17a5 5 0 016 0M3 3l18 18"/></svg>';
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.coinBg,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.string(icon, excludeFromSemantics: true),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.ink,
              ),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: const SizedBox(
                height: 32,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      'Try again',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
