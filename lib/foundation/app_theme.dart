import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Colors copied from the React Tailwind theme and the small SVG illustrations.
/// Screens should reference this class rather than declaring colors locally.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF8B5CF6);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color cta = Color(0xFFFF6B6B);
  // CSS brightness(.9) multiplies RGB channels without changing alpha.
  static const Color ctaDark = Color.from(
    alpha: 1,
    red: .9,
    green: 107 / 255 * .9,
    blue: 107 / 255 * .9,
  );
  static const Color primary10 = Color(0xFFF5F0FF);
  static const Color ink = Color(0xFF3B3354);
  static const Color ink2 = Color(0xFF8A839F);
  static const Color ink3 = Color(0xFFA8A2BA);
  static const Color card = Color(0xFFF7F4FC);
  static const Color screen = Color(0xFFFBF9FF);
  static const Color skeleton = Color(0xFFECE7F5);
  static const Color divider = Color(0xFFECE7F5);
  static const Color roseGold = Color(0xFFF4B8A6);
  static const Color coin = Color(0xFFFFC857);
  static const Color coinBg = Color(0xFFFFF4D6);
  static const Color vipA = Color(0xFFFFC857);
  static const Color vipB = Color(0xFFFF9F7A);
  static const Color badge = Color(0xFFFF4D8D);
  static const Color onlineRed = Color(0xFFFF6B6B);
  static const Color onlineCyan = Color(0xFF2ED3C6);
  static const Color onlineGreen = Color(0xFF3CC76A);
  static const Color lvGray = Color(0xFFC9C3D8);
  static const Color danger = Color(0xFFD92D2D);
  static const Color success = Color(0xFF087F5B);
  static const Color scrim30 = Color(0x4D3B3354);
  static const Color scrim50 = Color(0x803B3354);
  static const Color sub = Color(0xBF3B3354); // text-ink/75
  static const Color ink60 = Color(0x993B3354); // text-ink/60
  static const Color tintTokens = Color(0xFFFFF0DD);
  static const Color tintVip = Color(0xFFEFE6FF);
  static const Color tintInvite = Color(0xFFFFE3EA);
  static const Color profileA = Color(0xFFC4B5FD);
  static const Color profileB = Color(0xFFFFB4A8);

  static const Color pageBackground = Color(0xFFF1ECFA);
  static const Color splashTop = Color(0xFFFFF1F5);
  static const Color splashBottom = Color(0xFFEDE4FF);
  static const Color coinTop = Color(0xFFFFC85A);
  static const Color coinBottom = Color(0xFFF7A531);
  static const Color coinRing = Color(0xFFFFE2A8);
  static const Color levelPurple = Color(0xFF7C4AE8);
  static const Color levelGray = Color(0xFF6F6785);
  static const Color offlineIcon = Color(0xFFD9890B);
  static const Color frogYellow = Color(0xFFF7B43A);
  static const Color frogMouth = Color(0xFFA5521C);
  static const Color frogBlush = Color(0xFFF58A4A);
  static const Color frogEye = Color(0xFF222222);
  static const Color portraitSkin = Color(0xFFF3D3BD);
  static const Color flagPakistan = Color(0xFF0B6B3A);
  static const Color flagIndiaOrange = Color(0xFFFF9933);
  static const Color flagIndiaGreen = Color(0xFF138808);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color white20 = Color.fromRGBO(255, 255, 255, 0.20);
  static const Color white25 = Color.fromRGBO(255, 255, 255, 0.25);
  static const Color white30 = Color.fromRGBO(255, 255, 255, 0.30);
  static const Color white35 = Color.fromRGBO(255, 255, 255, 0.35);
  static const Color white45 = Color.fromRGBO(255, 255, 255, 0.45);
  static const Color white50 = Color.fromRGBO(255, 255, 255, 0.50);
  static const Color white60 = Color.fromRGBO(255, 255, 255, 0.60);
  static const Color white70 = Color.fromRGBO(255, 255, 255, 0.70);
  static const Color white80 = Color.fromRGBO(255, 255, 255, 0.80);
  static const Color white85 = Color.fromRGBO(255, 255, 255, 0.85);
  static const Color white90 = Color.fromRGBO(255, 255, 255, 0.90);

  static const Color ink30 = Color.fromRGBO(59, 51, 84, 0.30);
  static const Color ink35 = Color.fromRGBO(59, 51, 84, 0.35);

  static const List<Color> portraitBackgrounds = <Color>[
    Color(0xFFF6B8C8),
    Color(0xFFC94F7C),
    Color(0xFFF4D6A0),
    Color(0xFFD98A3D),
    Color(0xFFB9D8E8),
    Color(0xFF4F8FB3),
    Color(0xFFD9C3F0),
    Color(0xFF8A5CC2),
    Color(0xFFC5E6C9),
    Color(0xFF4F9C6A),
    Color(0xFFF3B3A6),
    Color(0xFFC9573F),
    Color(0xFFE0CFC0),
    Color(0xFF8B6A4F),
    Color(0xFFCFD6F5),
    Color(0xFF5A6BC2),
  ];

  static const List<Color> portraitHair = <Color>[
    Color(0xFF2B1B14),
    Color(0xFFE6C36A),
    Color(0xFFA8472A),
    ink,
    Color(0xFF5A3A28),
  ];
}

/// CSS angles describe a physical angle, not a box diagonal. This also preserves
/// the CSS gradient-line length (including its "magic corners") on rectangles.
class CssLinearGradient extends LinearGradient {
  const CssLinearGradient({
    required this.degrees,
    required super.colors,
    super.stops,
  });

  final double degrees;

  @override
  ui.Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final double angle = degrees * math.pi / 180;
    final Offset direction = Offset(math.sin(angle), -math.cos(angle));
    final double length =
        rect.width * direction.dx.abs() + rect.height * direction.dy.abs();
    final Offset half = direction * (length / 2);
    return ui.Gradient.linear(
      rect.center - half,
      rect.center + half,
      colors,
      stops,
    );
  }
}

class AppGradients {
  const AppGradients._();

  static final LinearGradient splashFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.splashBottom.withValues(alpha: 0),
      AppColors.splashBottom,
      AppColors.splashBottom,
    ],
    stops: const [0, .7, 1],
  );

  static const LinearGradient bgSplash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.splashTop, AppColors.splashBottom],
  );

  static const CssLinearGradient bgBrand = CssLinearGradient(
    degrees: 135,
    colors: <Color>[AppColors.primary, AppColors.cta],
  );

  static const LinearGradient bgCtaPill = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[AppColors.cta, AppColors.badge],
  );

  static const LinearGradient bgWelcome = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.primary, AppColors.profileA, AppColors.profileB],
    stops: <double>[0, 0.5, 1],
  );

  static const CssLinearGradient bgVip = CssLinearGradient(
    degrees: 135,
    colors: <Color>[AppColors.vipA, AppColors.vipB],
  );

  static const LinearGradient coin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.coinTop, AppColors.coinBottom],
  );

  static const LinearGradient level = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[AppColors.levelPurple, AppColors.primary],
  );
}

class AppTheme {
  const AppTheme._();

  static const TextTheme _textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 22,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.cta,
      surface: AppColors.screen,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.ink,
    ),
    scaffoldBackgroundColor: AppColors.pageBackground,
    textTheme: _textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.transparent,
    splashColor: AppColors.transparent,
    hoverColor: AppColors.transparent,
  );
}
