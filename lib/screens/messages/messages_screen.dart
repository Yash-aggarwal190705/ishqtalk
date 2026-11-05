import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/badge.dart' as app;
import '../../shared/empty_state.dart';
import '../../shared/offline_banner.dart';
import '../../shared/portrait.dart';
import '../../state/app_context.dart';
import '../../state/models.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.instant = false});

  final bool instant;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.instant) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      _loading = false;
    }
  }

  double get _navHeight => 56 + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final AppContextState app = context.watch<AppContextState>();
    final NavigationState navigation = context.read<NavigationState>();
    final List<Conversation> convos = app.convos.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _Header(
              onHistory: () => navigation.push('history-list'),
              onNotifications: () => navigation.push('notifications'),
            ),
            if (app.offline)
              const OfflineBanner(
                text: "You're offline. Showing saved conversations.",
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: _navHeight),
                child: Column(
                  children: <Widget>[
                    _TopRow(
                      title: 'Visitors',
                      subtitle: 'Who visited my profile',
                      badgeCount: 2,
                      lead: _RowLead.visitors,
                      onTap: () => navigation.push('visitors-list'),
                    ),
                    const _TopRow(
                      title: 'Notifications',
                      subtitle: 'Welcome to IshqTalk! Local preview.',
                      date: '10-24',
                      badgeCount: 1,
                      lead: _RowLead.notifications,
                    ),
                    if (_loading)
                      for (int i = 0; i < 3; i++) const _RowSkeleton()
                    else if (convos.isEmpty)
                      EmptyState(
                        title: 'No conversations yet',
                        body: "Start one from someone's profile.",
                        action: 'Explore people',
                        onAction: () => navigation.tab('explore'),
                        child: const AppIcon(
                          name: 'chat',
                          size: 28,
                          color: AppColors.ink3,
                        ),
                      )
                    else
                      for (final Conversation convo in convos)
                        _ConversationRow(
                          convo: convo,
                          onTap: () {
                            navigation.openChat(convo.user.id);
                            app.markRead(convo.user.id);
                          },
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onHistory, required this.onNotifications});

  final VoidCallback onHistory;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.paddingOf(context).top,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      alignment: Alignment.bottomCenter,
      child: Row(
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
                'Message',
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
              _headerIcon(label: 'History', icon: 'history', onTap: onHistory),
              _headerIcon(
                label: 'Notifications',
                icon: 'bell',
                onTap: onNotifications,
              ),
              _headerIcon(label: 'More', icon: 'dots'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required String label,
    required String icon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SizedBox(
        width: 44,
        height: 44,
        child: AppTap(
          key: ValueKey<String>('header-$icon'),
          label: label,
          onTap:
              onTap ??
              () {
                // TODO: open the real notifications / overflow menu.
              },
          child: Center(
            child: AppIcon(name: icon, size: 24, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

enum _RowLead { visitors, notifications }

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.title,
    required this.subtitle,
    required this.lead,
    this.badgeCount = 0,
    this.date,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final _RowLead lead;
  final int badgeCount;
  final String? date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget leadCircle = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: lead == _RowLead.visitors
            ? AppColors.coinBg
            : AppColors.primary10,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIcon(
          name: lead == _RowLead.visitors ? 'eye' : 'bell',
          size: 24,
          color: lead == _RowLead.visitors ? AppColors.coin : AppColors.primary,
        ),
      ),
    );
    return AppTap(
      label: title,
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            leadCircle,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (date != null)
                    Text(
                      date!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        height: 14 / 11,
                        color: AppColors.ink2,
                      ),
                    ),
                  if (badgeCount > 0) app.Badge(number: badgeCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.convo, required this.onTap});

  final Conversation convo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = convo.unread > 0;
    final Message? last = convo.messages.isEmpty ? null : convo.messages.last;
    final String preview = last == null
        ? 'No messages yet'
        : last.from == 'me'
        ? 'You: ${last.text}'
        : last.text;
    return AppTap(
      label: convo.user.name,
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(child: _avatar()),
                  if (convo.user.avail == 'online')
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    convo.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                      color: unread ? AppColors.ink : AppColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (convo.date.isNotEmpty)
                    Text(
                      convo.date,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        height: 14 / 11,
                        color: AppColors.ink2,
                      ),
                    ),
                  if (unread) app.Badge(number: convo.unread),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    final String? url = convo.user.photoUrl;
    if (url == null || url.isEmpty) return Portrait(seed: convo.user.id);
    final Widget fallback = Portrait(seed: convo.user.id);
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

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          const Shimmer(
            child: ClipOval(child: SizedBox(width: 48, height: 48)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: const Shimmer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: SizedBox(height: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 2 / 3,
                  child: const Shimmer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: SizedBox(height: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal Notifications screen: a back header plus the single notification
/// we have data for. Expand when a notifications API exists.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Container(
              height: 64 + MediaQuery.paddingOf(context).top,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  AppTap(
                    label: 'Back',
                    onTap: () => navigation.back(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: AppIcon(
                          name: 'back',
                          size: 24,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const _TopRow(
              title: 'Notifications',
              subtitle: 'Welcome to IshqTalk! Local preview.',
              date: '10-24',
              badgeCount: 1,
              lead: _RowLead.notifications,
            ),
          ],
        ),
      ),
    );
  }
}
