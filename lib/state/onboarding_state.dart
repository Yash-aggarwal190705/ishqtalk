import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState extends ChangeNotifier {
  OnboardingState({SharedPreferences? preferences})
    : _preferences = preferences {
    onboarded = preferences?.getString(onboardedKey) == '1';
    notificationChoice = preferences?.getString(notificationsKey);
  }

  static const String onboardedKey = 'yourapp.hasOnboarded';
  static const String notificationsKey = 'yourapp.notifications';
  final SharedPreferences? _preferences;
  bool onboarded = false;
  String? notificationChoice;

  void setOnboarded() {
    onboarded = true;
    _preferences?.setString(onboardedKey, '1').catchError((Object _) => false);
    notifyListeners();
  }

  void setNotifChoice(String choice) {
    if (choice != 'allow' && choice != 'deny') {
      throw ArgumentError.value(choice, 'choice');
    }
    notificationChoice = choice;
    _preferences
        ?.setString(notificationsKey, choice)
        .catchError((Object _) => false);
    notifyListeners();
  }

  void reset() {
    onboarded = false;
    notificationChoice = null;
    _preferences?.remove(onboardedKey).catchError((Object _) => false);
    _preferences?.remove(notificationsKey).catchError((Object _) => false);
    notifyListeners();
  }
}
