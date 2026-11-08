// v2_shared_widgets.dart
// Reference helpers for the v2 screens (Messages, Token history, Level, My items, Conversation,
// Edit profile, App settings, onboarding). UNTESTED: no Flutter/Dart SDK was available when this was
// written. Adapt names and imports to the project, then run `flutter analyze` and fix what it reports.
// If a helper with the same job already exists in the project (Header, Sheet, Shimmer, Snack, TokenCoin),
// keep the existing one only if it matches the numbers in v2_00_read_me_first.md, otherwise replace it.
//
// Packages: flutter_svg, google_fonts, intl.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------------------------
// Tokens (from src/index.css). Alpha constants: .25=0x40 .30=0x4D .35=0x59 .50=0x80 .60=0x99 .75=0xBF
// ---------------------------------------------------------------------------------------------
abstract final class K {
  static const primary = Color(0xFF8B5CF6);
  static const cta = Color(0xFFFF6B6B);
  static const primary10 = Color(0xFFF5F0FF);
  static const ink = Color(0xFF3B3354);
  static const ink2 = Color(0xFF8A839F);
  static const ink3 = Color(0xFFA8A2BA);
  static const card = Color(0xFFF7F4FC);
  static const screen = Color(0xFFFBF9FF);
  static const divider = Color(0xFFECE7F5);
  static const roseGold = Color(0xFFF4B8A6);
  static const coin = Color(0xFFFFC857);
  static const coinBg = Color(0xFFFFF4D6);
  static const vipA = Color(0xFFFFC857);
  static const vipB = Color(0xFFFF9F7A);
  static const badge = Color(0xFFFF4D8D);
  static const onlineCyan = Color(0xFF2ED3C6);
  static const onlineGreen = Color(0xFF3CC76A);
  static const lvGray = Color(0xFFC9C3D8);
  static const tintTokens = Color(0xFFFFF0DD);
  static const tintVip = Color(0xFFEFE6FF);
  static const tintInvite = Color(0xFFFFE3EA);
  static const success = Color(0xFF087F5B);
  static const danger = Color(0xFFD92D2D);
  static const profileA = Color(0xFFC4B5FD);
  static const profileB = Color(0xFFFFB4A8);

  static const sub = Color(0xBF3B3354); // text-ink/75  (secondary text)
  static const ink60 = Color(0x993B3354); // text-ink/60 (placeholders, disabled text)
  static const scrim30 = Color(0x4D3B3354); // bg-ink/30  (Sheet, Dialog)
  static const scrim35 = Color(0x593B3354); // bg-ink/35  (login / welcome modals)
  static const scrim50 = Color(0x803B3354); // bg-ink/50  (Messages sheets, delete account)
  // shadow-[0_4px_14px_color-mix(in_srgb,var(--color-primary)_8%,transparent)]
  static const softShadow = [BoxShadow(color: Color(0x148B5CF6), offset: Offset(0, 4), blurRadius: 14)];
}

// ---------------------------------------------------------------------------------------------
// Text. Tailwind v4 line heights: 12/16, 14/20, 16/24, 18/28, 20/28, 24/32. Any other size with no
// explicit leading-* inherits html line-height 1.5 (so 11px -> 16.5, 13px -> 19.5, 15px -> 22.5).
// ---------------------------------------------------------------------------------------------
double _defaultLine(double s) {
  switch (s) {
    case 12:
      return 16;
    case 14:
      return 20;
    case 16:
      return 24;
    case 18:
      return 28;
    case 20:
      return 28;
    case 24:
      return 32;
    default:
      return s * 1.5;
  }
}

TextStyle t(double size, FontWeight w,
    {Color color = K.ink, double? line, FontStyle? style, TextDecoration? deco, double? letter}) {
  return GoogleFonts.poppins(
    fontSize: size,
    fontWeight: w,
    color: color,
    fontStyle: style,
    decoration: deco,
    letterSpacing: letter,
    height: (line ?? _defaultLine(size)) / size,
  ).copyWith(leadingDistribution: TextLeadingDistribution.even);
}

/// toLocaleString('en-IN'): 2,000 / 99,900 / 1,00,000
final NumberFormat _in = NumberFormat.decimalPattern('en_IN');
String fmtIN(int n) => _in.format(n);

