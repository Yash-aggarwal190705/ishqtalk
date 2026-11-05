// Reproduces the BEFORE state of the My Profile glass cards (P1-P4) from the
// previous implementation: container-level padding top = peek + 6 shifted
// every layer down, and content was bottom-anchored so tall content overflowed
// ABOVE the frosted panel.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ishqtalk/foundation/app_icons.dart';
import 'package:ishqtalk/foundation/app_theme.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/shared/coin.dart';
import 'package:ishqtalk/state/app_context.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

const _Tone _tokensTone = _Tone(
  a: Color(0xFFFFC46B),
  b: Color(0xFFFF9F2E),
  tintA: Color(0xC8FFC48C),
  tintB: Color(0x94FFC48C),
  glow: Color(0x52FF9F2E),
);
const _Tone _vipTone = _Tone(
  a: Color(0xFFA98BFF),
  b: Color(0xFF7B5CFF),
  tintA: Color(0xC8CDBEFF),
  tintB: Color(0x94CDBEFF),
  glow: Color(0x527B5CFF),
);
const _Tone _inviteTone = _Tone(
  a: Color(0xFFFF8FB1),
  b: Color(0xFFFF5C8A),
  tintA: Color(0xC8FFB9CD),
  tintB: Color(0x94FFB9CD),
  glow: Color(0x52FF5C8A),
);

class _Tone {
  const _Tone({
    required this.a,
    required this.b,
    required this.tintA,
    required this.tintB,
    required this.glow,
  });

  final Color a;
  final Color b;
  final Color tintA;
  final Color tintB;
  final Color glow;
}

class _OldGlassCard extends StatelessWidget {
  const _OldGlassCard({
    required this.tone,
    required this.peek,
    required this.child,
    this.height,
  });

  final _Tone tone;
  final double peek;
  final Widget child;
  final double? height;

  String get _folderSvg {
    final String a = appColorHex(tone.a);
    final String b = appColorHex(tone.b);
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 60"><defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="$a"/><stop offset="1" stop-color="$b"/></linearGradient></defs><path d="M0,60 V14 Q0,0 14,0 H60 Q70,0 78,5 L90,12 Q97,16 108,16 H146 Q160,16 160,30 V60 Z" fill="url(#g)"/></svg>';
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = height ?? 150;
    return SizedBox(
      height: cardHeight,
      child: Container(
        padding: EdgeInsets.only(top: peek + 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 6,
              right: 6,
              top: 0,
              child: SizedBox(
                height: 60,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.black, Colors.black, Colors.transparent],
                    stops: <double>[0, .65, 1],
                  ).createShader(rect),
                  child: SvgPicture.string(
                    _folderSvg,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: -12,
              height: cardHeight * .38 + 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[tone.glow, tone.glow.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: peek,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(22)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black,
                        Colors.black,
                        Color(0x59000000),
                        Colors.transparent,
                      ],
                      stops: <double>[0, .52, .78, 1],
                    ).createShader(rect),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[tone.tintA, tone.tintB],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 1,
                          child: ColoredBox(color: AppColors.white85),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.white45),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(22),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 60,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  AppColors.white50,
                                  AppColors.transparent,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(left: 12, right: 12, bottom: 12, child: child),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);

  testWidgets('before glass cards (reproduced)', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double colW = (constraints.maxWidth - 8) / 2;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: colW,
                      child: _OldGlassCard(
                        tone: _tokensTone,
                        peek: 22,
                        height: 150,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Tokens',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      height: 20 / 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A3E00),
                                    ),
                                  ),
                                ),
                                AppIcon(name: 'chev', size: 16, color: Color(0xFF7A3E00)),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Coin(size: 20),
                                SizedBox(width: 6),
                                Text(
                                  '2',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    height: 24 / 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7A3E00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: colW,
                      child: Column(
                        children: <Widget>[
                          _OldGlassCard(
                            tone: _vipTone,
                            peek: 14,
                            height: 71,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    height: 20 / 16,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF3E2A99),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Free Bonus',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    height: 16 / 11,
                                    color: Color(0xFF6B5BB0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _OldGlassCard(
                            tone: _inviteTone,
                            peek: 14,
                            height: 71,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const <Widget>[
                                SizedBox(
                                  width: 96,
                                  child: Text(
                                    'Invite to earn money',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      height: 16 / 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8A1F47),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Get Bonus',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    height: 16 / 11,
                                    color: Color(0xFFB0587A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    // The old layout overflows invisibly, like CSS "overflow: hidden".
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('reference_images/before_me_cards.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });
}
