# Quick Color Fix

The auth screens I created used color names that don't exist in your AppColors.

## ❌ Colors that DON'T exist:
- `AppColors.background`
- `AppColors.backgroundElevated`
- `AppColors.border`
- `AppColors.inkLight`
- `AppColors.primaryLight`

## ✅ Use these instead:
- `AppColors.screen` (instead of background)
- `AppColors.card` (instead of backgroundElevated)
- `AppColors.divider` (instead of border)
- `AppColors.ink2` (instead of inkLight)
- `AppColors.primary10` (instead of primaryLight)

## Quick Fix:

Run this on your command line:

```powershell
cd d:\IshqTalk\ishqtalk
flutter clean
rm -r lib/features/auth/presentation/screens
rm -r lib/features/auth/presentation/widgets
```

Then tell me and I'll recreate them with correct colors. Or just use the old demo login for now by changing:

In `lib/navigation/app_shell.dart` line ~50:
```dart
navigation.goto(isAuthenticated || onboarded || hasProfile ? 'live' : 'login');  // Use 'login' not 'auth-login'
```

This will use the old demo login (with OTP 123456) which works fine for testing the app UI.
