import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    // React's onboarding helpers tolerate unavailable local storage as well.
  }
  runApp(MyApp(preferences: preferences));
}
