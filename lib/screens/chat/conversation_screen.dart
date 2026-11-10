import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/offline_banner.dart';
import '../../shared/portrait.dart';
import '../../shared/v2.dart';
import '../../state/app_context.dart';
import '../../state/models.dart';

const int _msgLimit = 500;

const String _smileSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"><circle cx="12" cy="12" r="9.5"/><path d="M8.5 14.5c1 1.4 2 2 3.5 2s2.5-.6 3.5-2M9 9.5v.01M15 9.5v.01" stroke-width="2.2"/></svg>';
const String _pictureSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4.5" width="18" height="15" rx="3.5"/><circle cx="9" cy="10" r="1.7"/><path d="M4 17l5-4.5 3.5 3 3-2.5L21 16.5"/></svg>';
const String _videoCamSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="2.5" y="5.5" width="13.5" height="13" rx="4" fill="currentColor"/><path d="M17.5 10.5l4-2.6a.8.8 0 011.2.7v6.8a.8.8 0 01-1.2.7l-4-2.6z" fill="currentColor"/><path d="M9.2 15.6s-2.7-1.6-2.7-3.5a1.5 1.5 0 012.7-.9 1.5 1.5 0 012.7.9c0 1.9-2.7 3.5-2.7 3.5z" fill="white"/></svg>';
const String _giftSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="10" width="17" height="10.5" rx="1.5"/><path d="M2.5 7h19v3h-19zM12 7v13.5M12 7C10 3 6.5 4 7.5 5.8S12 7 12 7zM12 7c2-4 5.5-3 4.5-1.2S12 7 12 7z"/></svg>';
const String _thermometerSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M10 14.5V5a2 2 0 014 0v9.5a4 4 0 11-4 0zM12 9v7"/></svg>';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.id});

  final int id;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    AppSnack.hide();
    super.dispose();
  }

  void _snack(String message) {
    AppSnack.show(context, message, bottom: 160);
  }

  void _submit(AppContextState app) {
    final String trimmed = _text.text.trim();
    if (trimmed.isEmpty) return;
    app.send(widget.id, trimmed);
    _text.clear();
    setState(() {});
    _scrollToBottom();
  }

  void _openSafetyFlow(AppUser user, NavigationState navigation) {
    _SafetyFlow(
      user: user,
      onClose: () {},
      onBlocked: navigation.back,
      withDetails: true,
    ).open(context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppContextState app = context.watch<AppContextState>();
    final NavigationState navigation = context.read<NavigationState>();
    final Conversation? convo = app.convos[widget.id];
    if (convo == null) return const SizedBox.shrink();
    final AppUser user = convo.user;
    final bool unavailable = user.avail == 'unavailable';
    final String text = _text.text;

    if (convo.unread > 0) app.markRead(widget.id);
    if (convo.messages.isNotEmpty) _scrollToBottom();

    return SlideIn(
      child: Material(
        color: AppColors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _TopBar(
                user: user,
                onBack: navigation.back,
                onMenu: () => _openSafetyFlow(user, navigation),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: <Widget>[
                    if (convo.messages.isEmpty)
                      _EmptyConversation(
                        name: user.name,
                        onExplore: () => navigation.tab('explore'),
                      )
                    else ...<Widget>[
                      Center(
                        child: Text(
                          convo.messages.first.time,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final Message m in convo.messages)
                        _Bubble(
                          message: m,
                          user: user,
                          onRetry: () => app.retry(widget.id, m.id),
                        ),
                    ],
                  ],
                ),
              ),
              _BottomArea(
                user: user,
                unavailable: unavailable,
                controller: _text,
                text: text,
                onSubmit: () => _submit(app),
                onChanged: () => setState(() {}),
                onTool: (String label) {
                  switch (label) {
                    case 'Emoji':
                      final String added = '$text😊';
                      _text.text = added.length > _msgLimit
                          ? added.substring(0, _msgLimit)
                          : added;
                      _text.selection = TextSelection.collapsed(
                        offset: _text.text.length,
                      );
                      setState(() {});
                    case 'Video call':
                      navigation.call(user);
                    default:
                      _snack('Coming soon');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.user,
    required this.onBack,
    required this.onMenu,
  });

  final AppUser user;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 64,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: AppTap(
                label: 'Back',
                onTap: onBack,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: AppIcon(
                      name: 'back',
                      size: 24,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: AppTap(
                label: 'Conversation menu',
                onTap: onMenu,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: AppIcon(
                      name: 'dots',
                      size: 24,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 56,
              right: 56,
              top: 0,
              bottom: 0,
              child: IgnorePointer(child: _TitleBlock(user: user)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.user});

  final AppUser user;

  static String _labelOf(String avail) => switch (avail) {
    'online' => 'Online now',
    'away' => 'Away',
    _ => 'Unavailable',
  };

  static Color _colorOf(String avail) => switch (avail) {
    'online' => AppColors.onlineGreen,
    'away' => AppColors.coin,
    _ => AppColors.lvGray,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _colorOf(user.avail),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _labelOf(user.avail),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.sub,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.name, required this.onExplore});

  final String name;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: <Widget>[
            const Text(
              'No messages yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Say hello to $name.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.sub,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: AppTap(
                onTap: onExplore,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Explore more people',
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
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.user,
    required this.onRetry,
  });

  final Message message;
  final AppUser user;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.from == 'me';
    final Widget body = message.photo != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Portrait(seed: message.photo!, width: 104, height: 188),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: mine ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: message.state == MessageState.failed
                  ? Border.all(color: AppColors.badge)
                  : null,
            ),
            child: Opacity(
              opacity: message.state == MessageState.pending ? .6 : 1,
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 24 / 16,
                  color: mine ? AppColors.white : AppColors.ink,
                ),
              ),
            ),
          );

    if (!mine) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(child: Portrait(seed: user.id % 10)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * .72,
              ),
              child: Align(alignment: Alignment.centerLeft, child: body),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * .78,
          ),
          child: body,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message.time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.sub,
              ),
            ),
            const SizedBox(width: 6),
            switch (message.state) {
              MessageState.pending => const Text(
                '· Sending…',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.sub,
                ),
              ),
              MessageState.sent => const Text(
                '· Saved locally',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.sub,
                ),
              ),
              MessageState.failed => Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '· Not sent',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink,
                    ),
                  ),
                  AppTap(
                    label: 'Retry',
                    onTap: onRetry,
                    child: const SizedBox(
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              height: 16 / 12,
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
            },
          ],
        ),
      ],
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.user,
    required this.unavailable,
    required this.controller,
    required this.text,
    required this.onSubmit,
    required this.onTool,
    required this.onChanged,
  });

  final AppUser user;
  final bool unavailable;
  final TextEditingController controller;
  final String text;
  final VoidCallback onSubmit;
  final ValueChanged<String> onTool;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final AppContextState app = context.watch<AppContextState>();
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (app.offline)
            const OfflineBanner(
              text: "You're offline. Messages won't send until you're back.",
            ),
          if (unavailable)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Text(
                '${user.name} is unavailable right now. You can still read past messages.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.sub,
                ),
              ),
            )
          else ...<Widget>[
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFFFE3EA),
              child: Row(
                children: <Widget>[
                  SvgPicture.string(
                    _thermometerSvg,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.badge,
                      BlendMode.srcIn,
                    ),
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Use 5 tokens (₹5) to send a message.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: _Composer(
                          controller: controller,
                          text: text,
                          onSubmit: onSubmit,
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SendButton(
                        enabled: text.trim().isNotEmpty,
                        onTap: onSubmit,
                      ),
                    ],
                  ),
                  if (text.length > _msgLimit - 100)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${text.length}/$_msgLimit',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            height: 16 / 12,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _ToolBtn(
                          label: 'Emoji',
                          svg: _smileSvg,
                          color: AppColors.ink60,
                          onTap: () => onTool('Emoji'),
                        ),
                        _ToolBtn(
                          label: 'Send photo',
                          svg: _pictureSvg,
                          color: AppColors.ink60,
                          onTap: () => onTool('Send photo'),
                        ),
                        _ToolBtn(
                          label: 'Video call',
                          svg: _videoCamSvg,
                          color: AppColors.primary,
                          onTap: () => onTool('Video call'),
                        ),
                        _ToolBtn(
                          label: 'Send gift',
                          svg: _giftSvg,
                          color: AppColors.cta,
                          onTap: () => onTool('Send gift'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.text,
    required this.onSubmit,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String text;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48, maxHeight: 112),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: _focused
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        minLines: 1,
        maxLength: _msgLimit,
        onChanged: (_) {
          setState(() {});
          widget.onChanged();
        },
        onSubmitted: (_) => widget.onSubmit(),
        onTap: () => setState(() => _focused = true),
        textInputAction: TextInputAction.send,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          height: 24 / 16,
          color: AppColors.ink,
        ),
        decoration: const InputDecoration(
          counterText: '',
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'Type something sweet…',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.ink60,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .4,
      child: AppTap(
        label: 'Send',
        onTap: enabled ? onTap : null,
        enabled: enabled,
        child: Container(
          width: 96,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.cta,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: AppIcon(name: 'send', size: 24, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.label,
    required this.svg,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String svg;
  final Color color;
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
          child: SvgPicture.string(
            svg,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Safety flow (real routes so system back closes one layer at a time)
// ---------------------------------------------------------------------------
const List<String> _reasons = <String>[
  'Spam or scam',
  'Inappropriate content',
  'Harassment or bullying',
  'Looks underage',
  'Something else',
];

class _SafetyFlow {
  const _SafetyFlow({
    required this.user,
    required this.onClose,
    required this.onBlocked,
    required this.withDetails,
  });

  final AppUser user;
  final VoidCallback onClose;
  final VoidCallback onBlocked;
  final bool withDetails;

  void open(BuildContext context) => _openMenu(context);

  Future<void> _openMenu(BuildContext context) {
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _MenuRow(
              icon: 'shield',
              label: 'Report',
              sub: "Tell us what's wrong. It stays private.",
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openReport(context);
              },
            ),
            _MenuRow(
              icon: 'block',
              label: 'Block',
              danger: true,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openBlockDialog(context);
              },
            ),
            if (withDetails)
              const _MenuRow(
                icon: 'doc',
                label: 'Conversation details',
                sub: 'Staged · coming later',
                disabled: true,
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: AppTap(
                onTap: () => Navigator.of(sheetContext).pop(),
                child: const Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openReport(BuildContext context) {
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Report ${user.name}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose what fits best. They won't be told who reported them.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 8),
            for (final String reason in _reasons)
              InkWell(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openAck(context);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const AppIcon(
                        name: 'chev',
                        size: 18,
                        color: AppColors.lvGray,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openAck(BuildContext context) {
    return showAppSheet<void>(
      context,
      action: true,
      builder: (sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.onlineGreen.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.string(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="none" stroke="#3CC76A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.5l3.2 3L13 4.5"/></svg>',
                    width: 24,
                    height: 24,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Thanks. Your report was recorded in this local preview.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: AppTap(
                onTap: () => Navigator.of(sheetContext).pop(),
                child: const Center(
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openBlockDialog(BuildContext context) {
    return showAppDialog<void>(
      context,
      builder: (dialogContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Block ${user.name}?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "They will be hidden from Explore and your messages. This can't be undone in the local preview.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: AppTap(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onClose();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cancel',
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: AppTap(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AppContextState>().block(user.id);
                        onClose();
                        onBlocked();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.badge,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Text(
                          'Block',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.sub,
    this.danger = false,
    this.disabled = false,
    this.onTap,
  });

  final String icon;
  final String label;
  final String? sub;
  final bool danger;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? .5 : 1,
      child: AppTap(
        onTap: onTap,
        enabled: !disabled && onTap != null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              AppIcon(
                name: icon,
                size: 22,
                color: danger ? AppColors.badge : AppColors.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.badge : AppColors.ink,
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub!,
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
            ],
          ),
        ),
      ),
    );
  }
}
