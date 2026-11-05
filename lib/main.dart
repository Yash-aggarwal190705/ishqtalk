import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Stopwatch startup = Stopwatch()..start();
  if (kDebugMode || kProfileMode) {
    debugPrint('[STARTUP] main start');
  }

  // Only the essential local storage read is awaited before the first frame.
  // It is usually a few ms; the timeout + fallback guarantee a slow disk can
  // never block the first frame.
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
  } catch (_) {
    preferences = null;
  }
  if (kDebugMode || kProfileMode) {
    debugPrint('[STARTUP] prefs loaded in ${startup.elapsedMilliseconds}ms');
  }

  runApp(MyApp(preferences: preferences));
  if (kDebugMode || kProfileMode) {
    debugPrint('[STARTUP] runApp called at ${startup.elapsedMilliseconds}ms');
  }
}
