import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_theme.dart';
import 'domain.dart';

// ---------------------------------------------------------------------------
// TokenCoin (tokenHistory.tsx)
// ---------------------------------------------------------------------------
class TokenCoin extends StatelessWidget {
  const TokenCoin({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">'
      '<defs>'
      '<linearGradient id="a" x1="0.15" y1="0" x2="0.85" y2="1"><stop offset="0" stop-color="#FFC857"/><stop offset="1" stop-color="#FF9F7A"/></linearGradient>'
      '<linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FF9F7A"/><stop offset="1" stop-color="#FFC857"/></linearGradient>'
      '</defs>'
      '<circle cx="24" cy="24" r="23" fill="url(#a)"/>'
      '<circle cx="24" cy="24" r="17.5" fill="url(#b)" stroke="#FFFFFF" stroke-opacity="0.55" stroke-width="2"/>'
      '<path d="M24 12.5l3.4 7 7.6 1-5.6 5.3 1.4 7.6L24 29.6l-6.8 3.8 1.4-7.6-5.6-5.3 7.6-1z" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round"/>'
      '</svg>',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}

/// Lead icons (viewBox 24, stroke 1.75, round).
const String _calendarCheckSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="5" width="17" height="15.5" rx="3"/><path d="M8 3v4M16 3v4M3.5 10h17M9 15l2.2 2.2L15.5 13"/></svg>';
const String _walletSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7.5A2.5 2.5 0 016.5 5H18a2 2 0 012 2v2"/><rect x="3.5" y="7.5" width="17" height="12" rx="3"/><circle cx="16.5" cy="13.5" r="1.1" fill="currentColor"/></svg>';
const String _ticketSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 000 4v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2a2 2 0 000-4z"/><path d="M14 6v2.5M14 11v2M14 15.5V18"/></svg>';

class TxLeadIcon extends StatelessWidget {
  const TxLeadIcon({super.key, required this.kind, this.size = 22});

  final TxKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String svg = switch (kind) {
      TxKind.checkin => _calendarCheckSvg,
      TxKind.purchase => _walletSvg,
      TxKind.pass => _ticketSvg,
    };
    final Color bg = switch (kind) {
      TxKind.checkin => AppColors.tintTokens,
      TxKind.purchase => AppColors.tintVip,
      TxKind.pass => AppColors.tintInvite,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: SvgPicture.string(
          svg,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LevelPill (level.tsx)
// ---------------------------------------------------------------------------
class LevelPill extends StatelessWidget {
  const LevelPill(this.level, {super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    final Tier tier = tierOf(level);
    final Color? bg = switch (tier) {
      Tier.gray => AppColors.lvGray,
      Tier.mint => AppColors.onlineCyan,
      Tier.violet => AppColors.primary,
      Tier.pink => AppColors.badge,
      Tier.sunset => null,
    };
    final Color fg = tier == Tier.violet ? AppColors.white : AppColors.ink;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        gradient: tier == Tier.sunset
            ? cssLinear(135, const <Color>[AppColors.vipA, AppColors.vipB])
            : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          'Lv $level',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }

  static LinearGradient cssLinear(double deg, List<Color> colors) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        transform: CssAngleGrad(deg),
      );
}

class CssAngleGrad extends GradientTransform {
  const CssAngleGrad(this.deg);
  final double deg;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double a = deg * math.pi / 180;
    final double len =
        (bounds.width * math.sin(a)).abs() +
        (bounds.height * math.cos(a)).abs();
    final Offset c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.rotationZ(a + 3.141592653589793) *
        Matrix4.diagonal3Values(1, len / bounds.height, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);
  }
}

// ---------------------------------------------------------------------------
// OrbitBadge (level.tsx). Hexagon + two dashed arcs (drawn as arcs) + dot.
// ---------------------------------------------------------------------------
class OrbitBadge extends StatelessWidget {
  const OrbitBadge({super.key, required this.level, this.size = 112});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Tier tier = tierOf(level);
    final Paint hexFill = Paint()..style = PaintingStyle.fill;
    switch (tier) {
      case Tier.gray:
        hexFill.color = AppColors.lvGray;
      case Tier.mint:
        hexFill.color = AppColors.onlineCyan;
      case Tier.violet:
        hexFill.color = AppColors.primary;
      case Tier.pink:
        hexFill.color = AppColors.badge;
      case Tier.sunset:
        hexFill.shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.vipA, AppColors.vipB],
        ).createShader(const Rect.fromLTWH(14, 6, 84, 100));
    }
    final Path hex = Path()
      ..moveTo(56, 6)
      ..lineTo(98, 30)
      ..lineTo(98, 82)
      ..lineTo(56, 106)
      ..lineTo(14, 82)
      ..lineTo(14, 30)
      ..close();

    return Semantics(
      label: 'Level $level badge',
      child: CustomPaint(
        size: Size.square(size),
        painter: _OrbitBadgePainter(tier, hex, hexFill),
      ),
    );
  }
}

class _OrbitBadgePainter extends CustomPainter {
  _OrbitBadgePainter(this.tier, this.hex, this.hexFill);

  final Tier tier;
  final Path hex;
  final Paint hexFill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 112, size.height / 112);
    if (tier != Tier.gray) {
      // drop-shadow(0 0 14px coin@60%) — gaussian sigma 7.
      final Paint glow = Paint()
        ..color = AppColors.coin.withValues(alpha: .6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(hex, glow);
      canvas.drawPath(
        hex,
        glow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    canvas.drawPath(hex, hexFill);
    canvas.drawPath(
      hex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.white,
    );
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.white.withValues(alpha: .9);
    const Offset c = Offset(56, 56);
    // Circle r26 dash "110 54" at -30°; circle r17 dash "60 47" at 150°.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 26),
      -30 * 3.141592653589793 / 180,
      110 / 26,
      false,
      arc,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 17),
      150 * 3.141592653589793 / 180,
      60 / 17,
      false,
      arc,
    );
    canvas.drawCircle(c, 6, Paint()..color = AppColors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitBadgePainter old) => old.tier != tier;
}

// ---------------------------------------------------------------------------
// Gift sparkle (level.tsx)
// ---------------------------------------------------------------------------
const String _giftSparkleSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="10" width="14" height="10" rx="1.5"/><path d="M3 7.5h15V10H3zM10.5 7.5V20M10.5 7.5C9 4 6 5 7 6.5s3.5 1 3.5 1zM10.5 7.5c1.5-3.5 4.5-2.5 3.5-1s-3.5 1-3.5 1z"/><path d="M19.5 2.5l.8 2 2 .8-2 .8-.8 2-.8-2-2-.8 2-.8z" fill="currentColor" stroke-width="1"/></svg>';

class GiftSparkle extends StatelessWidget {
  const GiftSparkle({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _giftSparkleSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}