// ---------------------------------------------------------------------------------------------
// CSS linear-gradient(<angle>deg, ...) with the exact CSS gradient-line length for any box size.
// 0deg = to top, 90deg = to right, 180deg = to bottom, 135deg = to bottom right, 160deg ~ down + a little right.
// ---------------------------------------------------------------------------------------------
class CssAngle extends GradientTransform {
  const CssAngle(this.deg);
  final double deg;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final a = deg * math.pi / 180;
    final len = (bounds.width * math.sin(a)).abs() + (bounds.height * math.cos(a)).abs();
    final c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.rotationZ(a + math.pi) *
        Matrix4.diagonal3Values(1, len / bounds.height, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);
  }
}

LinearGradient cssLinear(double deg, List<Color> colors, [List<double>? stops]) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
      transform: CssAngle(deg),
    );

/// `.bg-vip` = linear-gradient(135deg, #FFC857, #FF9F7A)
LinearGradient get vipGradient => cssLinear(135, const [K.vipA, K.vipB]);

/// `.bg-brand` = linear-gradient(135deg, primary, cta)
LinearGradient get brandGradient => cssLinear(135, const [K.primary, K.cta]);

// ---------------------------------------------------------------------------------------------
// Neo button (primaryBtn / neo in the source): 52 tall, radius 20, 2 px ink border, hard 3,3 ink shadow.
// Pressed: moves 3,3 and loses the shadow. Disabled: border divider, text ink@60, no shadow.
// IMPORTANT: `.bg-vip` is an un-layered CSS rule, so on a gradient (vip) button the disabled state KEEPS
// the orange gradient. Only the red (danger) variant turns into the flat `card` colour when disabled.
// ---------------------------------------------------------------------------------------------
class NeoButton extends StatefulWidget {
  const NeoButton(this.label,
      {super.key, this.onPressed, this.danger = false, this.fill = true, this.hPad = 32});
  final String label;
  final VoidCallback? onPressed; // null = disabled
  final bool danger;
  final bool fill; // false = hug the label (px-8) like the empty-state buttons
  final double hPad;
  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final pressed = _down && enabled;
    final deco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: enabled ? K.ink : K.divider, width: 2),
      color: widget.danger ? (enabled ? K.danger : K.card) : null,
      gradient: widget.danger ? null : vipGradient,
      boxShadow: (enabled && !pressed) ? const [BoxShadow(color: K.ink, offset: Offset(3, 3))] : const [],
    );
    final fg = !enabled ? K.ink60 : (widget.danger ? Colors.white : K.ink);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: Transform.translate(
          offset: pressed ? const Offset(3, 3) : Offset.zero,
          child: Container(
            height: 52,
            width: widget.fill ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: widget.fill ? 0 : widget.hPad),
            decoration: deco,
            child: Center(
              widthFactor: widget.fill ? null : 1,
              child: Text(widget.label, style: t(16, FontWeight.w600, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

/// secondaryBtn: 52 tall, radius 20, 2 px primary border, white, label 16/600 primary, px 32, no shadow.
class OutlineButton52 extends StatelessWidget {
  const OutlineButton52(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: K.primary, width: 2)),
          child: Center(widthFactor: 1, child: Text(label, style: t(16, FontWeight.w600, color: K.primary))),
        ),
      );
}

/// Plain text button used under sheets: "Cancel", "Close", "Reset", "Stay logged in", ... h 48, 16/600 primary.
class SheetTextButton extends StatelessWidget {
  const SheetTextButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(height: 48, width: double.infinity, child: Center(child: Text(label, style: t(16, FontWeight.w600, color: K.primary)))),
      );
}

