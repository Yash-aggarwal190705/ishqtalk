import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/coin.dart';
import '../../state/onboarding_state.dart';
import 'notif_dialog.dart';
import 'payment_sheet.dart';

class WelcomeOfferTestOverrides {
  const WelcomeOfferTestOverrides({
    this.suppressNotificationPrompt = false,
    this.tooltipVisible,
    this.disableTimers = false,
  });

  final bool suppressNotificationPrompt;
  final bool? tooltipVisible;
  final bool disableTimers;
}

class WelcomeOffer extends StatefulWidget {
  const WelcomeOffer({
    super.key,
    this.forceNotif = false,
    this.forcePay = false,
    this.instant = false,
    this.testOverrides,
    this.onFinished,
  });

  final bool forceNotif;
  final bool forcePay;
  final bool instant;
  final WelcomeOfferTestOverrides? testOverrides;
  final VoidCallback? onFinished;

  @override
  State<WelcomeOffer> createState() => _WelcomeOfferState();
}

class _WelcomeOfferState extends State<WelcomeOffer> {
  static const List<_BlobSpec> _blobs = <_BlobSpec>[
    _BlobSpec(size: 180, left: -0.12, top: 0.06, delaySeconds: 0),
    _BlobSpec(size: 130, left: 0.70, top: 0.18, delaySeconds: -2),
    _BlobSpec(size: 200, left: 0.58, top: 0.62, delaySeconds: -4),
    _BlobSpec(size: 120, left: -0.06, top: 0.70, delaySeconds: -6),
    _BlobSpec(size: 150, left: 0.30, top: 0.84, delaySeconds: -8),
  ];

  Timer? _notificationTimer;
  Timer? _tooltipShowTimer;
  Timer? _tooltipHideTimer;
  bool _notificationVisible = false;
  bool _paymentVisible = false;
  bool _tooltipVisible = false;

  WelcomeOfferTestOverrides get _overrides =>
      widget.testOverrides ?? const WelcomeOfferTestOverrides();

