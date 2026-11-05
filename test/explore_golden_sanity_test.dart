import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decodes a saved golden and checks it is a real render: correct size,
/// not uniformly white, and containing the portrait-palette colors used by
/// the card placeholders (proves photos/portraits rendered).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const cases = <String, Size>{
    'explore.png': Size(390, 844),
    'explore_360.png': Size(360, 800),
    'explore_480.png': Size(480, 960),
  };
  for (final entry in cases.entries) {
    test('${entry.key} renders real content', () async {
      final bytes = File('test/goldens/${entry.key}').readAsBytesSync();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      expect(image.width, entry.value.width);
      expect(image.height, entry.value.height);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(data, isNotNull);
      final int width = image.width;
      final int height = image.height;
      int nonWhite = 0;
      final Set<int> colors = {};
      const int stride = 7; // sample every 7th pixel for speed
      for (int y = 0; y < height; y += stride) {
        for (int x = 0; x < width; x += stride) {
          final int offset = (y * width + x) * 4;
          final int r = data!.getUint8(offset);
          final int g = data.getUint8(offset + 1);
          final int b = data.getUint8(offset + 2);
          final int rgb = (r << 16) | (g << 8) | b;
          colors.add(rgb);
          if (rgb != 0xFFFFFF) nonWhite++;
        }
      }
      expect(nonWhite, greaterThan(0));
      // The 8 portrait palettes are all saturated; a real render must contain a
      // meaningful share of chromatic pixels (white/skeleton-only renders are
      // near-gray and would score ~0).
      int chromatic = 0;
      for (int y = 0; y < height; y += stride) {
        for (int x = 0; x < width; x += stride) {
          final int offset = (y * width + x) * 4;
          final int r = data!.getUint8(offset);
          final int g = data.getUint8(offset + 1);
          final int b = data.getUint8(offset + 2);
          final int max = [r, g, b].reduce((a, b) => a > b ? a : b);
          final int min = [r, g, b].reduce((a, b) => a < b ? a : b);
          if (max - min > 40) chromatic++;
        }
      }
      final int sampled = ((width / stride).ceil() * (height / stride).ceil());
      expect(
        chromatic / sampled,
        greaterThan(0.05),
        reason: '${entry.key}: only ${chromatic / sampled} chromatic share',
      );
      image.dispose();
    });
  }
}
