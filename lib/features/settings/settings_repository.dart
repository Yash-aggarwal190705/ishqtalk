import 'package:shared_preferences/shared_preferences.dart';

/// Local app settings (settings.tsx): safe mode (default On) and do-not-
/// disturb (default Off) persisted behind a repository so a real backend
/// can replace it later.
class SettingsRepository {
  const SettingsRepository();

  static const String safeModeKey = 'yourapp.safeMode';
  static const String dndKey = 'yourapp.doNotDisturb';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<bool> get safeMode async =>
      (await _prefs()).getBool(safeModeKey) ?? true;
  Future<bool> get doNotDisturb async =>
      (await _prefs()).getBool(dndKey) ?? false;

  void setSafeMode(bool value) {
    _prefs().then(
      (p) => p.setBool(safeModeKey, value).catchError((Object _) => false),
    );
  }

  void setDoNotDisturb(bool value) {
    _prefs().then(
      (p) => p.setBool(dndKey, value).catchError((Object _) => false),
    );
  }
}
