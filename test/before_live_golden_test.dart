// Reproduces the BEFORE state of the big lantern (L1-L4) from the previous
// implementation: a Stack sized by its intrinsic image (no 55% box), halo
// gradient radius 1, label/flame laid out against that wrong box.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/navigation/nav.dart';

import 'support/login_golden_fonts.dart';
import 'support/port_fixture.dart';

const String _oldCamSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 56 56"><rect x="4" y="12" width="32" height="32" rx="7" fill="#B8400F"/><path d="M40 24 L51 17 Q53 16 53 18.500 V37.500 Q53 40 51 39 L40 32 Z" fill="#B8400F"/></svg>';

class _OldFlame extends StatelessWidget {
  const _OldFlame({
    required this.xPct,
    required this.yPct,
    required this.width,
    required this.height,
  });

  final double xPct;
  final double yPct;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPct / 100 * width - width * 0.22 / 2,
      top: yPct / 100 * height - width * 0.22 / 2,
      width: width * 0.22,
      height: width * 0.22,
      child: LoopMotion(
        duration: const Duration(milliseconds: 900),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              radius: 1,
              colors: <Color>[
                Color(0xFFFFFBE6),
                Color(0xFFFFE9A0),
                Color(0xBFFFB03C),
                Color(0x00FF8C00),
              ],
              stops: <double>[0, .28, .55, .75],
            ),
          ),
        ),
        builder: (context, phase, idle, child) {
          final double e = Curves.easeInOut.transform(phase);
          return Transform.scale(
            scale: .9 + .25 * e,
            child: Opacity(opacity: .7 + .3 * e, child: child),
          );
        },
      ),
    );
  }
}

class _OldBigLanternSprite extends StatelessWidget {
  const _OldBigLanternSprite({
    required this.image,
    required this.width,
    required this.height,
  });

  final AssetImage image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start',
      child: AppTap(
        onTap: () {},
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: -width * .45,
              top: -height * .35,
              width: width * 1.9,
              height: height * 1.7,
              child: LoopMotion(
                duration: const Duration(milliseconds: 6000),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      radius: 1,
                      colors: <Color>[
                        Color(0xBFFF9632),
                        Color(0x59FF781E),
                        Colors.transparent,
                      ],
                      stops: <double>[0, .55, 1],
                    ),
                  ),
                ),
                builder: (context, phase, idle, child) {
                  final double e = Curves.easeInOut.transform(phase);
                  return Transform.scale(
                    scale: 1 + .08 * e,
                    child: Opacity(opacity: 1 - .4 * e, child: child),
                  );
                },
              ),
            ),
            Image(image: image, fit: BoxFit.contain),
            Positioned(
              left: 0,
              right: 0,
              top: height * 0.30,
              child: Column(
                children: <Widget>[
                  SvgPicture.string(
                    _oldCamSvg,
                    width: width * 0.20,
                    height: width * 0.20,
                  ),
                  SizedBox(height: width * 0.03),
                  Text(
                    'Start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.10,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB8400F),
                    ),
                  ),
                ],
              ),
            ),
            _OldFlame(
              xPct: 49.3,
              yPct: 90.2,
              width: width,
              height: height,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadLoginGoldenFonts);

  testWidgets('before big lantern (reproduced)', (tester) async {
    final AppContextState app = AppContextState();
    final NavigationState navigation = NavigationState(app: app);
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        fontFamilyFallback: loginGoldenFallback,
        app: app,
        navigation: navigation,
        child: LayoutBuilder(
          builder: (context, c) {
            final double w = c.maxWidth;
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFF0D0A24),
                        Color(0xFF3A1646),
                        Color(0xFFC2441B),
                      ],
                      stops: <double>[0, .52, 1],
                    ),
                  ),
                ),
                Center(
                  child: _OldBigLanternSprite(
                    image: const AssetImage('assets/images/lantern_big.png'),
                    width: w * 0.55,
                    height: w * 0.55 * 738 / 640,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 10));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('reference_images/before_live_gift.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    navigation.dispose();
    app.dispose();
  });
}
