import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/age_chip.dart';
import '../../shared/coin.dart';
import '../../shared/lv_chip.dart';
import '../../shared/portrait.dart';
import '../../state/app_context.dart';
import '../../state/models.dart';
import '../../state/profile_repository.dart';
import 'safety_flow.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.user,
    this.repository = const SeedProfileRepository(loadingDelay: Duration.zero),
    this.instant = false,
  });

  final AppUser user;
  final ProfileRepository repository;
  final bool instant;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  ProfileStats? _stats;
  List<String> _photos = const <String>[];
  bool _safety = false;

  @override
  void initState() {
    super.initState();
    _load();
    if (!widget.instant) {
      // Report a visit on enter: feeds the other user's Visitors list and
      // the "Profiles viewed" counter. Post-frame to avoid notify during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AppContextState>().visit(widget.user.id);
      });
    }
  }

  Future<void> _load() async {
    final ProfileStats stats = await widget.repository.statsFor(widget.user);
    final List<String> photos = await widget.repository.photosFor(widget.user);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _photos = photos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppContextState app = context.watch<AppContextState>();
    final NavigationState navigation = context.read<NavigationState>();
    final bool isFollowing = app.following.contains(widget.user.id);

    // System back closes the safety sheet/dialog before popping the profile.
    return PopScope(
      canPop: !_safety,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _safety = false);
      },
      child: SlideIn(
        child: Material(
          color: AppColors.white,
          child: SafeArea(
            top: false,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _TopBar(
                      onBack: navigation.back,
                      onMore: () => setState(() => _safety = true),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _IdentityBlock(user: widget.user, stats: _stats),
                            _ActionButtons(
                              following: isFollowing,
                              onFollow: () => app.toggleFollow(widget.user.id),
                              onMessage: () =>
                                  navigation.messageUser(widget.user),
                            ),
                            const _PhotosTab(),
                            _PhotoGrid(user: widget.user, photos: _photos),
                          ],
                        ),
                      ),
                    ),
                    _CallBar(
                      user: widget.user,
                      onCall: () => navigation.call(widget.user),
                    ),
                  ],
                ),
                if (_safety)
                  SafetyFlow(
                    user: widget.user,
                    onClose: () => setState(() => _safety = false),
                    onBlock: () => app.block(widget.user.id),
                    onBlocked: () {
                      // The PopScope refuses to pop while the overlay flag is
                      // still set; pop right after the rebuild.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) navigation.back();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 + MediaQuery.paddingOf(context).top,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: <Widget>[
          AppTap(
            label: 'Back',
            onTap: onBack,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AppIcon(name: 'back', size: 24, color: AppColors.ink),
              ),
            ),
          ),
          const Spacer(),
          AppTap(
            label: 'More options',
            onTap: onMore,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AppIcon(name: 'dots', size: 20, color: AppColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.user, required this.stats});

  final AppUser user;
  final ProfileStats? stats;

  String get _availLabel => switch (user.avail) {
    'online' => 'Online now',
    'away' => 'Away',
    _ => 'Unavailable',
  };

  Color get _availColor => switch (user.avail) {
    'online' => AppColors.onlineGreen,
    'away' => AppColors.coin,
    _ => AppColors.lvGray,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          SizedBox(width: 80, height: 80, child: _avatar()),
          const SizedBox(height: 12),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _availColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _availLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.ink2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AgeChip(age: user.age, country: user.country ?? 'India'),
              const SizedBox(width: 8),
              const LvChip(level: 3),
            ],
          ),
          if (user.topic != null) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                user.topic!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _Stat(number: '${stats?.following ?? 0}', label: 'Following'),
              _Stat(number: '${stats?.fans ?? 0}', label: 'Fans'),
              _Stat(number: '${stats?.friends ?? 0}', label: 'Friends'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final String? url = user.photoUrl;
    if (url == null || url.isEmpty) return Portrait(seed: user.id);
    final Widget fallback = Portrait(seed: user.id);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.following,
    required this.onFollow,
    required this.onMessage,
  });

  final bool following;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              toggled: following,
              child: SizedBox(
                height: 44,
                child: AppTap(
                  onTap: onFollow,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: following ? AppColors.card : AppColors.primary10,
                      border: following
                          ? Border.all(color: AppColors.divider)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      following ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: following ? AppColors.ink : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: AppTap(
                onTap: onMessage,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Photos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.user, required this.photos});

  final AppUser user;
  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final List<String> tiles = photos.isEmpty
        ? const <String>['', '', '']
        : photos;
    return Row(
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++)
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Portrait(seed: user.id + 3 + i),
            ),
          ),
      ],
    );
  }
}

class _CallBar extends StatelessWidget {
  const _CallBar({required this.user, required this.onCall});

  final AppUser user;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final bool unavailable = user.avail == 'unavailable';
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x143B3354),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        height: 48,
        child: AppTap(
          onTap: unavailable ? null : onCall,
          enabled: !unavailable,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: unavailable ? .4 : 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: unavailable
                ? const Text(
                    'Unavailable right now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        '35',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 18 / 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Coin(size: 14),
                      const Text(
                        '/min',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 18 / 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const AppIcon(
                        name: 'cam',
                        size: 22,
                        color: AppColors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
