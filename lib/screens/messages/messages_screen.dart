import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/logo.dart';
import '../../shared/offline_banner.dart';
import '../../shared/portrait.dart';
import '../../shared/v2.dart';
import '../../state/app_context.dart';
import '../../state/models.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    this.instant = false,
    this.forceEmpty = false,
  });

  final bool instant;
  final bool forceEmpty; // test-only

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _loading = true;
  final Set<int> _muted = <int>{};
  final Set<int> _archived = <int>{};

  double get _navHeight => 56 + MediaQuery.paddingOf(context).bottom;

  @override
  void initState() {
    super.initState();
    if (!widget.instant) {
      // Prototype fakes 600ms; min 300ms so the skeleton never flashes.
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    AppSnack.hide();
    super.dispose();
  }

  void _snack(String message) {
    AppSnack.show(context, message, bottom: _navHeight + 12);
  }

  @override
  Widget build(BuildContext context) {
    final AppContextState app = context.watch<AppContextState>();
    final NavigationState navigation = context.read<NavigationState>();
    final List<Conversation> all = widget.forceEmpty
        ? const <Conversation>[]
        : (app.convos.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
    final List<Conversation> chats = all
        .where((c) => !_archived.contains(c.user.id))
        .toList();

    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              children: <Widget>[
                _Header(
                  onHistory: () => navigation.push('history-list'),
                  onHelp: () => _snack('Coming soon'),
                  onMore: () => _openMoreSheet(app),
                ),
                if (app.offline)
                  const OfflineBanner(
                    text: "You're offline. Showing saved conversations.",
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: _navHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _SysRow(
                          disc: const _Disc(
                            color: AppColors.coinBg,
                            icon: 'eye',
                            iconSize: 26,
                            iconColor: AppColors.ink,
                          ),
                          title: 'Profile visitors',
                          preview: 'See who looked at your profile',
                          onTap: () => navigation.push('visitors-list'),
                        ),
                        _SysRow(
                          disc: const _Disc(
                            color: AppColors.primary10,
                            icon: 'bell',
                            iconSize: 26,
                            iconColor: AppColors.primary,
                          ),
                          title: 'Notifications',
                          preview: 'Welcome to YourApp! Say hi in a live room.',
                          date: '24 Oct',
                          onTap: () => navigation.push('notifications'),
                        ),
                        _SysRow(
                          disc: const _Disc(
                            color: Color(0xFFFFE3EA),
                            logoSize: 34,
                          ),
                          title: 'YourApp Help',
                          preview: 'Questions or something wrong? Ask here',
                          onTap: () => _snack('Coming soon'),
                        ),
                        const SizedBox(
                          height: 1,
                          child: ColoredBox(color: AppColors.divider),
                        ),
                        if (_loading)
                          ShimmerScope(
                            child: Column(
                              children: <Widget>[
                                for (int i = 0; i < 6; i++)
                                  const _SkeletonRow(),
                              ],
                            ),
                          )
                        else if (chats.isEmpty)
                          _EmptyState(onFindRoom: () => navigation.tab('live'))
                        else
                          for (final Conversation convo in chats)
                            _ConversationRow(
                              convo: convo,
                              muted: _muted.contains(convo.user.id),
                              onTap: () {
                                navigation.openChat(convo.user.id);
                                app.markRead(convo.user.id);
                              },
                              onLongPress: () => _openRowMenu(convo, app),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // More sheet + confirm dialog
  // ---------------------------------------------------------------------------
  Future<void> _openMoreSheet(AppContextState app) {
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Text(
              'Messages options',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.sub,
              ),
            ),
          ),
          _SheetRow(
            label: 'Mark all as read',
            onTap: () {
              Navigator.of(sheetContext).pop();
              app.markAllRead();
              _snack('All messages marked as read');
            },
          ),
          _SheetRow(
            label: 'Clear message list',
            danger: true,
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openClearDialog(app);
            },
          ),
          const SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.divider),
          ),
          _SheetRow(
            label: 'Cancel',
            center: true,
            bold: true,
            primary: true,
            onTap: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _openClearDialog(AppContextState app) {
    return showAppDialog<void>(
      context,
      dialogKey: const ValueKey<String>('clear-dialog'),
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Clear your message list?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "This removes all conversations from your list. This can't be undone.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 24),
          NeoButton(
            'Clear list',
            danger: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              app.clearConvos();
              _snack('Message list cleared');
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: AppTap(
              label: 'Cancel',
              onTap: () => Navigator.of(dialogContext).pop(),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
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

  // ---------------------------------------------------------------------------
  // Row menu (long-press)
  // ---------------------------------------------------------------------------
  Future<void> _openRowMenu(Conversation convo, AppContextState app) {
    final bool muted = _muted.contains(convo.user.id);
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) {
        void close() => Navigator.of(sheetContext).pop();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(
                convo.user.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.sub,
                ),
              ),
            ),
            _SheetRow(
              label: muted ? 'Unmute' : 'Mute',
              onTap: () {
                close();
                setState(() {
                  if (muted) {
                    _muted.remove(convo.user.id);
                  } else {
                    _muted.add(convo.user.id);
                  }
                });
                _snack(
                  muted
                      ? 'Unmuted ${convo.user.name}'
                      : 'Muted ${convo.user.name}',
                );
              },
            ),
            _SheetRow(
              label: 'Archive',
              onTap: () {
                close();
                setState(() => _archived.add(convo.user.id));
                _snack('Conversation archived');
              },
            ),
            _SheetRow(
              label: 'Report',
              onTap: () {
                close();
                _snack('Report sent. Thank you for helping keep YourApp safe');
              },
            ),
            _SheetRow(
              label: 'Block',
              danger: true,
              onTap: () {
                close();
                app.block(convo.user.id);
                _snack('Blocked ${convo.user.name}');
              },
            ),
            const SizedBox(
              height: 1,
              child: ColoredBox(color: AppColors.divider),
            ),
            _SheetRow(
              label: 'Cancel',
              center: true,
              bold: true,
              primary: true,
              onTap: close,
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header (not the shared Header)
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.onHistory,
    required this.onHelp,
    required this.onMore,
  });

  final VoidCallback onHistory;
  final VoidCallback onHelp;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.paddingOf(context).top,
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Messages',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              height: 32 / 28,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          Row(
            children: <Widget>[
              _IconBtn(
                label: 'Call history',
                icon: 'history',
                onTap: onHistory,
              ),
              _IconBtn(label: 'Help', icon: 'headset', onTap: onHelp),
              _IconBtn(label: 'More', icon: 'dots', onTap: onMore),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      label: label,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: AppIcon(name: icon, size: 24, color: AppColors.ink),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// System row + disc
// ---------------------------------------------------------------------------
class _Disc extends StatelessWidget {
  const _Disc({
    required this.color,
    this.icon,
    this.iconSize = 26,
    this.iconColor,
    this.logoSize,
  });

  final Color color;
  final String? icon;
  final double iconSize;
  final Color? iconColor;
  final double? logoSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: icon != null
            ? AppIcon(name: icon!, size: iconSize, color: iconColor)
            : Logo(size: logoSize!),
      ),
    );
  }
}

class _SysRow extends StatelessWidget {
  const _SysRow({
    required this.disc,
    required this.title,
    required this.preview,
    this.date,
    required this.onTap,
  });

  final Widget disc;
  final String title;
  final String preview;
  final String? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              disc,
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
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.sub,
                      ),
                    ),
                  ],
                ),
              ),
              if (date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    date!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.sub,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conversation row
// ---------------------------------------------------------------------------
class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.convo,
    required this.muted,
    required this.onTap,
    required this.onLongPress,
  });

  final Conversation convo;
  final bool muted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool unread = convo.unread > 0;
    final bool live = convo.user.avail == 'online';
    final Message? last = convo.messages.isEmpty ? null : convo.messages.last;
    final String preview = last == null
        ? 'No messages yet'
        : last.from == 'me'
        ? 'You: ${last.text}'
        : last.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        key: ValueKey<String>('row-${convo.user.id}'),
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              _Avatar(convo: convo, live: live),
              const SizedBox(width: 12),
              Expanded(
                key: ValueKey<String>('text-${convo.user.id}'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            convo.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 24 / 16,
                              fontWeight: unread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (muted) ...<Widget>[
                          const SizedBox(width: 6),
                          const AppIcon(
                            name: 'bellOff',
                            size: 14,
                            color: AppColors.sub,
                            stroke: 2,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                        color: unread ? AppColors.ink : AppColors.sub,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 42,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if (convo.date.isNotEmpty)
                      Text(
                        convo.date,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.sub,
                        ),
                      ),
                    if (unread)
                      Container(
                        height: 20,
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          '${convo.unread}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.convo, required this.live});

  final Conversation convo;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final Widget portrait = Portrait(seed: convo.user.id % 10);
    final Widget face = ClipOval(
      child: SizedBox(
        width: live ? 50 : 56,
        height: live ? 50 : 56,
        child: portrait,
      ),
    );
    return SizedBox(
      key: ValueKey<String>('avatar-${convo.user.id}'),
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: live
                  ? const <BoxShadow>[
                      // 2px primary ring drawn OUTSIDE the 56 box.
                      BoxShadow(color: AppColors.primary, spreadRadius: 2),
                    ]
                  : null,
            ),
            child: live
                ? Padding(padding: const EdgeInsets.all(3), child: face)
                : face,
          ),
          if (live)
            Positioned(
              key: ValueKey<String>('live-${convo.user.id}'),
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    height: 16 / 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton row
// ---------------------------------------------------------------------------
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            const ShimmerBox(w: 56, h: 56, circle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: ShimmerBox(h: 14),
                  ),
                  const SizedBox(height: 8),
                  const FractionallySizedBox(
                    widthFactor: 2 / 3,
                    child: ShimmerBox(h: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onFindRoom});

  final VoidCallback onFindRoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(name: 'chat', size: 28, color: AppColors.primary),
            ),
          ),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Say hi in a live room to start one.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 20),
          NeoButton('Find a room', fill: false, onPressed: onFindRoom),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet row
// ---------------------------------------------------------------------------
class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.onTap,
    this.danger = false,
    this.center = false,
    this.bold = false,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool center;
  final bool bold;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color color = danger
        ? AppColors.danger
        : primary
        ? AppColors.primary
        : AppColors.ink;
    return SizedBox(
      height: 56,
      child: AppTap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Text(
              label,
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
