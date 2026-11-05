import 'dart:io';

import 'package:flutter/services.dart';

import 'port_fixture.dart';

const loginGoldenFallback = ['PortNativeEmoji', 'PortNativeSymbols'];

/// Headless flutter_tester has no native fallback font manager. Use the emoji
/// font already shipped in the SDK and an installed OS CJK font for U+FF0B.
/// These files are test inputs only; neither is bundled with the application.
Future<void> loadLoginGoldenFonts() async {
  await loadPoppins();
  Directory sdk = File(Platform.resolvedExecutable).parent;
  while (!File('${sdk.path}/bin/flutter').existsSync() &&
      sdk.parent.path != sdk.path) {
    sdk = sdk.parent;
  }
  final emoji = File(
    Platform.environment['PORT_EMOJI_FONT'] ??
        '${sdk.path}/engine/src/flutter/txt/third_party/fonts/NotoColorEmoji.ttf',
  );
  String? symbolPath = Platform.environment['PORT_SYMBOL_FONT'];
  final fonts = Directory('/usr/share/fonts');
  if (symbolPath == null && fonts.existsSync()) {
    for (final file in fonts.listSync(recursive: true)) {
      if (file.path.endsWith('/NotoSansCJK-Regular.ttc')) {
        symbolPath = file.path;
        break;
      }
    }
  }
  if (!emoji.existsSync() ||
      symbolPath == null ||
      !File(symbolPath).existsSync()) {
    throw StateError(
      'Headless login goldens need existing native fonts. See test/goldens/README.md; set PORT_EMOJI_FONT and PORT_SYMBOL_FONT if needed.',
    );
  }
  for (final (family, file) in [
    ('PortNativeEmoji', emoji),
    ('PortNativeSymbols', File(symbolPath)),
  ]) {
    final loader = FontLoader(family);
    loader.addFont(
      Future.value(ByteData.sublistView(await file.readAsBytes())),
    );
    await loader.load();
  }
}
