import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import '../../shared/v2.dart';
import 'domain.dart';
import 'widgets.dart';

class TokenHistoryScreen extends StatefulWidget {
  const TokenHistoryScreen({
    super.key,
    this.repository = const WalletRepository(),
    this.forceEmpty = false,
    this.pinLoading = false,
    this.initialSheet = false,
  });

  final WalletRepository repository;
  final bool forceEmpty; // test-only
  final bool pinLoading; // test-only
  final bool initialSheet; // test-only

  @override
  State<TokenHistoryScreen> createState() => _TokenHistoryScreenState();
}

class _TokenHistoryScreenState extends State<TokenHistoryScreen> {
  bool _loading = true;
  TxFilter _filter = TxFilter.defaultFilter;

  @override
  void initState() {
    super.initState();
    if (!widget.pinLoading) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final List<Tx> all = widget.forceEmpty
        ? const <Tx>[]
        : widget.repository.transactions
              .where((t) => txMatches(t, _filter))
              .toList();
    final List<Tx> today = all.where((t) => t.daysAgo == 0).toList();
    final List<Tx> earlier = all.where((t) => t.daysAgo > 0).toList();

    return FadeIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(
                title: 'Token history',
                onBack: navigation.back,
                right: _FilterButton(
                  active: _filter.isActive,
                  onTap: () => _openFilterSheet(navigation),
                ),
              ),
              _BalanceCard(balance: widget.repository.balance),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _loading
                      ? const ShimmerScope(child: _Skeleton())
                      : all.isEmpty
                      ? _EmptyState(
                          noData: widget.forceEmpty,
                          onAction: () {
                            if (widget.forceEmpty) {
                              navigation.push('tokens');
                            } else {
                              setState(() => _filter = TxFilter.defaultFilter);
                            }
                          },
                        )
                      : Column(
                          children: <Widget>[
                            if (today.isNotEmpty)
                              _Group(label: 'Today', rows: today),
                            if (earlier.isNotEmpty)
                              _Group(label: 'Earlier', rows: earlier),
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

  Future<void> _openFilterSheet(NavigationState navigation) {
    return showAppSheet<void>(
      context,
      builder: (sheetContext) => _FilterSheet(
        initial: _filter,
        onShow: (TxFilter value) {
          Navigator.of(sheetContext).pop();
          setState(() => _filter = value);
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppTap(
        label: 'Filter',
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: <Widget>[
              const Center(
                child: AppIcon(name: 'sliders', size: 24, color: AppColors.ink),
              ),
              if (active)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.badge,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.screen, width: 2),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('balance-card'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: const <BoxShadow>[
          // shadow-[0_4px_14px_primary@8%]
          BoxShadow(
            color: Color(0x148B5CF6),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              const TokenCoin(size: 28),
              const SizedBox(width: 8),
              Text(
                '$balance tokens',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const Text(
            '1 token = ₹1',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.rows});

  final String label;
  final List<Tx> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: AppColors.sub,
            ),
          ),
        ),
        for (final Tx t in rows) _TxRow(tx: t),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});

  final Tx tx;

  @override
  Widget build(BuildContext context) {
    final int n = tx.amount.abs();
    return Semantics(
      label:
          '${tx.title}, ${tx.earned ? 'earned' : 'spent'} $n tokens, ${tx.when}',
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              TxLeadIcon(kind: tx.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tx.title,
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
                      tx.when,
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
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${tx.earned ? '+' : '\u2212'}$n',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w600,
                          color: tx.earned ? AppColors.success : AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const TokenCoin(size: 18),
                    ],
                  ),
                  Text(
                    '₹$n',
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
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < 4; i++)
          SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  const ShimmerBox(w: 40, h: 40, circle: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        FractionallySizedBox(
                          widthFactor: 1 / 2,
                          child: ShimmerBox(h: 14),
                        ),
                        SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 1 / 3,
                          child: ShimmerBox(h: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ShimmerBox(w: 48, h: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.noData, required this.onAction});

  final bool noData;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(child: TokenCoin(size: 40)),
          ),
          Text(
            noData ? 'No token activity yet' : 'No matching activity',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            noData
                ? 'Daily check-ins and top-ups will show up here.'
                : 'Try a different type or date range.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            noData ? 'Get tokens' : 'Reset filter',
            fill: false,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.onShow});

  final TxFilter initial;
  final ValueChanged<TxFilter> onShow;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TxFilter _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Filter',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Type',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            for (final TxType type in TxType.values)
              Expanded(
                child: _Segment(
                  label: switch (type) {
                    TxType.all => 'All',
                    TxType.earned => 'Earned',
                    TxType.spent => 'Spent',
                  },
                  selected: _draft.type == type,
                  onTap: () => setState(
                    () => _draft = TxFilter(type: type, range: _draft.range),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Date range',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 8),
        AppTap(
          key: const ValueKey<String>('range-button'),
          label: 'Date range: ${ranges[_draft.range].label}. Tap to change',
          onTap: () => setState(
            () => _draft = TxFilter(
              type: _draft.type,
              range: (_draft.range + 1) % ranges.length,
            ),
          ),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  ranges[_draft.range].label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                Transform.rotate(
                  angle: 3.141592653589793 / 2,
                  child: const AppIcon(
                    name: 'chev',
                    size: 18,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        NeoButton('Show results', onPressed: () => widget.onShow(_draft)),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: AppTap(
            label: 'Reset',
            onTap: () => setState(() => _draft = TxFilter.defaultFilter),
            child: const Center(
              child: Text(
                'Reset',
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
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AppTap(
        onTap: onTap,
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
