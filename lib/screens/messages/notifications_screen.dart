import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/empty_state.dart';
import '../../shared/header.dart';

class _Note {
  const _Note(this.title, this.body, this.date, this.icon);

  final String title;
  final String body;
  final String date;
  final String icon;
}

const List<_Note> _notes = <_Note>[
  _Note(
    'Welcome to YourApp!',
    'Say hi in a live room to start your first chat.',
    '24 Oct',
    'bell',
  ),
  _Note(
    'Daily check-in is ready',
    'Claim your match ticket in Bonus.',
    '24 Oct',
    'calendar',
  ),
  _Note(
    'Tara viewed your profile',
    'Say hi back from Profile visitors.',
    '23 Oct',
    'eye',
  ),
  _Note(
    'Safety tip',
    'Never share personal details in a chat.',
    '21 Oct',
    'shield',
  ),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.empty = false});

  final bool empty; // test-only

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Header(title: 'Notifications', onBack: navigation.back),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: empty
                    ? const EmptyState(
                        title: 'No notifications yet',
                        body: 'New updates will show up here.',
                        child: AppIcon(
                          name: 'bell',
                          size: 28,
                          color: AppColors.ink3,
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          for (final _Note note in _notes)
                            _NotificationRow(note: note),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.note});

  final _Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                name: note.icon,
                size: 26,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  note.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  note.body,
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
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              note.date,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.sub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
