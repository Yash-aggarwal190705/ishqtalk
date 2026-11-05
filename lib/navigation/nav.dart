import 'package:flutter/material.dart';

import '../foundation/app_theme.dart';
import '../shared/call_sheet.dart';
import '../state/app_context.dart';
import '../state/models.dart';
import 'screens.dart';

/// Hooks a tab screen registers so the shell's PopScope can decide what a
/// system back press means while that tab is active (e.g. close Explore
/// search or the edit-profile sheet before leaving the tab).
class BackHooks {
  BackHooks({this.isBlocking, this.onBack});

  final bool Function()? isBlocking;
  final VoidCallback? onBack;
}

class NavigationState extends ChangeNotifier {
  NavigationState({
    required this.app,
    this.screen = 'splash',
    this.instant = false,
  }) {
    _observer = _NavObserver(this);
  }
  final AppContextState app;
  String screen;
  bool instant;
  final List<String> _stack = <String>[];

  AppUser user = users.first;
  int? chatId;
  bool signed = false;
  int coins = 2;
  AppUser? callUser;
  String? paymentPrice;

  /// Per-tab back hooks (IndexedStack keeps all tabs mounted, so each tab
  /// registers its own).
  final Map<String, BackHooks> _tabHooks = <String, BackHooks>{};

  void setTabHooks(String tab, BackHooks hooks) => _tabHooks[tab] = hooks;
  BackHooks? hooksForTab(String tab) => _tabHooks[tab];

  /// Real Navigator used by the app. Pushed screens are routes on top of the
  /// shell (home), so the system back button/gesture pops them one at a time.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final _NavObserver _observer;

  NavigatorObserver get navigatorObserver => _observer;

  static const Set<String> _tabs = <String>{
    'live',
    'explore',
    'messages',
    'me',
  };

  /// Screens shown instead of the shell (onboarding etc.), never above it.
  static const Set<String> _baseScreens = <String>{
    'splash',
    'login',
    'login-expanded',
    'login-google',
    'login-email',
    'login-otp',
    'welcome-offer',
    'notif-prompt',
    'payment-sheet',
    'sky-lantern',
    'welcome',
    'setup',
  };

  bool get isTab => _tabs.contains(screen);
  bool get isBase => _baseScreens.contains(screen);

  /// Last tab shown by the shell (used while a pushed route covers it).
  String lastTab = 'live';

  List<String> get stack => List<String>.unmodifiable(_stack);

  void push(String id, {bool instant = false}) {
    if (isTab) lastTab = screen;
    _stack.add(screen);
    _setScreen(id, instant: instant);
    if (!isTab) {
      // Forward navigation always pushes a real route (rule 8).
      navigatorKey.currentState?.push(_routeFor(id));
    }
  }

  void back({bool instant = false}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      // Pop the topmost route; the observer updates `screen`.
      navigatorKey.currentState!.maybePop();
      return;
    }
    // No Navigator (unit tests / direct screen pumps): restore logically.
    final String destination = _stack.isEmpty ? 'live' : _stack.removeLast();
    _setScreen(destination, instant: instant);
  }

  void tab(String id, {bool instant = false}) {
    // Switching tabs clears any pushed screens above the shell (rule 6).
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _stack.clear();
    lastTab = id;
    _setScreen(id, instant: instant);
  }

  void goto(String id, {bool instant = false}) {
    if (_tabs.contains(id)) lastTab = id;
    _setScreen(id, instant: instant);
  }

  void jump(String id) {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _setScreen(id, instant: true);
  }

  void openUser(AppUser nextUser) {
    user = nextUser;
    push('profile');
  }

  void openChat(int id) {
    if (id < 0) {
      tab('explore');
      return;
    }
    chatId = id;
    push('chat');
  }

  void messageUser(AppUser nextUser) {
    app.ensureConvo(nextUser);
    chatId = nextUser.id;
    push('chat');
  }

  void call(AppUser? nextUser) {
    callUser = nextUser;
    notifyListeners();
    if (nextUser == null) return;
    final BuildContext? ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    // Real modal route: system back closes only the sheet (rule 3.2.2).
    showModalBottomSheet<void>(
      context: ctx,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => CallSheet(
        user: nextUser,
        close: () {
          Navigator.of(sheetContext).pop();
          call(null);
        },
      ),
    ).whenComplete(() => _onCallSheetClosed(nextUser));
  }

  void pay(String? price) {
    paymentPrice = price;
    notifyListeners();
    if (price == null) return;
    final BuildContext? ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    showModalBottomSheet<void>(
      context: ctx,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.ink30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.paddingOf(sheetContext).bottom + 32,
        ),
        child: Text(
          'PENDING PORT\nPaySheet — $price',
          textAlign: TextAlign.center,
        ),
      ),
    ).whenComplete(() {
      if (paymentPrice == price) pay(null);
    });
  }

  void _onCallSheetClosed(AppUser user) {
    if (callUser?.id == user.id) call(null);
  }

  void signIn() {
    signed = true;
    notifyListeners();
  }

  Route<void> _routeFor(String id) {
    final ScreenDef definition = screenById[id] ?? screens.first;
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: id),
      builder: (context) => definition.builder(context, definition),
    );
  }

  void _setScreen(String id, {required bool instant}) {
    if (instant) {
      _stack.clear();
      callUser = null;
      paymentPrice = null;
    }
    screen = id;
    this.instant = instant;
    notifyListeners();
  }

  void _handleRoutePop(String poppedId) {
    if (_stack.isNotEmpty) {
      screen = _stack.removeLast();
    } else {
      screen = 'live';
    }
    instant = false;
    notifyListeners();
  }
}

class _NavObserver extends NavigatorObserver {
  _NavObserver(this._state);
  final NavigationState _state;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _state._handleRoutePop(route.settings.name ?? 'live');
  }
}
