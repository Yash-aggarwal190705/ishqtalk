import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/coin.dart';
import '../../shared/header.dart';
import '../commerce/domain.dart';
import '../commerce/repositories.dart';
import '../commerce/widgets.dart';
import '../wallet/domain.dart';

class BonusScreen extends StatefulWidget {
  const BonusScreen({super.key, this.repository});

  final BonusRepository? repository;

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen> {
  late final BonusRepository _repo = widget.repository ?? BonusRepository();
  bool _loaded = false;
  bool _toastVisible = false;

  @override
  void initState() {
    super.initState();
    fakeLoad().then((_) {
      if (mounted) setState(() => _loaded = true);
    });
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _signIn() {
    _repo.signIn();
    setState(() => _toastVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    return SlideIn(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Material(
            color: AppColors.screen,
            child: Column(
              children: <Widget>[
                Container(
                  color: AppColors.white,
                  child: Header(
                    title: 'Bonus',
                    onBack: navigation.back,
                    right: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppTap(
                          onTap: () => navigation.push('package-props'),
                          child: Row(
                            children: <Widget>[
                              const AppIcon(
                                name: 'bag',
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_loaded ? _repo.ticketTotal : 0}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: <Widget>[
                            const Coin(size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${_loaded ? const WalletRepository().balance : 0}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _loaded ? _body(navigation) : _loading()),
              ],
            ),
          ),
          if (_toastVisible)
            Toast(
              message: '+1 Match Ticket',
              onDone: () => setState(() => _toastVisible = false),
            ),
        ],
      ),
    );
  }

  Widget _loading() {
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Text(
                'Daily Bonus',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              AppIcon(name: 'history', size: 16, color: AppColors.ink2),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 48 + 56 + 16),
            child: const LoadingSpinner(),
          ),
        ),
      ],
    );
  }

  Widget _body(NavigationState navigation) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _signInBlock(navigation),
          const SizedBox(height: 12),
          _vipCard(navigation),
          const SizedBox(height: 12),
          _taskCard('Tasks', BonusRepository.tasks, navigation),
          const SizedBox(height: 12),
          _taskCard('Daily Bonus', BonusRepository.daily, navigation),
        ],
      ),
    );
  }

  Widget _signInBlock(NavigationState navigation) {
    final bool signed = _repo.signedInToday;
    final int today = _repo.todayIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Sign in rewards',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            CountdownText(seconds: _repo.signInCountdownSeconds()),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final double gap = 8;
            final double cell = (constraints.maxWidth - 3 * gap) / 4;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (int i = 0; i < 7; i++)
                  RewardCell(
                    index: i,
                    claimed: i < today,
                    active: i == today,
                    width: i == 6 ? cell * 2 + gap : cell,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        AppTap(
          onTap: signed ? null : _signIn,
          enabled: !signed,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: signed
                  ? null
                  : const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFF8B5CF6), Color(0xFFFF6B6B)],
                    ),
              color: signed ? const Color(0xFFE0D4F5) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              signed ? 'Signed in today' : 'Sign in',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: signed ? AppColors.primary : AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _vipCard(NavigationState navigation) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'VIP Bonus',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.cta,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Text(
                    'Sign in for',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const TicketIcon(kind: TicketKind.chat, width: 20),
                  const SizedBox(width: 4),
                  const Text(
                    '+5',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const TicketIcon(kind: TicketKind.match, width: 20),
                  const SizedBox(width: 4),
                  const Text(
                    '+10',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppTap(
            onTap: () => navigation.push('package-props'),
            child: Container(
              width: 64,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: CssLinearGradient(
                  degrees: 90,
                  colors: <Color>[AppColors.vipA, AppColors.vipB],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: const Text(
                'Get VIP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 18 / 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(
    String title,
    List<RewardTask> tasks,
    NavigationState navigation,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              if (title == 'Daily Bonus')
                CountdownText(seconds: _repo.dailyCountdownSeconds()),
            ],
          ),
          for (int i = 0; i < tasks.length; i++)
            TaskRow(
              task: tasks[i],
              last: i == tasks.length - 1,
              onGo: () => _go(tasks[i], navigation),
            ),
        ],
      ),
    );
  }

  void _go(RewardTask task, NavigationState navigation) {
    switch (task.action) {
      case TaskAction.exploreTab:
        navigation.tab('explore');
      case TaskAction.openPackage:
        navigation.push('package-props');
      case TaskAction.none:
        break;
    }
  }

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: <BoxShadow>[
      BoxShadow(color: Color(0x143B3354), offset: Offset(0, 2), blurRadius: 8),
    ],
  );
}