// ---------------------------------------------------------------------------------------------
// Sheets. Always real routes (so system back closes them).
//  Sheet (ui.tsx Sheet):   scrim ink@30, radius 20, padding 16/8/16/32+safe, handle 40x4 with 16 below.
//  ActionSheet (inbox):    scrim ink@50, radius 28, padding 0/8/0/8+safe,  handle 40x4 with 8 below.
// ---------------------------------------------------------------------------------------------
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder, bool action = false, bool fullHeight = false}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    useSafeArea: false,
    barrierColor: action || fullHeight ? K.scrim50 : K.scrim30,
    constraints: const BoxConstraints(maxWidth: 480),
    sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 280), reverseDuration: Duration(milliseconds: 200), curve: Curves.easeOut),
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final bottom = mq.viewPadding.bottom;
      final kb = mq.viewInsets.bottom; // keyboard: lift the sheet above it
      final radius = Radius.circular(action || fullHeight ? 28 : 20);
      final handle = Center(
          child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: action ? 8 : 16),
              decoration: BoxDecoration(color: K.divider, borderRadius: BorderRadius.circular(2))));
      final inner = Column(mainAxisSize: fullHeight ? MainAxisSize.max : MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        handle,
        fullHeight ? Expanded(child: builder(ctx)) : Flexible(child: SingleChildScrollView(child: builder(ctx))),
      ]);
      final EdgeInsets pad = action
          ? EdgeInsets.fromLTRB(0, 8, 0, 8 + bottom)
          : fullHeight
              ? EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom) // delete-account sheet
              : EdgeInsets.fromLTRB(16, 8, 16, 32 + bottom);
      final maxH = fullHeight ? mq.size.height - 40 : mq.size.height * 0.9;
      return Padding(
        padding: EdgeInsets.only(bottom: kb),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxH),
          width: double.infinity,
          padding: pad,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: radius)),
          child: inner,
        ),
      );
    },
  );
}

