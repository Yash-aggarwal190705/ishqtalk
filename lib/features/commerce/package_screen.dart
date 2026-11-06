import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import '../../shared/portrait.dart';
import '../../shared/sheet.dart';
import '../commerce/domain.dart';
import '../commerce/repositories.dart';
import '../commerce/widgets.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key, this.initialTab = 'Props'});

  final String initialTab;

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  bool _loaded = false;
  late String _tab = widget.initialTab;
  PropItem? _item;

  @override
  void initState() {
    super.initState();
    fakeLoad().then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              children: <Widget>[
                Header(
                  title: 'Package',
                  onBack: navigation.back,
                  right: AppTap(
                    label: 'Usage history',
                    onTap: () => navigation.push('history-list'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        const AppIcon(
                          name: 'history',
                          size: 24,
                          color: AppColors.ink,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: Row(
                    children: <Widget>[
                      for (final String t in <String>['Props', 'Gift'])
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tab = t),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 32,
                                  child: Center(
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        height: 20 / 14,
                                        fontWeight: _tab == t
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: _tab == t
                                            ? AppColors.ink
                                            : AppColors.ink3,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 2,
                                  color: _tab == t
                                      ? AppColors.ink
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: !_loaded
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 128),
                            child: LoadingSpinner(),
                          ),
                        )
                      : _tab == 'Props'
                      ? _propsGrid()
                      : _giftEmpty(),
                ),
              ],
            ),
            if (_item != null)
              _ItemSheet(
                item: _item!,
                onClose: () => setState(() => _item = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _propsGrid() {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < PackageRepository.props.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(
                child: _PropTile(
                  item: PackageRepository.props[i],
                  onTap: () =>
                      setState(() => _item = PackageRepository.props[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _giftEmpty() {
    return FadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 128),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.string(
                _giftSvg,
                width: 96,
                height: 96,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 12),
              const Text(
                'No gifts yet',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gifts you receive will appear here',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _giftSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#DDD5EE" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="9" width="18" height="12" rx="1.5"/><path d="M2 6h20v3H2zM12 6v15M12 6C10 2 6 3 7 5s5 1 5 1zM12 6c2-4 6-3 5-1s-5 1-5 1z"/></svg>';
}

class _PropTile extends StatelessWidget {
  const _PropTile({required this.item, required this.onTap});

  final PropItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: <Widget>[
                TicketIcon(kind: item.kind, width: 44),
                const SizedBox(height: 4),
                Text(
                  '×${item.qty}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
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

class _ItemSheet extends StatelessWidget {
  const _ItemSheet({required this.item, required this.onClose});

  final PropItem item;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Sheet(
      close: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(child: TicketIcon(kind: item.kind, width: 64)),
          const SizedBox(height: 12),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
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
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 20),
          AppTap(
            // shortcut: "Use now" closes only, as in the prototype.
            onTap: onClose,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Text(
                'Use now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: AppTap(
              onTap: onClose,
              child: const Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.ink2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.empty = false});

  final bool empty;

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SlideIn(
      child: Material(
        color: AppColors.screen,
        child: Column(
          children: <Widget>[
            Header(title: 'History', onBack: navigation.back),
            Expanded(
              child: empty || HistoryRepository.calls.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 128),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'No calls yet',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                height: 20 / 14,
                                color: AppColors.ink2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTap(
                              onTap: () => navigation.tab('live'),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: const Text(
                                  'Start chat',
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
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom,
                      ),
                      children: <Widget>[
                        for (final CallRecord record in HistoryRepository.calls)
                          _HistoryRow(record: record),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final CallRecord record;

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: ClipOval(child: Portrait(seed: record.user.id)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    record.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.time,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink2,
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            AppTap(
              label: 'Call back',
              onTap: () => navigation.call(record.user),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(name: 'cam', size: 22, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
