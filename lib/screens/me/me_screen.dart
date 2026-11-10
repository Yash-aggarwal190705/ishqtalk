import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../navigation/nav.dart';
import '../../shared/coin.dart';
import '../../shared/flag.dart';
import '../../shared/frog_avatar.dart';
import '../../shared/lv_chip.dart';
import '../../state/app_context.dart';
import 'glass_card.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key, this.instant = false});

  final bool instant;

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  @override
  Widget build(BuildContext context) {
    final NavigationState navigation = context.read<NavigationState>();
    final AppContextState app = context.watch<AppContextState>();
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 56 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _GradientHeader(
                app: app,
                navigation: navigation,
                onEdit: () => navigation.push('edit-profile'),
              ),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _CardsGrid(app: app, navigation: navigation),
                    _MenuPanel(navigation: navigation),
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

/// Gradient header: runs under the status bar; content is 216 tall below it.
class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.app,
    required this.navigation,
    required this.onEdit,
  });

  final AppContextState app;
  final NavigationState navigation;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.only(top: top),
      height: top + 216,
      decoration: const BoxDecoration(
        gradient: CssLinearGradient(
          degrees: 160,
          colors: <Color>[AppColors.profileA, AppColors.profileB],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: -40,
              top: -40,
              child: _Blob(size: 176, opacity: .15),
            ),
            const Positioned(
              right: -40,
              top: 64,
              child: _Blob(size: 144, opacity: .18),
            ),
            const Positioned(
              left: 80,
              top: 96,
              child: _Blob(size: 112, opacity: .12),
            ),
            Positioned(left: 16, top: 60, child: FrogAvatar(size: 64, ring: 2)),
            Positioned(
              left: 92,
              top: 66,
              right: 60,
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      app.profileName.trim().isEmpty
                          ? 'Your Name'
                          : app.profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (app.vip) ...<Widget>[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        gradient: CssLinearGradient(
                          degrees: 90,
                          colors: <Color>[AppColors.vipA, AppColors.vipB],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          height: 14 / 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 92,
              top: 98,
              child: Row(
                children: <Widget>[
                  const _MeChip(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppIcon(
                          name: 'user',
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '18',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            height: 16 / 11,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _MeChip(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flag(country: 'India'),
                        SizedBox(width: 4),
                        Text(
                          'India',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            height: 16 / 11,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              right: 12,
              child: AppTap(
                label: 'Edit profile',
                onTap: onEdit,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: AppIcon(
                      name: 'edit',
                      size: 24,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: Row(
                children: <Widget>[
                  _Stat(number: '${app.sentCount}', label: 'Messages sent'),
                  _Stat(number: '${app.following.length}', label: 'Following'),
                  _Stat(
                    number: '${app.visited.length}',
                    label: 'Profiles viewed',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // Soft circle approximating a 60 px gaussian blur.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            AppColors.white.withValues(alpha: opacity),
            AppColors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _MeChip extends StatelessWidget {
  const _MeChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white60,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cards (reference GlassCard from glass_card.dart)
// ---------------------------------------------------------------------------

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({required this.app, required this.navigation});

  final AppContextState app;
  final NavigationState navigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double colW = (constraints.maxWidth - 8) / 2;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: colW,
                child: GlassCard(
                  key: const ValueKey<String>('card-tokens'),
                  tone: GlassTone.tokens,
                  height: 150,
                  peek: 22,
                  centerContent: true,
                  onTap: () => navigation.push('tokens'),
                  decoration: Positioned(
                    right: -12,
                    bottom: -12,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: Opacity(
                        opacity: 0.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color.fromRGBO(255, 170, 60, 0.7),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: Coin(size: 96),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Tokens',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A3E00),
                                ),
                              ),
                              const AppIcon(
                                name: 'chev',
                                size: 16,
                                color: Color(0xFF7A3E00),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 24,
                          child: Row(
                            children: <Widget>[
                              const Coin(size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '${navigation.coins}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A3E00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: colW,
                child: Column(
                  children: <Widget>[
                    GlassCard(
                      key: const ValueKey<String>('card-vip'),
                      tone: GlassTone.vip,
                      height: 71,
                      peek: 14,
                      decoration: Positioned(
                        top: 12,
                        right: 8,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Opacity(
                            opacity: 0.6,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(123, 92, 255, 0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: AppIcon(
                                name: 'diamond',
                                size: 48,
                                color: Color(0xFF7B5CFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'VIP',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 20 / 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3E2A99),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app.vip ? 'Active' : 'Free Bonus',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              height: 16 / 11,
                              color: Color(0xFF6B5BB0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      key: const ValueKey<String>('card-invite'),
                      tone: GlassTone.invite,
                      height: 71,
                      peek: 14,
                      decoration: Positioned(
                        right: 8,
                        bottom: 8,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Opacity(
                            opacity: 0.7,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(255, 92, 138, 0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: AppIcon(
                                name: 'heart',
                                size: 36,
                                color: Color(0xFFFF5C8A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 96,
                            child: Text(
                              'Invite to earn money',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A1F47),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get Bonus',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              height: 16 / 11,
                              color: Color(0xFFB0587A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu panel
// ---------------------------------------------------------------------------

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({required this.navigation});

  final NavigationState navigation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: <Widget>[
          _MenuRow(
            icon: 'clipboard',
            label: 'Daily Bonus',
            dot: true,
            onTap: () => navigation.push('bonus'),
          ),
          _MenuRow(
            icon: 'bag',
            label: 'Package',
            onTap: () => navigation.push('package-props'),
          ),
          _MenuRow(
            icon: 'diamond',
            label: 'My Level',
            trail: LvChip(level: 0, gray: true),
            onTap: () => navigation.push('level'),
          ),
          _MenuRow(
            icon: 'dollar',
            label: 'Credits',
            trail: _CreditsTrail(),
            onTap: () => navigation.push('token-history'),
          ),
          _MenuRow(
            icon: 'gear',
            label: 'App Settings',
            onTap: () => navigation.push('settings'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.dot = false,
    this.trail,
    this.onTap,
  });

  final String icon;
  final String label;
  final bool dot;
  final Widget? trail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onTap,
      enabled: onTap != null,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              AppIcon(name: icon, size: 24, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    if (dot) ...<Widget>[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.badge,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trail != null) ...<Widget>[trail!, const SizedBox(width: 8)],
              const AppIcon(name: 'chev', size: 20, color: AppColors.lvGray),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditsTrail extends StatelessWidget {
  const _CreditsTrail();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: CssLinearGradient(
              degrees: 135,
              colors: <Color>[Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Text(
            'S',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              height: 12 / 10,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '0',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile sheet
// ---------------------------------------------------------------------------

extension on AppContextState {
  bool get vip => false; // TODO: driven by entitlements/server when they exist.
}
