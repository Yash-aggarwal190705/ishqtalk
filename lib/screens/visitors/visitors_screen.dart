import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/age_chip.dart';
import '../../shared/call_button.dart';
import '../../shared/header.dart';
import '../../shared/portrait.dart';
import '../../shared/spinner.dart';
import '../../state/models.dart';
import '../../state/profile_repository.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({
    super.key,
    this.repository = const SeedProfileRepository(),
    this.instant = false,
    this.pinLoading = false,
  });

  final ProfileRepository repository;
  final bool instant;
  final bool pinLoading;

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  List<AppUser> _visitors = const <AppUser>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loading = widget.pinLoading || !widget.instant;
    _load();
  }

  Future<void> _load() async {
    final List<AppUser> fetched = await widget.repository.visitors();
    if (!mounted) return;
    setState(() {
      _visitors = fetched;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SlideIn(
      child: Material(
        color: AppColors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Header(title: 'Visitors', onBack: navigation.back),
              Expanded(
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 96),
                        child: const Center(child: Spinner()),
                      )
                    : FadeIn(
                        child: ListView(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.paddingOf(context).bottom,
                          ),
                          children: <Widget>[
                            for (final AppUser user in _visitors)
                              _VisitorRow(
                                user: user,
                                onTap: () => navigation.openUser(user),
                                onCall: () => navigation.call(user),
                              ),
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

class _VisitorRow extends StatelessWidget {
  const _VisitorRow({
    required this.user,
    required this.onTap,
    required this.onCall,
  });

  final AppUser user;
  final VoidCallback onTap;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      label: user.name,
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 48,
              height: 48,
              child: ClipOval(child: Portrait(seed: user.id)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
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
                  AgeChip(age: user.age, country: user.country),
                ],
              ),
            ),
            CallButton(onList: true, onTap: onCall),
          ],
        ),
      ),
    );
  }
}
