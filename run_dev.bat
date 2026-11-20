@echo off
REM Run IshqTalk with Supabase configuration
REM This script loads environment variables from .env file

echo Starting IshqTalk with Supabase...
echo.

flutter run ^
  --dart-define=SUPABASE_URL=https://pqbvflfkhnqgaeczdaoh.supabase.co ^
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_XlhZrvIKtg7yLCGAmsGj0A_wsMg-wnz

pause