/// Centered dialog (Messages "Clear your message list?"): scrim ink@50, side margin 24, radius 28, padding 24.
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder, Color scrim = K.scrim50, double radius = 28, double padding = 24}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: scrim,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (c, a, _, child) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    pageBuilder: (ctx, _, __) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(padding: EdgeInsets.all(padding), child: builder(ctx)),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------------------------
// Snackbar (the prototype's dark `say()` pill). One at a time. Call AppSnack.hide() in dispose().
// bottom per screen:  Messages / Me: 56 + safeBottom + 12   Conversation: 160   Edit profile / Settings: 24 + safeBottom
//                     Get tokens: 120 + safeBottom
// ---------------------------------------------------------------------------------------------
class AppSnack {
  static OverlayEntry? _entry;
  static Timer? _timer;
  static void show(BuildContext context, String message, {required double bottom, int ms = 2200}) {
    hide();
    _entry = OverlayEntry(builder: (_) => Positioned(left: 16, right: 16, bottom: bottom, child: _SnackBody(message)));
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _timer = Timer(Duration(milliseconds: ms), hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _SnackBody extends StatelessWidget {
  const _SnackBody(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (_, v, child) => Opacity(opacity: v, child: child),
        child: Semantics(
          liveRegion: true,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(color: K.ink, borderRadius: BorderRadius.circular(16)),
            child: Text(message, style: t(14, FontWeight.w400, color: Colors.white).copyWith(decoration: TextDecoration.none)),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------------------------
// Shimmer skeleton: background linear-gradient(90deg,#ECE7F5 0,#F7F4FC 50%,#ECE7F5 100%),
// background-size 720px, background-position-x animates -360 -> 360 over 1.4 s linear, infinite.
// Use ONE ShimmerScope above a skeleton list so every bar moves in sync.
// ---------------------------------------------------------------------------------------------
class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});
  final Widget child;
  static Animation<double> of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<_ShimmerInherited>()!.t;
  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShimmerInherited(t: _c, child: widget.child);
}

class _ShimmerInherited extends InheritedWidget {
  const _ShimmerInherited({required this.t, required super.child});
  final Animation<double> t;
  @override
  bool updateShouldNotify(_ShimmerInherited old) => false;
}

class _ShimmerShift extends GradientTransform {
  const _ShimmerShift(this.pos);
  final double pos;
  @override
  Matrix4? transform(Rect b, {TextDirection? textDirection}) =>
      Matrix4.translationValues(b.left + pos, 0, 0) * Matrix4.diagonal3Values(720 / b.width, 1, 1) * Matrix4.translationValues(-b.left, 0, 0);
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.w, this.h, this.radius = 4, this.circle = false});
  final double? w; // null = fill the parent width
  final double? h;
  final double radius;
  final bool circle;
  @override
  Widget build(BuildContext context) {
    final t = ShimmerScope.of(context);
    return AnimatedBuilder(
      animation: t,
      builder: (_, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [Color(0xFFECE7F5), Color(0xFFF7F4FC), Color(0xFFECE7F5)],
            stops: const [0, .5, 1],
            transform: _ShimmerShift(-360 + 720 * t.value),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------
// On/Off switch from settings.tsx (NOT a Material Switch). Visible box 100 x 48 incl. label.
// ---------------------------------------------------------------------------------------------
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.on, required this.onChanged, required this.label});
  final bool on;
  final ValueChanged<bool> onChanged;
  final String label;
  @override
  Widget build(BuildContext context) {
    const dur = Duration(milliseconds: 150);
    final thumbShadow = on
        ? const [
            BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3),
            BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2, spreadRadius: -1),
          ]
        : const [BoxShadow(color: K.lvGray, spreadRadius: 1.5)];
    return Semantics(
      toggled: on,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!on),
        // CSS has margin-right -8: paint 8 px further right so the track ends 20 px from the card edge.
        child: Transform.translate(
          offset: const Offset(8, 0),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 28, child: Text(on ? 'On' : 'Off', textAlign: TextAlign.right, style: t(14, FontWeight.w600, color: on ? K.ink : K.sub))),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: dur,
                  curve: Curves.easeInOut,
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: on ? K.primary : K.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: on ? K.primary : K.lvGray, width: 2),
                  ),
                  child: Stack(clipBehavior: Clip.none, children: [
                    AnimatedPositioned(
                      duration: dur,
                      curve: Curves.easeInOut,
                      left: on ? 22 : 2,
                      top: 2,
                      child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: thumbShadow)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------
// SVG art. flutter_svg does not render CSS variables or stroke-dasharray, so both are resolved here.
// ---------------------------------------------------------------------------------------------
const String _tokenCoinSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient id="a" x1="0.15" y1="0" x2="0.85" y2="1"><stop offset="0" stop-color="#FFC857"/><stop offset="1" stop-color="#FF9F7A"/></linearGradient>
<linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FF9F7A"/><stop offset="1" stop-color="#FFC857"/></linearGradient>
</defs>
<circle cx="24" cy="24" r="23" fill="url(#a)"/>
<circle cx="24" cy="24" r="17.5" fill="url(#b)" stroke="#FFFFFF" stroke-opacity="0.55" stroke-width="2"/>
<path d="M24 12.5l3.4 7 7.6 1-5.6 5.3 1.4 7.6L24 29.6l-6.8 3.8 1.4-7.6-5.6-5.3 7.6-1z" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round"/>
</svg>''';

class TokenCoin extends StatelessWidget {
  const TokenCoin({super.key, this.size = 20});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.string(_tokenCoinSvg, width: size, height: size);
}

/// 40 x 28 pass ticket (My items). Perforation = 6 dots (the CSS used stroke-dasharray "0.1 3" on M13.5 5v18).
class PassTicket extends StatelessWidget {
  const PassTicket({super.key, required this.match, this.w = 40});
  final bool match;
  final double w;
  @override
  Widget build(BuildContext context) {
    final body = match ? '#8B5CF6' : '#2ED3C6';
    final mark = match ? '#FFFFFF' : '#3B3354';
    final dots = [for (var i = 0; i < 6; i++) '<circle cx="13.5" cy="${(5 + i * 3.1).toStringAsFixed(1)}" r="0.8" fill="$mark"/>'].join();
    final glyph = match
        ? '<path d="M26.5 19.5s-5.5-3.2-5.5-7a2.9 2.9 0 015.5-1.3A2.9 2.9 0 0132 12.5c0 3.8-5.5 7-5.5 7z" fill="$mark"/>'
        : '<path d="M21.5 9h10a1.5 1.5 0 011.5 1.5v5a1.5 1.5 0 01-1.5 1.5H28l-3 2.5V17h-3.5A1.5 1.5 0 0120 15.5v-5A1.5 1.5 0 0121.5 9z" fill="$mark"/>';
    final svg = '<svg viewBox="0 0 40 28" xmlns="http://www.w3.org/2000/svg">'
        '<path d="M6 1h28a5 5 0 015 5v4.5a3.5 3.5 0 000 7V22a5 5 0 01-5 5H6a5 5 0 01-5-5v-4.5a3.5 3.5 0 000-7V6a5 5 0 015-5z" fill="$body"/>'
        '$dots$glyph</svg>';
    return SvgPicture.string(svg, width: w, height: w * 28 / 40);
  }
}

// ---------------------------------------------------------------------------------------------
// Level badge (level.tsx OrbitBadge). viewBox 112. Tier: 0 gray, 1-2 mint, 3-5 violet, 6-8 pink, 9-10 sunset.
// ---------------------------------------------------------------------------------------------
enum Tier { gray, mint, violet, pink, sunset }

Tier tierOf(int lv) => lv == 0 ? Tier.gray : lv <= 2 ? Tier.mint : lv <= 5 ? Tier.violet : lv <= 8 ? Tier.pink : Tier.sunset;

class LevelPill extends StatelessWidget {
  const LevelPill(this.lv, {super.key});
  final int lv;
  @override
  Widget build(BuildContext context) {
    final tier = tierOf(lv);
    final Color? bg = switch (tier) { Tier.gray => K.lvGray, Tier.mint => K.onlineCyan, Tier.violet => K.primary, Tier.pink => K.badge, Tier.sunset => null };
    final fg = tier == Tier.violet ? Colors.white : K.ink;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, gradient: tier == Tier.sunset ? vipGradient : null, borderRadius: BorderRadius.circular(12)),
      child: Center(widthFactor: 1, child: Text('Lv $lv', style: t(12, FontWeight.w700, color: fg))),
    );
  }
}

class OrbitBadge extends StatelessWidget {
  const OrbitBadge({super.key, required this.level, this.size = 112});
  final int level;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Level $level badge',
        child: CustomPaint(size: Size.square(size), painter: _OrbitBadgePainter(tierOf(level))),
      );
}

class _OrbitBadgePainter extends CustomPainter {
  _OrbitBadgePainter(this.tier);
  final Tier tier;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 112, size.height / 112);
    final hex = Path()
      ..moveTo(56, 6)
      ..lineTo(98, 30)
      ..lineTo(98, 82)
      ..lineTo(56, 106)
      ..lineTo(14, 82)
      ..lineTo(14, 30)
      ..close();
    if (tier != Tier.gray) {
      // filter: drop-shadow(0 0 14px coin @ 60%)  -> gaussian sigma 7
      final glow = Paint()
        ..color = K.coin.withValues(alpha: .6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(hex, glow);
      canvas.drawPath(hex, glow..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    final fill = Paint()..style = PaintingStyle.fill;
    switch (tier) {
      case Tier.gray:
        fill.color = K.lvGray;
      case Tier.mint:
        fill.color = K.onlineCyan;
      case Tier.violet:
        fill.color = K.primary;
      case Tier.pink:
        fill.color = K.badge;
      case Tier.sunset:
        fill.shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.vipA, K.vipB])
            .createShader(const Rect.fromLTWH(14, 6, 84, 100));
    }
    canvas.drawPath(hex, fill);
    canvas.drawPath(
        hex,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .9);
    const c = Offset(56, 56);
    // circle r26 dasharray "110 54" rotated -30deg; circle r17 dasharray "60 47" rotated 150deg
    canvas.drawArc(Rect.fromCircle(center: c, radius: 26), -30 * math.pi / 180, 110 / 26, false, arc);
    canvas.drawArc(Rect.fromCircle(center: c, radius: 17), 150 * math.pi / 180, 60 / 17, false, arc);
    canvas.drawCircle(c, 6, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitBadgePainter old) => old.tier != tier;
}

// ---------------------------------------------------------------------------------------------
// Dashed rounded rectangle (Edit profile "Add photo" tile: 1.5 px dashed #CFC8E6, radius 20).
// ---------------------------------------------------------------------------------------------
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter({this.color = const Color(0xFFCFC8E6), this.width = 1.5, this.radius = 20, this.dash = 4.5, this.gap = 3});
  final Color color;
  final double width, radius, dash, gap;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(width / 2), Radius.circular(radius - width / 2)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + dash, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) => false;
}
