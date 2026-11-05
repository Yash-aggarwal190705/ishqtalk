import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundation/app_icons.dart';
import '../foundation/app_motion.dart';
import '../foundation/app_theme.dart';
import 'badge.dart' as app;

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.active,
    required this.onTab,
    this.dark = false,
    this.badge = 0,
    this.dot = false,
  });
  final String active;
  final ValueChanged<String> onTab;
  final bool dark;
  final int badge;
  final bool dot;

  static const _items = <(String, String, String)>[
    ('explore', 'Explore', 'compass'),
    ('live', 'Live', 'live'),
    ('messages', 'Messages', 'chat'),
    ('me', 'Me', 'user'),
  ];

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: SizedBox(
      height: 56 + MediaQuery.paddingOf(context).bottom,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: dark ? 10 : 6,
            sigmaY: dark ? 10 : 6,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark ? AppColors.white35 : AppColors.white90,
                    border: const Border(
                      top: BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 0,
                right: 0,
                height: 56,
                child: Row(
                  children: <Widget>[
                    for (final (id, label, icon) in _items)
                      Expanded(
                        child: Semantics(
                          selected: active == id,
                          child: AppTap(
                            label: label,
                            onTap: () => onTab(id),
                            child: SizedBox(
                              height: 56,
                              child: Center(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: active == id ? 1 : 0,
                                    end: active == id ? 1 : 0,
                                  ),
                                  duration: animationsDisabled(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 200),
                                  curve: tailwindTransition,
                                  builder: (context, value, child) =>
                                      Transform.scale(
                                        scale: .95 + .05 * value,
                                        child: Container(
                                          width: 40,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary10
                                                .withValues(alpha: value),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: <Widget>[
                                              Center(
                                                child: NavIcon(
                                                  kind: icon,
                                                  solid: active == id,
                                                  color: Color.lerp(
                                                    dark
                                                        ? AppColors.ink
                                                        : AppColors.ink2,
                                                    AppColors.primary,
                                                    value,
                                                  )!,
                                                ),
                                              ),
                                              if (id == 'messages' && badge > 0)
                                                Positioned(
                                                  top: -6,
                                                  right: -2,
                                                  child: app.Badge(
                                                    number: badge,
                                                  ),
                                                ),
                                              if (id == 'me' && dot)
                                                Positioned(
                                                  top: 2,
                                                  right: 6,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color:
                                                              AppColors.badge,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
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
  );
}
