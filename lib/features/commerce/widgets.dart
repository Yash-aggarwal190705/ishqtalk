import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../shared/coin.dart';
import '../commerce/domain.dart';

// ---------------------------------------------------------------------------
// Ticket icon (viewBox 28x18, from screens2.tsx).
// ---------------------------------------------------------------------------
class TicketIcon extends StatelessWidget {
  const TicketIcon({super.key, required this.kind, this.width = 28});

  final TicketKind kind;
  final double width;

  @override
  Widget build(BuildContext context) {
    final String color = kind == TicketKind.chat ? '#FFB4A8' : '#8B5CF6';
    final String body = kind == TicketKind.chat
        ? '<path d="M9 4.5h10a1.5 1.5 0 011.5 1.5v4a1.5 1.5 0 01-1.5 1.5h-5l-3 2.2v-2.2H9A1.5 1.5 0 017.5 10V6A1.5 1.5 0 019 4.5z" fill="#fff"/><circle cx="11" cy="8" r=".9" fill="$color"/><circle cx="14" cy="8" r=".9" fill="$color"/><circle cx="17" cy="8" r=".9" fill="$color"/>'
        : '<path d="M14 13.5s-4.5-2.7-4.5-6A2.4 2.4 0 0114 6.2 2.4 2.4 0 0118.5 7.5c0 3.3-4.5 6-4.5 6z" fill="#fff"/>';
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 18">'
      '<path d="M3 0h22a3 3 0 003 3v1.5a3 3 0 000 6V15a3 3 0 00-3 3H3a3 3 0 00-3-3v-1.5a3 3 0 000-6V3a3 3 0 003-3z" fill="$color" transform="scale(1 .98)"/>'
      '$body</svg>',
      width: width,
      height: width * 18 / 28,
      excludeFromSemantics: true,
    );
  }
}

// ---------------------------------------------------------------------------
// LoadingSpinner: 48x48 white tile, 8 purple dots on a circle, rotating.
// ---------------------------------------------------------------------------
class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    final String dots =
        '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">'
        '${List<Object>.generate(8, (i) {
          const double r = 8;
          final double a = i * math.pi / 4;
          final double cx = 10 + r * math.sin(a);
          final double cy = 10 - r * math.cos(a);
          return '<circle cx="$cx" cy="$cy" r="1.6" fill="#8B5CF6" opacity="${0.25 + i * 0.1}"/>';
        }).join()}'
        '</svg>';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x263B3354),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Center(
        child: Spin(
          duration: const Duration(milliseconds: 800),
          child: SvgPicture.string(dots, excludeFromSemantics: true),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Countdown: HH:MM:SS, tabular figures, ticks down every second.
// ---------------------------------------------------------------------------
class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.seconds});

  final int seconds;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late int _left = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left > 0) setState(() => _left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static String fmt(int s) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(s ~/ 3600)}:${p((s % 3600) ~/ 60)}:${p(s % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const AppIcon(name: 'history', size: 14, color: AppColors.ink2),
        const SizedBox(width: 4),
        Text(
          fmt(_left),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.ink2,
            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Toast: centered pill, auto-hides after 1.8s.
// ---------------------------------------------------------------------------
class Toast extends StatefulWidget {
  const Toast({super.key, required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<Toast> createState() => _ToastState();
}

class _ToastState extends State<Toast> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom + 96;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: FadeIn(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x2E3B3354),
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reward cell (sign-in grid). Index 6 spans two columns.
// ---------------------------------------------------------------------------
class RewardCell extends StatelessWidget {
  const RewardCell({
    super.key,
    required this.index,
    required this.claimed,
    required this.active,
    required this.width,
  });

  final int index;
  final bool claimed;
  final bool active;
  final double width; // full cell width (or spanning two cells)

  @override
  Widget build(BuildContext context) {
    final bool big = index == 6;
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Opacity(
          opacity: claimed ? .6 : 1,
          child: TicketIcon(kind: TicketKind.match, width: 28),
        ),
        const SizedBox(height: 4),
        Text(
          big ? '+2' : '+1',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: big ? 18 : 14,
            height: big ? 24 / 18 : 20 / 14,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.white : AppColors.ink,
          ),
        ),
      ],
    );
    return Container(
      width: width,
      height: 80,
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF8B5CF6), Color(0xFF7C4AE8)],
              )
            : null,
        color: active ? null : const Color(0xFFEFE6FF),
        borderRadius: BorderRadius.circular(8),
        border: active ? Border.all(color: AppColors.coin, width: 2) : null,
        boxShadow: active
            ? const <BoxShadow>[
                BoxShadow(color: Color(0xB3FFC857), blurRadius: 6),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(child: content),
          if (claimed)
            Center(
              child: SvgPicture.string(
                '<svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 16 16" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.5l3.2 3L13 4.5"/></svg>',
                excludeFromSemantics: true,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task row.
// ---------------------------------------------------------------------------
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.last,
    required this.onGo,
  });

  final RewardTask task;
  final bool last;
  final VoidCallback onGo;

  Widget _rewardIcon(RewardKind kind, double size) {
    return switch (kind) {
      RewardKind.coin => Coin(size: size),
      RewardKind.chatTicket => TicketIcon(kind: TicketKind.chat, width: size),
      RewardKind.matchTicket => TicketIcon(kind: TicketKind.match, width: size),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      _rewardIcon(
                        task.reward,
                        task.reward == RewardKind.coin ? 16 : 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${task.amount}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 86,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (task.done)
                  Container(
                    width: 86,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Center(
                      child: SvgPicture.string(
                        '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.5l3.2 3L13 4.5"/></svg>',
                        excludeFromSemantics: true,
                      ),
                    ),
                  )
                else
                  AppTap(
                    onTap: onGo,
                    child: Container(
                      width: 86,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Go',
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
                const SizedBox(height: 2),
                Text(
                  '( ${task.progress} )',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    height: 14 / 11,
                    color: AppColors.ink3,
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
