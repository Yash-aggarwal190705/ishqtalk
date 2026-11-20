import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ishqtalk/features/auth/presentation/auth_state.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/foundation/app_theme.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/onboarding_state.dart';

const goldenSurface = ValueKey('golden-surface');

Future<void> loadPoppins() async {
  final loader = FontLoader('Poppins');
  for (final name in [
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'SemiBoldItalic',
    'BoldItalic',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/Poppins-$name.ttf'));
  }
  await loader.load();
}

class PortFixture extends StatelessWidget {
  const PortFixture({
    super.key,
    required this.child,
    this.app,
    this.onboarding,
    this.navigation,
    this.auth,
    this.freezeLoops = true,
    this.reducedMotion = false,
    this.padding = EdgeInsets.zero,
    this.fontFamilyFallback,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
  });
  final Widget child;
  final AppContextState? app;
  final OnboardingState? onboarding;
  final NavigationState? navigation;
  final AuthState? auth;
  final bool freezeLoops;
  final bool reducedMotion;
  final EdgeInsets padding;
  final List<String>? fontFamilyFallback;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      if (app != null) ChangeNotifierProvider.value(value: app!),
      if (onboarding != null) ChangeNotifierProvider.value(value: onboarding!),
      if (navigation != null) ChangeNotifierProvider.value(value: navigation!),
      if (auth != null) ChangeNotifierProvider.value(value: auth!),
      Provider.value(value: 'fixture'),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: padding,
            disableAnimations: reducedMotion,
            textScaler: TextScaler.noScaling,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontFamilyFallback: fontFamilyFallback,
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0,
              color: AppColors.ink,
              fontWeight: FontWeight.w400,
            ),
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: MotionScope(
              freezeLoops: freezeLoops,
              child: RepaintBoundary(key: goldenSurface, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

void usePortViewport(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
