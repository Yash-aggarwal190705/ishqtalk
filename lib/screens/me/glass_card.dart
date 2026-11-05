// glass_card.dart
//
// Reference implementation of the frosted "folder" cards on My Profile (Tokens, VIP, Invite).
// Layer order, bottom to top (this order is what makes it match the prototype):
//   1 folder back  2 glow  3 frosted panel  4 decoration (coin / diamond / heart)  5 text content
// The text (5) is never masked, never blurred and never clipped.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Color _rgba(List<int> c, double a) => Color.fromRGBO(c[0], c[1], c[2], a);

class GlassTone {
  const GlassTone({
    required this.a,
    required this.b,
    required this.tint,
    required this.glow,
  });

  final Color a, b; // folder-back gradient, top -> bottom
  final List<int> tint; // r,g,b of the frosted fill
  final List<int> glow; // r,g,b of the glow under the card

  static const tokens = GlassTone(
    a: Color(0xFFFFC46B),
    b: Color(0xFFFF9F2E),
    tint: [255, 196, 140],
    glow: [255, 159, 46],
  );
  static const vip = GlassTone(
    a: Color(0xFFA98BFF),
    b: Color(0xFF7B5CFF),
    tint: [205, 190, 255],
    glow: [123, 92, 255],
  );
  static const invite = GlassTone(
    a: Color(0xFFFF8FB1),
    b: Color(0xFFFF5C8A),
    tint: [255, 185, 205],
    glow: [255, 92, 138],
  );
}

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.tone,
    required this.height, // Tokens 150, VIP 71, Invite 71 (fixed, never intrinsic)
    required this.peek, // Tokens 22, VIP/Invite 14
    required this.decoration, // a widget laid out inside a Stack (use Positioned), see usage below
    required this.child,
    this.centerContent =
        false, // true for Tokens: the prototype's <button> centres its content
    this.onTap,
  });

  final GlassTone tone;
  final double height, peek;
  final Widget decoration, child;
  final bool centerContent;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tone;
    final h = widget.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: h,
          child: Stack(
            clipBehavior: Clip.none, // glow and text overflow are allowed
            children: [
              // 1) FOLDER BACK: tab on the left, slopes down to the right, fades out at the bottom.
              Positioned(
                left: 6,
                right: 6,
                top: 0,
                bottom: h * 0.42,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0, 0.65, 1],
                  ).createShader(r),
                  child: CustomPaint(painter: _FolderBackPainter(t.a, t.b)),
                ),
              ),

              // 2) GLOW under the card (blur sigma 14, colour @ 32%).
              Positioned(
                left: 12,
                right: 12,
                bottom: -12,
                height: h * 0.38,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _rgba(t.glow, 0.32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),

              // 3) FROSTED PANEL.
              // IMPORTANT: no ShaderMask / Opacity around the BackdropFilter (they isolate the layer
              // and the blur then has nothing to blur). The bottom fade is built into the fill
              // gradient instead: alpha = fill(.78 -> .58) x mask(1 @ 52%, .35 @ 78%, 0 @ 100%).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: widget.peek,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _rgba(t.tint, 0.78),
                                _rgba(t.tint, 0.676),
                                _rgba(t.tint, 0.218),
                                _rgba(t.tint, 0.0),
                              ],
                              stops: const [0.0, 0.52, 0.78, 1.0],
                            ),
                          ),
                        ),
                        // gloss: top 30%, white @ 50% -> 0
                        const Align(
                          alignment: Alignment.topCenter,
                          child: FractionallySizedBox(
                            heightFactor: 0.30,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(255, 255, 255, 0.5),
                                    Color.fromRGBO(255, 255, 255, 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 1 px glass rim, brightest at the top, fading with the mask
                        const CustomPaint(painter: _RimPainter(22)),
                      ],
                    ),
                  ),
                ),
              ),

              // 4) DECORATION above the panel, clipped to the 20-radius card.
              // (In the prototype the bottom of the panel is almost transparent, so the coin shows
              // through. Drawing it above the panel, at reduced opacity, gives the same look.)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(children: [widget.decoration]),
                  ),
                ),
              ),

              // 5) TEXT CONTENT: starts at peek + 6. Never masked, blurred or clipped.
              Positioned(
                left: 12,
                right: 12,
                top: widget.peek + 6,
                bottom: widget.centerContent ? 0 : null,
                child: Align(
                  alignment: widget.centerContent
                      ? Alignment.center
                      : Alignment.topLeft,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderBackPainter extends CustomPainter {
  const _FolderBackPainter(this.a, this.b);
  final Color a, b;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG viewBox 160 x 60, preserveAspectRatio="none"
    final sx = size.width / 160, sy = size.height / 60;
    final p = Path()
      ..moveTo(0, 60)
      ..lineTo(0, 14)
      ..quadraticBezierTo(0, 0, 14, 0)
      ..lineTo(60, 0)
      ..quadraticBezierTo(70, 0, 78, 5)
      ..lineTo(90, 12)
      ..quadraticBezierTo(97, 16, 108, 16)
      ..lineTo(146, 16)
      ..quadraticBezierTo(160, 16, 160, 30)
      ..lineTo(160, 60)
      ..close();
    final scaled = p.transform(Matrix4.diagonal3Values(sx, sy, 1).storage);
    canvas.drawPath(
      scaled,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a, b],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _FolderBackPainter old) =>
      old.a != a || old.b != b;
}

class _RimPainter extends CustomPainter {
  const _RimPainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.85),
            Color.fromRGBO(255, 255, 255, 0.45),
            Color.fromRGBO(255, 255, 255, 0.16),
            Color.fromRGBO(255, 255, 255, 0.0),
          ],
          stops: [0.0, 0.52, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RimPainter old) => old.radius != radius;
}

