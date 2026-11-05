import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_theme.dart';

enum LoginProvider { google, email, x, telegram, phone }

class LoginProviderIcon extends StatelessWidget {
  const LoginProviderIcon({super.key, required this.provider});
  final LoginProvider provider;

  @override
  Widget build(BuildContext context) {
    final String ink = appColorHex(AppColors.ink);
    final String content = switch (provider) {
      LoginProvider.google =>
        '<path fill="${appColorHex(AppColors.googleRed)}" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.800 2.400 30.300 0 24 0 14.600 0 6.500 5.400 2.600 13.200l7.900 6.100C12.400 13.600 17.700 9.500 24 9.500z"/>'
            '<path fill="${appColorHex(AppColors.googleBlue)}" d="M46.500 24.500c0-1.600-.1-3.100-.4-4.500H24v9h12.700c-.6 3-2.300 5.500-4.800 7.200l7.500 5.800c4.400-4.100 7.100-10.100 7.100-17.500z"/>'
            '<path fill="${appColorHex(AppColors.googleYellow)}" d="M10.500 28.700c-.5-1.400-.8-3-.8-4.700s.3-3.200.8-4.700l-7.900-6.100C.9 16.500 0 20.100 0 24s.9 7.500 2.600 10.800l7.900-6.100z"/>'
            '<path fill="${appColorHex(AppColors.googleGreen)}" d="M24 48c6.500 0 11.900-2.100 15.900-5.800l-7.500-5.800c-2.100 1.400-4.800 2.300-8.400 2.300-6.300 0-11.600-4.100-13.500-9.800l-7.900 6.100C6.500 42.600 14.600 48 24 48z"/>',
      LoginProvider.x =>
        '<path fill="$ink" d="M18.244 2.250h3.308l-7.227 8.260 8.502 11.240H16.170l-5.214-6.817L4.990 21.750H1.680l7.730-8.835L1.254 2.250H8.080l4.713 6.231zm-1.161 17.520h1.833L7.084 4.126H5.117z"/>',
      LoginProvider.telegram =>
        '<path fill="$ink" d="M21.900 3.600 2.700 11c-1.300.5-1.300 1.300-.2 1.600l4.900 1.500 1.900 5.800c.2.600.1.800.7.800.5 0 .7-.2 1-.5l2.400-2.300 4.900 3.600c.9.500 1.500.2 1.700-.8L22.900 5c.3-1.300-.5-1.900-1-1.400zM8.600 13.500l9.700-6.100c.5-.3.900-.1.500.2l-8.100 7.300-.3 3.400z"/>',
      LoginProvider.phone => '<path d="M5 4h4l2 5-2.500 1.500a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z"/>',
      LoginProvider.email => '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M4 7l8 6 8-6"/>',
    };
    final bool stroked =
        provider == LoginProvider.phone || provider == LoginProvider.email;
    final int viewBox = provider == LoginProvider.google ? 48 : 24;
    final double size = provider == LoginProvider.x ? 22 : 24;
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $viewBox $viewBox"'
      '${stroked ? ' fill="none" stroke="$ink" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"' : ''}>$content</svg>',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
