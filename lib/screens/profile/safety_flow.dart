import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../shared/dialog.dart';
import '../../shared/sheet.dart';
import '../../state/models.dart';

const List<String> reportReasons = <String>[
  'Spam or scam',
  'Inappropriate content',
  'Harassment or bullying',
  'Looks underage',
  'Something else',
];

class SafetyFlow extends StatefulWidget {
  const SafetyFlow({
    super.key,
    required this.user,
    required this.onClose,
    this.onBlock,
    this.onBlocked,
    this.withDetails = false,
  });

  final AppUser user;
  final VoidCallback onClose;
  final VoidCallback? onBlock;
  final VoidCallback? onBlocked;
  final bool withDetails;

  @override
  State<SafetyFlow> createState() => _SafetyFlowState();
}

enum _SafetyStep { menu, report, ack, block }

class _SafetyFlowState extends State<SafetyFlow> {
  _SafetyStep _step = _SafetyStep.menu;

  void _block() {
    widget.onBlock?.call();
    widget.onClose();
    widget.onBlocked?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _SafetyStep.block) {
      return AppDialog(
        title: 'Block ${widget.user.name}?',
        body: "They will be hidden from Explore and your messages. This can't be undone in the local preview.",
        close: widget.onClose,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 44,
              child: AppTap(
                onTap: widget.onClose,
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
          Expanded(
            child: SizedBox(
              height: 44,
              child: AppTap(
                onTap: _block,
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
      );
    }

    return Sheet(
      close: widget.onClose,
      child: switch (_step) {
        _SafetyStep.menu => _menu(),
        _SafetyStep.report => _report(),
        _SafetyStep.ack => _ack(),
        _SafetyStep.block => const SizedBox.shrink(),
      },
    );
  }

  Widget _menu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Row(
          icon: const AppIcon(name: 'shield', size: 22),
          label: 'Report',
          sub: "Tell us what's wrong. It stays private.",
          onTap: () => setState(() => _step = _SafetyStep.report),
        ),
        _Row(
          icon: const _BlockIcon(),
          label: 'Block',
          danger: true,
          onTap: () => setState(() => _step = _SafetyStep.block),
        ),
        if (widget.withDetails)
          const _Row(
            icon: AppIcon(name: 'doc', size: 22),
            label: 'Conversation details',
            sub: 'Staged · coming later',
            disabled: true,
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: AppTap(
            onTap: widget.onClose,
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
  }

  Widget _report() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Report ${widget.user.name}',
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
        for (final String reason in reportReasons)
          InkWell(
            onTap: () {
              // TODO: submit to the real reporting API.
              setState(() => _step = _SafetyStep.ack);
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
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
  }

  Widget _ack() {
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
                _checkSvg,
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
            onTap: widget.onClose,
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
  }

  static final String _checkSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="none" stroke="'
      '${appColorHex(AppColors.onlineGreen)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.500l3.200 3L13 4.500"/></svg>';
}

class _BlockIcon extends StatelessWidget {
  const _BlockIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: 22,
      height: 22,
      excludeFromSemantics: true,
    );
  }

  static final String _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="'
      '${appColorHex(AppColors.badge)}" stroke-width="1.75" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M5.600 5.600l12.800 12.800"/></svg>';
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.sub,
    this.danger = false,
    this.disabled = false,
    this.onTap,
  });

  final Widget icon;
  final String label;
  final String? sub;
  final bool danger;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      enabled: !disabled && onTap != null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            IconTheme(
              data: IconThemeData(
                color: danger ? AppColors.badge : AppColors.ink,
              ),
              child: icon,
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
                  if (sub != null) ...<Widget>[
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