  @override
  void initState() {
    super.initState();
    _notificationVisible =
        widget.forceNotif && !_overrides.suppressNotificationPrompt;
    _paymentVisible = widget.forcePay;
    if (_overrides.tooltipVisible != null) {
      _tooltipVisible = _overrides.tooltipVisible!;
    }
    if (_overrides.disableTimers) return;

    if (!widget.forceNotif &&
        !widget.forcePay &&
        !_overrides.suppressNotificationPrompt) {
      _notificationTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _notificationVisible = true);
      });
    }
    _tooltipShowTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _tooltipVisible = true);
    });
    _tooltipHideTimer = Timer(const Duration(milliseconds: 4000), () {
      if (mounted) setState(() => _tooltipVisible = false);
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _tooltipShowTimer?.cancel();
    _tooltipHideTimer?.cancel();
    super.dispose();
  }

  void _finish() {
    context.read<OnboardingState>().setOnboarded();
    widget.onFinished?.call();
    if (widget.onFinished == null) context.read<NavigationState>().tab('live');
  }

  void _chooseNotification(String choice) {
    setState(() {
      _notificationVisible = false;
    });
    context.read<OnboardingState>().setNotifChoice(choice);
  }

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.bgWelcome),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              for (final _BlobSpec blob in _blobs)
                _DriftingBlob(spec: blob, viewport: constraints.biggest),
              Positioned.fill(
                child: _NoScrollbar(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: safeTop,
                      bottom: 24 + safeBottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 56,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerRight,
                                child: AppTap(
                                  onTap: _finish,
                                  child: const SizedBox(
                                    height: 48,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Center(
                                        widthFactor: 1,
                                        child: Text(
                                          'Skip',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            height: 20 / 14,
                                            color: AppColors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 46,
                                right: 8,
                                child: IgnorePointer(
                                  ignoring: !_tooltipVisible,
                                  child: AnimatedOpacity(
                                    opacity: _tooltipVisible ? 1 : 0,
                                    duration: animationsDisabled(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 300),
                                    curve: tailwindTransition,
                                    child: const _TooltipBubble(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.08),
                        const _Headline(),
                        const SizedBox(height: 16),
                        const _WelcomeRibbon(),
                        const SizedBox(height: 24),
                        _OfferCard(
                          onContinue: () =>
                              setState(() => _paymentVisible = true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_notificationVisible)
                NotifDialog(
                  instant: widget.instant,
                  safeBottom: safeBottom,
                  onChoose: _chooseNotification,
                ),
              if (_paymentVisible)
                PaymentSheet(
                  instant: widget.instant,
                  safeBottom: safeBottom,
                  onClose: () => setState(() => _paymentVisible = false),
                  onSuccess: _finish,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlobSpec {
  const _BlobSpec({
    required this.size,
    required this.left,
    required this.top,
    required this.delaySeconds,
  });

  final double size;
  final double left;
  final double top;
  final int delaySeconds;
}

class _DriftingBlob extends StatelessWidget {
  const _DriftingBlob({required this.spec, required this.viewport});

  final _BlobSpec spec;
  final Size viewport;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: viewport.width * spec.left,
      top: viewport.height * spec.top,
      child: LoopMotion(
        duration: const Duration(seconds: 9),
        delay: Duration(seconds: spec.delaySeconds),
        builder: (context, phase, idle, child) => Transform.translate(
          offset: idle
              ? Offset.zero
              : Offset(14, -22) * pulseSequence.transform(phase),
          child: child,
        ),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            width: spec.size,
            height: spec.size,
            decoration: BoxDecoration(
              color: AppColors.coin.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoScrollbar extends StatelessWidget {
  const _NoScrollbar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ScrollConfiguration(behavior: const _NoScrollbarBehavior(), child: child);
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: -4,
          right: 20,
          child: Transform.rotate(
            angle: 0.7853981633974483,
            child: Container(width: 10, height: 10, color: AppColors.badge),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColors.badge,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Text(
            "Explore What's New!",
            softWrap: false,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 1.5,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final TextStyle stroke = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 44,
      height: 1,
      fontWeight: FontWeight.w800,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.vipB,
      shadows: <Shadow>[
        Shadow(
          color: AppColors.ink30,
          offset: const Offset(0, 3),
          blurRadius: 0,
        ),
      ],
    );
    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ExcludeSemantics(child: Text('DOUBLE', style: stroke)),
            const Text(
              'DOUBLE',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 44,
                height: 1,
                fontWeight: FontWeight.w800,
                color: AppColors.coin,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'COINS NOW',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  const _RibbonClipper({required this.left});

  final bool left;

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);
    if (left) {
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..lineTo(size.width * 0.25, size.height * 0.5);
    } else {
      path
        ..lineTo(size.width * 0.75, size.height * 0.5)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant _RibbonClipper oldClipper) =>
      oldClipper.left != left;
}

class _WelcomeRibbon extends StatelessWidget {
  const _WelcomeRibbon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: -24,
          top: 8,
          child: ClipPath(
            clipper: const _RibbonClipper(left: true),
            child: const ColoredBox(
              color: AppColors.ctaDark,
              child: SizedBox(width: 40, height: 32),
            ),
          ),
        ),
        Positioned(
          right: -24,
          top: 8,
          child: ClipPath(
            clipper: const _RibbonClipper(left: false),
            child: const ColoredBox(
              color: AppColors.ctaDark,
              child: SizedBox(width: 40, height: 32),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cta,
            borderRadius: BorderRadius.circular(6),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.cta.withValues(alpha: 0.35),
                offset: const Offset(0, 6),
                blurRadius: 14,
              ),
            ],
          ),
          child: const Text(
            'Welcome Bonus!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: const ColoredBox(color: AppColors.white20),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white30, width: 1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              const Text(
                'Purchase Now & Get:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Coin(size: 30),
                          SizedBox(width: 6),
                          Text(
                            '200',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Coins',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '+',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: SvgPicture.string(
                          appGiftSvg(AppColors.white),
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'x5 gifts',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PressScale(
                onTap: onContinue,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppGradients.bgCtaPill,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.badge.withValues(alpha: 0.35),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Continue for ₹119.99',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹239.98',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white70,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
