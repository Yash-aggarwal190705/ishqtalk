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

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({
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
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  late ItemTab _tab = widget.initialTab;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.pinLoading) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  Future<void> _openItemSheet(PassItem item) {
    return showAppSheet<void>(
      context,
      builder: (sheetContext) => _ItemSheet(
        item: item,
        onUseNow: () {
          Navigator.of(sheetContext).pop();
          context.read<NavigationState>().tab('live');
        },
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final List<PassItem> passes = widget.forceEmpty
        ? const <PassItem>[]
        : widget.repository.active;

    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(
                title: 'My items',
                onBack: navigation.back,
                right: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppTap(
                    label: 'Expired items',
                    onTap: () => navigation.push('expired-items'),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        children: <Widget>[
                          const Center(
                            child: AppIcon(
                              name: 'history',
                              size: 24,
                              color: AppColors.ink,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.badge,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.screen,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ItemTabs(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
              Expanded(
                child: _loading
                    ? const ItemsSkeleton()
                    : _tab == ItemTab.passes
                    ? passes.isEmpty
                          ? ItemsEmpty(
                              art: ItemArt.ticket,
                              title: 'No passes yet',
                              body: 'Earn passes with your daily bonus.',
                              action: NeoButton(
                                'See daily bonus',
                                fill: false,
                                // The source pushes Level here (prototype slip):
                                // the label says daily bonus but Level has that
                                // section. Kept per source.
                                onPressed: () => navigation.push('level'),
                              ),
                            )
                          : FadeIn(
                              child: ListView(
                                children: <Widget>[
                                  for (final PassItem p in passes)
                                    _PassRow(
                                      item: p,
                                      onTap: () => _openItemSheet(p),
                                    ),
                                ],
                              ),
                            )
                    : ItemsEmpty(
                        art: ItemArt.gift,
                        title: 'No gifts yet',
                        body: 'Gifts you get in rooms will show up here.',
                        action: OutlineButton52(
                          'Explore rooms',
                          onPressed: () => navigation.tab('explore'),
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

class _PassRow extends StatelessWidget {
  const _PassRow({required this.item, required this.onTap});

  final PassItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              PassTicket(kind: item.kind),
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
                    Text(
                      item.when,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.onlineCyan,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: const Text(
                  'Active',
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
      ),
    );
  }
}

class _ItemSheet extends StatelessWidget {
  const _ItemSheet({
    required this.item,
    required this.onUseNow,
    required this.onClose,
  });

  final PassItem item;
  final VoidCallback onUseNow;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Rendered via showAppSheet (real modal route) so system back closes it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(child: PassTicket(kind: item.kind, width: 80)),
        const SizedBox(height: 12),
        Text(
          '${item.name} × ${item.qty}',
          textAlign: TextAlign.center,
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
          item.desc,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.when,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.sub,
          ),
        ),
        const SizedBox(height: 20),
        NeoButton('Use now', onPressed: onUseNow),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: AppTap(
            onTap: onClose,
            child: const Center(
              child: Text(
                'Close',
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
