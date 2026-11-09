import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import '../../shared/v2.dart';
import 'domain.dart';

// ---------------------------------------------------------------------------
// PassTicket (myItems.tsx): 40x28, notched sides, dotted perforation.
// ---------------------------------------------------------------------------
class PassTicket extends StatelessWidget {
  const PassTicket({super.key, required this.kind, this.width = 40});

  final String kind; // 'match' | 'chat'
  final double width;

  @override
  Widget build(BuildContext context) {
    final bool match = kind == 'match';
    final String body = match ? '#8B5CF6' : '#2ED3C6';
    final String mark = match ? '#FFFFFF' : '#3B3354';
    final String glyph = match
        ? '<path d="M26.5 19.5s-5.5-3.2-5.5-7a2.9 2.9 0 015.5-1.3A2.9 2.9 0 0132 12.5c0 3.8-5.5 7-5.5 7z" fill="$mark"/>'
        : '<path d="M21.5 9h10a1.5 1.5 0 011.5 1.5v5a1.5 1.5 0 01-1.5 1.5H28l-3 2.5V17h-3.5A1.5 1.5 0 0120 15.5v-5A1.5 1.5 0 0121.5 9z" fill="$mark"/>';
    return SvgPicture.string(
      '<svg viewBox="0 0 40 28" xmlns="http://www.w3.org/2000/svg">'
      '<path d="M6 1h28a5 5 0 015 5v4.5a3.5 3.5 0 000 7V22a5 5 0 01-5 5H6a5 5 0 01-5-5v-4.5a3.5 3.5 0 000-7V6a5 5 0 015-5z" fill="$body"/>'
      '<path d="M13.5 5v18" fill="none" stroke="$mark" stroke-width="1.5" stroke-linecap="round" stroke-dasharray="0.1 3"/>'
      '$glyph</svg>',
      width: width,
      height: width * 28 / 40,
      excludeFromSemantics: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Art (viewBox 24, stroke 1.25, round).
// ---------------------------------------------------------------------------
const String _ticketArtSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8a2 2 0 012-2h14a2 2 0 012 2v2a2 2 0 000 4v2a2 2 0 01-2 2H5a2 2 0 01-2-2v-2a2 2 0 000-4z"/><path d="M14.5 6v2M14.5 11v2M14.5 16v2"/><path d="M8.5 14.5s-2-1.2-2-2.8a1.1 1.1 0 012-.5 1.1 1.1 0 012 .5c0 1.6-2 2.8-2 2.8z"/></svg>';
const String _giftArtSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="9" width="18" height="12" rx="1.5"/><path d="M2 6h20v3H2zM12 6v15M12 6C10 2 6 3 7 5s5 1 5 1zM12 6c2-4 6-3 5-1s-5 1-5 1z"/></svg>';
const String _bagArtSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"><path d="M5 8h14l1 12.5a1 1 0 01-1 1.1H5a1 1 0 01-1-1.1z"/><path d="M8.5 10.5V7a3.5 3.5 0 017 0v3.5"/></svg>';

enum ItemArt { ticket, gift, bag }

class ItemArtIcon extends StatelessWidget {
  const ItemArtIcon({super.key, required this.art, this.size = 56});

  final ItemArt art;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      switch (art) {
        ItemArt.ticket => _ticketArtSvg,
        ItemArt.gift => _giftArtSvg,
        ItemArt.bag => _bagArtSvg,
      },
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}

// ---------------------------------------------------------------------------
// ItemTabs (shared with Expired items): 48 tall, 2 columns, divider bottom,
// selected underline 56x3 vip gradient.
// ---------------------------------------------------------------------------
class ItemTabs extends StatelessWidget {
  const ItemTabs({super.key, required this.tab, required this.onChanged});

  final ItemTab tab;
  final ValueChanged<ItemTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: <Widget>[
          for (final ItemTab t in ItemTab.values)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(t),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Text(
                          t == ItemTab.passes ? 'Passes' : 'Gifts',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: t == tab
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: t == tab ? AppColors.ink : AppColors.sub,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: t == tab
                            ? cssLinear(135, const <Color>[
                                AppColors.vipA,
                                AppColors.vipB,
                              ])
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton: 4 rows (40x28 ticket, two bars, 56x24 pill).
// ---------------------------------------------------------------------------
class ItemsSkeleton extends StatelessWidget {
  const ItemsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < 4; i++)
            SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    const ShimmerBox(w: 40, h: 28, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          FractionallySizedBox(
                            widthFactor: 1 / 2,
                            child: ShimmerBox(h: 14),
                          ),
                          SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 2 / 3,
                            child: ShimmerBox(h: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const ShimmerBox(w: 56, h: 24, radius: 999),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty (112 circle, title 20/700, body 16/75, optional action).
// ---------------------------------------------------------------------------
class ItemsEmpty extends StatelessWidget {
  const ItemsEmpty({
    super.key,
    required this.art,
    required this.title,
    required this.body,
    this.action,
  });

  final ItemArt art;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Center(child: ItemArtIcon(art: art)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.sub,
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OutlineButton52 (secondaryBtn): 52 tall, radius 20, 2px primary border.
// ---------------------------------------------------------------------------
class OutlineButton52 extends StatelessWidget {
  const OutlineButton52(this.label, {super.key, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppTap(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
