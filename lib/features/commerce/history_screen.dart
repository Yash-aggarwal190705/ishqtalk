import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/header.dart';
import '../../shared/portrait.dart';
import '../commerce/repositories.dart';
import '../commerce/domain.dart';

/// History (call list): pushed screen, slide-in.
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
