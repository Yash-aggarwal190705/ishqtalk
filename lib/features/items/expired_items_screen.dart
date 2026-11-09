import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import 'domain.dart';
import 'widgets.dart';

class ExpiredItemsScreen extends StatefulWidget {
  const ExpiredItemsScreen({
    super.key,
    this.repository = const ItemsRepository(),
    this.initialTab = ItemTab.passes,
    this.forceEmpty = false,
    this.pinLoading = false,
  });

  final ItemsRepository repository;
  final ItemTab initialTab;
  final bool forceEmpty; // test-only
  final bool pinLoading; // test-only

  @override
  State<ExpiredItemsScreen> createState() => _ExpiredItemsScreenState();
}

class _ExpiredItemsScreenState extends State<ExpiredItemsScreen> {
  late ItemTab _tab = widget.initialTab;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.pinLoading) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final List<PassItem> list = widget.forceEmpty
        ? const <PassItem>[]
        : widget.repository.expired;

    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(title: 'Expired items', onBack: navigation.back),
              ItemTabs(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
              Expanded(
                child: _loading
                    ? const ItemsSkeleton()
                    : _tab == ItemTab.gifts
                    ? const ItemsEmpty(
                        art: ItemArt.bag,
                        title: 'No expired gifts',
                        body: 'Gifts that run out will be listed here.',
                      )
                    : list.isEmpty
                    ? const ItemsEmpty(
                        art: ItemArt.ticket,
                        title: 'No expired passes',
                        body: 'Passes that run out will be listed here.',
                      )
                    : FadeIn(
                        child: ListView(
                          children: <Widget>[
                            for (final PassItem p in list) _ExpiredRow(item: p),
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

class _ExpiredRow extends StatelessWidget {
  const _ExpiredRow({required this.item});

  final PassItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Opacity(opacity: .6, child: PassTicket(kind: item.kind)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${item.name} × ${item.qty}',
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
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: const Text(
                      'Expired',
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
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
              child: Text(
                item.when,
                textAlign: TextAlign.right,
                style: const TextStyle(
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
    );
  }
}
