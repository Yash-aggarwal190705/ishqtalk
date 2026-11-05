import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import 'account_chooser.dart';
import 'contact_sheet.dart';
import 'floating_emojis.dart';
import 'legal_dialog.dart';
import 'login_busy_bar.dart';
import 'login_coins.dart';
import 'login_logo.dart';
import 'login_provider_icons.dart';
import 'login_toast.dart';
import 'provider_button.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
    this.expanded = false,
    this.modal,
    this.instant = false,
  }) : assert(
         modal == null ||
             modal == 'google' ||
             modal == 'email' ||
             modal == 'email-otp' ||
             modal == 'phone' ||
             modal == 'terms' ||
             modal == 'privacy',
       );
  final bool expanded;

  /// React screen-registry values, preserved verbatim (including `email-otp`).
  final String? modal;
  final bool instant;

  @override
  State<Login> createState() => _LoginState();
}

// Retains the LoginView name used by integration briefs as well as React's Login.
typedef LoginView = Login;

class _LoginState extends State<Login> {
  late bool _expanded;
  late String? _modal;
  bool _busy = false;
  bool _toast = false;
  final List<Timer> _timers = [];
  late final TapGestureRecognizer _terms;
  late final TapGestureRecognizer _privacy;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded;
    _modal = widget.modal;
    _terms = TapGestureRecognizer()
      ..onTap = () => setState(() => _modal = 'terms');
    _privacy = TapGestureRecognizer()
      ..onTap = () => setState(() => _modal = 'privacy');
  }

  void _later(int ms, VoidCallback callback) {
    _timers.add(Timer(Duration(milliseconds: ms), callback));
  }

  void _start(LoginProvider provider) {
    if (_busy) return;
    setState(() => _busy = true);
    if (provider == LoginProvider.x || provider == LoginProvider.telegram) {
      _later(1200, () {
        setState(() => _busy = false);
        context.read<NavigationState>().goto('welcome-offer');
      });
    } else {
      _later(
        400,
        () => setState(() {
          _busy = false;
          _modal = provider.name;
        }),
      );
    }
  }

  void _closeModal() {
    FocusScope.of(context).unfocus();
    setState(() => _modal = null);
  }

  void _success() {
    _closeModal();
    setState(() => _busy = true);
    _later(1000, () {
      setState(() => _busy = false);
      context.read<NavigationState>().goto('welcome-offer');
    });
  }

  void _demoToast() {
    setState(() => _toast = true);
    _later(1800, () => setState(() => _toast = false));
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  Widget _provider(LoginProvider provider) => ProviderButton(
    provider: provider,
    disabled: _busy || (provider == LoginProvider.phone && !_expanded),
    onTap: () => _start(provider),
  );

  Widget _providers() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _provider(LoginProvider.google),
      const SizedBox(height: 12),
      _provider(LoginProvider.email),
      const SizedBox(height: 12),
      AnimatedContainer(
        key: const ValueKey('extra-providers'),
        duration: animationsDisabled(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: _expanded ? 116 : 0,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: OverflowBox(
          minHeight: 116,
          maxHeight: 116,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              if (_expanded) ...[
                Rise(
                  instant: widget.instant,
                  child: _provider(LoginProvider.x),
                ),
                const SizedBox(height: 12),
                Rise(
                  instant: widget.instant,
                  delay: const Duration(milliseconds: 60),
                  child: _provider(LoginProvider.telegram),
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (!_expanded)
        SizedBox(
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 48,
                child: Center(
                  child: AppTap(
                    onTap: () => setState(() => _expanded = true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'More',
                              style: TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                color: AppColors.ink2,
                              ),
                            ),
                            SizedBox(width: 4),
                            RotatedBox(
                              quarterTurns: 1,
                              child: AppIcon(
                                name: 'chev',
                                size: 14,
                                color: AppColors.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (_expanded)
        Rise(
          key: const ValueKey('phone-rise'),
          instant: widget.instant,
          delay: const Duration(milliseconds: 120),
          child: _provider(LoginProvider.phone),
        )
      else
        ExcludeSemantics(
          child: IgnorePointer(
            child: Opacity(
              opacity: .35,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.black, AppColors.transparent],
                ).createShader(rect),
                child: _provider(LoginProvider.phone),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _footer(double bottom) => Padding(
    padding: EdgeInsets.only(top: 24, bottom: 16 + bottom),
    child: Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: "By logging in, you confirm you're over 18 years old and agree to our ",
          ),
          TextSpan(
            text: 'Terms of Use',
            recognizer: _terms,
            style: const TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            recognizer: _privacy,
            style: const TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11, height: 1.5, color: AppColors.ink2),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final EdgeInsets safe = MediaQuery.paddingOf(context);
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.bgSplash),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                excluding: _modal != null,
                child: ExcludeFocus(
                  excluding: _modal != null,
                  child: IgnorePointer(
                    ignoring: _modal != null,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(24, safe.top, 24, 0),
                            sliver: SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: math.max(
                                      48,
                                      bounds.maxHeight * .12,
                                    ),
                                  ),
                                  Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: const [
                                        LoginLogo(),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: FloatingEmojis(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'YourApp',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      height: 1.5,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Register to Get\nFree Coins!',
                                          style: TextStyle(
                                            fontSize: 22,
                                            height: 1.25,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      LoginCoins(),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _providers(),
                                  const Spacer(),
                                  _footer(safe.bottom),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_modal == 'google')
                AccountChooser(
                  pick: _success,
                  addOther: _demoToast,
                  close: _closeModal,
                  instant: widget.instant,
                ),
              if (_modal == 'email' ||
                  _modal == 'email-otp' ||
                  _modal == 'phone')
                ContactSheet(
                  kind: _modal == 'phone'
                      ? ContactKind.phone
                      : ContactKind.email,
                  startAtOtp: _modal == 'email-otp',
                  done: _success,
                  close: _closeModal,
                  instant: widget.instant,
                ),
              if (_modal == 'terms' || _modal == 'privacy')
                LegalDialog(
                  privacy: _modal == 'privacy',
                  close: _closeModal,
                  instant: widget.instant,
                ),
              if (_busy) const LoginBusyBar(),
              if (_toast) LoginToast(instant: widget.instant),
            ],
          ),
        ),
      );
    },
  );
}
