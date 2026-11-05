import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';
import '../navigation/nav.dart';
import '../state/models.dart';

/// Cost per minute, in tokens. Replace with config when a backend exists.
const int callTokensPerMinute = 35;

typedef PermissionRequester = Future<bool> Function();

Future<bool> _requestCallPermissions() async {
  final ph.PermissionStatus camera = await ph.Permission.camera.request();
  final ph.PermissionStatus mic = await ph.Permission.microphone.request();
  return camera.isGranted && mic.isGranted;
}

class CallSheet extends StatefulWidget {
  const CallSheet({
    super.key,
    required this.user,
    required this.close,
    this.requester,
  });

  final AppUser user;
  final VoidCallback close;
  final PermissionRequester? requester;

  @override
  State<CallSheet> createState() => _CallSheetState();
}

enum _CallStep { intro, denied, started }

class _CallSheetState extends State<CallSheet> {
  _CallStep _step = _CallStep.intro;
  bool _busy = false;

  Future<void> _continue() async {
    final NavigationState navigation = context.read<NavigationState>();
    if (navigation.coins < callTokensPerMinute) {
      navigation.push('tokens');
      widget.close();
      return;
    }
    final PermissionRequester requester =
        widget.requester ?? _requestCallPermissions;
    setState(() => _busy = true);
    final bool granted = await requester();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = granted ? _CallStep.started : _CallStep.denied;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        switch (_step) {
          _CallStep.intro => _intro(),
          _CallStep.denied => _denied(),
          _CallStep.started => _started(),
        },
      ],
    );
  }

  Widget _intro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Intro(
          title: 'Video call with ${widget.user.name}',
          subtitle: '$callTokensPerMinute tokens per minute',
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: AppIcon(name: 'cam', size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Camera and microphone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your phone will ask for permission before a call can start. You can say no and keep chatting by message.',
                      style: TextStyle(
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
        const SizedBox(height: 20),
        _PrimaryButton(label: 'Continue', onTap: _busy ? null : _continue),
        const SizedBox(height: 8),
        _SecondaryButton(label: 'Not now', onTap: widget.close),
      ],
    );
  }

  Widget _denied() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Intro(
          title: 'Camera or microphone blocked',
          subtitle: 'You can still chat by message.',
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Open app settings',
          onTap: () => ph.openAppSettings(),
        ),
        const SizedBox(height: 8),
        _SecondaryButton(label: 'Not now', onTap: widget.close),
      ],
    );
  }

  Widget _started() {
    // TODO: replace with the real call surface once calling is wired up.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Intro(
          title: 'Call started',
          subtitle: 'Live video is not connected yet.',
        ),
        if (kDebugMode)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.coinBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '[debug] Placeholder — no call is placed and no tokens are used.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        const SizedBox(height: 20),
        _PrimaryButton(label: 'Got it', onTap: widget.close),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
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
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.ink2,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      enabled: onTap != null,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: onTap == null ? .4 : 1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
