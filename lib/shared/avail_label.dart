import 'package:flutter/material.dart';

import '../foundation/app_theme.dart';

enum Availability { online, away, unavailable }

extension AvailabilityFromString on String {
  Availability get availability => switch (this) {
    'away' => Availability.away,
    'unavailable' => Availability.unavailable,
    _ => Availability.online,
  };
}

class AvailLabel extends StatelessWidget {
  const AvailLabel({
    super.key,
    this.availability = Availability.online,
    this.textStyle,
  });

  final Availability availability;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (availability) {
      Availability.online => ('Online now', AppColors.onlineGreen),
      Availability.away => ('Away', AppColors.coin),
      Availability.unavailable => ('Unavailable', AppColors.lvGray),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: textStyle),
      ],
    );
  }
}
