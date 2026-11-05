import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/empty_state.dart';
import '../../shared/offline_banner.dart';
import '../../shared/token_pill.dart';
import '../../state/app_context.dart';
import '../../state/models.dart';
import 'user_repository.dart';
import 'widgets/user_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.repository = const SeedUserRepository(),
    this.instant = false,
  });

  final UserRepository repository;
  final bool instant;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _users = const <AppUser>[];
  bool _loading = true;
  String _query = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loading = !widget.instant;
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // System back closes the search first (same as Cancel) while on Explore.
    context.read<NavigationState>().setTabHooks(
      'explore',
      BackHooks(isBlocking: () => _searching, onBack: _cancelSearch),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final List<AppUser> fetched = await widget.repository.fetch();
    if (!mounted) return;
    setState(() {
      _users = fetched;
      _loading = false;
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final AppContextState app = context.watch<AppContextState>();
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _header(navigation, app),
            if (app.offline)
              OfflineBanner(
                text: "You're offline. Showing saved people.",
                onRetry: _load,
              ),
            Expanded(child: _body(app.blocked)),
          ],
        ),
      ),
    );
  }

  Widget _header(NavigationState navigation, AppContextState app) {
    return Container(
      height: 64 + MediaQuery.paddingOf(context).top,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      alignment: Alignment.bottomCenter,
      child: _searching ? _searchBar() : _normalHeader(navigation, app),
    );
  }

  Widget _normalHeader(NavigationState navigation, AppContextState app) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final double size = math.min(
              20,
              math.max(18, constraints.maxWidth * 0.055),
            );
            return Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size,
                height: 28 / size,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            );
          },
        ),
        Row(
          children: <Widget>[
            TokenPill(
              variant: TokenPillVariant.soft,
              onPlus: () => navigation.push('tokens'),
              count: navigation.coins,
            ),
            const SizedBox(width: 4),
            AppTap(
              label: 'Search',
              onTap: () => setState(() => _searching = true),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AppIcon(
                    name: 'search',
                    size: 24,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        children: <Widget>[
          const AppIcon(name: 'search', size: 18, color: AppColors.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration.collapsed(
                hintText: 'Search by name',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.ink3,
                ),
              ),
            ),
          ),
          AppTap(
            label: 'Cancel',
            onTap: _cancelSearch,
            child: const SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  'Cancel',
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
        ],
      ),
    );
  }

  Widget _body(Set<int> blocked) {
    final List<AppUser> visible = _loading
        ? users
        : _users
              .where(
                (user) =>
                    !blocked.contains(user.id) &&
                    user.name.toLowerCase().contains(
                      _query.trim().toLowerCase(),
                    ),
              )
              .toList();
    if (!_loading && visible.isEmpty) {
      return EmptyState(
        title: 'No results',
        body: 'Try another name.',
        action: 'Clear search',
        onAction: _cancelSearch,
        child: const AppIcon(name: 'search', size: 28, color: AppColors.ink3),
      );
    }
    final List<AppUser> left = <AppUser>[];
    final List<AppUser> right = <AppUser>[];
    for (int i = 0; i < visible.length; i++) {
      (i.isEven ? left : right).add(visible[i]);
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        4,
        0,
        4,
        56 + MediaQuery.paddingOf(context).bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double columnWidth = (constraints.maxWidth - 4) / 2;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: columnWidth,
                child: Column(
                  children: <Widget>[
                    for (final AppUser user in left)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _loading ? _skeleton(user) : _card(user),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: columnWidth,
                child: Column(
                  children: <Widget>[
                    for (final AppUser user in right)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _loading ? _skeleton(user) : _card(user),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _skeleton(AppUser user) {
    return Shimmer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 174 / user.h,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _card(AppUser user) {
    final NavigationState navigation = context.read<NavigationState>();
    return UserCard(
      user: user,
      onTap: () => navigation.openUser(user),
      onCall: () => navigation.call(user),
    );
  }
}