// ---------------------------------------------------------------------------
// USAGE (margin h16 around this row; fixed heights, 8 px gaps)
// ---------------------------------------------------------------------------
//
// SizedBox(
//   height: 150,
//   child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Expanded(
//       child: GlassCard(
//         tone: GlassTone.tokens, height: 150, peek: 22, centerContent: true, onTap: openTokens,
//         decoration: Positioned(
//           right: -12, bottom: -12,
//           child: ImageFiltered(
//             imageFilter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
//             child: Opacity(
//               opacity: 0.5, // tune 0.4 to 0.6 until the coin matches the target: pale ring + white star
//               child: DecoratedBox(
//                 decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
//                   BoxShadow(color: Color.fromRGBO(255, 170, 60, 0.7), blurRadius: 18),
//                 ]),
//                 child: CoinIcon(size: 96),
//               ),
//             ),
//           ),
//         ),
//         // content block = 68 tall (20 + 12 + 24 + 12 bottom padding), centred below peek + 6
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//             SizedBox(height: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Text('Tokens', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14, color: Color(0xFF7A3E00))),
//               Icon(Icons.chevron_right, size: 16, color: Color(0xFF7A3E00)),
//             ])),
//             SizedBox(height: 12),
//             SizedBox(height: 24, child: Row(children: [
//               CoinIcon(size: 20), SizedBox(width: 6),
//               Text('$coins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 24 / 16, color: Color(0xFF7A3E00))),
//             ])),
//           ]),
//         ),
//       ),
//     ),
//     SizedBox(width: 8),
//     Expanded(
//       child: Column(children: [
//         GlassCard(tone: GlassTone.vip, height: 71, peek: 14,
//           decoration: Positioned(top: 12, right: 8, child: /* diamond 48, #7B5CFF @ 60%, blur 1, glow */),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('VIP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, height: 20 / 16, color: Color(0xFF3E2A99))),
//             SizedBox(height: 8),
//             Text(isVip ? 'Active' : 'Free Bonus', style: TextStyle(fontSize: 11, color: Color(0xFF6B5BB0))),
//           ])),
//         SizedBox(height: 8),
//         GlassCard(tone: GlassTone.invite, height: 71, peek: 14,
//           decoration: Positioned(right: 8, bottom: 8, child: /* heart 36, #FF5C8A @ 70%, blur 1, glow */),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             SizedBox(width: 96, child: Text('Invite to earn money', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 16 / 12, color: Color(0xFF8A1F47)))),
//             SizedBox(height: 4),
//             Text('Get Bonus', style: TextStyle(fontSize: 11, color: Color(0xFFB0587A))),
//           ])),
//       ]),
//     ),
//   ]),
// )
