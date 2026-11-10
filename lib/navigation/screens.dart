import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../foundation/app_theme.dart';
import '../screens/explore/explore_screen.dart';
import '../features/commerce/bonus_screen.dart';
import '../features/commerce/history_screen.dart';
import '../features/commerce/tokens_screen.dart';
import '../features/items/domain.dart';
import '../features/items/expired_items_screen.dart';
import '../features/items/my_items_screen.dart';
import '../screens/chat/conversation_screen.dart';
import '../screens/me/edit_profile_screen.dart';
import '../features/wallet/level_screen.dart';
import '../features/wallet/token_history_screen.dart';
import '../screens/live/live_screen.dart';
import '../screens/me/me_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/messages/notifications_screen.dart';
import '../screens/onboarding/login.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/visitors/visitors_screen.dart';
import '../screens/onboarding/splash.dart';
import '../screens/onboarding/welcome_offer.dart';
import 'nav.dart';

typedef ScreenBuilder = Widget Function(
  BuildContext context,
  ScreenDef definition,
);

class ScreenDef {
  const ScreenDef({
    required this.id,
    required this.label,
    required this.group,
    required this.builder,
    this.props = const <String, Object?>{},
    this.navTab,
  });

  final String id;
  final String label;
  final String group;
  final ScreenBuilder builder;
  final Map<String, Object?> props;
  final String? navTab;
}

