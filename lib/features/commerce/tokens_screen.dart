import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/coin.dart';
import '../../shared/header.dart';
import '../commerce/domain.dart';
import '../commerce/repositories.dart';

class TokensScreen extends StatelessWidget {
  const TokensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SlideIn(
        child: Material(
          color: AppColors.primary,
          child: Column(
            children: <Widget>[
              Header(
                title: 'Get Tokens',
                onBack: navigation.back,
                dark: true,
                right: const AppIcon(
                  name: 'doc',
                  size: 24,
                  color: AppColors.white,
                ),
              ),
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Coin(size: 28),
                    const SizedBox(width: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double size = (constraints.maxWidth * 0.065)
                            .clamp(20.0, 24.0);
                        return Text(
                          '${navigation.coins}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      40 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: const Text(
                            'Limited offer',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PackGrid(packs: TokenRepository.packs),
                      ],
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

class _PackGrid extends StatelessWidget {
  const _PackGrid({required this.packs});

  final List<TokenPack> packs;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < packs.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _PackCard(pack: packs[i])),
            if (i + 1 < packs.length) ...<Widget>[
              const SizedBox(width: 8),
              Expanded(child: _PackCard(pack: packs[i + 1])),
            ],
          ],
        ),
      );
      if (i + 2 < packs.length) rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack});

  final TokenPack pack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 8),
                const Coin(size: 40),
                const SizedBox(height: 12),
                Text(
                  '${pack.tokens}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                if (pack.offPercent != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '${pack.offPercent}% OFF',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppTap(
            onTap: () => showPaySheet(context, pack.price),
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                pack.price,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 18 / 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _paymentMethods = <String>['UPI', 'Card', 'Wallet'];

Future<void> showPaySheet(BuildContext context, String price) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.ink30,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PaySheet(price: price),
  );
}

class _PaySheet extends StatefulWidget {
  const _PaySheet({required this.price});

  final String price;

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  int _selected = 0; // UPI by default

  @override
  Widget build(BuildContext context) {
    // The shared Sheet widget is a Stack overlay and cannot live inside a
    // modal bottom sheet; render the content directly instead.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        32 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Payment method',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _paymentMethods.length; i++)
            InkWell(
              onTap: () => setState(() => _selected = i),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _paymentMethods[i],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == _selected
                              ? AppColors.primary
                              : AppColors.lvGray,
                          width: 2,
                        ),
                      ),
                      child: i == _selected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          AppTap(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                'Pay ${widget.price}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          // TODO: wire Google Play Billing here when it is added.
        ],
      ),
    );
  }
}
