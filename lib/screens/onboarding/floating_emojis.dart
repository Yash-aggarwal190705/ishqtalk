import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';

class FloatingEmojis extends StatelessWidget {
  const FloatingEmojis({super.key});

  static const _floaters = <(String, double, double)>[
    ('😍', 20, -10),
    ('❤️', 16, 12),
    ('💗', 22, -4),
    ('😍', 14, 8),
    ('❤️', 18, -12),
    ('💗', 15, 6),
  ];

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: SizedBox(
        width: 0,
        height: 0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < _floaters.length; i++)
              Positioned(
                top: 0,
                left: 0,
                child: LoopMotion(
                  duration: const Duration(seconds: 3),
                  delay: Duration(milliseconds: i * 500),
                  builder: (context, phase, idle, child) {
                    final double value = Curves.easeOut.transform(phase);
                    return Opacity(
                      opacity: idle ? 0 : 1 - value,
                      child: Transform.translate(
                        offset: Offset(_floaters[i].$3 * value, -120 * value),
                        child: Transform.scale(
                          scale: .8 + .3 * value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    _floaters[i].$1,
                    style: TextStyle(fontSize: _floaters[i].$2, height: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