Widget pendingScreen(BuildContext context, ScreenDef definition) {
  return ColoredBox(
    color: AppColors.screen,
    child: Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.tintInvite,
          border: Border.all(color: AppColors.badge, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'PENDING PORT\n${definition.id}\n\n${definition.label}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    ),
  );
}

Widget _welcomeOfferBuilder(BuildContext context, ScreenDef definition) {
  final NavigationState navigation = context.read<NavigationState>();
  return WelcomeOffer(
    forceNotif: definition.props['forceNotif'] == true,
    forcePay: definition.props['forcePay'] == true,
    instant: navigation.instant,
  );
}

Widget _splashBuilder(BuildContext context, ScreenDef definition) =>
    const Splash();

Widget _loginBuilder(BuildContext context, ScreenDef definition) => Login(
  expanded: definition.props['expanded'] == true,
  modal: definition.props['modal'] as String?,
  instant: context.read<NavigationState>().instant,
);

Widget _exploreBuilder(BuildContext context, ScreenDef definition) =>
    ExploreScreen(instant: context.read<NavigationState>().instant);

Widget _liveBuilder(BuildContext context, ScreenDef definition) => LiveScreen(
  initial: definition.props['initial'] as LiveState? ?? LiveState.gift,
);

Widget _messagesBuilder(BuildContext context, ScreenDef definition) =>
    MessagesScreen(instant: context.read<NavigationState>().instant);

Widget _notificationsBuilder(BuildContext context, ScreenDef definition) =>
    NotificationsScreen(empty: definition.props['empty'] == true);

Widget _meBuilder(BuildContext context, ScreenDef definition) =>
    MeScreen(instant: context.read<NavigationState>().instant);

Widget _profileBuilder(BuildContext context, ScreenDef definition) =>
    UserProfileScreen(user: context.read<NavigationState>().user);

Widget _tokensBuilder(BuildContext context, ScreenDef definition) =>
    const TokensScreen();

Widget _bonusBuilder(BuildContext context, ScreenDef definition) =>
    const BonusScreen();

Widget _myItemsBuilder(BuildContext context, ScreenDef definition) =>
    MyItemsScreen(
      initialTab: definition.props['initialTab'] as ItemTab? ?? ItemTab.passes,
    );

Widget _expiredItemsBuilder(BuildContext context, ScreenDef definition) =>
    ExpiredItemsScreen();

Widget _historyBuilder(BuildContext context, ScreenDef definition) =>
    HistoryScreen(empty: definition.props['empty'] == true);

Widget _tokenHistoryBuilder(BuildContext context, ScreenDef definition) =>
    const TokenHistoryScreen();

Widget _levelBuilder(BuildContext context, ScreenDef definition) =>
    const LevelScreen();

Widget _chatBuilder(BuildContext context, ScreenDef definition) {
  final NavigationState navigation = context.read<NavigationState>();
  return ConversationScreen(
    id: navigation.chatId ?? definition.props['id'] as int? ?? 10,
  );
}

Widget _editProfileBuilder(BuildContext context, ScreenDef definition) =>
    const EditProfileScreen();

Widget _visitorsBuilder(BuildContext context, ScreenDef definition) =>
    VisitorsScreen(
      instant: context.read<NavigationState>().instant,
      pinLoading: definition.props['pinLoading'] == true,
    );

const List<ScreenDef> screens = <ScreenDef>[
  ScreenDef(
    id: 'splash',
    label: 'Splash',
    group: 'ONBOARDING',
    builder: _splashBuilder,
  ),
  ScreenDef(
    id: 'login',
    label: 'Login (collapsed)',
    group: 'ONBOARDING',
    builder: _loginBuilder,
  ),
  ScreenDef(
    id: 'login-expanded',
    label: 'Login (expanded)',
    group: 'ONBOARDING',
    builder: _loginBuilder,
    props: <String, Object?>{'expanded': true},
  ),
  ScreenDef(
    id: 'login-google',
    label: 'Account Chooser',
    group: 'ONBOARDING',
    builder: _loginBuilder,
    props: <String, Object?>{'modal': 'google'},
  ),
  ScreenDef(
    id: 'login-email',
    label: 'Email Sheet',
    group: 'ONBOARDING',
    builder: _loginBuilder,
    props: <String, Object?>{'modal': 'email'},
  ),
  ScreenDef(
    id: 'login-otp',
    label: 'OTP',
    group: 'ONBOARDING',
    builder: _loginBuilder,
    props: <String, Object?>{'modal': 'email-otp'},
  ),
  ScreenDef(
    id: 'welcome-offer',
    label: 'Welcome Offer',
    group: 'ONBOARDING',
    builder: _welcomeOfferBuilder,
  ),
  ScreenDef(
    id: 'notif-prompt',
    label: 'Notification Prompt',
    group: 'ONBOARDING',
    builder: _welcomeOfferBuilder,
    props: <String, Object?>{'forceNotif': true},
  ),
  ScreenDef(
    id: 'payment-sheet',
    label: 'Payment Sheet',
    group: 'ONBOARDING',
    builder: _welcomeOfferBuilder,
    props: <String, Object?>{'forcePay': true},
  ),
  ScreenDef(
    id: 'live',
    label: 'Live Home',
    group: 'MAIN TABS',
    builder: _liveBuilder,
    navTab: 'live',
  ),
  ScreenDef(
    id: 'explore',
    label: 'Explore',
    group: 'MAIN TABS',
    builder: _exploreBuilder,
    navTab: 'explore',
  ),
  ScreenDef(
    id: 'messages',
    label: 'Messages',
    group: 'MAIN TABS',
    builder: _messagesBuilder,
    navTab: 'messages',
  ),
  ScreenDef(
    id: 'me',
    label: 'My Profile',
    group: 'MAIN TABS',
    builder: _meBuilder,
    navTab: 'me',
  ),
  ScreenDef(
    id: 'live-searching',
    label: 'Live Home – Searching',
    group: 'LIVE',
    builder: _liveBuilder,
    props: <String, Object?>{'initial': LiveState.searching},
    navTab: 'live',
  ),
  ScreenDef(
    id: 'live-free',
    label: 'Live Home – Free',
    group: 'LIVE',
    builder: _liveBuilder,
    props: <String, Object?>{'initial': LiveState.free},
    navTab: 'live',
  ),
  ScreenDef(
    id: 'live-gift',
    label: 'Live Home – Gift offer',
    group: 'LIVE',
    builder: _liveBuilder,
    props: <String, Object?>{'initial': LiveState.gift},
    navTab: 'live',
  ),
  ScreenDef(
    id: 'sky-lantern',
    label: 'Sky Lantern',
    group: 'LIVE',
    builder: pendingScreen,
  ),
  ScreenDef(
    id: 'profile',
    label: 'User Profile',
    group: 'DISCOVER',
    builder: _profileBuilder,
  ),
  ScreenDef(
    id: 'call',
    label: 'Calling Sheet',
    group: 'DISCOVER',
    builder: pendingScreen,
    navTab: 'explore',
  ),
  ScreenDef(
    id: 'notifications',
    label: 'Notifications',
    group: 'MESSAGES',
    builder: _notificationsBuilder,
  ),
  ScreenDef(
    id: 'visitors-loading',
    label: 'Visitors Loading',
    group: 'MESSAGES',
    builder: _visitorsBuilder,
    props: <String, Object?>{'pinLoading': true},
  ),
  ScreenDef(
    id: 'visitors-list',
    label: 'Visitors List',
    group: 'MESSAGES',
    builder: _visitorsBuilder,
  ),
  ScreenDef(
    id: 'tokens',
    label: 'Get Tokens',
    group: 'COMMERCE',
    builder: _tokensBuilder,
  ),
  ScreenDef(
    id: 'bonus',
    label: 'Bonus',
    group: 'COMMERCE',
    builder: _bonusBuilder,
  ),
  ScreenDef(
    id: 'package-props',
    label: 'My items',
    group: 'COMMERCE',
    builder: _myItemsBuilder,
    props: <String, Object?>{'initialTab': ItemTab.passes},
  ),
  ScreenDef(
    id: 'package-gift',
    label: 'My items – Gifts',
    group: 'COMMERCE',
    builder: _myItemsBuilder,
    props: <String, Object?>{'initialTab': ItemTab.gifts},
  ),
  ScreenDef(
    id: 'expired-items',
    label: 'Expired items',
    group: 'COMMERCE',
    builder: _expiredItemsBuilder,
  ),
  ScreenDef(
    id: 'token-history',
    label: 'Token History',
    group: 'HISTORY',
    builder: _tokenHistoryBuilder,
  ),
  ScreenDef(
    id: 'level',
    label: 'Level',
    group: 'HISTORY',
    builder: _levelBuilder,
  ),
  ScreenDef(
    id: 'history-list',
    label: 'History List',
    group: 'HISTORY',
    builder: _historyBuilder,
  ),
  ScreenDef(
    id: 'history-empty',
    label: 'History Empty',
    group: 'HISTORY',
    builder: _historyBuilder,
    props: <String, Object?>{'empty': true},
  ),
  ScreenDef(
    id: 'welcome',
    label: 'Welcome',
    group: 'OTHER',
    builder: pendingScreen,
  ),
  ScreenDef(
    id: 'setup',
    label: 'Profile Setup',
    group: 'OTHER',
    builder: pendingScreen,
  ),
  ScreenDef(
    id: 'chat',
    label: 'Conversation',
    group: 'OTHER',
    builder: _chatBuilder,
    props: <String, Object?>{'id': 10},
  ),
  ScreenDef(
    id: 'edit-profile',
    label: 'Edit profile',
    group: 'OTHER',
    builder: _editProfileBuilder,
  ),
  ScreenDef(
    id: 'settings',
    label: 'App Settings',
    group: 'OTHER',
    builder: pendingScreen,
  ),
];

final Map<String, ScreenDef> screenById = <String, ScreenDef>{
  for (final ScreenDef screen in screens) screen.id: screen,
};

final List<String> screenGroups = <String>[
  ...<String>{for (final ScreenDef screen in screens) screen.group},
];
