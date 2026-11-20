import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../foundation/app_theme.dart';
import '../foundation/app_motion.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/live/live_screen.dart';
import '../screens/me/me_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../shared/bottom_nav.dart';
import '../state/app_context.dart';
import '../state/onboarding_state.dart';
import '../features/auth/presentation/auth_state.dart';
import 'nav.dart';
import 'screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.debugScreenPicker = false});

  final bool debugScreenPicker;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Timer? _splashTimer;
  bool _pickerOpen = false;

  static const List<String> _tabIds = <String>[
    'explore',
    'live',
    'messages',
    'me',
  ];

  @override
  void initState() {
    super.initState();
    // The splash timer is armed in build() so a delete-account restart back
    // to 'splash' re-arms it; the initial state is armed on first build.
  }

  Future<void> _advanceSplash() async {
    _splashTimer = null;
    if (!mounted) return;
    final NavigationState navigation = context.read<NavigationState>();
    if (navigation.screen != 'splash') return;

    // A real Supabase session skips the login screen. The session restore is
    // async, so wait briefly (max ~2s) for it to settle first.
    final AuthState auth = context.read<AuthState>();
    int waited = 0;
    while (mounted &&
        (auth.status == AuthStatus.initial ||
            auth.status == AuthStatus.loading) &&
        waited < 40) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited++;
    }
    if (!mounted) return;
    if (auth.isAuthenticated) {
      navigation.goto('live');
      if (kDebugMode || kProfileMode) {
        debugPrint('[STARTUP] splash -> live (authenticated)');
      }
      return;
    }

    final bool onboarded = context.read<OnboardingState>().onboarded;
    final bool hasProfile = context.read<AppContextState>().hasProfile;
    navigation.goto(onboarded || hasProfile ? 'live' : 'login');

    if (kDebugMode || kProfileMode) {
      debugPrint(
        '[STARTUP] splash -> ${onboarded || hasProfile ? 'live' : 'login'}',
      );
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.watch<NavigationState>();
    final AppContextState app = context.watch<AppContextState>();
    // Arm the splash timer whenever the screen is splash (startup or delete-
    // account restart); the one-shot timer advances to live/login.
    if (navigation.screen == 'splash' && _splashTimer == null) {
      _splashTimer = Timer(const Duration(milliseconds: 800), _advanceSplash);
    }
    // Pushed routes keep the tabs mounted underneath them (state kept); only
    // genuine base screens (onboarding) replace the shell.
    final bool base = navigation.isBase;
    final bool tabs = !base;

    // A tab screen can block back (Explore search, Me edit sheet).
    final String activeTab = navigation.isTab
        ? navigation.screen
        : navigation.lastTab;
    final BackHooks? hooks = navigation.hooksForTab(activeTab);
    final bool screenBlocked = tabs && (hooks?.isBlocking?.call() ?? false);
    final bool overlayOpen =
        navigation.callUser != null || navigation.paymentPrice != null;

    // Only Live (home) with nothing else open may exit the app. Base screens
    // (splash/login/welcome) are root screens, so back exits them (rule 7).
    final bool canPop =
        !tabs ||
        (navigation.screen == 'live' && !overlayOpen && !screenBlocked);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navigation.callUser != null) {
          navigation.call(null); // back closes the calling sheet first
          return;
        }
        if (navigation.paymentPrice != null) {
          navigation.pay(null); // back closes the pay sheet first
          return;
        }
        // Evaluate blocking hooks at back time (they can change without a
        // shell rebuild, e.g. Explore search opening).
        final String hookTab = navigation.isTab
            ? navigation.screen
            : navigation.lastTab;
        final BackHooks? hookNow = navigation.hooksForTab(hookTab);
        final bool blockedNow = hookNow?.isBlocking?.call() ?? false;
        if (blockedNow) {
          hookNow?.onBack?.call(); // close Explore search / edit sheet
          return;
        }
        if (navigation.isTab && navigation.screen != 'live') {
          navigation.tab('live'); // Explore / Messages / Me -> Live
        }
      },
      child: ColoredBox(
        color: AppColors.pageBackground,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.screen,
                boxShadow: MediaQuery.sizeOf(context).width >= 640
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: .25),
                          offset: const Offset(0, 25),
                          blurRadius: 50,
                          spreadRadius: -12,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (tabs)
                      _tabBody(navigation, app)
                    else
                      _baseBody(navigation),
                    if (widget.debugScreenPicker)
                      _DebugScreenPickerButton(
                        onTap: () => setState(() => _pickerOpen = true),
                      ),
                    if (_pickerOpen)
                      _DebugScreenPicker(
                        close: () => setState(() => _pickerOpen = false),
                        onSelect: (id) {
                          context.read<NavigationState>().jump(id);
                          setState(() => _pickerOpen = false);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Four tabs in one IndexedStack: state is kept when switching tabs and
  /// while pushed routes cover the shell.
  Widget _tabBody(NavigationState navigation, AppContextState app) {
    final int index = _tabIds.indexOf(navigation.screen);
    final int active = index < 0 ? _tabIds.indexOf(navigation.lastTab) : index;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        IndexedStack(
          index: active < 0 ? 1 : active,
          children: <Widget>[
            for (final String id in _tabIds)
              TickerMode(
                enabled: navigation.screen == id,
                child: KeyedSubtree(
                  key: ValueKey<String>('tab-$id'),
                  child: switch (id) {
                    'explore' => ExploreScreen(instant: navigation.instant),
                    'live' => LiveScreen(),
                    'messages' => MessagesScreen(instant: navigation.instant),
                    _ => MeScreen(instant: navigation.instant),
                  },
                ),
              ),
          ],
        ),
        BottomNav(
          active: navigation.screen,
          dark: navigation.screen == 'live',
          onTab: navigation.tab,
          badge: app.unread,
          dot: !navigation.signed,
        ),
      ],
    );
  }

  Widget _baseBody(NavigationState navigation) {
    final ScreenDef definition = screenById[navigation.screen] ?? screens.first;
    return FadeIn(
      key: ValueKey<String>(navigation.screen),
      instant: navigation.instant || definition.id == 'splash',
      child: definition.builder(context, definition),
    );
  }
}

class _DebugScreenPickerButton extends StatelessWidget {
  const _DebugScreenPickerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      right: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Screens',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 16 / 11,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugScreenPicker extends StatelessWidget {
  const _DebugScreenPicker({required this.close, required this.onSelect});

  final VoidCallback close;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.ink.withValues(alpha: 0.94),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Screen picker',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: close,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: <Widget>[
                    for (final String group in screenGroups) ...<Widget>[
                      Text(
                        group,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.profileA,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final ScreenDef definition in screens.where(
                        (screen) => screen.group == group,
                      ))
                        GestureDetector(
                          onTap: () => onSelect(definition.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Text(
                              '${definition.id} — ${definition.label}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                height: 18 / 13,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
