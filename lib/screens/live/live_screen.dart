import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/token_pill.dart';
import 'sky_lantern.dart';

enum LiveState { initial, gift, free, searching }

class LiveScreen extends StatefulWidget {
  const LiveScreen({
    super.key,
    this.initial = LiveState.gift,
    this.portraits = SkyLantern.defaultPortraits,
  });

  final LiveState initial;
  final List<String> portraits;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late LiveState _state = widget.initial;
  late LiveState _prev = widget.initial;

  double get _navHeight => 56 + MediaQuery.paddingOf(context).bottom;

  void _start() {
    if (_state == LiveState.searching) return;
    setState(() {
      _prev = _state;
      _state = LiveState.searching;
    });
  }

  void _cancel() {
    setState(() => _state = _prev);
  }

  // Badge labels are data from the API (the prototype seeds these).
  List<String> get _giftLabels => switch (_state) {
    LiveState.free => const <String>['7', '60% OFF'],
    LiveState.gift => const <String>['60% OFF'],
    _ => const <String>[],
  };

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final bool searching = _state == LiveState.searching;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        SkyLantern(onRelease: _start, portraits: widget.portraits),
        _topBar(navigation),
        if (!searching && _giftLabels.isNotEmpty)
          Positioned(
            right: 16,
            bottom: _navHeight + 96,
            child: Column(
              children: <Widget>[
                for (final String label in _giftLabels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GiftBox(label: label),
                  ),
              ],
            ),
          ),
        if (!searching)
          Positioned(
            left: 32,
            right: 32,
            bottom: _navHeight + 20,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                  child: Text(
                    _state == LiveState.free ? 'Free' : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (searching)
          Positioned(
            left: 0,
            right: 0,
            bottom: _navHeight + 44,
            child: FadeIn(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Finding someone for you',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          child: PulseDot(
                            delay: Duration(milliseconds: 200 * i),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _cancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _topBar(NavigationState navigation) {
    final double top = MediaQuery.paddingOf(context).top;
    return Positioned(
      left: 16,
      right: 16,
      top: top + 8,
      child: Row(
        children: <Widget>[
          TokenPill(
            variant: TokenPillVariant.dark,
            onPlus: () => navigation.push('tokens'),
            count: navigation.coins,
          ),
          const Spacer(),
          _roundButton(
            label: 'Daily check-in',
            icon: 'calendar',
            onTap: () => navigation.push('bonus'),
            badgeDot: true,
          ),
          const SizedBox(width: 12),
          _roundButton(
            label: 'History',
            icon: 'history',
            onTap: () => navigation.push('history-list'),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
    bool badgeDot = false,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AppTap(
            label: label,
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white60,
                border: Border.all(color: AppColors.white, width: 1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Center(
                    child: AppIcon(name: icon, size: 24, color: AppColors.ink),
                  ),
                  if (badgeDot)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.badge,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GiftBox extends StatelessWidget {
  const GiftBox({super.key, required this.label});

  final String label;

  bool get _sale => label.contains('%');

  @override
  Widget build(BuildContext context) {
    final Widget badge = _sale
        ? Container(
            width: 36,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: CssLinearGradient(
                degrees: 135,
                colors: <Color>[AppColors.vipA, AppColors.vipB],
              ),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8,
                height: 9 / 8,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          )
        : Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: CssLinearGradient(
                degrees: 135,
                colors: <Color>[AppColors.vipA, AppColors.vipB],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                height: 12 / 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          );
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x403B3354),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 0,
                  height: 32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Positioned(
                  left: 2,
                  right: 2,
                  top: 12,
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 32,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 32,
                      color: AppColors.coin,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: _sale ? -2 : 0,
            right: _sale ? -8 : -4,
            child: Transform.rotate(
              angle: _sale ? -8 * 3.141592653589793 / 180 : 0,
              child: badge,
            ),
          ),
        ],
      ),
    );
  }
}
