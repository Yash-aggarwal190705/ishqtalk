import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import 'domain.dart';
import 'widgets.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({
    super.key,
    this.repository = const WalletRepository(),
    this.tokensAdded,
    this.scrollToTable = false,
  });

  final WalletRepository repository;
  final int? tokensAdded; // test-only override
  final bool scrollToTable; // test-only

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final ScrollController _scroll = ScrollController();
  final ScrollController _tabs = ScrollController();
  late int _sel;

  @override
  void initState() {
    super.initState();
    _sel = levelOf(widget.tokensAdded ?? widget.repository.tokensAdded);
    if (widget.scrollToTable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Scroll so the rule card's top is ~8 below the scroll-area top.
        final double target = _estimateRuleTop();
        if (target > 0 && _scroll.hasClients) {
          _scroll.jumpTo(target.clamp(0, _scroll.position.maxScrollExtent));
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tabs.dispose();
    super.dispose();
  }

  /// Rough estimate: level card height + margins + tabs row.
  double _estimateRuleTop() {
    const double card = 112 + 8 + 24 + 16 + 12 + 8 + 12 + 20; // ~212
    return 4 + card + 12 + 48 + 8 + 72 + 16;
  }

  void _select(int i) {
    setState(() => _sel = i);
    // Centre the selected tab in the viewport.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tabs.hasClients) return;
      final double viewport = _tabs.position.viewportDimension;
      final double offset = (i * 64.0 - viewport / 2 + 28).clamp(
        0.0,
        _tabs.position.maxScrollExtent,
      );
      _tabs.animateTo(
        offset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final int tokensAdded = widget.tokensAdded ?? widget.repository.tokensAdded;
    final LevelInfo info = levelInfo(tokensAdded);

    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(title: 'Level', onBack: navigation.back),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _LevelCard(info: info, tokensAdded: tokensAdded),
                      _LevelTabs(
                        selected: _sel,
                        controller: _tabs,
                        onSelect: _select,
                      ),
                      _DailyBonusRow(selected: _sel),
                      _RuleTable(info: info),
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

// ---------------------------------------------------------------------------
// Level card
// ---------------------------------------------------------------------------
class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.info, required this.tokensAdded});

  final LevelInfo info;
  final int tokensAdded;

  static const LinearGradient _bg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.primary, Color(0xFF6348A5)],
    transform: _GradAngle(160),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _bg,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Soft blobs (gaussian sigma 40, under the content).
          const Positioned(
            top: -32,
            left: -32,
            child: _Blob(size: 128, color: Color(0x66FFB4A8)),
          ),
          const Positioned(
            top: 40,
            right: -40,
            child: _Blob(size: 144, color: Color(0x402ED3C6)),
          ),
          const Positioned(
            bottom: -40,
            left: 40,
            child: _Blob(size: 128, color: Color(0x4DC4B5FD)),
          ),
          Column(
            children: <Widget>[
              OrbitBadge(level: info.current),
              const SizedBox(height: 8),
              Text(
                'Lv ${info.current}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Lv ${info.current}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: Row(
                      children: <Widget>[
                        const TokenCoin(size: 18),
                        const SizedBox(width: 6),
                        Text(
                          fmtIN(tokensAdded),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            height: 18 / 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Lv ${info.next}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  color: AppColors.white.withValues(alpha: .25),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 358 * info.pct / 100,
                      height: 8,
                      color: AppColors.onlineCyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                info.isMax
                    ? "You've reached the top level"
                    : 'Add ${fmtIN(info.need)} tokens to reach Lv ${info.next}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradAngle extends GradientTransform {
  const _GradAngle(this.deg);

  final double deg;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double a = deg * 3.141592653589793 / 180;
    final double len =
        (bounds.width * math.sin(a)).abs() +
        (bounds.height * math.cos(a)).abs();
    final Offset c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.rotationZ(a + 3.141592653589793) *
        Matrix4.diagonal3Values(1, len / bounds.height, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs
// ---------------------------------------------------------------------------
class _LevelTabs extends StatelessWidget {
  const _LevelTabs({
    required this.selected,
    required this.controller,
    required this.onSelect,
  });

  final int selected;
  final ScrollController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 48,
      child: ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: <Widget>[
          for (int i = 0; i < thresholds.length; i++)
            InkWell(
              onTap: () => onSelect(i),
              child: Container(
                height: 48,
                constraints: const BoxConstraints(minWidth: 56),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Lv $i',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: i == selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == selected
                            ? AppColors.primary
                            : AppColors.sub,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == selected
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily bonus row
// ---------------------------------------------------------------------------
class _DailyBonusRow extends StatelessWidget {
  const _DailyBonusRow({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      constraints: const BoxConstraints(minHeight: 72),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.tintTokens,
              shape: BoxShape.circle,
            ),
            child: const Center(child: GiftSparkle()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Daily bonus',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '+${bonusPerLevel[selected]} tokens every day at Lv $selected',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Reach higher levels for a bigger bonus',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.sub,
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

// ---------------------------------------------------------------------------
// Rule table
// ---------------------------------------------------------------------------
class _RuleTable extends StatelessWidget {
  const _RuleTable({required this.info});

  final LevelInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x148B5CF6),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: <Widget>[
                const Text(
                  'Level rule',
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
                  "Your level follows the total tokens you've added.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.sub,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text(
                    'Level',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sub,
                    ),
                  ),
                  Text(
                    'Tokens added',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sub,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (int i = 0; i < thresholds.length; i++)
            Container(
              height: 56,
              color: i.isEven ? AppColors.primary10 : AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      LevelPill(i),
                      if (i == info.current) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.ink),
                          ),
                          child: const Text(
                            'You are here',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    thresholdLabels[i],
                    style: const TextStyle(
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
        ],
      ),
    );
  }
}
