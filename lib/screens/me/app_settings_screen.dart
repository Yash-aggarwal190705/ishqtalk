import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/settings_repository.dart';
import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import '../../shared/v2.dart';
import '../../state/app_context.dart';
import '../../state/onboarding_state.dart';

const String _checkSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>';

const List<(String, String)> _deleteItems = <(String, String)>[
  ('user', 'Your profile is removed'),
  ('chat', 'Your messages are removed'),
  ('dollar', 'Your tokens are removed'),
  ('shield', "This can't be undone"),
];

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key, this.initialSheet});

  /// Test-only: 'logout' | 'delete' opens that sheet after first frame.
  final String? initialSheet;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const SettingsRepository _settings = SettingsRepository();
  bool _safe = true;
  bool _dnd = false;
  String _cache = '86 MB';
  String _update = 'Up to date';
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (widget.initialSheet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.initialSheet == 'logout') {
          _openLogoutSheet();
        } else if (widget.initialSheet == 'delete') {
          _openDeleteSheet();
        }
      });
    }
  }

  Future<void> _loadSettings() async {
    final bool safe = await _settings.safeMode;
    final bool dnd = await _settings.doNotDisturb;
    if (!mounted) return;
    setState(() {
      _safe = safe;
      _dnd = dnd;
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    AppSnack.hide();
    super.dispose();
  }

  void _snack(String message) {
    AppSnack.show(
      context,
      message,
      bottom: 24 + MediaQuery.paddingOf(context).bottom,
    );
  }

  void _later() => _snack('Coming soon');

  void _clearCache() {
    if (_cache == '0 MB') return;
    setState(() => _cache = '0 MB');
    _snack('Cache cleared');
  }

  void _checkUpdate() {
    if (_update == 'Checking…') return;
    setState(() => _update = 'Checking…');
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _update = 'Up to date');
    });
  }

  void _logOut() {
    context.read<OnboardingState>().reset();
    // TODO: sign out from the real auth provider.
    context.read<NavigationState>().jump('login');
  }

  Future<void> _deleteAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.read<OnboardingState>().reset();
    context.read<AppContextState>().clearLocal();
    context.read<NavigationState>().jump('splash');
  }

  void _openLogoutSheet() {
    showAppSheet<void>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Log out of YourApp?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You can log back in any time.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            'Log out',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _logOut();
            },
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: AppTap(
              onTap: () => Navigator.of(sheetContext).pop(),
              child: const Center(
                child: Text(
                  'Stay logged in',
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

  void _openDeleteSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.scrim50,
      builder: (sheetContext) => _DeleteSheet(
        onClose: () => Navigator.of(sheetContext).pop(),
        onDelete: () {
          Navigator.of(sheetContext).pop();
          _deleteAccount();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: <Widget>[
              Header(title: 'App settings', onBack: navigation.back),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _Group(
                        title: 'General',
                        cardKey: 'group-general',
                        children: <Widget>[
                          _SettingsRow(
                            key: const ValueKey('row-App language'),
                            label: 'App language',
                            value: 'English',
                            onTap: _later,
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-Privacy policy'),
                            label: 'Privacy policy',
                            onTap: _later,
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-Terms of service'),
                            label: 'Terms of service',
                            onTap: _later,
                          ),
                        ],
                      ),
                      _Group(
                        title: 'Safety',
                        cardKey: 'group-safety',
                        children: <Widget>[
                          _SettingsRow(
                            key: const ValueKey('row-Blocked accounts'),
                            label: 'Blocked accounts',
                            onTap: _later,
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-My reports'),
                            label: 'My reports',
                            caption: 'Reports you sent and their status',
                            onTap: _later,
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-Safe mode'),
                            label: 'Safe mode',
                            caption: 'Hide sensitive content in discovery',
                            trailing: AppSwitch(
                              on: _safe,
                              onChanged: (bool value) {
                                setState(() => _safe = value);
                                _settings.setSafeMode(value);
                              },
                              label: 'Safe mode',
                            ),
                          ),
                        ],
                      ),
                      _Group(
                        title: 'Comfort',
                        cardKey: 'group-comfort',
                        children: <Widget>[
                          _SettingsRow(
                            key: const ValueKey('row-Do not disturb'),
                            label: 'Do not disturb',
                            caption: 'Pause call requests and notifications',
                            trailing: AppSwitch(
                              on: _dnd,
                              onChanged: (bool value) {
                                setState(() => _dnd = value);
                                _settings.setDoNotDisturb(value);
                              },
                              label: 'Do not disturb',
                            ),
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-Camera beauty'),
                            label: 'Camera beauty',
                            onTap: _later,
                          ),
                        ],
                      ),
                      _Group(
                        title: 'Device',
                        cardKey: 'group-device',
                        children: <Widget>[
                          _SettingsRow(
                            key: const ValueKey('row-Clear cache'),
                            label: 'Clear cache',
                            plain: true,
                            value: _cache,
                            onTap: _clearCache,
                          ),
                          _SettingsRow(
                            key: const ValueKey('row-Check for updates'),
                            label: 'Check for updates',
                            plain: true,
                            value: _update,
                            onTap: _checkUpdate,
                          ),
                        ],
                      ),
                      _Group(
                        title: 'Account',
                        cardKey: 'group-account',
                        children: <Widget>[
                          _SettingsRow(
                            key: const ValueKey('row-Delete account'),
                            label: 'Delete account',
                            danger: true,
                            onTap: _openDeleteSheet,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: AppTap(
                          key: const ValueKey('logout-button'),
                          label: 'Log out',
                          onTap: _openLogoutSheet,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: const Center(
                              child: Text(
                                'Log out',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'YourApp v0.1 demo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                    ],
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

class _DeleteSheet extends StatefulWidget {
  const _DeleteSheet({required this.onClose, required this.onDelete});

  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  State<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends State<_DeleteSheet> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double bottom = mq.viewPadding.bottom;
    return Container(
      key: const ValueKey('delete-sheet-panel'),
      height: mq.size.height - 40, // top edge 40 below the top
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Delete your account?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here is what happens when you delete:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      color: AppColors.sub,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final (String icon, String text) in _deleteItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.tintInvite,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AppIcon(
                                name: icon,
                                size: 20,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 24 / 16,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  AppTap(
                    label: 'I understand',
                    onTap: () => setState(() => _ack = !_ack),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _ack
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: _ack
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFF767676),
                                      width: 2,
                                    ),
                            ),
                            child: _ack
                                ? Center(
                                    child: SvgPicture.string(
                                      _checkSvg,
                                      width: 14,
                                      height: 14,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                      excludeFromSemantics: true,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'I understand',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 24 / 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          NeoButton(
            'Delete account',
            danger: true,
            onPressed: _ack ? widget.onDelete : null,
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: AppTap(
              onTap: widget.onClose,
              child: const Center(
                child: Text(
                  'Keep my account',
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
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.cardKey,
    required this.children,
  });

  final String title;
  final String cardKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: AppColors.sub,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            key: ValueKey<String>(cardKey),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x148B5CF6),
                  offset: Offset(0, 4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DecoratedBox(
                // DecoratedBox draws the border without insetting the rows
                // (Container would add border-derived padding).
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < children.length; i++) ...<Widget>[
                      if (i > 0) Container(height: 1, color: AppColors.divider),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    super.key,
    required this.label,
    this.caption,
    this.value,
    this.danger = false,
    this.plain = false,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? caption;
  final String? value;
  final bool danger;
  final bool plain;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool tappable = onTap != null && trailing == null;
    final Widget content = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: danger ? AppColors.danger : AppColors.ink,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
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
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              value!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.sub,
              ),
            ),
          ),
        if (trailing != null)
          Padding(padding: const EdgeInsets.only(left: 12), child: trailing),
        if (trailing == null && onTap != null && !plain)
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: AppIcon(name: 'chev', size: 18, color: AppColors.ink2),
          ),
      ],
    );
    final Widget box = Container(
      height: caption == null ? 56 : null,
      padding: caption == null
          ? const EdgeInsets.symmetric(horizontal: 20)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      constraints: caption == null ? null : const BoxConstraints(minHeight: 72),
      child: content,
    );
    return tappable ? AppTap(onTap: onTap, child: box) : box;
  }
}
