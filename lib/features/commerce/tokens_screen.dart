import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import '../../shared/v2.dart';
import '../wallet/domain.dart';
import '../wallet/widgets.dart';

const List<int> tokenAmounts = <int>[100, 500, 1000, 5000, 8000, 10000];

const String _checkSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>';

class TokensScreen extends StatefulWidget {
  const TokensScreen({
    super.key,
    this.initialSelected,
    this.initialSheet,
    this.onPay,
    this.repository = const WalletRepository(),
  });

  /// Test-only.
  final int? initialSelected;
  final String? initialSheet; // 'confirm'

  /// Payment stub: TODO wire a real payment SDK, balance stays unchanged.
  final void Function(int amount)? onPay;
  final WalletRepository repository;

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  int? _sel;

  @override
  void initState() {
    super.initState();
    _sel = widget.initialSelected;
    if (widget.initialSheet == 'confirm') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _sel != null) _openConfirmSheet();
      });
    }
  }

  @override
  void dispose() {
    AppSnack.hide();
    super.dispose();
  }

  void _pay(int amount) {
    widget.onPay?.call(amount);
    AppSnack.show(
      context,
      'Payments arrive after the demo',
      bottom: 120 + MediaQuery.paddingOf(context).bottom,
      ms: 2400,
    );
    // TODO: real payments are not integrated; the balance does not change.
  }

  void _openConfirmSheet() {
    final int n = _sel!;
    showAppSheet<void>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Confirm purchase',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: <Widget>[
              _confirmRow('Tokens', fmtIN(n), false),
              Container(height: 1, color: AppColors.divider),
              _confirmRow('Price', '₹${fmtIN(n)}', false),
              Container(height: 1, color: AppColors.divider),
              _confirmRow('Total', '₹${fmtIN(n)}', true),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'No extra fees. Tokens don’t expire.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            'Pay ₹${fmtIN(n)}',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _pay(n);
            },
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: AppTap(
              onTap: () => Navigator.of(sheetContext).pop(),
              child: const Center(
                child: Text(
                  'Cancel',
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

  Widget _confirmRow(String label, String value, bool total) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: total
                ? const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  )
                : const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.sub,
                  ),
          ),
          Text(
            value,
            style: total
                ? const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  )
                : const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
          ),
        ],
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
              Header(
                title: 'Get tokens',
                onBack: navigation.back,
                right: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppTap(
                    label: 'Token history',
                    onTap: () => navigation.push('token-history'),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: AppIcon(
                          name: 'history',
                          size: 24,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const TokenCoin(size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  fmtIN(widget.repository.balance),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    height: 28 / 24,
                                    fontWeight: FontWeight.w700,
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
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double colW = (constraints.maxWidth - 16) / 2;
                          final List<Widget> rows = <Widget>[];
                          for (int i = 0; i < tokenAmounts.length; i += 2) {
                            rows.add(
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: colW,
                                    child: _TokenCard(
                                      key: ValueKey<String>(
                                        'token-card-${tokenAmounts[i]}',
                                      ),
                                      amount: tokenAmounts[i],
                                      selected: _sel == tokenAmounts[i],
                                      onTap: () => setState(
                                        () => _sel = tokenAmounts[i],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (i + 1 < tokenAmounts.length)
                                    SizedBox(
                                      width: colW,
                                      child: _TokenCard(
                                        key: ValueKey<String>(
                                          'token-card-${tokenAmounts[i + 1]}',
                                        ),
                                        amount: tokenAmounts[i + 1],
                                        selected: _sel == tokenAmounts[i + 1],
                                        onTap: () => setState(
                                          () => _sel = tokenAmounts[i + 1],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                            if (i + 2 < tokenAmounts.length) {
                              rows.add(const SizedBox(height: 16));
                            }
                          }
                          return Column(children: rows);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _sel == null
                            ? 'Pick a card to continue'
                            : 'No extra fees. Tokens don’t expire.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 20 / 14,
                          color: AppColors.sub,
                        ),
                      ),
                    ),
                    NeoButton(
                      _sel == null
                          ? 'Choose an amount'
                          : 'Get ${fmtIN(_sel!)} tokens · ₹${fmtIN(_sel!)}',
                      onPressed: _sel == null ? null : _openConfirmSheet,
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

class _TokenCard extends StatelessWidget {
  const _TokenCard({
    super.key,
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: selected,
      label: '${fmtIN(amount)} tokens, ₹${fmtIN(amount)}',
      excludeSemantics: true,
      child: AppTap(
        onTap: onTap,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(color: AppColors.ink, offset: Offset(3, 3)),
                  ]
                : const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x148B5CF6),
                      offset: Offset(0, 4),
                      blurRadius: 14,
                    ),
                  ],
          ),
          child: Stack(
            children: <Widget>[
              if (selected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    key: const ValueKey('check-badge'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.onlineCyan,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: Center(
                      child: SvgPicture.string(
                        _checkSvg,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.ink,
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: DecoratedBox(
                    // Border drawn here so it does not inset the card content.
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected ? AppColors.ink : AppColors.divider,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 56,
                            child: Center(child: TokenCoin(size: 56)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${fmtIN(amount)} tokens',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              height: 24 / 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            key: ValueKey<String>('price-pill-$amount'),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: selected
                                  ? cssLinear(135, const <Color>[
                                      AppColors.vipA,
                                      AppColors.vipB,
                                    ])
                                  : null,
                              color: selected ? null : AppColors.primary10,
                            ),
                            child: Text(
                              '₹${fmtIN(amount)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                height: 24 / 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
