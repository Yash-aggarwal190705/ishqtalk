import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'foundation/app_theme.dart';
import 'navigation/app_shell.dart';
import 'navigation/nav.dart';
import 'state/app_context.dart';
import 'state/onboarding_state.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/data/supabase_auth_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.preferences,
    this.debugScreenPicker = const bool.fromEnvironment('DEV_SCREEN_PICKER'),
    this.initialScreen = const String.fromEnvironment(
      'INITIAL_SCREEN',
      defaultValue: 'splash',
    ),
  });

  final SharedPreferences? preferences;
  final bool debugScreenPicker;
  final String initialScreen;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthState(
          repository: SupabaseAuthRepository(),
        )..initialize(),
      ),
      ChangeNotifierProvider(
        create: (_) => AppContextState(preferences: preferences),
      ),
      ChangeNotifierProvider(
        create: (_) => OnboardingState(preferences: preferences),
      ),
      ChangeNotifierProvider(
        create: (context) => NavigationState(
          app: context.read<AppContextState>(),
          screen: kDebugMode ? initialScreen : 'splash',
        ),
      ),
    ],
    child: Builder(
      builder: (context) {
        final NavigationState navigation = context.read<NavigationState>();
        return MaterialApp(
          title: 'IshqTalk',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          navigatorKey: navigation.navigatorKey,
          navigatorObservers: <NavigatorObserver>[navigation.navigatorObserver],
          builder: (context, child) => DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0,
              fontWeight: FontWeight.w400,
              color: AppColors.ink,
            ),
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: AppShell(debugScreenPicker: kDebugMode && debugScreenPicker),
        );
      },
    ),
  );
}
