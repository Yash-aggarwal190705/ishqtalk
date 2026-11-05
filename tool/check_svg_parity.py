"""Verify the raw Icon path map against its checked-in React reference."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
react = (root.parent / 'app_screens/src/ui.tsx').read_text().split('export function Icon')[0]
dart = (root / 'lib/foundation/app_icons.dart').read_text().split('String _appIconSvg')[0]
react_paths = re.findall(r'\bd="([^"]+)"', react)
dart_paths = re.findall(r'\bd="([^"]+)"', dart)
assert react_paths == dart_paths, 'Icon path data has diverged from ui.tsx'
print(f'PASS: {len(react_paths)} original icon paths preserved verbatim')

login_source = (root.parent / 'app_screens/src/login.tsx').read_text()
login_paths = re.findall(r'\bd="([^"]+)"', login_source)
login_dart = '\n'.join(
    (root / f'lib/screens/onboarding/{name}.dart').read_text()
    for name in ['login_provider_icons', 'login_logo', 'login_coins']
)
ported_paths = re.findall(r'\bd="([^"]+)"', login_dart)
assert login_paths == ported_paths, 'Login SVG path data has diverged from login.tsx'
print(f'PASS: {len(login_paths)} original login SVG paths preserved verbatim')
