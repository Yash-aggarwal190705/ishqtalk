import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../foundation/app_icons.dart';
import '../../../foundation/app_motion.dart';
import '../../../foundation/app_theme.dart';
import '../../../shared/avail_label.dart';
import '../../../shared/call_button.dart';
import '../../../shared/flag.dart';
import '../../../shared/portrait.dart';
import '../../../state/models.dart';

final String _verifiedCheckSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="none" stroke="${appColorHex(AppColors.white)}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.500l3.200 3L13 4.500"/></svg>';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user, this.onTap, this.onCall});

  final AppUser user;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    height: 16 / 11,
    color: AppColors.white,
  );

  @override
  Widget build(BuildContext context) {
    final bool unavailable = user.avail == 'unavailable';
    return AppTap(
      label: user.name,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 174 / user.h,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _photo(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 96,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0x003B3354), Color(0x8C3B3354)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _nameRow(),
                    const SizedBox(height: 2),
                    AvailLabel(
                      availability: user.avail.availability,
                      textStyle: _labelStyle,
                    ),
                    const SizedBox(height: 2),
                    _metaRow(),
                  ],
                ),
              ),
              if (!unavailable)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CallButton(onTap: onCall),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo() {
    final String? url = user.photoUrl;
    if (url == null || url.isEmpty) return Portrait(seed: user.id);
    final Widget fallback = Portrait(seed: user.id);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }

  Widget _nameRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 105),
          child: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
        if (user.verified) ...<Widget>[
          const SizedBox(width: 3),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.badge,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(
              _verifiedCheckSvg,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _metaRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('${user.age}', style: _labelStyle),
        if (user.country != null) ...<Widget>[
          const SizedBox(width: 8),
          Flag(country: user.country!),
          const SizedBox(width: 4),
          Text(user.country!, style: _labelStyle),
        ],
      ],
    );
  }
}
